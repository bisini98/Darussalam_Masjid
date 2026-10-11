import 'login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleUp;
  late Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _scaleUp = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)),
    );

    _slideUp = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );

    _controller.forward();

    // Navigate to login after delay
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Stack(
          children: [
            // Background decorative circles
            Positioned(top: -60, right: -60, child: _circle(200, 0.06)),
            Positioned(top: 100, right: 60, child: _circle(80, 0.08)),
            Positioned(bottom: -80, left: -60, child: _circle(240, 0.05)),
            Positioned(bottom: 120, left: 80, child: _circle(60, 0.09)),
            Positioned(top: 200, left: -40, child: _circle(100, 0.07)),

            // Center content
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Opacity(
                    opacity: _fadeIn.value,
                    child: Transform.scale(
                      scale: _scaleUp.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Mosque icon with glow ring
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: AppColors.accentLight.withOpacity(0.6),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.mosque_rounded,
                              color: AppColors.accentLight,
                              size: 56,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Arabic name
                          Transform.translate(
                            offset: Offset(0, _slideUp.value),
                            child: Text(
                              'مسجد مجاهد',
                              style: GoogleFonts.amiri(
                                color: AppColors.accentLight,
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Transform.translate(
                            offset: Offset(0, _slideUp.value),
                            child: Text(
                              'MUJAHID MASJID',
                              style: GoogleFonts.notoSans(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 3,
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          Transform.translate(
                            offset: Offset(0, _slideUp.value),
                            child: Text(
                              'Mahal Management System',
                              style: GoogleFonts.notoSans(
                                color: Colors.white60,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 60),

                          // Loading dots
                          _LoadingDots(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom tagline
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _fadeIn,
                builder: (_, __) => Opacity(
                  opacity: _fadeIn.value,
                  child: Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      color: Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.white.withOpacity(opacity),
        width: 1.5,
      ),
    ),
  );
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i * 0.3;
            final t = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = 0.5 + 0.5 * (1 - (2 * t - 1).abs());
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.accentLight.withOpacity(0.6 + 0.4 * scale),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}