import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/models/service_model.dart';
import 'package:clickfix/services/location_service.dart';
import 'package:clickfix/screens/booking_screen.dart';
import 'package:clickfix/screens/customer/job_details_screen.dart';
import 'package:clickfix/screens/customer/worker_services_screen.dart';

class CustomerIndexScreen extends StatefulWidget {
  const CustomerIndexScreen({super.key});

  @override
  State<CustomerIndexScreen> createState() => _CustomerIndexScreenState();
}

class _CustomerIndexScreenState extends State<CustomerIndexScreen> {
  String _selectedCity = 'Faisalabad';
  List<String> _cities = ['Faisalabad', 'Karachi', 'Lahore', 'Islamabad', 'Rawalpindi'];
  bool _isLoadingCities = true;
  
  final PageController _sliderController = PageController(viewportFraction: 0.88);
  int _activeSliderIndex = 0;
  Timer? _sliderTimer;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _filteredCities = [];
  bool _showCitySuggestions = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCities();
    
    // Auto-scroll services slider every 4 seconds
    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && _sliderController.hasClients) {
        int nextIndex = _activeSliderIndex + 1;
        if (nextIndex >= ServiceModel.services.length) {
          nextIndex = 0;
        }
        _sliderController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    _searchController.addListener(() {
      final text = _searchController.text.trim();
      if (text.isNotEmpty) {
        setState(() {
          _filteredCities = _cities
              .where((city) => city.toLowerCase().contains(text.toLowerCase()))
              .toList();
        });
      } else {
        setState(() {
          _filteredCities = [];
        });
      }
    });
  }

  Future<void> _loadCities() async {
    final list = await LocationService.fetchCities();
    if (mounted) {
      setState(() {
        _cities = list;
        // Make sure Faisalabad or the first fetched city is selected default
        if (!_cities.contains(_selectedCity) && _cities.isNotEmpty) {
          _selectedCity = _cities.first;
        }
        _isLoadingCities = false;
      });
    }
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _sliderController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showCityPickerDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final text = _searchController.text.trim();
            final modalCities = text.isEmpty
                ? _cities
                : _cities.where((c) => c.toLowerCase().contains(text.toLowerCase())).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: isDark ? ClickFixTheme.primaryDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Your City',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search city (e.g. Lahore, Karachi...)',
                        prefixIcon: const Icon(Icons.search_rounded),
                        fillColor: isDark ? const Color(0xFF2C3034) : ClickFixTheme.primaryLight,
                      ),
                      onChanged: (val) {
                        setModalState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _isLoadingCities
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: modalCities.length,
                            itemBuilder: (context, index) {
                              final city = modalCities[index];
                              final isSelected = city == _selectedCity;
                              return ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                tileColor: isSelected
                                    ? ClickFixTheme.primaryAmber.withOpacity(0.1)
                                    : Colors.transparent,
                                leading: Icon(
                                  Icons.location_on_rounded,
                                  color: isSelected
                                      ? ClickFixTheme.primaryAmber
                                      : (isDark ? Colors.white38 : Colors.black38),
                                ),
                                title: Text(
                                  city,
                                  style: GoogleFonts.outfit(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? ClickFixTheme.primaryAmber
                                        : (isDark ? Colors.white : Colors.black87),
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle_rounded, color: ClickFixTheme.primaryAmber)
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedCity = city;
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final services = ServiceModel.services; // exactly 15 services

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero / Search Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [ClickFixTheme.primaryDark, const Color(0xFF1E2124)]
                      : [const Color(0xFFFFF9E6), Colors.white],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Location',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: ClickFixTheme.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          GestureDetector(
                            onTap: _showCityPickerDialog,
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_rounded, color: ClickFixTheme.primaryAmber, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  _selectedCity,
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : ClickFixTheme.textDark,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down_rounded, color: ClickFixTheme.primaryAmber),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? Colors.white10 : ClickFixTheme.borderGray),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.shopping_bag_outlined),
                          onPressed: () {
                            // Quick navigate to bookings
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Professional Services\nAt Your Fingerprints',
                    style: GoogleFonts.outfit(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      color: isDark ? Colors.white : ClickFixTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Book verified local professionals for repairs, maintenance, cleaning & renovate needs.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : ClickFixTheme.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C3034) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          focusNode: _searchFocusNode,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                              _showCitySuggestions = val.isNotEmpty;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search for plumber, electrician...',
                            prefixIcon: const Icon(Icons.search_rounded, color: ClickFixTheme.primaryAmber),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded),
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                        _showCitySuggestions = false;
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_showCitySuggestions && _searchQuery.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C3034) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.white10 : ClickFixTheme.borderGray),
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: services
                            .where((s) => s.title.toLowerCase().contains(_searchQuery.toLowerCase()))
                            .map((service) => ListTile(
                                  leading: Icon(service.iconData, color: ClickFixTheme.primaryAmber),
                                  title: Text(service.title),
                                  subtitle: Text('Category: ${service.category}'),
                                  onTap: () {
                                    setState(() {
                                      _showCitySuggestions = false;
                                      _searchQuery = '';
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => JobDetailsScreen(service: service),
                                      ),
                                    );
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),

            // Slider Section for 15 Services
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 12, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Premium Home Services',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '15 Services',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: ClickFixTheme.primaryAmber,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Swipe to discover our specialized solutions',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: ClickFixTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Beautiful 15 services carousel
            SizedBox(
              height: 240,
              child: PageView.builder(
                controller: _sliderController,
                itemCount: services.length,
                onPageChanged: (index) {
                  setState(() {
                    _activeSliderIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final service = services[index];
                  final isSelected = index == _activeSliderIndex;
                  return AnimatedScale(
                    scale: isSelected ? 1.0 : 0.95,
                    duration: const Duration(milliseconds: 300),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobDetailsScreen(service: service),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF2C3034), const Color(0xFF1E2124)]
                                : [Colors.white, const Color(0xFFFDFDFD)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ClickFixTheme.primaryAmber.withOpacity(isSelected ? (isDark ? 0.08 : 0.12) : 0),
                              blurRadius: 16,
                              spreadRadius: 2,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: isSelected
                                ? ClickFixTheme.primaryAmber.withOpacity(0.6)
                                : (isDark ? Colors.white10 : ClickFixTheme.borderGray.withOpacity(0.6)),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            children: [
                              // Glassmorphic accent circles
                              Positioned(
                                right: -40,
                                top: -40,
                                child: CircleAvatar(
                                  radius: 80,
                                  backgroundColor: ClickFixTheme.primaryAmber.withOpacity(0.04),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: ClickFixTheme.primaryAmber.withOpacity(0.18),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Icon(
                                            service.iconData,
                                            color: ClickFixTheme.primaryAmber,
                                            size: 30,
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.star_rounded, color: ClickFixTheme.primaryAmber, size: 18),
                                                const SizedBox(width: 4),
                                                Text(
                                                  service.rating,
                                                  style: GoogleFonts.outfit(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                '${service.activeWorkers} Experts',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 10,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service.category.toUpperCase(),
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: ClickFixTheme.primaryAmber,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          service.title,
                                          style: GoogleFonts.outfit(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          service.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            color: isDark ? Colors.white60 : ClickFixTheme.textMuted,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Rs. ${service.basePrice.toStringAsFixed(0)} (Base Price)',
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: ClickFixTheme.primaryAmber,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Book Now',
                                              style: GoogleFonts.outfit(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white70 : ClickFixTheme.textDark,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.arrow_forward_rounded, size: 16),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Indicator Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                services.length,
                (index) => Container(
                  width: _activeSliderIndex == index ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _activeSliderIndex == index
                        ? ClickFixTheme.primaryAmber
                        : (isDark ? Colors.white24 : Colors.black12),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Value Grid (Category shortcuts)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Explore Service Categories',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildCategoryItem(context, 'Maintenance', Icons.handyman_rounded, isDark),
                _buildCategoryItem(context, 'Appliances', Icons.kitchen_rounded, isDark),
                _buildCategoryItem(context, 'Cleaning', Icons.cleaning_services_rounded, isDark),
                _buildCategoryItem(context, 'Renovation', Icons.format_paint_rounded, isDark),
                _buildCategoryItem(context, 'Security', Icons.videocam_rounded, isDark),
                _buildCategoryItem(context, 'Vehicle', Icons.directions_car_rounded, isDark),
                _buildCategoryItem(context, 'Energy', Icons.solar_power_rounded, isDark),
                _buildCategoryItem(context, 'Tech Support', Icons.computer_rounded, isDark),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String title, IconData icon, bool isDark) {
    return InkWell(
      onTap: () {
        // Find first service of this category and show list
        final categoryServices = ServiceModel.services.where((s) => s.category == title).toList();
        if (categoryServices.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkerServicesScreen(serviceCategory: title),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C3034) : ClickFixTheme.primaryLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white10 : ClickFixTheme.borderGray.withOpacity(0.5)),
            ),
            child: Icon(
              icon,
              color: ClickFixTheme.primaryAmber,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
