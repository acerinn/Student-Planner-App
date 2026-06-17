import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<Color?> color1;
  late Animation<Color?> color2;
  late Animation<Color?> color3;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    color1 = ColorTween(
      begin: const Color(0xFFFFDEE9),
      end: const Color(0xFFE3D4FF),
    ).animate(_controller);

    color2 = ColorTween(
      begin: const Color(0xFFB5FFFC),
      end: const Color(0xFFFFF7FB),
    ).animate(_controller);

    color3 = ColorTween(
      begin: const Color(0xFFE3D4FF),
      end: const Color(0xFFFFDEE9),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color1.value ?? Colors.pink,
                color2.value ?? Colors.blue,
                color3.value ?? Colors.purple,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}