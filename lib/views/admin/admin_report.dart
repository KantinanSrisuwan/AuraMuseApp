import 'package:flutter/material.dart';
import '../widgets/admin_drawer.dart';

class AdminReport extends StatefulWidget {
  const AdminReport({super.key});

  @override
  State<AdminReport> createState() => _AdminReportState();
}

class _AdminReportState extends State<AdminReport> {
  // กำหนดเมนูที่กำลังเลือกอยู่เป็น Report
  String currentRoute = 'Report';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13112B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const AdminDrawer(currentRoute: 'Report'),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            "การรายงาน",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // ส่วนรายการ Report (ใช้ Expanded เพื่อให้เลื่อนดูได้ถ้ารายการยาว)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              children: [
                _buildReportItem(
                  deckId: "1082",
                  cardCount: "7",
                  deckName: "บทกวีแห่งพงไพร",
                  description: "มีคำไม่เหมาะสมในบทกวี",
                  imageAsset: Icons.grid_view_rounded, // แทนรูปจริงของคุณ
                ),
                _buildReportItem(
                  deckId: "1083",
                  cardCount: "15",
                  deckName: "บทนำสู่ความรุ่งโรจน์",
                  description: "ผมไม่สามารถเข้าถึงข้อความ",
                  imageAsset: Icons.auto_awesome_mosaic,
                ),
                // เพิ่มรายการอื่นๆ ได้ที่นี่...
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget สำหรับแต่ละบล็อกรายงาน
  Widget _buildReportItem({
    required String deckId,
    required String cardCount,
    required String deckName,
    required String description,
    required IconData imageAsset,
  }) {
    return InkWell(
      onTap: () {
        // เมื่อกดจะไปที่หน้าละเอียด (เดี๋ยวเราสร้าง Route รองรับในอนาคต)
        print("ไปที่หน้าละเอียดของเด็ค $deckId");
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          color: Colors.white,
          // ทำเส้นขอบล่างให้ดูเหมือนในรูป
          border: Border(bottom: BorderSide(color: Color(0xFF13112B), width: 8)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนรูปด้านซ้าย
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF4A3AFF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(imageAsset, color: Colors.white30, size: 50),
            ),
            const SizedBox(width: 15),
            // ส่วนข้อมูลด้านขวา
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "หมายเลขเด็ค : $deckId   จำนวนการ์ดในสำรับ : $cardCount ใบ",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text("ชื่อสำรับ : $deckName", style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    "คำอธิบาย : $description",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    overflow: TextOverflow.ellipsis, // ตัดข้อความถ้ามันยาวเกินไป
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}