import json
from pathlib import Path
import tempfile
import unittest

from import_open_hebrew import (
    classify_listening_difficulty,
    is_permissive_audio_license,
    load_seed_items,
    main as cli_main,
    merge_cards_by_id,
    parse_kaikki_line,
    parse_kaikki_verb_line,
    parse_tatoeba_listening_payload,
    parse_tatoeba_payload,
    save_seed_items,
    transliterate_hebrew,
)


class OpenHebrewImporterTests(unittest.TestCase):
    def test_license_filter_allows_cc0_and_cc_by_rejects_nc(self) -> None:
        self.assertTrue(is_permissive_audio_license("CC BY 2.0 FR"))
        self.assertTrue(is_permissive_audio_license("CC0 1.0"))
        self.assertFalse(is_permissive_audio_license("CC BY-NC 4.0"))
        self.assertFalse(is_permissive_audio_license("No license"))
        self.assertFalse(is_permissive_audio_license(None))

    def test_parse_tatoeba_payload_filters_restricted_audio_and_extracts_russian(self) -> None:
        payload = {
            "data": [
                {
                    "id": 1001,
                    "text": "שָׁלוֹם עוֹלָם",
                    "textLicence": "CC BY 2.0 FR",
                    "audios": [
                        {
                            "id": 55,
                            "author": "speaker1",
                            "license": "CC BY-NC 4.0",
                            "url": "https://audio.tatoeba.org/sentences/heb/1001_nc.mp3",
                        },
                        {
                            "id": 56,
                            "author": "speaker2",
                            "license": "CC0 1.0",
                            "url": "https://audio.tatoeba.org/sentences/heb/1001.mp3",
                        },
                    ],
                    "translations": [
                        [{"id": 2001, "lang": "rus", "text": "Привет, мир"}],
                    ],
                },
                {
                    "id": 1002,
                    "text": "תּוֹדָה",
                    "translations": [
                        [{"id": 2002, "lang": "eng", "text": "Thanks"}],
                    ],
                },
            ]
        }

        cards = parse_tatoeba_payload(payload)
        self.assertEqual(len(cards), 1)
        self.assertEqual(cards[0]["id"], "tatoeba_1001")
        self.assertEqual(cards[0]["russian_translation"], "Привет, мир")
        self.assertEqual(
            cards[0]["audio_url"],
            "https://audio.tatoeba.org/sentences/heb/1001.mp3",
        )
        self.assertEqual(cards[0]["license_name"], "CC0 1.0")

    def test_parse_kaikki_line_extracts_binyan_root_and_audio(self) -> None:
        kaikki_entry = {
            "word": "לדבר",
            "pos": "verb",
            "forms": [
                {"form": "לְדַבֵּר", "tags": ["canonical"]},
                {"form": "ד-ב-ר", "tags": ["root"]},
            ],
            "senses": [{"tags": ["pi'el"]}],
            "translations": [{"code": "ru", "word": "говорить"}],
            "sounds": [{"mp3_url": "https://upload.wikimedia.org/example.mp3"}],
        }

        card = parse_kaikki_line(json.dumps(kaikki_entry, ensure_ascii=False))
        self.assertIsNotNone(card)
        assert card is not None
        self.assertEqual(card["hebrew_vocalized"], "לְדַבֵּר")
        self.assertEqual(card["russian_translation"], "говорить")
        self.assertEqual(card["binyan"], "piel")
        self.assertEqual(card["root"], "ד-ב-ר")
        self.assertEqual(card["audio_url"], "https://upload.wikimedia.org/example.mp3")

    def test_merge_cards_preserves_existing_entries(self) -> None:
        existing = [{"id": "a", "hebrew_vocalized": "שָׁלוֹם"}]
        incoming = [{"id": "a", "hebrew_vocalized": "CHANGED"}, {"id": "b", "hebrew_vocalized": "קָפֶה"}]

        merged = merge_cards_by_id(existing, incoming)
        self.assertEqual(len(merged), 2)
        self.assertEqual(merged[0]["hebrew_vocalized"], "שָׁלוֹם")

    def test_parse_tatoeba_listening_payload_assigns_difficulty_and_focus_words(self) -> None:
        payload = {
            "data": [
                {
                    "id": 3001,
                    "text": "אֲנִי רוֹצֶה קָפֶה עִם חָלָב בַּבֹּקֶר בְּבַקָּשָׁה",
                    "textLicence": "CC BY 2.0 FR",
                    "audios": [],
                    "translations": [
                        [{"id": 4001, "lang": "rus", "text": "Я хочу кофе с молоком утром, пожалуйста."}],
                    ],
                },
                {
                    "id": 3002,
                    "text": "תּוֹדָה רַבָּה חָבֵר",
                    "textLicence": "CC BY 2.0 FR",
                    "audios": [],
                    "translations": [
                        [{"id": 4002, "lang": "rus", "text": "Большое спасибо, друг"}],
                    ],
                },
            ]
        }

        exercises = parse_tatoeba_listening_payload(payload)
        self.assertEqual(len(exercises), 2)
        self.assertEqual(exercises[0]["id"], "listen_tatoeba_3001")
        self.assertEqual(exercises[0]["difficulty"], "intermediate")
        self.assertEqual(len(exercises[0]["focus_words"]), 4)
        self.assertEqual(exercises[1]["difficulty"], "beginner")
        self.assertEqual(classify_listening_difficulty("א ב ג ד ה ו ז ח ט"), "advanced")

    def test_parse_kaikki_verb_line_builds_valid_grammar_paradigm(self) -> None:
        kaikki_verb = {
            "word": "למד",
            "pos": "verb",
            "senses": [{"tags": ["pa'al"]}],
            "translations": [{"code": "ru", "word": "учиться, изучать"}],
            "forms": [
                {"form": "לָמַד", "tags": ["canonical"]},
                {"form": "ל-מ-ד", "tags": ["root"]},
                {"form": "לִלְמֹד", "tags": ["infinitive"]},
                {"form": "לוֹמֵד", "tags": ["present", "masculine", "singular"], "romanization": "lomed"},
                {"form": "לוֹמֶדֶת", "tags": ["present", "feminine", "singular"]},
                {"form": "לָמַדְתִּי", "tags": ["past", "first-person", "singular"]},
                {"form": "תִּלְמְדוּ", "tags": ["future", "second-person", "plural"]},  # unsupported slot ignored
                {"form": "יִלְמְדוּ", "tags": ["future", "third-person", "plural"]},
                {"form": "לְמַד", "tags": ["imperative", "masculine", "singular"]},  # imperative ignored
            ],
        }

        verb = parse_kaikki_verb_line(json.dumps(kaikki_verb, ensure_ascii=False))
        self.assertIsNotNone(verb)
        assert verb is not None
        self.assertEqual(verb["binyan"], "paal")
        self.assertEqual(verb["root"], "ל-מ-ד")
        self.assertEqual(verb["infinitive_vocalized"], "לִלְמֹד")
        self.assertEqual(verb["russian_meaning"], "учиться, изучать")

        slots = {(c["tense"], c["person"]): c for c in verb["conjugations"]}
        self.assertIn(("present", "ms"), slots)
        self.assertEqual(slots[("present", "ms")]["transliteration"], "lomed")
        self.assertIn(("present", "fs"), slots)
        self.assertTrue(slots[("present", "fs")]["transliteration"])
        self.assertIn(("past", "1s"), slots)
        self.assertIn(("future", "3p"), slots)
        self.assertNotIn(("future", "2mp"), slots)
        self.assertEqual(len(slots), 4)

    def test_wrapped_seed_roundtrip_preserves_existing_items(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            seed_path = Path(tmpdir) / "listening_seed.json"
            save_seed_items(
                seed_path,
                [{"id": "listen_1", "transcript_vocalized": "שָׁלוֹם"}],
                wrapper_key="exercises",
            )
            loaded = load_seed_items(seed_path, wrapper_key="exercises")
            merged = merge_cards_by_id(
                loaded,
                [
                    {"id": "listen_1", "transcript_vocalized": "OVERWRITE"},
                    {"id": "listen_2", "transcript_vocalized": "תּוֹדָה"},
                ],
            )
            save_seed_items(seed_path, merged, wrapper_key="exercises")
            final_items = load_seed_items(seed_path, wrapper_key="exercises")

            self.assertEqual(len(final_items), 2)
            self.assertEqual(final_items[0]["transcript_vocalized"], "שָׁלוֹם")
            self.assertEqual(final_items[1]["id"], "listen_2")
            self.assertTrue(transliterate_hebrew("שָׁלוֹם"))

    def test_cli_kaikki_grammar_imports_from_gzip_jsonl(self) -> None:
        import gzip

        kaikki_verb = {
            "word": "סבר",
            "pos": "verb",
            "senses": [{"tags": ["hif'il"]}],
            "translations": [{"code": "ru", "word": "объяснять"}],
            "forms": [
                {"form": "הִסְבִּיר", "tags": ["canonical"]},
                {"form": "ס-ב-ר", "tags": ["root"]},
                {"form": "לְהַסְבִּיר", "tags": ["infinitive"]},
                {"form": "מַסְבִּיר", "tags": ["present", "masculine", "singular"]},
            ],
        }
        with tempfile.TemporaryDirectory() as tmpdir:
            gz_path = Path(tmpdir) / "kaikki.jsonl.gz"
            out_path = Path(tmpdir) / "grammar_seed.json"
            with gzip.open(gz_path, "wt", encoding="utf-8") as handle:
                handle.write(json.dumps(kaikki_verb, ensure_ascii=False) + "\n")

            exit_code = cli_main(
                [
                    "kaikki",
                    "--input",
                    str(gz_path),
                    "--format",
                    "grammar",
                    "--output",
                    str(out_path),
                ]
            )
            self.assertEqual(exit_code, 0)
            payload = json.loads(out_path.read_text(encoding="utf-8"))
            self.assertEqual(len(payload["verbs"]), 1)
            self.assertEqual(payload["verbs"][0]["binyan"], "hifil")


if __name__ == "__main__":
    unittest.main()
