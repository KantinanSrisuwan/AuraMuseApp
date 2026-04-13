import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1026),
        border: Border(top: BorderSide(color: Colors.blueAccent, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(5, (index) => _buildNavItem(index)),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    bool isSelected = selectedIndex == index;
    List<IconData> icons = [
      Icons.home,
      Icons.search,
      Icons.add_circle_outline,
      Icons.style, // รอเปลี่ยนเป็น SVG ภายหลัง
      Icons.person,
    ];

    return Material(
    color: Colors.transparent, // ต้องเป็นโปร่งใสเพื่อให้เห็นพื้นหลัง Navbar
    child: InkWell(
      onTap: () => onItemSelected(index),
      splashColor: const Color(0xFFFFD700).withOpacity(0.3),
      highlightColor: Colors.white.withOpacity(0.1),
      customBorder: const CircleBorder(),
      // 2. ใช้ Padding ครอบ Stack นิดหน่อยเพื่อให้คลื่นมีพื้นที่แผ่กว้างขึ้น
      child: Padding(
        padding: const EdgeInsets.all(8.0), 
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- โค้ดส่วนของ if (isSelected) และดาว SVG ของคุณเหมือนเดิมเป๊ะ ---
            if (isSelected)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  'assets/icons/star.svg',
                  width: 55,
                  height: 55,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFFFD700),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            Icon(
              icons[index],
              size: 30,
              color: isSelected ? Colors.white : Colors.white24,
            ),
          ],
        ),
      ),
    ),
  );
}
  }
