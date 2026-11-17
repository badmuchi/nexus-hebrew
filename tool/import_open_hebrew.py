#!/usr/bin/env python3
"""Open-source licensed Hebrew content ETL for Nexus Hebrew App.

Supports importing:
- Tatoeba API v1 (`heb` + `rus` translations + permissive CC0/CC-BY audio)
  into either `srs_seed.json` (`--format srs`) or `listening_seed.json`
  (`--format listening`).
- Kaikki.org / Wiktextract Hebrew JSONL(.gz) (`CC BY-SA 4.0`)
  into either `srs_seed.json` (`--format srs`) or `grammar_verbs_seed.json`
  (`--format grammar`).
"""

from __future__ import annotations

import argparse
import gzip
import hashlib
import json
import re
import sys
import unicodedata
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any, Callable, IO, Iterable, Optional

TATOEBA_API_URL = "https://api.tatoeba.org/v1/sentences"
TATOEBA_AUDIO_BASE = "https://audio.tatoeba.org/sentences/heb"

DEFAULT_OUTPUTS: dict[tuple[str, str], Path] = {
    ("tatoeba", "srs"): Path("assets/seed/srs_seed.json"),
    ("tatoeba", "listening"): Path("assets/seed/listening_seed.json"),
    ("kaikki", "srs"): Path("assets/seed/srs_seed.json"),
    ("kaikki", "grammar"): Path("assets/seed/grammar_verbs_seed.json"),
}

_HEBREW_LETTER_RE = re.compile(r"[\u05D0-\u05EA]")
_NIKKUD_AND_CANTILLATION_RE = re.compile(r"[\u0591-\u05C7]")
_SPLIT_WORDS_RE = re.compile(r'[\s,.\?!:;—–\-"״׳()]+')
_NON_SLUG_RE = re.compile(r"[^a-z0-9]+")

_BINYAN_HINTS: dict[str, tuple[str, ...]] = {
    "paal": ("pa'al", "paal", "qal", "kal", "פעל", "קל"),
    "piel": ("pi'el", "piel", "פיעל", "פִּעֵל"),
    "hifil": ("hif'il", "hifil", "hiph'il", "hiphil", "הפעיל"),
    "hitpael": ("hitpa'el", "hitpael", "התפעל"),
    "nifal": ("nif'al", "nifal", "niph'al", "niphil", "נפעל"),
    "pual": ("pu'al", "pual", "פועל"),
    "hufal": ("huf'al", "hufal", "hof'al", "hofal", "הופעל"),
}

_BINYAN_NOTES_RU: dict[str, str] = {
    "paal": "Базовый активный биньян Пааль (קַל / פָּעַל). Импорт из открытого словаря Kaikki / Wiktionary (CC BY-SA 4.0).",
    "piel": "Интенсивный активный биньян Пиэль (פִּעֵל). Импорт из открытого словаря Kaikki / Wiktionary (CC BY-SA 4.0).",
    "hifil": "Понудительный активный биньян Хифиль (הִפְעִיל). Импорт из открытого словаря Kaikki / Wiktionary (CC BY-SA 4.0).",
    "hitpael": "Возвратно-взаимный биньян Хитпаэль (הִתְפַּעֵל). Импорт из открытого словаря Kaikki / Wiktionary (CC BY-SA 4.0).",
    "nifal": "Страдательно-возвратный биньян Нифаль (נִפְעַל). Импорт из открытого словаря Kaikki / Wiktionary (CC BY-SA 4.0).",
    "pual": "Пассивная пара к Пиэль — биньян Пуаль (פֻּעַל). Импорт из открытого словаря Kaikki / Wiktionary (CC BY-SA 4.0).",
    "hufal": "Пассивная пара к Хифиль — биньян Хуфаль (הֻפְעַל). Импорт из открытого словаря Kaikki / Wiktionary (CC BY-SA 4.0).",
}

_CONSONANT_TRANSLIT: dict[str, str] = {
    "א": "",
    "ב": "v",
    "ג": "g",
    "ד": "d",
    "ה": "h",
    "ו": "v",
    "ז": "z",
    "ח": "kh",
    "ט": "t",
    "י": "y",
    "כ": "kh",
    "ך": "kh",
    "ל": "l",
    "מ": "m",
    "ם": "m",
    "נ": "n",
    "ן": "n",
    "ס": "s",
    "ע": "",
    "פ": "f",
    "ף": "f",
    "צ": "tz",
    "ץ": "tz",
    "ק": "k",
    "ר": "r",
    "ש": "sh",
    "ת": "t",
}

_STOP_HARD_LETTERS: dict[str, str] = {
    "ב": "b",
    "כ": "k",
    "ך": "k",
    "פ": "p",
    "ף": "p",
}

_VOWEL_TRANSLIT: dict[str, str] = {
    "\u05B0": "",   # shva
    "\u05B1": "e",  # hataf segol
    "\u05B2": "a",  # hataf patah
    "\u05B3": "o",  # hataf qamatz
    "\u05B4": "i",  # hiriq
    "\u05B5": "e",  # tzere
    "\u05B6": "e",  # segol
    "\u05B7": "a",  # patah
    "\u05B8": "a",  # qamatz
    "\u05B9": "o",  # holam
    "\u05BA": "o",  # holam haser
    "\u05BB": "u",  # qubutz
}

_DAGESH = "\u05BC"
_SHIN_DOT = "\u05C1"
_SIN_DOT = "\u05C2"

_GRAMMAR_PERSON_ORDER: dict[str, int] = {
    "ms": 0,
    "fs": 1,
    "mp": 2,
    "fp": 3,
    "1s": 4,
    "2ms": 5,
    "2fs": 6,
    "3ms": 7,
    "3fs": 8,
    "1p": 9,
    "3p": 10,
}
_TENSE_ORDER: dict[str, int] = {"present": 0, "past": 1, "future": 2}


def is_permissive_audio_license(license_name: Optional[str]) -> bool:
    """Allow only CC0 and non-restricted CC-BY audio licenses."""
    if not license_name:
        return False
    upper = license_name.upper().strip()
    if not upper or "NO LICENSE" in upper:
        return False
    if "NC" in upper or "ND" in upper:
        return False
    return "CC0" in upper or "CC-BY" in upper or "CC BY" in upper


def has_hebrew_letters(text: str) -> bool:
    return bool(_HEBREW_LETTER_RE.search(text))


def strip_nikkud(text: str) -> str:
    return _NIKKUD_AND_CANTILLATION_RE.sub("", unicodedata.normalize("NFC", text))


def extract_hebrew_letters(text: str) -> str:
    return "".join(_HEBREW_LETTER_RE.findall(text))


def split_hebrew_tokens(text: str) -> list[str]:
    return [tok.strip() for tok in _SPLIT_WORDS_RE.split(text.strip()) if tok.strip()]


def transliterate_hebrew(text: str) -> str:
    """Generate a compact Latin transliteration when Kaikki omits `romanization`."""
    normalized = unicodedata.normalize("NFC", text.strip())
    if not normalized:
        return "heb"

    words_out: list[str] = []
    for raw_word in normalized.split():
        # Break word into base character + trailing combining marks clusters
        clusters: list[tuple[str, list[str]]] = []
        for ch in raw_word:
            if unicodedata.combining(ch) and clusters:
                clusters[-1][1].append(ch)
            elif "\u0591" <= ch <= "\u05C7" and clusters:
                clusters[-1][1].append(ch)
            else:
                clusters.append((ch, []))

        parts: list[str] = []
        idx = 0
        while idx < len(clusters):
            base, marks = clusters[idx]
            if base == "ו" and _DAGESH in marks and not any(m in _VOWEL_TRANSLIT for m in marks):
                parts.append("u")
                idx += 1
                continue
            if base == "ו" and ("\u05B9" in marks or "\u05BA" in marks):
                parts.append("o")
                idx += 1
                continue

            if base == "ש" and _SIN_DOT in marks:
                consonant = "s"
            elif base in _STOP_HARD_LETTERS and _DAGESH in marks:
                consonant = _STOP_HARD_LETTERS[base]
            else:
                consonant = _CONSONANT_TRANSLIT.get(base, base if base.isascii() and base.isalnum() else "")

            vowel = ""
            for mark in marks:
                if mark in _VOWEL_TRANSLIT and _VOWEL_TRANSLIT[mark]:
                    vowel = _VOWEL_TRANSLIT[mark]
                    break

            parts.append(consonant + vowel)
            idx += 1

        joined = "".join(parts)
        if joined:
            words_out.append(joined)

    result = " ".join(words_out).strip()
    return result or "heb"


def _make_slug(text: str) -> str:
    latin = transliterate_hebrew(text).lower()
    slug = _NON_SLUG_RE.sub("_", latin).strip("_")
    return slug[:32] or "item"


def map_pos_to_category(raw_pos: Optional[str]) -> str:
    pos = (raw_pos or "").strip().lower()
    if pos == "verb":
        return "verb"
    if pos in {"noun", "proper noun", "name"}:
        return "noun"
    if pos in {"adj", "adjective"}:
        return "adjective"
    if pos in {"phrase", "idiom", "proverb"}:
        return "phrase"
    return "particle"


def _collect_tag_strings(entry: dict[str, Any]) -> list[str]:
    bag: list[str] = []
    for key in ("tags", "categories"):
        for val in entry.get(key, []) or []:
            if isinstance(val, str):
                bag.append(val.lower())
    for sense in entry.get("senses", []) or []:
        if not isinstance(sense, dict):
            continue
        for key in ("tags", "categories"):
            for val in sense.get(key, []) or []:
                if isinstance(val, str):
                    bag.append(val.lower())
    for form in entry.get("forms", []) or []:
        if not isinstance(form, dict):
            continue
        for val in form.get("tags", []) or []:
            if isinstance(val, str):
                bag.append(val.lower())
    return bag


def detect_binyan_from_tags(entry: dict[str, Any]) -> str:
    bag = _collect_tag_strings(entry)
    for binyan_id, hints in _BINYAN_HINTS.items():
        if any(hint in tag for tag in bag for hint in hints):
            return binyan_id
    return "none"


def extract_shoresh_from_entry(entry: dict[str, Any]) -> Optional[str]:
    candidates: list[str] = []
    if isinstance(entry.get("root"), str):
        candidates.append(entry["root"])
    for form in entry.get("forms", []) or []:
        if not isinstance(form, dict):
            continue
        tags = {str(t).lower() for t in form.get("tags", []) or []}
        if "root" in tags and isinstance(form.get("form"), str):
            candidates.append(form["form"])

    for raw in candidates:
        letters = _HEBREW_LETTER_RE.findall(raw)
        if 3 <= len(letters) <= 4:
            return "-".join(letters)
    return None


def extract_russian_translation(entry: dict[str, Any]) -> Optional[str]:
    for tr in entry.get("translations", []) or []:
        if not isinstance(tr, dict):
            continue
        lang = (tr.get("code") or tr.get("lang_code") or "").lower()
        word = (tr.get("word") or "").strip()
        if lang == "ru" and word:
            return word
    return None


def _extract_kaikki_audio_url(entry: dict[str, Any]) -> Optional[str]:
    for sound in entry.get("sounds", []) or []:
        if not isinstance(sound, dict):
            continue
        url = sound.get("mp3_url") or sound.get("ogg_url")
        if isinstance(url, str) and url.startswith("http"):
            return url
    return None


def _extract_canonical_hebrew(entry: dict[str, Any]) -> str:
    fallback_word = str(entry.get("word") or "").strip()
    for form in entry.get("forms", []) or []:
        if not isinstance(form, dict):
            continue
        tags = {str(t).lower() for t in form.get("tags", []) or []}
        if "canonical" in tags and isinstance(form.get("form"), str) and form["form"].strip():
            return unicodedata.normalize("NFC", form["form"].strip())
    return unicodedata.normalize("NFC", fallback_word)


def fetch_tatoeba_payload(query: str, limit: int) -> dict[str, Any]:
    params = urllib.parse.urlencode(
        {
            "lang": "heb",
            "trans": "rus",
            "q": query,
            "limit": max(1, min(limit, 50)),
        }
    )
    url = f"{TATOEBA_API_URL}?{params}"
    request = urllib.request.Request(
        url,
        headers={
            "Accept": "application/json",
            "User-Agent": "NexusHebrewAppETL/1.0 (+https://tatoeba.org)",
        },
    )
    with urllib.request.urlopen(request, timeout=20) as response:
        return json.loads(response.read().decode("utf-8"))


def _flatten_translations(raw_translations: Any) -> Iterable[dict[str, Any]]:
    if not isinstance(raw_translations, list):
        return
    for block in raw_translations:
        if isinstance(block, dict):
            yield block
        elif isinstance(block, list):
            for nested in block:
                if isinstance(nested, dict):
                    yield nested


def parse_tatoeba_payload(payload: dict[str, Any]) -> list[dict[str, Any]]:
    """Parse Tatoeba API v1 response into Nexus SRS card dicts."""
    cards: list[dict[str, Any]] = []
    for item in payload.get("data", []) or []:
        if not isinstance(item, dict):
            continue
        sent_id = item.get("id")
        hebrew_text = unicodedata.normalize("NFC", str(item.get("text") or "").strip())
        if not sent_id or not hebrew_text or not has_hebrew_letters(hebrew_text):
            continue

        rus_text: Optional[str] = None
        for tr in _flatten_translations(item.get("translations")):
            if str(tr.get("lang") or "").lower() == "rus":
                candidate = str(tr.get("text") or "").strip()
                if candidate:
                    rus_text = candidate
                    break
        if not rus_text:
            continue

        selected_audio_url: Optional[str] = None
        license_name = str(item.get("textLicence") or "CC BY 2.0 FR").strip()
        attribution = f"Sentence #{sent_id} from Tatoeba.org ({license_name})"

        for audio in item.get("audios", []) or []:
            if not isinstance(audio, dict):
                continue
            audio_license = audio.get("license")
            if not is_permissive_audio_license(audio_license):
                continue
            raw_url = str(audio.get("url") or "").strip()
            if raw_url.startswith("http"):
                selected_audio_url = raw_url
            elif audio.get("id"):
                selected_audio_url = f"{TATOEBA_AUDIO_BASE}/{sent_id}.mp3"
            if selected_audio_url:
                license_name = str(audio_license).strip()
                author = str(audio.get("author") or "community").strip()
                attribution = f"Audio by {author} on Tatoeba.org ({license_name})"
                break

        cards.append(
            {
                "id": f"tatoeba_{sent_id}",
                "hebrew_vocalized": hebrew_text,
                "russian_translation": rus_text,
                "root": None,
                "binyan": "none",
                "category": "phrase",
                "example_hebrew": None,
                "example_russian": None,
                "audio_url": selected_audio_url,
                "source_name": "Tatoeba.org",
                "license_name": license_name,
                "attribution_text": attribution,
            }
        )
    return cards


def classify_listening_difficulty(transcript: str) -> str:
    tokens = split_hebrew_tokens(transcript)
    count = len(tokens)
    if count <= 4:
        return "beginner"
    if count <= 8:
        return "intermediate"
    return "advanced"


def extract_focus_words(transcript: str, max_words: int = 4) -> list[str]:
    tokens = split_hebrew_tokens(transcript)
    focus: list[str] = []
    for tok in tokens:
        if not has_hebrew_letters(tok):
            continue
        if len(extract_hebrew_letters(tok)) < 2:
            continue
        if tok not in focus:
            focus.append(tok)
            if len(focus) == max_words:
                return focus
    for tok in tokens:
        if has_hebrew_letters(tok) and tok not in focus:
            focus.append(tok)
            if len(focus) == max_words:
                break
    return focus


def srs_card_to_listening_exercise(card: dict[str, Any]) -> Optional[dict[str, Any]]:
    raw_id = str(card.get("id") or "").strip()
    transcript = unicodedata.normalize("NFC", str(card.get("hebrew_vocalized") or "").strip())
    translation = str(card.get("russian_translation") or "").strip()
    if not raw_id or not transcript or not translation or not has_hebrew_letters(transcript):
        return None

    focus_words = extract_focus_words(transcript)
    if not focus_words:
        return None

    listen_id = raw_id if raw_id.startswith("listen_") else f"listen_{raw_id}"
    return {
        "id": listen_id,
        "transcript_vocalized": transcript,
        "russian_translation": translation,
        "audio_url": card.get("audio_url"),
        "difficulty": classify_listening_difficulty(transcript),
        "focus_words": focus_words,
        "source_name": card.get("source_name", "Tatoeba.org"),
        "license_name": card.get("license_name", "CC BY 2.0 FR"),
        "attribution_text": card.get("attribution_text"),
    }


def parse_tatoeba_listening_payload(payload: dict[str, Any]) -> list[dict[str, Any]]:
    """Convert Tatoeba API v1 payload into Nexus listening exercise dicts."""
    exercises: list[dict[str, Any]] = []
    for card in parse_tatoeba_payload(payload):
        exercise = srs_card_to_listening_exercise(card)
        if exercise is not None:
            exercises.append(exercise)
    return exercises


def parse_kaikki_line(raw_line: str) -> Optional[dict[str, Any]]:
    """Parse a single Kaikki/Wiktextract JSONL line into an SRS card dict."""
    raw_line = raw_line.strip()
    if not raw_line:
        return None
    try:
        entry = json.loads(raw_line)
    except json.JSONDecodeError:
        return None
    if not isinstance(entry, dict):
        return None

    hebrew = _extract_canonical_hebrew(entry)
    russian = extract_russian_translation(entry)
    if not hebrew or not has_hebrew_letters(hebrew) or not russian:
        return None

    raw_word = str(entry.get("word") or hebrew).strip()
    digest = hashlib.sha1(raw_word.encode("utf-8")).hexdigest()[:6]
    card_id = f"kaikki_{_make_slug(hebrew)}_{digest}"

    return {
        "id": card_id,
        "hebrew_vocalized": hebrew,
        "russian_translation": russian,
        "root": extract_shoresh_from_entry(entry),
        "binyan": detect_binyan_from_tags(entry),
        "category": map_pos_to_category(entry.get("pos")),
        "example_hebrew": None,
        "example_russian": None,
        "audio_url": _extract_kaikki_audio_url(entry),
        "source_name": "Wiktionary / Kaikki Hebrew",
        "license_name": "CC BY-SA 4.0",
        "attribution_text": "Adapted from Wiktionary lexical entry via Kaikki.org (CC BY-SA 4.0)",
    }


def _map_kaikki_form_slot(tags: set[str]) -> Optional[tuple[str, str]]:
    """Map Kaikki conjugation tags into Nexus (VerbTense, GrammaticalPerson) ids."""
    if "imperative" in tags or "table-tags" in tags or "inflection-template" in tags or "class" in tags:
        return None
    if "canonical" in tags or "root" in tags or "infinitive" in tags:
        return None

    tense: Optional[str] = None
    if "present" in tags:
        tense = "present"
    elif "past" in tags:
        tense = "past"
    elif "future" in tags:
        tense = "future"
    if tense is None:
        return None

    is_masculine = "masculine" in tags
    is_feminine = "feminine" in tags
    is_singular = "singular" in tags
    is_plural = "plural" in tags

    if tense == "present":
        if is_masculine and is_singular:
            return ("present", "ms")
        if is_feminine and is_singular:
            return ("present", "fs")
        if is_masculine and is_plural:
            return ("present", "mp")
        if is_feminine and is_plural:
            return ("present", "fp")
        return None

    # Past & Future slots supported by Nexus GrammaticalPerson enum:
    # 1s, 2ms, 2fs, 3ms, 3fs, 1p, 3p (note: 2mp/2fp are omitted intentionally).
    if "first-person" in tags and is_singular:
        return (tense, "1s")
    if "first-person" in tags and is_plural:
        return (tense, "1p")
    if "second-person" in tags and is_singular:
        if is_masculine:
            return (tense, "2ms")
        if is_feminine:
            return (tense, "2fs")
        return None
    if "third-person" in tags and is_singular:
        if is_masculine:
            return (tense, "3ms")
        if is_feminine:
            return (tense, "3fs")
        return None
    if "third-person" in tags and is_plural:
        return (tense, "3p")

    return None


def parse_kaikki_verb_line(raw_line: str) -> Optional[dict[str, Any]]:
    """Parse a Kaikki Hebrew `pos == 'verb'` entry into a `grammar_verbs_seed` item."""
    raw_line = raw_line.strip()
    if not raw_line:
        return None
    try:
        entry = json.loads(raw_line)
    except json.JSONDecodeError:
        return None
    if not isinstance(entry, dict) or str(entry.get("pos") or "").lower() != "verb":
        return None

    lemma = _extract_canonical_hebrew(entry)
    russian_meaning = extract_russian_translation(entry)
    root = extract_shoresh_from_entry(entry)
    binyan = detect_binyan_from_tags(entry)
    if not lemma or not has_hebrew_letters(lemma) or not russian_meaning or not root or binyan == "none":
        return None

    infinitive: Optional[str] = None
    conjugations_by_slot: dict[tuple[str, str], dict[str, str]] = {}

    for form_obj in entry.get("forms", []) or []:
        if not isinstance(form_obj, dict):
            continue
        raw_form = unicodedata.normalize("NFC", str(form_obj.get("form") or "").strip())
        if not raw_form or not has_hebrew_letters(raw_form):
            continue
        tags = {str(t).lower() for t in form_obj.get("tags", []) or []}

        if "infinitive" in tags and infinitive is None:
            infinitive = raw_form
            continue

        slot = _map_kaikki_form_slot(tags)
        if slot is None:
            continue

        # Prefer gender-neutral or masculine 3p form if Kaikki splits 3mp and 3fp
        if slot in conjugations_by_slot:
            if slot[1] == "3p" and "feminine" not in tags:
                pass  # allow masculine/common 3p to replace feminine-only 3p
            else:
                continue

        romanization = str(form_obj.get("romanization") or "").strip()
        translit = romanization if romanization else transliterate_hebrew(raw_form)
        conjugations_by_slot[slot] = {
            "tense": slot[0],
            "person": slot[1],
            "form_vocalized": raw_form,
            "transliteration": translit,
        }

    if not conjugations_by_slot:
        return None

    ordered_conjugations = [
        conjugations_by_slot[slot]
        for slot in sorted(
            conjugations_by_slot,
            key=lambda s: (_TENSE_ORDER.get(s[0], 99), _GRAMMAR_PERSON_ORDER.get(s[1], 99)),
        )
    ]

    digest = hashlib.sha1(f"{binyan}:{strip_nikkud(lemma)}".encode("utf-8")).hexdigest()[:6]
    verb_id = f"verb_{binyan}_{_make_slug(lemma)}_{digest}"

    return {
        "id": verb_id,
        "lemma_vocalized": lemma,
        "infinitive_vocalized": None if binyan in {"pual", "hufal"} else infinitive,
        "root": root,
        "binyan": binyan,
        "russian_meaning": russian_meaning,
        "grammar_notes_ru": _BINYAN_NOTES_RU.get(
            binyan,
            "Импортировано из открытого словаря Kaikki / Wiktionary (CC BY-SA 4.0).",
        ),
        "source_name": "Kaikki / Wiktionary",
        "license_name": "CC BY-SA 4.0",
        "attribution_text": "Paradigm adapted from Hebrew Wiktionary / Kaikki.org (CC BY-SA 4.0)",
        "conjugations": ordered_conjugations,
    }


def _open_text_or_gzip(path: Path) -> IO[str]:
    if path.suffix == ".gz":
        return gzip.open(path, "rt", encoding="utf-8")
    return path.open("r", encoding="utf-8")


def _parse_kaikki_stream(
    path: Path,
    parser_fn: Callable[[str], Optional[dict[str, Any]]],
    limit: int,
) -> list[dict[str, Any]]:
    items: list[dict[str, Any]] = []
    with _open_text_or_gzip(path) as handle:
        for line in handle:
            item = parser_fn(line)
            if item is not None:
                items.append(item)
                if len(items) >= limit:
                    break
    return items


def parse_kaikki_file(path: Path, limit: int = 50) -> list[dict[str, Any]]:
    return _parse_kaikki_stream(path, parse_kaikki_line, limit)


def parse_kaikki_verbs_file(path: Path, limit: int = 50) -> list[dict[str, Any]]:
    return _parse_kaikki_stream(path, parse_kaikki_verb_line, limit)


def merge_cards_by_id(
    existing: list[dict[str, Any]],
    incoming: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    """Merge records preserving existing entries when IDs collide."""
    merged = list(existing)
    seen_ids = {str(item.get("id")) for item in existing if item.get("id") is not None}
    for item in incoming:
        item_id = item.get("id")
        if item_id is None:
            continue
        if str(item_id) not in seen_ids:
            seen_ids.add(str(item_id))
            merged.append(item)
    return merged


def _wrapper_key_for_format(output_format: str) -> Optional[str]:
    if output_format == "listening":
        return "exercises"
    if output_format == "grammar":
        return "verbs"
    return None


def load_seed_items(path: Path, wrapper_key: Optional[str]) -> list[dict[str, Any]]:
    if not path.exists():
        return []
    raw_data = json.loads(path.read_text(encoding="utf-8"))
    if wrapper_key is None:
        if not isinstance(raw_data, list):
            raise ValueError(f"Expected JSON list in {path}")
        return [item for item in raw_data if isinstance(item, dict)]
    if not isinstance(raw_data, dict) or not isinstance(raw_data.get(wrapper_key), list):
        raise ValueError(f"Expected JSON object with list field '{wrapper_key}' in {path}")
    return [item for item in raw_data[wrapper_key] if isinstance(item, dict)]


def save_seed_items(
    path: Path,
    items: list[dict[str, Any]],
    wrapper_key: Optional[str],
) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    payload: Any = items if wrapper_key is None else {wrapper_key: items}
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Import open-licensed Hebrew content into Nexus seed JSON packs.",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    tatoeba_cmd = subparsers.add_parser(
        "tatoeba",
        help="Fetch Hebrew-Russian sentences from Tatoeba API v1",
    )
    tatoeba_cmd.add_argument("--query", required=True, help="Hebrew search word (e.g. קפה)")
    tatoeba_cmd.add_argument("--limit", type=int, default=20)
    tatoeba_cmd.add_argument(
        "--format",
        choices=("srs", "listening"),
        default="srs",
        help="Target seed format (srs cards or listening exercises)",
    )
    tatoeba_cmd.add_argument("--output", type=Path, default=None)
    tatoeba_cmd.add_argument("--dry-run", action="store_true")

    kaikki_cmd = subparsers.add_parser(
        "kaikki",
        help="Parse downloaded Kaikki Hebrew JSONL(.gz)",
    )
    kaikki_cmd.add_argument("--input", type=Path, required=True)
    kaikki_cmd.add_argument("--limit", type=int, default=50)
    kaikki_cmd.add_argument(
        "--format",
        choices=("srs", "grammar"),
        default="srs",
        help="Target seed format (srs cards or grammar verb paradigms)",
    )
    kaikki_cmd.add_argument("--output", type=Path, default=None)
    kaikki_cmd.add_argument("--dry-run", action="store_true")

    return parser


def main(argv: Optional[list[str]] = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    output_path: Path = args.output or DEFAULT_OUTPUTS[(args.command, args.format)]
    wrapper_key = _wrapper_key_for_format(args.format)

    try:
        if args.command == "tatoeba":
            payload = fetch_tatoeba_payload(args.query, args.limit)
            incoming = (
                parse_tatoeba_listening_payload(payload)
                if args.format == "listening"
                else parse_tatoeba_payload(payload)
            )
        else:
            if not args.input.exists():
                print(f"Input file not found: {args.input}", file=sys.stderr)
                return 2
            incoming = (
                parse_kaikki_verbs_file(args.input, limit=args.limit)
                if args.format == "grammar"
                else parse_kaikki_file(args.input, limit=args.limit)
            )
    except (urllib.error.URLError, TimeoutError, ValueError, OSError) as exc:
        print(f"ETL failed: {exc}", file=sys.stderr)
        return 1

    if args.dry_run:
        preview: Any = incoming if wrapper_key is None else {wrapper_key: incoming}
        print(json.dumps(preview, ensure_ascii=False, indent=2))
        return 0

    existing = load_seed_items(output_path, wrapper_key)
    merged = merge_cards_by_id(existing, incoming)
    save_seed_items(output_path, merged, wrapper_key)
    added_count = len(merged) - len(existing)
    print(f"Imported {added_count} new items into {output_path} (total: {len(merged)})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
