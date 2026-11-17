#!/usr/bin/env python3
"""Build a high-quality, frequency-ranked Hebrew-Russian dictionary seed pack.

Combines open-licensed sources downloaded into `/tmp/nexus_open_hebrew`:
1. `hermitdave/FrequencyWords` (`he_50k.txt`, CC BY-SA 4.0) for real conversational ranking.
2. Kaikki.org Russian Wiktionary Hebrew dump (`ruwiki_kaikki.org-dictionary-Иврит.jsonl`, CC BY-SA 4.0)
   for Russian glosses and forms.
3. Kaikki.org English Wiktionary Hebrew dump (`kaikki.org-dictionary-Hebrew.jsonl`, CC BY-SA 4.0)
   for canonical nikkud, stressed romanization, roots (shoresh), binyanim, and IPA matching.
4. Existing app seed entries (`srs_seed.json` and `grammar_verbs_seed.json`) so built-in deck
   items are always searchable inside the dictionary with offline MP3 links where available.
"""

from __future__ import annotations

import collections
import hashlib
import json
import pathlib
import re
import sys
import unicodedata
from typing import Any, Optional

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import import_open_hebrew as etl  # noqa: E402

CACHE_DIR = pathlib.Path("/tmp/nexus_open_hebrew")
FREQ_PATH = CACHE_DIR / "he_50k.txt"
RUWIKI_PATH = CACHE_DIR / "ruwiki_kaikki.org-dictionary-Иврит.jsonl"
ENWIKI_PATH = CACHE_DIR / "kaikki.org-dictionary-Hebrew.jsonl"

ROOT_DIR = pathlib.Path(__file__).resolve().parent.parent
SRS_SEED_PATH = ROOT_DIR / "assets/seed/srs_seed.json"
GRAMMAR_SEED_PATH = ROOT_DIR / "assets/seed/grammar_verbs_seed.json"
OUTPUT_PATH = ROOT_DIR / "assets/seed/dictionary_seed.json"

_NIKKUD_RE = re.compile(r"[\u0591-\u05C7]")
_HE_LETTER_RE = re.compile(r"[\u05D0-\u05EA]")
_BAD_GLOSS_PREFIXES = (
    "женск.",
    "мужск.",
    "мн.",
    "ед.",
    "форма ",
    "сопряж",
    "причастие",
    "деепричастие",
    "прошедшее",
    "настоящее",
    "будущее",
    "то же, что",
    "сокращ",
    "вариант ",
)
_ARCHAIC_GLOSS_MARKERS = ("библ.", "книжн.", "устар.", "религ.")
_ARCHAIC_EXAMPLE_MARKERS = (
    "фараон",
    "иегов",
    "господ",
    "моисе",
    "соломон",
    "давид",
    "ковчег",
    "ноах",
    "шмот",
    "берешит",
    "вавилон",
    "фараона",
    "израилевы",
    "царя ",
)
_POSSESSIVE_OR_SKIP_TAGS = {
    "table-tags",
    "inflection-template",
    "class",
    "construct",
    "first-person",
    "second-person",
    "third-person",
    "suffix",
    "pronominal",
}
_POS_EQUIV: dict[str, set[str]] = {
    "noun": {"noun"},
    "verb": {"verb", "adv"},
    "adj": {"adj", "adjective"},
    "adv": {"adv", "adverb", "prep", "conj", "part", "particle", "noun"},
    "prep": {"prep", "preposition", "adv"},
    "pron": {"pron", "pronoun", "det"},
    "conj": {"conj", "conjunction", "adv", "prep"},
    "intj": {"intj", "interjection", "phrase"},
    "num": {"num", "numeral"},
    "phrase": {"phrase", "idiom", "proverb", "intj"},
}


def strip_nikkud(text: str) -> str:
    return _NIKKUD_RE.sub("", unicodedata.normalize("NFC", text or "")).strip()


def clean_hebrew_plain(text: str) -> str:
    return strip_nikkud(text).replace("\u05BE", " ").strip()


def load_frequency_ranks(path: pathlib.Path) -> dict[str, int]:
    ranks: dict[str, int] = {}
    with path.open("r", encoding="utf-8") as handle:
        for idx, line in enumerate(handle, start=1):
            parts = line.strip().split()
            if not parts:
                continue
            plain = clean_hebrew_plain(parts[0])
            if plain and _HE_LETTER_RE.search(plain) and plain not in ranks:
                ranks[plain] = idx
    return ranks


def _ipa_vowel_skeleton(ipa: str) -> str:
    cleaned = ipa.lower().strip().strip("/[]")
    cleaned = re.sub(r"[ˈˌː.:()]", "", cleaned)
    return "".join(ch for ch in cleaned if ch in "aeiouəɛɔɪʊ")


def _extract_ipas(entry: dict[str, Any]) -> list[str]:
    out: list[str] = []
    for sound in entry.get("sounds") or []:
        if not isinstance(sound, dict):
            continue
        ipa = sound.get("ipa")
        if not isinstance(ipa, str) or not ipa.strip():
            continue
        note = str(sound.get("note") or "").lower()
        if any(bad in note for bad in ("biblical", "tiberian", "yemenite", "ashkenazi", "reconstructed")):
            continue
        out.append(ipa.strip())
    return out


def _extract_en_canonical(entry: dict[str, Any]) -> Optional[str]:
    for frm in entry.get("forms") or []:
        if not isinstance(frm, dict):
            continue
        tags = {str(t).lower() for t in (frm.get("tags") or [])}
        val = unicodedata.normalize("NFC", str(frm.get("form") or "").strip())
        if "canonical" in tags and _HE_LETTER_RE.search(val) and _NIKKUD_RE.search(val):
            return val
    return None


def _extract_en_romanization(entry: dict[str, Any]) -> Optional[str]:
    for frm in entry.get("forms") or []:
        if not isinstance(frm, dict):
            continue
        tags = {str(t).lower() for t in (frm.get("tags") or [])}
        val = str(frm.get("form") or "").strip()
        if "romanization" in tags and val and len(val) <= 48:
            if any(ord(ch) > 0x024F for ch in val):
                continue
            return val
    return None


def _extract_root(entry: dict[str, Any]) -> Optional[str]:
    root = etl.extract_shoresh_from_entry(entry)
    if root:
        return root
    for tpl in entry.get("etymology_templates") or []:
        if not isinstance(tpl, dict):
            continue
        args = tpl.get("args") or {}
        if not isinstance(args, dict):
            continue
        for val in args.values():
            if not isinstance(val, str):
                continue
            if "־" in val or "-" in val:
                letters = _HE_LETTER_RE.findall(val)
                if 3 <= len(letters) <= 4:
                    return "-".join(letters)
    return None


def _extract_forms_summary(
    entry: dict[str, Any],
    pos: str,
    canonical_heb: str,
) -> Optional[str]:
    parts: list[str] = []
    seen: set[str] = set()
    canon_nfc = unicodedata.normalize("NFC", canonical_heb)

    for frm in entry.get("forms") or []:
        if not isinstance(frm, dict):
            continue
        tags = {str(t).lower() for t in (frm.get("tags") or [])}
        if tags & _POSSESSIVE_OR_SKIP_TAGS:
            continue
        raw_form = unicodedata.normalize("NFC", str(frm.get("form") or "").strip())
        if not raw_form or not _HE_LETTER_RE.search(raw_form) or not _NIKKUD_RE.search(raw_form):
            continue
        if raw_form.endswith("־") or "\\" in raw_form or "/" in raw_form:
            continue
        if raw_form == canon_nfc:
            continue

        if pos == "verb":
            if "infinitive" in tags and "инф." not in seen:
                parts.append(f"инф. {raw_form}")
                seen.add("инф.")
            elif {"present", "masculine", "singular"} <= tags and "наст." not in seen:
                parts.append(f"наст. {raw_form}")
                seen.add("наст.")
        elif pos == "noun":
            if "plural" in tags and "singular" not in tags and "мн.ч." not in seen:
                parts.append(f"мн.ч. {raw_form}")
                seen.add("мн.ч.")
        elif pos in {"adj", "adjective"}:
            if {"feminine", "singular"} <= tags and "ж.р." not in seen:
                parts.append(f"ж.р. {raw_form}")
                seen.add("ж.р.")
            elif {"masculine", "plural"} <= tags and "мн.ч." not in seen:
                parts.append(f"мн.ч. {raw_form}")
                seen.add("мн.ч.")

        if len(parts) >= 2:
            break
    return " · ".join(parts) if parts else None


def _score_en_match(
    ru_pos: str,
    ru_vocalized: Optional[str],
    ru_ipas: list[str],
    en_entry: dict[str, Any],
) -> int:
    score = 0
    en_pos = (en_entry.get("pos") or "").lower()
    if en_pos == ru_pos:
        score += 40
    elif en_pos in _POS_EQUIV.get(ru_pos, set()):
        score += 20
    else:
        score -= 35

    en_can = _extract_en_canonical(en_entry)
    if not en_can:
        return -999
    if ru_vocalized and unicodedata.normalize("NFC", ru_vocalized) == en_can:
        score += 100

    en_ipas = _extract_ipas(en_entry)
    if ru_ipas and en_ipas:
        ru_skel = {_ipa_vowel_skeleton(x) for x in ru_ipas if _ipa_vowel_skeleton(x)}
        en_skel = {_ipa_vowel_skeleton(x) for x in en_ipas if _ipa_vowel_skeleton(x)}
        if ru_skel & en_skel:
            score += 70
        elif ru_skel and en_skel:
            score -= 60

    if _extract_root(en_entry):
        score += 5
    return score


def _clean_russian_gloss(raw: str) -> Optional[str]:
    text = re.sub(r"\s+", " ", raw).strip()
    if not text:
        return None
    lower = text.lower()
    if lower.startswith(_BAD_GLOSS_PREFIXES):
        return None
    if len(text) > 80:
        # Remove long explanatory parentheticals cleanly without leaving dangling "("
        shortened = re.sub(r"\s*\([^)]{18,}\)", "", text).strip()
        if shortened and len(shortened) >= 2:
            text = shortened
    if len(text) > 95:
        cut = text[:92].rsplit(" ", 1)[0].rstrip(" ,;(-")
        # Remove any unclosed parenthesis after trimming
        if "(" in cut and ")" not in cut[cut.rfind("(") :]:
            cut = cut[: cut.rfind("(")].rstrip(" ,;-")
        text = (cut or text[:92].rstrip()) + "..."
    # Helpful clean gloss for the ubiquitous genitive particle של
    if text == "от" and "обычно указывает на принадлежность" in raw:
        text = "от; предлог принадлежности (мой, твой, кого-чего)"
    return text


def _pick_modern_example(entry: dict[str, Any]) -> tuple[Optional[str], Optional[str]]:
    for sense in entry.get("senses") or []:
        if not isinstance(sense, dict):
            continue
        for ex in sense.get("examples") or []:
            if not isinstance(ex, dict):
                continue
            ref = str(ex.get("ref") or "").lower()
            he_text = unicodedata.normalize("NFC", str(ex.get("text") or "").strip())
            ru_text = str(ex.get("translation") or "").strip()
            if not he_text or not ru_text or not _HE_LETTER_RE.search(he_text):
                continue
            if len(he_text) > 85 or len(ru_text) > 110:
                continue
            combined_lower = (ref + " " + ru_text).lower()
            if any(marker in combined_lower for marker in _ARCHAIC_EXAMPLE_MARKERS):
                continue
            ru_text = ru_text.rstrip(";,")
            return he_text, ru_text
    return None, None


def build_dictionary_entries(target_count: int = 500) -> list[dict[str, Any]]:
    freq_ranks = load_frequency_ranks(FREQ_PATH)

    # 1. Index English Wiktionary Hebrew entries
    en_by_plain: dict[str, list[dict[str, Any]]] = collections.defaultdict(list)
    with ENWIKI_PATH.open("r", encoding="utf-8") as handle:
        for line in handle:
            entry = json.loads(line)
            plain = clean_hebrew_plain(entry.get("word") or "")
            if plain:
                en_by_plain[plain].append(entry)

    # 2. Seed existing SRS & Grammar entries first
    entries: list[dict[str, Any]] = []
    seen_keys: set[tuple[str, str]] = set()
    plain_occurrences: collections.Counter[str] = collections.Counter()

    srs_items = json.loads(SRS_SEED_PATH.read_text(encoding="utf-8"))
    for item in srs_items:
        heb = unicodedata.normalize("NFC", item["hebrew_vocalized"].strip())
        plain = clean_hebrew_plain(heb)
        cat = item.get("category") or "phrase"
        key = (plain, cat)
        if key in seen_keys:
            continue
        seen_keys.add(key)
        plain_occurrences[plain] += 1

        en_cands = en_by_plain.get(plain, [])
        rom = None
        forms_sum = None
        pos_hint = "verb" if cat == "verb" else ("adj" if cat == "adjective" else ("noun" if cat == "noun" else cat))
        for cand in en_cands:
            if (cand.get("pos") or "").lower() not in _POS_EQUIV.get(pos_hint, {pos_hint}):
                continue
            if not rom:
                rom = _extract_en_romanization(cand)
            if not forms_sum and cat in {"verb", "noun", "adjective"}:
                forms_sum = _extract_forms_summary(cand, pos_hint, heb)

        entries.append(
            {
                "id": item["id"],
                "hebrew_vocalized": heb,
                "russian_translation": item["russian_translation"],
                "transliteration": rom or etl.transliterate_hebrew(heb),
                "category": cat,
                "root": item.get("root"),
                "binyan": item.get("binyan") or "none",
                "forms_summary": forms_sum,
                "example_hebrew": item.get("example_hebrew"),
                "example_russian": item.get("example_russian"),
                "audio_url": item.get("audio_url"),
                "frequency_rank": freq_ranks.get(plain),
                "source_name": item.get("source_name") or "Wiktionary / Kaikki Hebrew",
                "license_name": item.get("license_name") or "CC BY-SA 4.0",
                "attribution_text": item.get("attribution_text"),
            }
        )

    grammar_data = json.loads(GRAMMAR_SEED_PATH.read_text(encoding="utf-8"))
    for verb in grammar_data.get("verbs", []):
        inf = verb.get("infinitive_vocalized")
        lemma = verb.get("lemma_vocalized")
        primary = unicodedata.normalize("NFC", (inf or lemma).strip())
        plain = clean_hebrew_plain(primary)
        key = (plain, "verb")
        if key in seen_keys:
            continue
        seen_keys.add(key)
        plain_occurrences[plain] += 1

        conjs = verb.get("conjugations") or []
        present_ms = next(
            (c["form_vocalized"] for c in conjs if c.get("tense") == "present" and c.get("person") == "ms"),
            None,
        )
        past_3ms = next(
            (c["form_vocalized"] for c in conjs if c.get("tense") == "past" and c.get("person") == "3ms"),
            None,
        )
        form_bits = [
            f"прош. {past_3ms}" if past_3ms and past_3ms != primary else None,
            f"наст. {present_ms}" if present_ms else None,
        ]
        forms_sum = " · ".join(b for b in form_bits if b) or None

        entries.append(
            {
                "id": f"dict_{verb['id']}",
                "hebrew_vocalized": primary,
                "russian_translation": verb["russian_meaning"],
                "transliteration": etl.transliterate_hebrew(primary),
                "category": "verb",
                "root": verb.get("root"),
                "binyan": verb.get("binyan") or "none",
                "forms_summary": forms_sum,
                "example_hebrew": None,
                "example_russian": None,
                "audio_url": None,
                "frequency_rank": freq_ranks.get(clean_hebrew_plain(lemma)),
                "source_name": verb.get("source_name") or "Kaikki / Wiktionary",
                "license_name": verb.get("license_name") or "CC BY-SA 4.0",
                "attribution_text": verb.get("attribution_text"),
            }
        )

    # 3. Parse Russian Wiktionary + English Wiktionary enrichment
    candidates: list[tuple[int, int, dict[str, Any]]] = []
    with RUWIKI_PATH.open("r", encoding="utf-8") as handle:
        for line in handle:
            ru_entry = json.loads(line)
            raw_pos = (ru_entry.get("pos") or "").lower()
            if raw_pos in {"suffix", "prefix", "letter", "character", "symbol", "unknown", "root", "name", "proper noun"}:
                continue

            plain = clean_hebrew_plain(ru_entry.get("word") or "")
            if not plain or not _HE_LETTER_RE.search(plain):
                continue
            rank = freq_ranks.get(plain)
            if rank is None or rank > 18000:
                continue

            glosses_raw: list[str] = []
            for sense in ru_entry.get("senses") or []:
                if not isinstance(sense, dict):
                    continue
                for g in sense.get("glosses") or []:
                    if isinstance(g, str):
                        cleaned = _clean_russian_gloss(g)
                        if cleaned and cleaned not in glosses_raw:
                            glosses_raw.append(cleaned)
            if not glosses_raw:
                continue

            non_archaic = [
                g for g in glosses_raw if not any(m in g.lower() for m in _ARCHAIC_GLOSS_MARKERS)
            ]
            if not non_archaic:
                continue

            ru_voc: Optional[str] = None
            ru_plural: Optional[str] = None
            for frm in ru_entry.get("forms") or []:
                if not isinstance(frm, dict):
                    continue
                fval = unicodedata.normalize("NFC", str(frm.get("form") or "").strip())
                tags = {str(t).lower() for t in (frm.get("tags") or [])}
                if not _HE_LETTER_RE.search(fval) or not _NIKKUD_RE.search(fval) or fval.endswith("־"):
                    continue
                if ("singular" in tags or "canonical" in tags) and not ru_voc:
                    ru_voc = fval
                elif "plural" in tags and "singular" not in tags and raw_pos == "noun" and not ru_plural:
                    ru_plural = f"мн.ч. {fval}"

            ru_ipas = _extract_ipas(ru_entry)
            en_cands = en_by_plain.get(plain, [])
            best_en: Optional[dict[str, Any]] = None
            best_score = -999
            for cand in en_cands:
                sc = _score_en_match(raw_pos, ru_voc, ru_ipas, cand)
                if sc > best_score:
                    best_score = sc
                    best_en = cand

            canonical = ru_voc
            rom: Optional[str] = None
            root: Optional[str] = None
            binyan = "none"
            forms_sum = ru_plural

            if best_en is not None and best_score >= 10:
                canonical = _extract_en_canonical(best_en) or canonical
                rom = _extract_en_romanization(best_en)
                root = _extract_root(best_en)
                if raw_pos == "verb":
                    binyan = etl.detect_binyan_from_tags(best_en)
                en_forms = _extract_forms_summary(best_en, raw_pos, canonical or "")
                if en_forms:
                    forms_sum = en_forms
            elif not canonical:
                continue

            if not canonical or not _NIKKUD_RE.search(canonical):
                continue

            category = etl.map_pos_to_category(raw_pos)
            key = (clean_hebrew_plain(canonical), category)
            if key in seen_keys:
                continue

            ex_heb, ex_ru = _pick_modern_example(ru_entry)

            # Ranking adjustments so modern active words beat obscure homographs
            adj_rank = rank
            if raw_pos in {"prep", "pron", "conj", "adv"}:
                adj_rank -= 250
            elif category == "verb" and binyan != "none" and binyan not in {"pual", "hufal"}:
                adj_rank -= 180
            elif category == "verb" and plain == "יש":
                adj_rank -= 260
            if binyan in {"pual", "hufal"}:
                adj_rank += 2500
            if root:
                adj_rank -= 120
            if forms_sum:
                adj_rank -= 80
            if best_score >= 60:
                adj_rank -= 100
            if rank <= 30 and category == "noun" and plain not in {"עם", "אם"}:
                adj_rank += 900
            # Penalize very obscure homographs on ultra-high-frequency tokens (rank <= 200)
            if rank <= 200 and category == "verb" and binyan == "paal" and not root:
                adj_rank += 800

            digest = hashlib.sha1(f"{canonical}:{category}".encode("utf-8")).hexdigest()[:6]
            item_id = f"dict_{etl._make_slug(canonical)}_{digest}"

            candidates.append(
                (
                    adj_rank,
                    rank,
                    {
                        "id": item_id,
                        "hebrew_vocalized": canonical,
                        "russian_translation": "; ".join(non_archaic[:3]),
                        "transliteration": rom or etl.transliterate_hebrew(canonical),
                        "category": category,
                        "root": root,
                        "binyan": binyan,
                        "forms_summary": forms_sum,
                        "example_hebrew": ex_heb,
                        "example_russian": ex_ru,
                        "audio_url": None,
                        "frequency_rank": rank,
                        "source_name": "Wiktionary / Kaikki Hebrew",
                        "license_name": "CC BY-SA 4.0",
                        "attribution_text": "Adapted from Russian & English Wiktionary via Kaikki.org (CC BY-SA 4.0)",
                    },
                )
            )

    candidates.sort(key=lambda tup: (tup[0], tup[1], tup[2]["id"]))

    # Also protect already-seeded curriculum tokens from random obscure homographs
    seeded_plains = set(plain_occurrences.keys())

    for adj_rank, rank, item in candidates:
        if len(entries) >= target_count:
            break
        heb_norm = clean_hebrew_plain(item["hebrew_vocalized"])
        key = (heb_norm, item["category"])
        if key in seen_keys:
            continue

        # Skip obscure homographs for words already curated or very high-frequency function tokens
        if rank <= 250 and plain_occurrences[heb_norm] >= 1:
            allow_second = heb_norm in {"עם", "אם"} and item["category"] in {"particle", "noun"}
            if not allow_second:
                continue

        if heb_norm in seeded_plains and rank <= 500:
            continue
        if item["binyan"] in {"pual", "hufal"} and rank <= 800:
            continue
        if plain_occurrences[heb_norm] >= 2:
            continue

        seen_keys.add(key)
        plain_occurrences[heb_norm] += 1
        entries.append(item)

    entries.sort(
        key=lambda e: (
            e["frequency_rank"] if isinstance(e.get("frequency_rank"), int) else 999999,
            clean_hebrew_plain(e["hebrew_vocalized"]),
        )
    )
    return entries


def main() -> int:
    for p in (FREQ_PATH, RUWIKI_PATH, ENWIKI_PATH):
        if not p.exists():
            print(f"Missing required source file: {p}. Run tool/fetch_open_hebrew_sources.py first.", file=sys.stderr)
            return 2

    entries = build_dictionary_entries(target_count=500)
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_text(
        json.dumps(entries, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    cats = collections.Counter(e["category"] for e in entries)
    with_root = sum(1 for e in entries if e.get("root"))
    with_audio = sum(1 for e in entries if e.get("audio_url"))
    with_forms = sum(1 for e in entries if e.get("forms_summary"))
    with_ex = sum(1 for e in entries if e.get("example_hebrew"))
    print(f"Wrote {len(entries)} dictionary entries -> {OUTPUT_PATH}")
    print("Categories:", dict(cats))
    print(f"With root: {with_root}, With forms: {with_forms}, With example: {with_ex}, With offline MP3: {with_audio}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
