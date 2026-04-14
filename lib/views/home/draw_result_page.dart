import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palette_generator/palette_generator.dart'; // ตัวดึงสีจากรูป
import 'dart:math';
import '../../core/constants/app_colors.dart';
import '../widgets/flippable_card.dart';

class DrawResultPage extends StatefulWidget {
  final String deckId;
  final String deckName;
  const DrawResultPage({super.key, required this.deckId, required this.deckName});

  @override
  State<DrawResultPage> createState() => _DrawResultPageState();
}

class _DrawResultPageState extends State<DrawResultPage> {
  // 1. ตัวแปรเก็บสีที่ดึงมาจากรูปภาพ (เริ่มด้วย List ว่าง)
  List<Color> _extractedPalette = [];
  
  // ตัวแปรเก็บไพ่ที่สุ่มได้
  String _imageUrl = '';
  String _cardText = 'กำลังโหลด...';
  
  // Firebase reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // สั่งให้ดึงไพ่แบบสุ่มทันทีเมื่อเข้าหน้านี้
    _fetchRandomCard();
  }

  // ฟังก์ชันดึงไพ่แบบสุ่มจาก sub-collection
  Future<void> _fetchRandomCard() async {
    try {
      // ดึงทุกไพ่จาก sub-collection cards
      QuerySnapshot cardsSnapshot = await _firestore
          .collection('decks')
          .doc(widget.deckId)
          .collection('cards')
          .get();
      
      if (!mounted) return;

      if (cardsSnapshot.docs.isEmpty) {
        setState(() {
          _cardText = 'ไม่พบไพ่ในเด็คนี้';
        });
        return;
      }

      // สุ่มเลือกไพ่หนึ่งใบ
      final randomCard = cardsSnapshot.docs[Random().nextInt(cardsSnapshot.docs.length)];
      
      setState(() {
        _imageUrl = randomCard['front_image'] ?? '';
        _cardText = randomCard['back_text'] ?? 'ไม่มีข้อมูล';
      });

      // ดึงสีจากรูปภาพ
      if (_imageUrl.isNotEmpty) {
        _generatePalette();
      }
    } catch (e) {
      if (!mounted) return;
      print('Error fetching random card: $e');
      setState(() {
        _cardText = 'เกิดข้อผิดพลาด: $e';
      });
    }
  }

  // ฟังก์ชันอัจฉริยะ: ดึงสีเด่นจากรูปภาพแบบอัตโนมัติ
  Future<void> _generatePalette() async {
    try {
      final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
        NetworkImage(_imageUrl),
        maximumColorCount: 5, // ขอสีที่เด่นที่สุด 5 สี
      );

      if (!mounted) return;

      setState(() {
        // ดึงสีทั้งหมดที่หาได้มาใส่ใน List
        _extractedPalette = generator.colors.toList();
      });
    } catch (e) {
      // กรณีโหลดรูปไม่ขึ้น ให้ใช้สีเทาเป็นค่าเริ่มต้น
      if (!mounted) return;
      setState(() {
        _extractedPalette = [Colors.grey, Colors.blueGrey];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "ผลลัพธ์จาก ${widget.deckName}",
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
      body: Center(
        child: Hero(
          tag: 'deck_card_${widget.deckId}',
          child: FlippableCard(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.75,
            backText: _cardText,
            palette: _extractedPalette.isEmpty 
                ? [const Color(0xFF1E2140)]
                : _extractedPalette,
            front: _buildFrontSide(),
          ),
        ),
      ),
    );
  }

  // ส่วนของการแสดงหน้าไพ่
  Widget _buildFrontSide() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: _imageUrl.isEmpty
          ? Container(
              color: Colors.grey[800],
              child: const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ),
            )
          : Image.network(
              _imageUrl,
              fit: BoxFit.cover,
              // เพิ่ม Loading สวยๆ ระหว่างรอรูป
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.white, size: 50),
                  ),
                );
              },
            ),
    );
  }
}