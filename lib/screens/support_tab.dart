import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';

class SupportTab extends StatefulWidget {
  const SupportTab({super.key});

  @override
  State<SupportTab> createState() => _SupportTabState();
}

class _SupportTabState extends State<SupportTab> {
  final _partnerFormKey = GlobalKey<FormState>();
  final TextEditingController _pNameController = TextEditingController();
  final TextEditingController _pPhoneController = TextEditingController();
  final TextEditingController _pExperienceController = TextEditingController();
  
  String _selectedSkill = 'Electrician';
  String _selectedCity = 'Faisalabad';

  final List<String> _skills = [
    'Electrician',
    'Plumber',
    'AC Mechanic',
    'Carpenter',
    'House Cleaner',
    'Painter',
    'Solar Installer',
    'CCTV Installer',
    'Gardener',
    'Mason',
  ];

  final List<String> _cities = ['Faisalabad', 'Karachi', 'Lahore', 'Islamabad', 'Rawalpindi'];

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How long does it take for a provider to arrive?',
      'a': 'Once your booking is accepted by an expert, they typically arrive at your selected time slot. For emergency bookings, they can arrive within 30-60 minutes.',
    },
    {
      'q': 'Are ClickFix professionals background-verified?',
      'a': 'Yes, absolutely. We perform rigorous identity checks, criminal background checks, and practical skill evaluations before onboarding any professional to ensure your safety and quality.',
    },
    {
      'q': 'What if something gets damaged during the service?',
      'a': 'We hold our experts to the highest standard, but in the rare event of accidental damage, ClickFix offers service protection and our support team will resolve it within 24 hours.',
    },
    {
      'q': 'How do I pay for the service?',
      'a': 'You can pay the professional directly in cash after the job is completed, or choose digital wallet transfers (JazzCash/EasyPaisa) upon completion.',
    },
  ];

  // Track which FAQs are expanded
  final List<bool> _faqExpandedStates = [false, false, false, false];

  @override
  void dispose() {
    _pNameController.dispose();
    _pPhoneController.dispose();
    _pExperienceController.dispose();
    super.dispose();
  }

  void _submitPartnerApplication() {
    if (_partnerFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Application submitted! We will contact you soon.',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      _pNameController.clear();
      _pPhoneController.clear();
      _pExperienceController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Support & Feedback',
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Get help or join our growing network of service experts',
              style: GoogleFonts.outfit(color: ClickFixTheme.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Contact cards
            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    context: context,
                    icon: Icons.email_outlined,
                    title: 'Email Us',
                    info: 'support@clickfix.pk',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildContactCard(
                    context: context,
                    icon: Icons.phone_android_rounded,
                    title: 'Call Support',
                    info: '+92 (041) 1234567',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              context: context,
              icon: Icons.location_on_outlined,
              title: 'Office Location',
              info: 'Peoples Colony No. 1, Faisalabad, Pakistan',
              isDark: isDark,
              isFullWidth: true,
            ),
            const SizedBox(height: 28),

            // FAQs Section
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                final isExpanded = _faqExpandedStates[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    title: Text(
                      faq['q']!,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : ClickFixTheme.textDark,
                      ),
                    ),
                    trailing: Icon(
                      isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: ClickFixTheme.primaryAmber,
                    ),
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _faqExpandedStates[index] = expanded;
                      });
                    },
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedAlignment: Alignment.topLeft,
                    shape: const Border(), // Remove default divider borders on expansion
                    children: [
                      Text(
                        faq['a']!,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : ClickFixTheme.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Become a Partner Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF2C3034), const Color(0xFF232629)]
                      : [const Color(0xFFFFF9E6), const Color(0xFFFFF3CD)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ClickFixTheme.primaryAmber.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Form(
                key: _partnerFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.engineering_rounded, color: ClickFixTheme.primaryAmber, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Join ClickFix Network',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ClickFixTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Are you a skilled plumber, electrician, or AC mechanic? Earn reliable income by registering with ClickFix.',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: ClickFixTheme.textDark.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.black12, height: 1),
                    const SizedBox(height: 16),

                    // Partner Name
                    _buildDarkFormLabel('Full Name'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _pNameController,
                      style: const TextStyle(color: ClickFixTheme.textDark),
                      decoration: _buildPartnerInputDecoration('Enter your name'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Partner Phone
                    _buildDarkFormLabel('Phone Number'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _pPhoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: ClickFixTheme.textDark),
                      decoration: _buildPartnerInputDecoration('03xx-xxxxxxx'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your phone';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Partner Skill Dropdown & City
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDarkFormLabel('Your Skill'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _selectedSkill,
                                style: const TextStyle(color: ClickFixTheme.textDark),
                                decoration: _buildPartnerInputDecoration(''),
                                items: _skills.map((skill) {
                                  return DropdownMenuItem(
                                    value: skill,
                                    child: Text(skill, style: const TextStyle(color: ClickFixTheme.textDark)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedSkill = val!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDarkFormLabel('Select City'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _selectedCity,
                                style: const TextStyle(color: ClickFixTheme.textDark),
                                decoration: _buildPartnerInputDecoration(''),
                                items: _cities.map((city) {
                                  return DropdownMenuItem(
                                    value: city,
                                    child: Text(city, style: const TextStyle(color: ClickFixTheme.textDark)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedCity = val!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Experience
                    _buildDarkFormLabel('Years of Experience'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _pExperienceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: ClickFixTheme.textDark),
                      decoration: _buildPartnerInputDecoration('E.g., 5 years'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submitPartnerApplication,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ClickFixTheme.primaryDark,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          'Submit Registration',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkFormLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: ClickFixTheme.textDark,
      ),
    );
  }

  InputDecoration _buildPartnerInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: GoogleFonts.outfit(color: ClickFixTheme.textMuted, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black12, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black12, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ClickFixTheme.primaryDark, width: 1.5),
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String info,
    required bool isDark,
    bool isFullWidth = false,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ClickFixTheme.primaryAmber.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: ClickFixTheme.primaryAmber,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                info,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : ClickFixTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
