import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/services/auth_service.dart';
import 'package:clickfix/screens/auth/profile_setup_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _selectedRole = 'Customer'; // default selection
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match!'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final success = AuthService().register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _selectedRole,
      );

      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User with this email already exists!'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? ClickFixTheme.primaryDark : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Account',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Join ClickFix as a client or a service provider.',
                  style: GoogleFonts.outfit(
                    color: ClickFixTheme.textMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),

                // Full Name
                Text(
                  'Full Name',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: ClickFixTheme.primaryAmber,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter your name';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Email
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter email';
                    if (!value.contains('@')) return 'Please enter valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Choose Role
                Text(
                  'Register As',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: ClickFixTheme.primaryAmber,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRole = 'Customer';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'Customer'
                                ? ClickFixTheme.primaryAmber.withOpacity(0.15)
                                : (isDark ? const Color(0xFF2C3034) : ClickFixTheme.primaryLight),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedRole == 'Customer'
                                  ? ClickFixTheme.primaryAmber
                                  : (isDark ? Colors.white10 : ClickFixTheme.borderGray),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.person_rounded,
                                color: _selectedRole == 'Customer' ? ClickFixTheme.primaryAmber : ClickFixTheme.textMuted,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Customer',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _selectedRole == 'Customer'
                                      ? (isDark ? Colors.white : ClickFixTheme.textDark)
                                      : ClickFixTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRole = 'Worker';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'Worker'
                                ? ClickFixTheme.primaryAmber.withOpacity(0.15)
                                : (isDark ? const Color(0xFF2C3034) : ClickFixTheme.primaryLight),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedRole == 'Worker'
                                  ? ClickFixTheme.primaryAmber
                                  : (isDark ? Colors.white10 : ClickFixTheme.borderGray),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.engineering_rounded,
                                color: _selectedRole == 'Worker' ? ClickFixTheme.primaryAmber : ClickFixTheme.textMuted,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Worker (Pro)',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _selectedRole == 'Worker'
                                      ? (isDark ? Colors.white : ClickFixTheme.textDark)
                                      : ClickFixTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
                  validator: (value) {
                    if (value == null || value.trim().length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                  decoration: InputDecoration(
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
                ),
                const SizedBox(height: 20),

                // Confirm Password
                Text(
                  'Confirm Password',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: ClickFixTheme.primaryAmber,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please confirm your password';
                    return null;
                  },
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: ClickFixTheme.textMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Submit Button (Next)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _handleRegister,
                    child: Text(
                      'Next: Complete Setup',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
