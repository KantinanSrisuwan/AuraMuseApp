import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
// หมายเหตุ: อย่าลืมตรวจสอบ path ของ AdminRoutes ให้ตรงกับโปรเจกต์ของคุณนะครับ
import '../../core/routes/admin_routes.dart'; 

// --- Model สำหรับเก็บข้อมูลสำรับให้คงที่ ---
class DeckModel {
  final String id;
  final String name;
  final int cardCount;
  final String status;
  final bool isWaiting;
  final bool isPublic;

  DeckModel({
    required this.id,
    required this.name,
    required this.cardCount,
    required this.status,
    this.isWaiting = false,
    this.isPublic = false,
  });
}

// --- ตั้งค่าให้เมาส์คลิกลากได้ (สำหรับ Web) ---
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class AdminUserDetailPage extends StatefulWidget {
  const AdminUserDetailPage({super.key});
  @override
  State<AdminUserDetailPage> createState() => _AdminUserDetailPageState();
}

class _AdminUserDetailPageState extends State<AdminUserDetailPage> {
  // ข้อมูลสมมติของผู้ใช้
  String username = "ราชาคนุษยัยามดึก";
  String email = "tokjaiz01@gmail.com";
  int deckCategoryIndex = 0;
  final List<String> categories = ["สำรับที่รอการตรวจสอบ", "สำรับที่เผยแพร่สู่สาธารณะ", "สำรับส่วนตัว"];

  // List เก็บข้อมูลสำรับแยกตามประเภท (สุ่มแค่ครั้งเดียวตอน initState)
  List<DeckModel> waitingDecks = [];
  List<DeckModel> publicDecks = [];
  List<DeckModel> privateDecks = [];

  @override
  void initState() {
    super.initState();
    _initMockData();
  }

  // ฟังก์ชันสุ่มข้อมูลจำลอง (จะถูกเรียกครั้งเดียว ข้อมูลจะนิ่ง)
  void _initMockData() {
    final rand = Random();
    List<String> pool = ["คัมภีร์ลับ", "มนตราดำ", "แสงแห่งเทพ", "บทกวีพงไพร", "เงาจันทร์", "ตำนานมังกร"];
    
    // 1. สำรับรอตรวจสอบ
    waitingDecks = List.generate(4, (i) => DeckModel(
      id: "W-${100+i}", name: "${pool[rand.nextInt(pool.length)]} #${i+1}", 
      cardCount: 5 + rand.nextInt(15), status: "รอการตรวจสอบ", isWaiting: true
    ));
    // 2. สำรับสาธารณะ
    publicDecks = List.generate(7, (i) => DeckModel(
      id: "P-${200+i}", name: "${pool[rand.nextInt(pool.length)]} #${i+1}", 
      cardCount: 15 + rand.nextInt(15), status: "เผยแพร่แล้ว", isPublic: true
    ));
    // 3. สำรับส่วนตัว
    privateDecks = List.generate(3, (i) => DeckModel(
      id: "PV-${300+i}", name: "${pool[rand.nextInt(pool.length)]} #${i+1}", 
      cardCount: 10 + rand.nextInt(10), status: "ส่วนตัว"
    ));
  }

  @override
  Widget build(BuildContext context) {
    final dynamic args = ModalRoute.of(context)!.settings.arguments;
    List<DeckModel> activeList = deckCategoryIndex == 0 ? waitingDecks : (deckCategoryIndex == 1 ? publicDecks : privateDecks);

    return Scaffold(
      backgroundColor: const Color(0xFF13112B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), 
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: ScrollConfiguration(
        behavior: MyCustomScrollBehavior(),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfileHeader(args),
                  const SizedBox(height: 30),
                  _buildDeckSlider(activeList),
                  const SizedBox(height: 150), // เผื่อที่ให้ปุ่มด้านล่าง
                ],
              ),
            ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  // --- Widget: ส่วนหัวโปรไฟล์ ---
  Widget _buildProfileHeader(dynamic args) {
    return Row(
      children: [
        CircleAvatar(
          radius: 65, 
          backgroundColor: Colors.deepPurple, 
          backgroundImage: NetworkImage("https://picsum.photos/seed/${args?['userId'] ?? 'user'}/200")
        ),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _infoText("หมายเลข user", args?['userId'] ?? "1082"),
          _infoText("Username", username),
          _infoText("EMAIL", email),
          _infoText("รวมสำรับทั้งหมด", "${waitingDecks.length + publicDecks.length + privateDecks.length}"),
        ])),
      ],
    );
  }

  // --- Widget: Container แสดงสำรับ (พร้อมลูกศรสลับประเภท) ---
  Widget _buildDeckSlider(List<DeckModel> currentList) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A3F), 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.white10)
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: deckCategoryIndex > 0 ? Colors.white : Colors.white24, size: 20), 
                onPressed: deckCategoryIndex > 0 ? () => setState(() => deckCategoryIndex--) : null
              ),
              Text(categories[deckCategoryIndex], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: deckCategoryIndex < 2 ? Colors.white : Colors.white24, size: 20), 
                onPressed: deckCategoryIndex < 2 ? () => setState(() => deckCategoryIndex++) : null
              ),
            ],
          ),
          const Divider(color: Colors.white12),
          SizedBox(
            height: 200,
            child: currentList.isEmpty 
              ? const Center(child: Text("ไม่มีข้อมูลสำรับ", style: TextStyle(color: Colors.white24)))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: currentList.length,
                  itemBuilder: (context, index) => _buildDeckCard(currentList[index], index),
                ),
          ),
        ],
      ),
    );
  }

  // --- Widget: การ์ดสำรับใบย่อย ---
  Widget _buildDeckCard(DeckModel deck, int index) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(
          context, 
          deck.isWaiting ? AdminRoutes.adminVerifyDetail : AdminRoutes.adminDeckDetail, 
          arguments: {
            'deckId': deck.id, 
            'deckName': deck.name, 
            'cardCount': deck.cardCount.toString(),
            'isPublic': deck.isPublic, 
            'status': deck.status
          }
        );
        if (result == "delete") {
          setState(() {
            if (deckCategoryIndex == 0) {
              waitingDecks.removeAt(index);
            } else if (deckCategoryIndex == 1) publicDecks.removeAt(index);
            else privateDecks.removeAt(index);
          });
        }
      },
      child: Container(
        width: 120, margin: const EdgeInsets.only(right: 15, top: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05), 
          borderRadius: BorderRadius.circular(10), 
          border: Border.all(color: Colors.orangeAccent.withOpacity(0.2))
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.style, color: Colors.orangeAccent, size: 40),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5), 
              child: Text(deck.name, style: const TextStyle(color: Colors.white, fontSize: 10), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center)
            ),
            Text("${deck.cardCount} ใบ", style: const TextStyle(color: Colors.white38, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _infoText(String l, String v) => Padding(padding: const EdgeInsets.only(bottom: 5), child: Text("$l : $v", style: const TextStyle(color: Colors.white70, fontSize: 13)));

  // --- Widget: กลุ่มปุ่มด้านล่าง ---
  Widget _buildActionButtons(BuildContext context) {
    return Positioned(
      bottom: 30, left: 20, right: 20, 
      child: Row(
        children: [
          // แก้ไขสีปุ่มแก้ไขข้อมูลเป็นสีเหลืองสว่าง (Yellow Accent)
          Expanded(child: _btn("แก้ไขข้อมูล", const Color.fromARGB(248, 255, 208, 0), Colors.white, () => Navigator.pushNamed(context, AdminRoutes.adminEditUser))),
          const SizedBox(width: 15),
          Expanded(child: _btn("ลบบัญชี", Colors.redAccent, Colors.white, () => _showDeleteUserDialog(context))),
        ],
      ),
    );
  }

  // --- Widget เสริม: ปุ่มกดสไตล์มาตรฐาน ---
  Widget _btn(String t, Color bg, Color tc, VoidCallback fn) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg, 
        padding: const EdgeInsets.symmetric(vertical: 18), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
      ),
      onPressed: fn, 
      child: Text(t, style: TextStyle(color: tc, fontWeight: FontWeight.bold, fontSize: 16))
    );
  }

  // --- Pop-up ยืนยันการลบบัญชี ---
  void _showDeleteUserDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Colors.redAccent, width: 2), 
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              SizedBox(width: 10),
              Text("คำเตือน!! (ลบบัญชี)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          content: const Text(
            "การลบบัญชีผู้ใช้จะเป็นการลบข้อมูลถาวร รวมถึงสำรับไพ่ทั้งหมด บัญชีนี้จะไม่สามารถกู้คืนได้อีก ท่านแน่ใจหรือไม่ที่จะดำเนินการต่อ?",
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          actions: [
            Row(
              children: [
                Expanded(child: _btn("ยืนยันการลบ", Colors.redAccent, Colors.white, () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                })),
                const SizedBox(width: 10),
                Expanded(child: _btn("ยกเลิก", const Color(0xFF455A64), Colors.white, () => Navigator.pop(dialogContext))),
              ],
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        );
      },
    );
  }
}