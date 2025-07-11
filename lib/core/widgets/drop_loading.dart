import 'package:flutter/material.dart';

class DropLoadingWidget extends StatefulWidget {
  final String? message;

  const DropLoadingWidget({super.key, this.message});

  @override
  State<DropLoadingWidget> createState() => _DropLoadingWidgetState();
}

class _DropLoadingWidgetState extends State<DropLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fallAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..repeat(reverse: true);
    _fallAnimation =
        Tween<double>(begin: 0.0, end: 40.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(color: Colors.white.withOpacity(0.5)),
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _fallAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _fallAnimation.value),
                  child: Icon(Icons.water_drop, size: 60, color: Colors.blue),
                );
              },
            ),
            const SizedBox(height: 40),
            if (widget.message != null)
              Text(
                widget.message!,
                style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
              ),
          ],
        ),
      ),
    ]);
  }
}
