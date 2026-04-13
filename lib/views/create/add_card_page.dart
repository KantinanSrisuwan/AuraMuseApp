import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final TextEditingController _backTextController = TextEditingController();
  String? _selectedImagePath; // ตัวแปรสำหรับเก็บ Path รูปภาพ (รอต่อ Logic)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("สร้างการ์ดใบใหม่", 
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white), // ปุ่มกากบาทเพื่อยกเลิก
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ส่วนเนื้อหาแบบ Scroll ได้
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ส่วนที่ 1: เลือกรูปภาพหน้าการ์ด ---
                  const Text("1. เลือกรูปภาพสำหรับหน้าการ์ด", 
                    style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Center(
                    child: _buildImageInput(), // Widget สำหรับเลือกรูปภาพ
                  ),

                  const SizedBox(height: 30),

                  // --- ส่วนที่ 2: กรอกข้อความหลังการ์ด ---
                  const Text("2. กรอกข้อความสำหรับหลังการ์ด", 
                    style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildTextInput(), // Widget สำหรับกรอกข้อความ
                ],
              ),
            ),
          ),

          // --- ส่วนปุ่มยืนยันด้านล่าง ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700], // สีเขียวเหมือน EditDeckPage
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  // Logic การรวมรูปและ Text เป็นการ์ด (รอทำต่อ)
                  Navigator.pop(context);
                },
                child: const Text("เพิ่มการ์ดเข้าสำรับ", 
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget พื้นที่เลือกรูปภาพ ---
  Widget _buildImageInput() {
    return GestureDetector(
      onTap: () {
        // Logic การเปิด Gallery (รอทำต่อ)
        print("เลือกรูปจาก Gallery");
      },
      child: AspectRatio(
        aspectRatio: 0.65, // ทรงไพ่ทาโรต์
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2D4E), // เทาเข้ม
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white10),
          ),
          child: _selectedImagePath == null
              // สถานะว่างเปล่า
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library_outlined, size: 60, color: Colors.white24),
                    SizedBox(height: 10),
                    Text("แตะเพื่อเลือกรูปภาพ", style: TextStyle(color: Colors.white24)),
                  ],
                )
              // สถานะมีรูป (รอใส่ Image.file ในอนาคต)
              : const Center(child: Text("รูปภาพที่เลือก", style: TextStyle(color: Colors.white))),
        ),
      ),
    );
  }

  // --- Widget พื้นที่กรอกข้อความ Multi-line ---
  Widget _buildTextInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D4E), // เทาเข้ม
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _backTextController,
        maxLines: 6, // กรอกได้หลายบรรทัดเหมือนรูปที่ 3
        style: const TextStyle(color: Colors.white70),
        maxLength: 300, // กำหนดจำนวนตัวอักษร
        decoration: const InputDecoration(
          hintText: "กรอกคำทำนาย, ความหมาย, หรือผลลัพธ์ที่นี่...",
          hintStyle: TextStyle(color: Colors.white10),
          border: InputBorder.none, // ลบเส้นขอบด้านล่าง
          counterStyle: TextStyle(color: Colors.white24), // สีของตัวเลข character count
        ),
      ),
    );
  }
}