import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'sender_home_screen.dart';
import 'transporter_home_screen.dart';
import '../services/token_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _pulse;
  late Animation<double> _scan;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _logoScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.35, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.28, curve: Curves.easeOut),
      ),
    );

    _pulse = Tween<double>(begin: 0.88, end: 1.22).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scan = Tween<double>(begin: -180, end: 180).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 8));

    final token = await TokenStorage.getToken();
    final roleRaw = await TokenStorage.getRole();
    final role = (roleRaw ?? '').trim().toLowerCase();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      if (role == 'sender') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SenderHomeScreen()),
        );
        return;
      }

      if (role == 'transporter') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TransporterHomeScreen()),
        );
        return;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _radarCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF1FCBFF).withValues(alpha: opacity),
          width: 1.4,
        ),
      ),
    );
  }

  Widget _truckTire() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Transform.rotate(
          angle: _controller.value * math.pi * 16,
          child: Container(
            width: 245,
            height: 245,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.65),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.95),
                width: 20,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1FCBFF).withValues(alpha: 0.45),
                  blurRadius: 45,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: CustomPaint(
              painter: _TirePainter(),
            ),
          ),
        );
      },
    );
  }

  Widget _loadingLine() {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      width: 150,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: _controller.value.clamp(0.08, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1FCBFF),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1FCBFF).withValues(alpha: 0.95),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _logoArea() {
    return SizedBox(
      width: 310,
      height: 310,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: _pulse.value,
            child: _radarCircle(285, 0.16),
          ),
          Transform.scale(
            scale: 1.06,
            child: _radarCircle(240, 0.25),
          ),
          _radarCircle(195, 0.36),

          _truckTire(),

          Positioned(
            top: _scan.value + 150,
            child: Container(
              width: 270,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF1FCBFF).withValues(alpha: 0.7),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1FCBFF).withValues(alpha: 1),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: _scan.value + 170,
            child: Container(
              width: 220,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8FEAFF).withValues(alpha: 0.75),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1FCBFF).withValues(alpha: 0.08),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1FCBFF).withValues(alpha: 0.55),
                  blurRadius: 70,
                  spreadRadius: 15,
                ),
              ],
            ),
          ),

          Transform.scale(
            scale: _logoScale.value,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/logo1.png',
                height: 170,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.15,
            colors: [
              Color(0xFF123352),
              Color(0xFF061226),
              Color(0xFF02040A),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Opacity(
                opacity: _logoOpacity.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _logoArea(),
                    const SizedBox(height: 26),
                    const Text(
                      'TeReT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Brži put do prijevoza',
                      style: TextStyle(
                        color: const Color(0xFF8FEAFF).withValues(alpha: 0.95),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    _loadingLine(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TirePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final outerTreadPaint = Paint()
      ..color = Colors.grey.shade500.withValues(alpha: 0.9)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    final innerTreadPaint = Paint()
      ..color = Colors.grey.shade700.withValues(alpha: 0.85)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final ringPaint = Paint()
      ..color = Colors.grey.shade900.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    final neonRingPaint = Paint()
      ..color = const Color(0xFF1FCBFF).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius - 26, ringPaint);
    canvas.drawCircle(center, radius - 58, neonRingPaint);
    canvas.drawCircle(center, radius - 84, neonRingPaint);

    for (int i = 0; i < 32; i++) {
      final angle = (math.pi * 2 / 32) * i;

      final startOuter = Offset(
        center.dx + math.cos(angle - 0.08) * (radius - 28),
        center.dy + math.sin(angle - 0.08) * (radius - 28),
      );

      final endOuter = Offset(
        center.dx + math.cos(angle + 0.08) * (radius - 6),
        center.dy + math.sin(angle + 0.08) * (radius - 6),
      );

      canvas.drawLine(startOuter, endOuter, outerTreadPaint);

      final startInner = Offset(
        center.dx + math.cos(angle + 0.14) * (radius - 62),
        center.dy + math.sin(angle + 0.14) * (radius - 62),
      );

      final endInner = Offset(
        center.dx + math.cos(angle - 0.02) * (radius - 34),
        center.dy + math.sin(angle - 0.02) * (radius - 34),
      );

      canvas.drawLine(startInner, endInner, innerTreadPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}