import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    'kaa': "Natijelerim",
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
  String get tueLong => _t({'uz': "Seshanba", 'kaa': "Sheshembi", 'ru': "Вторник", 'de': "Dienstag"});
  String get wedLong => _t({'uz': "Chorshanba", 'kaa': "Sárshembi", 'ru': "Среда", 'de': "Mittwoch"});
  String get thuLong => _t({'uz': "Payshanba", 'kaa': "Kishi peyshembi", 'ru': "Четверг", 'de': "Donnerstag"});
  String get friLong => _t({'uz': "Juma", 'kaa': "Juma", 'ru': "Пятница", 'de': "Freitag"});
  String get satLong => _t({'uz': "Shanba", 'kaa': "Shembi", 'ru': "Суббота", 'de': "Samstag"});
  String get sunLong => _t({'uz': "Yakshanba", 'kaa': "Ykshembi", 'ru': "Воскресенье", 'de': "Sonntag"});

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
    'kaa': "Ajayıp gápler",
    'ru': "Странные предложения",
    'de': "Seltsame Sätze",
  });
  String get strangeSentencesDesc => _t({
    'uz': "So'zlardan grammatik to'g'ri, lekin mantiqsiz gap tuzing",
    'kaa': "Sózlerden grammatikalıq durıs, biraq aqılsız gáp dúziń",
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
        "Bul oyın házirge shekem islenip atır. Jańalıqlardı hám jańa oyınlardı biliw ushın qosımshanı jańalań — jaqında qosamız!",
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
    'kaa': "ta qaldı",
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
    'kaa': "Aqırǵı faollıq",
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
    'kaa': "Iltimos, dástúrge qaytadan kiriń",
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
    'kaa': "Tahrirlew",
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
    'kaa': "Bul muǵallimdi óshirmekshimisizbq?",
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
    'kaa': "Dars materialları",
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
    'uz': "Show sample answer",
    'kaa': "Show sample answer",
    'ru': "Show sample answer",
    'de': "Show sample answer",
  });
  String get sampleAnswerComingSoon => _t({
    'uz': "Beispielantwort tez orada qo'shiladi.",
    'kaa': "Beispielantwort tez orada qosıladı.",
    'ru': "Beispielantwort скоро будет добавлена.",
    'de': "Beispielantwort wird bald hinzugefügt.",
  });
  String get aiPoweredEvaluation => _t({
    'uz': "AI-Powered Evaluation",
    'kaa': "AI-Powered Evaluation",
    'ru': "AI-Powered Evaluation",
    'de': "AI-Powered Evaluation",
  });
  String get yourAnswer => _t({
    'uz': "Your Answer",
    'kaa': "Your Answer",
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
    'kaa': "Jabıwıńızdı jazıń, AI baholaydı.",
    'ru': "Напишите ваш ответ, AI оценит.",
    'de': "Schreiben Sie Ihre Antwort, AI bewertet.",
  });
  String get evaluation => _t({
    'uz': "BAHOLASH",
    'kaa': "BAHOLAW",
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
    'kaa': "DAVOMATNI BELGILEW",
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
    'kaa': "STATISTIKA HÁM NATIJALAR",
    'ru': "СТАТИСТИКА И РЕЗУЛЬТАТЫ",
    'de': "STATISTIK UND ERGEBNISSE",
  });
  String get upcomingLessons => _t({
    'uz': "KEYINGI DARSLAR",
    'kaa': "KEYINGI DÁRSLER",
    'ru': "БЛИЖАЙШИЕ УРОКИ",
    'de': "KOMMENDE UNTERRICHTSSTUNDEN",
  });
  String get noLessonToday => _t({
    'uz': "Bugun dars yo'q, dam oling yoki qo'shimcha mashq qiling",
    'kaa': "Bugún dars joq, dam alıń yamasa qosımsha maqtaq qılıń",
    'ru': "Сегодня нет урока, отдохните или сделайте дополнительные упражнения",
    'de': "Heute keine Lektion, ruhen Sie sich aus oder machen Sie zusätzliche Übungen",
  });
  String get viewHomework => _t({
    'uz': "UY VAZIFASINI KO'RISH",
    'kaa': "UY WAZIFASINÍ KÓRİW",
    'ru': "ПОСМОТРЕТЬ ДОМАШНЕЕ ЗАДАНИЕ",
    'de': "HAUSAUFGABE ANSEHEN",
  });
  String get homeworkSubmitted => _t({
    'uz': "UY VAZIFASI TOPSHIRILDI",
    'kaa': "UY WAZIFASI TOPSHIRILDI",
    'ru': "ДОМАШНЕЕ ЗАДАНИЕ СДАНО",
    'de': "HAUSAUFGABE ABGEGEBEN",
  });
  String get curriculum => _t({
    'uz': "O'QUV REJASI",
    'kaa': "ÓQIW REJASI",
    'ru': "УЧЕБНЫЙ ПЛАН",
    'de': "STUDIENPLAN",
  });
  String get addHomework => _t({
    'uz': "UY VAZIFA QO'SHISH",
    'kaa': "UY WAZIFA QOSÍW",
    'ru': "ДОБАВИТЬ ДОМАШНЕЕ ЗАДАНИЕ",
    'de': "HAUSAUFGABE HINZUFÜGEN",
  });
  String get homeworkCount => _t({
    'uz': "UY VAZIFA",
    'kaa': "UY WAZIFA",
    'ru': "ДОМАШНЕЕ ЗАДАНИЕ",
    'de': "HAUSAUFGABE",
  });
  String get tapToAddHomework => _t({
    'uz': "+ tugmasini bosib uy vazifa qo'shing",
    'kaa': "+ túymesin basıp uy wazifa qosıń",
    'ru': "Нажмите + чтобы добавить домашнее задание",
    'de': "Drücken Sie + um Hausaufgabe hinzuzufügen",
  });
  String get lesson => _t({
    'uz': "Dars",
    'kaa': "Dars",
    'ru': "Урок",
    'de': "Lektion",
  });
  String get addLesson => _t({
    'uz': "DARS QO'SHISH",
    'kaa': "DARS QOSÍW",
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
    'kaa': "topshirdı",
    'ru': "сдал",
    'de': "abgegeben",
  });
  String get link => _t({
    'uz': "Havola (Link)",
    'kaa': "Silte (Link)",
    'ru': "Ссылка (Link)",
    'de': "Link",
  });
  String get text => _t({
    'uz': "Matn",
    'kaa': "Matin",
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
    'kaa': "Material matinin kiritiń...",
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
    'kaa': "Sarlavha...",
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
    'kaa': "Túsindiriw (ixtiyarıy)...",
    'ru': "Комментарий (необязательно)...",
    'de': "Kommentar (optional)...",
  });
  String get commentOptionalCaps => _t({
    'uz': "IZOH (IXTIYORIY)",
    'kaa': "TÚSINDÍRÍW (IXTIYARIY)",
    'ru': "КОММЕНТАРИЙ (НЕОБЯЗАТЕЛЬНО)",
    'de': "KOMMENTAR (OPTIONAL)",
  });
  String get writeCommentOptional => _t({
    'uz': "Izoh yozing (ixtiyoriy)...",
    'kaa': "Túsindiriw jazıń (ixtiyarıy)...",
    'ru': "Напишите комментарий (необязательно)...",
    'de': "Schreibe einen Kommentar (optional)...",
  });
  String get testAnswersOptional => _t({
    'uz': "TEST JAVOBLARI (ixtiyoriy)",
    'kaa': "TEST JUUAPLARI (ixtiyarıy)",
    'ru': "ОТВЕТЫ НА ТЕСТ (необязательно)",
    'de': "TESTANTWORTEN (optional)",
  });
}
