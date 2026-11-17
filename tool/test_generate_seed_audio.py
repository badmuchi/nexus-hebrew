#!/usr/bin/env python3
"""Unit tests for the audio seed pipeline helpers."""

import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import generate_seed_audio as gsa  # noqa: E402


class GenerateSeedAudioTests(unittest.TestCase):
    def test_sanitize_for_speech_removes_cantillation_meteg_and_bidi_markers(self) -> None:
        raw = "\u200Fכֹּותֵ\u05BDב\u05BF · אֶפְשָׁר\u05BEלְדַבֵּר (לְאַט) — כֵּן\u05C3"
        cleaned = gsa.sanitize_for_speech(raw)
        self.assertEqual(cleaned, "כֹּותֵב , אֶפְשָׁר לְדַבֵּר לְאַט , כֵּן")

    def test_permissive_wikimedia_license_filter(self) -> None:
        self.assertTrue(
            gsa._is_permissive_wikimedia_url(
                "https://upload.wikimedia.org/commons/LL-Q9288.mp3",
                None,
            )
        )
        self.assertTrue(
            gsa._is_permissive_wikimedia_url(
                "https://example.com/audio.mp3",
                "CC BY-SA 4.0",
            )
        )
        self.assertFalse(
            gsa._is_permissive_wikimedia_url(
                "https://example.com/audio.mp3",
                "CC BY-NC 4.0",
            )
        )
        self.assertFalse(
            gsa._is_permissive_wikimedia_url(
                "https://example.com/audio.mp3",
                "Copyrighted",
            )
        )


if __name__ == "__main__":
    unittest.main()
