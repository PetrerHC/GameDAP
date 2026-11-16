import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFC9F2F9),
                Color(0xFFA8E0D8),
              ],
            ),
          ),
        ),
        Positioned(
          top: 80,
          right: -40,
          child: _BackgroundBubble(
            size: 180,
            opacity: 0.15,
          ),
        ),
        Positioned(
          top: 300,
          right: 50,
          child: _BackgroundBubble(
            size: 60,
            opacity: 0.10,
          ),
        ),
        child,
      ],
    );
  }
}

class _BackgroundBubble extends StatelessWidget {
  final double size;
  final double opacity;

  const _BackgroundBubble({
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
    );
  }
}
