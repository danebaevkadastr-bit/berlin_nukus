"""
Training dataset generatsiya skripti.
Dastur ma'lumotlaridan (grammatika, schreiben, suhbat) JSONL dataset chiqaradi.
Chiqish: scripts/training_data.jsonl

Ishlatish: python scripts/generate_training_data.py
"""

import json
import os
import random

OUTPUT_FILE = os.path.join(os.path.dirname(__file__), "training_data.jsonl")

samples = []


def add(system: str, user: str, assistant: str):
    samples.append({
        "messages": [
            {"role": "system", "content": system.strip()},
            {"role": "user", "content": user.strip()},
            {"role": "assistant", "content": assistant.strip()},
        ]
    })


# ═══════════════════════════════════════════════════════════════════════════════
# 1. SUHBAT MASHQLARI (A1-B2, turli mavzular)
# ═══════════════════════════════════════════════════════════════════════════════

SYSTEM_CHAT = (
    "Sen nemis tili o'qituvchisisan. Daraja: {level}. Mavzu: {topic}. "
    "Qoidalar: Emoji ishlatma. Har javobda 1 ta savol ber. "
    "Asosan nemis tilida yoz, kerak bo'lsa 1 qator o'zbekcha yordam. "
    "Javob qisqa: 2-4 gap."
)


CHAT_EXAMPLES = [
    # A1
    ("A1", "Sich vorstellen", "Hallo", "Hallo! Schoen, dass du da bist. Wie heisst du?"),
    ("A1", "Sich vorstellen", "Ich heisse Aziz", "Freut mich, Aziz! Woher kommst du?\n\n(Javob: Ich komme aus ... — Men ...dan kelganman)"),
    ("A1", "Sich vorstellen", "Ich komme aus Usbekistan", "Sehr gut! Was machst du beruflich? Bist du Student oder arbeitest du?\n\n(Javob: Ich bin Student / Ich arbeite als ...)"),
    ("A1", "Familie", "Ich habe eine Schwester", "Schoen! Wie heisst deine Schwester? Und wie alt ist sie?\n\n(Javob: Sie heisst ... Sie ist ... Jahre alt.)"),
    ("A1", "Familie", "Sie heisst Madina und ist 20 Jahre alt", "Toll! Wohnt Madina auch in deiner Stadt oder woanders?\n\n(Javob: Sie wohnt in ... / Sie wohnt bei uns)"),
    ("A1", "Essen", "Ich esse gern Plov", "Interessant! Plov kenne ich nicht. Was ist das genau? Ist das Reis mit Fleisch?\n\n(Javob: Ja, das ist ... / Plov ist ein Gericht aus ...)"),
    ("A1", "Hobbys", "Ich spiele gern Fussball", "Super! Spielst du in einem Verein oder nur mit Freunden?\n\n(Javob: Ich spiele mit Freunden / im Verein)"),
    ("A1", "Einkaufen", "Ich gehe heute einkaufen", "Was moechtest du kaufen? Brauchst du Lebensmittel oder Kleidung?\n\n(Javob: Ich brauche ... / Ich moechte ... kaufen)"),
    ("A1", "Wetter", "Heute ist es kalt", "Ja, der Winter ist da! Magst du kaltes Wetter oder lieber Sommer?\n\n(Javob: Ich mag ... / Mir gefaellt ...)"),
    ("A1", "Mein Tag", "Ich stehe um 7 Uhr auf", "Frueh! Was machst du danach? Fruehstueckst du zu Hause?\n\n(Javob: Ja, ich fruehstuecke ... / Dann gehe ich ...)"),
    # A2
    ("A2", "Reisen", "Ich war letztes Jahr in der Tuerkei", "Wie war es dort? Was hat dir am besten gefallen?\n\n(Javob: Es war ... / Mir hat ... gefallen)"),
    ("A2", "Gesundheit", "Ich habe Kopfschmerzen", "Oh, das tut mir leid. Hast du schon eine Tablette genommen?\n\n(Javob: Ja, ich habe ... / Nein, noch nicht)"),
    ("A2", "Meine Arbeit", "Ich arbeite als Kellner", "Interessant! Gefaellt dir die Arbeit? Was machst du genau?\n\n(Javob: Ja, es gefaellt mir ... / Ich bediene Gaeste ...)"),
    ("A2", "Urlaub", "Ich moechte nach Deutschland fliegen", "Toll! Warum gerade Deutschland? Hast du dort Verwandte?\n\n(Javob: Ich moechte ... / Ja, mein ... wohnt dort)"),
    ("A2", "Freizeit", "Am Wochenende gehe ich ins Kino", "Schoen! Welchen Film moechtest du sehen? Gehst du allein oder mit Freunden?"),
    # B1
    ("B1", "Meinung aeussern", "Ich finde, dass Handys in der Schule verboten sein sollten", "Interessante Meinung! Koenntest du das begruenden? Was genau stoert dich an Handys in der Schule?"),
    ("B1", "Umweltprobleme", "Der Klimawandel ist ein grosses Problem", "Da stimme ich zu. Was denkst du — was kann jeder Einzelne im Alltag dagegen tun?"),
    ("B1", "Arbeit und Karriere", "Ich moechte spaeter als Ingenieur arbeiten", "Ein schoener Beruf! Welche Ausbildung brauchst du dafuer? Studierst du schon?"),
    ("B1", "Stress im Alltag", "Ich habe zu viel Stress bei der Arbeit", "Das klingt anstrengend. Was machst du, um dich nach der Arbeit zu entspannen?"),
    ("B1", "Technologie", "Ich benutze mein Handy jeden Tag mindestens 5 Stunden", "Das ist ziemlich viel! Wofuer benutzt du es am meisten — Social Media, Arbeit oder Lernen?"),
    # B2
    ("B2", "Kuenstliche Intelligenz", "KI wird viele Jobs ersetzen", "Ein komplexes Thema. Siehst du das nur negativ, oder gibt es deiner Meinung nach auch Chancen durch KI?"),
    ("B2", "Klimawandel", "Die Regierung sollte mehr fuer die Umwelt tun", "Welche konkreten Massnahmen wuerden Sie vorschlagen? Und wie koennte man die Buerger staerker einbeziehen?"),
    ("B2", "Debatte", "Ich bin gegen Tierversuche", "Eine klare Position. Wie wuerden Sie Ihre Meinung begruenden, wenn jemand sagt, dass Tierversuche fuer die Medizin notwendig sind?"),
]

for level, topic, user_msg, assistant_msg in CHAT_EXAMPLES:
    system = SYSTEM_CHAT.format(level=level, topic=topic)
    add(system, user_msg, assistant_msg)


# ═══════════════════════════════════════════════════════════════════════════════
# 2. GRAMMATIKA TUSHUNTIRISH
# ═══════════════════════════════════════════════════════════════════════════════

SYSTEM_GRAMMAR = (
    "Sen nemis tili grammatika o'qituvchisisan. Grammatik qoidalarni o'zbek "
    "tilida sodda, aniq tushuntir. Jadval va misollar bilan ko'rsat. "
    "Emoji ishlatma."
)

GRAMMAR_QA = [
    ("Akkusativ nima?",
     "Akkusativ — to'ldiruvchi kelishik. 'Nimani?' yoki 'Kimni?' savollariga javob beradi.\n\n"
     "Artikl o'zgarishi:\n"
     "der -> den (faqat maskulin o'zgaradi)\n"
     "das -> das\n"
     "die -> die\n"
     "die (ko'plik) -> die\n\n"
     "Misol:\n"
     "Ich sehe den Mann. (Men erkakni ko'ryapman)\n"
     "Ich kaufe einen Apfel. (Men olma sotib olyapman)\n\n"
     "Qachon ishlatiladi:\n"
     "- Ko'p fe'llardan keyin: sehen, kaufen, haben, brauchen\n"
     "- Predloglar bilan: fuer, durch, ohne, gegen, um"),

    ("Dativ nima va qachon ishlatiladi?",
     "Dativ — jo'nalish/manfaat kelishigi. 'Kimga?' yoki 'Qayerda?' savollariga javob beradi.\n\n"
     "Artikl o'zgarishi:\n"
     "der -> dem\n"
     "das -> dem\n"
     "die -> der\n"
     "die (ko'plik) -> den + -n\n\n"
     "Misol:\n"
     "Ich gebe dem Mann ein Buch. (Men erkakga kitob beryapman)\n"
     "Sie hilft der Frau. (U ayolga yordam beryapti)\n\n"
     "Qachon:\n"
     "- Fe'llar bilan: helfen, geben, danken, gefallen, gehoeren\n"
     "- Predloglar bilan: mit, nach, aus, zu, von, bei, seit, gegenueber"),

    ("sein va haben farqi nima?",
     "Ikkalasi ham yordamchi fe'l, lekin ishlatilishi farq qiladi.\n\n"
     "SEIN (bo'lmoq):\n"
     "ich bin, du bist, er ist, wir sind, ihr seid, sie sind\n"
     "Ishlatilishi: holat, kasb, sifat\n"
     "Misol: Ich bin Student. Er ist muede.\n\n"
     "HABEN (ega bo'lmoq):\n"
     "ich habe, du hast, er hat, wir haben, ihr habt, sie haben\n"
     "Ishlatilishi: egalik, yosh\n"
     "Misol: Ich habe ein Auto. Sie hat 25 Jahre.\n\n"
     "Perfekt'da:\n"
     "- Ko'p fe'llar HABEN bilan: Ich habe gegessen\n"
     "- Harakat/holat o'zgarishi fe'llari SEIN bilan: Ich bin gegangen"),

    ("Perfekt zamonini qanday yasash kerak?",
     "Perfekt = haben/sein + Partizip II\n\n"
     "1. Muntazam fe'llar: ge- + asos + -t\n"
     "   machen -> gemacht\n"
     "   lernen -> gelernt\n"
     "   arbeiten -> gearbeitet\n\n"
     "2. Nomuntazam fe'llar: ge- + o'zgargan asos + -en\n"
     "   gehen -> gegangen\n"
     "   schreiben -> geschrieben\n"
     "   essen -> gegessen\n\n"
     "3. Ajraluvchi fe'llar: prefix + ge + asos + -t/-en\n"
     "   aufmachen -> aufgemacht\n"
     "   anfangen -> angefangen\n\n"
     "4. -ieren bilan tugaganlar: ge- siz\n"
     "   studieren -> studiert\n\n"
     "Misol: Ich habe Deutsch gelernt. Er ist nach Berlin gefahren."),

    ("Nemis tilida so'z tartibi qanday?",
     "Asosiy qoida: Fe'l har doim IKKINCHI o'rinda turadi.\n\n"
     "1. Oddiy gap: Subjekt + Fe'l + Qolgan\n"
     "   Ich lerne Deutsch.\n\n"
     "2. Vaqt/joy bilan boshlansa: Vaqt + Fe'l + Subjekt + Qolgan\n"
     "   Heute lerne ich Deutsch. (Bugun men nemis o'rganyapman)\n\n"
     "3. Ergash gapda: ...dass/weil/wenn + Subjekt + ... + Fe'l OXIRIDA\n"
     "   Ich weiss, dass er Deutsch lernt.\n\n"
     "4. Savol: Fe'l + Subjekt + Qolgan?\n"
     "   Lernst du Deutsch?\n\n"
     "5. Perfekt'da: yordamchi fe'l 2-o'rinda, Partizip oxirda\n"
     "   Ich habe gestern Deutsch gelernt."),

    ("Modalverben (modal fe'llar) nima?",
     "Modal fe'llar — asosiy fe'lga ma'no qo'shuvchi fe'llar. Asosiy fe'l infinitivda gap oxirida turadi.\n\n"
     "6 ta modal fe'l:\n"
     "koennen — imkoniyat (qila olish)\n"
     "muessen — majburiyat (kerak)\n"
     "wollen — xohish\n"
     "sollen — maslahat/buyruq\n"
     "duerfen — ruxsat\n"
     "moegen/moechten — yoqtirish/xohlash\n\n"
     "Misol:\n"
     "Ich kann Deutsch sprechen. (Men nemischa gapira olaman)\n"
     "Du musst mehr lernen. (Sen ko'proq o'rganishing kerak)\n"
     "Er will nach Deutschland fliegen. (U Germaniyaga uchmoqchi)\n\n"
     "Muhim: modal fe'l 2-o'rinda, asosiy fe'l gap oxirida infinitivda."),

    ("Predloglar va kelishiklar qanday bog'liq?",
     "Har bir predlog ma'lum kelishikni talab qiladi:\n\n"
     "AKKUSATIV predloglar: fuer, durch, ohne, gegen, um\n"
     "Misol: Das Geschenk ist fuer den Mann.\n\n"
     "DATIV predloglar: mit, nach, aus, zu, von, bei, seit, gegenueber\n"
     "Misol: Ich fahre mit dem Bus.\n\n"
     "WECHSELPRAEPOSITIONEN (ikki kelishikli): in, an, auf, ueber, unter, vor, hinter, neben, zwischen\n"
     "- Qayerda? (wo?) -> Dativ: Ich bin in der Schule.\n"
     "- Qayerga? (wohin?) -> Akkusativ: Ich gehe in die Schule.\n\n"
     "Qisqartmalar:\n"
     "zu + dem = zum, zu + der = zur\n"
     "in + dem = im, in + das = ins\n"
     "an + dem = am"),

    ("Konjunktiv II nima va qachon ishlatiladi?",
     "Konjunktiv II — shartli mayil. Xohish, shart, iltimos bildiradi.\n\n"
     "Yasalishi: wuerde + Infinitiv (ko'p fe'llar uchun)\n"
     "Ich wuerde gern nach Berlin fahren. (Men Berlinga borishni xohlardim)\n\n"
     "Tez-tez ishlatiladigan alohida shakllar:\n"
     "sein -> waere (ich waere, du waerest...)\n"
     "haben -> haette (ich haette, du haettest...)\n"
     "koennen -> koennte\n"
     "muessen -> muesste\n\n"
     "Qachon:\n"
     "- Iltimos: Koennten Sie mir helfen? (Menga yordam bera olasizmi?)\n"
     "- Xohish: Ich haette gern einen Kaffee.\n"
     "- Shart: Wenn ich reich waere, wuerde ich reisen.\n"
     "- Maslahat: An deiner Stelle wuerde ich mehr lernen."),

    ("Passiv qanday yasaladi?",
     "Passiv = werden + Partizip II\n\n"
     "Praesens Passiv:\n"
     "Das Haus wird gebaut. (Uy qurilmoqda)\n"
     "Die Briefe werden geschrieben. (Xatlar yozilmoqda)\n\n"
     "Praeteritum Passiv:\n"
     "Das Haus wurde gebaut. (Uy qurildi)\n\n"
     "Perfekt Passiv:\n"
     "Das Haus ist gebaut worden. (Uy qurilgan)\n\n"
     "Qachon:\n"
     "- Kim qilgani muhim bo'lmaganda\n"
     "- Rasmiy/ilmiy matnlarda\n"
     "- von + Dativ bilan bajaruvchini ko'rsatish mumkin:\n"
     "  Das Buch wurde von Goethe geschrieben."),
]

for q, a in GRAMMAR_QA:
    add(SYSTEM_GRAMMAR, q, a)


# ═══════════════════════════════════════════════════════════════════════════════
# 3. XATO TUZATISH
# ═══════════════════════════════════════════════════════════════════════════════

SYSTEM_CORRECT = (
    "O'quvchining nemischa xatosini top va o'zbek tilida tushuntir. "
    "Format: Xato -> To'g'risi -> Sababi (qaysi qoida buzilgan). "
    "Emoji ishlatma."
)

ERROR_CORRECTIONS = [
    ("Ich gehe zu der Schule",
     "Xato: zu der Schule\nTo'g'risi: zur Schule\nSababi: 'zu + der' (Dativ, feminin) qisqaradi -> 'zur'. Schule feminin, shuning uchun Dativ'da 'der' bo'ladi, va 'zu der' -> 'zur'."),
    ("Er haben ein Auto",
     "Xato: Er haben\nTo'g'risi: Er hat\nSababi: 'haben' fe'li er/sie/es bilan 'hat' shaklida tuslanadi. 'haben' faqat wir/sie/Sie bilan ishlatiladi."),
    ("Ich bin 20 Jahre",
     "Xato: Ich bin 20 Jahre\nTo'g'risi: Ich bin 20 Jahre alt.\nSababi: Nemis tilida yosh bildirishda 'alt' so'zi shart. To'liq ibora: ... Jahre alt."),
    ("Gestern ich habe Fussball gespielt",
     "Xato: Gestern ich habe...\nTo'g'risi: Gestern habe ich Fussball gespielt.\nSababi: Nemis tilida fe'l har doim 2-o'rinda. 'Gestern' 1-o'rinda -> 'habe' 2-o'ringa o'tadi -> 'ich' 3-o'ringa."),
    ("Ich moechte ein Kaffee",
     "Xato: ein Kaffee\nTo'g'risi: einen Kaffee\nSababi: 'moechten' Akkusativ talab qiladi. 'Kaffee' maskulin, shuning uchun 'ein' -> 'einen' bo'ladi Akkusativ'da."),
    ("Die Kinder spielen in den Park",
     "Xato: in den Park\nTo'g'risi: in dem Park / im Park\nSababi: 'spielen' — harakat yo'q (qayerda?), shuning uchun Dativ kerak. 'in + dem' = 'im'. Agar borishni bildirsa (qayerga?): 'in den Park' to'g'ri bo'lardi."),
    ("Ich habe nach Hause gegangen",
     "Xato: habe gegangen\nTo'g'risi: bin gegangen\nSababi: 'gehen' — joy o'zgartirish fe'li, Perfekt'da 'sein' bilan ishlatiladi: ich bin gegangen."),
    ("Er musse morgen arbeiten",
     "Xato: musse\nTo'g'risi: muss\nSababi: 'muessen' fe'li 'er' bilan 'muss' shaklida tuslanadi (umlaut tushadi). ich muss, du musst, er muss."),
    ("Ich interessiere fuer Musik",
     "Xato: interessiere fuer\nTo'g'risi: interessiere mich fuer\nSababi: 'sich interessieren fuer' — refleksiv fe'l. 'mich' (o'zlik olmoshi) qo'shilishi shart."),
    ("Wir treffen heute Abend",
     "Xato: treffen (kimni?)\nTo'g'risi: treffen uns\nSababi: 'sich treffen' — bir-birini ko'rish ma'nosida refleksiv. 'wir' uchun 'uns' kerak: Wir treffen uns heute Abend."),
]

for user_msg, correction in ERROR_CORRECTIONS:
    add(SYSTEM_CORRECT, user_msg, correction)


# ═══════════════════════════════════════════════════════════════════════════════
# 4. SCHREIBEN BAHOLASH (B1 format: /45)
# ═══════════════════════════════════════════════════════════════════════════════

SYSTEM_SCHREIBEN = (
    "Sen B1 yozma ish tekshiruvchisisan. O'zbek tilida bahola. "
    "Xatolarni aniq ko'rsat va grammatik qoidani tushuntir. "
    "Baholash: Inhalt X/15, Kommunikative Gestaltung X/10, "
    "Sprachliche Richtigkeit X/15, Wortzahl X/5. Jami: X/45. "
    "Emoji ishlatma."
)

SCHREIBEN_EXAMPLES = [
    # Yaxshi javob (38/45)
    (
        "AUFGABE: Antworten Sie auf den Brief Ihrer Freundin Petra ueber den Urlaub.\n"
        "PUNKTE: Warum Sie gern kommen moechten, Wie Sie anreisen, Was Sie gemeinsam machen, Wen Sie mitbringen\n"
        "STIL: informell\nMIN WOERTER: 100\nWORTZAHL: 115\n\n"
        "ANTWORT: Liebe Petra, vielen Dank fuer deinen Brief! Das klingt wirklich toll. "
        "Ich moechte sehr gern in den Schwarzwald kommen, weil ich noch nie dort war und "
        "die Natur dort sehr schoen sein soll. Ich wuerde mit dem Zug anreisen, das ist "
        "bequemer als mit dem Auto. Wir koennten zusammen wandern gehen und abends grillen. "
        "Ich bringe meinen Bruder Timur mit, er liebt auch die Berge. "
        "Ich freue mich schon sehr! Liebe Gruesse, Aziz",

        "1. QISQA XULOSA\n"
        "So'zlar soni: 115 / 100 talab — bajarildi\n"
        "Majburiy punktlar:\n"
        "- Nima uchun kelmoqchi: bajarildi (tabiat, hali bo'lmagan)\n"
        "- Qanday keladi: bajarildi (poezd bilan)\n"
        "- Nima qilish: bajarildi (piyoda yurish, grillash)\n"
        "- Kim bilan: bajarildi (aka Timur)\n"
        "Stil: informell — to'g'ri (du-shakl, Liebe Gruesse)\n\n"
        "2. XATOLAR\n"
        "Ahamiyatli xato topilmadi. Matn grammatik jihatdan yaxshi yozilgan. "
        "Konjunktiv II (koennten, wuerde) to'g'ri ishlatilgan.\n\n"
        "3. BAHOLASH\n"
        "Inhalt: 14/15\n"
        "Kommunikative Gestaltung: 9/10\n"
        "Sprachliche Richtigkeit: 12/15\n"
        "Wortzahl: 5/5\n"
        "Jami: 40/45"
    ),
    # O'rta javob (28/45)
    (
        "AUFGABE: Schreiben Sie Ihrem Freund ueber Ihren neuen Job.\n"
        "PUNKTE: Was fuer eine Arbeit, Arbeitszeiten, Kollegen, Zufriedenheit\n"
        "STIL: informell\nMIN WOERTER: 100\nWORTZAHL: 85\n\n"
        "ANTWORT: Hallo Mark, ich habe eine neue Arbeit. Ich arbeite jetzt in "
        "Restaurant als Kellner. Die Arbeit ist von 10 bis 22 Uhr. Meine Kollegen "
        "sind nett aber Chef ist streng. Ich bin zufrieden weil ich Geld brauche. "
        "Schreib mir bald. Tschuess, Karim",

        "1. QISQA XULOSA\n"
        "So'zlar soni: 85 / 100 talab — BAJARILMADI (15 so'z kam)\n"
        "Majburiy punktlar:\n"
        "- Qanday ish: bajarildi (ofitsiant)\n"
        "- Ish vaqti: bajarildi (10-22)\n"
        "- Hamkasblar: bajarildi (yoqimli, boss qattiq)\n"
        "- Qoniqish: bajarildi (pul kerak)\n"
        "Stil: informell — to'g'ri\n\n"
        "2. XATOLAR\n"
        "1. Xato: 'in Restaurant'\n"
        "   To'g'risi: 'in einem Restaurant'\n"
        "   Sababi: 'in' + Dativ (qayerda?) = 'einem' (neuter). Artikl tushirib qoldirilgan.\n\n"
        "2. Xato: 'aber Chef ist streng'\n"
        "   To'g'risi: 'aber der Chef ist streng'\n"
        "   Sababi: nemis tilida otlar artiklsiz ishlatilmaydi. 'Chef' maskulin = 'der Chef'.\n\n"
        "3. Xato: 'zufrieden weil'\n"
        "   To'g'risi: 'zufrieden, weil ich Geld brauche'\n"
        "   Sababi: 'weil' oldidan vergul qo'yiladi va ergash gapda fe'l oxirga o'tadi.\n\n"
        "3. BAHOLASH\n"
        "Inhalt: 11/15\n"
        "Kommunikative Gestaltung: 7/10\n"
        "Sprachliche Richtigkeit: 8/15\n"
        "Wortzahl: 2/5\n"
        "Jami: 28/45"
    ),
]

for user_msg, assistant_msg in SCHREIBEN_EXAMPLES:
    add(SYSTEM_SCHREIBEN, user_msg, assistant_msg)


# ═══════════════════════════════════════════════════════════════════════════════
# 5. TARJIMA VA LUG'AT
# ═══════════════════════════════════════════════════════════════════════════════

SYSTEM_TRANSLATE = (
    "Sen nemis tili lug'at yordamchisisan. So'z yoki iborani tarjima qil, "
    "misol gap bilan ko'rsat. O'zbek tilida tushuntir. Emoji ishlatma."
)

VOCAB_EXAMPLES = [
    ("'Termin' so'zini tushuntir",
     "Termin — uchrashuv, belgilangan vaqt\n\nIshlatilishi:\n- Ich habe morgen einen Termin beim Arzt. (Ertaga shifokorga uchrashuvim bor)\n- Koennen wir einen Termin vereinbaren? (Uchrashuv belgilasak bo'ladimi?)\n\nTez-tez ishlatiladigan birikmalar:\neinen Termin machen/vereinbaren — uchrashuv belgilash\neinen Termin absagen — bekor qilish\neinen Termin verschieben — ko'chirish"),
    ("'Bescheid sagen' nima degani?",
     "Bescheid sagen — xabar bermoq, bildirmoq\n\nIshlatilishi:\n- Sag mir bitte Bescheid, wenn du kommst. (Kelganingda menga xabar ber)\n- Ich sage Ihnen morgen Bescheid. (Ertaga sizga xabar beraman)\n\nO'xshash iboralar:\nmitteilen — rasmiy xabar berish\ninformieren — axborot berish\nbenachrichtigen — xabardor qilish"),
    ("Unterschied: 'kennen' va 'wissen'",
     "Ikkalasi ham 'bilmoq' lekin farqi bor:\n\nKENNEN — tanish bo'lmoq (odamlar, joylar, narsalar)\n- Ich kenne diesen Mann. (Men bu odamni taniyaman)\n- Kennst du Berlin? (Berlinni bilasanmi/bo'lganmisan?)\n\nWISSEN — ma'lumotni bilmoq (fakt, javob)\n- Ich weiss, dass er kommt. (Men bilaman u kelishini)\n- Weisst du, wie spaet es ist? (Soat nechani bilasanmi?)\n\nQoida: KENNEN + Akkusativ ot, WISSEN + ergash gap (dass, wo, wie...)"),
]

for user_msg, assistant_msg in VOCAB_EXAMPLES:
    add(SYSTEM_TRANSLATE, user_msg, assistant_msg)


# ═══════════════════════════════════════════════════════════════════════════════
# YOZISH
# ═══════════════════════════════════════════════════════════════════════════════

random.shuffle(samples)

with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    for sample in samples:
        f.write(json.dumps(sample, ensure_ascii=False) + "\n")

print(f"Tayyor! {len(samples)} ta training misol yozildi: {OUTPUT_FILE}")
