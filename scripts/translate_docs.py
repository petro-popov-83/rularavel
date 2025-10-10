#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
import re
import time
from pathlib import Path
from typing import Iterable

import requests

PREFIX_RE = re.compile(r'^(\s*(?:[-*+]\s+|\d+\.\s+|>\s+|#+\s+|:::\s*|\|\s+|\|))')
TRANSLATE_URL = "https://translate.googleapis.com/translate_a/single"
MAX_RETRIES = 5
SLEEP_SECONDS = 0.5

DESTINATION_ALIASES: dict[str, list[str]] = {
    "artisan.md": ["artisan-console.md"],
    "blade.md": ["blade-templates.md"],
    "container.md": ["service-container.md"],
    "csrf.md": ["csrf-protection.md"],
    "providers.md": ["service-providers.md"],
    "urls.md": ["url-generation.md"],
    "vite.md": ["asset-bundling.md"],
}


class Translator:
    def __init__(self, cache_dir: Path, source_lang: str = "en", target_lang: str = "ru") -> None:
        self.cache_dir = cache_dir
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.source_lang = source_lang
        self.target_lang = target_lang
        self.session = requests.Session()

    def _cache_path(self, text: str) -> Path:
        digest = hashlib.sha1(text.encode("utf-8")).hexdigest()
        return self.cache_dir / f"{digest}.json"

    def _cached(self, text: str) -> str | None:
        path = self._cache_path(text)
        if not path.exists():
            return None
        try:
            payload = json.loads(path.read_text("utf-8"))
        except json.JSONDecodeError:
            path.unlink(missing_ok=True)
            return None
        if payload.get("text") != text:
            path.unlink(missing_ok=True)
            return None
        return payload.get("translation")

    def _store_cache(self, text: str, translation: str) -> None:
        path = self._cache_path(text)
        payload = json.dumps({"text": text, "translation": translation}, ensure_ascii=False)
        path.write_text(payload, encoding="utf-8")

    def _translate_piece(self, text: str) -> str:
        cached = self._cached(text)
        if cached is not None:
            return cached
        params = {
            "client": "gtx",
            "sl": self.source_lang,
            "tl": self.target_lang,
            "dt": "t",
            "q": text,
        }
        backoff = SLEEP_SECONDS
        for _ in range(MAX_RETRIES):
            try:
                response = self.session.get(TRANSLATE_URL, params=params, timeout=30)
            except requests.RequestException:
                time.sleep(backoff)
                backoff *= 2
                continue
            if response.status_code == 200:
                try:
                    payload = response.json()
                except json.JSONDecodeError:
                    time.sleep(backoff)
                    backoff *= 2
                    continue
                parts = [entry[0] for entry in payload[0] if entry[0]]
                translation = "".join(parts)
                self._store_cache(text, translation)
                return translation
            if response.status_code in {429, 500, 502, 503}:
                time.sleep(backoff)
                backoff *= 2
                continue
        raise RuntimeError("Translation service failed")

    def translate(self, texts: Iterable[str]) -> list[str]:
        results: list[str] = []
        for text in texts:
            if not text:
                results.append('')
                continue
            results.append(self._translate_piece(text))
        return results


def translate_file(src_path: Path, dest_path: Path, translator: Translator):
    dest_path.parent.mkdir(parents=True, exist_ok=True)

    in_code_block = False
    output_lines: list[str | None] = []
    segments: list[str] = []
    slots: list[tuple[int, str]] = []

    with src_path.open('r', encoding='utf-8') as f:
        lines = f.readlines()

    for line in lines:
        stripped = line.rstrip('\n')

        if stripped.strip().startswith('```'):
            output_lines.append(stripped)
            in_code_block = not in_code_block
            continue

        if in_code_block or not stripped.strip():
            output_lines.append(stripped)
            continue

        match = PREFIX_RE.match(stripped)
        prefix = match.group(1) if match else ''
        core_text = stripped[len(prefix):] if prefix else stripped

        if not core_text.strip():
            output_lines.append(stripped)
            continue

        slots.append((len(output_lines), prefix))
        output_lines.append(None)
        segments.append(core_text)

    if segments:
        translations = translator.translate(segments)
        for (index, prefix), translated in zip(slots, translations):
            output_lines[index] = f"{prefix}{translated}"

    translated_text = '\n'.join(line if line is not None else '' for line in output_lines) + '\n'
    dest_path.write_text(translated_text, encoding='utf-8')

    for alias in DESTINATION_ALIASES.get(src_path.name, []):
        alias_path = dest_path.parent / alias
        alias_path.write_text(translated_text, encoding='utf-8')


def main():
    parser = argparse.ArgumentParser(description="Translate Laravel docs from English to Russian")
    parser.add_argument('src_dir', type=Path, help='Path to original docs directory')
    parser.add_argument('dest_dir', type=Path, help='Destination directory for translated docs')
    parser.add_argument('--files', nargs='*', help='Specific markdown files to translate')
    parser.add_argument('--cache-dir', type=Path, default=Path('.cache/translate'), help='Directory to store translation cache')
    args = parser.parse_args()

    if args.files:
        sources = [args.src_dir / name for name in args.files]
    else:
        sources = sorted(args.src_dir.glob('*.md'))

    translator = Translator(args.cache_dir)

    for src_path in sources:
        if not src_path.exists():
            print(f"Skipping missing file {src_path}")
            continue
        dest_path = args.dest_dir / src_path.name
        translate_file(src_path, dest_path, translator)
        print(f"Translated {src_path.name}")


if __name__ == '__main__':
    main()
