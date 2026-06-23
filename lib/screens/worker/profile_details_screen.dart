import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/screens/worker/profile_edit_screen.dart';
import 'package:clickfix/screens/auth/login_screen.dart';
import 'package:clickfix/services/auth_service.dart';
import 'package:clickfix/services/api_service.dart';
import 'package:clickfix/models/service_model.dart';

class WorkerProfileDetailsScreen extends StatefulWidget {
  const WorkerProfileDetailsScreen({super.key});

  @override
  State<WorkerProfileDetailsScreen> createState() => _WorkerProfileDetailsScreenState();
}

class _WorkerProfileDetailsScreenState extends State<WorkerProfileDetailsScreen> {
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
      debugPrint('Error refreshing worker profile: $e');
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
    final phone = user?.phoneNumber ?? 'N/A';
    final city = user?.city ?? 'Faisalabad';
    final description = user?.description ?? 'No bio provided.';

    // Resolve service category dynamically
    final service = ServiceModel.services.firstWhere(
      (element) => element.id == user?.serviceId?.toString(),
      orElse: () => const ServiceModel(
        id: '',
        title: 'Professional Service',
        category: 'Worker',
        iconData: Icons.engineering_rounded,
        description: '',
        basePrice: 0,
      ),
    );
    final serviceCategory = service.title;

    final String imageUrl = user?.profilePicture != null && user!.profilePicture!.isNotEmpty
        ? (user.profilePicture!.startsWith('http')
            ? user.profilePicture!
            : 'https://clickfix.hafiztalha.com/storage/${user.profilePicture}')
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Professional Profile',
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
                  builder: (context) => const WorkerProfileEditScreen(),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar details
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
                                backgroundColor: user?.avatarColor ?? Colors.teal,
                                backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                                child: imageUrl.isEmpty
                                    ? Text(
                                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'W',
                                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
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
                            const SizedBox(height: 6),
                            Text(
                              'Category: $serviceCategory',
                              style: GoogleFonts.outfit(fontSize: 14, color: ClickFixTheme.primaryAmber, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Background Verified',
                                style: GoogleFonts.outfit(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      Text(
                        'Professional Overview',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('Phone Number', phone),
                              _buildInfoRow('Service Area / City', city),
                              _buildInfoRow('Response Time', '< 30 Minutes'),
                              _buildInfoRow('Working Hours', '09:00 AM - 08:00 PM'),
                              _buildInfoRow('Member Since', 'Oct 2024'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Professional Bio',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            description,
                            style: GoogleFonts.outfit(fontSize: 13, height: 1.5),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Text(
                        'Recent Reviews',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                      ),
                      const SizedBox(height: 12),

                      _buildReviewItem('Asim Jamil', 5, 'Highly recommended! Arrived on time and solved the inverter AC board error instantly.', '2 days ago'),
                      _buildReviewItem('Fatima Shah', 4, 'Good work but recommended some extra cabling cost.', '1 week ago'),

                      const SizedBox(height: 28),
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
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: GoogleFonts.outfit(fontSize: 13, color: ClickFixTheme.textMuted)),
          Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String author, int rating, String desc, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(author, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(time, style: TextStyle(color: ClickFixTheme.textMuted, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(
                rating,
                (index) => const Icon(Icons.star_rounded, color: ClickFixTheme.primaryAmber, size: 14),
              ),
            ),
            const SizedBox(height: 8),
            Text(desc, style: GoogleFonts.outfit(fontSize: 12, height: 1.4)),
          ],
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
}
