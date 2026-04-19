import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palette_generator/palette_generator.dart'; // ตัวดึงสีจากรูป
import 'dart:math';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/flippable_card.dart';

class DrawResultPage extends StatefulWidget {
  final String deckId;
  final String deckName;
  final String? cardId; // Optional: specific card to display
  const DrawResultPage({
    super.key,
    required this.deckId,
    required this.deckName,
    this.cardId, // If provided, show this specific card. If not, show random
  });

  @override
  State<DrawResultPage> createState() => _DrawResultPageState();
}

class _DrawResultPageState extends State<DrawResultPage> {
  // 1. ตัวแปรเก็บสีที่ดึงมาจากรูปภาพ (เริ่มด้วย List ว่าง)
  List<Color> _extractedPalette = [];
  
  // ตัวแปรเก็บไพ่ที่สุ่มได้
  String _imageUrl = '';
  String _cardText = 'กำลังโหลด...';
  bool _isFirstDraw = true; // ตัวแปรย่อมรู้ว่าครั้งแรกที่เปิดหน้า
  
  // Firebase reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // สั่งให้ดึงไพ่แบบสุ่มทันทีเมื่อเข้าหน้านี้
    _fetchRandomCard();
  }

  // ฟังก์ชันเพิ่ม draw_count ของ deck
  Future<void> _incrementDrawCount() async {
    try {
      if (widget.deckId.isEmpty) return;

      await _firestore.collection('decks').doc(widget.deckId).update({
        'draw_count': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing draw_count: $e');
    }
  }

  // ฟังก์ชันดึงไพ่แบบสุ่มจาก sub-collection (หรือไพ่ที่ระบุ หากมี cardId)
  Future<void> _fetchRandomCard() async {
    try {
      late DocumentSnapshot cardSnapshot;

      // ถ้ามี cardId ให้ดึงไพ่นั้นโดยตรง
      if (widget.cardId != null && widget.cardId!.isNotEmpty) {
        cardSnapshot = await _firestore
            .collection('decks')
            .doc(widget.deckId)
            .collection('cards')
            .doc(widget.cardId!)
            .get();
      } else {
        // ถ้าไม่มี cardId ให้สุ่มไพ่แบบปกติ
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
        cardSnapshot = cardsSnapshot.docs[Random().nextInt(cardsSnapshot.docs.length)];
      }

      if (!mounted) return;
      
      if (!cardSnapshot.exists) {
        setState(() {
          _cardText = 'ไม่พบไพ่นี้';
        });
        return;
      }

      setState(() {
        _imageUrl = cardSnapshot['front_image'] ?? '';
        _cardText = cardSnapshot['back_text'] ?? 'ไม่มีข้อมูล';
      });

      // เพิ่ม draw_count เฉพาะครั้งแรกเมื่อเข้าหน้า
      if (_isFirstDraw) {
        _isFirstDraw = false;
        _incrementDrawCount();
      }

      // ดึงสีจากรูปภาพ
      if (_imageUrl.isNotEmpty) {
        _generatePalette();
      }
    } catch (e) {
      if (!mounted) return;
      print('Error fetching card: $e');
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
        List<Color> colors = generator.colors.toList();
        // เรียงสีจากสว่างที่สุดไปมืดที่สุด
        colors.sort((a, b) => b.computeLuminance().compareTo(a.computeLuminance()));
        _extractedPalette = colors;
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
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.cosmicGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  "ผลลัพธ์จาก ${widget.deckName}",
                  style: const TextStyle(color: AppColors.cosmicCyan, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                centerTitle: true,
              ).animate().fadeIn(duration: 400.ms),
              Expanded(
                child: Center(
                  child: Hero(
                    tag: 'deck_card_${widget.deckId}',
                    child: FlippableCard(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: MediaQuery.of(context).size.height * 0.75,
                      backText: _cardText,
                      palette: _extractedPalette.isEmpty 
                          ? [AppColors.cosmicPurple]
                          : _extractedPalette,
                      front: _buildFrontSide(),
                    ),
                  ),
                ).animate().scale(curve: Curves.easeOutQuart),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ส่วนของการแสดงหน้าไพ่
  Widget _buildFrontSide() {
    // ถ้าไม่พบไพ่ให้แสดงข้อความแทน
    if (_cardText == 'ไม่พบไพ่ในเด็คนี้' || _cardText == 'ไม่พบไพ่นี้') {
      return Container(
        decoration: AppColors.glassDecoration(radius: 24),
        child: Center(
          child: Text(
            _cardText,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textWhiteMuted, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.cosmicCyan.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: _imageUrl.isEmpty
            ? Container(
                decoration: AppColors.glassDecoration(radius: 24),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.cosmicCyan),
                ),
              )
            : Image.network(
                _imageUrl,
                fit: BoxFit.cover,
                // เพิ่ม Loading สวยๆ ระหว่างรอรูป
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: AppColors.glassDecoration(radius: 24),
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.cosmicCyan),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: AppColors.glassDecoration(radius: 24),
                    child: const Center(
                      child: Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
                    ),
                  );
                },
              ),
      ),
    );
  }
}