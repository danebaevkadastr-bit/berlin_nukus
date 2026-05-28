import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'conversation_topics_l10n.dart';
import 'locale_manager.dart';

class AppLocalizations {
  final String _code;

  AppLocalizations(this._code);

  static AppLocalizations of(BuildContext context) {
    try {
      final locale = Provider.of<ValueNotifier<AppLocale>>(context).value;
      return AppLocalizations(locale.code);
    } catch (_) {
      final locale = Provider.of<ValueNotifier<AppLocale>>(context, listen: false).value;
      return AppLocalizations(locale.code);
    }
  }

  String _t(Map<String, String> map) =>
      map[_code] ?? map['uz'] ?? map.values.first;

  // ── Navigation ─────────────────────────────────────────────────────────────
  String get navHome => _t({'uz': "Bosh", 'kaa': "Bas", 'ru': "Главная", 'de': "Start"});
  String get navGroup => _t({'uz': "Guruh", 'kaa': "Topar", 'ru': "Группа", 'de': "Gruppe"});
  String get navLearning => _t({'uz': "O'rganish", 'kaa': "Úyreniw", 'ru': "Учёба", 'de': "Lernen"});
  String get navGames => _t({'uz': "O'yinlar", 'kaa': "Oyınlar", 'ru': "Игры", 'de': "Spiele"});
  String get navProfile => _t({'uz': "Profil", 'kaa': "Profil", 'ru': "Профиль", 'de': "Profil"});
  String get navPayment => _t({'uz': "To'lov", 'kaa': "Tólew", 'ru': "Оплата", 'de': "Zahlung"});

  // ── Login ──────────────────────────────────────────────────────────────────
  String get loginSubtitle => _t({
    'uz': "Nemis tilini o'rganishni boshlang!",
    'kaa': "Nemis tilin úyreniwdi baslań!",
    'ru': "Начните изучать немецкий!",
    'de': "Fangen Sie an, Deutsch zu lernen!",
  });
  String get email => _t({'uz': "Email", 'kaa': "Email", 'ru': "Почта", 'de': "E-Mail"});
  String get password => _t({'uz': "Parol", 'kaa': "Parol", 'ru': "Пароль", 'de': "Passwort"});
  String get login => _t({'uz': "Kirish", 'kaa': "Kiriw", 'ru': "Войти", 'de': "Anmelden"});
  String get or => _t({'uz': "yoki", 'kaa': "yamasa", 'ru': "или", 'de': "oder"});
  String get signInWithGoogle => _t({
    'uz': "Google orqali kirish",
    'kaa': "Google arqalı kiriw",
    'ru': "Войти через Google",
    'de': "Mit Google anmelden",
  });
  String get register => _t({
    'uz': "Ro'yxatdan o'tish",
    'kaa': "Dizimnen ótiw",
    'ru': "Регистрация",
    'de': "Registrieren",
  });
  String get fillAllFields => _t({
    'uz': "Iltimos, barcha maydonlarni to'ldiring!",
    'kaa': "Iltimas, hámme orınlardı toltırıń!",
    'ru': "Пожалуйста, заполните все поля!",
    'de': "Bitte füllen Sie alle Felder aus!",
  });
  String get wrongCredentials => _t({
    'uz': "Email yoki parol noto'g'ri!",
    'kaa': "Email yamasa parol nadurıs!",
    'ru': "Неверный email или пароль!",
    'de': "Falsche E-Mail oder Passwort!",
  });

  String get forgotPassword => _t({
    'uz': "Parolni unutdingizmi?",
    'kaa': "Paroldi umıttıńızba?",
    'ru': "Забыли пароль?",
    'de': "Passwort vergessen?",
  });
  String get forgotPasswordSubtitle => _t({
    'uz': "Emailingizni kiriting va biz sizga tiklash havolasini yuboramiz!",
    'kaa': "Emailıńızdı kiritiń hám biz sizge qayta tiklew siltemesin jiberemiz!",
    'ru': "Введите email, и мы отправим вам ссылку для восстановления!",
    'de': "Geben Sie Ihre E-Mail ein, und wir senden Ihnen einen Link zur Wiederherstellung!",
  });
  String get sendResetLink => _t({
    'uz': "Tiklash havolasini yuborish",
    'kaa': "Tiklew siltemesin jiberiw",
    'ru': "Отправить ссылку",
    'de': "Link senden",
  });
  String get resetLinkSent => _t({
    'uz': "Tiklash havolasi emailingizga yuborildi! 📧",
    'kaa': "Tiklew siltemesi emailıńızǵa jiberildi! 📧",
    'ru': "Ссылка отправлена на ваш email! 📧",
    'de': "Link an Ihre E-Mail gesendet! 📧",
  });
  String get enterValidEmail => _t({
    'uz': "Iltimos, to'g'ri email kiriting!",
    'kaa': "Iltimas, durıs email kiritiń!",
    'ru': "Пожалуйста, введите корректный email!",
    'de': "Bitte geben Sie eine gültige E-Mail-Adresse ein!",
  });

  // ── Settings ───────────────────────────────────────────────────────────────
  String get settingsTitle => _t({
    'uz': "Sozlamalar",
    'kaa': "Sazlawlar",
    'ru': "Настройки",
    'de': "Einstellungen",
  });
  String get profileInfo => _t({
    'uz': "Profil ma'lumotlari",
    'kaa': "Profil maǵlıwmatları",
    'ru': "Данные профиля",
    'de': "Profilinformationen",
  });
  String get appLanguage => _t({
    'uz': "Dastur tili",
    'kaa': "Dástúr tili",
    'ru': "Язык приложения",
    'de': "App-Sprache",
  });
  String get currentLanguage => _t({
    'uz': "Hozirgi til",
    'kaa': "Házirgi til",
    'ru': "Текущий язык",
    'de': "Aktuelle Sprache",
  });
  String get darkMode => _t({
    'uz': "Qorong'u rejim",
    'kaa': "Qaranǵı rejim",
    'ru': "Тёмный режим",
    'de': "Dunkelmodus",
  });
  String get lightMode => _t({
    'uz': "Yorug' rejim",
    'kaa': "Jarıq rejim",
    'ru': "Светлый режим",
    'de': "Heller Modus",
  });
  String get changeTheme => _t({
    'uz': "Ilova mavzusini o'zgartirish",
    'kaa': "Dástúr temasın ózgertiriw",
    'ru': "Изменить тему",
    'de': "Thema ändern",
  });
  String get vibration => _t({
    'uz': "Tebranishlar",
    'kaa': "Tebreniwler",
    'ru': "Вибрация",
    'de': "Vibration",
  });
  String get vibrationDesc => _t({
    'uz': "Bildirishnomalar va bosishlarda tebranish",
    'kaa': "Xabarlamalar hám basıwlarda tebreniw",
    'ru': "Вибрация при уведомлениях",
    'de': "Vibration bei Benachrichtigungen",
  });
  String get about => _t({
    'uz': "Ilova haqida",
    'kaa': "Dástúr haqqında",
    'ru': "О приложении",
    'de': "Über die App",
  });
  String get versionInfo => _t({
    'uz': "Versiya 1.0.0 • Berlin-Nukus",
    'kaa': "Versiya 1.0.0 • Berlin-Nukus",
    'ru': "Версия 1.0.0 • Berlin-Nukus",
    'de': "Version 1.0.0 • Berlin-Nukus",
  });
  String get darkModeOn => _t({
    'uz': "Dark mode yoqildi",
    'kaa': "Qaranǵı rejim qosıldı",
    'ru': "Тёмный режим включён",
    'de': "Dunkelmodus aktiviert",
  });
  String get lightModeOn => _t({
    'uz': "Light mode yoqildi",
    'kaa': "Jaqtı rejim qosıldı",
    'ru': "Светлый режим включён",
    'de': "Hellmodus aktiviert",
  });
  String get editProfileComingSoon => _t({
    'uz': "Profil tahrirlash tez orada qo'shiladi",
    'kaa': "Profildi ózgertiriw tez qosıladı",
    'ru': "Редактирование профиля скоро появится",
    'de': "Bearbeitung kommt bald",
  });
  String get close => _t({'uz': "Yopish", 'kaa': "Jabıw", 'ru': "Закрыть", 'de': "Schließen"});
  String get lastUpdate => _t({
    'uz': "So'ngi yangilanish: 2026",
    'kaa': "Aqırǵı jańalanıw: 2026",
    'ru': "Последнее обновление: 2026",
    'de': "Letztes Update: 2026",
  });
  String get developer => _t({
    'uz': "Dasturchi: Berlin-Nukus Team",
    'kaa': "Programmer: Berlin-Nukus Team",
    'ru': "Разработчик: Berlin-Nukus Team",
    'de': "Entwickler: Berlin-Nukus Team",
  });

  // ── Home (Student) ─────────────────────────────────────────────────────────
  String get hello => _t({'uz': "Salom", 'kaa': "Sálem", 'ru': "Привет", 'de': "Hallo"});
  String get todayLessons => _t({
    'uz': "Bugungi darslar",
    'kaa': "Búgingi sabaqlar",
    'ru': "Сегодняшние уроки",
    'de': "Heutige Stunden",
  });
  String get myProgress => _t({
    'uz': "Mening taraqqiyotim",
    'kaa': "Menin rawajlanıwım",
    'ru': "Мой прогресс",
    'de': "Mein Fortschritt",
  });
  String get words => _t({'uz': "So'zlar", 'kaa': "Sózler", 'ru': "Слова", 'de': "Wörter"});
  String get tests => _t({'uz': "Testlar", 'kaa': "Testler", 'ru': "Тесты", 'de': "Tests"});
  String get lessons => _t({'uz': "Darslar", 'kaa': "Sabaqlar", 'ru': "Уроки", 'de': "Stunden"});
  String get viewAll => _t({
    'uz': "Barchasini ko'rish",
    'kaa': "Bárlıǵın kóriw",
    'ru': "Посмотреть все",
    'de': "Alle ansehen",
  });
  String get continueLesson => _t({
    'uz': "Davom etish",
    'kaa': "Dawam etiw",
    'ru': "Продолжить",
    'de': "Weiter",
  });
  String get noLessons => _t({
    'uz': "Bugun dars yo'q",
    'kaa': "Búgin sabaq joq",
    'ru': "Сегодня уроков нет",
    'de': "Heute keine Stunden",
  });
  String get dailyTask => _t({
    'uz': "Kunlik topshiriq",
    'kaa': "Kúnlik tapsırma",
    'ru': "Ежедневное задание",
    'de': "Tägliche Aufgabe",
  });
  String get streak => _t({
    'uz': "kunlik seria",
    'kaa': "kúnlik seria",
    'ru': "дней подряд",
    'de': "Tage am Stück",
  });
  String get quickActions => _t({
    'uz': "Tezkor harakatlar",
    'kaa': "Tez hareketler",
    'ru': "Быстрые действия",
    'de': "Schnellaktionen",
  });
  String get readyToLearn => _t({
    'uz': "O'rganishga tayyormisan?",
    'kaa': "Úyreniwge tayyarmısań?",
    'ru': "Готов к учебе?",
    'de': "Bereit zum Lernen?",
  });
  String get todayLesson => _t({
    'uz': "Bugungi dars",
    'kaa': "Búgingi sabaq",
    'ru': "Сегодняшний урок",
    'de': "Heutige Stunde",
  });
  String get translation => _t({
    'uz': "Tarjima",
    'kaa': "Awdarma",
    'ru': "Перевод",
    'de': "Übersetzung",
  });
  String get chat => _t({
    'uz': "Chat",
    'kaa': "Chat",
    'ru': "Чат",
    'de': "Chat",
  });
  String get chatComingSoon => _t({
    'uz': "Chat bo'limi tez orada ishga tushadi!",
    'kaa': "Chat bólimi jaqında iske túsedi!",
    'ru': "Раздел чата скоро заработает!",
    'de': "Der Chat-Bereich wird bald verfügbar sein!",
  });
  String get leaderboard => _t({
    'uz': "Peshqadamlar",
    'kaa': "Jetekshiler",
    'ru': "Лидеры",
    'de': "Bestenliste",
  });
  String get activity => _t({
    'uz': "Faollik",
    'kaa': "Iskerlik",
    'ru': "Активность",
    'de': "Aktivität",
  });
  String get fiveDayStreak => _t({
    'uz': "5 kunlik seriya!",
    'kaa': "5 kúnlik seriya!",
    'ru': "Серия из 5 дней!",
    'de': "5-Tage-Strähne!",
  });
  String get twoDaysLeft => _t({
    'uz': "Yana 2 kun",
    'kaa': "Jáne 2 kún",
    'ru': "Еще 2 дня",
    'de': "Noch 2 Tage",
  });
  String get pendingHomeworks => _t({
    'uz': "2 ta vazifa bajarilmagan",
    'kaa': "2 tapsırma tapsırılmaǵan",
    'ru': "2 задания не выполнены",
    'de': "2 Hausaufgaben ausstehend",
  });
  String get twoHomeworks => _t({
    'uz': "2 ta",
    'kaa': "2 dana",
    'ru': "2 шт.",
    'de': "2 Stk.",
  });
  String get monShort => _t({'uz': "D", 'kaa': "D", 'ru': "Пн", 'de': "Mo"});
  String get tueShort => _t({'uz': "S", 'kaa': "S", 'ru': "Вт", 'de': "Di"});
  String get wedShort => _t({'uz': "Ch", 'kaa': "Ch", 'ru': "Ср", 'de': "Mi"});
  String get thuShort => _t({'uz': "P", 'kaa': "P", 'ru': "Чт", 'de': "Do"});
  String get friShort => _t({'uz': "J", 'kaa': "J", 'ru': "Пт", 'de': "Fr"});
  String get satShort => _t({'uz': "Sh", 'kaa': "Sh", 'ru': "Сб", 'de': "Sa"});
  String get sunShort => _t({'uz': "Yak", 'kaa': "Yak", 'ru': "Вс", 'de': "So"});

  // ── Profile ────────────────────────────────────────────────────────────────
  String get editProfile => _t({
    'uz': "Profilni tahrirlash",
    'kaa': "Profildi ózgertiriw",
    'ru': "Редактировать профиль",
    'de': "Profil bearbeiten",
  });
  String get logout => _t({'uz': "Chiqish", 'kaa': "Shıǵıw", 'ru': "Выйти", 'de': "Abmelden"});
  String get level => _t({'uz': "Daraja", 'kaa': "Dáreje", 'ru': "Уровень", 'de': "Niveau"});
  String get achievements => _t({
    'uz': "Yutuqlar",
    'kaa': "Jetiskenliler",
    'ru': "Достижения",
    'de': "Errungenschaften",
  });
  String get paid => _t({
    'uz': "To'langan",
    'kaa': "Tólendi",
    'ru': "Оплачено",
    'de': "Bezahlt",
  });
  String get pending => _t({
    'uz': "Kutilmoqda",
    'kaa': "Kútilmekte",
    'ru': "Ожидается",
    'de': "Ausstehend",
  });
  String get myResults => _t({
    'uz': "Natijalarim",
    'kaa': "Natiyjelerim",
    'ru': "Мои результаты",
    'de': "Meine Ergebnisse",
  });
  String get settingsDesc => _t({
    'uz': "Til, qorong'u rejim va boshqa sozlamalar",
    'kaa': "Til, qaranǵı rejim hám basqa sazlamalar",
    'ru': "Язык, темный режим и другие настройки",
    'de': "Sprache, Dunkelmodus und andere Einstellungen",
  });

  // ── Group ──────────────────────────────────────────────────────────────────
  String get myGroup => _t({
    'uz': "Mening guruhim",
    'kaa': "Menin toparım",
    'ru': "Моя группа",
    'de': "Meine Gruppe",
  });
  String get schedule => _t({
    'uz': "Jadval",
    'kaa': "Keste",
    'ru': "Расписание",
    'de': "Stundenplan",
  });
  String get classmates => _t({
    'uz': "Sinfdoshlar",
    'kaa': "Toparlaslar",
    'ru': "Одноклассники",
    'de': "Klassenkameraden",
  });
  String get homework => _t({
    'uz': "Uyga vazifa",
    'kaa': "Úyge tapsırma",
    'ru': "Домашнее задание",
    'de': "Hausaufgaben",
  });
  String get notEnrolledInAnyCourse => _t({
    'uz': "Siz hali hech qanday\nkursga yozilmagansiz",
    'kaa': "Siz ele hesh qanday\nkursqa jazılmaǵansız",
    'ru': "Вы еще не записаны\nни на один курс",
    'de': "Sie sind noch in\nkeinem Kurs eingetragen",
  });
  String get studentsCountLabel => _t({
    'uz': "ta",
    'kaa': "dana",
    'ru': "чел.",
    'de': "Teilnehmer",
  });
  String get noLessonAddedYet => _t({
    'uz': "📭 Hali dars qo'shilmagan",
    'kaa': "📭 Ele sabaq qosılmaǵan",
    'ru': "📭 Урок еще не добавлен",
    'de': "📭 Noch keine Stunde hinzugefügt",
  });
  String get viewMaterials => _t({
    'uz': "Materiallarni ko'rish",
    'kaa': "Materiallardı kóriw",
    'ru': "Посмотреть материалы",
    'de': "Materialien ansehen",
  });
  String get noMaterialsYet => _t({
    'uz': "Hozircha materiallar yo'q",
    'kaa': "Házirshe materiallar joq",
    'ru': "Материалов пока нет",
    'de': "Noch keine Materialien",
  });
  String get materialComingSoon => _t({
    'uz': "Material tez orada ochiladi",
    'kaa': "Material tez arada ashıladı",
    'ru': "Материал скоро откроется",
    'de': "Material wird bald geöffnet",
  });
  String get monLong => _t({'uz': "Dushanba", 'kaa': "Dúyshembi", 'ru': "Понедельник", 'de': "Montag"});
  String get tueLong => _t({'uz': "Seshanba", 'kaa': "Shiyshembi", 'ru': "Вторник", 'de': "Dienstag"});
  String get wedLong => _t({'uz': "Chorshanba", 'kaa': "Sárshembi", 'ru': "Среда", 'de': "Mittwoch"});
  String get thuLong => _t({'uz': "Payshanba", 'kaa': "Piyshembi", 'ru': "Четверг", 'de': "Donnerstag"});
  String get friLong => _t({'uz': "Juma", 'kaa': "Juma", 'ru': "Пятница", 'de': "Freitag"});
  String get satLong => _t({'uz': "Shanba", 'kaa': "Shembi", 'ru': "Суббота", 'de': "Samstag"});
  String get sunLong => _t({'uz': "Yakshanba", 'kaa': "Ekshembi", 'ru': "Воскресенье", 'de': "Sonntag"});

  String get jan => _t({'uz': "yan", 'kaa': "yan", 'ru': "янв", 'de': "Jan"});
  String get feb => _t({'uz': "fev", 'kaa': "fev", 'ru': "фев", 'de': "Feb"});
  String get mar => _t({'uz': "mar", 'kaa': "mar", 'ru': "мар", 'de': "Mär"});
  String get apr => _t({'uz': "apr", 'kaa': "apr", 'ru': "апр", 'de': "Apr"});
  String get may => _t({'uz': "may", 'kaa': "may", 'ru': "май", 'de': "Mai"});
  String get iyn => _t({'uz': "iyn", 'kaa': "iyn", 'ru': "июн", 'de': "Jun"});
  String get iyl => _t({'uz': "iyl", 'kaa': "iyl", 'ru': "июл", 'de': "Jul"});
  String get avg => _t({'uz': "avg", 'kaa': "avg", 'ru': "авг", 'de': "Aug"});
  String get sen => _t({'uz': "sen", 'kaa': "sen", 'ru': "сен", 'de': "Sep"});
  String get okt => _t({'uz': "okt", 'kaa': "okt", 'ru': "окт", 'de': "Okt"});
  String get noy => _t({'uz': "noy", 'kaa': "noy", 'ru': "ноя", 'de': "Nov"});
  String get dek => _t({'uz': "dek", 'kaa': "dek", 'ru': "дек", 'de': "Dez"});

  // ── Learning ───────────────────────────────────────────────────────────────
  String get vocabulary => _t({
    'uz': "Lug'at",
    'kaa': "Sózlik",
    'ru': "Словарь",
    'de': "Vokabular",
  });
  String get grammar => _t({
    'uz': "Grammatika",
    'kaa': "Grammatika",
    'ru': "Грамматика",
    'de': "Grammatik",
  });
  String get listening => _t({
    'uz': "Tinglash",
    'kaa': "Tıńlaw",
    'ru': "Аудирование",
    'de': "Hören",
  });
  String get speaking => _t({
    'uz': "Gapirish",
    'kaa': "Sóylesиw",
    'ru': "Говорение",
    'de': "Sprechen",
  });
  String get learningProgress => _t({
    'uz': "O'rganish progressi",
    'kaa': "Úyreniw progressi",
    'ru': "Прогресс обучения",
    'de': "Lernfortschritt",
  });
  String get percentCompleted => _t({
    'uz': "bajarilgan",
    'kaa': "orınlanǵan",
    'ru': "выполнено",
    'de': "abgeschlossen",
  });
  String get categories => _t({
    'uz': "Kategoriyalar",
    'kaa': "Kategoriyalar",
    'ru': "Категории",
    'de': "Kategorien",
  });
  String get speakWithAi => _t({
    'uz': "AI bilan gaplashish",
    'kaa': "JI menen sóylesiw",
    'ru': "Разговор с ИИ",
    'de': "Sprechen mit KI",
  });
  String get learnArticles => _t({
    'uz': "Artikllarni o'rganish",
    'kaa': "Artikllerdi úyreniw",
    'ru': "Изучение артиклей",
    'de': "Artikel lernen",
  });
  String get writingExercises => _t({
    'uz': "Yozish mashqlari",
    'kaa': "Jazıw tapsırmaları",
    'ru': "Упражнения на письмо",
    'de': "Schreibübungen",
  });
  String get listeningExercises => _t({
    'uz': "Tinglash mashqlari",
    'kaa': "Tıńlaw tapsırmaları",
    'ru': "Упражнения на аудирование",
    'de': "Hörübungen",
  });
  String get vocabAndTranslation => _t({
    'uz': "Lug'at va tarjima",
    'kaa': "Lúǵat hám awdarma",
    'ru': "Словарь и перевод",
    'de': "Wortschatz & Übersetzung",
  });

  // ── Games ──────────────────────────────────────────────────────────────────
  String get wordGame => _t({
    'uz': "So'z o'yini",
    'kaa': "Sóz oyını",
    'ru': "Игра слов",
    'de': "Wortspiel",
  });
  String get quiz => _t({'uz': "Viktorina", 'kaa': "Viktorina", 'ru': "Викторина", 'de': "Quiz"});
  String get flashcards => _t({
    'uz': "Kartochkalar",
    'kaa': "Kartoshkalar",
    'ru': "Карточки",
    'de': "Karteikarten",
  });
  String get myStars => _t({
    'uz': "Mening yulduzlarim",
    'kaa': "Meniń juldızlarım",
    'ru': "Мои звезды",
    'de': "Meine Sterne",
  });
  String get all => _t({
    'uz': "Barchasi",
    'kaa': "Barlıǵı",
    'ru': "Все",
    'de': "Alle",
  });
  String get allGames => _t({
    'uz': "Barcha o'yinlar",
    'kaa': "Barlıq oyınlar",
    'ru': "Все игры",
    'de': "Alle Spiele",
  });
  String get gameSynonymBattleTitle => _t({
    'uz': "Sinonim jangi",
    'kaa': "Sinonim gúresi",
    'ru': "Битва синонимов",
    'de': "Synonym-Kampf",
  });
  String get synonymBattle => _t({
    'uz': "Sinonimlar jangi",
    'kaa': "Sinonimler gúresi",
    'ru': "Битва синонимов",
    'de': "Synonym-Kampf",
  });
  String get gameGrammarTitle => _t({
    'uz': "Grammatik o'yin",
    'kaa': "Grammatika oyını",
    'ru': "Грамматическая игра",
    'de': "Grammatikspiel",
  });
  String get grammarQuiz => _t({
    'uz': "Grammatika viktorinasi",
    'kaa': "Grammatika viktorinası",
    'ru': "Грамматическая викторина",
    'de': "Grammatik-Quiz",
  });
  String get gameDerDieDasTitle => _t({
    'uz': "Der, die, das",
    'kaa': "Der, die, das",
    'ru': "Der, die, das",
    'de': "Der, die, das",
  });
  String get articleSpeedGame => _t({
    'uz': "Artikllar tezkor o'yini",
    'kaa': "Artikller tez oyını",
    'ru': "Быстрая игра с артиклями",
    'de': "Artikel-Schnellspiel",
  });
  String get gameVoiceTitle => _t({
    'uz': "Ovozli o'yin",
    'kaa': "Dawıslı oyın",
    'ru': "Голосовая игра",
    'de': "Sprachspiel",
  });
  String get pronunciationAndListening => _t({
    'uz': "Talaffuz va tinglash",
    'kaa': "Aytılıw hám tıńlaw",
    'ru': "Произношение и слух",
    'de': "Aussprache & Hören",
  });
  String get interactiveStory => _t({
    'uz': "Interaktiv hikoya",
    'kaa': "Interaktiv gúrriń",
    'ru': "Интерактивная история",
    'de': "Interaktive Geschichte",
  });
  String get gameTranslationBattleTitle => _t({
    'uz': "Tarjima battle",
    'kaa': "Awdarma jarısı",
    'ru': "Битва переводов",
    'de': "Übersetzungsduell",
  });
  String get translationBattle => _t({
    'uz': "Bot bilan tarjima musobaqasi",
    'kaa': "Bot penen awdarma jarısı",
    'ru': "Битва переводов с ботом",
    'de': "Übersetzungskampf mit Bot",
  });
  String get creativeSentenceMaking => _t({
    'uz': "Kreativ gap tuzish",
    'kaa': "Kreativ gáp dúziw",
    'ru': "Креативное составление предложений",
    'de': "Kreativer Satzbau",
  });
  String get strangeSentencesGame => _t({
    'uz': "G'alati gaplar",
    'kaa': "Ózgeshe gápler",
    'ru': "Странные предложения",
    'de': "Seltsame Sätze",
  });
  String get strangeSentencesDesc => _t({
    'uz': "So'zlardan grammatik to'g'ri, lekin mantiqsiz gap tuzing",
    'kaa': "Sózlerden grammatikalıq durıs, biraq ózgeshe gáp dúziń",
    'ru': "Составьте грамматически верное, но абсурдное предложение",
    'de': "Bilde grammatisch korrekte, aber unsinnige Sätze",
  });
  String get germanStoryGame => _t({
    'uz': "Nemischa hikoya",
    'kaa': "Nemisshe gúrriń",
    'ru': "Немецкая история",
    'de': "Deutsche Geschichte",
  });
  String get germanStoryDesc => _t({
    'uz': "Berilgan gaplardan o'z hikoyangizni yarating",
    'kaa': "Berilgen gáplerden óz gúrrińińizdi jasań",
    'ru': "Создайте свою историю из данных предложений",
    'de': "Erfinde deine Geschichte aus vorgegebenen Sätzen",
  });
  String get describePictureGame => _t({
    'uz': "Rasmni tariflang",
    'kaa': "Súwretti túsindiriń",
    'ru': "Опишите картинку",
    'de': "Bild beschreiben",
  });
  String get describePictureDesc => _t({
    'uz': "Rasmda nima borligini nemis tilida yozing",
    'kaa': "Súwrette ne bar ekenin nemis tilinde jazıń",
    'ru': "Опишите на немецком, что изображено",
    'de': "Beschreibe auf Deutsch, was du siehst",
  });
  String get gameComingSoonTitle => _t({
    'uz': "Tez orada!",
    'kaa': "Jaqında!",
    'ru': "Скоро!",
    'de': "Bald verfügbar!",
  });
  String get gameComingSoonMessage => _t({
    'uz':
        "Bu o'yin hozircha ishlab chiqilmoqda. Yangiliklar va yangi o'yinlar uchun ilovani yangilab boring — tez orada ochamiz!",
    'kaa':
        "Bul oyın házirshe islenip atır. Jańalıqlardı hám jańa oyınlardı biliw ushın qosımshanı jańalań — jaqında qosamız!",
    'ru':
        "Эта игра пока в разработке. Обновляйте приложение — скоро откроем новые игры и функции!",
    'de':
        "Dieses Spiel ist noch in Entwicklung. Halte die App aktuell — wir öffnen es bald!",
  });
  String get gameComingSoonButton => _t({
    'uz': "Tushundim",
    'kaa': "Túsidnim",
    'ru': "Понятно",
    'de': "Verstanden",
  });
  String get noGroupTitle => _t({
    'uz': "Guruhga qo'shilmagansiz",
    'kaa': "Toparga qosılmadıńız",
    'ru': "Вы не в группе",
    'de': "Keine Gruppe",
  });
  String get noGroupMessage => _t({
    'uz': "Siz hali hech qanday guruhga qo'shilmagansiz. Iltimos, admin yoki ustozingizga xabar bering!",
    'kaa': "Siz ele hesh qanday toparǵa qosılmaǵansız. Iltimas, admin yáki ustazıńızga xabar beriń!",
    'ru': "Вы ещё не добавлены ни в одну группу. Пожалуйста, свяжитесь с администратором или преподавателем!",
    'de': "Sie sind noch in keiner Gruppe. Bitte wenden Sie sich an Ihren Administrator oder Lehrer!",
  });
  String get noGroupButton => _t({
    'uz': "Tushundim",
    'kaa': "Túsindim",
    'ru': "Понятно",
    'de': "Verstanden",
  });

  String get strangeSentencesPickHint => _t({
    'uz': "Grammatik jihatdan to'g'ri g'alati gapni tanlang",
    'kaa': "Grammatikalıq durıs bir qızıqarlı gápti tańlań",
    'ru': "Выберите грамматически верное абсурдное предложение",
    'de': "Wähle den grammatisch korrekten absurden Satz",
  });
  String get strangeSentencesOrderHint => _t({
    'uz': "So'zlarni to'g'ri tartibda joylashtiring",
    'kaa': "Sózlerdi durıs tártipte qoyıń",
    'ru': "Расставьте слова в правильном порядке",
    'de': "Ordne die Wörter in die richtige Reihenfolge",
  });
  String get strangeSentencesLoading => _t({
    'uz': "AI yangi savollar tayyorlayapti...",
    'kaa': "JI jańa sorawlar tayarlap atır...",
    'ru': "ИИ готовит новые вопросы...",
    'de': "KI bereitet neue Fragen vor...",
  });
  String get strangeSentencesRulesHowTo => _t({
    'uz': "O'yin qoidalari",
    'kaa': "Oyın qaǵıydaları",
    'ru': "Правила игры",
    'de': "Spielregeln",
  });
  String get strangeSentencesStart => _t({
    'uz': "Boshlash",
    'kaa': "Baslaw",
    'ru': "Начать",
    'de': "Starten",
  });
  String get strangeSentencesYourSentence => _t({
    'uz': "Sizning gapingiz",
    'kaa': "Siziń gápińiz",
    'ru': "Ваше предложение",
    'de': "Dein Satz",
  });
  String get strangeSentencesTapWords => _t({
    'uz': "So'zlarni bosing",
    'kaa': "Sózlerdi basıń",
    'ru': "Нажимайте на слова",
    'de': "Tippe auf die Wörter",
  });
  String get strangeSentencesCheck => _t({
    'uz': "Tekshirish",
    'kaa': "Tekseriw",
    'ru': "Проверить",
    'de': "Prüfen",
  });
  String get strangeSentencesReset => _t({
    'uz': "Qayta",
    'kaa': "Qayta",
    'ru': "Сброс",
    'de': "Zurücksetzen",
  });

  // ── Teacher ────────────────────────────────────────────────────────────────
  String get helloTeacher => _t({
    'uz': "Salom, O'qituvchi 👋",
    'kaa': "Sálem, Muǵallim 👋",
    'ru': "Привет, Учитель 👋",
    'de': "Hallo, Lehrer 👋",
  });
  String get groups => _t({'uz': "Guruhlar", 'kaa': "Toparlar", 'ru': "Группы", 'de': "Gruppen"});
  String get students => _t({
    'uz': "O'quvchilar",
    'kaa': "Oqıwshılar",
    'ru': "Учащиеся",
    'de': "Schüler",
  });
  String get pendingWork => _t({
    'uz': "Kutayotgan ishlar",
    'kaa': "Kútilip atırǵan jumıslar",
    'ru': "Ожидающие задания",
    'de': "Ausstehende Aufgaben",
  });
  String get attendance => _t({
    'uz': "Davomat",
    'kaa': "Qatnas",
    'ru': "Посещаемость",
    'de': "Anwesenheit",
  });
  String get material => _t({
    'uz': "Material",
    'kaa': "Material",
    'ru': "Материал",
    'de': "Material",
  });
  String get check => _t({
    'uz': "Tekshirish",
    'kaa': "Tekseriw",
    'ru': "Проверить",
    'de': "Prüfen",
  });
  String get todayDashboard => _t({
    'uz': "Bugungi Boshqaruv Paneli",
    'kaa': "Búgingi Basqarıw Paneli",
    'ru': "Панель управления",
    'de': "Heutiges Dashboard",
  });
  String get remainingSubmissions => _t({
    'uz': "ta qoldi",
    'kaa': "dana qaldı",
    'ru': "осталось",
    'de': "verbleibend",
  });
  String get submittedOf => _t({
    'uz': "topshirilgan",
    'kaa': "tapsırılǵan",
    'ru': "сдано",
    'de': "eingereicht",
  });
  String get noTodayLessons => _t({
    'uz': "Bugungi darslar yo'q",
    'kaa': "Búgingi sabaqlar joq",
    'ru': "Сегодня уроков нет",
    'de': "Heute keine Stunden",
  });
  String get noPendingWork => _t({
    'uz': "Kutayotgan ishlar yo'q",
    'kaa': "Kútilip atırǵan jumıslar joq",
    'ru': "Нет заданий",
    'de': "Keine ausstehenden Aufgaben",
  });

  // ── Admin ──────────────────────────────────────────────────────────────────
  String get adminDashboard => _t({
    'uz': "Boshqaruv Paneli",
    'kaa': "Basqarıw Paneli",
    'ru': "Панель управления",
    'de': "Verwaltungspanel",
  });
  String get totalStudents => _t({
    'uz': "O'quvchilar",
    'kaa': "Oqıwshılar",
    'ru': "Учащиеся",
    'de': "Schüler",
  });
  String get totalTeachers => _t({
    'uz': "O'qituvchilar",
    'kaa': "Muǵallimler",
    'ru': "Учителя",
    'de': "Lehrer",
  });
  String get totalGroups => _t({
    'uz': "Guruhlar",
    'kaa': "Toparlar",
    'ru': "Группы",
    'de': "Gruppen",
  });
  String get totalRevenue => _t({
    'uz': "Daromad",
    'kaa': "Dáramat",
    'ru': "Доход",
    'de': "Einnahmen",
  });
  String get addStudent => _t({
    'uz': "O'quvchi qo'shish",
    'kaa': "Oqıwshı qosıw",
    'ru': "Добавить ученика",
    'de': "Schüler hinzufügen",
  });
  String get addTeacher => _t({
    'uz': "O'qituvchi qo'shish",
    'kaa': "Muǵallim qosıw",
    'ru': "Добавить учителя",
    'de': "Lehrer hinzufügen",
  });
  String get courses => _t({'uz': "Kurslar", 'kaa': "Kurslar", 'ru': "Курсы", 'de': "Kurse"});
  String get payments => _t({
    'uz': "To'lovlar",
    'kaa': "Tólemler",
    'ru': "Платежи",
    'de': "Zahlungen",
  });
  String get recentActivity => _t({
    'uz': "So'nggi faollik",
    'kaa': "Aqırǵı iskerlik",
    'ru': "Последние активности",
    'de': "Letzte Aktivitäten",
  });
  String get quickAction => _t({
    'uz': "Tezkor amallar",
    'kaa': "Tez ámeller",
    'ru': "Быстрые действия",
    'de': "Schnellaktionen",
  });

  // ── Splash ─────────────────────────────────────────────────────────────────
  String get loading => _t({
    'uz': "Yuklanmoqda...",
    'kaa': "Júkleniwde...",
    'ru': "Загрузка...",
    'de': "Wird geladen...",
  });

  // ── Common ─────────────────────────────────────────────────────────────────
  String get back => _t({'uz': "Orqaga", 'kaa': "Artqa", 'ru': "Назад", 'de': "Zurück"});
  String get save => _t({'uz': "Saqlash", 'kaa': "Saqlaw", 'ru': "Сохранить", 'de': "Speichern"});
  String get cancel => _t({'uz': "Bekor qilish", 'kaa': "Toqtatıw", 'ru': "Отмена", 'de': "Abbrechen"});
  String get search => _t({'uz': "Qidirish", 'kaa': "Izdew", 'ru': "Поиск", 'de': "Suche"});
  String get noData => _t({'uz': "Ma'lumot yo'q", 'kaa': "Maǵlıwmat joq", 'ru': "Нет данных", 'de': "Keine Daten"});
  String get languageChanged => _t({
    'uz': "Til muvaffaqiyatli o'zgartirildi",
    'kaa': "Til sátli ózgertirildi",
    'ru': "Язык успешно изменён",
    'de': "Sprache erfolgreich geändert",
  });
  String get teacherProfile => _t({
    'uz': "O'qituvchi Profili",
    'kaa': "Muǵallim Profili",
    'ru': "Профиль Учителя",
    'de': "Lehrerprofil",
  });
  String get sections => _t({
    'uz': "Bo'limlar",
    'kaa': "Bólimler",
    'ru': "Разделы",
    'de': "Bereiche",
  });
  String get logoutLabel => _t({
    'uz': "Tizimdan chiqish",
    'kaa': "Tizimnen shıǵıw",
    'ru': "Выйти из системы",
    'de': "Ausloggen",
  });
  String get myGroups => _t({
    'uz': "Mening Guruhlarim",
    'kaa': "Mening Toparlarım",
    'ru': "Мои Группы",
    'de': "Meine Gruppen",
  });
  String get pleaseReLogin => _t({
    'uz': "Iltimos, tizimga qaytadan kiring",
    'kaa': "Iltimas, dástúrge qaytadan kiriń",
    'ru': "Пожалуйста, войдите в систему заново",
    'de': "Bitte melden Sie sich erneut an",
  });
  String get noGroupsAssigned => _t({
    'uz': "Sizga hech qanday guruh biriktirilmagan",
    'kaa': "Sizge hesh qanday topar biriktirilmegen",
    'ru': "За вами не закреплено ни одной группы",
    'de': "Ihnen sind keine Gruppen zugewiesen",
  });
  String get started => _t({
    'uz': "Boshlangan",
    'kaa': "Baslanǵan",
    'ru': "Начато",
    'de': "Gestartet",
  });
  String get edit => _t({
    'uz': "Tahrirlash",
    'kaa': "Ózgertiw",
    'ru': "Редактировать",
    'de': "Bearbeiten",
  });
  String get duration => _t({
    'uz': "Davomiyligi",
    'kaa': "Dawamlılıǵı",
    'ru': "Продолжительность",
    'de': "Dauer",
  });
  String get startDateLabel => _t({
    'uz': "Boshlanish sanasi",
    'kaa': "Baslanıw sánesi",
    'ru': "Дата начала",
    'de': "Startdatum",
  });
  String get courseName => _t({
    'uz': "Kurs nomi",
    'kaa': "Kurs atı",
    'ru': "Название курса",
    'de': "Kursname",
  });
  String get courseType => _t({
    'uz': "Turi",
    'kaa': "Túri",
    'ru': "Тип",
    'de': "Typ",
  });
  String get addCourse => _t({
    'uz': "Yangi kurs qo'shish",
    'kaa': "Taza kurs qosıw",
    'ru': "Добавить новый курс",
    'de': "Neuen Kurs hinzufügen",
  });
  String get noCoursesYet => _t({
    'uz': "Hozircha kurslar yo'q",
    'kaa': "Házirshe kurslar joq",
    'ru': "Курсов пока нет",
    'de': "Noch keine Kurse",
  });
  String get student => _t({
    'uz': "Talaba",
    'kaa': "Oqıwshı",
    'ru': "Ученик",
    'de': "Schüler",
  });
  String get studentsLabel => _t({
    'uz': "Talabalar",
    'kaa': "Oqıwshılar",
    'ru': "Ученики",
    'de': "Schüler",
  });
  String get task => _t({
    'uz': "Topshiriq",
    'kaa': "Tapsırma",
    'ru': "Задание",
    'de': "Aufgabe",
  });
  String get noStudentsInGroup => _t({
    'uz': "Guruhda talabalar yo'q",
    'kaa': "Toparda oqıwshılar joq",
    'ru': "В группе нет учеников",
    'de': "Keine Schüler in der Gruppe",
  });
  String get studentAlreadyInGroup => _t({
    'uz': "Bu talaba allaqachon",
    'kaa': "Bul oqıwshı álleqashan",
    'ru': "Этот ученик уже",
    'de': "Dieser Schüler ist bereits",
  });
  String get studyingInGroup => _t({
    'uz': "guruhida o'qiydi!",
    'kaa': "toparında oqıydı!",
    'ru': "в группе учится!",
    'de': "in der Gruppe lernt!",
  });
  String get willBeAddedSoon => _t({
    'uz': "tez orada qo'shiladi",
    'kaa': "tez arada qosıladı",
    'ru': "скоро будет добавлено",
    'de': "wird bald hinzugefügt",
  });
  String get noStudentsFound => _t({
    'uz': "Studentlar topilmadi",
    'kaa': "Studentler tabılmadı",
    'ru': "Студенты не найдены",
    'de': "Keine Schüler gefunden",
  });
  String get deleteStudentTitle => _t({
    'uz': "Studentni o'chirish",
    'kaa': "Studentti óshiriw",
    'ru': "Удалить студента",
    'de': "Schüler löschen",
  });
  String get deleteStudentConfirm => _t({
    'uz': "Bu studentni o'chirmoqchimisiz?",
    'kaa': "Bul studentti óshirmekshimisizba?",
    'ru': "Вы действительно хотите удалить этого студента?",
    'de': "Möchten Sie diesen Schüler wirklich löschen?",
  });
  String get delete => _t({
    'uz': "O'chirish",
    'kaa': "Óshiriw",
    'ru': "Удалить",
    'de': "Löschen",
  });
  String get studentDeleted => _t({
    'uz': "Student o'chirildi",
    'kaa': "Student óshirildi",
    'ru': "Студент удален",
    'de': "Schüler gelöscht",
  });
  String get phoneLabel => _t({
    'uz': "Telefon",
    'kaa': "Telefon",
    'ru': "Телефон",
    'de': "Telefon",
  });
  String get joinedDate => _t({
    'uz': "Qo'shilgan sana",
    'kaa': "Qosılǵan sáne",
    'ru': "Дата регистрации",
    'de': "Beitrittsdatum",
  });
  String get groupLabel => _t({
    'uz': "Guruh",
    'kaa': "Topar",
    'ru': "Группа",
    'de': "Gruppe",
  });
  String get notAssignedYet => _t({
    'uz': "Hali biriktirilmagan",
    'kaa': "Ele biriktirilmegen",
    'ru': "Еще не назначен",
    'de': "Noch nicht zugewiesen",
  });
  String get noTeachersFound => _t({
    'uz': "O'qituvchilar topilmadi",
    'kaa': "Muǵallimler tabılmadı",
    'ru': "Учителя не найдены",
    'de': "Keine Lehrer gefunden",
  });
  String get deleteTeacherTitle => _t({
    'uz': "O'qituvchini o'chirish",
    'kaa': "Muǵallimdi óshiriw",
    'ru': "Удалить учителя",
    'de': "Lehrer löschen",
  });
  String get deleteTeacherConfirm => _t({
    'uz': "Bu o'qituvchini o'chirmoqchimisiz?",
    'kaa': "Bul muǵallimdi óshirmekshimisizba?",
    'ru': "Вы действительно хотите удалить этого учителя?",
    'de': "Möchten Sie diesen Lehrer wirklich löschen?",
  });
  String get teacherDeleted => _t({
    'uz': "O'qituvchi o'chirildi",
    'kaa': "Muǵallim óshirildi",
    'ru': "Учитель удален",
    'de': "Lehrer gelöscht",
  });
  String get fullNameLabel => _t({
    'uz': "To'liq ism",
    'kaa': "Tolıq atı",
    'ru': "Полное имя",
    'de': "Vollständiger Name",
  });
  String get passwordLabel => _t({
    'uz': "Parol",
    'kaa': "Parol",
    'ru': "Пароль",
    'de': "Passwort",
  });
  String get assignedGroupsLabel => _t({
    'uz': "Biriktirilgan guruhlar",
    'kaa': "Biriktirilgen toparlar",
    'ru': "Закрепленные группы",
    'de': "Zugewiesene Gruppen",
  });
  String get add => _t({
    'uz': "Qo'shish",
    'kaa': "Qosıw",
    'ru': "Добавить",
    'de': "Hinzufügen",
  });
  String get materials => _t({
    'uz': "Dars materiallari",
    'kaa': "Sabaq materialları",
    'ru': "Материалы урока",
    'de': "Unterrichtsmaterialien",
  });

  // ── Schreiben ─────────────────────────────────────────────────────────────────
  String get schreibenTitle => _t({
    'uz': "SCHREIBEN",
    'kaa': "SCHREIBEN",
    'ru': "SCHREIBEN",
    'de': "SCHREIBEN",
  });
  String get aufgabe => _t({
    'uz': "AUFGABE",
    'kaa': "AUFGABE",
    'ru': "AUFGABE",
    'de': "AUFGABE",
  });
  String get styleLabel => _t({
    'uz': "Stil:",
    'kaa': "Stil:",
    'ru': "Стиль:",
    'de': "Stil:",
  });
  String get showSampleAnswer => _t({
    'uz': "Namuna javobni ko‘rsatish",
    'kaa': "Úlgi juwaptı kórsetiw",
    'ru': "Показать пример ответа",
    'de': "Show sample answer",
  });
  String get sampleAnswerComingSoon => _t({
    'uz': "Beispielantwort tez orada qo'shiladi.",
    'kaa': "Beispielantwort tez arada qosıladı.",
    'ru': "Beispielantwort скоро будет добавлена.",
    'de': "Beispielantwort wird bald hinzugefügt.",
  });
  String get aiPoweredEvaluation => _t({
    'uz': "Sun'iy intellekt yordamida baholash",
    'kaa': "Jasalma intellekt járdeminde bahalaw",
    'ru': "Оценка на основе искусственного интеллекта",
    'de': "AI-Powered Evaluation",
  });
  String get yourAnswer => _t({
    'uz': "Sizning javobingiz",
    'kaa': "Sizdiń juwabıńız",
    'ru': "Your Answer",
    'de': "Your Answer",
  });
  String get wordCountLabel => _t({
    'uz': "Wörter",
    'kaa': "Wörter",
    'ru': "Wörter",
    'de': "Wörter",
  });
  String get yourLetterHint => _t({
    'uz': "Ihr Brief:",
    'kaa': "Ihr Brief:",
    'ru': "Ihr Brief:",
    'de': "Ihr Brief:",
  });
  String get evaluating => _t({
    'uz': "Tekshirilmoqda...",
    'kaa': "Tekshirilmoqda...",
    'ru': "Проверяется...",
    'de': "Wird überprüft...",
  });
  String get submit => _t({
    'uz': "Yuborish",
    'kaa': "Jiberiw",
    'ru': "Отправить",
    'de': "Absenden",
  });
  String get writeAnswerHint => _t({
    'uz': "Javobingizni yozing, AI baholaydi.",
    'kaa': "Jabıwıńızdı jazıń, AI baxalaydı.",
    'ru': "Напишите ваш ответ, AI оценит.",
    'de': "Schreiben Sie Ihre Antwort, AI bewertet.",
  });
  String get evaluation => _t({
    'uz': "BAHOLASH",
    'kaa': "BAXALAW",
    'ru': "ОЦЕНКА",
    'de': "BEWERTUNG",
  });
  String get backBtn => _t({
    'uz': "Orqaga",
    'kaa': "Artqa",
    'ru': "Назад",
    'de': "Zurück",
  });
  String get next => _t({
    'uz': "Keyingi",
    'kaa': "Keyingi",
    'ru': "Далее",
    'de': "Weiter",
  });

  // ── Teacher ─────────────────────────────────────────────────────────────────
  String get checked => _t({
    'uz': "Tekshirildi ✓",
    'kaa': "Tekserildi ✓",
    'ru': "Проверено ✓",
    'de': "Überprüft ✓",
  });
  String get profilePhotoUpdated => _t({
    'uz': "Profil rasmi yangilandi",
    'kaa': "Profil suratı jańalandı",
    'ru': "Фото профиля обновлено",
    'de': "Profilbild aktualisiert",
  });
  String get markAttendance => _t({
    'uz': "DAVOMATNI BELGILASH",
    'kaa': "QATNASDÍ BELGILEW",
    'ru': "ОТМЕТИТЬ ПОСЕЩАЕМОСТЬ",
    'de': "ANWESENHEIT MARKIEREN",
  });
  String get materialsHeader => _t({
    'uz': "MATERIALLAR",
    'kaa': "MATERIALLAR",
    'ru': "МАТЕРИАЛЫ",
    'de': "MATERIALIEN",
  });
  String get addedMaterials => _t({
    'uz': "Qo'shilgan materiallar:",
    'kaa': "Qosılğan materiallar:",
    'ru': "Добавленные материалы:",
    'de': "Hinzugefügte Materialien:",
  });
  String get homeworkHeader => _t({
    'uz': "UY VAZIFASI",
    'kaa': "UY WAZIFASI",
    'ru': "ДОМАШНЕЕ ЗАДАНИЕ",
    'de': "HAUSAUFGABE",
  });

  // ── Student Learning ────────────────────────────────────────────────────────
  String get statisticsAndResults => _t({
    'uz': "STATISTIKA VA NATIJALAR",
    'kaa': "STATISTIKA HÁM NÁTIYJELER",
    'ru': "СТАТИСТИКА И РЕЗУЛЬТАТЫ",
    'de': "STATISTIK UND ERGEBNISSE",
  });
  String get upcomingLessons => _t({
    'uz': "KEYINGI DARSLAR",
    'kaa': "KEYINGI SABAQLAR",
    'ru': "БЛИЖАЙШИЕ УРОКИ",
    'de': "KOMMENDE UNTERRICHTSSTUNDEN",
  });
  String get noLessonToday => _t({
    'uz': "Bugun dars yo'q, dam oling yoki qo'shimcha mashq qiling",
    'kaa': "Bugún sabaq joq, dem alıń yamasa qosımsha shınıǵıw qılıń",
    'ru': "Сегодня нет урока, отдохните или сделайте дополнительные упражнения",
    'de': "Heute keine Lektion, ruhen Sie sich aus oder machen Sie zusätzliche Übungen",
  });
  String get viewHomework => _t({
    'uz': "UY VAZIFASINI KO'RISH",
    'kaa': "ÚY JUMÍSÍN KÓRIW",
    'ru': "ПОСМОТРЕТЬ ДОМАШНЕЕ ЗАДАНИЕ",
    'de': "HAUSAUFGABE ANSEHEN",
  });
  String get homeworkSubmitted => _t({
    'uz': "UY VAZIFASI TOPSHIRILDI",
    'kaa': "ÚY JUMÍSÍ TAPSÍRÍLDÍ TAPSÍRÍLDÍ",
    'ru': "ДОМАШНЕЕ ЗАДАНИЕ СДАНО",
    'de': "HAUSAUFGABE ABGEGEBEN",
  });
  String get curriculum => _t({
    'uz': "O'QUV REJASI",
    'kaa': "OQÍW REJESI",
    'ru': "УЧЕБНЫЙ ПЛАН",
    'de': "STUDIENPLAN",
  });
  String get addHomework => _t({
    'uz': "UY VAZIFA QO'SHISH",
    'kaa': "ÚY JUMÍSÍN QOSÍW",
    'ru': "ДОБАВИТЬ ДОМАШНЕЕ ЗАДАНИЕ",
    'de': "HAUSAUFGABE HINZUFÜGEN",
  });
  String get homeworkCount => _t({
    'uz': "UY VAZIFA",
    'kaa': "ÚYGE TAPSÍRMA",
    'ru': "ДОМАШНЕЕ ЗАДАНИЕ",
    'de': "HAUSAUFGABE",
  });
  String get tapToAddHomework => _t({
    'uz': "+ tugmasini bosib uy vazifa qo'shing",
    'kaa': "+ túymesin basıp úy jumısın qosıń",
    'ru': "Нажмите + чтобы добавить домашнее задание",
    'de': "Drücken Sie + um Hausaufgabe hinzuzufügen",
  });
  String get lesson => _t({
    'uz': "Dars",
    'kaa': "Sabaq",
    'ru': "Урок",
    'de': "Lektion",
  });
  String get addLesson => _t({
    'uz': "DARS QO'SHISH",
    'kaa': "SABAQ QOSÍW",
    'ru': "ДОБАВИТЬ УРОК",
    'de': "LEKTION HINZUFÜGEN",
  });
  String get materialLabel => _t({
    'uz': "Material",
    'kaa': "Material",
    'ru': "Материал",
    'de': "Material",
  });
  String get submitted => _t({
    'uz': "topshirdi",
    'kaa': "tapsırdı",
    'ru': "сдал",
    'de': "abgegeben",
  });
  String get link => _t({
    'uz': "Havola (Link)",
    'kaa': "Silteme (Link)",
    'ru': "Ссылка (Link)",
    'de': "Link",
  });
  String get text => _t({
    'uz': "Matn",
    'kaa': "Tekst",
    'ru': "Текст",
    'de': "Text",
  });
  String get linkHint => _t({
    'uz': "https://... yoki Telegram/Drive havolasi",
    'kaa': "https://... yamasa Telegram/Drive siltesi",
    'ru': "https://... или ссылка Telegram/Drive",
    'de': "https://... oder Telegram/Drive Link",
  });
  String get materialTextHint => _t({
    'uz': "Material matnini kiriting...",
    'kaa': "Material tekstin kiritiń...",
    'ru': "Введите текст материала...",
    'de': "Materialtext eingeben...",
  });
  String get saveBtn => _t({
    'uz': "SAQLASH",
    'kaa': "SAQLAW",
    'ru': "СОХРАНИТЬ",
    'de': "SPEICHERN",
  });
  String get titleHint => _t({
    'uz': "Sarlavha...",
    'kaa': "Titul...",
    'ru': "Заголовок...",
    'de': "Titel...",
  });
  String get detailInfoHint => _t({
    'uz': "Batafsil ma'lumot...",
    'kaa': "Tolıq maǵlıwmat...",
    'ru': "Подробная информация...",
    'de': "Detaillierte Informationen...",
  });
  String get commentOptional => _t({
    'uz': "Izoh (ixtiyoriy)...",
    'kaa': "Túsindiriw (ıqtıyarlı)...",
    'ru': "Комментарий (необязательно)...",
    'de': "Kommentar (optional)...",
  });
  String get commentOptionalCaps => _t({
    'uz': "IZOH (IXTIYORIY)",
    'kaa': "TÚSINDÍRÍW (ÍQTÍYARLÍ)",
    'ru': "КОММЕНТАРИЙ (НЕОБЯЗАТЕЛЬНО)",
    'de': "KOMMENTAR (OPTIONAL)",
  });
  String get writeCommentOptional => _t({
    'uz': "Izoh yozing (ixtiyoriy)...",
    'kaa': "Túsindiriw jazıń (ÍQTÍYARLÍ)...",
    'ru': "Напишите комментарий (необязательно)...",
    'de': "Schreibe einen Kommentar (optional)...",
  });
  String get testAnswersOptional => _t({
    'uz': "TEST JAVOBLARI (ixtiyoriy)",
    'kaa': "TEST JUWAPLARI (ıqtıyarlı)",
    'ru': "ОТВЕТЫ НА ТЕСТ (необязательно)",
    'de': "TESTANTWORTEN (optional)",
  });

  // ── Notifications & messaging ─────────────────────────────────────────────
  String get notificationsTitle => _t({
    'uz': "Xabarnomalar",
    'kaa': "Xabarlamalar",
    'ru': "Уведомления",
    'de': "Benachrichtigungen",
  });
  String get markAllAsRead => _t({
    'uz': "Barchasini o'qildi deb belgilash",
    'kaa': "Barlıǵın oqılǵan dep belgilew",
    'ru': "Отметить все как прочитанные",
    'de': "Alle als gelesen markieren",
  });
  String get noNotificationsYet => _t({
    'uz': "Hozircha xabarlar yo'q",
    'kaa': "Házirshe xabarlar joq",
    'ru': "Пока нет уведомлений",
    'de': "Noch keine Benachrichtigungen",
  });
  String get noNotificationsSubtitle => _t({
    'uz': "Sizga yangi xabarlar kelganda bu yerda ko'rsatiladi",
    'kaa': "Sizge taza xabarlar kelgende bul jerde kórsetiledi",
    'ru': "Новые уведомления появятся здесь",
    'de': "Neue Benachrichtigungen erscheinen hier",
  });
  String get sendMessage => _t({
    'uz': "Xabar yuborish",
    'kaa': "Xabar jiberiw",
    'ru': "Отправить сообщение",
    'de': "Nachricht senden",
  });
  String get titleLabel => _t({
    'uz': "Sarlavha",
    'kaa': "Titul",
    'ru': "Заголовок",
    'de': "Titel",
  });
  String get messageBodyLabel => _t({
    'uz': "Xabar matni",
    'kaa': "Xabar teksti",
    'ru': "Текст сообщения",
    'de': "Nachrichtentext",
  });
  String get selectUserLabel => _t({
    'uz': "Foydalanuvchini tanlang",
    'kaa': "Paydalanıwshını tańlań",
    'ru': "Выберите пользователя",
    'de': "Benutzer auswählen",
  });
  String get enterTitleAndMessage => _t({
    'uz': "Sarlavha va xabar matnini kiriting",
    'kaa': "Titul hám xabar tekstin kiritiń",
    'ru': "Введите заголовок и текст сообщения",
    'de': "Titel und Nachrichtentext eingeben",
  });
  String get messageSent => _t({
    'uz': "Xabar yuborildi",
    'kaa': "Xabar jiberildi",
    'ru': "Сообщение отправлено",
    'de': "Nachricht gesendet",
  });
  String get messageFallback => _t({
    'uz': "Xabar",
    'kaa': "Xabar",
    'ru': "Сообщение",
    'de': "Nachricht",
  });

  // ── Chat ───────────────────────────────────────────────────────────────────
  String get groupChat => _t({
    'uz': "Guruh chati",
    'kaa': "Topar chatı",
    'ru': "Групповой чат",
    'de': "Gruppenchat",
  });
  String get noMessagesYet => _t({
    'uz': "Hali xabarlar yo'q",
    'kaa': "Ele xabarlar joq",
    'ru': "Сообщений пока нет",
    'de': "Noch keine Nachrichten",
  });
  String get sendFirstMessage => _t({
    'uz': "Birinchi xabarni yuboring!",
    'kaa': "Birinshi xabardı jiberiń!",
    'ru': "Отправьте первое сообщение!",
    'de': "Senden Sie die erste Nachricht!",
  });
  String get writeMessageHint => _t({
    'uz': "Xabar yozing...",
    'kaa': "Xabar jazıń...",
    'ru': "Напишите сообщение...",
    'de': "Nachricht schreiben...",
  });
  String get reply => _t({
    'uz': "Javob berish",
    'kaa': "Juwap berıw",
    'ru': "Ответить",
    'de': "Antworten",
  });
  String get copy => _t({
    'uz': "Nusxa olish",
    'kaa': "Kóshirme alıw",
    'ru': "Копировать",
    'de': "Kopieren",
  });
  String get edited => _t({
    'uz': "tahrirlangan",
    'kaa': "ózgertilgen",
    'ru': "изменено",
    'de': "bearbeitet",
  });
  String get deleteMessage => _t({
    'uz': "Xabarni o'chirish",
    'kaa': "Xabardı óshiriw",
    'ru': "Удалить сообщение",
    'de': "Nachricht löschen",
  });
  String get deleteMessageConfirm => _t({
    'uz': "Ushbu xabarni o'chirishni xohlaysizmi?",
    'kaa': "Bul xabardı óshiriwdı qáleysiz ba?",
    'ru': "Вы хотите удалить это сообщение?",
    'de': "Möchten Sie diese Nachricht löschen?",
  });
  String get messageDeleted => _t({
    'uz': "Xabar o'chirildi",
    'kaa': "Xabar óshirildi",
    'ru': "Сообщение удалено",
    'de': "Nachricht gelöscht",
  });
  String get copiedToClipboard => _t({
    'uz': "Nusxa olindi",
    'kaa': "Kóshirme alındı",
    'ru': "Скопировано",
    'de': "Kopiert",
  });
  String get editingMessage => _t({
    'uz': "Xabarni tahrirlash",
    'kaa': "Xabardı ózgertiw",
    'ru': "Редактирование сообщения",
    'de': "Nachricht bearbeiten",
  });
  String get replyingTo => _t({
    'uz': "Javob berish",
    'kaa': "Juwap beriw",
    'ru': "Ответ на",
    'de': "Antwort auf",
  });
  String get groupMembersTitle => _t({
    'uz': "Guruh a'zolari",
    'kaa': "Topar aǵzaları",
    'ru': "Участники группы",
    'de': "Gruppenmitglieder",
  });
  String get teacherBadge => _t({
    'uz': "Ustoz",
    'kaa': "Muǵallim",
    'ru': "Учитель",
    'de': "Lehrer",
  });
  String get groupTeacherRole => _t({
    'uz': "Guruh o'qituvchisi",
    'kaa': "Topar muǵallimi",
    'ru': "Преподаватель группы",
    'de': "Gruppenlehrer",
  });
  String get noGroupsTitle => _t({
    'uz': "Guruhlar yo'q",
    'kaa': "Toparlar joq",
    'ru': "Нет групп",
    'de': "Keine Gruppen",
  });
  String get unknown => _t({
    'uz': "Noma'lum",
    'kaa': "Belgisiz",
    'ru': "Неизвестно",
    'de': "Unbekannt",
  });
  String get translator => _t({
    'uz': "Tarjimon",
    'kaa': "Awdarmashı",
    'ru': "Переводчик",
    'de': "Übersetzer",
  });
  String get translateAction => _t({
    'uz': "Tarjima qilish",
    'kaa': "Awdarma qılıw",
    'ru': "Перевести",
    'de': "Übersetzen",
  });
  String get aiBot => _t({
    'uz': "AI Bot",
    'kaa': "AI Bot",
    'ru': "AI Бот",
    'de': "KI-Bot",
  });
  String get qaSubtitle => _t({
    'uz': "Savol-javob",
    'kaa': "Suraw-juwap",
    'ru': "Вопросы и ответы",
    'de': "Fragen & Antworten",
  });
  String get freeConversation => _t({
    'uz': "Erkin suhbat",
    'kaa': "Erkin sóylesiw",
    'ru': "Свободный разговор",
    'de': "Freies Gespräch",
  });

  // ── Home extras ────────────────────────────────────────────────────────────
  String get streakSavedTitle => _t({
    'uz': "STREAK SAQLANDI!",
    'kaa': "STREAK SAQLANDI!",
    'ru': "СЕРИЯ СОХРАНЕНА!",
    'de': "SERIE GESPEICHERT!",
  });
  String get keepLearningDaily => _t({
    'uz': "Har kuni o'rganishda davom eting!",
    'kaa': "Hár kún úyreniwdi dawam etiń!",
    'ru': "Продолжайте учиться каждый день!",
    'de': "Lernen Sie jeden Tag weiter!",
  });
  String get averageScore => _t({
    'uz': "O'rtacha Ball",
    'kaa': "Ortasha ball",
    'ru': "Средний балл",
    'de': "Durchschnittsnote",
  });
  String get noDataYet => _t({
    'uz': "Hozircha ma'lumot yo'q",
    'kaa': "Házirshe maǵlıwmat joq",
    'ru': "Данных пока нет",
    'de': "Noch keine Daten",
  });
  String get errorOccurred => _t({
    'uz': "Xatolik yuz berdi",
    'kaa': "Qátelik júz berdi",
    'ru': "Произошла ошибка",
    'de': "Ein Fehler ist aufgetreten",
  });
  String get emailNotRegistered => _t({
    'uz': "Ushbu elektron pochta ro'yxatdan o'tmagan.",
    'kaa': "Bul elektron pochta dizimnen ótpegen.",
    'ru': "Этот email не зарегистрирован.",
    'de': "Diese E-Mail ist nicht registriert.",
  });
  String get wrongPasswordEntered => _t({
    'uz': "Parol noto'g'ri kiritildi.",
    'kaa': "Parol nadurıs kiritildi.",
    'ru': "Неверный пароль.",
    'de': "Falsches Passwort eingegeben.",
  });
  String get passwordsDontMatch => _t({
    'uz': "Parollar mos kelmadi",
    'kaa': "Parollar sáykes kelmeydi",
    'ru': "Пароли не совпадают",
    'de': "Passwörter stimmen nicht überein",
  });
  String get passwordMin6 => _t({
    'uz': "Parol kamida 6 ta belgidan iborat bo'lishi kerak",
    'kaa': "Parol keminde 6 belgiden turıwı kerek",
    'ru': "Пароль должен содержать минимум 6 символов",
    'de': "Passwort muss mindestens 6 Zeichen haben",
  });
  String get registerSuccess => _t({
    'uz': "Muvaffaqiyatli ro'yxatdan o'tdingiz! 🎉",
    'kaa': "Sátli dizimnen óttińiz! 🎉",
    'ru': "Регистрация прошла успешно! 🎉",
    'de': "Erfolgreich registriert! 🎉",
  });
  String get genericError => _t({
    'uz': "Xatolik yuz berdi",
    'kaa': "Qátelik júz berdi",
    'ru': "Произошла ошибка",
    'de': "Ein Fehler ist aufgetreten",
  });
  String get emailInUse => _t({
    'uz': "Bu email band. Boshqa email kiriting.",
    'kaa': "Bul email band. Basqa email kiritiń.",
    'ru': "Этот email уже занят. Введите другой.",
    'de': "Diese E-Mail ist vergeben. Andere E-Mail eingeben.",
  });
  String get retry => _t({
    'uz': "Qayta urinish",
    'kaa': "Qayta urınıw",
    'ru': "Повторить",
    'de': "Erneut versuchen",
  });
  String get failedToLoadData => _t({
    'uz': "Ma'lumotlarni yuklab bo'lmadi.",
    'kaa': "Maǵlıwmatlardı júklew múmkin bolmadı.",
    'ru': "Не удалось загрузить данные.",
    'de': "Daten konnten nicht geladen werden.",
  });
  String get noInternetTitle => _t({
    'uz': "Internet aloqasi yo'q",
    'kaa': "Internet baylanısı joq",
    'ru': "Нет подключения к интернету",
    'de': "Keine Internetverbindung",
  });
  String get noInternetMessage => _t({
    'uz': "Internet aloqasini tekshiring va qayta urining.",
    'kaa': "Internet baylanısın tekseriń hám qayta urınıń.",
    'ru': "Проверьте подключение и попробуйте снова.",
    'de': "Internetverbindung prüfen und erneut versuchen.",
  });
  String get noLessonsYet => _t({
    'uz': "Hozircha darslar yo'q",
    'kaa': "Házirshe sabaqlar joq",
    'ru': "Уроков пока нет",
    'de': "Noch keine Lektionen",
  });
  String get noLessonsSubtitle => _t({
    'uz': "Tez orada yangi darslar qo'shiladi.\nKuting yoki qo'shimcha mashq qiling!",
    'kaa': "Tez arada taza sabaqlar qosıladı.\nKútiń yamasa qosımsha maqtaq qılıń!",
    'ru': "Скоро появятся новые уроки.\nПодождите или сделайте доп. упражнения!",
    'de': "Neue Lektionen kommen bald.\nWarten oder extra üben!",
  });
  String get viewGames => _t({
    'uz': "O'yinlarni ko'rish",
    'kaa': "Oyınlardı kóriw",
    'ru': "Посмотреть игры",
    'de': "Spiele ansehen",
  });
  String get allHomeworkDone => _t({
    'uz': "Barcha vazifalar tugatildi!",
    'kaa': "Barlıq tapsırmalar tamamlandı!",
    'ru': "Все задания выполнены!",
    'de': "Alle Aufgaben erledigt!",
  });
  String get allHomeworkDoneSubtitle => _t({
    'uz': "Ajoyib! Siz barcha uyga vazifalarni bajardingiz.",
    'kaa': "Ajayıp! Siz barlıq úy tapsırmaların orınladıńız.",
    'ru': "Отлично! Вы выполнили все домашние задания.",
    'de': "Super! Alle Hausaufgaben erledigt.",
  });
  String get noGamesYet => _t({
    'uz': "O'yinlar yo'q",
    'kaa': "Oyınlar joq",
    'ru': "Игр нет",
    'de': "Keine Spiele",
  });
  String get noGamesSubtitle => _t({
    'uz': "Hozircha mavjud o'yinlar yo'q.\nTez orada yangilari qo'shiladi.",
    'kaa': "Házirshe bar oyınlar joq.\nTez arada yangıları qosıladı.",
    'ru': "Игр пока нет.\nСкоро появятся новые.",
    'de': "Noch keine Spiele.\nBald kommen neue.",
  });
  String get noMessagesTitle => _t({
    'uz': "Xabarlar yo'q",
    'kaa': "Xabarlar joq",
    'ru': "Нет сообщений",
    'de': "Keine Nachrichten",
  });
  String get noMessagesSubtitle => _t({
    'uz': "Suhbatni boshlash uchun biror narsa yozing.",
    'kaa': "Sóylesiwdi baslaw ushın birdeń jazıń.",
    'ru': "Напишите что-нибудь, чтобы начать чат.",
    'de': "Schreiben Sie etwas, um zu starten.",
  });
  String get noGroupsSubtitle => _t({
    'uz': "Siz hali hech qanday guruhga qo'shilmagansiz.\nGuruhga qo'shiling va darslarni boshlang!",
    'kaa': "Siz ele hesh qanday toparǵa qosılmaǵansız.\nToparǵa qosılıń hám sabaqlardı baslań!",
    'ru': "Вы ещё не в группе.\nПрисоединитесь и начните уроки!",
    'de': "Sie sind in keiner Gruppe.\nTreten Sie einer bei!",
  });
  String get joinGroup => _t({
    'uz': "Guruhga qo'shilish",
    'kaa': "Toparǵa qosılıw",
    'ru': "Присоединиться к группе",
    'de': "Gruppe beitreten",
  });
  String get noAchievementsYet => _t({
    'uz': "Yutuqlar yo'q",
    'kaa': "Jetiskenlikler joq",
    'ru': "Достижений нет",
    'de': "Keine Erfolge",
  });
  String get noAchievementsSubtitle => _t({
    'uz': "O'yinlarda qatnashib yutuqlarni qo'lga kiting!",
    'kaa': "Oyınlarda qatnasıp jetiskenliklerdi qolǵa kiriń!",
    'ru': "Участвуйте в играх и получайте достижения!",
    'de': "Spielen Sie und sammeln Sie Erfolge!",
  });
  String get justNow => _t({
    'uz': "Hozirgina",
    'kaa': "Házir",
    'ru': "Только что",
    'de': "Gerade eben",
  });
  String get yesterday => _t({
    'uz': "Kecha",
    'kaa': "Keше",
    'ru': "Вчера",
    'de': "Gestern",
  });
  String get serverErrorTitle => _t({
    'uz': "Server xatosi",
    'kaa': "Server qáteligi",
    'ru': "Ошибка сервера",
    'de': "Serverfehler",
  });
  String get serverErrorMessage => _t({
    'uz': "Serverda xatolik yuz berdi. Iltimos, keyinroq qayta urining.",
    'kaa': "Serverde qátelik júz berdi. Keyinirek qayta urınıń.",
    'ru': "Ошибка на сервере. Попробуйте позже.",
    'de': "Serverfehler. Bitte später erneut versuchen.",
  });
  String get timeoutTitle => _t({
    'uz': "Vaqt tugadi",
    'kaa': "Waqıt tawsıldı",
    'ru': "Время истекло",
    'de': "Zeit abgelaufen",
  });
  String get timeoutMessage => _t({
    'uz': "So'rov tugadi. Internet aloqasini tekshiring va qayta urining.",
    'kaa': "Soraw tamamlandı. Internet baylanısın tekseriń.",
    'ru': "Запрос истёк. Проверьте интернет и повторите.",
    'de': "Anfrage abgelaufen. Internet prüfen und erneut versuchen.",
  });
  String get unknownErrorMessage => _t({
    'uz': "Noma'lum xatolik yuz berdi.",
    'kaa': "Belgisiz qátelik júz berdi.",
    'ru': "Произошла неизвестная ошибка.",
    'de': "Unbekannter Fehler aufgetreten.",
  });
  String get dataNotFoundTitle => _t({
    'uz': "Ma'lumot topilmadi",
    'kaa': "Maǵlıwmat tabılmadı",
    'ru': "Данные не найдены",
    'de': "Daten nicht gefunden",
  });
  String get dataNotFoundMessage => _t({
    'uz': "So'ralgan ma'lumotlar topilmadi.",
    'kaa': "Soraw etilgen maǵlıwmatlar tabılmadı.",
    'ru': "Запрошенные данные не найдены.",
    'de': "Angeforderte Daten nicht gefunden.",
  });
  String get permissionRequiredTitle => _t({
    'uz': "Ruxsat kerak",
    'kaa': "Ruxsat kerek",
    'ru': "Требуется разрешение",
    'de': "Berechtigung erforderlich",
  });
  String permissionRequiredMessage(String permission) {
    final template = _t({
      'uz': '{p} ruxsatini berishingiz kerak.',
      'kaa': '{p} ruxsatın beriwińiz kerek.',
      'ru': 'Необходимо разрешение: {p}.',
      'de': 'Berechtigung {p} erforderlich.',
    });
    return template.replaceAll('{p}', permission);
  }
  String get grantPermission => _t({
    'uz': "Ruxsat berish",
    'kaa': "Ruxsat beriw",
    'ru': "Разрешить",
    'de': "Berechtigung erteilen",
  });
  String get gallery => _t({
    'uz': "Galereya",
    'kaa': "Galereya",
    'ru': "Галерея",
    'de': "Galerie",
  });
  String get camera => _t({
    'uz': "Kamera",
    'kaa': "Kamera",
    'ru': "Камера",
    'de': "Kamera",
  });
  String get tryAgainLater => _t({
    'uz': "Xatolik yuz berdi. Iltimos qaytadan urinib ko'ring.",
    'kaa': "Qátelik júz berdi. Iltimas, qayta urınıń.",
    'ru': "Произошла ошибка. Попробуйте снова.",
    'de': "Ein Fehler ist aufgetreten. Bitte erneut versuchen.",
  });

  String peopleCount(int count) {
    final template = _t({
      'uz': '{n} kishi',
      'kaa': '{n} kisi',
      'ru': '{n} чел.',
      'de': '{n} Personen',
    });
    return template.replaceAll('{n}', count.toString());
  }

  String studentsCount(int count) {
    final template = _t({
      'uz': '{n} talaba',
      'kaa': '{n} oqıwshı',
      'ru': '{n} учеников',
      'de': '{n} Schüler',
    });
    return template.replaceAll('{n}', count.toString());
  }

  String homeworkTasksCount(int count) {
    final template = _t({
      'uz': '{n} ta vazifa',
      'kaa': '{n} tapsırma',
      'ru': '{n} заданий',
      'de': '{n} Aufgaben',
    });
    return template.replaceAll('{n}', count.toString());
  }

  String homeworkMarkedDone(String title) {
    final template = _t({
      'uz': '{title} tugatildi!',
      'kaa': '{title} tamamlandı!',
      'ru': '{title} выполнено!',
      'de': '{title} erledigt!',
    });
    return template.replaceAll('{title}', title);
  }

  String homeworkUnmarked(String title) {
    final template = _t({
      'uz': '{title} olib tashlandi',
      'kaa': '{title} alıp taslandı',
      'ru': '{title} снято',
      'de': '{title} entfernt',
    });
    return template.replaceAll('{title}', title);
  }

  String activityStreakDays(int days) {
    final template = _t({
      'uz': 'FAOLIYAT: {n} KUN',
      'kaa': 'ISKERLIK: {n} KÚN',
      'ru': 'АКТИВНОСТЬ: {n} ДН.',
      'de': 'AKTIVITÄT: {n} TAGE',
    });
    return template.replaceAll('{n}', days.toString());
  }

  String minutesShort(int minutes) {
    final template = _t({
      'uz': '{n} daqiqa',
      'kaa': '{n} minut',
      'ru': '{n} мин.',
      'de': '{n} Min.',
    });
    return template.replaceAll('{n}', minutes.toString());
  }

  String dayMinutes(String day, int minutes) {
    final template = _t({
      'uz': '{day}: {minutes} daqiqa',
      'kaa': '{day}: {minutes} minut',
      'ru': '{day}: {minutes} мин.',
      'de': '{day}: {minutes} Min.',
    });
    return template
        .replaceAll('{day}', day)
        .replaceAll('{minutes}', minutes.toString());
  }

  String get thisWeek => _t({
    'uz': "Shu hafta",
    'kaa': "Bul hápte",
    'ru': "Эта неделя",
    'de': "Diese Woche",
  });

  String weeksAgo(int weeks) {
    final template = _t({
      'uz': '{n} hafta oldin',
      'kaa': '{n} hápte aldın',
      'ru': '{n} нед. назад',
      'de': 'vor {n} Wochen',
    });
    return template.replaceAll('{n}', weeks.toString());
  }

  String get totalTime => _t({
    'uz': "Jami",
    'kaa': "Barlıǵı",
    'ru': "Всего",
    'de': "Gesamt",
  });

  String get activeDays => _t({
    'uz': "Faol kunlar",
    'kaa': "Aktiv kúnler",
    'ru': "Акт. дни",
    'de': "Akt. Tage",
  });

  String get average => _t({
    'uz': "O'rtacha",
    'kaa': "Ortasha",
    'ru': "Средн.",
    'de': "Durchschn.",
  });

  String formatRelativeTime(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) return justNow;
    if (difference.inMinutes < 60) return minutesAgo(difference.inMinutes);
    if (difference.inHours < 24) return hoursAgo(difference.inHours);
    if (difference.inDays < 7) return daysAgo(difference.inDays);
    return '${date.day}/${date.month}/${date.year}';
  }

  String formatChatTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) return justNow;
    if (difference.inHours < 1) return minutesAgo(difference.inMinutes);
    if (difference.inDays < 1) return hoursAgo(difference.inHours);
    if (difference.inDays == 1) return yesterday;
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String minutesAgo(int count) {
    final template = _t({
      'uz': '{n} daqiqa oldin',
      'kaa': '{n} minut aldın',
      'ru': '{n} мин. назад',
      'de': 'vor {n} Min.',
    });
    return template.replaceAll('{n}', count.toString());
  }

  String hoursAgo(int count) {
    final template = _t({
      'uz': '{n} soat oldin',
      'kaa': '{n} saat aldın',
      'ru': '{n} ч. назад',
      'de': 'vor {n} Std.',
    });
    return template.replaceAll('{n}', count.toString());
  }

  String daysAgo(int count) {
    final template = _t({
      'uz': '{n} kun oldin',
      'kaa': '{n} kún aldın',
      'ru': '{n} дн. назад',
      'de': 'vor {n} Tagen',
    });
    return template.replaceAll('{n}', count.toString());
  }

  String conversationSubtitle(String germanTitle) =>
      ConversationTopicsL10n.subtitle(_code, germanTitle);

  // ── Translation ────────────────────────────────────────────────────────────
  String get translationTitle => _t({
    'uz': "TARJIMA",
    'kaa': "AWDARMA",
    'ru': "ПЕРЕВОД",
    'de': "ÜBERSETZUNG",
  });
  String get enterGermanWord => _t({
    'uz': "Nemis so'z yoki ibora kiriting",
    'kaa': "Nemis sóz yamasa ibora kiritiń",
    'ru': "Введите немецкое слово или фразу",
    'de': "Deutsches Wort oder Phrase eingeben",
  });
  String get translationHint => _t({
    'uz': "Masalan: der Tisch, gehen, das Haus...",
    'kaa': "Mysal: der Tisch, gehen, das Haus...",
    'ru': "Например: der Tisch, gehen, das Haus...",
    'de': "z.B.: der Tisch, gehen, das Haus...",
  });
  String get translateButton => _t({
    'uz': "TARJIMA QILISH",
    'kaa': "AWDARMA QILIW",
    'ru': "ПЕРЕВЕСТИ",
    'de': "ÜBERSETZEN",
  });
  String get enterWordToTranslate => _t({
    'uz': "Tarjima olish uchun nemis so'z kiriting",
    'kaa': "Awdarma alıw ushın nemis sóz kiritiń",
    'ru': "Введите немецкое слово для перевода",
    'de': "Geben Sie ein deutsches Wort zum Übersetzen ein",
  });
  String get originalWord => _t({
    'uz': "ASL SO'Z",
    'kaa': "KIRITILGEN SÓZ",
    'ru': "ИСХОДНОЕ СЛОВО",
    'de': "ORIGINALWORT",
  });
  String get meanings => _t({
    'uz': "MA'NOLAR",
    'kaa': "MÁNISLERI",
    'ru': "ЗНАЧЕНИЯ",
    'de': "BEDEUTUNGEN",
  });
  String get example => _t({
    'uz': "MISOL",
    'kaa': "MÍSAL",
    'ru': "ПРИМЕР",
    'de': "BEISPIEL",
  });

  // ── Chat settings ──────────────────────────────────────────────────────────
  String get settings => _t({
    'uz': "Sozlamalar",
    'kaa': "Sazlamalar",
    'ru': "Настройки",
    'de': "Einstellungen",
  });
  String get textSize => _t({
    'uz': "Matn o'lchami",
    'kaa': "Tekst ólshemi",
    'ru': "Размер текста",
    'de': "Textgröße",
  });
  String get playbackSpeed => _t({
    'uz': "Ijro tezligi",
    'kaa': "Atqarıw tezligi",
    'ru': "Скорость воспроизведения",
    'de': "Wiedergabegeschwindigkeit",
  });
  String get autoReadAi => _t({
    'uz': "AI javobini avtomatik o'qish",
    'kaa': "AI juwabın avtomatik oqıw",
    'ru': "Автоозвучка ответа ИИ",
    'de': "KI-Antwort automatisch vorlesen",
  });
  String get openTranslationDefault => _t({
    'uz': "Tarjimani default ochish",
    'kaa': "Awdarmanı hár dayım ashıw",
    'ru': "Перевод открывать по умолчанию",
    'de': "Übersetzung standardmäßig öffnen",
  });
  String get showCorrections => _t({
    'uz': "Correction ko'rsatish",
    'kaa': "Dúzetiwlerdi kórsetiw",
    'ru': "Показывать исправления",
    'de': "Korrekturen anzeigen",
  });
  String get chatLength => _t({
    'uz': "Chat uzunligi",
    'kaa': "Chat uzınlıǵı",
    'ru': "Длина чата",
    'de': "Chat-Länge",
  });
  String chatWordLimit(int limit, int max) {
    final template = _t({
      'uz': '{n} so\'z (maks. {max})',
      'kaa': '{n} sóz (maks. {max})',
      'ru': '{n} слов (макс. {max})',
      'de': '{n} Wörter (max. {max})',
    });
    return template.replaceAll('{n}', '$limit').replaceAll('{max}', '$max');
  }

  String chatMessageLimit(int limit, int max) {
    final template = _t({
      'uz': '{n} ta xabar (maks. {max})',
      'kaa': '{n} xabar (maks. {max})',
      'ru': '{n} сообщений (макс. {max})',
      'de': '{n} Nachrichten (max. {max})',
    });
    return template.replaceAll('{n}', '$limit').replaceAll('{max}', '$max');
  }
  String get selectMentor => _t({
    'uz': "Mentor tanlang",
    'kaa': "Mentor tańlań",
    'ru': "Выберите ментора",
    'de': "Mentor auswählen",
  });
  String get typeHere => _t({
    'uz': "Yozing...",
    'kaa': "Jazıń...",
    'ru': "Напишите...",
    'de': "Schreiben...",
  });
  String get microphoneError => _t({
    'uz': "Mikrofon ishlamadi. Ruxsat berilganligini tekshiring.",
    'kaa': "Mikrofon jumıs istemeydı. Ruxsat berilgenligin tekserıń.",
    'ru': "Микрофон не работает. Проверьте разрешения.",
    'de': "Mikrofon funktioniert nicht. Überprüfen Sie die Berechtigungen.",
  });
  String get errorFound => _t({
    'uz': "Xato topildi",
    'kaa': "Qáte tabıldı",
    'ru': "Найдена ошибка",
    'de': "Fehler gefunden",
  });

  // ── Statistics ─────────────────────────────────────────────────────────────
  String get homeworkCompletion => _t({
    'uz': "Vazifa tugatilishi",
    'kaa': "Tapsırma tamamlanwı",
    'ru': "Выполнение заданий",
    'de': "Aufgabenabschluss",
  });
  String get totalLessons => _t({
    'uz': "Jami darslar",
    'kaa': "Barlıq sabaqlar",
    'ru': "Всего уроков",
    'de': "Lektionen gesamt",
  });
  String get attended => _t({
    'uz': "Qatnashgan",
    'kaa': "Qatnasqan",
    'ru': "Посещено",
    'de': "Teilgenommen",
  });
  String get notAttended => _t({
    'uz': "Qatnashmagan",
    'kaa': "Qatnaspaǵan",
    'ru': "Пропущено",
    'de': "Nicht teilgenommen",
  });
  String get totalHomeworks => _t({
    'uz': "Jami vazifalar",
    'kaa': "Barlıq tapsırmalar",
    'ru': "Всего заданий",
    'de': "Aufgaben gesamt",
  });
  String get completed => _t({
    'uz': "Bajarilgan",
    'kaa': "Orınlanǵan",
    'ru': "Выполнено",
    'de': "Erledigt",
  });
  String get notCompleted => _t({
    'uz': "Bajarilmagan",
    'kaa': "Orınlanbaǵan",
    'ru': "Не выполнено",
    'de': "Nicht erledigt",
  });
  String get totalStars => _t({
    'uz': "Jami yulduzlar",
    'kaa': "Barlıq juldızlar",
    'ru': "Всего звёзд",
    'de': "Sterne gesamt",
  });
  String get currentStreak => _t({
    'uz': "Hozirgi streak",
    'kaa': "Házirgi streak",
    'ru': "Текущая серия",
    'de': "Aktuelle Serie",
  });
  String streakDays(int days) {
    final template = _t({
      'uz': '{n} kun',
      'kaa': '{n} kún',
      'ru': '{n} дн.',
      'de': '{n} Tage',
    });
    return template.replaceAll('{n}', days.toString());
  }
  String scoreOutOf(double score) {
    final template = _t({
      'uz': '{n}/10',
      'kaa': '{n}/10',
      'ru': '{n}/10',
      'de': '{n}/10',
    });
    return template.replaceAll('{n}', score.toStringAsFixed(1));
  }

  // ── Payments ───────────────────────────────────────────────────────────────
  String get paymentsTitle => _t({
    'uz': "TO'LOVLAR",
    'kaa': "TÓLEMLER",
    'ru': "ПЛАТЕЖИ",
    'de': "ZAHLUNGEN",
  });
  String get coursesNotFound => _t({
    'uz': "Kurslar topilmadi",
    'kaa': "Kurslar tabılmadı",
    'ru': "Курсы не найдены",
    'de': "Keine Kurse gefunden",
  });
  String get groupsNotFound => _t({
    'uz': "Guruhlar topilmadi",
    'kaa': "Toparlar tabılmadı",
    'ru': "Группы не найдены",
    'de': "Keine Gruppen gefunden",
  });
  String get noStudentsInGroupPayment => _t({
    'uz': "Guruhda studentlar yo'q",
    'kaa': "Toparda studentlar joq",
    'ru': "В группе нет учеников",
    'de': "Keine Schüler in der Gruppe",
  });
  String get periodUnknown => _t({
    'uz': "Period noma'lum",
    'kaa': "Period belgisiz",
    'ru': "Период неизвестен",
    'de': "Zeitraum unbekannt",
  });
  String get paymentAccepted => _t({
    'uz': "QABUL QILINDI",
    'kaa': "QABUL QÍLÍNDÍ",
    'ru': "ПРИНЯТО",
    'de': "ANGENOMMEN",
  });
  String get paymentRejected => _t({
    'uz': "BEKOR QILINDI",
    'kaa': "BIYKAR QÍLÍNDÍ",
    'ru': "ОТМЕНЕНО",
    'de': "ABGELEHNT",
  });
  String get cash => _t({
    'uz': "NAQD",
    'kaa': "NAQ",
    'ru': "НАЛИЧНЫЕ",
    'de': "BAR",
  });
  String get card => _t({
    'uz': "PLASTIK",
    'kaa': "PLASTIK",
    'ru': "КАРТА",
    'de': "KARTE",
  });
  String get addCashPayment => _t({
    'uz': "NAQD TO'LOV QO'SHISH",
    'kaa': "NAQ TÓLEM QOSÍW",
    'ru': "ДОБАВИТЬ НАЛИЧНЫЙ ПЛАТЁЖ",
    'de': "BARZAHLUNG HINZUFÜGEN",
  });
  String get periodLabel => _t({
    'uz': "PERIOD",
    'kaa': "PERIOD",
    'ru': "ПЕРИОД",
    'de': "ZEITRAUM",
  });
  String get noteLabel => _t({
    'uz': "IZOH",
    'kaa': "TÚSINDIRIW",
    'ru': "КОММЕНТАРИЙ",
    'de': "NOTIZ",
  });
  String get confirmAndSave => _t({
    'uz': "TASDIQLASH VA SAQLASH",
    'kaa': "RASTAW HÁM SAQLAW",
    'ru': "ПОДТВЕРДИТЬ И СОХРАНИТЬ",
    'de': "BESTÄTIGEN UND SPEICHERN",
  });
  String get paymentAlreadyExists => _t({
    'uz': "Bu davr uchun allaqachon to'lov kiritilgan!",
    'kaa': "Bul dáwir ushın álleqashan tólem kiritilgen!",
    'ru': "За этот период платёж уже внесён!",
    'de': "Für diesen Zeitraum wurde bereits gezahlt!",
  });
  String get cashPaymentConfirmed => _t({
    'uz': "Naqd to'lov tasdiqlandi!",
    'kaa': "Naq tólem tastıyqlandı!",
    'ru': "Наличный платёж подтверждён!",
    'de': "Barzahlung bestätigt!",
  });
  String get acceptPayment => _t({
    'uz': "QABUL QILISH",
    'kaa': "QABUL QÍLÍW",
    'ru': "ПРИНЯТЬ",
    'de': "ANNEHMEN",
  });
  String get rejectPayment => _t({
    'uz': "BEKOR QILISH",
    'kaa': "BIYKAR QÍLÍW",
    'ru': "ОТКЛОНИТЬ",
    'de': "ABLEHNEN",
  });
  String get adminNote => _t({
    'uz': "ADMIN IZOHI",
    'kaa': "ADMIN TÚSINDIRMESI",
    'ru': "КОММЕНТАРИЙ АДМИНА",
    'de': "ADMIN-NOTIZ",
  });
  String get paymentAcceptedMsg => _t({
    'uz': "To'lov qabul qilindi!",
    'kaa': "Tólem qabıl qılındı!",
    'ru': "Платёж принят!",
    'de': "Zahlung angenommen!",
  });
  String get paymentRejectedMsg => _t({
    'uz': "To'lov bekor qilindi",
    'kaa': "Tólem biykar qılındı",
    'ru': "Платёж отклонён",
    'de': "Zahlung abgelehnt",
  });
  String get yourPaymentAccepted => _t({
    'uz': "Sizning to'lovingiz qabul qilindi.",
    'kaa': "Siziń tólemińiz qabıl etildi.",
    'ru': "Ваш платёж принят.",
    'de': "Ihre Zahlung wurde angenommen.",
  });
  String paymentRejectedBody(String reason) {
    final template = _t({
      'uz': "Sizning to'lovingiz bekor qilindi. {reason}",
      'kaa': "Siziń tólemińiz biykar qılındı. {reason}",
      'ru': "Ваш платёж отклонён. {reason}",
      'de': "Ihre Zahlung wurde abgelehnt. {reason}",
    });
    return template.replaceAll('{reason}', reason);
  }
  String get reasonPrefix => _t({
    'uz': "Sabab:",
    'kaa': "Sebep:",
    'ru': "Причина:",
    'de': "Grund:",
  });
  String groupStudentsTitle(String groupName) {
    final template = _t({
      'uz': '{name} — STUDENTLAR',
      'kaa': '{name} — STUDENTLAR',
      'ru': '{name} — УЧЕНИКИ',
      'de': '{name} — SCHÜLER',
    });
    return template.replaceAll('{name}', groupName);
  }
  String get pleaseSelectPeriod => _t({
    'uz': "Iltimos, period tanlang",
    'kaa': "Iltimas, period tańlań",
    'ru': "Пожалуйста, выберите период",
    'de': "Bitte Zeitraum wählen",
  });
  String get paymentSubmittedSuccess => _t({
    'uz': "To'lov muvaffaqiyatli yuborildi!",
    'kaa': "Tólem sátli jiberildi!",
    'ru': "Платёж успешно отправлен!",
    'de': "Zahlung erfolgreich gesendet!",
  });
  String get newPaymentReceived => _t({
    'uz': "Yangi to'lov keldi",
    'kaa': "Jańa tólem keldi",
    'ru': "Новый платёж",
    'de': "Neue Zahlung",
  });
  String paymentSentBody(String name, String period) {
    final template = _t({
      'uz': '{name} to\'lov yubordi: {period} davri',
      'kaa': '{name} tólem jiberdi: {period} dáwiri',
      'ru': '{name} отправил платёж: период {period}',
      'de': '{name} hat Zahlung gesendet: Zeitraum {period}',
    });
    return template.replaceAll('{name}', name).replaceAll('{period}', period);
  }
  String get paymentExampleHint => _t({
    'uz': "Masalan: Aprel oyi to'lovi...",
    'kaa': "Mysal: Aprel ayı tólemi...",
    'ru': "Например: оплата за апрель...",
    'de': "z.B.: Zahlung für April...",
  });
  String get cashPaymentExampleHint => _t({
    'uz': "Masalan: Aprel oyi naqd to'lovi...",
    'kaa': "Mysal: Aprel ayı naq tólemi...",
    'ru': "Например: наличная оплата за апрель...",
    'de': "z.B.: Barzahlung für April...",
  });

  // ── Teacher / lessons ────────────────────────────────────────────────────────
  String get deleteLessonTitle => _t({
    'uz': "Darsni o'chirish",
    'kaa': "Sabaqtı óshiriw",
    'ru': "Удалить урок",
    'de': "Lektion löschen",
  });
  String get deleteLessonConfirm => _t({
    'uz': "Rostdan ham ushbu darsni o'chirmoqchimisiz?",
    'kaa': "Shıńında da bul sabaqtı óshirmekshi sizbe?",
    'ru': "Действительно удалить этот урок?",
    'de': "Diese Lektion wirklich löschen?",
  });
  String get deleteUpper => _t({
    'uz': "O'CHIRISH",
    'kaa': "ÓSHIRIW",
    'ru': "УДАЛИТЬ",
    'de': "LÖSCHEN",
  });
  String get cancelUpper => _t({
    'uz': "BEKOR QILISH",
    'kaa': "BIYKAR QÍLÍW",
    'ru': "ОТМЕНА",
    'de': "ABBRECHEN",
  });
  String get editLesson => _t({
    'uz': "DARSNI TAHRIRLASH",
    'kaa': "SABAQTI ÓZGERTIW",
    'ru': "РЕДАКТИРОВАТЬ УРОК",
    'de': "LEKTION BEARBEITEN",
  });
  String get lessonTypeHint => _t({
    'uz': "Yoki o'zingiz yozing (Masalan: Imtihon)",
    'kaa': "Yamasa ózińiz jazıń (Mysal: Imtihon)",
    'ru': "Или введите сами (например: Экзамен)",
    'de': "Oder selbst eingeben (z.B.: Prüfung)",
  });
  String get timeHint => _t({
    'uz': "Vaqt (14:00)",
    'kaa': "Waqıt (14:00)",
    'ru': "Время (14:00)",
    'de': "Uhrzeit (14:00)",
  });
  String get roomHint => _t({
    'uz': "Xona (B1)",
    'kaa': "Xana (B1)",
    'ru': "Аудитория (B1)",
    'de': "Raum (B1)",
  });
  String get attendanceSaved => _t({
    'uz': "Davomat saqlandi ✅",
    'kaa': "Qatnas saqlandı ✅",
    'ru': "Посещаемость сохранена ✅",
    'de': "Anwesenheit gespeichert ✅",
  });
  String taskNumber(int n) {
    final template = _t({
      'uz': 'Vazifa {n}',
      'kaa': 'Tapsırma {n}',
      'ru': 'Задание {n}',
      'de': 'Aufgabe {n}',
    });
    return template.replaceAll('{n}', n.toString());
  }
  String get checkedShort => _t({
    'uz': "Tekshirilgan",
    'kaa': "Tekserilgen",
    'ru': "Проверено",
    'de': "Überprüft",
  });
  String resultCorrect(int correct, int total) {
    final template = _t({
      'uz': 'Natija: {c}/{t} to\'g\'ri',
      'kaa': 'Nátije: {c}/{t} durıs',
      'ru': 'Результат: {c}/{t} верно',
      'de': 'Ergebnis: {c}/{t} richtig',
    });
    return template.replaceAll('{c}', '$correct').replaceAll('{t}', '$total');
  }
  String get submittedUpper => _t({
    'uz': "TOPSHIRDI",
    'kaa': "TOPSHIRDI",
    'ru': "СДАЛ",
    'de': "ABGEGEBEN",
  });
  String get notSubmitted => _t({
    'uz': "YO'Q",
    'kaa': "JOQ",
    'ru': "НЕТ",
    'de': "NEIN",
  });
  String get homeworkNotSubmittedYet => _t({
    'uz': "Hali uy vazifa topshirilmagan",
    'kaa': "Ele úy tapsırması topsırılmagan",
    'ru': "Домашнее задание ещё не сдано",
    'de': "Hausaufgabe noch nicht abgegeben",
  });
  String homeworkDue(String title) {
    final template = _t({
      'uz': 'Uy vazifasi ({title})',
      'kaa': 'Úy tapsırması ({title})',
      'ru': 'Домашнее задание ({title})',
      'de': 'Hausaufgabe ({title})',
    });
    return template.replaceAll('{title}', title);
  }

  // ── Admin / groups ─────────────────────────────────────────────────────────
  String get adminProfile => _t({
    'uz': "ADMIN PROFIL",
    'kaa': "ADMIN PROFIL",
    'ru': "ПРОФИЛЬ АДМИНА",
    'de': "ADMIN-PROFIL",
  });
  String get editProfileCaps => _t({
    'uz': "PROFILNI TAHRIRLASH",
    'kaa': "PROFILDI TAHRIRLEW",
    'ru': "РЕДАКТИРОВАТЬ ПРОФИЛЬ",
    'de': "PROFIL BEARBEITEN",
  });
  String get groupAbout => _t({
    'uz': "GURUH HAQIDA",
    'kaa': "TOPAR HAqqında",
    'ru': "О ГРУППЕ",
    'de': "ÜBER DIE GRUPPE",
  });
  String get groupNameLabel => _t({
    'uz': "Guruh nomi",
    'kaa': "Topar atı",
    'ru': "Название группы",
    'de': "Gruppenname",
  });
  String get studentCountLabel => _t({
    'uz': "Studentlar soni",
    'kaa': "Studentlar sanı",
    'ru': "Количество учеников",
    'de': "Anzahl Schüler",
  });
  String durationMonths(int n) {
    final template = _t({
      'uz': '{n} oy',
      'kaa': '{n} ay',
      'ru': '{n} мес.',
      'de': '{n} Mon.',
    });
    return template.replaceAll('{n}', n.toString());
  }
  String studentRemovedFromGroup(String name) {
    final template = _t({
      'uz': '{name} guruhdan chiqarildi',
      'kaa': '{name} topardan shıǵarıldı',
      'ru': '{name} удалён из группы',
      'de': '{name} aus der Gruppe entfernt',
    });
    return template.replaceAll('{name}', name);
  }
  String studentAddedToGroup(String name) {
    final template = _t({
      'uz': '{name} guruhga qo\'shildi',
      'kaa': '{name} toparǵa qosıldı',
      'ru': '{name} добавлен в группу',
      'de': '{name} zur Gruppe hinzugefügt',
    });
    return template.replaceAll('{name}', name);
  }
  String get teacherAssigned => _t({
    'uz': "O'qituvchi biriktirildi",
    'kaa': "Muǵallim biriktirildi",
    'ru': "Учитель назначен",
    'de': "Lehrer zugewiesen",
  });
  String get newGroup => _t({
    'uz': "YANGI GURUH",
    'kaa': "TÁZE TOPAR",
    'ru': "НОВАЯ ГРУППА",
    'de': "NEUE GRUPPE",
  });
  String get noGroupsYetAdmin => _t({
    'uz': "Hali guruhlar yo'q",
    'kaa': "Ele toparlar joq",
    'ru': "Групп пока нет",
    'de': "Noch keine Gruppen",
  });
  String get teachersNotFound => _t({
    'uz': "Teacherlar topilmadi",
    'kaa': "Muǵallimler tabılmadı",
    'ru': "Учителя не найдены",
    'de': "Keine Lehrer gefunden",
  });
  String get studentsNotFound => _t({
    'uz': "Studentlar topilmadi",
    'kaa': "Studentlar tabılmadı",
    'ru': "Ученики не найдены",
    'de': "Keine Schüler gefunden",
  });
  String get teacherAddedSuccess => _t({
    'uz': "O'qituvchi muvaffaqiyatli qo'shildi!",
    'kaa': "Muǵallim sátli qosıldı!",
    'ru': "Учитель успешно добавлен!",
    'de': "Lehrer erfolgreich hinzugefügt!",
  });
  String get activeGroups => _t({
    'uz': "Faol guruhlar",
    'kaa': "Aktiv toparlar",
    'ru': "Активные группы",
    'de': "Aktive Gruppen",
  });
  String activeGroupsCount(int n) {
    final template = _t({
      'uz': 'Hozirda {n} ta faol guruh mavjud',
      'kaa': 'Házir {n} aktiv topar bar',
      'ru': 'Сейчас {n} активных групп',
      'de': 'Derzeit {n} aktive Gruppen',
    });
    return template.replaceAll('{n}', n.toString());
  }
  String get newTests => _t({
    'uz': "Yangi testlar",
    'kaa': "Jańa testler",
    'ru': "Новые тесты",
    'de': "Neue Tests",
  });
  String get noNewTestsYet => _t({
    'uz': "Hali yangi testlar qo'shilmadi",
    'kaa': "Ele jańa testler qosılmadı",
    'ru': "Новые тесты ещё не добавлены",
    'de': "Noch keine neuen Tests",
  });
  String get paymentControl => _t({
    'uz': "To'lov nazorati",
    'kaa': "Tólem basqarıwı",
    'ru': "Контроль платежей",
    'de': "Zahlungskontrolle",
  });
  String get navTeacher => _t({
    'uz': "Ustoz",
    'kaa': "Muǵallim",
    'ru': "Учитель",
    'de': "Lehrer",
  });
  String get navStudent => _t({
    'uz': "O'quvchi",
    'kaa': "Oqıwshı",
    'ru': "Ученик",
    'de': "Schüler",
  });
  String get navCourse => _t({
    'uz': "Kurs",
    'kaa': "Kurs",
    'ru': "Курс",
    'de': "Kurs",
  });
  String get offline => _t({
    'uz': "Offline",
    'kaa': "Offline",
    'ru': "Офлайн",
    'de': "Offline",
  });
  String get online => _t({
    'uz': "Online",
    'kaa': "Online",
    'ru': "Онлайн",
    'de': "Online",
  });
  String get unknownCourse => _t({
    'uz': "Noma'lum kurs",
    'kaa': "Belgisiz kurs",
    'ru': "Неизвестный курс",
    'de': "Unbekannter Kurs",
  });

  // ── Conversations UI ───────────────────────────────────────────────────────
  String get levelBeginner => _t({
    'uz': "Boshlang'ich",
    'kaa': "Baslanǵısh",
    'ru': "Начальный",
    'de': "Anfänger",
  });
  String get levelElementary => _t({
    'uz': "Elementar",
    'kaa': "Elementar",
    'ru': "Элементарный",
    'de': "Elementar",
  });
  String get levelIntermediate => _t({
    'uz': "O'rta",
    'kaa': "Orta",
    'ru': "Средний",
    'de': "Mittelstufe",
  });
  String get levelUpperIntermediate => _t({
    'uz': "O'rta-Ilg'or",
    'kaa': "Orta-Joqarı",
    'ru': "Выше среднего",
    'de': "Obere Mittelstufe",
  });
  String conversationsLevel(String level) {
    final template = _t({
      'uz': '{level} SUHBATLAR',
      'kaa': '{level} SÓYLESİWLER',
      'ru': 'РАЗГОВОРЫ {level}',
      'de': 'GESPRÄCHE {level}',
    });
    return template.replaceAll('{level}', level);
  }
  String get freeChatPickTopic => _t({
    'uz': "O'zingiz xohlagan mavzuda suhbatlashing",
    'kaa': "Ózińiz xohlagan máwzuda sóylesiń",
    'ru': "Общайтесь на любую тему",
    'de': "Sprechen Sie über jedes Thema",
  });
  String get completedBadge => _t({
    'uz': "TUGALLANGAN",
    'kaa': "TAMAMLANGAN",
    'ru': "ЗАВЕРШЕНО",
    'de': "ABGESCHLOSSEN",
  });
  String get goalTravel => _t({
    'uz': "Sayohat",
    'kaa': "Sayaxat",
    'ru': "Путешествие",
    'de': "Reisen",
  });
  String get goalStudy => _t({
    'uz': "O'qish / Ish",
    'kaa': "Oqıw / Is",
    'ru': "Учёба / Работа",
    'de': "Studium / Arbeit",
  });
  String get goalExam => _t({
    'uz': "Imtihon",
    'kaa': "Imtihan",
    'ru': "Экзамен",
    'de': "Prüfung",
  });
  String get goalDaily => _t({
    'uz': "Kundalik muloqot",
    'kaa': "Kúndelik sóylesiw",
    'ru': "Ежедневное общение",
    'de': "Tägliche Kommunikation",
  });
  String freeChatTitle(String level, String goal) {
    final template = _t({
      'uz': 'Erkin suhbat ({level} - {goal})',
      'kaa': 'Erkin sóylesiw ({level} - {goal})',
      'ru': 'Свободный чат ({level} - {goal})',
      'de': 'Freies Gespräch ({level} - {goal})',
    });
    return template.replaceAll('{level}', level).replaceAll('{goal}', goal);
  }

  // ── Games ──────────────────────────────────────────────────────────────────
  String get easy => _t({
    'uz': "Oson",
    'kaa': "Ańsat",
    'ru': "Лёгкий",
    'de': "Leicht",
  });
  String get medium => _t({
    'uz': "O'rta",
    'kaa': "Orta",
    'ru': "Средний",
    'de': "Mittel",
  });
  String get hard => _t({
    'uz': "Qiyin",
    'kaa': "Qıyın",
    'ru': "Сложный",
    'de': "Schwer",
  });
  String get wrongLabel => _t({
    'uz': "Xato",
    'kaa': "Qáte",
    'ru': "Ошибка",
    'de': "Falsch",
  });
  String get tryAgain => _t({
    'uz': "Qayta urinish",
    'kaa': "Qayta urınıw",
    'ru': "Повторить",
    'de': "Erneut versuchen",
  });
  String get rules => _t({
    'uz': "Qoidalar",
    'kaa': "Qaǵıydalar",
    'ru': "Правила",
    'de': "Regeln",
  });
  String get practiceMore => _t({
    'uz': "Yana mashq qiling!",
    'kaa': "Jáne maqtaq qılıń!",
    'ru': "Потренируйтесь ещё!",
    'de': "Üben Sie weiter!",
  });
  String get learnAgain => _t({
    'uz': "Yana o'rganish",
    'kaa': "Jáne úyreniw",
    'ru': "Учить снова",
    'de': "Nochmal lernen",
  });
  String get exit => _t({
    'uz': "Chiqish",
    'kaa': "Shıǵıw",
    'ru': "Выход",
    'de': "Beenden",
  });
  String correctCount(String correct, String total) {
    final template = _t({
      'uz': "To'g'ri: {c}/{t}",
      'kaa': "Durıs: {c}/{t}",
      'ru': "Верно: {c}/{t}",
      'de': "Richtig: {c}/{t}",
    });
    return template.replaceAll('{c}', correct).replaceAll('{t}', total);
  }
  String get writeStoryHere => _t({
    'uz': "Hikoyani shu yerga yozing...",
    'kaa': "Hikayeni bul jerge jazıń...",
    'ru': "Напишите историю здесь...",
    'de': "Schreiben Sie die Geschichte hier...",
  });
  String wordCount(int n) {
    final template = _t({
      'uz': '{n} so\'z',
      'kaa': '{n} sóz',
      'ru': '{n} слов',
      'de': '{n} Wörter',
    });
    return template.replaceAll('{n}', n.toString());
  }
  String get checkStory => _t({
    'uz': "Hikoyani tekshirish",
    'kaa': "Gúrrińdi tekseriw",
    'ru': "Проверить историю",
    'de': "Geschichte prüfen",
  });
  String get congrats => _t({
    'uz': "Tabriklaymiz!",
    'kaa': "Qutlıqlaymız!",
    'ru': "Поздравляем!",
    'de': "Glückwunsch!",
  });
  String get storyRejected => _t({
    'uz': "Hikoya qabul qilinmadi",
    'kaa': "Gúrriń qabıl etilmadi",
    'ru': "История не принята",
    'de': "Geschichte nicht angenommen",
  });
  String get start => _t({
    'uz': "Boshlash",
    'kaa': "Baslaw",
    'ru': "Начать",
    'de': "Starten",
  });
  String get selectLevel => _t({
    'uz': "Darajani tanlang",
    'kaa': "Dárejeni tańlań",
    'ru': "Выберите уровень",
    'de': "Niveau wählen",
  });
  String categoriesCount(int n) {
    final template = _t({
      'uz': '{n} kategoriya',
      'kaa': '{n} kategoriya',
      'ru': '{n} категорий',
      'de': '{n} Kategorien',
    });
    return template.replaceAll('{n}', n.toString());
  }

  // ── Group / homework UI ────────────────────────────────────────────────────
  String get submittedStatus => _t({
    'uz': "Topshirildi",
    'kaa': "Topshirildi",
    'ru': "Сдано",
    'de': "Abgegeben",
  });
  String get notSubmittedStatus => _t({
    'uz': "Topshirilmagan",
    'kaa': "Tapsırılmaǵan",
    'ru': "Не сдано",
    'de': "Nicht abgegeben",
  });
  String get homeworkSubmittedNotifTitle => _t({
    'uz': "Uy vazifa topshirildi",
    'kaa': "Úyge tapsırma tapsırıldı",
    'ru': "Домашнее задание сдано",
    'de': "Hausaufgabe abgegeben",
  });
  String homeworkSubmittedBody(String student, String group, String date) {
    final template = _t({
      'uz': '{student} {group} guruhida {date} sanasidagi vazifani topshirdi',
      'kaa': '{student} {group} toparında {date} sánesindegi tapsırmanı tapsırdı',
      'ru': '{student} сдал задание в группе {group} за {date}',
      'de': '{student} hat in Gruppe {group} die Aufgabe vom {date} abgegeben',
    });
    return template
        .replaceAll('{student}', student)
        .replaceAll('{group}', group)
        .replaceAll('{date}', date);
  }
  String get answerSent => _t({
    'uz': "Javob yuborildi ✅",
    'kaa': "Juwap jiberildi ✅",
    'ru': "Ответ отправлен ✅",
    'de': "Antwort gesendet ✅",
  });
  String get testAnswersHint => _t({
    'uz': "Javoblar: 1a,2b,3c...",
    'kaa': "Juwaplar: 1a,2b,3c...",
    'ru': "Ответы: 1a,2b,3c...",
    'de': "Antworten: 1a,2b,3c...",
  });
  String get time => _t({
    'uz': "Vaqt",
    'kaa': "Waqıt",
    'ru': "Время",
    'de': "Zeit",
  });
  String get noExtraInfo => _t({
    'uz': "Qo'shimcha ma'lumot yo'q",
    'kaa': "Qosımsha maǵlıwmat joq",
    'ru': "Дополнительной информации нет",
    'de': "Keine zusätzlichen Informationen",
  });
  String get answers => _t({
    'uz': "Javoblar:",
    'kaa': "Juwaplar:",
    'ru': "Ответы:",
    'de': "Antworten:",
  });
  String correctAnswer(String ans) {
    final template = _t({
      'uz': "(To'g'risi: {ans})",
      'kaa': "(Durısı: {ans})",
      'ru': "(Верно: {ans})",
      'de': "(Richtig: {ans})",
    });
    return template.replaceAll('{ans}', ans);
  }
  String get pleaseReLoginShort => _t({
    'uz': "Iltimos, qayta kiring",
    'kaa': "Iltimas, qayta kiriń",
    'ru': "Пожалуйста, войдите снова",
    'de': "Bitte erneut anmelden",
  });
  String get phoneNumber => _t({
    'uz': "Telefon raqam",
    'kaa': "Telefon nomer",
    'ru': "Номер телефона",
    'de': "Telefonnummer",
  });
  String get haveAccountLogin => _t({
    'uz': "Hisobingiz bormi? Kirish",
    'kaa': "Akkauntıńız barma? Kiriw",
    'ru': "Есть аккаунт? Войти",
    'de': "Konto vorhanden? Anmelden",
  });
  String get confirmPassword => _t({
    'uz': "Parolni tasdiqlang",
    'kaa': "Paroldı tastıyıqlań",
    'ru': "Подтвердите пароль",
    'de': "Passwort bestätigen",
  });
  String get phone => _t({
    'uz': "Telefon",
    'kaa': "Telefon",
    'ru': "Телефон",
    'de': "Telefon",
  });
  String get test => _t({
    'uz': "TEST",
    'kaa': "TEST",
    'ru': "ТЕСТ",
    'de': "TEST",
  });
  String get comingSoonGame => _t({
    'uz': "Tez orada",
    'kaa': "Tez arada",
    'ru': "Скоро",
    'de': "Demnächst",
  });
  String get paymentHistoryEmpty => _t({
    'uz': "To'lov tarixi yo'q",
    'kaa': "Tólem tariyxı joq",
    'ru': "Истории платежей нет",
    'de': "Keine Zahlungshistorie",
  });
  String get receiptUploadFailed => _t({
    'uz': "Chek yuklanmadi",
    'kaa': "Chek júklenbegen",
    'ru': "Чек не загружен",
    'de': "Beleg nicht hochgeladen",
  });
  String get durationMonthsLabel => _t({
    'uz': "Davomiyligi (oy soni)",
    'kaa': "Dawamlılıǵı (ay sanı)",
    'ru': "Длительность (месяцев)",
    'de': "Dauer (Monate)",
  });
  String get searchHint => _t({
    'uz': "Qidirish...",
    'kaa': "Izlew...",
    'ru': "Поиск...",
    'de': "Suchen...",
  });
  String get paymentPending => _t({
    'uz': "KUTILMOQDA",
    'kaa': "KÚTILMEKTE",
    'ru': "ОЖИДАНИЕ",
    'de': "AUSSTEHEND",
  });
  // ── Extra keys for localization ────────────────────────────────────────────
  String get studentsShort => _t({'uz': "O'quvchi", 'kaa': "Oqıwshı", 'ru': "Ученик", 'de': "Schüler"});
  String get lessonsShort => _t({'uz': "Darslar", 'kaa': "Sabaqlar", 'ru': "Уроки", 'de': "Stunden"});
  String get remainingShort => _t({'uz': "ta qoldi", 'kaa': "ta qaldı", 'ru': "осталось", 'de': "verbleibend"});
  String get submittedShort => _t({'uz': "topshirilgan", 'kaa': "tapsırılǵan", 'ru': "сдано", 'de': "eingereicht"});
  String get checkUpper => _t({'uz': "TEKSHIRISH", 'kaa': "TEKSERIW", 'ru': "ПРОВЕРИТЬ", 'de': "PRÜFEN"});
  String get submittedUpper2 => _t({'uz': "TOPSHIRDI", 'kaa': "TOPSHIRDI", 'ru': "СДАЛ", 'de': "ABGEGEBEN"});
  String get notSubmittedShort => _t({'uz': "YO'Q", 'kaa': "JOQ", 'ru': "НЕТ", 'de': "NEIN"});
  String get checkedUpper => _t({'uz': "TEKSHIRILDI", 'kaa': "TEKSERILDI", 'ru': "ПРОВЕРЕНО", 'de': "GEPRÜFT"});
  String get checkedShortMark => _t({'uz': "✓ Tekshirilgan", 'kaa': "✓ Tekserilgen", 'ru': "✓ Проверено", 'de': "✓ Geprüft"});
  String get noCoursesFound => _t({'uz': "Kurslar yo'q", 'kaa': "Kurslar joq", 'ru': "Курсов нет", 'de': "Keine Kurse"});
  String get homeworkDefault => _t({'uz': "Uy vazifa", 'kaa': "Úy tapsırması", 'ru': "Домашнее задание", 'de': "Hausaufgabe"});
  String get pleaseReLoginShort2 => _t({'uz': "Iltimos, qayta kiring", 'kaa': "Iltimas, qayta kiriń", 'ru': "Пожалуйста, войдите снова", 'de': "Bitte erneut anmelden"});
  String get noHomeworkSubmittedYet => _t({'uz': "Hali uy vazifa topshirilmagan", 'kaa': "Ele úy tapsırması topsırılmagan", 'ru': "Домашнее задание ещё не сдано", 'de': "Hausaufgabe noch nicht abgegeben"});
  String get changeTeacher => _t({'uz': "O'ZGARTIRISH", 'kaa': "ÓZGERTIRIW", 'ru': "ИЗМЕНИТЬ", 'de': "ÄNDERN"});
  String get notAssigned => _t({'uz': "Biriktirilmagan", 'kaa': "Biriktirilmegen", 'ru': "Не назначен", 'de': "Nicht zugewiesen"});
  String get noStudentsAddedYet => _t({'uz': "Hali studentlar qo'shilmagan", 'kaa': "Ele studentlar qosılmagan", 'ru': "Студентов пока нет", 'de': "Noch keine Schüler"});
  String get groupAboutHeader => _t({'uz': "GURUH HAQIDA ℹ️", 'kaa': "TOPAR HAQQINDA ℹ️", 'ru': "О ГРУППЕ ℹ️", 'de': "ÜBER DIE GRUPPE ℹ️"});
  String get teacherHeader => _t({'uz': "O'QITUVCHI 👨‍🏫", 'kaa': "MUǴALLIM 👨‍🏫", 'ru': "УЧИТЕЛЬ 👨‍🏫", 'de': "LEHRER 👨‍🏫"});
  String get studentsHeader => _t({'uz': "STUDENTLAR 🧑‍🎓", 'kaa': "STUDENTLAR 🧑‍🎓", 'ru': "УЧЕНИКИ 🧑‍🎓", 'de': "SCHÜLER 🧑‍🎓"});
  String get groupNameInfo => _t({'uz': "Guruh nomi", 'kaa': "Topar atı", 'ru': "Название группы", 'de': "Gruppenname"});
  String get startedInfo => _t({'uz': "Boshlangan", 'kaa': "Baslanǵan", 'ru': "Начато", 'de': "Gestartet"});
  String get durationInfo => _t({'uz': "Davomiyligi", 'kaa': "Dawamlılıǵı", 'ru': "Продолжительность", 'de': "Dauer"});
  String get studentCountInfo => _t({'uz': "Studentlar soni", 'kaa': "Studentlar sanı", 'ru': "Количество учеников", 'de': "Anzahl Schüler"});
  String get newGroupTitle => _t({'uz': "YANGI GURUH ➕", 'kaa': "TÁZE TOPAR ➕", 'ru': "НОВАЯ ГРУППА ➕", 'de': "NEUE GRUPPE ➕"});
  String get groupNameHint => _t({'uz': "Guruh nomi", 'kaa': "Topar atı", 'ru': "Название группы", 'de': "Gruppenname"});
  String get selectStartDate => _t({'uz': "Boshlangan sana tanlang", 'kaa': "Baslanǵan sáne tańlań", 'ru': "Выберите дату начала", 'de': "Startdatum wählen"});
  String get durationMonthsHint => _t({'uz': "Davomiyligi (oy soni)", 'kaa': "Dawamlılıǵı (ay sanı)", 'ru': "Длительность (месяцев)", 'de': "Dauer (Monate)"});
  String get selectColor => _t({'uz': "RANG TANLANG", 'kaa': "REŃDI TAŃLAŃ", 'ru': "ВЫБЕРИТЕ ЦВЕТ", 'de': "FARBE WÄHLEN"});
  String get studentsInfoLabel => _t({'uz': "Studentlar", 'kaa': "Studentlar", 'ru': "Ученики", 'de': "Schüler"});
  String get startedInfoLabel => _t({'uz': "Boshlangan", 'kaa': "Baslanǵan", 'ru': "Начато", 'de': "Gestartet"});
  String get durationInfoLabel => _t({'uz': "Davomiyligi", 'kaa': "Dawamlılıǵı", 'ru': "Продолжительность", 'de': "Dauer"});
  String get noGroupsYet => _t({'uz': "Hali guruhlar yo'q", 'kaa': "Ele toparlar joq", 'ru': "Групп пока нет", 'de': "Noch keine Gruppen"});
  String get unknownGroup => _t({'uz': "Noma'lum", 'kaa': "Belgisiz", 'ru': "Неизвестно", 'de': "Unbekannt"});
  String get addedToGroup => _t({'uz': "guruhga qo'shildi", 'kaa': "toparǵa qosıldı", 'ru': "добавлен в группу", 'de': "zur Gruppe hinzugefügt"});
  String get removedFromGroup => _t({'uz': "guruhdan chiqarildi", 'kaa': "topardan shıǵarıldı", 'ru': "удалён из группы", 'de': "aus der Gruppe entfernt"});
  String get activeGroupsLabel => _t({'uz': "Faol guruhlar", 'kaa': "Aktiv toparlar", 'ru': "Активные группы", 'de': "Aktive Gruppen"});
  String get newTestsLabel => _t({'uz': "Yangi testlar", 'kaa': "Jańa testler", 'ru': "Новые тесты", 'de': "Neue Tests"});
  String get noNewTestsLabel => _t({'uz': "Hali yangi testlar qo'shilmadi", 'kaa': "Ele jańa testler qosılmadı", 'ru': "Новые тесты ещё не добавлены", 'de': "Noch keine neuen Tests"});
  String get paymentControlLabel => _t({'uz': "To'lov nazorati", 'kaa': "Tólem basqarıwı", 'ru': "Контроль платежей", 'de': "Zahlungskontrolle"});
  String get allPaymentsConfirmed => _t({'uz': "Barcha to'lovlar tasdiqlangan", 'kaa': "Barlıq tólemler tastıyqlanǵan", 'ru': "Все платежи подтверждены", 'de': "Alle Zahlungen bestätigt"});
  String pendingPaymentsCount(int n) {
    final template = _t({'uz': '{n} ta to\'lov tasdiqlanishi kutilmoqda', 'kaa': '{n} tólem tastıyqlanıwı kútilmekte', 'ru': '{n} платежей ожидают подтверждения', 'de': '{n} Zahlungen warten auf Bestätigung'});
    return template.replaceAll('{n}', n.toString());
  }
  String get receiptAttached => _t({'uz': "Chek biriktirilgan", 'kaa': "Chek biriktirilgen", 'ru': "Чек прикреплён", 'de': "Beleg angehängt"});
  String get receiptNotAttached => _t({'uz': "Chek biriktirilmagan", 'kaa': "Chek biriktirilmegen", 'ru': "Чек не прикреплён", 'de': "Kein Beleg"});
  String get tapToZoom => _t({'uz': "Kattalashtirish uchun bosing", 'kaa': "Úlkeytiw ushın basıń", 'ru': "Нажмите для увеличения", 'de': "Zum Vergrößern tippen"});
  String get cashPaymentPending => _t({'uz': "Naqd to'lov — tasdiqlash kutilmoqda", 'kaa': "Naq tólem — tastıyqlawı kútilmekte", 'ru': "Наличный платёж — ожидает подтверждения", 'de': "Barzahlung — wartet auf Bestätigung"});
  String get addedByAdmin => _t({'uz': "Admin tomonidan qo'shildi", 'kaa': "Admin tárepinen qosıldı", 'ru': "Добавлено администратором", 'de': "Vom Admin hinzugefügt"});
  String get studentCountSuffix => _t({'uz': "ta student", 'kaa': "student", 'ru': "учеников", 'de': "Schüler"});
  String get cardPaymentType => _t({'uz': "PLASTIK (KARTA)", 'kaa': "PLASTIK (KARTA)", 'ru': "КАРТА", 'de': "KARTE"});
  String get whichArticle => _t({'uz': "Qaysi artikl?", 'kaa': "Qaysı artikl?", 'ru': "Какой артикль?", 'de': "Welcher Artikel?"});
  String consecutiveStreak(int n) {
    final template = _t({'uz': 'Ketma-ket: {n} 🔥', 'kaa': 'Ketme-ket: {n} 🔥', 'ru': 'Подряд: {n} 🔥', 'de': 'Hintereinander: {n} 🔥'});
    return template.replaceAll('{n}', n.toString());
  }
  String get roundFinished => _t({'uz': "RAUND YAKUNLANDI", 'kaa': "RAUND TAMAMLANDI", 'ru': "РАУНД ЗАВЕРШЁН", 'de': "RUNDE BEENDET"});
  String get playAgain => _t({'uz': "YANA O'YNASH", 'kaa': "JÁNE OYLAW", 'ru': "ИГРАТЬ СНОВА", 'de': "NOCHMAL SPIELEN"});
  String get backUpper => _t({'uz': "ORQAGA", 'kaa': "ARTQA", 'ru': "НАЗАД", 'de': "ZURÜCK"});
  String get articleRules => _t({'uz': "ARTIKL QOIDALARI", 'kaa': "ARTIKL QAǴIYDALARI", 'ru': "ПРАВИЛА АРТИКЛЕЙ", 'de': "ARTIKELREGELN"});
  String get memoryTips => _t({'uz': "ESDA SAQLASH UCHUN", 'kaa': "ESDE SAQLAW USHIN", 'ru': "ДЛЯ ЗАПОМИНАНИЯ", 'de': "ZUM MERKEN"});
  String get startGame => _t({'uz': "O'YINNI BOSHLASH", 'kaa': "OYINDI BASLAW", 'ru': "НАЧАТЬ ИГРУ", 'de': "SPIEL STARTEN"});
  String get quickArticleLearn => _t({'uz': "Artiklarni tez tanish", 'kaa': "Artikllerdi tez tanıw", 'ru': "Быстрое изучение артиклей", 'de': "Artikel schnell lernen"});
  String get derDieDasLearningTitle => _t({'uz': "Der, Die, Das - O'rganish", 'kaa': "Der, Die, Das - Úyreniw", 'ru': "Der, Die, Das - Обучение", 'de': "Der, Die, Das - Lernen"});
  String get nextUpper => _t({'uz': "KEYINGI", 'kaa': "KEYINGI", 'ru': "ДАЛЕЕ", 'de': "WEITER"});
  String get roundCompleted => _t({'uz': "Raund yakunlandi!", 'kaa': "Raund tamamlandı!", 'ru': "Раунд завершён!", 'de': "Runde abgeschlossen!"});
  String get accuracyLabel => _t({'uz': "Aniqlik", 'kaa': "Anıqlıq", 'ru': "Точность", 'de': "Genauigkeit"});
  String accuracyPercent(int n) {
    final template = _t({'uz': 'Aniqlik: {n}%', 'kaa': 'Anıqlıq: {n}%', 'ru': 'Точность: {n}%', 'de': 'Genauigkeit: {n}%'});
    return template.replaceAll('{n}', n.toString());
  }
  String correctWrong(int correct, int wrong) {
    final template = _t({'uz': "To'g'ri: {c} | Xato: {w}", 'kaa': "Durıs: {c} | Qáte: {w}", 'ru': "Верно: {c} | Ошибок: {w}", 'de': "Richtig: {c} | Falsch: {w}"});
    return template.replaceAll('{c}', correct.toString()).replaceAll('{w}', wrong.toString());
  }
  String get learnAgainBtn => _t({'uz': "Yana o'rganish", 'kaa': "Jáne úyreniw", 'ru': "Учить снова", 'de': "Nochmal lernen"});
  String get exitBtn => _t({'uz': "Chiqish", 'kaa': "Shıǵıw", 'ru': "Выход", 'de': "Beenden"});
  String get grammarTitle => _t({'uz': "Grammatika", 'kaa': "Grammatika", 'ru': "Грамматика", 'de': "Grammatik"});
  String get selectLevelHint => _t({'uz': "Darajani tanlang", 'kaa': "Dárejeni tańlań", 'ru': "Выберите уровень", 'de': "Niveau wählen"});
  String get grammarLevelsSubtitle => _t({'uz': "A1, A2, B1, B2 darajalari", 'kaa': "A1, A2, B1, B2 dárejeleri", 'ru': "Уровни A1, A2, B1, B2", 'de': "Niveaus A1, A2, B1, B2"});
  String get sprechenAiTitle => _t({'uz': "Sprechen AI", 'kaa': "Sprechen AI", 'ru': "Sprechen AI", 'de': "Sprechen AI"});
  String get horenTitle => _t({'uz': "Hören", 'kaa': "Hören", 'ru': "Hören", 'de': "Hören"});
  String get schreibenShort => _t({'uz': "Schreiben", 'kaa': "Schreiben", 'ru': "Schreiben", 'de': "Schreiben"});
  String get grammarShort => _t({'uz': "Grammatika", 'kaa': "Grammatika", 'ru': "Грамматика", 'de': "Grammatik"});
  String get timeLabel => _t({'uz': "Vaqt", 'kaa': "Waqıt", 'ru': "Время", 'de': "Zeit"});
  String get noteLabel2 => _t({'uz': "IZOH", 'kaa': "TÚSINDIRIW", 'ru': "КОММЕНТАРИЙ", 'de': "NOTIZ"});
  String testResultLabel(int correct, int total) {
    final template = _t({'uz': 'Test: {c}/{t} to\'g\'ri', 'kaa': 'Test: {c}/{t} durıs', 'ru': 'Тест: {c}/{t} верно', 'de': 'Test: {c}/{t} richtig'});
    return template.replaceAll('{c}', correct.toString()).replaceAll('{t}', total.toString());
  }
  String get answersLabel => _t({'uz': "Javoblar:", 'kaa': "Juwaplar:", 'ru': "Ответы:", 'de': "Antworten:"});
  String correctAnswerLabel(String ans) {
    final template = _t({'uz': "(To'g'risi: {ans})", 'kaa': "(Durısı: {ans})", 'ru': "(Верно: {ans})", 'de': "(Richtig: {ans})"});
    return template.replaceAll('{ans}', ans);
  }
  String get noExtraInfoLabel => _t({'uz': "Qo'shimcha ma'lumot yo'q", 'kaa': "Qosımsha maǵlıwmat joq", 'ru': "Дополнительной информации нет", 'de': "Keine zusätzlichen Informationen"});
  String get storyGameTitle => _t({'uz': "Hikoya O'YINI", 'kaa': "Hikaye OYINI", 'ru': "ИГРА ИСТОРИЯ", 'de': "GESCHICHTENSPIEL"});
  String get storyRulesTitle => _t({'uz': "QOIDALAR:", 'kaa': "QAǴIYDALAR:", 'ru': "ПРАВИЛА:", 'de': "REGELN:"});
  String get storyLoadingWords => _t({'uz': "So'zlar yuklanmoqda...", 'kaa': "Sózler júkleniwde...", 'ru': "Слова загружаются...", 'de': "Wörter werden geladen..."});
  String get storyWritePrompt => _t({'uz': "Quyidagi so'zlardan foydalanib hikoya yozing:", 'kaa': "Tómendegi sózlerden paydalanıp hikaye jazıń:", 'ru': "Напишите историю, используя следующие слова:", 'de': "Schreiben Sie eine Geschichte mit folgenden Wörtern:"});
  String get storyThemeLabel => _t({'uz': "Mavzu:", 'kaa': "Máwzu:", 'ru': "Тема:", 'de': "Thema:"});
  String storyLengthHint(int min, int max) {
    final template = _t({'uz': 'Hikoya uzunligi: {min}-{max} so\'z', 'kaa': 'Hikaye uzınlıǵı: {min}-{max} sóz', 'ru': 'Длина истории: {min}-{max} слов', 'de': 'Länge der Geschichte: {min}-{max} Wörter'});
    return template.replaceAll('{min}', min.toString()).replaceAll('{max}', max.toString());
  }
  String get storyHintText => _t({'uz': "Hikoyani shu yerga yozing...", 'kaa': "Hikayeni bul jerge jazıń...", 'ru': "Напишите историю здесь...", 'de': "Schreiben Sie die Geschichte hier..."});
  String get checkStoryBtn => _t({'uz': "Hikoyani Tekshirish", 'kaa': "Hikayeni Tekseriw", 'ru': "Проверить историю", 'de': "Geschichte prüfen"});
  String get newStory => _t({'uz': "Yangi hikoya", 'kaa': "Jańa hikaye", 'ru': "Новая история", 'de': "Neue Geschichte"});
  String get scoreLabel => _t({'uz': "Ball:", 'kaa': "Ball:", 'ru': "Балл:", 'de': "Punkte:"});
  String get wordCountResult => _t({'uz': "So'zlar soni:", 'kaa': "Sózler sanı:", 'ru': "Количество слов:", 'de': "Wortanzahl:"});
  String get storyDifficultyLabel => _t({'uz': "Darajani tanlang:", 'kaa': "Dárejeni tańlań:", 'ru': "Выберите уровень:", 'de': "Schwierigkeit wählen:"});
  String get easyLabel => _t({'uz': "Oson", 'kaa': "Oson", 'ru': "Лёгкий", 'de': "Leicht"});
  String get mediumLabel => _t({'uz': "O'rtacha", 'kaa': "Orta", 'ru': "Средний", 'de': "Mittel"});
  String get hardLabel => _t({'uz': "Qiyin", 'kaa': "Qıyın", 'ru': "Сложный", 'de': "Schwer"});
  String get startBtn => _t({'uz': "Boshlash", 'kaa': "Baslaw", 'ru': "Начать", 'de': "Starten"});
  String get closeBtn => _t({'uz': "Yopish", 'kaa': "Jabıw", 'ru': "Закрыть", 'de': "Schließen"});
  String get thisRound => _t({'uz': "Bu raund", 'kaa': "Bul raund", 'ru': "Этот раунд", 'de': "Diese Runde"});
  String get totalStarsLabel => _t({'uz': "Jami yulduz", 'kaa': "Barlıq juldız", 'ru': "Всего звёзд", 'de': "Sterne gesamt"});
  String get correctLabel => _t({'uz': "To'g'ri", 'kaa': "Durıs", 'ru': "Верно", 'de': "Richtig"});
  String get wrongLabelShort => _t({'uz': "Xato", 'kaa': "Qáte", 'ru': "Ошибок", 'de': "Falsch"});
  String get accuracyShort => _t({'uz': "Aniqlik", 'kaa': "Anıqlıq", 'ru': "Точность", 'de': "Genauigkeit"});
  String get storyRuleItem1 => _t({'uz': "1. Berilgan so'zlardan foydalanib hikoya yozing", 'kaa': "1. Berilgen sózlerden paydalanıp gúrriń jazıń", 'ru': "1. Напишите историю, используя данные слова", 'de': "1. Schreiben Sie eine Geschichte mit den gegebenen Wörtern"});
  String get storyRuleItem2 => _t({'uz': "2. Otlarning artiklini o'zgartirishingiz mumkin (masalan: das Buch → ein Buch)", 'kaa': "2. Atlıqlardıń artiklın ózgertiwińiz múmkin (mysal: das Buch → ein Buch)", 'ru': "2. Можно изменять артикль существительных (например: das Buch → ein Buch)", 'de': "2. Sie können den Artikel der Nomen ändern (z.B.: das Buch → ein Buch)"});
  String get storyRuleItem3 => _t({'uz': "3. Fe'llarni turli shakllarda ishlatishingiz mumkin (masalan: lesen → ich lese)", 'kaa': "3. Feyillerdi túrli formalarda isletiwińiz múmkin (mysal: lesen → ich lese)", 'ru': "3. Глаголы можно использовать в разных формах (например: lesen → ich lese)", 'de': "3. Verben können in verschiedenen Formen verwendet werden (z.B.: lesen → ich lese)"});
  String get storyRuleItem4 => _t({'uz': "4. Hikoya uzunligi berilgan oraliqda bo'lishi kerak", 'kaa': "4. Gúrriń uzınlıǵı berilgen aralıqta bolıwı kerek", 'ru': "4. Длина истории должна быть в указанном диапазоне", 'de': "4. Die Länge der Geschichte muss im angegebenen Bereich liegen"});
  String get storyRuleItem5 => _t({'uz': "5. Grammatik jihatdan to'g'ri bo'lishi kerak", 'kaa': "5. Grammatikalıq jaqtan durıs bolıwı kerek", 'ru': "5. Должна быть грамматически правильной", 'de': "5. Muss grammatisch korrekt sein"});
  String get storyRuleItem6 => _t({'uz': "6. Mantiqan bog'liq hikoya yozing", 'kaa': "6. Logikalıq baylanıslı gúrriń jazıń", 'ru': "6. Напишите логически связную историю", 'de': "6. Schreiben Sie eine logisch zusammenhängende Geschichte"});

  // ── Additional keys for remaining hardcoded strings ────────────────────────
  String get editLessonTitle => _t({'uz': "DARSNI TAHRIRLASH", 'kaa': "SABAQTI ÓZGERTIRIW", 'ru': "РЕДАКТИРОВАТЬ УРОК", 'de': "LEKTION BEARBEITEN"});
  String get timeHintLabel => _t({'uz': "Vaqt (14:00)", 'kaa': "Waqıt (14:00)", 'ru': "Время (14:00)", 'de': "Zeit (14:00)"});
  String get roomHintLabel => _t({'uz': "Xona (B1)", 'kaa': "Bólme (B1)", 'ru': "Комната (B1)", 'de': "Raum (B1)"});
  String taskNumberLabel(int n) {
    final template = _t({'uz': 'Vazifa {n}', 'kaa': 'Tapsırma {n}', 'ru': 'Задание {n}', 'de': 'Aufgabe {n}'});
    return template.replaceAll('{n}', n.toString());
  }
  String get categoriesCountLabel => _t({'uz': "kategoriya", 'kaa': "kategoriya", 'ru': "категория", 'de': "Kategorie"});
  String get monthsLabel => _t({'uz': "oy", 'kaa': "ay", 'ru': "мес.", 'de': "Mon."});
  String get addPaymentTitle => _t({'uz': "TO'LOV QO'SHISH", 'kaa': "TÓLEM QOSIW", 'ru': "ДОБАВИТЬ ПЛАТЕЖ", 'de': "ZAHLUNG HINZUFÜGEN"});
  String get selectPeriod => _t({'uz': "PERIOD TANLANG", 'kaa': "PERIOD TAŇLAŃ", 'ru': "ВЫБЕРИТЕ ПЕРИОД", 'de': "PERIODE AUSWÄHLEN"});
  String get paymentNoteHint => _t({'uz': "Masalan: Aprel oyi to'lovi...", 'kaa': "Mysal: Aprel aýı tólewi...", 'ru': "Например: оплата за апрель...", 'de': "Zum Beispiel: Zahlung für April..."});
  String get attachReceipt => _t({'uz': "CHEK BIRIKTIRISH", 'kaa': "CHEK BIRIKTIRIW", 'ru': "ПРИКРЕПИТЬ ЧЕК", 'de': "BELEG ANHÄNGEN"});
  String get receiptAttachedCaps => _t({'uz': "CHEK BIRIKTIRILDI ✓", 'kaa': "CHEK BIRIKTIRILDI ✓", 'ru': "ЧЕК ПРИКРЕПЛЕН ✓", 'de': "BELEG ANGEHÄNGT ✓"});
  String get selectReceiptImage => _t({'uz': "CHEK RASMINI TANLANG", 'kaa': "CHEK SÚWRETIN TAŇLAŃ", 'ru': "ВЫБЕРИТЕ ИЗОБРАЖЕНИЕ ЧЕКА", 'de': "BELEG-BILD AUSWÄHLEN"});
  String get selectFromGalleryCamera => _t({'uz': "Galereya yoki kameradan tanlang", 'kaa': "Galereya yamasa kameradan tańlań", 'ru': "Выберите из галереи или камеры", 'de': "Aus Galerie oder Kamera auswählen"});
  String get submitBtn => _t({'uz': "YUBORISH", 'kaa': "JIBERIW", 'ru': "ОТПРАВИТЬ", 'de': "SENDEN"});
  String get adminLabel => _t({'uz': "Admin", 'kaa': "Admin", 'ru': "Админ", 'de': "Admin"});
  String get adminNoteLabel => _t({'uz': "ADMIN IZOHI", 'kaa': "ADMIN TÚSINDIRMESI", 'ru': "ЗАМЕТКА АДМИНА", 'de': "ADMIN-NOTIZ"});
  String get cardWithParentheses => _t({'uz': "PLASTIK (KARTA)", 'kaa': "PLASTIK (KARTA)", 'ru': "ПЛАСТИК (КАРТА)", 'de': "PLASTIK (KARTE)"});
  String homeworkTitleLabel(int n) {
    final template = _t({'uz': 'Uy vazifa {n}', 'kaa': 'Úyge tapsırma {n}', 'ru': 'Домашнее задание {n}', 'de': 'Hausaufgabe {n}'});
    return template.replaceAll('{n}', n.toString());
  }
  String get cashLabel => _t({'uz': "NAQD", 'kaa': "NAQ", 'ru': "НАЛИЧНЫЕ", 'de': "BAR"});
  String get cardLabel => _t({'uz': "PLASTIK", 'kaa': "PLASTIK", 'ru': "КАРТА", 'de': "KARTE"});
  String studentsCountShort(int n) {
    final template = _t({'uz': '{n} ta', 'kaa': '{n} dana', 'ru': '{n} уч.', 'de': '{n} Sch.'});
    return template.replaceAll('{n}', n.toString());
  }
  String studentAddedToGroupMsg(String name) {
    final template = _t({'uz': '{name} guruhga qo\'shildi', 'kaa': '{name} toparǵa qosıldı', 'ru': '{name} добавлен в группу', 'de': '{name} zur Gruppe hinzugefügt'});
    return template.replaceAll('{name}', name);
  }
  String studentRemovedFromGroupMsg(String name) {
    final template = _t({'uz': '{name} guruhdan chiqarildi', 'kaa': '{name} topardan shıǵarıldı', 'ru': '{name} удалён из группы', 'de': '{name} aus der Gruppe entfernt'});
    return template.replaceAll('{name}', name);
  }
  String activeGroupsCountText(int n) {
    final template = _t({'uz': '{n} ta faol guruh', 'kaa': '{n} aktiv topar', 'ru': '{n} активных групп', 'de': '{n} aktive Gruppen'});
    return template.replaceAll('{n}', n.toString());
  }

  // ── Hören ──────────────────────────────────────────────────────────────────
  String get horenScreenTitle => _t({'uz': "Hören", 'kaa': "Hören", 'ru': "Hören", 'de': "Hören"});
  String get horenSelectLevel => _t({'uz': "Daraja tanlang", 'kaa': "Dárejeni tańlań", 'ru': "Выберите уровень", 'de': "Niveau wählen"});
  String get horenComingSoon => _t({'uz': "Tez kunda", 'kaa': "Tez arада", 'ru': "Скоро", 'de': "Demnächst"});
  String get horenComingSoonDesc => _t({'uz': "Bu daraja uchun materiallar tayyorlanmoqda", 'kaa': "Bul dareje ushın materiallar tayarlanıwda", 'ru': "Материалы для этого уровня готовятся", 'de': "Materialien für dieses Niveau werden vorbereitet"});
  String get horenTeil1Title => _t({'uz': "Teil 1 – Qisqa Suhbatlar", 'kaa': "Teil 1 – Qısqa Sóylesiw", 'ru': "Teil 1 – Короткие разговоры", 'de': "Teil 1 – Kurze Gespräche"});
  String get horenTeil1Desc => _t({'uz': "Qisqa suhbatni tinglang va to'g'ri javobni tanlang", 'kaa': "Qısqa sóylesiwdi tıńlań hám durıs jawaptı tańlań", 'ru': "Прослушайте короткий разговор и выберите правильный ответ", 'de': "Hören Sie den kurzen Dialog und wählen Sie die richtige Antwort"});
  String get horenTeil1Note => _t({'uz': "Haqiqiy imtihonda audio 2 marta o'ynatiladi", 'kaa': "Haqıyqıy imtihanda audio 2 ret oynatıladı", 'ru': "На реальном экзамене аудио воспроизводится 2 раза", 'de': "In der echten Prüfung wird das Audio 2 Mal abgespielt"});
  String get horenTeil2Title => _t({'uz': "Teil 2 – E'lonlar", 'kaa': "Teil 2 – Xabarlar", 'ru': "Teil 2 – Объявления", 'de': "Teil 2 – Durchsagen"});
  String get horenTeil2Desc => _t({'uz': "Vokzal, aeroportdagi e'lonlarni tinglang va Richtig/Falsch deb belgilang", 'kaa': "Vokzal, aeroporttaǵı xabarlardı tıńlań hám Richtig/Falsch dep belgilań", 'ru': "Слушайте объявления на вокзале, в аэропорту и отмечайте Richtig/Falsch", 'de': "Hören Sie Durchsagen am Bahnhof, Flughafen usw. und markieren Sie Richtig/Falsch"});
  String get horenTeil2Note => _t({'uz': "Haqiqiy imtihonda audio faqat 1 marta o'ynatiladi", 'kaa': "Haqıyqıy imtihanda audio tek 1 ret oynatıladı", 'ru': "На реальном экзамене аудио воспроизводится только 1 раз", 'de': "In der echten Prüfung wird das Audio nur 1 Mal abgespielt"});
  String get horenTeil3Title => _t({'uz': "Teil 3 – Qisqa Xabarlar", 'kaa': "Teil 3 – Qısqa Xabarlar", 'ru': "Teil 3 – Короткие сообщения", 'de': "Teil 3 – Kurze Mitteilungen"});
  String get horenTeil3Desc => _t({'uz': "Qisqa xabar yoki e'lonni tinglang va savolga javob bering", 'kaa': "Qısqa xabar yamasa xabarlardı tıńlań hám sorawǵa jawap beriń", 'ru': "Прослушайте короткое сообщение или объявление и ответьте на вопрос", 'de': "Hören Sie die kurze Mitteilung und beantworten Sie die Frage"});
  String get horenTeil3Note => _t({'uz': "Haqiqiy imtihonda audio 2 marta o'ynatiladi", 'kaa': "Haqıyqıy imtihanda audio 2 ret oynatıladı", 'ru': "На реальном экзамене аудио воспроизводится 2 раза", 'de': "In der echten Prüfung wird das Audio 2 Mal abgespielt"});
  String get horenTotalQuestions => _t({'uz': "Jami savollar", 'kaa': "Barlıq sorawlar", 'ru': "Всего вопросов", 'de': "Fragen gesamt"});
  String get horenCorrect => _t({'uz': "To'g'ri", 'kaa': "Durıs", 'ru': "Верно", 'de': "Richtig"});
  String get horenWrong => _t({'uz': "Xato", 'kaa': "Qáte", 'ru': "Неверно", 'de': "Falsch"});
  String get horenStartTeil => _t({'uz': "Boshlash", 'kaa': "Baslaw", 'ru': "Начать", 'de': "Starten"});
  String get horenQuestion => _t({'uz': "Savol", 'kaa': "Soraw", 'ru': "Вопрос", 'de': "Frage"});
  String get horenPlayAudio => _t({'uz': "Audioni o'ynatish", 'kaa': "Audionı oynatıw", 'ru': "Воспроизвести аудио", 'de': "Audio abspielen"});
  String get horenPauseAudio => _t({'uz': "To'xtatish", 'kaa': "Toqtatıw", 'ru': "Пауза", 'de': "Pause"});
  String get horenAudioPlaying => _t({'uz': "Ijro etilmoqda...", 'kaa': "Oynatılıwda...", 'ru': "Воспроизводится...", 'de': "Wird abgespielt..."});
  String get horenAudioReady => _t({'uz': "Tayyor", 'kaa': "Tayar", 'ru': "Готово", 'de': "Bereit"});
  String get horenNextQuestion => _t({'uz': "Keyingi savol", 'kaa': "Keyingi soraw", 'ru': "Следующий вопрос", 'de': "Nächste Frage"});
  String get horenFinish => _t({'uz': "Yakunlash", 'kaa': "Juwmaqlaw", 'ru': "Завершить", 'de': "Beenden"});
  String get horenResult => _t({'uz': "Natija", 'kaa': "Nátiyje", 'ru': "Результат", 'de': "Ergebnis"});
  String get horenTryAgain => _t({'uz': "Qayta urinish", 'kaa': "Qayta urınıw", 'ru': "Попробовать снова", 'de': "Nochmal versuchen"});
  String horenProgress(int current, int total) {
    final template = _t({'uz': '{c} / {t}', 'kaa': '{c} / {t}', 'ru': '{c} / {t}', 'de': '{c} / {t}'});
    return template.replaceAll('{c}', current.toString()).replaceAll('{t}', total.toString());
  }
  String get horenA1LevelName => _t({'uz': "Boshlang'ich", 'kaa': "Baslanǵısh", 'ru': "Начальный", 'de': "Anfänger"});
  String get horenA2LevelName => _t({'uz': "Elementar", 'kaa': "Elementar", 'ru': "Элементарный", 'de': "Elementar"});
  String get horenB1LevelName => _t({'uz': "O'rta", 'kaa': "Orta", 'ru': "Средний", 'de': "Mittelstufe"});
  String get horenB2LevelName => _t({'uz': "O'rta-yuqori", 'kaa': "Orta-joqarı", 'ru': "Выше среднего", 'de': "Obere Mittelstufe"});
}
