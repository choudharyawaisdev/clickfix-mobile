import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clickfix/services/auth_service.dart';
import 'package:clickfix/services/api_service.dart';
import 'package:clickfix/services/location_service.dart';
import 'package:clickfix/screens/auth/profile_setup_screen.dart';
import 'package:clickfix/widgets/interactive_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController(text: 'Faisalabad');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _selectedRole = 'Customer'; // default selection
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreeToPrivacy = false;

  List<dynamic> _apiServices = [];
  bool _isLoadingServices = false;
  int? _selectedServiceId;

  List<String> _allCities = [];
  List<String> _filteredCities = [];
  bool _isLoadingCities = true;
  bool _showCityDropdown = false;
  String _selectedCity = 'Faisalabad';

  @override
  void initState() {
    super.initState();
    _loadCities();
    _cityController.addListener(_onCityChanged);
  }

  void _onCityChanged() {
    final query = _cityController.text.trim();
    if (query.isNotEmpty && query != _selectedCity) {
      setState(() {
        _filteredCities = _allCities
            .where((city) => city.toLowerCase().contains(query.toLowerCase()))
            .toList();
        _showCityDropdown = true;
      });
    } else if (query.isEmpty) {
      setState(() {
        _filteredCities = [];
        _showCityDropdown = false;
      });
    }
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

  void _loadServices() async {
    setState(() {
      _isLoadingServices = true;
    });
    try {
      final response = await ApiService().getServices();
      if (response['status'] == true && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          setState(() {
            _apiServices = data;
            if (_apiServices.isNotEmpty) {
              _selectedServiceId = _apiServices.first['id'] as int?;
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingServices = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cityController.removeListener(_onCityChanged);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_agreeToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the Privacy Policy to proceed.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match!'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final success = await AuthService().register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        role: _selectedRole.toLowerCase(),
        serviceId: _selectedRole == 'Worker' ? _selectedServiceId : null,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration failed. Email or phone might already exist!'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Widget _buildRoleCard({
    required String role,
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? ClickFixTheme.primaryAmber.withOpacity(isDark ? 0.15 : 0.1)
                : (isDark ? const Color(0xFF2C3034) : ClickFixTheme.primaryLight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? ClickFixTheme.primaryAmber
                  : (isDark ? Colors.white.withOpacity(0.08) : ClickFixTheme.borderGray),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: ClickFixTheme.primaryAmber.withOpacity(isDark ? 0.15 : 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ClickFixTheme.primaryAmber.withOpacity(0.2)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? ClickFixTheme.primaryAmber : ClickFixTheme.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isSelected
                      ? (isDark ? Colors.white : ClickFixTheme.textDark)
                      : ClickFixTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : ClickFixTheme.textDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
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
          // Main scrollable view
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
                      'Create Account',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : ClickFixTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Join ClickFix as a client or a service provider.',
                      style: GoogleFonts.outfit(
                        color: ClickFixTheme.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Card Panel for Form
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
                          // Full Name
                          Text(
                            'Full Name',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ClickFixTheme.primaryAmber,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            style: GoogleFonts.outfit(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'Enter your full name',
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                color: isDark ? Colors.white70 : ClickFixTheme.textMuted,
                                size: 20,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Please enter your name';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Email
                          Text(
                            'Email Address',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ClickFixTheme.primaryAmber,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.outfit(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'Enter your email',
                              prefixIcon: Icon(
                                Icons.mail_outline_rounded,
                                color: isDark ? Colors.white70 : ClickFixTheme.textMuted,
                                size: 20,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Please enter email';
                              if (!value.contains('@')) return 'Please enter valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Phone Number
                          Text(
                            'Phone Number',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ClickFixTheme.primaryAmber,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.outfit(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'e.g. +923001234567',
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: isDark ? Colors.white70 : ClickFixTheme.textMuted,
                                size: 20,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Please enter phone number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // City
                          Text(
                            'City Location',
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
                                      controller: _cityController,
                                      style: GoogleFonts.outfit(fontSize: 15),
                                      decoration: InputDecoration(
                                        hintText: 'Type city (e.g. Lahore, Karachi)',
                                        prefixIcon: Icon(
                                          Icons.location_city_rounded,
                                          color: isDark ? Colors.white70 : ClickFixTheme.textMuted,
                                          size: 20,
                                        ),
                                        suffixIcon: _allCities.contains(_cityController.text.trim())
                                            ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                                            : null,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) return 'Please enter city';
                                        return null;
                                      },
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
                                                  _cityController.text = city;
                                                  _showCityDropdown = false;
                                                });
                                                FocusScope.of(context).unfocus();
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                          const SizedBox(height: 18),

                          // Choose Role
                          Text(
                            'Register As',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ClickFixTheme.primaryAmber,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildRoleCard(
                                role: 'Customer',
                                icon: Icons.person_rounded,
                                label: 'Customer',
                                isDark: isDark,
                                onTap: () {
                                  setState(() {
                                    _selectedRole = 'Customer';
                                  });
                                },
                              ),
                              const SizedBox(width: 16),
                              _buildRoleCard(
                                role: 'Worker',
                                icon: Icons.engineering_rounded,
                                label: 'Worker (Pro)',
                                isDark: isDark,
                                onTap: () {
                                  setState(() {
                                    _selectedRole = 'Worker';
                                  });
                                  if (_apiServices.isEmpty) {
                                    _loadServices();
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          if (_selectedRole == 'Worker') ...[
                            Text(
                              'Select Service Field',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: ClickFixTheme.primaryAmber,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _isLoadingServices
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
                                      ),
                                    ),
                                  )
                                : DropdownButtonFormField<int>(
                                    value: _selectedServiceId,
                                    dropdownColor: isDark ? const Color(0xFF2C3034) : Colors.white,
                                    items: _apiServices.map<DropdownMenuItem<int>>((service) {
                                      final serviceName = service['name'] ?? service['title'] ?? 'Specialist';
                                      return DropdownMenuItem<int>(
                                        value: service['id'] as int,
                                        child: Text(
                                          serviceName.toString(),
                                          style: GoogleFonts.outfit(fontSize: 14),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedServiceId = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (_selectedRole == 'Worker' && value == null) {
                                        return 'Please select your service';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Select field...',
                                      prefixIcon: Icon(
                                        Icons.construction_rounded,
                                        color: isDark ? Colors.white70 : ClickFixTheme.textMuted,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 18),
                          ],

                          // Password
                          Text(
                            'Password',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ClickFixTheme.primaryAmber,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.outfit(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'Minimum 8 characters',
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: isDark ? Colors.white70 : ClickFixTheme.textMuted,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: ClickFixTheme.textMuted,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().length < 8) return 'Password must be at least 8 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Confirm Password
                          Text(
                            'Confirm Password',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ClickFixTheme.primaryAmber,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: GoogleFonts.outfit(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'Re-enter your password',
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: isDark ? Colors.white70 : ClickFixTheme.textMuted,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: ClickFixTheme.textMuted,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Please confirm your password';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Privacy Policy Prominent Disclosure Consent
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _agreeToPrivacy,
                                  activeColor: ClickFixTheme.primaryAmber,
                                  onChanged: (val) {
                                    setState(() {
                                      _agreeToPrivacy = val ?? false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _agreeToPrivacy = !_agreeToPrivacy;
                                    });
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: isDark ? Colors.white70 : ClickFixTheme.textDark,
                                      ),
                                      children: [
                                        const TextSpan(text: 'I agree to the collection of my profile details in accordance with the '),
                                        WidgetSpan(
                                          alignment: PlaceholderAlignment.middle,
                                          child: GestureDetector(
                                            onTap: () async {
                                              final uri = Uri.parse('https://clickfix.hafiztalha.com/privacy-policy');
                                              if (await canLaunchUrl(uri)) {
                                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                                              }
                                            },
                                            child: Text(
                                              'Privacy Policy',
                                              style: GoogleFonts.outfit(
                                                fontSize: 12,
                                                color: ClickFixTheme.primaryAmber,
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const TextSpan(text: '.'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Submit Button (Next)
                          InteractiveButton(
                            isLoading: _isLoading,
                            onPressed: _handleRegister,
                            child: Text(
                              'Next: Complete Setup',
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
