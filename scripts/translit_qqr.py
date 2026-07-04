# -*- coding: utf-8 -*-
"""
Qoraqalpoqcha-ruscha lug'at (1958, kirill) faylini tozalash + transliteratsiya.

Vazifalari:
  1) Muqova / so'zboshi (OCR axlat) qismini tashlab yuborish.
  2) Aniq axlat qatorlarni filtrlash (juda ko'p notarif belgili qatorlar).
  3) Qoraqalpoq KIRILL -> LOTIN transliteratsiya (faqat bosh so'z uchun).
  4) Tozalangan natijani .txt va .jsonl ga yozish.

ESLATMA: Faylda qoraqalpoqcha (bosh so'z) ham, ruscha (tarjima) ham KIRILL.
Ikkalasini 100% avtomatik ajratib bo'lmaydi. Shuning uchun standart rejimda
faqat HAR QATORDAGI BIRINCHI SO'Z (bosh so'z) lotinga o'giriladi, ruscha
tarjima kirillda qoladi. --all bayrog'i bilan butun qator o'giriladi.

Foydalanish:
    python translit_qqr.py qqr-rus-cleaned.txt
    python translit_qqr.py qqr-rus-cleaned.txt --all
"""
import sys
import re
import json
import unicodedata

# ── Qoraqalpoq kirill -> lotin xaritasi ──────────────────────────────────────
# Foydalanuvchi tasdiqlagan asosiy harflar: ы->ı, ң->ń, ә->á, ө->ó, ғ->ǵ
CYR2LAT = {
    'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'ғ': 'ǵ', 'д': 'd', 'е': 'e',
    'ё': 'yo', 'ж': 'j', 'з': 'z', 'и': 'i', 'й': 'y', 'к': 'k', 'қ': 'q',
    'л': 'l', 'м': 'm', 'н': 'n', 'ң': 'ń', 'о': 'o', 'ө': 'ó', 'п': 'p',
    'р': 'r', 'с': 's', 'т': 't', 'у': 'u', 'ұ': 'u', 'ү': 'ú', 'ў': 'w',
    'ф': 'f', 'х': 'x', 'ҳ': 'h', 'һ': 'h', 'ц': 'c', 'ч': 'ch', 'ш': 'sh',
    'щ': 'shch', 'ъ': '', 'ы': 'ı', 'і': 'i', 'ь': '', 'э': 'e', 'ю': 'yu',
    'я': 'ya', 'ә': 'á', 'ө': 'ó', 'ң': 'ń', 'ғ': 'ǵ', 'ы': 'ı',
}


def transliterate(text: str) -> str:
    """Kirill matnni qoraqalpoq lotin alifbosiga o'giradi (bosh harf saqlanadi)."""
    out = []
    for ch in text:
        lower = ch.lower()
        if lower in CYR2LAT:
            lat = CYR2LAT[lower]
            # Bosh harf bo'lsa, natijaning birinchi harfini ham bosh qilamiz
            if ch.isupper() and lat:
                lat = lat[0].upper() + lat[1:]
            out.append(lat)
        else:
            out.append(ch)
    return ''.join(out)


# ── Axlat (OCR shovqin) qatorlarni aniqlash ──────────────────────────────────
CYR_RE = re.compile(r'[а-яёәөңғқўұүһіы]', re.IGNORECASE)
# Ruxsat etilgan belgilar: kirill, lotin, raqam, bo'sh joy va oddiy tinish
ALLOWED_RE = re.compile(r"[а-яёәөңғқўұүһіыa-z0-9\s\.\,\;\:\!\?\(\)\-—…»«№]", re.IGNORECASE)


def garbage_ratio(line: str) -> float:
    """Ruxsat etilmagan belgilar ulushi (0..1). Yuqori bo'lsa - axlat."""
    s = line.strip()
    if not s:
        return 0.0
    bad = sum(1 for ch in s if not ALLOWED_RE.match(ch))
    return bad / len(s)


def is_garbage(line: str) -> bool:
    s = line.strip()
    if not s:
        return True
    # Kirill harf umuman yo'q bo'lsa - foydasiz
    if not CYR_RE.search(s):
        return True
    # Belgilarning 18% dan ko'pi ruxsatsiz bo'lsa - OCR axlat
    if garbage_ratio(s) > 0.18:
        return True
    # Juda qisqa (1-2 belgi) va mazmunsiz
    letters = sum(1 for ch in s if ch.isalpha())
    if letters < 2:
        return True
    return False


# ── So'zboshi tugab, asl lug'at qayerdan boshlanishini topish ─────────────────
PREFACE_MARKERS = [
    'предислови', 'издательств', 'москва', 'академия наук', 'баскаков',
    'грамматическ', 'словарь', 'сезлик', 'сөзлик', 'редакц', 'население',
]


def find_body_start(lines):
    """So'zboshidan keyingi haqiqiy lug'at boshlanishini taxminlaydi.

    Heuristika: so'zboshida uzun jumlalar bo'ladi (juda ko'p so'z bir qatorda).
    Lug'at yozuvlari odatda qisqa (bosh so'z + qisqa tarjima). Oxirgi
    so'zboshi markerli qatordan keyingi qatorni boshlanish deb olamiz.
    """
    last_preface = -1
    for i, ln in enumerate(lines):
        low = ln.lower()
        if any(m in low for m in PREFACE_MARKERS):
            last_preface = i
    return last_preface + 1 if last_preface >= 0 else 0


# ── Yozuvni ajratish: bosh so'z (qqr) + ruscha tarjima ───────────────────────
# Grammatik belgilar: ат.(ot), фе.(fe'l), сын.(sifat) va h.k. - bosh so'z chegarasi
GRAM_MARK_RE = re.compile(r'\b(ат|фе|сын|рә|сан|кө|тақ|бай|элк|жал)\.', re.IGNORECASE)


def parse_entry(line: str):
    """Qatorni (qqr_bosh_soz, rus_tarjima) ga ajratadi. Topilmasa None."""
    s = line.strip()
    # Birinchi bo'sh joygacha - taxminiy bosh so'z
    parts = s.split(None, 1)
    if len(parts) < 2:
        return None
    head, rest = parts[0], parts[1]
    # Grammatik belgini tarjimadan olib tashlaymiz (ixtiyoriy)
    rest = GRAM_MARK_RE.sub('', rest, count=1).strip(' .,;:')
    if not head or not rest:
        return None
    return head, rest


def main():
    if len(sys.argv) < 2:
        print("Foydalanish: python translit_qqr.py <fayl.txt> [--all]")
        sys.exit(1)

    path = sys.argv[1]
    translit_all = '--all' in sys.argv

    with open(path, 'r', encoding='utf-8', errors='replace') as f:
        raw_lines = f.readlines()

    raw_lines = [unicodedata.normalize('NFC', ln) for ln in raw_lines]
    start = find_body_start(raw_lines)
    body = raw_lines[start:]

    clean_lines = []   # tozalangan (lotin) qatorlar
    pairs = []         # (rus, qqr_lotin) juftliklar -> training uchun
    dropped = 0

    for ln in body:
        if is_garbage(ln):
            dropped += 1
            continue
        if translit_all:
            clean_lines.append(transliterate(ln.rstrip('\n')))
            continue
        parsed = parse_entry(ln)
        if not parsed:
            dropped += 1
            continue
        head_cyr, rus = parsed
        head_lat = transliterate(head_cyr)
        clean_lines.append(f"{head_lat}\t{rus}")
        pairs.append({"rus": rus, "qqr": head_lat})


    # ── Natijani yozish ──────────────────────────────────────────────────────
    out_txt = path.rsplit('.', 1)[0] + '_latin.txt'
    with open(out_txt, 'w', encoding='utf-8') as f:
        f.write('\n'.join(clean_lines))

    if pairs:
        out_jsonl = path.rsplit('.', 1)[0] + '_pairs.jsonl'
        with open(out_jsonl, 'w', encoding='utf-8') as f:
            for p in pairs:
                f.write(json.dumps(p, ensure_ascii=False) + '\n')

    print(f"Jami qator (so'zboshidan keyin): {len(body)}")
    print(f"Tashlangan (axlat/ajralmadi):    {dropped}")
    print(f"Tozalangan qator:                {len(clean_lines)}")
    print(f"Saqlandi: {out_txt}")
    if pairs:
        print(f"Saqlandi: {out_jsonl}  ({len(pairs)} juftlik)")
    print("\nDIQQAT: OCR sifati past bo'lsa, natijani ko'z bilan tekshiring!")


if __name__ == '__main__':
    main()
