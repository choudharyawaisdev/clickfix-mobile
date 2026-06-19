import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/models/service_model.dart';
import 'package:clickfix/screens/booking_screen.dart';
import 'package:clickfix/screens/customer/job_details_screen.dart';

class WorkerServicesScreen extends StatelessWidget {
  final String serviceCategory;

  const WorkerServicesScreen({
    super.key,
    required this.serviceCategory,
  });

  // Simulated worker list for demonstration
  static const List<Map<String, dynamic>> dummyWorkers = [
    {
      'name': 'Hafiz Muhammad Talha',
      'rating': 4.9,
      'completedJobs': 142,
      'experience': '5 Years',
      'priceMultiplier': 1.0,
      'badge': 'Top Rated Pro',
      'about': 'Professional repair expert specializing in residential electrical setups and appliances.',
      'avatarColor': Colors.teal,
    },
    {
      'name': 'Awais Choudhary',
      'rating': 4.8,
      'completedJobs': 98,
      'experience': '3 Years',
      'priceMultiplier': 0.9,
      'badge': 'Super Fast',
      'about': 'Quick response handyman, expert in plumbing fixes and water system diagnostics.',
      'avatarColor': Colors.deepPurple,
    },
    {
      'name': 'Sajid Mehmood',
      'rating': 5.0,
      'completedJobs': 210,
      'experience': '8 Years',
      'priceMultiplier': 1.1,
      'badge': 'Gold Elite',
      'about': 'Master contractor with extensive experience in structural, wood and painting installations.',
      'avatarColor': Colors.indigo,
    },
    {
      'name': 'Imran Khan',
      'rating': 4.7,
      'completedJobs': 56,
      'experience': '2 Years',
      'priceMultiplier': 0.85,
      'badge': 'Budget Friendly',
      'about': 'Affordable solutions for general home maintenance, solar alignment, and IT network diagnostics.',
      'avatarColor': Colors.orange,
    }
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Filter services belonging to this category
    final categoryServices = ServiceModel.services
        .where((s) => s.category.toLowerCase() == serviceCategory.toLowerCase())
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          serviceCategory,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: categoryServices.isEmpty
          ? Center(
              child: Text(
                'No services in this category.',
                style: GoogleFonts.outfit(color: ClickFixTheme.textMuted),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Services',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: categoryServices.length,
                      itemBuilder: (context, index) {
                        final service = categoryServices[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(service.iconData, color: ClickFixTheme.primaryAmber),
                            ),
                            title: Text(
                              service.title,
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Starts from Rs. ${service.basePrice.toStringAsFixed(0)}',
                              style: TextStyle(color: ClickFixTheme.primaryAmber, fontWeight: FontWeight.w600),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                            onTap: () {
                              Navigator.push(
                                context,
                                  MaterialPageRoute(
                                    builder: (context) => JobDetailsScreen(service: service),
                                  ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Featured Service Providers',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dummyWorkers.length,
                      itemBuilder: (context, index) {
                        final worker = dummyWorkers[index];
                        final service = categoryServices.first;
                        final workerBasePrice = service.basePrice * worker['priceMultiplier'];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundColor: worker['avatarColor'] as Color,
                                      child: Text(
                                        worker['name'][0],
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                worker['name'] as String,
                                                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: ClickFixTheme.primaryAmber.withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  worker['badge'] as String,
                                                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.star_rounded, color: ClickFixTheme.primaryAmber, size: 14),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${worker['rating']} (${worker['completedJobs']} jobs)',
                                                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(Icons.history_rounded, size: 14, color: ClickFixTheme.textMuted),
                                              const SizedBox(width: 2),
                                              Text(
                                                worker['experience'] as String,
                                                style: GoogleFonts.outfit(fontSize: 12, color: ClickFixTheme.textMuted),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  worker['about'] as String,
                                  style: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.white60 : ClickFixTheme.textMuted),
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Estimated Cost', style: TextStyle(fontSize: 10, color: ClickFixTheme.textMuted)),
                                        Text(
                                          'Rs. ${workerBasePrice.toStringAsFixed(0)}',
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: ClickFixTheme.primaryAmber),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BookingScreen(
                                              initialService: service,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text('Hire Expert'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
}
