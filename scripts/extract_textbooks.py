"""
Qoraqalpoq darsliklari (PDF) -> CPT (Continued Pretraining) korpusi.

Kirish: matnli (skaner EMAS) lotin alifbosidagi PDF darsliklar.
  Kaggle: /kaggle/input/<dataset>/  (PDF lar shu yerda)
  Lokal:  scripts/textbooks/         (PDF larni shu yerga qo'ying)

Chiqish (Kaggle'da /kaggle/working/, lokalda scripts/):
  qqr_corpus.txt   - butun toza matn (tekshirish uchun)
  qqr_cpt.jsonl    - {"text": "..."} bo'laklari (Unsloth CPT uchun)

Bog'liqlik: PyMuPDF (fitz).  Kaggle: !pip install pymupdf
Ishlatish (Kaggle):
    python extract_textbooks.py --input /kaggle/input/qqr-books --output /kaggle/working
"""

import argparse
import json
import os
import re
import sys


def extract_pdf_text(path: str) -> str:
    """PDF dan matnni ajratadi (PyMuPDF)."""
    import fitz  # PyMuPDF
    doc = fitz.open(path)
    pages = []
    for page in doc:
        pages.append(page.get_text("text"))
    doc.close()
    return "\n".join(pages)


# ── TOZALASH ───────────────────────────────────────────────────────────────────

# Homoglyph: ko'rinishi lotinga o'xshash KIRILL harflar -> asl LOTIN harf.
# Word/PDF da xato terilgan kirill belgilarni tuzatadi (a/а, o/о, e/е, ...).
HOMOGLYPH = {
    "а": "a", "е": "e", "о": "o", "р": "p", "с": "c", "у": "y", "х": "x",
    "к": "k", "т": "t", "м": "m", "н": "h", "і": "i", "ј": "j", "ѕ": "s",
    "һ": "h", "ԛ": "q", "ԝ": "w", "в": "v",
    "А": "A", "Е": "E", "О": "O", "Р": "P", "С": "C", "У": "Y", "Х": "X",
    "К": "K", "Т": "T", "М": "M", "Н": "H", "В": "B", "І": "I", "Ј": "J",
    "Ѕ": "S",
}


def normalize_homoglyphs(text: str):
    """Kirill homoglyph belgilarni lotinga o'giradi. (matn, tuzatilgan_son) qaytaradi."""
    fixed = 0
    out = []
    for ch in text:
        if ch in HOMOGLYPH:
            out.append(HOMOGLYPH[ch])
            fixed += 1
        else:
            out.append(ch)
    return "".join(out), fixed


# Qoraqalpoq lotin harflari (matnli qatorlarni aniqlash uchun)
QQR_LATIN = set("abdefghijklmnopqrstuwxyzáǵıńóúçşABDEFGHIJKLMNOPQRSTUWXYZÁǴINÓÚ")

PAGE_NUM_RE = re.compile(r"^\s*\d{1,4}\s*$")          # yolg'iz sahifa raqami
EXERCISE_RE = re.compile(r"^\s*\d+[\.\)]\s*")          # "12." yoki "12)" mashq raqami


def is_text_line(line: str) -> bool:
    """Qatorda yetarlicha harf bormi (sarlavha/raqam/bo'sh emas)?"""
    s = line.strip()
    if len(s) < 3:
        return False
    if PAGE_NUM_RE.match(s):
        return False
    letters = sum(1 for c in s if c.isalpha())
    if letters < 3:
        return False
    # Harflar belgilarning yarmidan kam bo'lsa — shovqin
    if letters < len(s) * 0.5:
        return False
    return True


def clean_text(raw: str) -> str:
    """Xom matnni tozalaydi: shovqin qatorlarni tashlaydi, qatorlarni birlashtiradi.
    Darsliklar LOTIN alifbosida — transliteratsiya kerak emas."""
    lines = raw.split("\n")
    kept = [ln.strip() for ln in lines if is_text_line(ln)]

    # Tire bilan bo'lingan so'zlarni birlashtirish: "so'z-\nlar" -> "so'zlar"
    text = "\n".join(kept)
    text = re.sub(r"(\w)-\n(\w)", r"\1\2", text)

    # Qatorlarni paragraflarga birlashtirish:
    # gap tugamagan (nuqta/savol/undov bilan tugamagan) qatorlarni keyingisiga ulaymiz.
    out_lines = []
    buf = ""
    for ln in text.split("\n"):
        ln = ln.strip()
        if not ln:
            continue
        buf = (buf + " " + ln).strip() if buf else ln
        if re.search(r"[.!?:;»\"]$", buf):
            out_lines.append(buf)
            buf = ""
    if buf:
        out_lines.append(buf)

    return "\n".join(out_lines)


# ── CHIQARISH ──────────────────────────────────────────────────────────────────

def chunk_text(text: str, max_chars: int = 1200):
    """Matnni ~max_chars belgilik bo'laklarga bo'ladi (gap chegarasida)."""
    chunks = []
    buf = ""
    for para in text.split("\n"):
        para = para.strip()
        if not para:
            continue
        if len(buf) + len(para) + 1 > max_chars and buf:
            chunks.append(buf.strip())
            buf = para
        else:
            buf = (buf + "\n" + para).strip() if buf else para
    if buf:
        chunks.append(buf.strip())
    # Juda qisqa bo'laklarni tashlaymiz
    return [c for c in chunks if len(c) >= 200]


def main():
    ap = argparse.ArgumentParser()
    here = os.path.dirname(os.path.abspath(__file__))
    ap.add_argument("--input", default=os.path.join(here, "textbooks"),
                    help="PDF lar joylashgan papka")
    ap.add_argument("--output", default=here, help="Chiqish papkasi")
    args = ap.parse_args()

    if os.path.isfile(args.input) and args.input.lower().endswith(".pdf"):
        # Bitta PDF fayl berilgan
        in_dir = os.path.dirname(args.input)
        pdfs = [os.path.basename(args.input)]
    elif os.path.isdir(args.input):
        in_dir = args.input
        pdfs = sorted(f for f in os.listdir(args.input) if f.lower().endswith(".pdf"))
    else:
        print(f"XATO: kirish topilmadi (papka yoki .pdf fayl bering): {args.input}")
        sys.exit(1)

    if not pdfs:
        print(f"XATO: {args.input} ichida PDF topilmadi.")
        sys.exit(1)

    print(f"{len(pdfs)} ta PDF topildi.")
    all_text = []
    for name in pdfs:
        path = os.path.join(in_dir, name)
        try:
            raw = extract_pdf_text(path)
        except Exception as e:
            print(f"  [O'TKAZILDI] {name}: {e}")
            continue
        cleaned = clean_text(raw)
        all_text.append(cleaned)
        print(f"  [OK] {name}: {len(cleaned)} belgi")

    corpus = "\n\n".join(all_text)
    txt_path = os.path.join(args.output, "qqr_corpus.txt")
    with open(txt_path, "w", encoding="utf-8") as f:
        f.write(corpus)
    print(f"\nKorpus yozildi: {txt_path}  ({len(corpus)} belgi)")

    chunks = chunk_text(corpus)
    jsonl_path = os.path.join(args.output, "qqr_cpt.jsonl")
    with open(jsonl_path, "w", encoding="utf-8") as f:
        for ch in chunks:
            f.write(json.dumps({"text": ch}, ensure_ascii=False) + "\n")
    print(f"CPT dataset yozildi: {jsonl_path}  ({len(chunks)} bo'lak)")

    print("\n--- Namuna (1-bo'lak) ---")
    if chunks:
        print(chunks[0][:500])


if __name__ == "__main__":
    main()
