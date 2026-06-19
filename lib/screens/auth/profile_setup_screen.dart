import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/services/auth_service.dart';
import 'package:clickfix/services/location_service.dart';
import 'package:clickfix/screens/main_navigation_screen.dart';

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

  void _completeSetup() {
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

      AuthService().completeProfile(
        _selectedColor,
        _addressController.text.trim(),
        _selectedCity,
      );

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? ClickFixTheme.primaryDark : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                const SizedBox(height: 32),

                // Avatar Accent Color Picker
                Text(
                  'Choose Profile Accent Color',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: ClickFixTheme.primaryAmber,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: CircleAvatar(
                    radius: 40,
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
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _avatarColors.length,
                    itemBuilder: (context, index) {
                      final color = _avatarColors[index];
                      final isSelected = color == _selectedColor;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? ClickFixTheme.primaryAmber : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
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
                            decoration: InputDecoration(
                              hintText: _selectedCity.isEmpty ? 'Type city (e.g. Faisalabad, Karachi)' : _selectedCity,
                              suffixIcon: _selectedCity.isNotEmpty
                                  ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                                  : const Icon(Icons.location_city_rounded),
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
                                    title: Text(city),
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
                  decoration: const InputDecoration(
                    hintText: 'e.g. House #104, Block D, Kohinoor City',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter your street address';
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _completeSetup,
                    child: Text(
                      'Complete Profile Setup',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
