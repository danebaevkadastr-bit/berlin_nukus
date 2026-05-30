// Data models and questions for Hören A1 (Goethe Institut)

const _base =
    'https://res.cloudinary.com/dmk6ir51m/video/upload/v1779954896';
const _base2 =
    'https://res.cloudinary.com/dmk6ir51m/video/upload/v1779962870';

const _t1q1  = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q1_iyvyew.mp3';
const _t1q2  = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q2_ncpyhi.mp3';
const _t1q3  = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q3_fc46of.mp3';
const _t1q4  = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q4_qbfhql.mp3';
const _t1q5  = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q5_sh6laj.mp3';
const _t1q6  = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q6_x3nti0.mp3';
const _t1q7  = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q7_x8bzcs.mp3';
const _t1q8  = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q8_yneizj.mp3';
const _t1q9  = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q9_qinhqv.mp3';
const _t1q10 = '$_base/assets_audio_a1_goethelistening_goethea1listeningteil1q10_y8p8h2.mp3';

const _t2q1  = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q1_hcyzuv.mp3';
const _t2q2  = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q2_hbo261.mp3';
const _t2q3  = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q3_l9c1fo.mp3';
const _t2q4  = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q4_iag768.mp3';
const _t2q5  = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q5_kv6asj.mp3';
const _t2q6  = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q6_smruiw.mp3';
const _t2q7  = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q7_u25tcp.mp3';
const _t2q8  = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q8_vtnxco.mp3';
const _t2q9  = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q9_koqmsi.mp3';
const _t2q10 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q10_dn9oes.mp3';
const _t2q11 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q11_ufuvvz.mp3';
const _t2q12 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q12_aszxvv.mp3';
const _t2q13 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q13_cla3j6.mp3';
const _t2q14 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q14_p7mtk3.mp3';
const _t2q15 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q15_yvoebs.mp3';
const _t2q16 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q16_r0ldsv.mp3';
const _t2q17 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q17_yjfeww.mp3';
const _t2q18 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q18_jzrbnr.mp3';
const _t2q19 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q19_jku5ch.mp3';
const _t2q20 = '$_base2/assets_audio_a1_goethelistening_goethea1listeningteil2q20_j9jlru.mp3';

class HorenQuestion {
  final String audioTitle;
  final String audioUrl;
  final String question;
  final List<String> options;
  final String correctAnswer;

  const HorenQuestion({
    required this.audioTitle,
    required this.audioUrl,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}

class HorenTeil {
  final int teilNumber;
  final List<HorenQuestion> questions;

  const HorenTeil({
    required this.teilNumber,
    required this.questions,
  });
}

class HorenLevel {
  final String level;
  final List<HorenTeil> teile;

  const HorenLevel({required this.level, required this.teile});
}

// ── A1 Data ───────────────────────────────────────────────────────────────────

const horenA1 = HorenLevel(
  level: 'A1',
  teile: [
    // ── Teil 1 – 10 savollar ─────────────────────────────────────────────────
    HorenTeil(
      teilNumber: 1,
      questions: [
        HorenQuestion(
          audioTitle: 'Aufgabe 1',
          audioUrl: _t1q1,
          question: 'Wo wollen die Freunde essen?',
          options: ['Im Park', 'Zu Hause', 'Im Restaurant'],
          correctAnswer: 'Zu Hause',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 2',
          audioUrl: _t1q2,
          question: 'Wann kommt der Zug?',
          options: ['Um 14:15 Uhr', 'Um 15:15 Uhr', 'Um 14:45 Uhr'],
          correctAnswer: 'Um 14:45 Uhr',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 3',
          audioUrl: _t1q3,
          question: 'Was trinkt die Frau?',
          options: ['Tee', 'Kaffee', 'Wasser'],
          correctAnswer: 'Tee',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 4',
          audioUrl: _t1q4,
          question: 'Wie viele Kinder hat Frau Meier?',
          options: ['Zwei', 'Eins', 'Drei'],
          correctAnswer: 'Zwei',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 5',
          audioUrl: _t1q5,
          question: 'Wo ist die Post?',
          options: [
            'Links um die Ecke',
            'Neben dem Supermarkt',
            'Geradeaus und rechts',
          ],
          correctAnswer: 'Geradeaus und rechts',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 6',
          audioUrl: _t1q6,
          question: 'Wann hat der Arzt wieder auf?',
          options: ['Am Donnerstag', 'Am Montag', 'Am Freitag'],
          correctAnswer: 'Am Montag',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 7',
          audioUrl: _t1q7,
          question: 'Was kostet das T-Shirt?',
          options: ['Zwölf Euro', 'Zweiundzwanzig Euro', 'Zwanzig Euro'],
          correctAnswer: 'Zwölf Euro',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 8',
          audioUrl: _t1q8,
          question: 'Wann beginnt der Film?',
          options: ['Um acht Uhr', 'Um neun Uhr', 'Um halb neun'],
          correctAnswer: 'Um halb neun',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 9',
          audioUrl: _t1q9,
          question: 'Was bestellt der Mann?',
          options: ['Schnitzel', 'Pizza', 'Suppe'],
          correctAnswer: 'Suppe',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 10',
          audioUrl: _t1q10,
          question: 'Woher kommt Ana?',
          options: ['Aus Spanien', 'Aus Portugal', 'Aus Italien'],
          correctAnswer: 'Aus Portugal',
        ),
      ],
    ),

    // ── Teil 2 – Richtig / Falsch (20 savollar) ──────────────────────────────
    HorenTeil(
      teilNumber: 2,
      questions: [
        HorenQuestion(
          audioTitle: 'Aufgabe 1',
          audioUrl: _t2q1,
          question: 'Der Zug nach München fährt von Gleis 5.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 2',
          audioUrl: _t2q2,
          question: 'Die Fahrgäste sollen beim Busfahrer ein Ticket kaufen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 3',
          audioUrl: _t2q3,
          question: 'Herr Weber soll zum Ausgang kommen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 4',
          audioUrl: _t2q4,
          question: 'Das Geschäft schließt um 19 Uhr.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 5',
          audioUrl: _t2q5,
          question: 'Die Fahrgäste sollen nicht aussteigen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 6',
          audioUrl: _t2q6,
          question: 'Die Kinder können im 2. Stock spielen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 7',
          audioUrl: _t2q7,
          question: 'Der Flug nach Berlin hat Verspätung.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 8',
          audioUrl: _t2q8,
          question: 'Die Fahrgäste sollen um 11 Uhr am Bus sein.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 9',
          audioUrl: _t2q9,
          question: 'Frau Klein soll zur Information im Erdgeschoss kommen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 10',
          audioUrl: _t2q10,
          question: 'Der Zug fährt in 10 Minuten weiter.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 11',
          audioUrl: _t2q11,
          question: 'Die Kunden sollen zur Kasse 3 gehen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 12',
          audioUrl: _t2q12,
          question: 'Man kann heute bis 22 Uhr schwimmen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 13',
          audioUrl: _t2q13,
          question: 'Der kleine Jonas sucht seine Mutter.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 14',
          audioUrl: _t2q14,
          question: 'Die Fahrgäste sollen rechts aussteigen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 15',
          audioUrl: _t2q15,
          question: 'Der Flug nach Madrid ist zum Einsteigen bereit.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 16',
          audioUrl: _t2q16,
          question: 'Die Fahrgäste können ihr Gepäck mitnehmen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 17',
          audioUrl: _t2q17,
          question: 'Obst und Gemüse sind heute besonders günstig.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 18',
          audioUrl: _t2q18,
          question: 'Der Bus fährt zum Krankenhaus.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 19',
          audioUrl: _t2q19,
          question: 'Herr Berger soll zum Schalter 12 kommen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        HorenQuestion(
          audioTitle: 'Aufgabe 20',
          audioUrl: _t2q20,
          question: 'Die Besucher sollen zum Ausgang gehen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
      ],
    ),

    // ── Teil 3 – placeholder ──────────────────────────────────────────────────
    HorenTeil(
      teilNumber: 3,
      questions: [
        HorenQuestion(
          audioTitle: 'Durchsage 1',
          audioUrl: '',
          question: 'Von welchem Gleis fährt der Zug ab?',
          options: ['Gleis 3', 'Gleis 5', 'Gleis 7'],
          correctAnswer: 'Gleis 5',
        ),
        HorenQuestion(
          audioTitle: 'Durchsage 2',
          audioUrl: '',
          question: 'Was ist im Angebot?',
          options: ['Brot', 'Milch', 'Äpfel'],
          correctAnswer: 'Milch',
        ),
        HorenQuestion(
          audioTitle: 'Durchsage 3',
          audioUrl: '',
          question: 'Wann beginnt die Veranstaltung?',
          options: ['Um 14 Uhr', 'Um 15 Uhr', 'Um 16 Uhr'],
          correctAnswer: 'Um 15 Uhr',
        ),
        HorenQuestion(
          audioTitle: 'Durchsage 4',
          audioUrl: '',
          question: 'Welcher Flug wird aufgerufen?',
          options: ['Flug nach Berlin', 'Flug nach München', 'Flug nach Hamburg'],
          correctAnswer: 'Flug nach München',
        ),
        HorenQuestion(
          audioTitle: 'Durchsage 5',
          audioUrl: '',
          question: 'Wer wird aufgerufen?',
          options: ['Herr Müller', 'Frau Schmidt', 'Herr Weber'],
          correctAnswer: 'Frau Schmidt',
        ),
      ],
    ),
  ],
);


// ── B1 Data (TELC) ────────────────────────────────────────────────────────────

const _baseB1 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127063';
const _baseB1T1Set2 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127055';
const _baseB1T1Set3 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127050';
const _baseB1T1Set4 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127039';
const _baseB1T1Set5 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127029';
const _baseB1T1Set6 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127021';
const _baseB1T1Set7 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127013';
const _baseB1T1Set8 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127007';
const _baseB1T1Set9 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127000';
const _baseB1T1Set10 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780126991';
const _baseB1T2 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127059';
const _baseB1T2Set2 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127051';
const _baseB1T2Set3 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127044';
const _baseB1T2Set4 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127036';
const _baseB1T2Set5 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127025';
const _baseB1T2Set6 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127022';
const _baseB1T2Set7 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127014';
const _baseB1T2Set8 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127008';
const _baseB1T2Set9 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127000';
const _baseB1T2Set10 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780126992';

// Teil 3 base URLs
const _baseB1T3 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127058';
const _baseB1T3Set2 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127052';

const _b1t1q1 = '$_baseB1/assets_audio_telc_b1_listening_q1_dkduw5.mp3';
const _b1t1q2 = '$_baseB1/assets_audio_telc_b1_listening_q2_hxuzyz.mp3';
const _b1t1q3 = '$_baseB1/assets_audio_telc_b1_listening_q3_sqmzti.mp3';
const _b1t1q4 = '$_baseB1/assets_audio_telc_b1_listening_q4_p6xsnh.mp3';
const _b1t1q5 = '$_baseB1/assets_audio_telc_b1_listening_q5_nsyo4b.mp3';
const _b1t1q6 = '$_baseB1T1Set2/assets_audio_telc_b1_listening_q6_ogkg9s.mp3';
const _b1t1q7 = '$_baseB1T1Set2/assets_audio_telc_b1_listening_q7_okzlsi.mp3';
const _b1t1q8 = '$_baseB1T1Set2/assets_audio_telc_b1_listening_q8_rim69z.mp3';
const _b1t1q9 = '$_baseB1T1Set2/assets_audio_telc_b1_listening_q9_qggq3g.mp3';
const _b1t1q10 = '$_baseB1T1Set2/assets_audio_telc_b1_listening_q10_xbwhcl.mp3';
const _b1t1q11 = '$_baseB1T1Set3/assets_audio_telc_b1_listening_q11_bv78it.mp3';
const _b1t1q12 = '$_baseB1T1Set3/assets_audio_telc_b1_listening_q12_vegsdy.mp3';
const _b1t1q13 = '$_baseB1T1Set3/assets_audio_telc_b1_listening_q13_upgza2.mp3';
const _b1t1q14 = '$_baseB1T1Set3/assets_audio_telc_b1_listening_q14_kh7xd2.mp3';
const _b1t1q15 = '$_baseB1T1Set3/assets_audio_telc_b1_listening_q15_omtqt5.mp3';
const _b1t1q16 = '$_baseB1T1Set4/assets_audio_telc_b1_listening_q16_y26u4s.mp3';
const _b1t1q17 = '$_baseB1T1Set4/assets_audio_telc_b1_listening_q17_xqqeey.mp3';
const _b1t1q18 = '$_baseB1T1Set4/assets_audio_telc_b1_listening_q18_kna5lm.mp3';
const _b1t1q19 = '$_baseB1T1Set4/assets_audio_telc_b1_listening_q19_qmqp9k.mp3';
const _b1t1q20 = '$_baseB1T1Set4/assets_audio_telc_b1_listening_q20_iwkmxu.mp3';
const _b1t1q21 = '$_baseB1T1Set5/assets_audio_telc_b1_listening_q21_vtaegb.mp3';
const _b1t1q22 = '$_baseB1T1Set5/assets_audio_telc_b1_listening_q22_nu8tfw.mp3';
const _b1t1q23 = '$_baseB1T1Set5/assets_audio_telc_b1_listening_q23_ktmuvw.mp3';
const _b1t1q24 = '$_baseB1T1Set5/assets_audio_telc_b1_listening_q24_zbzhbb.mp3';
const _b1t1q25 = '$_baseB1T1Set5/assets_audio_telc_b1_listening_q25_irpdrh.mp3';
const _b1t1q26 = '$_baseB1T1Set6/assets_audio_telc_b1_listening_q26_pkcxi9.mp3';
const _b1t1q27 = '$_baseB1T1Set6/assets_audio_telc_b1_listening_q27_okjpyo.mp3';
const _b1t1q28 = '$_baseB1T1Set6/assets_audio_telc_b1_listening_q28_govhaf.mp3';
const _b1t1q29 = '$_baseB1T1Set6/assets_audio_telc_b1_listening_q29_zac8tp.mp3';
const _b1t1q30 = '$_baseB1T1Set6/assets_audio_telc_b1_listening_q30_vsj8v9.mp3';
const _b1t1q31 = '$_baseB1T1Set7/assets_audio_telc_b1_listening_q31_q9gafc.mp3';
const _b1t1q32 = '$_baseB1T1Set7/assets_audio_telc_b1_listening_q32_rxwytb.mp3';
const _b1t1q33 = '$_baseB1T1Set7/assets_audio_telc_b1_listening_q33_uh4w5s.mp3';
const _b1t1q34 = '$_baseB1T1Set7/assets_audio_telc_b1_listening_q34_uj5kom.mp3';
const _b1t1q35 = '$_baseB1T1Set7/assets_audio_telc_b1_listening_q35_xonaaj.mp3';
const _b1t1q36 = '$_baseB1T1Set8/assets_audio_telc_b1_listening_q36_rt61hx.mp3';
const _b1t1q37 = '$_baseB1T1Set8/assets_audio_telc_b1_listening_q37_xh3o2f.mp3';
const _b1t1q38 = '$_baseB1T1Set8/assets_audio_telc_b1_listening_q38_fbmkpf.mp3';
const _b1t1q39 = '$_baseB1T1Set8/assets_audio_telc_b1_listening_q39_mgoyis.mp3';
const _b1t1q40 = '$_baseB1T1Set8/assets_audio_telc_b1_listening_q40_r5yh51.mp3';
const _b1t1q41 = '$_baseB1T1Set9/assets_audio_telc_b1_listening_q41_slsczk.mp3';
const _b1t1q42 = '$_baseB1T1Set9/assets_audio_telc_b1_listening_q42_a6k5ob.mp3';
const _b1t1q43 = '$_baseB1T1Set9/assets_audio_telc_b1_listening_q43_mzhrcq.mp3';
const _b1t1q44 = '$_baseB1T1Set9/assets_audio_telc_b1_listening_q44_htolc2.mp3';
const _b1t1q45 = '$_baseB1T1Set9/assets_audio_telc_b1_listening_q45_beccag.mp3';
const _b1t1q46 = '$_baseB1T1Set10/assets_audio_telc_b1_listening_q46_ajqzrn.mp3';
const _b1t1q47 = '$_baseB1T1Set10/assets_audio_telc_b1_listening_q47_cgehrw.mp3';
const _b1t1q48 = '$_baseB1T1Set10/assets_audio_telc_b1_listening_q48_tn3png.mp3';
const _b1t1q49 = '$_baseB1T1Set10/assets_audio_telc_b1_listening_q49_y9cy3x.mp3';
const _b1t1q50 = '$_baseB1T1Set10/assets_audio_telc_b1_listening_q50_pmtkyl.mp3';

const _b1t2test1 = '$_baseB1T2/assets_audio_telc_b1_listening_teil2_isg18o.mp3';
const _b1t2test2 = '$_baseB1T2Set2/assets_audio_telc_b1_listening_teil2set2_zby4a3.mp3';
const _b1t2test3 = '$_baseB1T2Set3/assets_audio_telc_b1_listening_teil2set3_yax8wq.mp3';
const _b1t2test4 = '$_baseB1T2Set4/assets_audio_telc_b1_listening_teil2set4_unaptb.mp3';
const _b1t2test5 = '$_baseB1T2Set5/assets_audio_telc_b1_listening_teil2set5_nc0zwy.mp3';
const _b1t2test6 = '$_baseB1T2Set6/assets_audio_telc_b1_listening_teil2set6_bfgskg.mp3';
const _b1t2test7 = '$_baseB1T2Set7/assets_audio_telc_b1_listening_teil2set7_im8jbm.mp3';
const _b1t2test8 = '$_baseB1T2Set8/assets_audio_telc_b1_listening_teil2set8_iojmse.mp3';
const _b1t2test9 = '$_baseB1T2Set9/assets_audio_telc_b1_listening_teil2set9_v86k9c.mp3';
const _b1t2test10 = '$_baseB1T2Set10/assets_audio_telc_b1_listening_teil2set10_hdsao3.mp3';

// Teil 3 audio URLs (Test 1)
const _b1t3q1 = '$_baseB1T3/assets_audio_telc_b1_listening_teil3q1_g4a2jv.mp3';
const _b1t3q2 = '$_baseB1T3/assets_audio_telc_b1_listening_teil3q2_t57fyv.mp3';
const _b1t3q3 = '$_baseB1T3/assets_audio_telc_b1_listening_teil3q3_fym6kp.mp3';
const _b1t3q4 = '$_baseB1T3/assets_audio_telc_b1_listening_teil3q4_wngzzv.mp3';
const _b1t3q5 = '$_baseB1T3/assets_audio_telc_b1_listening_teil3q5_h4ee3i.mp3';
// Test 2
const _b1t3q6 = '$_baseB1T3Set2/assets_audio_telc_b1_listening_teil3q6_rpv3tq.mp3';
const _b1t3q7 = '$_baseB1T3Set2/assets_audio_telc_b1_listening_teil3q7_x1h9te.mp3';
const _b1t3q8 = '$_baseB1T3Set2/assets_audio_telc_b1_listening_teil3q8_jgiksd.mp3';
const _b1t3q9 = '$_baseB1T3Set2/assets_audio_telc_b1_listening_teil3q9_crfe8y.mp3';
const _b1t3q10 = '$_baseB1T3Set2/assets_audio_telc_b1_listening_teil3q10_t0ihem.mp3';

const _baseB1T3Set3 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127043';
// Test 3
const _b1t3q11 = '$_baseB1T3Set3/assets_audio_telc_b1_listening_teil3q11_rryw7t.mp3';
const _b1t3q12 = '$_baseB1T3Set3/assets_audio_telc_b1_listening_teil3q12_v8czcj.mp3';
const _b1t3q13 = '$_baseB1T3Set3/assets_audio_telc_b1_listening_teil3q13_igdafc.mp3';
const _b1t3q14 = '$_baseB1T3Set3/assets_audio_telc_b1_listening_teil3q14_ywscqg.mp3';
const _b1t3q15 = '$_baseB1T3Set3/assets_audio_telc_b1_listening_teil3q15_ulnxex.mp3';

const _baseB1T3Set4 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127035';
// Test 4
const _b1t3q16 = '$_baseB1T3Set4/assets_audio_telc_b1_listening_teil3q16_pepi92.mp3';
const _b1t3q17 = '$_baseB1T3Set4/assets_audio_telc_b1_listening_teil3q17_bynluj.mp3';
const _b1t3q18 = '$_baseB1T3Set4/assets_audio_telc_b1_listening_teil3q18_wbrs1k.mp3';
const _b1t3q19 = '$_baseB1T3Set4/assets_audio_telc_b1_listening_teil3q19_klo9vd.mp3';
const _b1t3q20 = '$_baseB1T3Set4/assets_audio_telc_b1_listening_teil3q20_ful3hi.mp3';

const _baseB1T3Set5 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127050';
// Test 5
const _b1t3q21 = '$_baseB1T3Set5/assets_audio_telc_b1_listening_teil3q21_llad5a.mp3';
const _b1t3q22 = '$_baseB1T3Set5/assets_audio_telc_b1_listening_teil3q22_gj4f7k.mp3';
const _b1t3q23 = '$_baseB1T3Set5/assets_audio_telc_b1_listening_teil3q23_e7h0fc.mp3';
const _b1t3q24 = '$_baseB1T3Set5/assets_audio_telc_b1_listening_teil3q24_jetdv7.mp3';
const _b1t3q25 = '$_baseB1T3Set5/assets_audio_telc_b1_listening_teil3q25_whiq0g.mp3';

const _baseB1T3Set6 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127022';
// Test 6
const _b1t3q26 = '$_baseB1T3Set6/assets_audio_telc_b1_listening_teil3q26_pcuwh7.mp3';
const _b1t3q27 = '$_baseB1T3Set6/assets_audio_telc_b1_listening_teil3q27_vbphhk.mp3';
const _b1t3q28 = '$_baseB1T3Set6/assets_audio_telc_b1_listening_teil3q28_cwomn9.mp3';
const _b1t3q29 = '$_baseB1T3Set6/assets_audio_telc_b1_listening_teil3q29_uru605.mp3';
const _b1t3q30 = '$_baseB1T3Set6/assets_audio_telc_b1_listening_teil3q30_ppd1p5.mp3';

const _baseB1T3Set7 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127015';
// Test 7
const _b1t3q31 = '$_baseB1T3Set7/assets_audio_telc_b1_listening_teil3q31_gsaiwy.mp3';
const _b1t3q32 = '$_baseB1T3Set7/assets_audio_telc_b1_listening_teil3q32_p6vwn3.mp3';
const _b1t3q33 = '$_baseB1T3Set7/assets_audio_telc_b1_listening_teil3q33_zs7fxl.mp3';
const _b1t3q34 = '$_baseB1T3Set7/assets_audio_telc_b1_listening_teil3q34_bzgyiy.mp3';
const _b1t3q35 = '$_baseB1T3Set7/assets_audio_telc_b1_listening_teil3q35_v95q44.mp3';

const _baseB1T3Set8 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127011';
// Test 8
const _b1t3q36 = '$_baseB1T3Set8/assets_audio_telc_b1_listening_teil3q36_gr2d02.mp3';
const _b1t3q37 = '$_baseB1T3Set8/assets_audio_telc_b1_listening_teil3q37_uipqlx.mp3';
const _b1t3q38 = '$_baseB1T3Set8/assets_audio_telc_b1_listening_teil3q38_sbonvq.mp3';
const _b1t3q39 = '$_baseB1T3Set8/assets_audio_telc_b1_listening_teil3q39_jixysk.mp3';
const _b1t3q40 = '$_baseB1T3Set8/assets_audio_telc_b1_listening_teil3q40_wnj585.mp3';

const _baseB1T3Set9 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780127002';
// Test 9
const _b1t3q41 = '$_baseB1T3Set9/assets_audio_telc_b1_listening_teil3q41_t57hqd.mp3';
const _b1t3q42 = '$_baseB1T3Set9/assets_audio_telc_b1_listening_teil3q42_w4t5fj.mp3';
const _b1t3q43 = '$_baseB1T3Set9/assets_audio_telc_b1_listening_teil3q43_w26k2i.mp3';
const _b1t3q44 = '$_baseB1T3Set9/assets_audio_telc_b1_listening_teil3q44_u9hpla.mp3';
const _b1t3q45 = '$_baseB1T3Set9/assets_audio_telc_b1_listening_teil3q45_zkgtw1.mp3';

const _baseB1T3Set10 = 'https://res.cloudinary.com/dmk6ir51m/video/upload/v1780126993';
// Test 10
const _b1t3q46 = '$_baseB1T3Set10/assets_audio_telc_b1_listening_teil3q46_v34kjl.mp3';
const _b1t3q47 = '$_baseB1T3Set10/assets_audio_telc_b1_listening_teil3q47_isrkph.mp3';
const _b1t3q48 = '$_baseB1T3Set10/assets_audio_telc_b1_listening_teil3q48_t3k5cw.mp3';
const _b1t3q49 = '$_baseB1T3Set10/assets_audio_telc_b1_listening_teil3q49_pzvvjo.mp3';
const _b1t3q50 = '$_baseB1T3Set10/assets_audio_telc_b1_listening_teil3q50_slqyqf.mp3';

final horenB1 = HorenLevel(
  level: 'B1',
  teile: [
    // ── Teil 1 – Telefonansagen (10 TESTS × 5 savollar = 50 savol) ───────────
    HorenTeil(
      teilNumber: 1,
      questions: [
        // TEST 1: (1), (2), (3), (4), (5)
        const HorenQuestion(
          audioTitle: 'Aufgabe 1',
          audioUrl: _b1t1q1,
          question: 'Die Sprecherin findet nicht das Rauchverbot selbst, sondern vor allem die Diskussion darüber belastend.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 2',
          audioUrl: _b1t1q2,
          question: 'Der Sprecher glaubt, dass das Rauchverbot mit der Zeit für die meisten ganz normal wird.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 3',
          audioUrl: _b1t1q3,
          question: 'Die Sprecherin ist überzeugt, dass ihre Kneipe ohne das Rauchverbot heute wirtschaftlich gut dastehen würde.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 4',
          audioUrl: _b1t1q4,
          question: 'Bevor er in einer Raucherkabine sitzt, bleibt der Sprecher lieber ganz weg.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 5',
          audioUrl: _b1t1q5,
          question: 'Die Sprecherin merkt im Restaurantbetrieb bisher keine wirtschaftlichen Folgen des Rauchverbots.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        
        // TEST 2: (6), (7), (8), (9), (10)
        const HorenQuestion(
          audioTitle: 'Aufgabe 6',
          audioUrl: _b1t1q6,
          question: 'Die Sprecherin würde auf dem Markt gern mehr kaufen, wenn das finanziell leichter wäre.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 7',
          audioUrl: _b1t1q7,
          question: 'Der Sprecher lehnt gesunde Ernährung nicht grundsätzlich ab, will daraus im Alltag aber kein großes Thema machen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 8',
          audioUrl: _b1t1q8,
          question: 'Für die Sprecherin reicht es für eine gesunde Lebensweise im Wesentlichen, Bio-Produkte zu kaufen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 9',
          audioUrl: _b1t1q9,
          question: 'Dem Sprecher fällt seine Umstellung auf gesünderes Essen leicht.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 10',
          audioUrl: _b1t1q10,
          question: 'Die Sprecherin meint, dass gesundes Essen für viele Menschen vor allem am Geld scheitert.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        
        // TEST 3-10 (placeholder - jami 50 ta savol bo'lishi kerak)
        ...List.generate(40, (index) {
          final questionNum = index + 11;
          String audioUrl = '';
          String question = 'Placeholder savol - audio qo\'shilganda yangilanadi.';
          String correctAnswer = 'Richtig';
          
          // Test 3 uchun audio va savollar (11-15)
          if (questionNum == 11) {
            audioUrl = _b1t1q11;
            question = 'Die Sprecherin findet Umweltkonzerte vor allem deshalb problematisch, weil Anspruch und Wirklichkeit nicht zusammenpassen.';
          } else if (questionNum == 12) {
            audioUrl = _b1t1q12;
            question = 'Weil der Sprecher kaum noch Hoffnung hat, verzichtet er im Alltag auf Umweltschutz.';
            correctAnswer = 'Falsch';
          } else if (questionNum == 13) {
            audioUrl = _b1t1q13;
            question = 'Der Sprecher sieht für sich persönlich keinen Anlass, beim Thema Strom etwas zu ändern.';
            correctAnswer = 'Falsch';
          } else if (questionNum == 14) {
            audioUrl = _b1t1q14;
            question = 'Die Sprecherin verbindet Umweltschutz eher mit eigenem Verhalten als mit großer Politik.';
          } else if (questionNum == 15) {
            audioUrl = _b1t1q15;
            question = 'Die Sprecherin hält Wassersparen vor allem für eine Frage des Geldes.';
            correctAnswer = 'Falsch';
          }
          // Test 4 uchun audio va savollar (16-20)
          else if (questionNum == 16) {
            audioUrl = _b1t1q16;
            question = 'Ohne das neue Sportangebot in ihrer Nähe hätte die Sprecherin vermutlich weiter keinen Sport gemacht.';
          } else if (questionNum == 17) {
            audioUrl = _b1t1q17;
            question = 'Die Sprecherin und ihre Freundin schaffen es bisher eher selten, ihren Plan umzusetzen.';
          } else if (questionNum == 18) {
            audioUrl = _b1t1q18;
            question = 'Für den Sprecher ist Sport vor allem dann interessant, wenn er ihn gemeinsam mit anderen macht.';
            correctAnswer = 'Falsch';
          } else if (questionNum == 19) {
            audioUrl = _b1t1q19;
            question = 'Weil die Sprecherin kein Fitnessstudio mag, bewegt sie sich insgesamt eher wenig.';
            correctAnswer = 'Falsch';
          } else if (questionNum == 20) {
            audioUrl = _b1t1q20;
            question = 'Dem Sprecher gefällt an seinem jetzigen Studio nicht nur das eigentliche Training.';
          }
          // Test 5 uchun audio va savollar (21-25)
          else if (questionNum == 21) {
            audioUrl = _b1t1q21;
            question = 'Im Urlaub will der Sprecher vor allem am Strand entspannen.';
            correctAnswer = 'Falsch';
          } else if (questionNum == 22) {
            audioUrl = _b1t1q22;
            question = 'Dem Sprecher ist auf der Reise wichtig, unterwegs spontan bleiben zu können.';
          } else if (questionNum == 23) {
            audioUrl = _b1t1q23;
            question = 'Die Sprecherin erlebt ihre Ferien zu Hause als komplett verlorene Zeit.';
            correctAnswer = 'Falsch';
          } else if (questionNum == 24) {
            audioUrl = _b1t1q24;
            question = 'Für die Sprecherin steht bei der Reise nach Mexiko ihr eigenes Spanischlernen im Vordergrund.';
            correctAnswer = 'Falsch';
          } else if (questionNum == 25) {
            audioUrl = _b1t1q25;
            question = 'Für den Sprecher gehört zum Camping gerade dazu, dass es nicht besonders bequem ist.';
          }
          // Test 6 uchun audio va savollar (26-30)
          else if (questionNum == 26) {
            audioUrl = _b1t1q26;
            question = 'Die Sprecherin liest Nachrichten zwar gern online, hält soziale Netzwerke dafür aber nicht für verlässlich genug.';
          } else if (questionNum == 27) {
            audioUrl = _b1t1q27;
            question = 'Für den Sprecher sind soziale Netzwerke eher ein erster Hinweis als eine endgültige Informationsquelle.';
          } else if (questionNum == 28) {
            audioUrl = _b1t1q28;
            question = 'Wenn eine Meldung in sozialen Netzwerken oft geteilt wird, wirkt sie auf die Sprecherin glaubwürdiger.';
            correctAnswer = 'Falsch';
          } else if (questionNum == 29) {
            audioUrl = _b1t1q29;
            question = 'Der Sprecher hat die gedruckte Zeitung inzwischen vollständig durch Nachrichten-Apps ersetzt.';
            correctAnswer = 'Falsch';
          } else if (questionNum == 30) {
            audioUrl = _b1t1q30;
            question = 'Gefährlich findet die Sprecherin weniger das Tempo als den fehlenden Zusammenhang.';
          }
          // Test 7 uchun audio va savollar (31-35)
          else if (questionNum == 31) {
            audioUrl = _b1t1q31;
            question = 'Ausschlaggebend für die Einführung der Kartenzahlung war am Ende der Wunsch der Kunden.';
          } else if (questionNum == 32) {
            audioUrl = _b1t1q32;
            question = 'Für Notfälle hat der Sprecher normalerweise Bargeld dabei.';
            correctAnswer = 'Falsch';
          } else if (questionNum == 33) {
            audioUrl = _b1t1q33;
            question = 'Mit Kartenzahlung behält die Sprecherin ihre Ausgaben besser im Blick als mit Bargeld.';
            correctAnswer = 'Falsch';
          } else if (questionNum == 34) {
            audioUrl = _b1t1q34;
            question = 'Der Sprecher sieht Kartenzahlung im Berufsalltag nicht nur positiv.';
          } else if (questionNum == 35) {
            audioUrl = _b1t1q35;
            question = 'Was die Sprecherin an einer bargeldlosen Zukunft am meisten stört, hat mit Datenschutz zu tun.';
          }
          // Test 8 uchun audio va savollar (36-40)
          else if (questionNum == 36) {
            audioUrl = _b1t1q36;
            question = 'Für die Sprecherin sollte man bei Haustieren in Mietwohnungen nicht pauschal urteilen.';
          } else if (questionNum == 37) {
            audioUrl = _b1t1q37;
            question = 'Nach Meinung des Sprechers gehen Probleme mit Haustieren meist vom Tier selbst aus.';
            correctAnswer = 'Falsch';
          } else if (questionNum == 38) {
            audioUrl = _b1t1q38;
            question = 'Obwohl die Sprecherin ihre Rechte kennt, verzichtet sie auf einen Streit mit dem Vermieter.';
          } else if (questionNum == 39) {
            audioUrl = _b1t1q39;
            question = 'Der Hund hat dem Sprecher geholfen, nach dem Tod seiner Frau wieder mehr unter Leute zu kommen.';
          } else if (questionNum == 40) {
            audioUrl = _b1t1q40;
            question = 'Die Sprecherin verlangt die Zusatzkaution, weil sie Tiere grundsätzlich nicht in Wohnungen will.';
            correctAnswer = 'Falsch';
          }
          // Test 9 uchun audio va savollar (41-45)
          else if (questionNum == 41) {
            audioUrl = _b1t1q41;
            question = 'Für die Sprecherin ist Homeoffice vor allem deshalb positiv, weil sie dadurch täglich viel Zeit spart.';
          } else if (questionNum == 42) {
            audioUrl = _b1t1q42;
            question = 'Im Homeoffice kann sich der Sprecher besser konzentrieren als im Büro.';
            correctAnswer = 'Falsch';
          } else if (questionNum == 43) {
            audioUrl = _b1t1q43;
            question = 'Die Sprecherin will weder nur zu Hause noch nur im Büro arbeiten.';
          } else if (questionNum == 44) {
            audioUrl = _b1t1q44;
            question = 'Der Sprecher hält Homeoffice besonders für neue Mitarbeiter für schwierig.';
          } else if (questionNum == 45) {
            audioUrl = _b1t1q45;
            question = 'Die Sprecherin glaubt, dass man mit kleinen Kindern im Homeoffice nebenbei problemlos arbeiten kann.';
            correctAnswer = 'Falsch';
          }
          // Test 10 uchun audio va savollar (46-50)
          else if (questionNum == 46) {
            audioUrl = _b1t1q46;
            question = 'Für die Sprecherin ist Ehrenamt mehr als nur ein Pluspunkt im Lebenslauf.';
          } else if (questionNum == 47) {
            audioUrl = _b1t1q47;
            question = 'Der Sprecher engagiert sich nicht, weil ihn soziale Projekte nicht interessieren.';
            correctAnswer = 'Falsch';
          } else if (questionNum == 48) {
            audioUrl = _b1t1q48;
            question = 'Die Sprecherin hat durch ihr Ehrenamt selbst neue Aufgaben und Kontakte gefunden.';
          } else if (questionNum == 49) {
            audioUrl = _b1t1q49;
            question = 'Der Sprecher könnte sich eher punktuell als regelmäßig ehrenamtlich engagieren.';
          } else if (questionNum == 50) {
            audioUrl = _b1t1q50;
            question = 'Die Sprecherin findet, dass Vereine neue Helfer oft zu vorsichtig ansprechen.';
            correctAnswer = 'Falsch';
          }
          
          return HorenQuestion(
            audioTitle: 'Aufgabe $questionNum',
            audioUrl: audioUrl,
            question: question,
            options: ['Richtig', 'Falsch'],
            correctAnswer: correctAnswer,
          );
        }),
      ],
    ),

    // ── Teil 2 – Radiointerview (10 TESTS × 10 savollar = 100 savol) ─────────
    HorenTeil(
      teilNumber: 2,
      questions: [
        // TEST 1 (1-10) - bitta audio
        const HorenQuestion(
          audioTitle: 'Aufgabe 1',
          audioUrl: _b1t2test1,
          question: 'Vor dem Umbau hatte der Verein noch kein festes Haus.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 2',
          audioUrl: _b1t2test1,
          question: 'Mit Anfang zwanzig war für Herrn Basler schon klar, dass er später so ein Haus leiten wollte.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 3',
          audioUrl: _b1t2test1,
          question: 'Der Kulturbahnhof soll mehr sein als nur ein Ort für Auftritte.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 4',
          audioUrl: _b1t2test1,
          question: 'Nachmittags kommen oft Leute aus der Nachbarschaft in den Kulturbahnhof.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 5',
          audioUrl: _b1t2test1,
          question: 'Das Café ist im Kulturbahnhof jeden Tag geöffnet.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 6',
          audioUrl: _b1t2test1,
          question: 'Ohne eigene Einnahmen könnte das Zentrum nicht auskommen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 7',
          audioUrl: _b1t2test1,
          question: 'Herr Basler fehlen eher Mitarbeiter als Programmideen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 8',
          audioUrl: _b1t2test1,
          question: 'Der Proberaum im Keller wird vor allem von Schulklassen genutzt.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 9',
          audioUrl: _b1t2test1,
          question: 'Herr Basler möchte künftig enger mit Schulen zusammenarbeiten.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 10',
          audioUrl: _b1t2test1,
          question: 'Im Kulturbahnhof sind schon alle Räume gut erreichbar.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        
        // TEST 2 (11-20) - bitta audio
        const HorenQuestion(
          audioTitle: 'Aufgabe 11',
          audioUrl: _b1t2test2,
          question: 'Das frühere Museumsgebäude lag mitten in der Stadt.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 12',
          audioUrl: _b1t2test2,
          question: 'Die Entscheidung für die Museumsarbeit stand bei Frau Lenz schon vor dem Studium fest.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 13',
          audioUrl: _b1t2test2,
          question: 'Die Ausstellung ist nicht in erster Linie für Touristen gedacht.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 14',
          audioUrl: _b1t2test2,
          question: 'Gerade für Fotos aus dem Arbeitsalltag war das Museum auf private Leihgaben angewiesen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 15',
          audioUrl: _b1t2test2,
          question: 'Für Schulen gibt es schon ein festes Wochenprogramm.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 16',
          audioUrl: _b1t2test2,
          question: 'Bei größeren Sonderausstellungen reicht das normale Budget des Museums nicht aus.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 17',
          audioUrl: _b1t2test2,
          question: 'Im Museum helfen nur ältere Ehrenamtliche mit.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 18',
          audioUrl: _b1t2test2,
          question: 'Frau Lenz hält fehlende Ausstellungsstücke für das größte Problem des Museums.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 19',
          audioUrl: _b1t2test2,
          question: 'Später soll man wenigstens einen Teil der Sammlung auch von zu Hause aus ansehen können.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 20',
          audioUrl: _b1t2test2,
          question: 'Nach der neuen Dauerausstellung will Frau Lenz erst einmal nichts Weiteres verändern.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        
        // TEST 3 (21-30) - bitta audio
        const HorenQuestion(
          audioTitle: 'Aufgabe 21',
          audioUrl: _b1t2test3,
          question: 'Frau Neumann hatte schon lange geplant, einmal so ein Zentrum zu leiten.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 22',
          audioUrl: _b1t2test3,
          question: 'Frau Neumann hat selbst eine handwerkliche Ausbildung gemacht.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 23',
          audioUrl: _b1t2test3,
          question: 'Im Zentrum können Jugendliche verschiedene Berufe praktisch ausprobieren.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 24',
          audioUrl: _b1t2test3,
          question: 'Die offenen Nachmittage sind nur für Schulklassen gedacht.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 25',
          audioUrl: _b1t2test3,
          question: 'Viele Eltern informieren sich schon früh über Aufstiegschancen im Handwerk.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 26',
          audioUrl: _b1t2test3,
          question: 'Einige Betriebe unterstützen das Zentrum mit Material und Praktikumsplätzen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 27',
          audioUrl: _b1t2test3,
          question: 'Am schwierigsten ist für das Zentrum, Jugendliche überhaupt für Handwerk zu interessieren.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 28',
          audioUrl: _b1t2test3,
          question: 'Nach Ansicht von Frau Neumann reichen kurze Videos im Internet für die Berufswahl aus.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 29',
          audioUrl: _b1t2test3,
          question: 'Nach einem Praktikum entscheiden sich manche Jugendliche anders als zuerst gedacht.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 30',
          audioUrl: _b1t2test3,
          question: 'Für Schulen auf dem Land ist eine mobile Werkstatt geplant.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        
        // TEST 4 (31-40) - bitta audio
        const HorenQuestion(
          audioTitle: 'Aufgabe 31',
          audioUrl: _b1t2test4,
          question: 'Erst als ein Raum frei wurde, konnte die Bibliothek mit der Medienwerkstatt wirklich anfangen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 32',
          audioUrl: _b1t2test4,
          question: 'Die Leute brachten defekte Geräte vorbei, damit Mitarbeiter der Bibliothek sie reparieren konnten.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 33',
          audioUrl: _b1t2test4,
          question: 'Besonders ältere Besucher nutzen gern die Hilfe durch die Jugendlichen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 34',
          audioUrl: _b1t2test4,
          question: 'Beim Roboter-Wettbewerb ging es darum, einer Maschine Bewegung beizubringen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 35',
          audioUrl: _b1t2test4,
          question: 'Die Bibliothek freut sich, wenn Teilnehmer der Werkstatt eigene Ideen mitbringen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 36',
          audioUrl: _b1t2test4,
          question: 'Für den Kurs zur Bildbearbeitung braucht man einen eigenen Computer.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 37',
          audioUrl: _b1t2test4,
          question: 'Im Fotokurs geht es vor allem um komplizierte Aufnahmetechniken.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 38',
          audioUrl: _b1t2test4,
          question: 'Die Schulen in der Umgebung haben selbst meist gute technische Ausstattung.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 39',
          audioUrl: _b1t2test4,
          question: 'Manche Lehrer nutzen die Medienwerkstatt inzwischen als Ergänzung zum Unterricht.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 40',
          audioUrl: _b1t2test4,
          question: 'Herr Schubert plant als Nächstes ein Projekt zur Musikproduktion.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        
        // TEST 5 (41-50) - bitta audio
        const HorenQuestion(
          audioTitle: 'Aufgabe 41',
          audioUrl: _b1t2test5,
          question: 'Der frühere Standort war zu groß für das Sozialkaufhaus geworden.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 42',
          audioUrl: _b1t2test5,
          question: 'Im Sozialkaufhaus dürfen nur Menschen mit wenig Geld einkaufen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 43',
          audioUrl: _b1t2test5,
          question: 'Zurzeit werden vor allem Kleidungsstücke besonders stark nachgefragt.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 44',
          audioUrl: _b1t2test5,
          question: 'Kleinere Spenden können oft direkt im Laden abgegeben werden.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 45',
          audioUrl: _b1t2test5,
          question: 'Elektrogeräte kommen erst nach einer Prüfung in den Verkauf.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 46',
          audioUrl: _b1t2test5,
          question: 'Das größte Problem ist im Moment, dass zu wenig gespendet wird.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 47',
          audioUrl: _b1t2test5,
          question: 'Manche Kunden fühlen sich beim ersten Besuch zunächst unsicher.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 48',
          audioUrl: _b1t2test5,
          question: 'Im Sozialkaufhaus arbeiten ausschließlich Ehrenamtliche.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 49',
          audioUrl: _b1t2test5,
          question: 'Größere Möbel sollen später auch mit Fotos im Internet gezeigt werden.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 50',
          audioUrl: _b1t2test5,
          question: 'Herr Akin meint, dass Wiederverwendung für die Umwelt keine Rolle spielt.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        
        // TEST 6 (51-60) - bitta audio
        const HorenQuestion(
          audioTitle: 'Aufgabe 51',
          audioUrl: _b1t2test6,
          question: 'Frau Berger hat früher in einer Versicherung gearbeitet.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 52',
          audioUrl: _b1t2test6,
          question: 'Schon als Jugendliche wollte Frau Berger Bäckerin werden.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 53',
          audioUrl: _b1t2test6,
          question: 'Frau Berger hat sich neben ihrem alten Beruf auf den Wechsel vorbereitet.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 54',
          audioUrl: _b1t2test6,
          question: 'In der Bäckerei arbeitet Frau Berger erst seit wenigen Wochen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 55',
          audioUrl: _b1t2test6,
          question: 'Das frühe Aufstehen ist für Frau Berger das größte Problem.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 56',
          audioUrl: _b1t2test6,
          question: 'Die Bäckerei backt mit Mehl aus der Region.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 57',
          audioUrl: _b1t2test6,
          question: 'Am Samstag steht Frau Berger oft im Verkauf und nicht hinten in der Backstube.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 58',
          audioUrl: _b1t2test6,
          question: 'Viele Kunden mögen an der Bäckerei besonders die Zutaten aus der Umgebung.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 59',
          audioUrl: _b1t2test6,
          question: 'Frau Berger möchte lieber wieder in ihr altes Büro zurück.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 60',
          audioUrl: _b1t2test6,
          question: 'Später möchte Frau Berger Backkurse für Kinder anbieten.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        
        // TEST 7 (61-70) - bitta audio
        const HorenQuestion(
          audioTitle: 'Aufgabe 61',
          audioUrl: _b1t2test7,
          question: 'Der Markt am Rathausplatz findet nur einmal pro Woche statt.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 62',
          audioUrl: _b1t2test7,
          question: 'Auf dem Markt verkaufen nicht nur Bauern ihre Waren.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 63',
          audioUrl: _b1t2test7,
          question: 'Die späten Öffnungszeiten am Donnerstag sind vor allem für Berufstätige gedacht.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 64',
          audioUrl: _b1t2test7,
          question: 'Im Winter fehlen auf dem Markt vor allem Käse- und Brotstände.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 65',
          audioUrl: _b1t2test7,
          question: 'Einige Verkäufer kommen aus Orten in der Umgebung.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 66',
          audioUrl: _b1t2test7,
          question: 'Neue Anbieter müssen im ersten Jahr mehr Standgebühr bezahlen als die anderen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 67',
          audioUrl: _b1t2test7,
          question: 'Bei starkem Regen kommen oft weniger Kunden auf den Markt.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 68',
          audioUrl: _b1t2test7,
          question: 'Ab nächstem Monat soll es auf dem Markt einmal im Monat eine Kochvorführung geben.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 69',
          audioUrl: _b1t2test7,
          question: 'Frau König glaubt, dass der Markt nur für Touristen interessant ist.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 70',
          audioUrl: _b1t2test7,
          question: 'Der Donnerstagmarkt dauert länger als der Samstagsmarkt am Vormittag.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        
        // TEST 8 (71-80) - bitta audio
        const HorenQuestion(
          audioTitle: 'Aufgabe 71',
          audioUrl: _b1t2test8,
          question: 'Die Schülerzeitung gibt es schon seit fünf Jahren.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 72',
          audioUrl: _b1t2test8,
          question: 'Nur die Lehrerin entscheidet über die Themen der Zeitung.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 73',
          audioUrl: _b1t2test8,
          question: 'Vor dem Druck trifft sich die Redaktion manchmal öfter als einmal pro Woche.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 74',
          audioUrl: _b1t2test8,
          question: 'Auf der Internetseite erscheinen öfter kurze Beiträge als in der gedruckten Zeitung.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 75',
          audioUrl: _b1t2test8,
          question: 'Erfahrene Schüler helfen neuen Mitgliedern beim Einstieg.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 76',
          audioUrl: _b1t2test8,
          question: 'Die gedruckte Zeitung erscheint jeden Monat.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 77',
          audioUrl: _b1t2test8,
          question: 'Kurz vor dem Druck hat die Redaktion oft zu wenig Zeit.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 78',
          audioUrl: _b1t2test8,
          question: 'Das größte Problem der Redaktion ist, überhaupt Themen zu finden.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 79',
          audioUrl: _b1t2test8,
          question: 'Im nächsten Jahr soll es zusätzlich auch einen Podcast geben.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 80',
          audioUrl: _b1t2test8,
          question: 'Bei der Schülerzeitung dürfen nur ältere Schüler mitmachen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        
        // TEST 9 (81-90) - bitta audio
        const HorenQuestion(
          audioTitle: 'Aufgabe 81',
          audioUrl: _b1t2test9,
          question: 'Vor der Eröffnung musste der Raum erst wieder hergerichtet werden.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 82',
          audioUrl: _b1t2test9,
          question: 'Im Repair-Café werden ausschließlich Elektrogeräte repariert.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 83',
          audioUrl: _b1t2test9,
          question: 'Etwa die Hälfte der laufenden Kosten wird durch Spenden gedeckt.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 84',
          audioUrl: _b1t2test9,
          question: 'Nur fünf der zwölf Ehrenamtlichen haben einen handwerklichen Beruf gelernt.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 85',
          audioUrl: _b1t2test9,
          question: 'Die Besucher sollen im Repair-Café möglichst auch selbst mitarbeiten.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 86',
          audioUrl: _b1t2test9,
          question: 'Schulklassen kommen in der Werkstatt nur zum Zuschauen vorbei.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 87',
          audioUrl: _b1t2test9,
          question: 'Im Alltag ist es am schwierigsten, genügend Helfer zu finden.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 88',
          audioUrl: _b1t2test9,
          question: 'Seit dem Frühjahr gibt es zusätzlich einen Termin am Mittwochabend.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 89',
          audioUrl: _b1t2test9,
          question: 'Die Stadt trägt die Kosten des Projekts allein.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 90',
          audioUrl: _b1t2test9,
          question: 'Künftig sollen dort auch funktionierende Geräte weitergegeben werden.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        
        // TEST 10 (91-100) - bitta audio
        const HorenQuestion(
          audioTitle: 'Aufgabe 91',
          audioUrl: _b1t2test10,
          question: 'Das Sprachcafé ist vor allem als zusätzlicher Grammatikunterricht gedacht.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 92',
          audioUrl: _b1t2test10,
          question: 'An den Treffen nehmen auch Leute aus dem Viertel teil, die selbst kein Deutsch lernen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 93',
          audioUrl: _b1t2test10,
          question: 'Für die normalen Treffen muss man sich vorher anmelden.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 94',
          audioUrl: _b1t2test10,
          question: 'Der Freitagstermin ist besonders für Menschen gedacht, die abends schwer Zeit haben.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 95',
          audioUrl: _b1t2test10,
          question: 'Meistens sitzen heute noch alle Teilnehmer an einem einzigen großen Tisch.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 96',
          audioUrl: _b1t2test10,
          question: 'Nur zwei Gesprächsleiter arbeiten direkt in der Bibliothek.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 97',
          audioUrl: _b1t2test10,
          question: 'Ohne die Unterstützung der Stadt könnte das Sprachcafé nicht so regelmäßig stattfinden.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 98',
          audioUrl: _b1t2test10,
          question: 'Für Kinder wurde ein eigener Betreuungsraum eingerichtet.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 99',
          audioUrl: _b1t2test10,
          question: 'Am schwierigsten ist es, immer neue Gesprächsthemen zu finden.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 100',
          audioUrl: _b1t2test10,
          question: 'Im Sommer sollen Wörter direkt an Orten in der Stadt geübt werden.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
      ],
    ),

    // ── Teil 3 – Alltagsgespräch (10 TESTS × 5 savollar = 50 savol) ──────────
    HorenTeil(
      teilNumber: 3,
      questions: [
        // TEST 1 (1-5)
        const HorenQuestion(
          audioTitle: 'Aufgabe 1',
          audioUrl: _b1t3q1,
          question: 'Im Stadtmuseum ist der Eintritt ab 18 Uhr frei.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 2',
          audioUrl: _b1t3q2,
          question: 'Im Westen wird es am Nachmittag wieder sonnig.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 3',
          audioUrl: _b1t3q3,
          question: 'Der Bus zum Klinikum hält heute am Bahnhofplatz.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 4',
          audioUrl: _b1t3q4,
          question: 'Der Monteur kommt am Freitag nach 14 Uhr.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 5',
          audioUrl: _b1t3q5,
          question: 'Birnen sind heute billiger als Äpfel.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        
        // TEST 2 (6-10)
        const HorenQuestion(
          audioTitle: 'Aufgabe 6',
          audioUrl: _b1t3q6,
          question: 'Fahrgäste nach Bad Tölz fahren mit dem Zug von Gleis 22 weiter.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 7',
          audioUrl: _b1t3q7,
          question: 'Das Straßenfest beginnt schon am Freitagvormittag.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 8',
          audioUrl: _b1t3q8,
          question: 'Am Donnerstagnachmittag bleibt die Praxis geschlossen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 9',
          audioUrl: _b1t3q9,
          question: 'Der Junge wurde gestern Nachmittag in der Nähe des Hauptbahnhofs gesehen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 10',
          audioUrl: _b1t3q10,
          question: '29 Euro kostet heute eine Damenjacke aus der Frühlingskollektion.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        
        // TEST 3 (11-15)
        const HorenQuestion(
          audioTitle: 'Aufgabe 11',
          audioUrl: _b1t3q11,
          question: 'Die Lesung findet im ersten Stock statt.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 12',
          audioUrl: _b1t3q12,
          question: 'Passagiere nach Wien sollen sofort zu Gate 12 gehen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 13',
          audioUrl: _b1t3q13,
          question: 'Zwischen Ulm-West und Ulm-Ost ist nur eine Spur frei.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 14',
          audioUrl: _b1t3q14,
          question: 'Kinder unter sechs Jahren zahlen am Samstag keinen Eintritt.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 15',
          audioUrl: _b1t3q15,
          question: 'Das Treffen beginnt jetzt schon um 18 Uhr.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        
        // TEST 4 (16-20)
        const HorenQuestion(
          audioTitle: 'Aufgabe 16',
          audioUrl: _b1t3q16,
          question: 'Der Film "Luna" beginnt um 20.30 Uhr.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 17',
          audioUrl: _b1t3q17,
          question: 'Im Süden bleibt es am Abend trocken.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 18',
          audioUrl: _b1t3q18,
          question: 'Im Zugbistro gibt es heute keine warmen Speisen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 19',
          audioUrl: _b1t3q19,
          question: 'Das Fahrrad kann ab morgen abgeholt werden.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 20',
          audioUrl: _b1t3q20,
          question: 'Die Führung durch das Gewächshaus kostet extra.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        
        // TEST 5 (21-25)
        const HorenQuestion(
          audioTitle: 'Aufgabe 21',
          audioUrl: _b1t3q21,
          question: 'Das Sonderangebot für Kaffee gilt bis Samstag.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 22',
          audioUrl: _b1t3q22,
          question: 'Die Haltestelle Rathaus wird nur heute nicht angefahren.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 23',
          audioUrl: _b1t3q23,
          question: 'Der Hauptpreis ist ein Hamburg-Wochenende mit Musicalbesuch.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 24',
          audioUrl: _b1t3q24,
          question: 'Für den Elternabend soll man den Eingang an der Turnhalle benutzen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 25',
          audioUrl: _b1t3q25,
          question: 'Am Sonntag ist die Ausstellung bis 18 Uhr geöffnet.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        
        // TEST 6 (26-30)
        const HorenQuestion(
          audioTitle: 'Aufgabe 26',
          audioUrl: _b1t3q26,
          question: 'In Norddeutschland kann es am Morgen glatt werden.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 27',
          audioUrl: _b1t3q27,
          question: 'Fahrgäste nach Freiburg steigen in Offenburg aus.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 28',
          audioUrl: _b1t3q28,
          question: 'Beim Kauf von drei Joghurts ist der billigste gratis.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 29',
          audioUrl: _b1t3q29,
          question: 'Der Hund soll heute nüchtern in die Praxis kommen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 30',
          audioUrl: _b1t3q30,
          question: 'Schüler bekommen 50 Prozent Ermäßigung.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        
        // TEST 7 (31-35)
        const HorenQuestion(
          audioTitle: 'Aufgabe 31',
          audioUrl: _b1t3q31,
          question: 'Die Fahrgäste sollen heute zur Haltestelle Opernhaus gehen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 32',
          audioUrl: _b1t3q32,
          question: 'Am Bodensee wird es am Nachmittag freundlicher.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 33',
          audioUrl: _b1t3q33,
          question: 'Der Italienischkurs beginnt schon am 28. April.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 34',
          audioUrl: _b1t3q34,
          question: 'Die Jacke kann schon am Freitagvormittag abgeholt werden.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 35',
          audioUrl: _b1t3q35,
          question: 'Die Sonderangebote gibt es in der Modeabteilung im ersten Stock.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        
        // TEST 8 (36-40)
        const HorenQuestion(
          audioTitle: 'Aufgabe 36',
          audioUrl: _b1t3q36,
          question: 'Wer nach Koblenz weiterfahren will, muss in Mainz umsteigen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 37',
          audioUrl: _b1t3q37,
          question: 'Die Ausstellung ist auch montags geöffnet.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 38',
          audioUrl: _b1t3q38,
          question: 'In Norddeutschland kann es in der Nacht Frost geben.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 39',
          audioUrl: _b1t3q39,
          question: 'Herr Berger kann sein Fahrrad morgen erst ab 10 Uhr abholen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 40',
          audioUrl: _b1t3q40,
          question: 'Nur Kinder unter zehn Jahren kommen heute kostenlos in den Zoo.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        
        // TEST 9 (41-45)
        const HorenQuestion(
          audioTitle: 'Aufgabe 41',
          audioUrl: _b1t3q41,
          question: 'Morgen sind im Hallenbad vor 15 Uhr alle Becken geschlossen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 42',
          audioUrl: _b1t3q42,
          question: 'Frau Weber kann das Paket auch am Samstagvormittag abholen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 43',
          audioUrl: _b1t3q43,
          question: 'Vor dem Konzert kann man in der Musikschule Instrumente ausprobieren.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 44',
          audioUrl: _b1t3q44,
          question: 'Auch die Einfahrt über den Markt ist heute gesperrt.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 45',
          audioUrl: _b1t3q45,
          question: 'Am Samstag schließt der Recyclinghof früher als an den Werktagen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        
        // TEST 10 (46-50)
        const HorenQuestion(
          audioTitle: 'Aufgabe 46',
          audioUrl: _b1t3q46,
          question: 'Wer sich schon angemeldet hat, muss sich für heute nicht noch einmal melden.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 47',
          audioUrl: _b1t3q47,
          question: 'Herr Özdemir muss sich spätestens um 20 Uhr im Hotel melden.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 48',
          audioUrl: _b1t3q48,
          question: 'Wer zum ersten Mal Blut spendet, kann noch bis 19 Uhr kommen.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Falsch',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 49',
          audioUrl: _b1t3q49,
          question: 'Bereits gekaufte Nachmittagskarten gelten auch morgen noch.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
        const HorenQuestion(
          audioTitle: 'Aufgabe 50',
          audioUrl: _b1t3q50,
          question: 'Auch vor 10 Uhr kann man ausgeliehene Medien zurückgeben.',
          options: ['Richtig', 'Falsch'],
          correctAnswer: 'Richtig',
        ),
      ],
    ),
  ],
);
