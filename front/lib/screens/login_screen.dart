import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../main.dart'; 
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  bool _showPass = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, .08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('И-мэйл болон нууц үгээ оруулна уу');
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success = await _apiService.login(email, password);

      if (!mounted) return;

      if (success) {
        // Амжилттай болбол шууд шилжинэ
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainNavigation(key: UniqueKey())),
        );
      } else {
        _showError('Нэвтрэх мэдээлэл буруу байна');
      }
    } catch (e) {
      _showError('Сервертэй холбогдоход алдаа гарлаа');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Nunito')),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          Positioned(top: -80, right: -80, child: _blob(220, AppTheme.primary.withOpacity(.18))),
          Positioned(top: 120, left: -60, child: _blob(160, AppTheme.secondary.withOpacity(.12))),
          Positioned(bottom: -60, right: -40, child: _blob(200, AppTheme.accent.withOpacity(.10))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),
                      Center(
                        child: Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(.4), blurRadius: 24, offset: const Offset(0, 8))],
                          ),
                          child: const Icon(Icons.hub_rounded, color: Colors.white, size: 40),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text('UniConnect', style: TextStyle(
                          fontFamily: 'Nunito', fontWeight: FontWeight.w900,
                          fontSize: 32, color: AppTheme.textPrimary, letterSpacing: -1,
                        )),
                      ),
                      const Center(
                        child: Text('Оюутны нийгэмлэгийн платформ', style: TextStyle(
                          fontFamily: 'Nunito', fontWeight: FontWeight.w500,
                          fontSize: 14, color: AppTheme.textSecondary,
                        )),
                      ),
                      const SizedBox(height: 52),
                      const Text('Нэвтрэх', style: TextStyle(
                        fontFamily: 'Nunito', fontWeight: FontWeight.w800,
                        fontSize: 26, color: AppTheme.textPrimary,
                      )),
                      const SizedBox(height: 4),
                      const Text('Дансаараа нэвтэрнэ үү', style: TextStyle(
                        fontFamily: 'Nunito', fontSize: 14, color: AppTheme.textSecondary,
                      )),
                      const SizedBox(height: 32),
                      _InputField(
                        controller: _emailController,
                        hint: 'И-мэйл хаяг',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      _InputField(
                        controller: _passController,
                        hint: 'Нууц үг',
                        icon: Icons.lock_outline_rounded,
                        isPassword: !_showPass,
                        suffix: IconButton(
                          onPressed: () => setState(() => _showPass = !_showPass),
                          icon: Icon(_showPass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppTheme.textSecondary, size: 20),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Нууц үг мартсан?', style: TextStyle(
                            fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                            fontSize: 13, color: AppTheme.primary,
                          )),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // GradientButton-ийг энд дуудаж байна
                      _MyGradientButton(
                        text: 'Нэвтрэх',
                        isLoading: _isLoading,
                        onTap: _handleLogin,
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        const Expanded(child: Divider(color: AppTheme.textMuted, thickness: .5)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Text('эсвэл', style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppTheme.textMuted)),
                        ),
                        const Expanded(child: Divider(color: AppTheme.textMuted, thickness: .5)),
                      ]),
                      const SizedBox(height: 16),
                      _SocialLoginButton(
                        icon: Icons.school_rounded,
                        text: 'Сургуулийн и-мэйлээр нэвтрэх',
                        onTap: () {},
                      ),
                      const SizedBox(height: 24),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              // Энд шилжих кодыг бичнэ
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterScreen()),
                              );
                            }, 
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                                children: [
                                  TextSpan(text: 'Бүртгэлгүй юу?  ', style: TextStyle(color: AppTheme.textSecondary)),
                                  TextSpan(
                                    text: 'Бүртгүүлэх', 
                                    style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800)
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// Дэлгэцийн доторх туслах Widget-үүд
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _InputField({
    required this.controller, required this.hint, required this.icon,
    this.isPassword = false, this.keyboardType, this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'Nunito', color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontFamily: 'Nunito', color: AppTheme.textMuted, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class _MyGradientButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onTap;

  const _MyGradientButton({required this.text, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity, height: 56,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(.3), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Center(
          child: isLoading 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Nunito')),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _SocialLoginButton({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity, height: 54,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.secondary, size: 20),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}