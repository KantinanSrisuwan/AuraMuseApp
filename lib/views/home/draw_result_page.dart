import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart'; // ตัวดึงสีจากรูป
import '../../core/constants/app_colors.dart';
import '../widgets/flippable_card.dart';

class DrawResultPage extends StatefulWidget {
  final String deckName;
  const DrawResultPage({super.key, required this.deckName});

  @override
  State<DrawResultPage> createState() => _DrawResultPageState();
}

class _DrawResultPageState extends State<DrawResultPage> {
  // 1. ตัวแปรเก็บสีที่ดึงมาจากรูปภาพ (เริ่มด้วย List ว่าง)
  List<Color> _extractedPalette = [];
  
  // 2. URL รูปหน้าไพ่ (ในอนาคตจะเปลี่ยนเป็นตัวแปรที่รับมาจาก Database)
  final String _imageUrl = 'https://picsum.photos/seed/tree/600/1000';

  @override
  void initState() {
    super.initState();
    // 3. สั่งให้เริ่มดึงสีทันทีเมื่อเข้าหน้านี้
    _generatePalette();
  }

  // 4. ฟังก์ชันอัจฉริยะ: ดึงสีเด่นจากรูปภาพแบบอัตโนมัติ
  Future<void> _generatePalette() async {
    try {
      final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
        NetworkImage(_imageUrl),
        maximumColorCount: 5, // ขอสีที่เด่นที่สุด 5 สี
      );

      setState(() {
        // ดึงสีทั้งหมดที่หาได้มาใส่ใน List
        _extractedPalette = generator.colors.toList();
      });
    } catch (e) {
      // กรณีโหลดรูปไม่ขึ้น ให้ใช้สีเทาเป็นค่าเริ่มต้น
      setState(() {
        _extractedPalette = [Colors.grey, Colors.blueGrey];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Mock Database Text ---
    const String mockDatabaseText = 
        "วิญญาณศิลปินจะตื่นรู้\nเมื่อมองดูดวงดาราที่พร่างพราย\nจงสร้างสรรค์งานศิลป์ที่ไม่มีวันตาย\nด้วยหัวใจที่เปี่ยมไปด้วยศรัทธา";

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
          tag: 'deck_card_${widget.deckName}',
          child: FlippableCard(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.75,
            backText: mockDatabaseText,
            // 5. ส่งสีที่ดึงมาได้เข้าไป ถ้ายังดึงไม่เสร็จให้ส่ง List ว่างไปก่อน
            palette: _extractedPalette.isEmpty 
                ? [const Color(0xFF1E2140)] // สีพื้นระว่างรอโหลด
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
      child: Image.network(
        _imageUrl,
        fit: BoxFit.cover,
        // เพิ่ม Loading สวยๆ ระหว่างรอรูป
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        },
      ),
    );
  }
}