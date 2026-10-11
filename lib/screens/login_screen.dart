import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  // Hardcoded admin credentials (replace with real auth later)
  static const _adminUser = 'admin';
  static const _adminPass = 'masjid123';

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideIn = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    if (_username.text.trim() == _adminUser && _password.text == _adminPass) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainShell(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } else {
      setState(() {
        _loading = false;
        _error = 'Invalid username or password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      body: isWide ? _desktopLayout() : _mobileLayout(),
    );
  }

  // ─── Desktop: split layout ───────────────────────────────────
  Widget _desktopLayout() {
    return Row(
      children: [
        // Left panel
        Expanded(
          child: Container(
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: Stack(
              children: [
                Positioned(top: -80, left: -80, child: _circle(260, 0.06)),
                Positioned(bottom: -60, right: -60, child: _circle(200, 0.07)),
                Positioned(top: 200, right: 40, child: _circle(80, 0.1)),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(color: AppColors.accentLight, width: 2),
                            boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 30, spreadRadius: 4)],
                          ),
                          child: const Icon(Icons.mosque_rounded, color: AppColors.accentLight, size: 50),
                        ),
                        const SizedBox(height: 28),
                        Text('مسجد مجاهد', style: GoogleFonts.amiri(color: AppColors.accentLight, fontSize: 40, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('MUJAHID MASJID', style: GoogleFonts.notoSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 3)),
                        const SizedBox(height: 6),
                        Text('Mahal Management System', style: GoogleFonts.notoSans(color: Colors.white60, fontSize: 13)),
                        const SizedBox(height: 48),
                        // Feature list
                        ...[
                          ('👥', 'Manage all Mahal members'),
                          ('📍', 'Filter by place / area'),
                          ('💰', 'Track Sadaqah collections'),
                          ('🧾', 'Generate & print receipts'),
                        ].map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item.$1, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 10),
                              Text(item.$2, style: GoogleFonts.notoSans(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        )),
                        const SizedBox(height: 40),
                        Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', style: GoogleFonts.amiri(color: Colors.white30, fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right panel — login form
        SizedBox(
          width: 440,
          child: Container(
            color: AppColors.surface,
            child: Center(child: _loginForm()),
          ),
        ),
      ],
    );
  }

  // ─── Mobile: full screen ─────────────────────────────────────
  Widget _mobileLayout() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 48),
              // Logo
              const Icon(Icons.mosque_rounded, color: AppColors.accentLight, size: 60),
              const SizedBox(height: 12),
              Text('مسجد مجاهد', style: GoogleFonts.amiri(color: AppColors.accentLight, fontSize: 32, fontWeight: FontWeight.bold)),
              Text('MUJAHID MASJID', style: GoogleFonts.notoSans(color: Colors.white70, fontSize: 13, letterSpacing: 2)),
              const SizedBox(height: 40),
              // Form card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10))],
                ),
                padding: const EdgeInsets.all(28),
                child: _loginForm(cardMode: false),
              ),
              const SizedBox(height: 32),
              Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', style: GoogleFonts.amiri(color: Colors.white30, fontSize: 13)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginForm({bool cardMode = true}) {
    Widget form = FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideIn,
        child: Padding(
          padding: cardMode ? const EdgeInsets.all(40) : EdgeInsets.zero,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cardMode) ...[
                  Text('Welcome Back', style: GoogleFonts.amiri(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Sign in to manage your Mahal', style: GoogleFonts.notoSans(fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 36),
                ] else ...[
                  Text('Admin Login', style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Sign in to continue', style: GoogleFonts.notoSans(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                ],

                // Username
                Text('Username', style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _username,
                  validator: (v) => (v == null || v.isEmpty) ? 'Enter username' : null,
                  decoration: InputDecoration(
                    hintText: 'Enter your username',
                    prefixIcon: const Icon(Icons.person_rounded, color: AppColors.textLight, size: 20),
                    filled: true,
                    fillColor: AppColors.surfaceDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                  ),
                ),
                const SizedBox(height: 18),

                // Password
                Text('Password', style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.textLight, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: AppColors.textLight, size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                  ),
                ),

                // Error message
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
                        const SizedBox(width: 8),
                        Text(_error!, style: GoogleFonts.notoSans(color: AppColors.error, fontSize: 13)),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Text('Sign In', style: GoogleFonts.notoSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 20),

                // Default credentials hint
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Default: admin / masjid123',
                          style: GoogleFonts.notoSans(fontSize: 12, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!cardMode) return form;

    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: form,
    );
  }

  Widget _circle(double size, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withOpacity(opacity), width: 1.5),
    ),
  );
}