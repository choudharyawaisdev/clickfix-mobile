import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/screens/customer/profile_edit_screen.dart';
import 'package:clickfix/screens/auth/login_screen.dart';
import 'package:clickfix/services/auth_service.dart';
import 'package:clickfix/services/api_service.dart';

class CustomerProfileDetailsScreen extends StatefulWidget {
  const CustomerProfileDetailsScreen({super.key});

  @override
  State<CustomerProfileDetailsScreen> createState() => _CustomerProfileDetailsScreenState();
}

class _CustomerProfileDetailsScreenState extends State<CustomerProfileDetailsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService().getProfile();
      if (response['status'] == true && response.containsKey('data')) {
        if (mounted) {
          setState(() {
            AuthService().currentUser = ClickFixUser.fromJson(response['data']);
          });
        }
      }
    } catch (e) {
      debugPrint('Error refreshing customer profile: $e');
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = AuthService().currentUser;
    final displayName = user?.name ?? 'Guest User';
    final displayEmail = user?.email ?? 'guest@clickfix.com';
    final role = user?.role ?? 'customer';
    final displayRole = role.isNotEmpty ? (role[0].toUpperCase() + role.substring(1)) : 'Customer';
    final phone = user?.phoneNumber ?? 'N/A';
    final city = user?.city ?? 'Faisalabad';
    final address = user?.description ?? 'No address set';

    final String imageUrl = user?.profilePicture != null && user!.profilePicture!.isNotEmpty
        ? (user.profilePicture!.startsWith('http')
            ? user.profilePicture!
            : 'https://clickfix.hafiztalha.com/storage/${user.profilePicture}')
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshProfile,
            tooltip: 'Refresh Profile',
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: ClickFixTheme.primaryAmber),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomerProfileEditScreen(),
                ),
              );
              if (updated == true) {
                _refreshProfile();
              }
            },
          ),
        ],
      ),
      body: _isLoading && user == null
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshProfile,
              color: ClickFixTheme.primaryAmber,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: user?.avatarColor ?? ClickFixTheme.primaryDark,
                                backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                                child: imageUrl.isEmpty
                                    ? Text(
                                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              displayName,
                              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              displayEmail,
                              style: GoogleFonts.outfit(fontSize: 14, color: ClickFixTheme.textMuted),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$displayRole Account',
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
                      _buildDetailItem(Icons.phone_iphone_rounded, 'Phone Number', phone, isDark),
                      _buildDetailItem(Icons.location_on_rounded, 'Street Address / Bio', address, isDark),
                      _buildDetailItem(Icons.location_city_rounded, 'City', city, isDark),
                      
                      const SizedBox(height: 24),
                      _buildSectionHeader('Account Preferences', isDark),
                      _buildDetailItem(Icons.payment_rounded, 'Payment Method', 'Cash on Delivery / Easypaisa', isDark),
                      _buildDetailItem(Icons.notifications_active_rounded, 'Notification Settings', 'Push & SMS enabled', isDark),
                      _buildDetailItem(Icons.language_rounded, 'Language', 'English / Urdu', isDark),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Logging out...'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            await AuthService().logout();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                (route) => false,
                              );
                            }
                          },
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Log Out'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showDeleteAccountDialog(context),
                          icon: const Icon(Icons.delete_forever_rounded),
                          label: const Text('Delete Account'),
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
            ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete Account',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.redAccent),
          ),
          content: Text(
            'Are you sure you want to permanently delete your account? This action cannot be undone and you will lose all bookings and profile information.',
            style: GoogleFonts.outfit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(color: ClickFixTheme.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Close dialog
                _performDeleteAccount(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _performDeleteAccount(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
        ),
      ),
    );

    final success = await AuthService().deleteAccount();

    if (context.mounted) {
      Navigator.pop(context); // Close loader
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Account deleted successfully' : 'Account deletion requested successfully.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
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
