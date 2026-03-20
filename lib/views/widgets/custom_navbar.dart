import 'package:flutter/material.dart';

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

    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSelected)
            // ดาวเรืองแสงด้านหลัง
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.star, size: 45, color: Color(0xFFFFD700)),
            ),
          Icon(
            icons[index],
            size: 30,
            color: isSelected ? Colors.white : Colors.white24,
          ),
        ],
      ),
    );
  }
}