import 'package:flutter/material.dart';
import '../widgets/admin_drawer.dart';

class AdminVerified extends StatefulWidget {
  const AdminVerified({super.key});

  @override
  State<AdminVerified> createState() => _AdminVerifiedState();
}

class _AdminVerifiedState extends State<AdminVerified> {
  // ใช้ GlobalKey เพื่อคุม Scaffold ให้เปิด Drawer ได้แม่นยำ
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF13112B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 30),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      // ไฮไลท์ที่เมนู 'Verified'
      drawer: const AdminDrawer(currentRoute: 'Verified'),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            "สำรับที่รอการตรวจสอบ",
            style: TextStyle(
              color: Colors.white, 
              fontSize: 22, 
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildVerifiedItem(
                  deckId: "1087",
                  cardCount: "15",
                  deckName: "ความสงบและเที่ยงธรรม",
                  dateCreated: "08/03/2026",
                ),
                _buildVerifiedItem(
                  deckId: "1083",
                  cardCount: "15",
                  deckName: "บทนำสู่ความรุ่งโรจน์",
                  dateCreated: "06/03/2026",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget สำหรับบล็อกสำรับที่รอตรวจ
  Widget _buildVerifiedItem({
    required String deckId,
    required String cardCount,
    required String deckName,
    required String dateCreated,
  }) {
    return InkWell(
      onTap: () {
        print("เข้าสู่โหมดตรวจสอบสำรับหมายเลข: $deckId");
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFF13112B), width: 8),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปตัวอย่างสำรับ (ไอคอนสีม่วง/น้ำเงิน)
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF4A3AFF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.verified_user_outlined, color: Colors.white30, size: 50),
            ),
            const SizedBox(width: 15),
            // รายละเอียดข้อมูล
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "หมายเลขเด็ค : $deckId   จำนวนการ์ดในสำรับ : $cardCount ใบ",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Text("ชื่อสำรับ : $deckName", style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 5),
                  Text(
                    "วันที่สร้าง : $dateCreated",
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
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