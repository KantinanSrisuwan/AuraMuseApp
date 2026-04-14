import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../home/draw_result_page.dart';

class DeckDetailPage extends StatefulWidget {
  final Map<String, dynamic>? deckData;
  const DeckDetailPage({super.key, this.deckData});

  @override
  State<DeckDetailPage> createState() => _DeckDetailPageState();
}

class _DeckDetailPageState extends State<DeckDetailPage> {
  bool _isFavorite = false;
  bool _isQuickDraw = false;

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2D4E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("รายงานความไม่เหมาะสม", style: TextStyle(color: Colors.white)),
        content: TextField(
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "เหตุผลของคุณ...",
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ยกเลิก", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context),
            child: const Text("ยืนยัน", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String deckName = widget.deckData?['name'] ?? "สำรับไพ่";
    final String deckImage = widget.deckData?['image'] ?? 'https://picsum.photos/seed/deck/400/600';

    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(onPressed: () => setState(() => _isFavorite = !_isFavorite), 
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? Colors.redAccent : Colors.white)),
          IconButton(onPressed: () => setState(() => _isQuickDraw = !_isQuickDraw), 
            icon: Icon(_isQuickDraw ? Icons.bolt : Icons.bolt_outlined, color: _isQuickDraw ? Colors.yellowAccent : Colors.white)),
          IconButton(icon: const Icon(Icons.new_releases_outlined, color: Colors.white), onPressed: _showReportDialog),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text("กดที่ไพ่เพื่อเริ่มสุ่ม!", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w200)),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DrawResultPage(deckId: widget.deckData?['id'] ?? '', deckName: deckName))),
                // ใส่ HitTestBehavior เพื่อให้แรงปัดผ่านไปหา PageView ได้
                behavior: HitTestBehavior.translucent, 
                child: Hero(
                  tag: 'deck_hero_$deckName',
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 25, offset: Offset(0, 10))],
                      image: DecorationImage(image: NetworkImage(deckImage), fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(deckName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("จำนวนไพ่ในสำรับ : 15 ใบ", style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 30),
          const Column(
            children: [
              Text("เลื่อนขึ้นเพื่อดูไพ่ในสำรับ", style: TextStyle(color: Colors.white12, fontSize: 12)),
              Icon(Icons.keyboard_arrow_up, color: Colors.white12),
              SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}