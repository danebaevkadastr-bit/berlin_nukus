"""
Qoraqalpoq tili: KIRILL -> LOTIN transliteratsiya moduli.

Qoraqalpoq lotin alifbosi (2016-yildan keyingi rasmiy variant):
  ы -> ı,  ң -> ń,  ә -> á,  ө -> ó,  ғ -> ǵ,  ў -> w,  ү -> ú  va h.k.
  ч, ш, щ -> sh  (qoraqalpoqda "ch" va "shch" yo'q!)

MUHIM: Bu modul faqat QORAQALPOQ matnini o'giradi.
Rus tilidagi tarjima qismi KIRILLDA qoladi (uni o'girmaymiz).

Ishlatish:
    from qqr_translit import translit
    translit("ҚАРАҚАЛПАҚША")  -> "QARAQALPAQSHA"
"""

# Ko'p harfli (digraf) almashtirishlar AVVAL bajariladi.
# MUHIM: Qoraqalpoq tilida "ch" va "shch" yo'q.
# Kirill ч, ш, щ — uchalasi ham bitta "sh" tovushiga o'giriladi.
_MULTI = [
    ("щ", "sh"),
    ("ч", "sh"),
    ("ш", "sh"),
    ("ю", "yu"),
    ("я", "ya"),
    ("ё", "yo"),
]

# Bir harfli almashtirishlar (kichik harf bilan beriladi, katta harf avtomatik).
_SINGLE = {
    "а": "a", "ә": "á", "б": "b", "в": "v", "г": "g", "ғ": "ǵ",
    "д": "d", "е": "e", "ж": "j", "з": "z", "и": "i", "й": "y",
    "к": "k", "қ": "q", "л": "l", "м": "m", "н": "n", "ң": "ń",
    "о": "o", "ө": "ó", "п": "p", "р": "r", "с": "s", "т": "t",
    "у": "u", "ў": "w", "ұ": "u", "ү": "ú", "ф": "f", "х": "x",
    "ҳ": "h", "һ": "h", "ц": "c", "ы": "ı", "і": "i",
    "ъ": "'", "ь": "'", "э": "e",
}


def _match_case(src_char: str, repl: str, all_caps: bool = False) -> str:
    """Asl harf katta bo'lsa, almashtirilgan matnni ham mos holatga keltiradi.

    all_caps=True bo'lsa (masalan QARAQALPAQSHA), digraf to'liq katta yoziladi.
    Aks holda faqat birinchi harf katta (Cho'l -> Chol kabi).
    """
    if src_char.isupper():
        if len(repl) > 1 and not all_caps:
            return repl[0].upper() + repl[1:]
        return repl.upper()
    return repl


def translit(text: str) -> str:
    """Qoraqalpoq kirill matnini lotinga o'giradi."""
    result = []
    i = 0
    n = len(text)
    while i < n:
        ch = text[i]
        low = ch.lower()

        # Atrofdagi harflarga qarab "all caps" holatini aniqlaymiz.
        prev_ch = text[i - 1] if i > 0 else ""
        next_ch = text[i + 1] if i + 1 < n else ""
        all_caps = (next_ch.isupper() or prev_ch.isupper())

        # 1) Digraflarni tekshiramiz (щ, ч, ш, ю, я, ё)
        matched = False
        for cyr, lat in _MULTI:
            if low == cyr:
                result.append(_match_case(ch, lat, all_caps))
                matched = True
                break
        if matched:
            i += 1
            continue

        # 2) Bir harfli almashtirish
        if low in _SINGLE:
            result.append(_match_case(ch, _SINGLE[low], all_caps))
        else:
            # Kirill bo'lmagan belgilar (raqam, tinish belgisi, bo'sh joy) o'zgarmaydi
            result.append(ch)
        i += 1

    return "".join(result)


# Matnda kirill harf bormi-yo'qmi tekshirish (qoraqalpoq qatorini aniqlash uchun)
_CYRILLIC = set(_SINGLE.keys()) | {c for c, _ in _MULTI}


def has_cyrillic(text: str) -> bool:
    return any(c.lower() in _CYRILLIC for c in text)


if __name__ == "__main__":
    # Tezkor test
    tests = [
        ("ҚАРАҚАЛПАҚША", "QARAQALPAQSHA"),
        ("сөзлик", "sózlik"),
        ("тил", "til"),
        ("ың", "ıń"),
        ("әне", "áne"),
        ("ғарры", "ǵarrı"),
        ("чай", "shay"),
        ("щи", "shi"),
    ]
    ok = True
    for src, expected in tests:
        got = translit(src)
        mark = "OK " if got == expected else "XATO"
        if got != expected:
            ok = False
        print(f"[{mark}] {src!r} -> {got!r} (kutilgan: {expected!r})")
    print("\nHammasi to'g'ri!" if ok else "\nBa'zi testlar xato!")
