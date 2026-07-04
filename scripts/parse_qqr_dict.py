"""
QORAQALPOQ-RUSCHA lug'atni (1958, Baskakov) tozalash + LOTINGA o'girish skripti.

Kirish fayl:  scripts/qqr-rus-cleaned.txt   (kirill alifbosida, OCR natijasi)
Chiqish 1:    scripts/qqr_dict_latin.tsv    (lotin_qqr <TAB> ruscha tarjima)
Chiqish 2:    scripts/qqr_dict_training.jsonl (rus->qqr tarjima training dataseti)

Bosqichlar:
  1. Muqova / so'zboshi qatorlarini tashlab yuborish (lug'at boshlanguncha).
  2. Axlat OCR qatorlarini filtrlash (juda qisqa, belgi-shovqinli qatorlar).
  3. Har bir yozuvni: QORAQALPOQ bosh so'z + RUSCHA tarjimaga ajratish.
  4. Qoraqalpoq qismini lotinga o'girish (rus qismi kirillda qoladi).
  5. TSV va JSONL chiqarish.

Ishlatish:
    python scripts/parse_qqr_dict.py
"""

import json
import os
import re

from qqr_translit import translit, has_cyrillic

HERE = os.path.dirname(__file__)
INPUT_FILE = os.path.join(HERE, "qqr-rus-cleaned.txt")
OUT_TSV = os.path.join(HERE, "qqr_dict_latin.tsv")
OUT_JSONL = os.path.join(HERE, "qqr_dict_training.jsonl")

# Asosiy lug'at A-Я qismi shu belgidan KEYIN boshlanadi (alifbo jadvalidan keyin).
START_MARKER = "КАРАКАЛПАКСКИЙ АЛФАВИТ"
# Asosiy lug'at shu belgilardan BIRINCHISIDA tugaydi (keyin ilovalar: ismlar, grammatika).
END_MARKERS = [
    "Мужские имена",
    "НАЗВАНИЯ КАРАКАЛПАКСКИХ",
    "ОЧЕРК ГРАММАТИКИ",
]

# Qoraqalpoq alifbosidagi yaroqli harflar (kichik). Bosh so'z faqat shulardan iborat bo'lishi kerak.
QQR_LETTERS = set("абвгғдежзийкқлмнңоөпрстуўүұфхһцшыэюяёіәъь")
# Qoraqalpoqqa XOS harflar (rus tilida yo'q). Bularning biri bo'lsa — aniq qoraqalpoq so'zi.
QQR_ONLY = set("әғқңөўүұһі")


# Ruscha-kirill harflari (bosh so'z qoraqalpoqcha, tarjima ruscha ekanini ajratish uchun)
# Qoraqalpoqda bor, rusda yo'q maxsus harflar:
QQR_SPECIFIC = set("әғқңөўүұһ")


def is_garbage(line: str) -> bool:
    """OCR axlat qatorini aniqlaydi."""
    s = line.strip()
    if not s:
        return True
    # Juda qisqa (1-2 belgi)
    if len(s) <= 2:
        return True
    letters = sum(1 for c in s if c.isalpha())
    nonletters = len(s) - letters
    # Harf umuman yo'q yoki belgi-shovqin harfdan ko'p
    if letters == 0:
        return True
    if nonletters > letters:
        return True
    # Kirill harf umuman bo'lmasa (faqat lotin shovqin) — tashlaymiz
    if not has_cyrillic(s):
        return True
    # |, \, ", ) kabi OCR shovqin belgilari ko'p bo'lsa
    noise = sum(1 for c in s if c in "|\\/\"'`()[]{}~^")
    if noise >= 3:
        return True
    return False


def find_region(lines):
    """Asosiy lug'at A-Я qismining (start, end) qator indekslarini topadi."""
    start = 0
    for i, ln in enumerate(lines):
        if START_MARKER in ln:
            start = i + 1
            break
    # Alifbo jadvalini o'tkazib yuboramiz: START_MARKER dan keyin yolg'iz "А" qatorini topamiz.
    for i in range(start, min(start + 40, len(lines))):
        if lines[i].strip() == "А":
            start = i + 1
            break

    end = len(lines)
    for marker in END_MARKERS:
        for i in range(start, len(lines)):
            if marker in lines[i]:
                end = i
                break
        if end != len(lines):
            break
    return start, end


def is_valid_headword(tok: str) -> bool:
    """Token toza qoraqalpoq bosh so'zimi? (faqat yaroqli harflar, shovqinsiz)"""
    core = tok.strip("-").strip()
    if not (2 <= len(core) <= 22):
        return False
    for ch in core:
        if ch == "-":
            continue
        if ch.lower() not in QQR_LETTERS:
            return False  # raqam, |, ), lotin harfi va h.k. bo'lsa — yaroqsiz
    return True


def is_qqr_word(tok: str) -> bool:
    """Tokenda qoraqalpoqqa xos harf bormi? (rus so'zidan ajratish uchun)"""
    return any(ch.lower() in QQR_ONLY for ch in tok)


# Bosh so'zni tarjimadan ajratish: birinchi ketma-ket lotin-bo'lmagan / katta harfli
# qoraqalpoq so'z(lar)i bosh so'z, qolgani tarjima deb hisoblaymiz.
# OCR formatida odatda:  "bosh_so'z   ruscha tarjima" yoki "bosh_so'z- tarjima"
SPLIT_RE = re.compile(r"^([\u0400-\u04ff\-\s]+?)\s+([\u0400-\u04ff].*)$")


def split_entry(line: str):
    """(qoraqalpoq_bosh_so'z, ruscha_tarjima) qaytaradi yoki None.

    Faqat ISHONCHLI yozuvlarni qabul qiladi: bosh so'z toza qoraqalpoq so'zi
    bo'lishi va qoraqalpoqqa xos harf(lar) saqlashi shart. Bu OCR shovqinini
    va rus nasr qatorlarini chetlab o'tadi.
    """
    s = line.strip()
    # Tartib raqami / sahifa raqamini olib tashlaymiz
    s = re.sub(r"^\d+\s*[\.\)]?\s*", "", s)
    words = s.split()
    if len(words) < 2:
        return None

    head = words[0]
    if not is_valid_headword(head):
        return None
    # Bosh so'z qoraqalpoqqa xos harf saqlashi shart (rus loyqasini kamaytirish uchun).
    if not is_qqr_word(head):
        return None

    translation = " ".join(words[1:]).strip(" -—.,")
    head = head.strip(" .,")
    if not head or not translation or len(translation) < 2:
        return None
    return head, translation


SYSTEM_TRANSLATE = (
    "Sen rus va qoraqalpoq tillari tarjimonisan. "
    "Berilgan ruscha so'zni qoraqalpoq tiliga (lotin alifbosida) tarjima qil. "
    "Faqat tarjimani yoz, qo'shimcha izoh berma."
)


def main():
    if not os.path.exists(INPUT_FILE):
        print(f"XATO: kirish fayli topilmadi: {INPUT_FILE}")
        print("Iltimos, lug'at .txt faylini shu yerga 'qqr-rus-cleaned.txt' nomi bilan qo'ying.")
        return

    with open(INPUT_FILE, "r", encoding="utf-8", errors="ignore") as f:
        lines = f.readlines()

    print(f"Jami qatorlar: {len(lines)}")

    start, end = find_region(lines)
    print(f"Asosiy lug'at qismi: {start}-{end} qatorlar oralig'ida.")
    body = lines[start:end]

    kept = []
    garbage = 0
    for ln in body:
        if is_garbage(ln):
            garbage += 1
            continue
        kept.append(ln.rstrip("\n"))

    print(f"Axlat sifatida tashlangan: {garbage}, qolgan: {len(kept)}")

    entries = []
    seen = set()
    for ln in kept:
        parsed = split_entry(ln)
        if not parsed:
            continue
        head_cyr, translation_ru = parsed
        if head_cyr in seen:
            continue
        seen.add(head_cyr)
        head_lat = translit(head_cyr)
        entries.append((head_lat, head_cyr, translation_ru))

    print(f"Ajratilgan lug'at yozuvlari: {len(entries)}")

    # TSV chiqarish
    with open(OUT_TSV, "w", encoding="utf-8") as f:
        f.write("qqr_latin\tqqr_kirill\truscha\n")
        for lat, cyr, ru in entries:
            f.write(f"{lat}\t{cyr}\t{ru}\n")
    print(f"TSV yozildi: {OUT_TSV}")

    # JSONL training dataset (rus -> qqr lotin)
    with open(OUT_JSONL, "w", encoding="utf-8") as f:
        for lat, cyr, ru in entries:
            sample = {
                "messages": [
                    {"role": "system", "content": SYSTEM_TRANSLATE},
                    {"role": "user", "content": ru},
                    {"role": "assistant", "content": lat},
                ]
            }
            f.write(json.dumps(sample, ensure_ascii=False) + "\n")
    print(f"JSONL yozildi: {OUT_JSONL}")

    print("\n--- Namuna (dastlabki 15 yozuv) ---")
    for lat, cyr, ru in entries[:15]:
        print(f"  {lat}  ({cyr})  =  {ru}")


if __name__ == "__main__":
    main()
