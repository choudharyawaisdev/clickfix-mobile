import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/models/service_model.dart';
import 'package:clickfix/screens/booking_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String selectedCity = 'Faisalabad';
  final List<String> cities = ['Faisalabad', 'Karachi', 'Lahore', 'Islamabad', 'Rawalpindi'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Section
          _buildHeroSection(isDark),
          
          // 2. Stats Section
          _buildStatsSection(isDark),

          // 3. Popular Services Header & List
          _buildSectionHeader(
            context: context,
            title: 'Popular Services',
            subtitle: 'Our most requested home solutions',
            onTap: () {
              // Direct navigation can be implemented by communicating with parent if needed
            },
          ),
          _buildPopularServices(isDark),

          // 4. How It Works Section
          _buildHowItWorksSection(isDark),

          // 5. Why Choose Us Section (Value Props)
          _buildWhyChooseUs(isDark),

          // 6. Testimonials Section
          _buildTestimonialsSection(isDark),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [ClickFixTheme.primaryDark, const Color(0xFF1E2124)]
              : [const Color(0xFFFFF9E6), Colors.white],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Headline
          Text(
            'Experience\nReliability at Your\nDoorstep',
            style: GoogleFonts.outfit(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              height: 1.2,
              color: isDark ? Colors.white : ClickFixTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Get top-rated professionals for all house repairs, plumbing, electrical installations, and cleaning services.',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : ClickFixTheme.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // Search & Filter Card
          Card(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.1) : ClickFixTheme.borderGray.withOpacity(0.6),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // City Selector Dropdown
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: ClickFixTheme.primaryAmber, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCity,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : ClickFixTheme.textDark,
                            ),
                            items: cities.map((String city) {
                              return DropdownMenuItem<String>(
                                value: city,
                                child: Text(city),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedCity = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(height: 1),
                  ),
                  // Search Field
                  Row(
                    children: [
                      Icon(Icons.search_rounded, color: isDark ? Colors.white70 : ClickFixTheme.textMuted, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search for plumber, electrician...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            fillColor: Colors.transparent,
                          ),
                          style: GoogleFonts.outfit(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final query = _searchController.text.trim();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Searching for "$query" in $selectedCity...'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: ClickFixTheme.primaryDark,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ClickFixTheme.primaryAmber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.explore_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Find Experts',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDark) {
    final List<Map<String, dynamic>> stats = [
      {'val': '450+', 'label': 'Active Experts', 'icon': Icons.engineering_rounded},
      {'val': '4.9/5', 'label': 'Avg. Rating', 'icon': Icons.star_rounded},
      {'val': '100%', 'label': 'Premium Quality', 'icon': Icons.workspace_premium_rounded},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      height: 100,
      child: Row(
        children: stats.map((stat) {
          return Expanded(
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              elevation: 0,
              color: isDark ? const Color(0xFF2C3034) : ClickFixTheme.primaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(stat['icon'], size: 16, color: ClickFixTheme.primaryAmber),
                        const SizedBox(width: 4),
                        Text(
                          stat['val'],
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: isDark ? Colors.white : ClickFixTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat['label'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: isDark ? Colors.white50 : ClickFixTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onTap,
                child: const Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        color: ClickFixTheme.primaryAmber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 20, color: ClickFixTheme.primaryAmber),
                  ],
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: ClickFixTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularServices(bool isDark) {
    // Pick 4 popular services (Electrician, Plumbing, AC Repair, Cleaning)
    final popular = ServiceModel.services.take(4).toList();

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: popular.length,
        itemBuilder: (context, index) {
          final service = popular[index];
          return Container(
            width: 155,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingScreen(initialService: service),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ClickFixTheme.primaryAmber.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          service.iconData,
                          color: ClickFixTheme.primaryAmber,
                          size: 24,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Starts at Rs.${service.basePrice.toStringAsFixed(0)}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : ClickFixTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHowItWorksSection(bool isDark) {
    final steps = [
      {
        'num': '01',
        'title': 'Book a Service',
        'desc': 'Select the service you need, choose your time and location, and book instantly.',
        'icon': Icons.touch_app_outlined
      },
      {
        'num': '02',
        'title': 'Professional Arrives',
        'desc': 'Our background-verified professional will arrive at your place fully equipped.',
        'icon': Icons.support_agent_rounded
      },
      {
        'num': '03',
        'title': 'Pay & Relax',
        'desc': 'Get the job done with premium quality, verify the work, and pay securely.',
        'icon': Icons.task_alt_rounded
      },
    ];

    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF1E2124) : ClickFixTheme.primaryLight,
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How ClickFix Works',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Simplifying home maintenance in 3 easy steps',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: ClickFixTheme.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: steps.map((step) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: ClickFixTheme.primaryAmber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        step['num'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ClickFixTheme.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title'] as String,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step['desc'] as String,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: isDark ? Colors.white60 : ClickFixTheme.textMuted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseUs(bool isDark) {
    final benefits = [
      {
        'title': '100% Secure',
        'desc': 'Verified professionals, transparent billing, and secure payment methods.',
        'icon': Icons.security_rounded
      },
      {
        'title': '10,000+ Clients',
        'desc': 'Loved by thousands of homeowners across Pakistan for reliability.',
        'icon': Icons.people_rounded
      },
      {
        'title': 'Top Rated Experts',
        'desc': 'Skilled experts with average ratings above 4.8 stars.',
        'icon': Icons.star_border_rounded
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why Choose ClickFix',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: benefits.map((benefit) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          benefit['icon'] as IconData,
                          color: ClickFixTheme.primaryAmber,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              benefit['title'] as String,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              benefit['desc'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white60 : ClickFixTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection(bool isDark) {
    final testimonials = [
      {
        'name': 'Muhammad Ali',
        'city': 'Faisalabad',
        'rating': 5,
        'comment': 'ClickFix electrician arrived within 30 minutes! Highly professional and fixed the AC short circuit issue immediately.',
        'avatar': 'MA'
      },
      {
        'name': 'Ayesha Khan',
        'city': 'Karachi',
        'rating': 5,
        'comment': 'Used the deep cleaning service for my kitchen. The team was equipped with everything and left the kitchen spotless!',
        'avatar': 'AK'
      },
      {
        'name': 'Zainab Bibi',
        'city': 'Islamabad',
        'rating': 4,
        'comment': 'Great plumbing service. Base rates are transparent and they fixed a leakage that was bothering us for months.',
        'avatar': 'ZB'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text(
            'What Our Clients Say',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: testimonials.length,
            itemBuilder: (context, index) {
              final test = testimonials[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: ClickFixTheme.primaryAmber,
                              child: Text(
                                test['avatar'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ClickFixTheme.primaryDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  test['name'] as String,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  test['city'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white60 : ClickFixTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              children: List.generate(
                                test['rating'] as int,
                                (i) => const Icon(
                                  Icons.star_rounded,
                                  color: ClickFixTheme.primaryAmber,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Text(
                            '"${test['comment']}"',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: isDark ? Colors.white70 : ClickFixTheme.textDark,
                              height: 1.4,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
