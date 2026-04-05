import 'package:flutter/material.dart';
import '../widgets/admin_drawer.dart';

class AdminDeck extends StatefulWidget {
  const AdminDeck({super.key});

  @override
  State<AdminDeck> createState() => _AdminDeckState();
}

class _AdminDeckState extends State<AdminDeck> {
  // 1. สร้าง GlobalKey เพื่อคุม Scaffold (ทำให้ปุ่ม Burger Bar กดติดชัวร์ 100%)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // 2. ผูก Key เข้ากับ Scaffold
      backgroundColor: const Color(0xFF13112B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 30),
          onPressed: () {
            // 3. สั่งเปิด Drawer ผ่าน Key
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: const AdminDrawer(currentRoute: 'Deck'),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            "สำรับทั้งหมด",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildDeckItem(
                  deckId: "1082",
                  cardCount: "7",
                  deckName: "บทกวีแห่งพงไพร",
                  dateCreated: "08/03/2026",
                ),
                _buildDeckItem(
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

  // Widget ย่อยสำหรับรายการ Deck
  Widget _buildDeckItem({
    required String deckId,
    required String cardCount,
    required String deckName,
    required String dateCreated,
  }) {
    return InkWell( // 1. ครอบด้วย InkWell เพื่อให้กดได้และมีเอฟเฟกต์ Ripple
      onTap: () {
        // 2. สั่งนำทางไปหน้าละเอียด (ตัวอย่าง: AdminRoutes.adminDeckDetail)
        // ตอนนี้ผมใส่ Print ไว้ให้เช็คก่อนนะครับว่ากดติดไหม
        print("กำลังไปที่หน้าละเอียดของสำรับหมายเลข: $deckId");
        
        // เมื่อคุณสร้างหน้าละเอียดเสร็จแล้ว ให้ใช้คำสั่งนี้:
        // Navigator.pushNamed(context, AdminRoutes.adminDeckDetail, arguments: deckId);
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
            // ส่วนรูปด้านซ้าย
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF4A3AFF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.style, color: Colors.white30, size: 50),
            ),
            const SizedBox(width: 15),
            // ส่วนข้อมูลด้านขวา
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "หมายเลขเด็ค : $deckId   จำนวนการ์ด : $cardCount ใบ",
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