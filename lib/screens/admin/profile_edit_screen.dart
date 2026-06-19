import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';

class AdminProfileEditScreen extends StatefulWidget {
  const AdminProfileEditScreen({super.key});

  @override
  State<AdminProfileEditScreen> createState() => _AdminProfileEditScreenState();
}

class _AdminProfileEditScreenState extends State<AdminProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _securityCodeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Platform Admin');
    _emailController = TextEditingController(text: 'admin@clickfix.com');
    _securityCodeController = TextEditingController(text: '••••••••');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _securityCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Admin Profile',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ClickFixTheme.primaryAmber, width: 3),
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: ClickFixTheme.primaryDark,
                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 48,
                            color: ClickFixTheme.primaryAmber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Admin Display Name',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter display name';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Text(
                  'Admin Email Address',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
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

                Text(
                  'Admin Passcode / Security Key',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _securityCodeController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter passcode';
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Admin settings updated successfully'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'Save Admin Profile',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
