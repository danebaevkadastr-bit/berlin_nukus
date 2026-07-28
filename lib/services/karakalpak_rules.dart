// Qoraqalpoq tili uchun barcha qoidalar, grammatika, lug'at va slang.
//
// Bu fayl faqat KAA (Karakalpak) tili tanlanganda promptga qo'shiladigan
// ma'lumotlarni saqlaydi. Asosiy prompt mantiqi (shaxsiyat, triggerlar,
// xato qoidalari) gemini_live_prompt.dart da qoladi.
//
// Yangi so'z yoki grammatika qo'shmoqchi bo'lsangiz — faqat shu faylni
// tahrirlang, asosiy promptga tegmang.

/// Qoraqalpoqcha slang so'zlar (sarkazm va hazil uchun).
/// Asosiy promptdagi $slangExamples o'rniga ishlatiladi.
const String kaaSlangExamples =
    '"Ajaǵa", "Bawırım", "zor", "qáte qıldıń/uyatqa qaldıń-ǵoy!"';

/// O'zbekcha/Qozoqchadan Qoraqalpoqchaga tarjima JSON xaritasi.
/// Model shu so'zlarni ko'rsa, darhol qoraqalpoqcha ekvivalentiga almashtiradi.
const String kaaForbiddenWordsJson =
    // --- Bog'lovchilar va yuklamalar (Konjunktionen & Partikeln) ---
    '{"ha":"awa", "yo\'q":"yaq/joq", "lekin":"biraq", "chunki":"óytkeni", '
    '"va":"hám", "ham":"da/de", "yoki":"yamasa/yáki", "bilan":"benen", '
    '"uchun":"ushın", "shuning uchun":"sonıń ushın", "agar":"eger", '
    '"ammo":"biraq", "faqat":"tek/ǵana", '
    // --- Olmoshlar va umumiy so'zlar (Pronomen & allgemein) ---
    '"nima":"ne", "nega":"nege", "qachon":"qashan", "qayerda":"qayerde", '
    '"qanday qilib":"qalayınsha", "shunday":"usınday/tap sonday", '
    '"menimcha":"menińshe", "hamma":"hámme", "hech kim":"hesh kim", '
    '"hech narsa":"hesh nárse", "hech qachon":"hesh qashan", '
    // --- Vaqt so'zlari (Zeitwörter) ---
    '"hozir":"házir", "bugun":"búgin", "ertaga":"erteń", "kecha":"keshe", '
    '"ertalab":"azanda", "kechqurun":"keshqurın", "kunduzi":"kúndiz", '
    '"har doim":"hár qashan/hár dayım", "ba\'zan":"geyde", '
    '"yil":"jıl", "oy":"ay", "hafta":"hápte", "kun":"kún", '
    '"soat":"saat", "vaqt":"waqıt", "daqiqa":"minut", "soniya":"sekund", '
    '"yarim":"yarım", "oldin":"aldın/burın", "keyin":"keyin/soń", '
    // --- Sifatlar (Adjektive) ---
    '"to\'g\'ri":"durıs", "xato":"qáte", "noto\'g\'ri":"nadurıs", '
    '"yaxshi":"jaqsı", "yomon":"jaman", "qiyin":"qıyın", "oson":"ańsat", '
    '"katta":"úlken", "kichkina":"kishi/kishkene", "yangi":"jańa", '
    '"chiroyli":"shıraylı/ádemi", "xunuk":"kórimsiz", '
    '"issiq":"issı", "sovuq":"suwıq", "uzoq":"uzaq", "yaqin":"jaqın", '
    '"qimmat":"qımbat", "arzon":"arzan", "toza":"taza", "iflos":"kir/patas", '
    '"boy":"bay", "kambag\'al":"jarli", "ko\'p":"kóp", "kam":"kem", '
    '"sekin":"aqırın/áste", "jiddiy":"saldamlı", "dangasa":"erinshek", '
    '"aqlli":"aqıllı", "ahmoq":"aqılsız/tentek", '
    '"xursand":"quwanıshlı", "xafa":"qapa", "g\'azablangan":"ashıwlı", '
    '"qattiqqo\'l":"qatal", "kuchli":"kúshli", "kuchsiz":"hálsiz/kúshsiz", '
    '"kasal":"kesel", "sog\'lom":"saw-salamat", "zerikarli":"zerigerli", '
    '"ajoyib":"ájayıp", "dahshatli":"qorqınıshlı", "g\'alati":"qızıq/túrli", '
    '"to\'liq":"tolıq", "bo\'sh":"bos", "quruq":"qurǵaq", "ho\'l":"ızǵar/hól", '
    '"muhim":"áhmiyetli", "qiziqarli":"qızıqlı", '
    // --- Fe'llar (Verben) ---
    '"gapir":"sóyle", "gapirmoq":"sóylew", "qaytar":"tákirarla", '
    '"qaytarish":"tákirarlaw", "qil":"isle", "qilmoq":"istew", '
    '"o\'qi":"oqı", "yoz":"jaz", "bormoq":"barıw", "kelmoq":"keliw", '
    '"yemoq":"jew", "ichmoq":"ishiw", "bermoq":"beriw", "olmoq":"alıw", '
    '"boshlamoq":"baslaw", "tugatmoq":"tawsıw/juwmaqlaw", '
    '"o\'tirmoq":"otırıw", "turmoq":"turıw", "kulmoq":"kúliw", '
    '"yig\'lamoq":"jılaw", "o\'ylamoq":"oylaw", "bilmoq":"biliw", '
    '"xohlamoq":"qálew", "yaxshi ko\'rmoq":"jaqsı kóriw", '
    '"kutmoq":"kútiw", "qidirmoq":"izlew", "topmoq":"tabıw", '
    '"eshitmoq":"esitiw", "ko\'rmoq":"kóriw", '
    '"uxlamoq":"uyıqlaw", "uyg\'onmoq":"oyanıw", "yugurmoq":"juwırıw", '
    '"yurmoq":"júriw", "sotib olmoq":"satıp alıw", "sotmoq":"satıw", '
    '"to\'lamoq":"tólew", "ko\'rsatmoq":"kórsetiw", "yashirmoq":"jasırıw", '
    '"o\'rganmoq":"úyreniw", "o\'rgatmoq":"úyretiw", '
    '"tayyorlanmoq":"tayarlanıw", "yodlamoq":"yadlaw", '
    '"unutmoq":"umıtıw", "eslamoq":"eslew", "tushmoq":"túsiw", '
    '"chiqmoq":"shıǵıw", "ochmoq":"ashıw", "yopmoq":"jabıw", '
    '"tushundim":"túsindim", "tushundingmi":"túsindińbe", '
    '"tushuntirish":"túsindiriw", '
    '"qo\'shiq aytmoq":"qosıq aytıw", "raqsga tushmoq":"oyınǵa túsiw", '
    // --- Oila va odamlar (Familie & Menschen) ---
    '"oila":"shańaraq", "ota":"áke", "ona":"ana", "bola":"bala", '
    '"qiz":"qız", "aka":"ajaǵa", "uka":"ini", "opa":"apa", '
    '"singil":"qarındas", "do\'st":"dos", "odam":"adam", '
    '"o\'quvchi":"oqıwshı", "o\'qituvchi":"muǵallim", '
    '"brat":"ajaǵa", "jigar":"bawırım", '
    // --- Tana a'zolari (Körperteile) ---
    '"ko\'z":"kóz", "qo\'l":"qol", "bosh":"bas", "quloq":"qulaq", '
    '"burun":"murın", "og\'iz":"awız", "tish":"tis", "yurak":"júrek", '
    '"qon":"qan", "soch":"shash", "ovoz":"dawıs", '
    // --- Kundalik so'zlar (Alltag) ---
    '"uy":"úy", "suv":"suw", "non":"nan", "ish":"jumıs", '
    '"hayot":"ómir", "dunyo":"dúnya", "yo\'l":"jol", '
    '"yordam":"járdem", "dars":"sabaq", "maqsad":"maqset", '
    '"kerak":"kerek", "mumkin":"múmkin", "e\'tibor":"itibar", '
    '"tajriba":"tájiriybe", "harakat":"háreket", '
    '"o\'zgartirish":"ózgertiw", "qayta":"qaytadan", '
    // --- Joy va xizmatlar (Orte & Dienste) ---
    '"do\'kon":"dúkan", "bozor":"bazar", "shahar":"qala", '
    '"qishloq":"awıl", "ko\'cha":"kóshe", "kvartira":"pátir", '
    '"chegara":"shegara", "kasalxona":"emxana", '
    '"shifokor":"shıpaker", "dori":"dári", '
    // --- Oziq-ovqat (Essen) ---
    '"ovqat":"awqat", "ichimlik":"ishimlik", "go\'sht":"gósh", '
    '"meva":"miywe", "sabzavot":"palız eginleri/kóktaw", '
    // --- Ta'lim va madaniyat (Bildung & Kultur) ---
    '"misol":"misal", "savol":"soraw", "javob":"juwap", '
    '"qoida":"qaǵıyda", "so\'z":"sóz", "gap":"gáp", "talaffuz":"aytılıwı", '
    '"imtihon":"imtihan", "muammo":"mashqala", "yechim":"sheshim", '
    '"lug\'at":"sózlik", "tarjima":"awdarma", "matn":"tekst", '
    '"hikoya":"gúrriń", "ertak":"ertek", "qog\'oz":"qaǵaz", '
    '"qalam":"qálem", "rasm":"súwret", '
    '"chipta":"bilet", "narx":"baha", "masalan":"máselen/mısalı", '
    // --- Tabiat (Natur) ---
    '"quyosh":"quyash", "yulduz":"juldız", "osmon":"aspan", '
    '"yer":"jer", "tog\'":"taw", "yomg\'ir":"jawın", "qor":"qar", '
    '"shamol":"samal", '
    // --- Yo'nalish (Richtung) ---
    '"o\'ng":"oń", "chap":"shep", "tepa":"tóbe/joqarı", '
    '"past":"pást/tómen", "o\'rtasida":"ortasında", '
    // --- Vaqt tushunchalari (Zeitbegriffe) ---
    '"o\'tgan":"ótken", "kelajak":"keleshek", "asr":"ásir", '
    // --- Umumiy (Allgemein) ---
    '"juda":"júdá/dım", "ko\'proq":"kóbirek", "rahmat":"raxmet", '
    '"iltimos":"iltimas", "umuman":"ulıwma"}';

/// Nemischa → Qoraqalpoqcha lug'at (Deutsch -> Karakalpakisch Sözlik).
/// Model nemischa so'zni qoraqalpoqchaga tarjima qilganda shu ro'yxatga amal qiladi.
const String kaaDeutschSozlik =
    '"Fehler" -> qáte, "Richtig" -> durıs, "Falsch" -> nadurıs / qáte, '
    '"Beispiel" -> misal, "Erklärung" -> túsindiriw, "Satz" -> gáp, '
    '"Wort" -> sóz, "Übung" -> shınıǵıw, "Wiederholen" -> tákirarlaw, '
    '"Lernen" -> úyreniw, "Ja/Einverstanden" -> Awa / Awa boladı, '
    '"Regel" -> qaǵıyda, "Grammatik" -> grammatika, '
    '"Substantiv/Nomen" -> atlıq, "Verb" -> feyil, "Adjektiv" -> kelbetlik, '
    '"Suffix" -> qosımta, "Wurzel" -> túbir, "Plural" -> kóplik, '
    '"Singular" -> birlik, "Kasus" -> seplik, "Person" -> bet, '
    '"Frage" -> soraw, "Antwort" -> juwap, "Text" -> tekst / matn, '
    '"Thema" -> tema, "Aussprache" -> talaffuz / aytılıw, '
    '"Bedeutung" -> máni, "Silbe" -> buwın, "Buchstabe" -> hárip, '
    '"Laut" -> ses, "Stimme" -> dawıs, "Vokal" -> dawıslı ses, '
    '"Konsonant" -> dawıssız ses, "gut" -> jaqsı, "schlecht" -> jaman, '
    '"leicht" -> ańsat / jeńil, "schwer" -> qıyın / awır, '
    '"schnell" -> tez, "langsam" -> aqırın / báseń, '
    '"heute" -> búgin, "morgen" -> erteń, "gestern" -> keshe, '
    '"jetzt" -> házir / endi, "verstehen" -> túsiniw, '
    '"sprechen" -> sóylew / gáplesiw, "lesen" -> oqıw, '
    '"schreiben" -> jazıw, "hören" -> tıńlaw, "Freund" -> dos, '
    '"Lehrer" -> muǵallim / ustaz, "Schüler" -> oqıwshı, '
    '"Schule" -> mektep, "Buch" -> kitap, "Heft" -> dápter, '
    '"Prüfung" -> imtihan, "Aufgabe" -> tapsırma, '
    '"nochmal" -> qaytadan / tağı bir ret.';

/// Qoraqalpoq tili grammatikasi (5-6 sinf darajasida).
/// Vokal garmoniyasi, sepliklar, fe'l zamonlari, so'z yasash va boshqalar.
const String kaaGrammatikRegeln = '''
  **3. DAWISLILARDIŃHARMONIYASI (Vokalharmonie — SEHR WICHTIG):**
  Karakalpakisch hat harte (juwan) Vokale: **a, o, u, ı** und weiche (jińishke) Vokale: **á, ó, ú, i, e**.
  Suffixe müssen zum Vokal des Wortstamms passen! Harter Stamm -> hartes Suffix, weicher Stamm -> weiches Suffix.
  Beispiele: dalada (in der Steppe), paxtanı (die Baumwolle-Akk), kitaplar (Bücher) — harter Stamm.
  súwretshi (Maler), dápterler (Hefte), keldim (ich kam) — weicher Stamm.
  Sage NIEMALS "dápterlar" (falsch!), sondern immer "dápterler" (richtig!).

  **4. ATLIQTIŃKÓPLIK SANI (Pluralbildung):**
  Plural: **-lar** (nach harten Vokalen), **-ler** (nach weichen Vokalen).
  Frage: **kimler? neler?** Beispiele: balalar (Kinder), gúller (Blumen), oqıwshılar (Schüler), dápterler (Hefte).

  **5. SEPLIKLER (Kasussystem — 6 Fälle):**
  Karakalpakisch hat 6 Kasus. Verwende IMMER die richtigen Endungen:
  Ataw seplik (Nominativ): keine Endung. Iyelik seplik (Genitiv): -nıń/-niń, -dıń/-diń, -tıń/-tiń. Barıs seplik (Dativ): -qa/-ke, -ǵa/-ge. Tabıs seplik (Akkusativ): -nı/-ni, -dı/-di, -tı/-ti. Shıǵıs seplik (Ablativ): -nan/-nen, -dan/-den, -tan/-ten. Orın seplik (Lokativ): -da/-de, -ta/-te, -nda/-nde.

  **6. TARTIM JALǴAWLARI (Possessivsuffixe):**
  I bet: -m, -ım/-im (birlik), -mız/-miz (kóplik). II bet: -ń, -ıń/-iń (birlik), -ńız/-ńiz (kóplik). III bet: -ı/-i, -sı/-si (birlik), -ları/-leri (kóplik).

  **7. FEYIL — MÁHÁLLAR (Verb-Tempussystem):**
  Házirgi davomli máhál: -ıp/-ip atır + Personalendung. Házirgi máhál: -adı/-edi, -ydı/-ydi. Ótken máhál: -dı/-di, -tı/-ti. Keler máhál: -adı/-edi mit Kontext.

  **8. FEYILDIŃ BOLIMSIZ TÚRI (Verneinung):**
  Verneinungssuffixe: -ma/-me, -ba/-be, -pa/-pe. Vokalharmonie beachten!

  **9. FEYIL MEYILLERI (Verbmodi):**
  Buyrıq meyil (Imperativ): oqı! jazıń! Shárt meyil (Konditional): -sa/-se. Tilek meyil (Optativ): -ayın/-eyin.

  **10. KELBETLIK DÁREJELERI (Adjektiv-Steigerung):**
  Jay dáreje (Positiv), Arttırıw dáreje (Elativ: sup-sulıw, qıp-qızıl), Salıstırıw dáreje (Komparativ: -raq/-rek).

  **11. GÁP QURILISI (Satzbau):**
  Grundwortstellung: SOV (Subjekt-Objekt-Verb). Men kitaptı oqıdım (Ich las das Buch).

  **12. ǴOY YUKLAMASI (Partikel ǵoy):**
  Benutze ǵoy für Betonung und Erstaunen: "Bul durıs emes-ǵoy!" (Das ist doch falsch!).

  **13. ALMASIQLAR (Pronomen):**
  Betlik: men, sen, ol, biz, siz, olar. Tartım: meniki, seniki, onıki. Siltew: bul, sol, usı. Soraw: kim, ne, qanday.

  **14. SANLIQLAR (Zahlwörter):**
  Kardinal: bir, eki, úsh, tórt, bes, altı, jeti, segiz, toǵız, on. Ordinal: -ınshı/-inshi. Kollektiv: -aw/-ew.

  **15. RÁWISHLER (Adverbien):**
  Waqıt: búgin, erteń, keshe, házir. Orın: joqarıda, tómende. Sın: tez, áste. Muǵdar: kóp, az, júdá, dım.

  **16. KÓMEKSHI SÓZLER (Hilfswörter - Postpositionen, Konjunktionen, Partikeln):**
  - **Tirkewish (Postpositionen):** ushın (für), deyin / sheyin / shekem (bis), menen / benen / penen (mit), haqqında / tuwralı / jóninde (über), keyin / soń (nach), burın / aldın (vor), qaray / qarap (in Richtung), qaramastan / qaramay (trotz). Merke: Sie stehen IMMER nach dem Nomen.
  - **Dáneker (Konjunktionen):** hám / jáne (und), biraq / lekin / al (aber), sebebi / óytkeni (weil), sonlıqtan / sol sebepli / sonıń ushın (deshalb), eger / eger de (wenn), ya / yaki / yamasa (oder).
  - **Janapay (Partikeln):** 
    1) Soraw (Frage): ma/me, ba/be, pa/pe, she (bei 2. Person: mı/mi, bı/bi, pı/pi - z.B. adambısań).
    2) Ayırıw-sheklew (Einschränkend): tek, ǵana, tek ǵana, bolsa, gileń.
    3) Kúsheytiw (Verstärkend): da/de, tap, ǵoy, -aq (mit Bindestrich: sen-aq), hám.
    4) Modal: aw, ay, shı/shi (Aufforderung), ós, sesh, mıs/mis/mısh/mish (Sarkasmus/Hörensagen).

  **17. MODAL SÓZLER (Modalwörter):**
  Sie drücken die Einstellung des Sprechers aus und werden oft durch Kommata getrennt (wie Einschübe).
  - **Sicherheit/Überzeugung:** álbette (natürlich), sózsiz (zweifellos), shınında (wirklich).
  - **Vermutung:** bálkim / múmkin (vielleicht), shaması (anscheinend).
  - **Zustimmung/Ablehnung:** awa (ja), joq / yaq (nein), maqul / jaqsı (einverstanden).
  - **Emotionen:** tilekke qarsı (leider), baxtımızǵa (zum Glück).
  - **Schlussfolgerung/Ordnung:** demek (also), qısqası (kurz gesagt), máselen / mısalı (zum Beispiel), menińshe (meiner Meinung nach).

  **18. TAŃLAQ (Ausrufewörter / Interjektionen):**
  Drücken starke Emotionen, Befehle oder Höflichkeitsfloskeln aus. Meist durch Komma getrennt.
  - **Emotional:** bárekella / yasha (bravo!), átteń / yapırmay / way / astapıralla (oh nein / schade / erstaunt), pa / pay / pah / túw (Ausrufe des Erstaunens).
  - **Befehl / Anrede:** hey, qaraǵım / shıraǵım (meine Liebe/r), posh / tss (psst/weg da).
  - **Höflichkeit / Alltag:** assalawma áleykum (Hallo), xosh / saw bol (Tschüss), raxmet (Danke), ápiw etiń (Entschuldigung), márhámat (Bitte sehr), qutlıqlayman (Ich gratuliere).

  **19. ELIKLEWISH SÓZLER (Laut- und Bildmalerei / Onomatopoetika):**
  Ahmen Geräusche oder visuelle Bewegungen nach. Oft gepaart oder verdoppelt (mit Bindestrich) und meist mit dem Hilfsverb "et-" verbunden (z.B. jılt-jılt etedi, gúmp etti).
  - **Seske eliklewish (Geräusche):** tars, tısır, gúmp, gúrs, shaq-shuq, gúldir-gúldir, taq-tuq, shıńǵır-shıńǵır.
  - **Kóriniske eliklewish (Visuell/Bewegung):** jalt, jılt, zımp, jarq, jalt-jult, selteń-selteń, zır-zır, dir-dir.

  **20. SINTAKSIS (Satzlehre & Satzglieder):**
  - **Bas aǵzalar (Hauptsatzglieder):** Baslawısh (Subjekt) und Bayanlawısh (Prädikat) bilden das Fundament.
  - **Ekinshi dárejeli aǵzalar (Nebensatzglieder):** Anıqlawısh (Attribut), Tolıqlawısh (Objekt), Pısıqlawısh (Adverbiale Bestimmung).
  - **Satzarten:** 
    - Jay gáp (Einfacher Satz) vs. Qospa gáp (Zusammengesetzter Satz).
    - Keńeytilmegen gáp (Unerweiterter Satz - nur Subjekt & Prädikat).
    - Keńeytilgen gáp (Erweiterter Satz - mit Attributen, Objekten etc.).''';

/// Qoraqalpoqcha gaplashish misollari (Sprachbeispiele für KAA).
const String kaaSpeakingExamples = '''
**DURIS MISALLAR (qaraqalpaqsha):**

Misal 1 (Qáteni tuzatıw):
User: "Ich habe gegangen nach Berlin."
AI: "Toqta! 'Ich habe gegangen'?! Bul qáte-ǵoy! Háreket feyilleri 'sein' menen isletiledi, 'haben' menen emes! Durısı: 'Ich bin gegangen'. Bunı 1-klass balası da biledi ǵoy!"

Misal 2 (Grammatika túsindiriw):
User: "in der Stadt penen in die Stadt — qaysı durıs?"
AI: "'Wo?' — 'in der Stadt' (Dativ). 'Wohin?' — 'in die Stadt' (Akkusativ). Bul bazalıq grammatika, Ajaǵa!"

Misal 3 (Ádettegi sáwbet):
User: "Búgin ne shınıǵamız?"
AI: "Búgin Telc imtihanınıń 2-bólimin shınıǵamız — birgelikte rejeleshtiriw. Mısalı, tuwılǵan kúndi shólkemlestireyik. Tayınbasan?"

**NADURIS (búlay ISLEME!):**
❌ "Búgin biz üben Teil 2..." (eki tildi aralastırma!)
❌ "Du musst aytıw kerek..." (eki tildi aralastırma!)
✅ "Búgin 2-bólimdi shınıǵamız..." (taza qaraqalpaqsha + nemischa termin OK)
''';

/// Barcha qoraqalpoqcha qoidalarni bitta prompt blokiga yig'ib beradi.
/// [gemini_live_prompt.dart] da `$karakalpakBlock` sifatida ishlatiladi.
String buildKarakalpakBlock() {
  return '''
- **KARAKALPAKISCHE VOKABELN UND GRAMMATIK (WICHTIG)**: Wenn du Karakalpakisch sprichst, beachte ALLE folgenden Regeln STRIKT:

  **1. VERBOTENE WÖRTER (USBEKISCH/KASACHISCH VERMEIDEN!):**
  Wenn du auf Karakalpakisch sprichst, ersetze diese Wörter IMMER strikt gemäß dieser JSON-Map (Usbekisch -> Karakalpakisch):
  $kaaForbiddenWordsJson

  **2. DEUTSCH -> KARAKALPAKISCH SÓZLIK (Wortwahl / Vokabular):**
  $kaaDeutschSozlik

$kaaGrammatikRegeln
''';
}
