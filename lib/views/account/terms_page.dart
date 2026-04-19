import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textWhite,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "ข้อกำหนดของแพลตฟอร์ม",
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader("ยินดีต้อนรับสู่ AuraMuse"),
            _buildParagraph(
              "เพื่อให้ AuraMuse เป็นสังคมแห่งการแบ่งปันแรงบันดาลใจและความคิดสร้างสรรค์ที่ปลอดภัยสำหรับทุกคน เราขอความร่วมมือผู้ใช้ทุกท่านปฏิบัติตามข้อกำหนดและแนวทางปฏิบัติดังต่อไปนี้",
            ),

            const SizedBox(height: 25),

            _buildSectionTitle("1. มาตรฐานเนื้อหา (Content Standards)"),
            _buildPoint(
              "ห้ามใช้คำหยาบคาย:",
              "ไม่อนุญาตให้ใช้ถ้อยคำไม่สุภาพ คำหยาบคาย หรือภาษาที่ส่อไปในทางลามกอนาจาร ทั้งในชื่อสำรับ (Deck Name) และเนื้อหาภายในไพ่",
            ),
            _buildPoint(
              "ห้ามการเหยียดและประทุษวาจา (Hate Speech):",
              "ห้ามสร้างเนื้อหาที่ส่งเสริมความเกลียดชัง การดูหมิ่น หรือการเหยียดหยามบุคคลหรือกลุ่มบุคคลตามเชื้อชาติ ศาสนา เพศ ความพิกา หรือรสนิยมทางเพศ",
            ),
            _buildPoint(
              "ห้ามการข่มขู่และรบกวน (Harassment):",
              "ห้ามใช้แพลตฟอร์มเพื่อการข่มขู่ คุกคาม หรือรบกวนสิทธิส่วนบุคคลของผู้อื่นในทุกรูปแบบ",
            ),

            const SizedBox(height: 25),

            _buildSectionTitle("2. ลิขสิทธิ์และสิทธิในทรัพย์สินทางปัญญา"),
            _buildParagraph(
              "ผู้ใช้งานต้องรับผิดชอบต่อภาพและเนื้อหาที่นำมาสร้างเป็นสำรับ โดยต้องมั่นใจว่ามีสิทธิในการใช้งานและไม่ละเมิดลิขสิทธิ์ของผู้อื่น AuraMuse จะไม่รับผิดชอบต่อการละเมิดที่เกิดขึ้นจากผู้ใช้งาน",
            ),

            const SizedBox(height: 25),

            _buildSectionTitle("3. ระบบการรายงาน (Reporting System)"),
            _buildParagraph(
              "หากคุณพบเห็นสำรับหรือเนื้อหาที่ละเมิดข้อกำหนดข้างต้น คุณสามารถใช้ฟังก์ชัน 'Report' เพื่อแจ้งให้ทีมงานตรวจสอบได้ทันที ทีมงานจะพิจารณาข้อมูลภายใน 24-48 ชั่วโมง",
            ),

            const SizedBox(height: 25),

            _buildSectionTitle("4. การบังคับใช้มาตรฐาน"),
            _buildParagraph(
              "AuraMuse ขอสงวนสิทธิ์ในการ 'ไม่ยอมรับ (Reject)' หรือ 'ลบเนื้อหา' ที่ขัดต่อข้อกำหนดนี้โดยไม่จำเป็นต้องแจ้งให้ทราบล่วงหน้า ในกรณีที่พบการทำผิดซ้ำ บัญชีผู้ใช้อาจถูกระงับ (Ban) อย่างถาวร",
            ),

            const SizedBox(height: 25),

            _buildParagraph(
              "ขอบคุณที่ร่วมเป็นส่วนหนึ่งในการสร้างพื้นที่สร้างสรรค์ที่ดีไปกับเรา ✨",
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.cosmicCyan,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textWhite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textWhiteMuted,
        fontSize: 15,
        height: 1.6,
      ),
    );
  }

  Widget _buildPoint(String title, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: AppColors.textWhiteMuted,
            fontSize: 15,
            height: 1.6,
            fontFamily: 'Roboto', // หรือ font อื่นที่คุณใช้ในโปรเจค
          ),
          children: [
            TextSpan(
              text: "• $title ",
              style: const TextStyle(
                color: AppColors.cosmicPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: detail),
          ],
        ),
      ),
    );
  }
}
