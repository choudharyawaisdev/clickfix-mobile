import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/services/auth_service.dart';
import 'package:clickfix/services/location_service.dart';
import 'package:clickfix/screens/main_navigation_screen.dart';
import 'package:clickfix/widgets/interactive_button.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _citySearchController = TextEditingController();
  
  Color _selectedColor = Colors.teal;
  String _selectedCity = '';
  List<String> _allCities = [];
  List<String> _filteredCities = [];
  bool _isLoadingCities = true;
  bool _showCityDropdown = false;

  final List<Color> _avatarColors = const [
    Colors.teal,
    Colors.deepPurple,
    Colors.indigo,
    Colors.orange,
    Colors.blue,
    Colors.pink,
    Colors.green,
    Colors.redAccent,
  ];

  @override
  void initState() {
    super.initState();
    _loadCities();
    _citySearchController.addListener(() {
      final query = _citySearchController.text.trim();
      if (query.isNotEmpty) {
        setState(() {
          _filteredCities = _allCities
              .where((city) => city.toLowerCase().contains(query.toLowerCase()))
              .toList();
          _showCityDropdown = true;
        });
      } else {
        setState(() {
          _filteredCities = [];
          _showCityDropdown = false;
        });
      }
    });
  }

  Future<void> _loadCities() async {
    final list = await LocationService.fetchCities();
    if (mounted) {
      setState(() {
        _allCities = list;
        _isLoadingCities = false;
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _citySearchController.dispose();
    super.dispose();
  }

  void _completeSetup() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCity.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your city location!'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final success = await AuthService().completeProfile(
        _selectedColor,
        _addressController.text.trim(),
        _selectedCity,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome, ${AuthService().currentUser!.name}! Setup complete.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to complete profile setup.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background elegant gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF15181B), ClickFixTheme.primaryDark]
                      : [const Color(0xFFFAFAFA), const Color(0xFFF5F7FA)],
                ),
              ),
            ),
          ),
          // Glowing circle top right
          Positioned(
            top: -120,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ClickFixTheme.primaryAmber.withOpacity(isDark ? 0.08 : 0.04),
              ),
            ),
          ),
          // Glowing circle bottom left
          Positioned(
            bottom: -150,
            left: -80,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ClickFixTheme.primaryAmber.withOpacity(isDark ? 0.04 : 0.02),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Setup',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : ClickFixTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Complete your details so clients or providers can locate you.',
                      style: GoogleFonts.outfit(
                        color: ClickFixTheme.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Card panel for inputs
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C3034).withOpacity(0.85) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.08) : ClickFixTheme.borderGray.withOpacity(0.6),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar Accent Color Picker
                          Text(
                            'Choose Profile Accent Color',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ClickFixTheme.primaryAmber,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedColor.withOpacity(0.4),
                                  width: 4,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 38,
                                backgroundColor: _selectedColor,
                                child: Text(
                                  AuthService().currentUser?.name[0].toUpperCase() ?? 'U',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 52,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _avatarColors.length,
                              itemBuilder: (context, index) {
                                final color = _avatarColors[index];
                                final isSelected = color == _selectedColor;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedColor = color;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: isSelected ? 44 : 38,
                                      height: isSelected ? 44 : 38,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? ClickFixTheme.primaryAmber : Colors.transparent,
                                          width: isSelected ? 3.0 : 0.0,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: color.withOpacity(0.4),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                )
                                              ]
                                            : [],
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            )
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // City Selector
                          Text(
                            'Select City Location',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ClickFixTheme.primaryAmber,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _isLoadingCities
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Loading Pakistan cities...'),
                                    ],
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      controller: _citySearchController,
                                      style: GoogleFonts.outfit(fontSize: 15),
                                      decoration: InputDecoration(
                                        hintText: _selectedCity.isEmpty ? 'Type city (e.g. Faisalabad)' : _selectedCity,
                                        prefixIcon: Icon(
                                          Icons.search_rounded,
                                          color: isDark ? Colors.white70 : ClickFixTheme.textMuted,
                                          size: 20,
                                        ),
                                        suffixIcon: _selectedCity.isNotEmpty
                                            ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                                            : Icon(
                                                Icons.location_city_rounded,
                                                color: isDark ? Colors.white60 : ClickFixTheme.textMuted,
                                              ),
                                      ),
                                    ),
                                    if (_showCityDropdown && _filteredCities.isNotEmpty)
                                      Container(
                                        constraints: const BoxConstraints(maxHeight: 180),
                                        margin: const EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF2C3034) : Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: isDark ? Colors.white10 : ClickFixTheme.borderGray),
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _filteredCities.length,
                                          itemBuilder: (context, index) {
                                            final city = _filteredCities[index];
                                            return ListTile(
                                              title: Text(city, style: GoogleFonts.outfit(fontSize: 14)),
                                              onTap: () {
                                                setState(() {
                                                  _selectedCity = city;
                                                  _citySearchController.text = city;
                                                  _showCityDropdown = false;
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                          const SizedBox(height: 20),

                          // Street Address
                          Text(
                            'Street Address',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ClickFixTheme.primaryAmber,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _addressController,
                            maxLines: 3,
                            style: GoogleFonts.outfit(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'e.g. House #104, Block D, Kohinoor City',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(bottom: 40.0), // align to top
                                child: Icon(
                                  Icons.home_outlined,
                                  color: isDark ? Colors.white70 : ClickFixTheme.textMuted,
                                  size: 20,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Please enter your street address';
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // Submit Button
                          InteractiveButton(
                            onPressed: _completeSetup,
                            child: Text(
                              'Complete Profile Setup',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: ClickFixTheme.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
