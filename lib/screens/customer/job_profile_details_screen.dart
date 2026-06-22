import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/models/service_model.dart';
import 'package:clickfix/services/api_service.dart';
import 'package:clickfix/screens/booking_screen.dart';
import 'package:clickfix/screens/chat/chat_screen.dart';

class JobProfileDetailsScreen extends StatefulWidget {
  final int jobId;

  const JobProfileDetailsScreen({
    super.key,
    required this.jobId,
  });

  @override
  State<JobProfileDetailsScreen> createState() => _JobProfileDetailsScreenState();
}

class _JobProfileDetailsScreenState extends State<JobProfileDetailsScreen> {
  bool _isLoading = true;
  dynamic _jobData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService().getJobDetails(widget.jobId);
      if (response['status'] == true && response.containsKey('data')) {
        setState(() {
          _jobData = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load job details.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    // Format phone number by removing '+' or formatting spaces if necessary,
    // but the backend format +923001234567 is compatible with wa.me
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final urlString = 'https://wa.me/$cleanPhone?text=Hello%20I%20found%20your%20job%20on%20ClickFix%20and%20need%20assistance.';
    final uri = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch WhatsApp. Please check if it is installed.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching WhatsApp: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _navigateToChat(int userId, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          receiverId: userId,
          receiverName: name,
        ),
      ),
    );
  }

  void _handleBooking(dynamic workerUser, ServiceModel service) {
    final bool isOnline = workerUser['is_online'] == true || workerUser['is_online'] == 1 || workerUser['is_online'] == '1';
    
    if (!isOnline) {
      // Worker is offline. Show warning dialog.
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                const SizedBox(width: 8),
                Text('Pro is Offline', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              '${workerUser['name'] ?? 'This provider'} is currently offline. Workers must be online to receive bookings. You can try sending a chat message or checking back later.',
              style: GoogleFonts.outfit(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close', style: GoogleFonts.outfit(color: ClickFixTheme.textMuted)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _navigateToChat(workerUser['id'], workerUser['name'] ?? 'Provider');
                },
                child: Text('Chat Instead', style: GoogleFonts.outfit()),
              ),
            ],
          );
        },
      );
      return;
    }

    // Pro is online, navigate to booking form
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingScreen(
          initialService: service,
          workerId: workerUser['id'],
          workerName: workerUser['name'],
        ),
      ),
    );
  }

  ServiceModel _getServiceModel(dynamic serviceData) {
    if (serviceData == null) return ServiceModel.services.first;
    final String serviceId = (serviceData['id'] ?? '').toString();
    return ServiceModel.services.firstWhere(
      (element) => element.id == serviceId,
      orElse: () => ServiceModel(
        id: serviceId,
        title: serviceData['title'] ?? serviceData['name'] ?? 'Service',
        category: serviceData['category'] ?? 'Maintenance',
        description: serviceData['description'] ?? '',
        basePrice: double.tryParse((serviceData['base_price'] ?? serviceData['basePrice'] ?? '0').toString()) ?? 0,
        iconData: Icons.engineering_rounded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 60, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _fetchDetails,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final workerUser = _jobData['user'] ?? {};
    final serviceData = _jobData['service'];
    final ServiceModel service = _getServiceModel(serviceData);

    final String title = _jobData['title'] ?? service.title;
    final double price = double.tryParse((_jobData['price'] ?? '0').toString()) ?? service.basePrice;
    final String location = _jobData['location'] ?? workerUser['city'] ?? 'Faisalabad';
    final String description = _jobData['description'] ?? 'No description provided.';
    
    final String workerName = workerUser['name'] ?? 'Professional';
    final String workerPhone = workerUser['phone_number'] ?? '';
    final int workerId = workerUser['id'] ?? 0;
    final int completedJobs = workerUser['completed_jobs_count'] ?? 0;
    final int level = workerUser['user_level'] ?? 0;
    final bool isOnline = workerUser['is_online'] == true || workerUser['is_online'] == 1 || workerUser['is_online'] == '1';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Service Profile',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: () async {
              final res = await ApiService().toggleWishlist(workerId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res['message'] ?? 'Wishlist updated'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              color: isDark ? const Color(0xFF1E2124) : ClickFixTheme.primaryAmber.withOpacity(0.05),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: ClickFixTheme.primaryAmber.withOpacity(0.2),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.teal,
                          child: Text(
                            workerName.isNotEmpty ? workerName[0].toUpperCase() : 'P',
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 36),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isOnline ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? const Color(0xFF1E2124) : Colors.white, width: 3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    workerName,
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: isOnline ? Colors.green.withOpacity(0.12) : Colors.grey.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isOnline ? 'ONLINE' : 'OFFLINE',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isOnline ? Colors.green : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: ClickFixTheme.primaryAmber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Level $level Pro',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: ClickFixTheme.primaryAmber,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, color: ClickFixTheme.primaryAmber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '4.9 Rating',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.task_alt_rounded, color: Colors.teal, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$completedJobs Jobs Finished',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Listing Title & Price Card
                  Text(
                    title,
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: ClickFixTheme.primaryAmber, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        location,
                        style: GoogleFonts.outfit(color: ClickFixTheme.textMuted, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Description Card
                  Text(
                    'Professional Description',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C3034) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.05) : ClickFixTheme.borderGray,
                      ),
                    ),
                    child: Text(
                      description,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? Colors.white70 : ClickFixTheme.textDark,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  // Inclusions
                  Text(
                    'What we promise',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildBulletRow(Icons.verified_user_outlined, 'ClickFix Verified Professional guarantee'),
                  _buildBulletRow(Icons.monetization_on_outlined, 'No hidden platform fees, payment upon completion'),
                  _buildBulletRow(Icons.support_agent_outlined, '24/7 dedicated ClickFix support channel assistance'),
                  
                  const SizedBox(height: 120), // Bottom sheet spacing
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        decoration: BoxDecoration(
          color: isDark ? ClickFixTheme.primaryDark : Colors.white,
          border: Border(
            top: BorderSide(color: isDark ? Colors.white10 : ClickFixTheme.borderGray),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated Cost',
                  style: GoogleFonts.outfit(fontSize: 13, color: ClickFixTheme.textMuted, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Rs. ${price.toStringAsFixed(0)}',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: ClickFixTheme.primaryAmber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // WhatsApp Button
                if (workerPhone.isNotEmpty) ...[
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => _launchWhatsApp(workerPhone),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.green, size: 24),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                // Chat Button
                SizedBox(
                  width: 52,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => _navigateToChat(workerId, workerName),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ClickFixTheme.primaryAmber,
                      side: const BorderSide(color: ClickFixTheme.primaryAmber, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.forum_outlined, color: ClickFixTheme.primaryAmber, size: 24),
                  ),
                ),
                const SizedBox(width: 10),
                // Book Button
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _handleBooking(workerUser, service),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Book Now',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(fontSize: 13, color: ClickFixTheme.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
