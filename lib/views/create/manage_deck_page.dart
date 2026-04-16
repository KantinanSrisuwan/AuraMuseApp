import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import 'edit_deck_page.dart';

class ManageDeckPage extends StatefulWidget {
  const ManageDeckPage({super.key});

  @override
  State<ManageDeckPage> createState() => _ManageDeckPageState();
}

class _ManageDeckPageState extends State<ManageDeckPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream function สำหรับ real-time monitoring
  Stream<List<DocumentSnapshot>> _getMyDecksStream() async* {
    final user = _auth.currentUser;
    if (user == null) {
      yield [];
      return;
    }

    // Listen ที่ user document เพื่อได้ my_decks array ที่เปลี่ยนแปลง
    yield* _firestore.collection('users').doc(user.uid).snapshots().asyncMap(
      (userDoc) async {
        if (!userDoc.exists) return [];

        final myDeckIds = List<String>.from(userDoc['my_decks'] ?? []);
        if (myDeckIds.isEmpty) return [];

        // ดึง deck documents ทั้งหมด
        List<DocumentSnapshot> decks = [];
        for (String deckId in myDeckIds) {
          try {
            final deckDoc = await _firestore.collection('decks').doc(deckId).get();
            if (deckDoc.exists) {
              decks.add(deckDoc);
            }
          } catch (e) {
            print('Error fetching deck: $e');
          }
        }
        return decks;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("จัดการสำรับของฉัน", 
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: StreamBuilder<List<DocumentSnapshot>>(
                stream: _getMyDecksStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'เกิดข้อผิดพลาด',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final decks = snapshot.data ?? [];

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: decks.length + 1, // รวมปุ่มเพิ่มท้ายที่สุด
                    itemBuilder: (context, index) {
                      if (index == decks.length) {
                        return _buildAddBtn(context);
                      }
                      return _buildDeckItem(context, decks[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddBtn(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // รอให้ EditDeckPage เสร็จ (สร้าง deck ใหม่โดยไม่ระบุ deckId)
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditDeckPage()),
        );
        // หลังจากกลับมา ให้ setState เพื่อ rebuild Stream
        if (mounted) {
          setState(() {});
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.add, color: Colors.white24, size: 40),
      ),
    );
  }

  Widget _buildDeckItem(BuildContext context, DocumentSnapshot deck) {
    final String coverImage = deck['cover_image'] ?? '';
    final String deckId = deck.id;

    return GestureDetector(
      onTap: () async {
        // รอให้ EditDeckPage เสร็จ
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditDeckPage(deckId: deckId)),
        );
        // หลังจากกลับมา ให้ setState เพื่อ rebuild Stream
        if (mounted) {
          setState(() {});
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: coverImage.isNotEmpty
            ? Image.network(
                coverImage,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    Container(
                      color: Colors.grey[800],
                      child: const Center(child: Icon(Icons.image_not_supported, color: Colors.white30)),
                    ),
              )
            : Container(
                color: Colors.grey[800],
                child: const Center(child: Icon(Icons.image_not_supported, color: Colors.white30)),
              ),
      ),
    );
  }
}