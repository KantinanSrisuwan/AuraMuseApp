import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/constants/app_colors.dart';

class FlippableCard extends StatefulWidget {
  final Widget front;
  final String backText;
  final List<Color> palette; // รับลิสต์สีแบบ Real-time
  final double width;
  final double height;

  const FlippableCard({
    super.key,
    required this.front,
    required this.backText,
    required this.palette,
    this.width = 300,
    this.height = 500,
  });

  @override
  State<FlippableCard> createState() => _FlippableCardState();
}

class _FlippableCardState extends State<FlippableCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _animation = Tween<double>(begin: 0, end: pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value;
          final isBackVisible = angle >= pi / 2;

          return Transform(
            transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle),
            alignment: Alignment.center,
            child: isBackVisible 
              ? Transform(alignment: Alignment.center, transform: Matrix4.identity()..rotateY(pi), child: _buildBack())
              : widget.front,
          );
        },
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.glassBorder.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cosmicCyan.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.cosmicPurple.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ส่วนของเนื้อหา Text
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Text(
                widget.backText,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.5, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          // ส่วนของ Color Palette (Real-time)
          Positioned(
            bottom: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.palette.map((color) => _buildColorDot(color)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 25, height: 25,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1),
        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 2))],
      ),
    );
  }
}