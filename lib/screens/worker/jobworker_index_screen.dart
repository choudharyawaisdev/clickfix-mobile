import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/screens/worker/jobworker_create_screen.dart';
import 'package:clickfix/screens/worker/bookings_screen.dart';

class WorkerJobworkerIndexScreen extends StatelessWidget {
  const WorkerJobworkerIndexScreen({super.key});

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
              // Welcome header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back,',
                        style: GoogleFonts.outfit(fontSize: 14, color: ClickFixTheme.textMuted),
                      ),
                      Text(
                        'Hafiz Talha (Pro)',
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 4, backgroundColor: Colors.green),
                        const SizedBox(width: 6),
                        Text(
                          'Online',
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Statistics Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStatCard('Total Earnings', 'Rs. 42,500', Icons.account_balance_wallet_rounded, isDark),
                  _buildStatCard('Jobs Done', '142', Icons.task_alt_rounded, isDark),
                  _buildStatCard('Average Rating', '4.9 / 5.0', Icons.star_rounded, isDark),
                  _buildStatCard('Active Jobs', '2', Icons.directions_run_rounded, isDark),
                ],
              ),
              const SizedBox(height: 28),

              // CTA buttons for creating a new service
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Offered Services',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WorkerJobworkerCreateScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Service'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              _buildOfferedServiceCard('AC Master Cleaning', 'Appliances', 'Rs. 1,500', isDark),
              _buildOfferedServiceCard('UPS Repair & Installation', 'Maintenance', 'Rs. 800', isDark),

              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Job Requests',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WorkerBookingsScreen(),
                        ),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildRequestCard('Plumbing Leakage Fix', 'D-Ground, Faisalabad', 'Rs. 600', '15 mins ago', isDark),
              _buildRequestCard('Sofa Cleaning (5-Seater)', 'Gulberg, Lahore', 'Rs. 2,000', '1 hour ago', isDark),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String val, IconData icon, bool isDark) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: ClickFixTheme.primaryAmber, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(val, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(label, style: GoogleFonts.outfit(fontSize: 11, color: ClickFixTheme.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferedServiceCard(String title, String category, String price, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(category, style: TextStyle(color: ClickFixTheme.textMuted, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(price, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber, fontSize: 14)),
            const SizedBox(width: 8),
            const Icon(Icons.edit_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(String service, String loc, String price, String time, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: ClickFixTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(loc, style: TextStyle(color: ClickFixTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(time, style: TextStyle(color: ClickFixTheme.primaryAmber, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Accept', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
