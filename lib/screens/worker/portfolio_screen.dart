import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';

class WorkerPortfolioScreen extends StatelessWidget {
  const WorkerPortfolioScreen({super.key});

  final List<Map<String, dynamic>> _dummyProjects = const [
    {
      'title': 'AC Installation at Commercial Office',
      'category': 'AC Repair',
      'date': 'May 2026',
      'description': 'Completed standard installation of 5 inverter split AC units in an office space with copper wiring and insulation checks.',
      'rating': 5.0,
    },
    {
      'title': 'Full Home UPS Backup Integration',
      'category': 'Electrician',
      'date': 'April 2026',
      'description': 'Set up a dual battery 3KVA solar hybrid UPS system with auto-overload cutouts and distribution box configuration.',
      'rating': 4.9,
    },
    {
      'title': 'Smart Home Security Cam Layout',
      'category': 'CCTV Camera',
      'date': 'March 2026',
      'description': 'Installed 8 IP-based 4MP night-vision CCTV cameras with network video recorder (NVR) and cloud-viewing sync.',
      'rating': 4.8,
    }
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Portfolio',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat('12', 'Projects Added'),
                      _buildMiniStat('100%', 'Job Success'),
                      _buildMiniStat('3+', 'Years Exp'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Showcase Projects',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _dummyProjects.length,
                itemBuilder: (context, index) {
                  final proj = _dummyProjects[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Simulated Project Image/Placeholder with Icon
                        Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: Icon(
                            Icons.home_repair_service_rounded,
                            size: 48,
                            color: ClickFixTheme.primaryAmber.withOpacity(0.6),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      proj['category'] as String,
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: ClickFixTheme.primaryAmber,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    proj['date'] as String,
                                    style: GoogleFonts.outfit(fontSize: 12, color: ClickFixTheme.textMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                proj['title'] as String,
                                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                proj['description'] as String,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: isDark ? Colors.white60 : ClickFixTheme.textMuted,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: ClickFixTheme.primaryAmber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${proj['rating']} Client Rating',
                                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, color: ClickFixTheme.primaryAmber),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, color: ClickFixTheme.textMuted),
        ),
      ],
    );
  }
}
