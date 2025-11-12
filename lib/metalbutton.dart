import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class LiquidMetalShowcase extends StatefulWidget {
  const LiquidMetalShowcase({Key? key}) : super(key: key);

  @override
  State<LiquidMetalShowcase> createState() => _LiquidMetalShowcaseState();
}

class _LiquidMetalShowcaseState extends State<LiquidMetalShowcase>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return CustomPaint(
                painter: BackgroundPainter(_backgroundController.value),
                child: Container(),
              );
            },
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'LIQUID METAL',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w100,
                    letterSpacing: 8,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 60),
                LiquidMetalButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mercury Activated!'),
                        backgroundColor: Colors.blueGrey,
                      ),
                    );
                  },
                  child: const Text(
                    'MERCURY',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LiquidMetalButton(
                      onPressed: () {},
                      isCircle: true,
                      size: const Size(80, 80),
                      child: const Icon(Icons.favorite, size: 32),
                    ),
                    const SizedBox(width: 20),
                    LiquidMetalButton(
                      onPressed: () {},
                      isCircle: true,
                      size: const Size(80, 80),
                      child: const Icon(Icons.flash_on, size: 32),
                    ),
                    const SizedBox(width: 20),
                    LiquidMetalButton(
                      onPressed: () {},
                      isCircle: true,
                      size: const Size(80, 80),
                      child: const Icon(Icons.star, size: 32),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                LiquidMetalButton(
                  onPressed: () {},
                  size: const Size(200, 60),
                  child: const Text(
                    'MORPH',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LiquidMetalButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Size size;
  final bool isCircle;

  const LiquidMetalButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.size = const Size(180, 60),
    this.isCircle = false,
  }) : super(key: key);

  @override
  State<LiquidMetalButton> createState() => _LiquidMetalButtonState();
}

class _LiquidMetalButtonState extends State<LiquidMetalButton>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _morphController;
  late AnimationController _shimmerController;
  late Animation<double> _rippleAnimation;
  late Animation<double> _morphAnimation;

  List<Ripple> ripples = [];
  Offset? tapPosition;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _morphController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _morphAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _morphController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      tapPosition = details.localPosition;
      ripples.add(Ripple(
        position: details.localPosition,
        animation: _rippleAnimation,
      ));
    });
    _rippleController.forward(from: 0);
    _morphController.forward(from: 0);
  }

  void _handleTapUp(TapUpDetails details) {
    widget.onPressed();
    Future.delayed(const Duration(milliseconds: 300), () {
      _morphController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _rippleAnimation,
          _morphAnimation,
          _shimmerController,
        ]),
        builder: (context, child) {
          return CustomPaint(
            painter: LiquidMetalPainter(
              ripples: ripples,
              morphValue: _morphAnimation.value,
              shimmerValue: _shimmerController.value,
              isCircle: widget.isCircle,
            ),
            child: Container(
              width: widget.size.width,
              height: widget.size.height,
              alignment: Alignment.center,
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}

class Ripple {
  final Offset position;
  final Animation<double> animation;

  Ripple({required this.position, required this.animation});
}

class LiquidMetalPainter extends CustomPainter {
  final List<Ripple> ripples;
  final double morphValue;
  final double shimmerValue;
  final bool isCircle;

  LiquidMetalPainter({
    required this.ripples,
    required this.morphValue,
    required this.shimmerValue,
    required this.isCircle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Create liquid metal path
    Path path;
    if (isCircle) {
      path = _createCirclePath(size);
    } else {
      path = _createLiquidPath(size);
    }

    // Draw shadow
    canvas.drawPath(
      path.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Create metallic gradient
    final gradient = ui.Gradient.linear(
      Offset(0, size.height * shimmerValue),
      Offset(size.width, size.height * (1 - shimmerValue)),
      [
        const Color(0xFFE8E8E8),
        const Color(0xFFBDBDBD),
        const Color(0xFFF5F5F5),
        const Color(0xFF9E9E9E),
        const Color(0xFFE0E0E0),
      ],
      [0.0, 0.25, 0.5, 0.75, 1.0],
    );

    // Main button paint
    final paint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    // Draw main button
    canvas.drawPath(path, paint);

    // Draw ripples
    for (final ripple in ripples) {
      final rippleRadius = size.width * 0.8 * ripple.animation.value;
      final rippleOpacity = 1.0 - ripple.animation.value;

      final ripplePaint = Paint()
        ..shader = ui.Gradient.radial(
          ripple.position,
          rippleRadius,
          [
            Colors.white.withOpacity(0.6 * rippleOpacity),
            Colors.white.withOpacity(0.3 * rippleOpacity),
            Colors.transparent,
          ],
          [0.0, 0.5, 1.0],
        )
        ..style = PaintingStyle.fill;

      canvas.saveLayer(rect, Paint());
      canvas.drawPath(path, Paint()..color = Colors.white);
      canvas.drawCircle(
        ripple.position,
        rippleRadius,
        ripplePaint..blendMode = BlendMode.srcIn,
      );
      canvas.restore();
    }

    // Draw edge highlight
    final edgePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        [
          Colors.white.withOpacity(0.8),
          Colors.white.withOpacity(0.2),
        ],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, edgePaint);

    // Clean up old ripples
    ripples.removeWhere((ripple) => ripple.animation.value >= 1.0);
  }

  Path _createLiquidPath(Size size) {
    final path = Path();
    final radius = 20.0;
    final morph = morphValue * 5;

    path.moveTo(radius, 0);

    // Top edge with liquid effect
    path.quadraticBezierTo(
      size.width / 2,
      -morph,
      size.width - radius,
      0,
    );

    // Top right corner
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // Right edge
    path.quadraticBezierTo(
      size.width + morph,
      size.height / 2,
      size.width,
      size.height - radius,
    );

    // Bottom right corner
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - radius,
      size.height,
    );

    // Bottom edge
    path.quadraticBezierTo(
      size.width / 2,
      size.height + morph,
      radius,
      size.height,
    );

    // Bottom left corner
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    // Left edge
    path.quadraticBezierTo(
      -morph,
      size.height / 2,
      0,
      radius,
    );

    // Top left corner
    path.quadraticBezierTo(0, 0, radius, 0);

    path.close();
    return path;
  }

  Path _createCirclePath(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final morph = morphValue * 3;

    final path = Path();

    for (int i = 0; i < 360; i += 10) {
      final angle = i * math.pi / 180;
      final waveOffset = math.sin(angle * 4 + shimmerValue * 2 * math.pi) * morph;
      final r = radius + waveOffset;

      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(LiquidMetalPainter oldDelegate) => true;
}

class BackgroundPainter extends CustomPainter {
  final double animationValue;

  BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final offset = animationValue + i * 0.2;
      final radius = size.width * 0.3 * (1 + 0.2 * math.sin(offset * 2 * math.pi));

      paint.shader = ui.Gradient.radial(
        Offset(
          size.width * (0.5 + 0.3 * math.cos(offset * 2 * math.pi)),
          size.height * (0.5 + 0.3 * math.sin(offset * 2 * math.pi)),
        ),
        radius,
        [
          Colors.blue.withOpacity(0.05),
          Colors.transparent,
        ],
      );

      canvas.drawCircle(
        Offset(
          size.width * (0.5 + 0.3 * math.cos(offset * 2 * math.pi)),
          size.height * (0.5 + 0.3 * math.sin(offset * 2 * math.pi)),
        ),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) => true;
}