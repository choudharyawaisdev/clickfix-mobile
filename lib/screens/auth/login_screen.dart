import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/services/auth_service.dart';
import 'package:clickfix/screens/main_navigation_screen.dart';
import 'package:clickfix/screens/auth/register_screen.dart';
import 'package:clickfix/widgets/clickfix_logo.dart';
import 'package:clickfix/widgets/interactive_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    final success = await AuthService().login(email, password);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged in as ${AuthService().currentUser!.name}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password!'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildDemoChip(String label, VoidCallback onTap, IconData icon, bool isDark) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
              ),
              color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.01),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: ClickFixTheme.primaryAmber,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : ClickFixTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background elegant gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF15181B), ClickFixTheme.primaryDark]
                      : [const Color(0xFFFAFAFA), const Color(0xFFF5F7FA)],
                ),
              ),
            ),
          ),
          // Glowing circle in background top right
          Positioned(
            top: -120,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ClickFixTheme.primaryAmber.withOpacity(isDark ? 0.08 : 0.04),
              ),
            ),
          ),
          // Glowing circle in background bottom left
          Positioned(
            bottom: -150,
            left: -80,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ClickFixTheme.primaryAmber.withOpacity(isDark ? 0.04 : 0.02),
              ),
            ),
          ),
          // Scrollable main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    // App Logo
                    ClickFixLogo(
                      iconSize: 64,
                      fontSize: 32,
                      isDarkBackground: isDark,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reliable Home Services',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: ClickFixTheme.textMuted,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Card Form Container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C3034).withOpacity(0.85) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.08) : ClickFixTheme.borderGray.withOpacity(0.6),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back!',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : ClickFixTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Log in to request services or manage your jobs.',
                              style: GoogleFonts.outfit(
                                color: ClickFixTheme.textMuted,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Email Address
                            Text(
                              'Email Address',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: ClickFixTheme.primaryAmber,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.outfit(fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'Enter email or phone number',
                                prefixIcon: Icon(
                                  Icons.mail_outline_rounded,
                                  color: isDark ? Colors.white70 : ClickFixTheme.textMuted,
                                  size: 20,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter email or phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Password
                            Text(
                              'Password',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: ClickFixTheme.primaryAmber,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.outfit(fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                prefixIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  color: isDark ? Colors.white70 : ClickFixTheme.textMuted,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                    color: ClickFixTheme.textMuted,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return 'Please enter password';
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),

                            // Login Button
                            InteractiveButton(
                              isLoading: _isLoading,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _handleLogin(
                                    _emailController.text,
                                    _passwordController.text,
                                  );
                                }
                              },
                              child: Text(
                                'Log In',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: ClickFixTheme.primaryDark,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Register Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: GoogleFonts.outfit(fontSize: 14, color: ClickFixTheme.textMuted),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                    );
                                  },
                                  child: Text(
                                    'Register Now',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: ClickFixTheme.primaryAmber,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Test Shortcuts Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C3034).withOpacity(0.5) : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.06) : ClickFixTheme.borderGray.withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                size: 16,
                                color: ClickFixTheme.primaryAmber.withOpacity(0.85),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'QUICK DEMO SIGN IN',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: ClickFixTheme.textMuted,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildDemoChip('Customer', () => _handleLogin('customer@clickfix.com', 'customer123'), Icons.person_outline_rounded, isDark),
                              const SizedBox(width: 8),
                              _buildDemoChip('Worker', () => _handleLogin('worker@clickfix.com', 'worker123'), Icons.engineering_outlined, isDark),
                              const SizedBox(width: 8),
                              _buildDemoChip('Admin', () => _handleLogin('admin@clickfix.com', 'admin123'), Icons.admin_panel_settings_outlined, isDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
