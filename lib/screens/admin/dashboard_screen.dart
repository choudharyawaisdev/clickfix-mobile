import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Control Hub',
                style: GoogleFonts.outfit(fontSize: 14, color: ClickFixTheme.textMuted, fontWeight: FontWeight.bold),
              ),
              Text(
                'Platform Overview',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 20),

              // Overview Metrics Row
              Row(
                children: [
                  Expanded(child: _buildMetricCard('Total Revenue', 'Rs. 248K', Icons.insights_rounded, isDark)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricCard('Active Bookings', '32', Icons.receipt_long_rounded, isDark)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildMetricCard('Total Workers', '45', Icons.engineering_rounded, isDark)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricCard('Registered Users', '1,240', Icons.people_rounded, isDark)),
                ],
              ),

              const SizedBox(height: 28),
              Text(
                'Platform Booking Volume',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Dynamic booking chart using simple Flutter widgets
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Weekly Reports', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('+18% from last week', style: GoogleFonts.outfit(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBar('Mon', 40, isDark),
                            _buildBar('Tue', 55, isDark),
                            _buildBar('Wed', 70, isDark),
                            _buildBar('Thu', 50, isDark),
                            _buildBar('Fri', 85, isDark),
                            _buildBar('Sat', 100, isDark),
                            _buildBar('Sun', 95, isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),
              Text(
                'Pending Worker Verifications',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _buildVerificationItem('Zahid Mahmood', 'Carpenter', 'Lahore', isDark),
              _buildVerificationItem('Muhammad Rizwan', 'Electrician', 'Rawalpindi', isDark),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, bool isDark) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: ClickFixTheme.primaryAmber, size: 24),
                const Icon(Icons.arrow_forward_rounded, size: 14, color: ClickFixTheme.textMuted),
              ],
            ),
            const SizedBox(height: 16),
            Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.outfit(fontSize: 11, color: ClickFixTheme.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String day, double percentage, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 14,
          height: percentage,
          decoration: BoxDecoration(
            color: ClickFixTheme.primaryAmber,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(day, style: GoogleFonts.outfit(fontSize: 10, color: ClickFixTheme.textMuted)),
      ],
    );
  }

  Widget _buildVerificationItem(String name, String skill, String city, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('$skill • $city', style: TextStyle(color: ClickFixTheme.textMuted, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                side: const BorderSide(color: Colors.redAccent),
                foregroundColor: Colors.redAccent,
              ),
              child: const Text('Reject', style: TextStyle(fontSize: 10)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
              ),
              child: const Text('Approve', style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}
