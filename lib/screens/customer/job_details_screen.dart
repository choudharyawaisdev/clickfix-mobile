import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/models/service_model.dart';
import 'package:clickfix/screens/booking_screen.dart';

class JobDetailsScreen extends StatelessWidget {
  final ServiceModel service;

  const JobDetailsScreen({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Service Details',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${service.title}" added to wishlist'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image/Icon Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              color: isDark ? const Color(0xFF1E2124) : ClickFixTheme.primaryAmber.withOpacity(0.06),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ClickFixTheme.primaryAmber.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: ClickFixTheme.primaryAmber.withOpacity(0.4), width: 2),
                    ),
                    child: Icon(
                      service.iconData,
                      size: 64,
                      color: ClickFixTheme.primaryAmber,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      service.category.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: ClickFixTheme.primaryAmber,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.title,
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, color: ClickFixTheme.primaryAmber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${service.rating} Rating',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.people_rounded, color: ClickFixTheme.primaryAmber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${service.activeWorkers} Pros Active',
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
                  Text(
                    'About Service',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : ClickFixTheme.textMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Inclusions/Exclusions list
                  Text(
                    'What is Included',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildBulletItem('Professional & certified expert deployment', isDark),
                  _buildBulletItem('Complete safety evaluation & inspection', isDark),
                  _buildBulletItem('Tools & basic diagnostic kit checklist', isDark),
                  _buildBulletItem('Post-service cleaning of work area', isDark),
                  
                  const SizedBox(height: 24),
                  Text(
                    'Please Note',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildBulletItem('Spare parts or replacement hardware will be charged separately', isDark, isWarning: true),
                  _buildBulletItem('Base inspection charge is non-refundable', isDark, isWarning: true),
                  
                  const SizedBox(height: 32),
                  
                  // Customer Reviews Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Customer Reviews',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'See All',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ClickFixTheme.primaryAmber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildReviewCard('Asim Jamil', 5, 'Absolutely fantastic service! The professional fixed our AC leakage within 20 minutes.', isDark),
                  _buildReviewCard('Mariam Bibi', 4, 'Very polite technician. Clean work, but arrived 10 minutes late.', isDark),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? ClickFixTheme.primaryDark : Colors.white,
          border: Border(
            top: BorderSide(color: isDark ? Colors.white10 : ClickFixTheme.borderGray),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Starting Cost',
                  style: GoogleFonts.outfit(fontSize: 12, color: ClickFixTheme.textMuted),
                ),
                Text(
                  'Rs. ${service.basePrice.toStringAsFixed(0)}',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: ClickFixTheme.primaryAmber,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingScreen(initialService: service),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Book Service',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletItem(String text, bool isDark, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isWarning ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            color: isWarning ? Colors.redAccent : Colors.green,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: isDark ? Colors.white70 : ClickFixTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String name, int stars, String comment, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                Row(
                  children: List.generate(
                    stars,
                    (index) => const Icon(Icons.star_rounded, color: ClickFixTheme.primaryAmber, size: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              comment,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: isDark ? Colors.white60 : ClickFixTheme.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
