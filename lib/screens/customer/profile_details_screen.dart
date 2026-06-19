import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/screens/customer/profile_edit_screen.dart';

class CustomerProfileDetailsScreen extends StatelessWidget {
  const CustomerProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: ClickFixTheme.primaryAmber),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomerProfileEditScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // User Avatar & Name
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: ClickFixTheme.primaryAmber, width: 3),
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: ClickFixTheme.primaryDark,
                        child: Text(
                          'C',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: ClickFixTheme.primaryAmber,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hafiz Muhammad Talha',
                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'talha@clickfix.com',
                      style: GoogleFonts.outfit(fontSize: 14, color: ClickFixTheme.textMuted),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Premium Customer',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: ClickFixTheme.primaryAmber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Details Group
              _buildSectionHeader('Contact Information', isDark),
              _buildDetailItem(Icons.phone_iphone_rounded, 'Phone', '+92 300 1234567', isDark),
              _buildDetailItem(Icons.location_on_rounded, 'Default Address', 'D-Ground, Faisalabad, Pakistan', isDark),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Account Preferences', isDark),
              _buildDetailItem(Icons.payment_rounded, 'Payment Method', 'Cash on Delivery / Easypaisa', isDark),
              _buildDetailItem(Icons.notifications_active_rounded, 'Notification Settings', 'Push & SMS enabled', isDark),
              _buildDetailItem(Icons.language_rounded, 'Language', 'English / Urdu', isDark),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logging out...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ClickFixTheme.primaryAmber,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: ClickFixTheme.primaryAmber),
        title: Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, color: ClickFixTheme.textMuted),
        ),
        subtitle: Text(
          value,
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
