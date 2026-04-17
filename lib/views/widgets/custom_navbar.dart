import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:project_flutter/core/constants/app_colors.dart';

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
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        height: 70,
        decoration: AppColors.glassDecoration(radius: 35), // Floating rounded glass
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) => _buildNavItem(index)),
        ),
      ).animate().fadeIn(duration: 800.ms).slideY(begin: 1, end: 0, curve: Curves.easeOutQuart),
    );
  }

  Widget _buildNavItem(int index) {
    bool isSelected = selectedIndex == index;
    List<IconData> icons = [
      Icons.home_outlined, // 0: Home
      Icons.search, // 1: Search
      Icons.add_circle, // 2: Add Deck
      Icons.style_outlined, // 3: My Decks
      Icons.person_outline, // 4: Profile
    ];

    List<IconData> activeIcons = [
      Icons.home,
      Icons.search_rounded,
      Icons.add_circle,
      Icons.style,
      Icons.person,
    ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onItemSelected(index),
        splashColor: const Color(0xFFFFD700).withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.1),
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
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
                ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
              Icon(
                isSelected ? activeIcons[index] : icons[index],
                size: isSelected ? 30 : 26,
                color: isSelected ? Colors.white : AppColors.textWhiteFaded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
