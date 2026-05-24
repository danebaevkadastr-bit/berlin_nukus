import re
from pathlib import Path

text = Path("lib/screens/student/conversations_screen.dart").read_text(encoding="utf-8")
pattern = re.compile(
    r"_ConversationItem\(\s*'([^']+)',\s*'([^']+)',\s*Icons\.(\w+)",
    re.MULTILINE,
)
items = {}
for de, uz, _ in pattern.findall(text):
    items[de] = uz

lines = ["// Generated from conversations_screen.dart — do not edit by hand.", ""]
lines.append("class ConversationTopicsL10n {")
lines.append("  static String subtitle(String code, String germanTitle) {")
lines.append("    final map = _maps[code] ?? _maps['uz']!;")
lines.append("    return map[germanTitle] ?? germanTitle;")
lines.append("  }")
lines.append("")
lines.append("  static const _maps = <String, Map<String, String>>{")

for lang in ("uz", "kaa", "ru", "de"):
    lines.append(f"    '{lang}': {{")
    for de, uz in sorted(items.items()):
        de_esc = de.replace("\\", "\\\\").replace("'", "\\'")
        if lang == "uz":
            val = uz
        elif lang == "kaa":
            val = uz  # close to uz
        elif lang == "ru":
            val = uz  # placeholder — same until translated
        else:
            val = de  # German title as fallback for de UI
        val_esc = val.replace("\\", "\\\\").replace("'", "\\'")
        lines.append(f"      '{de_esc}': '{val_esc}',")
    lines.append("    },")

lines.append("  };")
lines.append("}")

out = Path("lib/l10n/conversation_topics_l10n.dart")
out.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(f"Wrote {len(items)} topics to {out}")
