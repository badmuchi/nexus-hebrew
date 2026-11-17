#!/usr/bin/env python3
"""Generate studio-normalized Hebrew MP3 assets for bundled seed packs.

Priority cascade per entry:
1. Real native-speaker recordings from Wikimedia Commons / Lingua Libre (via Kaikki
   open dumps, strictly filtered to permissive licenses and unambiguous vocalized
   single words so homographs like אִם vs אֵם never collide).
2. Microsoft Neural Hebrew voices (`he-IL-HilaNeural`, `he-IL-AvriNeural`) via
   `edge-tts` for full-sentence dialogue/listening tracks, homographs, and words
   without native Wikimedia recordings.
3. macOS `say -v Carmit` fallback only when `edge-tts` is unavailable and
   `--allow-robot-fallback` is set.

Every output MP3 is trimmed of dead silence, loudness-normalized (`-16 LUFS`),
and verified with `ffprobe` so playback volume and clarity stay consistent.
"""

from __future__ import annotations

import argparse
import asyncio
import hashlib
import json
import os
import re
import subprocess
import tempfile
import unicodedata
import urllib.error
import urllib.request
from pathlib import Path
from typing import Optional

try:
    import edge_tts  # type: ignore[import-not-found]
except ImportError:  # pragma: no cover - optional in bare system python
    edge_tts = None

ROOT = Path(__file__).resolve().parent.parent
CACHE_DIR = Path("/tmp/nexus_open_hebrew")
AUDIO_CACHE_DIR = CACHE_DIR / "audio_cache"
KAIKKI_EN_PATH = CACHE_DIR / "kaikki.org-dictionary-Hebrew.jsonl"

FFMPEG_BIN = "/opt/homebrew/bin/ffmpeg"
FFPROBE_BIN = "/opt/homebrew/bin/ffprobe"
FALLBACK_VOICE = "Carmit"
NEURAL_FEMALE = "he-IL-HilaNeural"
NEURAL_MALE = "he-IL-AvriNeural"
USER_AGENT = "NexusHebrewApp/1.0 (https://github.com/nexus-hebrew; open-source educational pack)"

CANTILLATION_AND_RARE_RE = re.compile(
    r"[\u0591-\u05AF\u05BD\u05BF\u05C0\u05C3\u200E\u200F\u202A-\u202E\u2066-\u2069]"
)
NIKKUD_RE = re.compile(r"[\u0591-\u05C7]")
HE_LETTERS_RE = re.compile(r"[\u05D0-\u05EA]")
MULTI_SPACE_RE = re.compile(r"\s+")

AUDIO_FILTER_CHAIN = (
    "highpass=f=75,"
    "silenceremove=start_periods=1:start_threshold=-42dB:detection=peak,"
    "areverse,"
    "silenceremove=start_periods=1:start_threshold=-42dB:detection=peak,"
    "areverse,"
    "afade=t=in:st=0:d=0.012,"
    "loudnorm=I=-16:TP=-1.5:LRA=11"
)


def strip_nikkud(raw: str) -> str:
    return NIKKUD_RE.sub("", unicodedata.normalize("NFC", raw or "")).strip()


def sanitize_for_speech(raw: str) -> str:
    text = unicodedata.normalize("NFC", raw)
    text = CANTILLATION_AND_RARE_RE.sub("", text)
    text = (
        text.replace("\u05BE", " ")
        .replace("—", ", ")
        .replace("–", ", ")
        .replace("·", ", ")
        .replace(";", ", ")
        .replace("/", ", ")
        .replace("(", " ")
        .replace(")", " ")
        .replace("[", " ")
        .replace("]", " ")
    )
    return MULTI_SPACE_RE.sub(" ", text).strip()


def is_external_url(value: str | None) -> bool:
    if not value:
        return False
    lower = value.strip().lower()
    return lower.startswith("http://") or lower.startswith("https://")


def _is_permissive_wikimedia_url(url: str, license_str: str | None) -> bool:
    lower_url = url.lower()
    if "ll-q9288" in lower_url:
        return True
    if not license_str:
        return True  # Kaikki Wikimedia Commons audio without NC tag
    upper = license_str.upper()
    if "NC" in upper or "ND" in upper or "FAIR" in upper:
        return False
    return any(tok in upper for tok in ("CC", "PUBLIC", "PD", "FREE", "GPL"))


def build_wikimedia_audio_index(kaikki_path: Path = KAIKKI_EN_PATH) -> dict[str, str]:
    """Map unambiguous stripped Hebrew words -> native Wikimedia Commons audio URL."""
    if not kaikki_path.exists():
        return {}

    vocalized_forms: dict[str, set[str]] = {}
    urls_by_stripped: dict[str, list[str]] = {}

    with kaikki_path.open("r", encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if not line:
                continue
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue

            word = unicodedata.normalize("NFC", str(entry.get("word", "")).strip())
            stripped = strip_nikkud(word)
            if not stripped or " " in stripped or len(HE_LETTERS_RE.findall(stripped)) < 2:
                continue

            canons = [
                unicodedata.normalize("NFC", str(f.get("form", "")).strip())
                for f in entry.get("forms", [])
                if "canonical" in f.get("tags", []) and f.get("form")
            ]
            bucket = vocalized_forms.setdefault(stripped, set())
            if canons:
                bucket.update(canons)
            elif word != stripped:
                bucket.add(word)
            else:
                bucket.add(stripped)

            sounds = entry.get("sounds") or []
            for s in sounds:
                if not isinstance(s, dict):
                    continue
                url = s.get("mp3_url") or s.get("ogg_url")
                if not url or not isinstance(url, str):
                    continue
                if not _is_permissive_wikimedia_url(url, s.get("license")):
                    continue
                url_list = urls_by_stripped.setdefault(stripped, [])
                if s.get("mp3_url") and url not in url_list:
                    url_list.insert(0, url)
                elif url not in url_list:
                    url_list.append(url)

    safe_index: dict[str, str] = {}
    for stripped, urls in urls_by_stripped.items():
        # Only use native Wikimedia recording when stripped spelling is non-homographic
        # (single vocalized form) or shares a single unique recording URL.
        variants = vocalized_forms.get(stripped, set())
        if len(variants) <= 1 and urls:
            safe_index[stripped] = urls[0]
    return safe_index


def _probe_duration(path: Path) -> Optional[float]:
    if not path.exists() or path.stat().st_size < 400:
        return None
    proc = subprocess.run(
        [
            FFPROBE_BIN,
            "-v",
            "error",
            "-show_entries",
            "format=duration",
            "-of",
            "default=noprint_wrappers=1:nokey=1",
            str(path),
        ],
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        return None
    try:
        return float(proc.stdout.strip())
    except ValueError:
        return None


def _transcode_and_normalize(src_audio: Path, out_mp3: Path, *, max_duration: float = 16.0) -> bool:
    out_mp3.parent.mkdir(parents=True, exist_ok=True)
    tmp_out = out_mp3.with_suffix(".tmp.mp3")
    proc = subprocess.run(
        [
            FFMPEG_BIN,
            "-y",
            "-i",
            str(src_audio),
            "-af",
            AUDIO_FILTER_CHAIN,
            "-ac",
            "1",
            "-ar",
            "24000",
            "-b:a",
            "64k",
            str(tmp_out),
        ],
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        tmp_out.unlink(missing_ok=True)
        return False
    dur = _probe_duration(tmp_out)
    if dur is None or dur < 0.14 or dur > max_duration:
        tmp_out.unlink(missing_ok=True)
        return False
    tmp_out.replace(out_mp3)
    return True


def _download_wikimedia_sync(url: str) -> Optional[Path]:
    AUDIO_CACHE_DIR.mkdir(parents=True, exist_ok=True)
    digest = hashlib.sha256(url.encode("utf-8")).hexdigest()[:16]
    ext = ".mp3" if ".mp3" in url.lower() else ".ogg"
    cached = AUDIO_CACHE_DIR / f"{digest}{ext}"
    if cached.exists() and cached.stat().st_size > 1000:
        return cached

    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(req, timeout=12) as resp:
            if resp.status != 200:
                return None
            data = resp.read()
        if len(data) < 1000:
            return None
        cached.write_bytes(data)
        return cached
    except (urllib.error.URLError, TimeoutError, OSError):
        return None


async def _synthesize_edge_tts_raw(text: str, voice: str, rate: str, out_path: Path) -> bool:
    if edge_tts is None:
        return False
    for attempt in range(3):
        try:
            comm = edge_tts.Communicate(text, voice=voice, rate=rate)
            await comm.save(str(out_path))
            if out_path.exists() and out_path.stat().st_size > 400:
                return True
        except Exception:  # noqa: BLE001 - network/WS retry
            await asyncio.sleep(0.5 * (attempt + 1))
    return False


def _synthesize_carmit_raw(text: str, out_aiff: Path) -> bool:
    proc = subprocess.run(
        ["/usr/bin/say", "-v", FALLBACK_VOICE, "-o", str(out_aiff), text],
        capture_output=True,
        text=True,
    )
    return proc.returncode == 0 and out_aiff.exists() and out_aiff.stat().st_size > 400


async def _produce_one(
    *,
    sem: asyncio.Semaphore,
    total: int,
    text: str,
    out_mp3: Path,
    voice: str,
    wikimedia_url: Optional[str],
    overwrite: bool,
    allow_robot_fallback: bool,
    stats: dict[str, int],
) -> None:
    def record(key: str) -> None:
        stats[key] += 1
        done = sum(stats.values())
        if done % 50 == 0 or done == total:
            print(
                f"Progress {done}/{total} -> "
                f"wikimedia={stats['wikimedia']}, neural={stats['neural']}, "
                f"skipped={stats['skipped']}, failed={stats['failed']}",
                flush=True,
            )

    if out_mp3.exists() and not overwrite and _probe_duration(out_mp3) is not None:
        record("skipped")
        return

    cleaned = sanitize_for_speech(text)
    if not cleaned:
        return

    async with sem:
        # 1. Try native Wikimedia speaker recording when available and unambiguous
        if wikimedia_url:
            cached_src = await asyncio.to_thread(_download_wikimedia_sync, wikimedia_url)
            if cached_src is not None:
                ok = await asyncio.to_thread(_transcode_and_normalize, cached_src, out_mp3)
                if ok:
                    record("wikimedia")
                    return

        # 2. Try Microsoft Neural Hebrew TTS (`he-IL-HilaNeural` / `he-IL-AvriNeural`)
        if edge_tts is not None:
            word_count = len(cleaned.split())
            rate = "-8%" if word_count <= 2 else "-4%"
            with tempfile.TemporaryDirectory() as tmpdir:
                raw_mp3 = Path(tmpdir) / "neural.mp3"
                if await _synthesize_edge_tts_raw(cleaned, voice, rate, raw_mp3):
                    ok = await asyncio.to_thread(_transcode_and_normalize, raw_mp3, out_mp3)
                    if ok:
                        record("neural")
                        return

        # 3. Last-resort macOS Carmit fallback
        if allow_robot_fallback:
            with tempfile.TemporaryDirectory() as tmpdir:
                raw_aiff = Path(tmpdir) / "carmit.aiff"
                ok_say = await asyncio.to_thread(_synthesize_carmit_raw, cleaned, raw_aiff)
                if ok_say and await asyncio.to_thread(_transcode_and_normalize, raw_aiff, out_mp3):
                    record("carmit")
                    return

        record("failed")


def _collect_jobs(
    *,
    dict_offline_limit: int,
    wikimedia_index: dict[str, str],
) -> tuple[list[dict[str, object]], dict[str, object]]:
    jobs: list[dict[str, object]] = []
    seen_paths: set[str] = set()

    def add_job(text: str, rel_asset: str, voice: str, allow_wikimedia: bool) -> None:
        if rel_asset in seen_paths:
            return
        seen_paths.add(rel_asset)
        wiki_url = None
        if allow_wikimedia and len(sanitize_for_speech(text).split()) <= 1:
            wiki_url = wikimedia_index.get(strip_nikkud(text))
        jobs.append(
            {
                "text": text,
                "out_mp3": ROOT / rel_asset,
                "voice": voice,
                "wikimedia_url": wiki_url,
            }
        )

    # 1. Dialogues: shopkeeper מוֹכֵר reads in natural male neural voice
    dialogue_path = ROOT / "assets/seed/dialogues_seed.json"
    dialogues = json.loads(dialogue_path.read_text(encoding="utf-8"))
    for node in dialogues:
        existing = node.get("audio_path")
        if is_external_url(existing):
            continue
        rel_asset = existing or f"assets/audio/dialogue/{node['id']}.mp3"
        node["audio_path"] = rel_asset
        add_job(node["line_hebrew"], rel_asset, NEURAL_MALE, allow_wikimedia=False)

    # 2. Listening: alternate HilaNeural & AvriNeural for natural speaker variety
    listening_path = ROOT / "assets/seed/listening_seed.json"
    listening_payload = json.loads(listening_path.read_text(encoding="utf-8"))
    for idx, item in enumerate(listening_payload["exercises"]):
        existing = item.get("audio_url")
        if is_external_url(existing):
            continue
        rel_asset = existing or f"assets/audio/listening/{item['id']}.mp3"
        item["audio_url"] = rel_asset
        voice = NEURAL_FEMALE if idx % 2 == 0 else NEURAL_MALE
        add_job(item["transcript_vocalized"], rel_asset, voice, allow_wikimedia=False)

    # 3. SRS: native Wikimedia single words where unambiguous + neural for phrases/others
    srs_path = ROOT / "assets/seed/srs_seed.json"
    srs_cards = json.loads(srs_path.read_text(encoding="utf-8"))
    for idx, card in enumerate(srs_cards):
        existing = card.get("audio_url")
        if is_external_url(existing):
            continue
        rel_asset = existing or f"assets/audio/srs/{card['id']}.mp3"
        card["audio_url"] = rel_asset
        is_single = card.get("category") != "phrase"
        add_job(
            card["hebrew_vocalized"],
            rel_asset,
            NEURAL_FEMALE if idx % 3 != 0 else NEURAL_MALE,
            allow_wikimedia=is_single,
        )

    # 4. Dictionary: cover up to `dict_offline_limit` (default all 500!) offline
    dict_path = ROOT / "assets/seed/dictionary_seed.json"
    dict_entries: list[dict[str, object]] = []
    if dict_path.exists():
        dict_entries = json.loads(dict_path.read_text(encoding="utf-8"))
        covered = 0
        for entry in dict_entries:
            existing = entry.get("audio_url")
            if is_external_url(existing):
                continue
            if covered >= dict_offline_limit:
                break
            rel_asset = existing or f"assets/audio/dictionary/{entry['id']}.mp3"
            entry["audio_url"] = rel_asset
            covered += 1
            is_single = entry.get("category") != "phrase"
            add_job(
                str(entry["hebrew_vocalized"]),
                str(rel_asset),
                NEURAL_FEMALE,
                allow_wikimedia=is_single,
            )

    manifests = {
        "dialogue": (dialogue_path, dialogues),
        "listening": (listening_path, listening_payload),
        "srs": (srs_path, srs_cards),
        "dictionary": (dict_path, dict_entries),
    }
    return jobs, manifests


async def _run_pipeline(args: argparse.Namespace) -> dict[str, int]:
    if edge_tts is None and not args.allow_robot_fallback:
        raise RuntimeError(
            "edge_tts package is not installed in this Python interpreter. "
            "Run with `/tmp/tts_venv/bin/python tool/generate_seed_audio.py` or pass --allow-robot-fallback."
        )

    wikimedia_index = build_wikimedia_audio_index() if args.with_wikimedia else {}
    print(f"Indexed {len(wikimedia_index)} unambiguous Wikimedia Commons native recordings.")

    jobs, manifests = _collect_jobs(
        dict_offline_limit=args.dict_offline_limit,
        wikimedia_index=wikimedia_index,
    )
    print(f"Processing {len(jobs)} audio assets (overwrite={args.overwrite})...")

    sem = asyncio.Semaphore(args.concurrency)
    stats = {"wikimedia": 0, "neural": 0, "carmit": 0, "skipped": 0, "failed": 0}
    total_jobs = len(jobs)
    tasks = [
        _produce_one(
            sem=sem,
            total=total_jobs,
            text=str(job["text"]),
            out_mp3=job["out_mp3"],  # type: ignore[arg-type]
            voice=str(job["voice"]),
            wikimedia_url=job["wikimedia_url"],  # type: ignore[arg-type]
            overwrite=args.overwrite,
            allow_robot_fallback=args.allow_robot_fallback,
            stats=stats,
        )
        for job in jobs
    ]
    await asyncio.gather(*tasks)

    for key, (path, payload) in manifests.items():
        if key == "dictionary" and not path.exists():
            continue
        path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    return stats


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--overwrite", action="store_true", help="Regenerate existing MP3 files.")
    parser.add_argument(
        "--dict-offline-limit",
        type=int,
        default=500,
        help="Total dictionary entries given bundled offline MP3s (default: all 500).",
    )
    parser.add_argument(
        "--with-wikimedia",
        action=argparse.BooleanOptionalAction,
        default=True,
        help="Prefer unambiguous Wikimedia Commons native speaker recordings for single words.",
    )
    parser.add_argument(
        "--allow-robot-fallback",
        action="store_true",
        help="Allow macOS say -v Carmit fallback when edge-tts is unavailable.",
    )
    parser.add_argument(
        "--concurrency",
        type=int,
        default=6,
        help="Max concurrent synthesis/download workers.",
    )
    args = parser.parse_args()

    os.environ.setdefault("PATH", "/opt/homebrew/bin:/usr/bin:/bin")
    stats = asyncio.run(_run_pipeline(args))
    print(f"Done! Audio stats: {stats}")
    return 1 if stats["failed"] > 0 else 0


if __name__ == "__main__":
    raise SystemExit(main())
