import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/video_models.dart';

class VideoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch videos from the 'videos' collection in Firestore.
  Future<List<GermanVideo>> getVideos() async {
    try {
      final snapshot = await _firestore.collection('videos').get();
      if (snapshot.docs.isEmpty) {
        // Fallback to local mock list if Firestore is empty
        return _mockGermanVideosList;
      }
      return snapshot.docs.map((doc) => GermanVideo.fromJson(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint('Error fetching videos from Firestore: ');
      // Fallback to local mock list in case of network/permission errors
      return _mockGermanVideosList;
    }
  }
}

/// Fallback Nicos Weg A1, A2, B1 va Easy German individual seriyalari bazasi
final List<GermanVideo> _mockGermanVideosList = [
  // 1. Nicos Weg A1 - Folge 1: Hallo!
  const GermanVideo(
    id: 'nicos_weg_a1_f1',
    title: 'Nicos Weg A1 - Folge 1: Hallo!',
    level: 'A1',
    category: 'Nicos Weg',
    youtubeId: '4-eDoThe6qo',
    durationText: '1:45',
    description: 'Nico aeroportga yetib keladi va o\'zini tanishtiradi.',
    subtitles: [
      SubtitleSegment(
        startTimeSec: 4.0,
        endTimeSec: 5.5,
        textDe: 'Hallo!',
        words: [
          GermanWord(wordDe: 'Hallo!', transUz: 'Salom!', transKaa: 'Sálem!', transRu: 'Привет!'),
        ],
      ),
      SubtitleSegment(
        startTimeSec: 8.0,
        endTimeSec: 12.0,
        textDe: 'Ich heiße Emma. Wie heißt du?',
        words: [
          GermanWord(wordDe: 'Ich', transUz: 'Men', transKaa: 'Men', transRu: 'Я'),
          GermanWord(wordDe: 'heiße', transUz: 'ismim ...', transKaa: 'atım ...', transRu: 'зовут ...'),
          GermanWord(wordDe: 'Emma.', transUz: 'Emma.', transKaa: 'Emma.', transRu: 'Эмма.'),
        ],
      ),
    ],
    quizQuestions: [],
  ),
  // 2. Nicos Weg A1 - Folge 2: Koffer weg!
  const GermanVideo(
    id: 'nicos_weg_a1_f2',
    title: 'Nicos Weg A1 - Der ganze Film',
    level: 'A1',
    category: 'Nicos Weg',
    youtubeId: 'w1X_VovwIu8',
    durationText: '1:43:55',
    description: 'Nicos Weg A1 darajasi uchun to\'liq film.',
    subtitles: [],
    quizQuestions: [],
  ),
];
