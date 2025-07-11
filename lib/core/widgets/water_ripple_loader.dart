import 'package:flutter/material.dart';

class WaterRippleLoader extends StatefulWidget {
  final String? message;

  const WaterRippleLoader({super.key, this.message});

  @override
  State<WaterRippleLoader> createState() => _WaterRippleLoaderState();
}

class _WaterRippleLoaderState extends State<WaterRippleLoader>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _rippleAnimation = Tween<double>(begin: 0.0, end: 60.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.white.withOpacity(0.4)),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _rippleAnimation,
                builder: (_, __) {
                  return Container(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: _rippleAnimation.value,
                          height: _rippleAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withOpacity(
                              1 - (_rippleAnimation.value / 60),
                            ),
                          ),
                        ),
                        const Icon(Icons.waves, size: 32, color: Colors.blue),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              if (widget.message != null)
                Text(
                  widget.message!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
