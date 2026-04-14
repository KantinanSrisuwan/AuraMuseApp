import 'package:cloud_firestore/cloud_firestore.dart';

// Model สำหรับ Deck
class DeckModel {
  final String id;
  final String deckName;
  final String coverImage;
  final String creatorId;
  final String creatorUsername;
  final int viewCount;
  final int drawCount;
  final DateTime createdAt;
  final int cardCount;
  final String status;

  DeckModel({
    required this.id,
    required this.deckName,
    required this.coverImage,
    required this.creatorId,
    required this.creatorUsername,
    required this.viewCount,
    required this.drawCount,
    required this.createdAt,
    required this.cardCount,
    this.status = 'pending',
  });

  factory DeckModel.fromFirestore(DocumentSnapshot doc, int cardCount) {
    final data = doc.data() as Map<String, dynamic>;
    return DeckModel(
      id: doc.id,
      deckName: data['deck_name'] ?? 'ไม่มีชื่อ',
      coverImage: data['cover_image'] ?? '',
      creatorId: data['creator_id'] ?? '',
      creatorUsername: data['creator_username'] ?? 'ไม่ระบุ',
      viewCount: data['view_count'] ?? 0,
      drawCount: data['draw_count'] ?? 0,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cardCount: cardCount,
      status: data['status'] ?? 'pending',
    );
  }
}

// Firestore Service
class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ดึง Decks ทั้งหมด พร้อมจำนวน Cards
  static Future<List<DeckModel>> getAllDecks() async {
    try {
      final snapshot = await _db.collection('decks').get();
      List<DeckModel> decks = [];

      for (var doc in snapshot.docs) {
        // ดึงจำนวน cards จาก sub-collection
        final cardsSnapshot = await _db
            .collection('decks')
            .doc(doc.id)
            .collection('cards')
            .get();

        final deck = DeckModel.fromFirestore(doc, cardsSnapshot.docs.length);
        decks.add(deck);
      }

      return decks;
    } catch (e) {
      print('Error fetching decks: $e');
      return [];
    }
  }

  // ดึง Decks ของ User
  static Future<List<DeckModel>> getDecksByCreator(String creatorId) async {
    try {
      final snapshot = await _db
          .collection('decks')
          .where('creator_id', isEqualTo: creatorId)
          .get();
      List<DeckModel> decks = [];

      for (var doc in snapshot.docs) {
        final cardsSnapshot = await _db
            .collection('decks')
            .doc(doc.id)
            .collection('cards')
            .get();

        final deck = DeckModel.fromFirestore(doc, cardsSnapshot.docs.length);
        decks.add(deck);
      }

      return decks;
    } catch (e) {
      print('Error fetching decks by creator: $e');
      return [];
    }
  }

  // ดึง Decks ของ User ตามสถานะ
    try {
      final snapshot = await _db
          .collection('decks')
          .where('status', isEqualTo: status)
          .get();
      List<DeckModel> decks = [];

      for (var doc in snapshot.docs) {
        final cardsSnapshot = await _db
            .collection('decks')
            .doc(doc.id)
            .collection('cards')
            .get();

        final deck = DeckModel.fromFirestore(doc, cardsSnapshot.docs.length);
        decks.add(deck);
      }

      return decks;
    } catch (e) {
      print('Error fetching decks by status: $e');
      return [];
    }
  }

  // Stream สำหรับ Real-time Decks (optional สำหรับความขึ้นต่อกันแบบ real-time)
  static Stream<List<DeckModel>> getDecksStream() {
    return _db.collection('decks').snapshots().asyncMap((snapshot) async {
      List<DeckModel> decks = [];
      for (var doc in snapshot.docs) {
        final cardsSnapshot = await _db
            .collection('decks')
            .doc(doc.id)
            .collection('cards')
            .get();

        final deck = DeckModel.fromFirestore(doc, cardsSnapshot.docs.length);
        decks.add(deck);
      }
      return decks;
    });
  }

  // ดึง Deck detail ตาม ID
  static Future<DeckModel?> getDeckById(String deckId) async {
    try {
      final doc = await _db.collection('decks').doc(deckId).get();
      if (!doc.exists) return null;

      final cardsSnapshot =
          await _db.collection('decks').doc(deckId).collection('cards').get();

      return DeckModel.fromFirestore(doc, cardsSnapshot.docs.length);
    } catch (e) {
      print('Error fetching deck: $e');
      return null;
    }
  }

  // ดึง Cards ของ Deck
  static Future<List<Map<String, dynamic>>> getCardsByDeckId(
      String deckId) async {
    try {
      final snapshot = await _db
          .collection('decks')
          .doc(deckId)
          .collection('cards')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching cards: $e');
      return [];
    }
  }

  // ลบ Deck
  static Future<bool> deleteDeck(String deckId) async {
    try {
      // ลบ sub-collection cards ก่อน
      final cardsSnapshot = await _db
          .collection('decks')
          .doc(deckId)
          .collection('cards')
          .get();

      for (var cardDoc in cardsSnapshot.docs) {
        await cardDoc.reference.delete();
      }

      // ลบ deck document
      await _db.collection('decks').doc(deckId).delete();

      return true;
    } catch (e) {
      print('Error deleting deck: $e');
      return false;
    }
  }

  // ดึง Users ทั้งหมด
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final snapshot = await _db.collection('users').get();
      return snapshot.docs.map((doc) {
        return {
          'uid': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // ดึง User detail ตาม UID
  static Future<Map<String, dynamic>?> getUserById(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      return {
        'uid': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // Update View Count ของ Deck
  static Future<void> incrementViewCount(String deckId) async {
    try {
      await _db.collection('decks').doc(deckId).update({
        'view_count': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  // Update Draw Count ของ Deck
  static Future<void> incrementDrawCount(String deckId) async {
    try {
      await _db.collection('decks').doc(deckId).update({
        'draw_count': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing draw count: $e');
    }
  }

  // Update User info
  static Future<bool> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update(data);
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // ลบ User
  static Future<bool> deleteUser(String uid) async {
    try {
      await _db.collection('users').doc(uid).delete();
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Model สำหรับ Report
  static Future<List<Map<String, dynamic>>> getAllReports() async {
    try {
      final snapshot = await _db.collection('reports').get();
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      print('Error fetching reports: $e');
      return [];
    }
  }

  // ดึง Report detail
  static Future<Map<String, dynamic>?> getReportById(String reportId) async {
    try {
      final doc = await _db.collection('reports').doc(reportId).get();
      if (!doc.exists) return null;

      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    } catch (e) {
      print('Error fetching report: $e');
      return null;
    }
  }

  // สร้าง Report ใหม่
  static Future<bool> createReport({
    required String deckId,
    required String reportedByUid,
    required String reason,
  }) async {
    try {
      await _db.collection('reports').add({
        'deck_id': deckId,
        'reported_by_uid': reportedByUid,
        'reason': reason,
        'created_at': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, approved, rejected
      });
      return true;
    } catch (e) {
      print('Error creating report: $e');
      return false;
    }
  }

  // อัปเดต Report status
  static Future<bool> updateReportStatus(String reportId, String status) async {
    try {
      await _db.collection('reports').doc(reportId).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating report: $e');
      return false;
    }
  }

  // ลบ Report
  static Future<bool> deleteReport(String reportId) async {
    try {
      await _db.collection('reports').doc(reportId).delete();
      return true;
    } catch (e) {
      print('Error deleting report: $e');
      return false;
    }
  }
