#!/usr/bin/env python3
"""Download open-licensed Hebrew <-> Russian sources into /tmp/nexus_open_hebrew.

Sources (all permissive / share-alike open data):
1. hermitdave/FrequencyWords (he_50k.txt, CC BY-SA 4.0)
2. Kaikki.org English Wiktionary Hebrew JSONL (CC BY-SA 4.0)
3. Kaikki.org Russian Wiktionary Hebrew JSONL or Russian translations (CC BY-SA 4.0)
4. Tatoeba API v1 Hebrew <-> Russian sentences (CC BY 2.0 FR / CC0)
"""

from __future__ import annotations

import json
import pathlib
import re
import subprocess
import sys
import urllib.parse

CACHE_DIR = pathlib.Path("/tmp/nexus_open_hebrew")
FREQ_URL = (
    "https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/"
    "content/2016/he/he_50k.txt"
)
KAIKKI_HE_INDEX = "https://kaikki.org/dictionary/Hebrew/index.html"
KAIKKI_RU_WIKI_INDEX = "https://kaikki.org/ruwiktionary/index.html"
KAIKKI_RU_EN_FALLBACK = (
    "https://kaikki.org/dictionary/Russian/kaikki.org-dictionary-Russian.jsonl"
)
TATOEBA_API = "https://api.tatoeba.org/v1/sentences"
USER_AGENT = "NexusHebrewAppETL/1.0 (+https://kaikki.org)"


def _curl_fetch_text(url: str) -> str:
    proc = subprocess.run(
        ["/usr/bin/curl", "-fsSL", "--max-time", "30", "-A", USER_AGENT, url],
        capture_output=True,
        text=True,
        check=True,
    )
    return proc.stdout


def _curl_download_file(url: str, dest: pathlib.Path) -> pathlib.Path:
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.exists() and dest.stat().st_size > 1024:
        print(f"Using cached {dest} ({dest.stat().st_size} bytes)")
        return dest

    tmp = dest.with_suffix(dest.suffix + ".part")
    print(f"Downloading {url} -> {dest}", flush=True)
    subprocess.run(
        [
            "/usr/bin/curl",
            "-fsSL",
            "--max-time",
            "300",
            "-A",
            USER_AGENT,
            "-o",
            str(tmp),
            url,
        ],
        check=True,
    )
    tmp.replace(dest)
    print(f"Saved {dest} ({dest.stat().st_size} bytes)")
    return dest


def _find_kaikki_he_jsonl_url() -> str:
    html = _curl_fetch_text(KAIKKI_HE_INDEX)
    matches = re.findall(r'href="([^"]*Hebrew[^"]*\.jsonl(?:\.gz)?)"', html)
    for preferred in matches:
        if "all" in preferred.lower() or preferred.endswith(
            ("Hebrew.jsonl.gz", "Hebrew.jsonl")
        ):
            return (
                preferred
                if preferred.startswith("http")
                else "https://kaikki.org/dictionary/Hebrew/" + preferred.lstrip("./")
            )
    if matches:
        first = matches[0]
        return (
            first
            if first.startswith("http")
            else "https://kaikki.org/dictionary/Hebrew/" + first.lstrip("./")
        )
    return "https://kaikki.org/dictionary/Hebrew/kaikki.org-dictionary-Hebrew.jsonl"


def _find_ruwiktionary_hebrew_url() -> str | None:
    try:
        html = _curl_fetch_text(KAIKKI_RU_WIKI_INDEX)
    except subprocess.CalledProcessError as exc:
        print(f"ruwiktionary index check failed: {exc}")
        return None

    # Look for Hebrew / Иврит language link on ruwiktionary page
    links = re.findall(r'href="([^"]+)"', html)
    print("ruwiktionary index links count:", len(links))
    for href in links:
        decoded = urllib.parse.unquote(href)
        if "Иврит" in decoded or "Hebrew" in decoded or "/he/" in decoded.lower():
            print("Matched ruwiktionary link:", decoded, "->", href)
            if href.endswith((".jsonl", ".jsonl.gz")):
                return urllib.parse.urljoin(KAIKKI_RU_WIKI_INDEX, href)
            sub_url = urllib.parse.urljoin(KAIKKI_RU_WIKI_INDEX, href)
            try:
                sub_html = _curl_fetch_text(sub_url)
                sub_matches = re.findall(r'href="([^"]+\.jsonl(?:\.gz)?)"', sub_html)
                print("  subpage jsonl links:", sub_matches[:5])
                if sub_matches:
                    return urllib.parse.urljoin(sub_url, sub_matches[0])
            except subprocess.CalledProcessError:
                pass
    return None


def _fetch_tatoeba_examples(dest: pathlib.Path, pages: int = 8) -> None:
    if dest.exists() and dest.stat().st_size > 1024:
        print(f"Using cached {dest} ({dest.stat().st_size} bytes)")
        return

    all_items: list[dict[str, object]] = []
    seen_ids: set[int] = set()
    # Fetch short practical sentences in Hebrew with Russian translations
    for word_count in ("2-5", "1-3", "4-8"):
        for page in range(1, 4):
            params = urllib.parse.urlencode(
                {
                    "lang": "heb",
                    "trans:lang": "rus",
                    "trans:is_direct": "yes",
                    "word_count": word_count,
                    "sort": "relevance",
                    "limit": "50",
                    "page": str(page),
                }
            )
            url = f"{TATOEBA_API}?{params}"
            try:
                raw = _curl_fetch_text(url)
                payload = json.loads(raw)
            except (subprocess.CalledProcessError, json.JSONDecodeError) as exc:
                print(f"Tatoeba batch ({word_count} p{page}) skipped: {exc}")
                continue
            rows = payload.get("data") or payload.get("results") or []
            for row in rows:
                if not isinstance(row, dict):
                    continue
                sid = row.get("id")
                if isinstance(sid, int) and sid not in seen_ids:
                    seen_ids.add(sid)
                    all_items.append(row)
            if len(all_items) >= pages * 50:
                break

    dest.write_text(
        json.dumps({"data": all_items}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(f"Saved {len(all_items)} Tatoeba heb<->rus sentences to {dest}")


def main() -> int:
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    _curl_download_file(FREQ_URL, CACHE_DIR / "he_50k.txt")

    kaikki_he_url = _find_kaikki_he_jsonl_url()
    he_name = pathlib.PurePosixPath(kaikki_he_url).name or "kaikki_he.jsonl"
    _curl_download_file(kaikki_he_url, CACHE_DIR / he_name)

    ruwiki_he_url = _find_ruwiktionary_hebrew_url()
    if ruwiki_he_url:
        ru_name = urllib.parse.unquote(
            pathlib.PurePosixPath(urllib.parse.urlparse(ruwiki_he_url).path).name
        )
        _curl_download_file(ruwiki_he_url, CACHE_DIR / f"ruwiki_{ru_name}")
    else:
        print("No dedicated ruwiktionary Hebrew jsonl; downloading Kaikki Russian reverse-translations...")
        _curl_download_file(KAIKKI_RU_EN_FALLBACK, CACHE_DIR / "kaikki_ru_from_en.jsonl")

    _fetch_tatoeba_examples(CACHE_DIR / "tatoeba_heb_rus.json")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except subprocess.CalledProcessError as exc:
        print(f"Download failed: {exc}", file=sys.stderr)
        raise SystemExit(exc.returncode or 1)
