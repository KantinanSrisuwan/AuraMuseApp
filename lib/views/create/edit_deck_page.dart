import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'package:project_flutter/core/routes/app_routes.dart';

class EditDeckPage extends StatefulWidget {
  final Map<String, dynamic>? initialData; // ถ้าเป็น null คือสร้างใหม่
  const EditDeckPage({super.key, this.initialData});

  @override
  State<EditDeckPage> createState() => _EditDeckPageState();
}

class _EditDeckPageState extends State<EditDeckPage> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _cards = []; // รายการรูปการ์ดในสำรับ

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['name'] ?? "";
      // _cards = ดึงข้อมูลการ์ดเดิมมาใส่ตรงนี้
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
      ),
      body: Column(
        children: [
          // 1. ส่วนหัว (แถบสีม่วง)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: const Color(0xFF2A1B60),
            child: Center(
              child: Text(
                _nameController.text.isEmpty ? "ชื่อสำรับ(ตัวอย่าง)" : _nameController.text,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),

          // 2. ส่วนข้อมูลหลัก (Cover + Name Input)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ส่วนใส่รูปปก
                _buildSquareButton(
                  width: 120,
                  height: 160,
                  onTap: () => print("เลือกรูปปก"),
                ),
                const SizedBox(width: 20),
                // ส่วนกรอกชื่อและจำนวน
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("ชื่อสำรับ", style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[300],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                        ),
                        onChanged: (val) => setState(() {}),
                      ),
                      const SizedBox(height: 20),
                      Text("จำนวนไพ่ปัจจุบัน : ${_cards.length}", style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                )
              ],
            ),
          ),

          // 3. ส่วนรายการการ์ด (Grid)
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFF1E1E3A),
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.65,
                ),
                itemCount: _cards.length + 1, // +1 สำหรับปุ่มเพิ่มการ์ด
                itemBuilder: (context, index) {
                  if (index == _cards.length) {
                    return _buildSquareButton(
                          onTap: () {
                          // วาร์ปไปหน้าสร้างการ์ด
                        Navigator.pushNamed(context, AppRoutes.addCard);
                          },
                        );
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                      image: const DecorationImage(image: NetworkImage("https://picsum.photos/200/300"), fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),
          ),

          // 4. ปุ่มยืนยันด้านล่าง
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("ยืนยัน", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget ปุ่มสี่เหลี่ยมที่มีเครื่องหมาย +
  Widget _buildSquareButton({double? width, double? height, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.add, size: 40, color: Colors.black54),
      ),
    );
  }
}