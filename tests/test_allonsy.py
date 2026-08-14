from __future__ import annotations

import importlib.machinery
import importlib.util
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest import mock


SCRIPT = Path(__file__).parents[1] / "bin" / "allonsy"


def load_allonsy():
    loader = importlib.machinery.SourceFileLoader("allonsy", str(SCRIPT))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    if spec is None:
        raise RuntimeError("Could not load Allonsy")
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


class AllonsyTests(unittest.TestCase):
    def setUp(self) -> None:
        self.allonsy = load_allonsy()

    def test_command_preserves_maximum_quality_and_prevents_option_injection(self) -> None:
        hostile_url = "--exec=touch /tmp/should-not-run"
        with tempfile.TemporaryDirectory() as directory, mock.patch.object(
            sys, "argv", ["allonsy", "-o", directory, "--", hostile_url]
        ), mock.patch.object(
            self.allonsy,
            "executable",
            side_effect=["/trusted/yt-dlp", "/trusted/ffmpeg", "/trusted/deno"],
        ), mock.patch.object(
            self.allonsy.subprocess, "run", return_value=subprocess.CompletedProcess([], 0)
        ) as run, mock.patch.dict(
            self.allonsy.os.environ, {"GITHUB_TOKEN": "secret"}, clear=False
        ):
            result = self.allonsy.main()

        self.assertEqual(result, 0)
        command = run.call_args.args[0]
        self.assertIn("bestvideo+bestaudio/best", command)
        self.assertIn("--ignore-config", command)
        self.assertIn("--no-plugin-dirs", command)
        self.assertIn("--no-overwrites", command)
        self.assertIn("--no-post-overwrites", command)
        self.assertEqual(command[-2:], ["--", hostile_url])
        self.assertNotIn("--extract-audio", command)
        self.assertEqual(command[command.index("--ffmpeg-location") + 1], "/trusted/ffmpeg")
        self.assertEqual(
            command[command.index("--js-runtimes") + 1], "deno:/trusted/deno"
        )
        self.assertEqual(command[command.index("--merge-output-format") + 1], "mkv")
        self.assertFalse(run.call_args.kwargs.get("shell", False))
        self.assertNotIn("GITHUB_TOKEN", run.call_args.kwargs["env"])

    def test_preferred_executable_wins_over_path(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            preferred = Path(directory) / "tool"
            preferred.touch(mode=0o755)
            with mock.patch.object(self.allonsy.shutil, "which", return_value="/hostile/tool"):
                self.assertEqual(
                    self.allonsy.executable("tool", (preferred,)), str(preferred)
                )

    def test_non_executable_preferred_path_is_rejected_without_path_fallback(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            preferred = Path(directory) / "tool"
            preferred.touch(mode=0o644)
            with self.assertRaises(SystemExit), mock.patch.object(
                self.allonsy.shutil, "which", return_value="/hostile/tool"
            ) as which:
                self.allonsy.executable("tool", (preferred,), search_path=False)
            which.assert_not_called()

    def test_bare_youtube_id_becomes_clean_url(self) -> None:
        self.assertEqual(
            self.allonsy.normalize_source("hHAziowW_Vg"),
            "https://youtu.be/hHAziowW_Vg",
        )
        self.assertEqual(
            self.allonsy.normalize_source("https://youtu.be/hHAziowW_Vg"),
            "https://youtu.be/hHAziowW_Vg",
        )


if __name__ == "__main__":
    unittest.main()
