import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/screens/worker/profile_edit_screen.dart';

class WorkerProfileDetailsScreen extends StatelessWidget {
  const WorkerProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Professional Profile',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: ClickFixTheme.primaryAmber),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkerProfileEditScreen(),
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
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.teal,
                        child: Text(
                          'T',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hafiz Muhammad Talha',
                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Category: AC Repair & Electrical',
                      style: GoogleFonts.outfit(fontSize: 14, color: ClickFixTheme.textMuted),
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
                      _buildInfoRow('Service Area', 'Faisalabad & Suburbs'),
                      _buildInfoRow('Response Time', '< 30 Minutes'),
                      _buildInfoRow('Working Hours', '09:00 AM - 08:00 PM'),
                      _buildInfoRow('Member Since', 'Oct 2024'),
                    ],
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
              
              const SizedBox(height: 40),
            ],
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
}
