#!/usr/bin/env python3
"""game_words.dart ga uz/ru/kaa/de tarjimalarini qo'shadi."""
import re
import time
from pathlib import Path

try:
    from deep_translator import GoogleTranslator
except ImportError:
    GoogleTranslator = None

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "lib" / "utils" / "game_words.dart"
OUT = ROOT / "lib" / "utils" / "game_words_i18n.dart"

ENTRY_RE = re.compile(
    r"\{'word': '((?:\\'|[^'])*)', 'article': '((?:\\'|[^'])*)', 'translation': '((?:\\'|[^'])*)'\}"
)


def unescape(s: str) -> str:
    return s.replace("\\'", "'")


def escape_dart(s: str) -> str:
    return s.replace("\\", "\\\\").replace("'", "\\'")


def parse_entries(text: str) -> list[dict]:
    entries = []
    for m in ENTRY_RE.finditer(text):
        entries.append(
            {
                "word": unescape(m.group(1)),
                "article": unescape(m.group(2)),
                "uz": unescape(m.group(3)),
            }
        )
    return entries


def translate_batch(texts: list[str], target: str, src: str = "uz") -> list[str]:
    if not GoogleTranslator:
        return texts
    translator = GoogleTranslator(source=src, target=target)
    out = []
    for i, t in enumerate(texts):
        if not t.strip():
            out.append(t)
            continue
        try:
            out.append(translator.translate(t))
        except Exception:
            out.append(t)
        if (i + 1) % 20 == 0:
            time.sleep(0.3)
    return out


def main():
    text = SRC.read_text(encoding="utf-8")
    entries = parse_entries(text)
    print(f"Parsed {len(entries)} words")

    uz_list = [e["uz"] for e in entries]
    ru_list = translate_batch(uz_list, "ru", "uz") if GoogleTranslator else uz_list
    kaa_list = translate_batch(uz_list, "kk", "uz") if GoogleTranslator else uz_list

    lines = [
        "// GENERATED — tool/build_game_word_i18n.py",
        "// Qaraqalpaq (kaa) uchun Google kk tarjimasidan foydalaniladi.",
        "class GameWordsI18n {",
        "  static const Map<String, Map<String, String>> byWord = {",
    ]
    for e, uz, ru, kaa in zip(entries, uz_list, ru_list, kaa_list):
        noun = e["word"].split(" ", 1)[-1] if " " in e["word"] else e["word"]
        de_hint = noun
        w = escape_dart(e["word"])
        lines.append(f"    '{w}': {{")
        lines.append(f"      'uz': '{escape_dart(uz)}',")
        lines.append(f"      'ru': '{escape_dart(ru)}',")
        lines.append(f"      'kaa': '{escape_dart(kaa)}',")
        lines.append(f"      'de': '{escape_dart(de_hint)}',")
        lines.append("    },")
    lines.append("  };")
    lines.append("}")
    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
