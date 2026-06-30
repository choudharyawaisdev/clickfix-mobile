import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/models/service_model.dart';
import 'package:clickfix/services/location_service.dart';
import 'package:clickfix/services/api_service.dart';
import 'package:clickfix/screens/customer/job_details_screen.dart';
import 'package:clickfix/screens/customer/job_profile_details_screen.dart';
import 'package:clickfix/screens/booking_screen.dart';
import 'package:clickfix/widgets/clickfix_logo.dart';
import 'package:clickfix/screens/customer/worker_services_screen.dart';
import 'package:clickfix/services/auth_service.dart';

class CustomerIndexScreen extends StatefulWidget {
  const CustomerIndexScreen({super.key});

  @override
  State<CustomerIndexScreen> createState() => _CustomerIndexScreenState();
}

class _CustomerIndexScreenState extends State<CustomerIndexScreen> {
  String _selectedCity = 'Faisalabad';
  List<String> _cities = ['Faisalabad', 'Karachi', 'Lahore', 'Islamabad', 'Rawalpindi'];
  bool _isLoadingCities = true;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _filteredCities = [];
  bool _showCitySuggestions = false;
  String _searchQuery = '';

  // Currently selected service (All Services by default)
  final ServiceModel _allServicesOption = const ServiceModel(
    id: 'all',
    title: 'All Services',
    category: 'All',
    iconData: Icons.all_inclusive_rounded,
    description: 'Display all available worker jobs.',
    basePrice: 0,
  );

  late ServiceModel _selectedService;

  // Active Job Posts Carousel variables
  List<dynamic> _apiJobs = [];
  Map<String, List<dynamic>> _groupedJobs = {};
  List<int> _wishlistedWorkerIds = [];
  bool _isLoadingJobs = true;
  final PageController _jobsSliderController = PageController(viewportFraction: 0.88);
  int _activeJobIndex = 0;
  bool _isServicesExpanded = false;

  List<ServiceModel> _apiServices = [];
  bool _isLoadingServices = true;

  Timer? _carouselTimer;

  void _startAutoPlay() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_apiJobs.isNotEmpty) {
        int nextPage = _activeJobIndex + 1;
        if (nextPage >= _apiJobs.length) {
          nextPage = 0;
        }
        if (_jobsSliderController.hasClients) {
          _jobsSliderController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  ServiceModel _getServiceModel(dynamic serviceData) {
    if (serviceData == null) return ServiceModel.services.first;
    final String serviceId = (serviceData['id'] ?? '').toString();
    return ServiceModel.services.firstWhere(
      (element) => element.id == serviceId,
      orElse: () => ServiceModel(
        id: serviceId,
        title: serviceData['title'] ?? serviceData['name'] ?? 'Service',
        category: serviceData['category'] ?? 'Maintenance',
        description: serviceData['description'] ?? '',
        basePrice: double.tryParse((serviceData['base_price'] ?? serviceData['basePrice'] ?? '0').toString()) ?? 0,
        iconData: Icons.engineering_rounded,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedCity = LocationService.selectedCity.isNotEmpty ? LocationService.selectedCity : 'All Cities';
    LocationService.selectedCity = _selectedCity;
    _selectedService = _allServicesOption;
    _loadCities();
    _loadServices();
    _loadWishlist();

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

  Future<void> _loadWishlist() async {
    try {
      final response = await ApiService().getWishlist();
      if (response['status'] == true && response.containsKey('data')) {
        final List<dynamic> list = response['data'] as List? ?? [];
        if (mounted) {
          setState(() {
            _wishlistedWorkerIds = list
                .map((w) => w['id'] as int? ?? 0)
                .where((id) => id != 0)
                .toList();
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoadingServices = true;
    });
    try {
      final response = await ApiService().getServices();
      if (response['status'] == true && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          final List<ServiceModel> loaded = data
              .map((item) => ServiceModel.fromJson(item as Map<String, dynamic>))
              .toList();
          
          if (mounted) {
            setState(() {
              _apiServices = [_allServicesOption, ...loaded];
              _selectedService = _allServicesOption;
              _isLoadingServices = false;
            });
            _loadApiJobs();
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading dynamic services: $e');
    }
    
    // Fallback to static list if API fails
    if (mounted) {
      setState(() {
        _apiServices = [_allServicesOption, ...ServiceModel.services];
        _selectedService = _allServicesOption;
        _isLoadingServices = false;
      });
      _loadApiJobs();
    }
  }

  Future<void> _loadCities() async {
    final list = await LocationService.fetchCities();
    if (mounted) {
      setState(() {
        _cities = ['All Cities', ...list];
        _isLoadingCities = false;
      });
    }
  }

  Future<void> _loadApiJobs() async {
    setState(() {
      _isLoadingJobs = true;
    });

    try {
      // Fetch all jobs to support multiple carousels and filter by city
      final response = await ApiService().getJobs(
        category: null,
        city: _selectedCity == 'All Cities' ? null : _selectedCity,
      );
      if (response['status'] == true && response.containsKey('data')) {
        final data = response['data'];
        List<dynamic> parsedJobs = [];
        if (data is List) {
          parsedJobs = data;
        } else if (data is Map && data.containsKey('data')) {
          final innerData = data['data'];
          if (innerData is List) {
            parsedJobs = innerData;
          }
        }

        parsedJobs.shuffle(); // Shuffle jobs randomly so different services/workers appear first each load

        // Group jobs by category dynamically based on their service category
        final Map<String, List<dynamic>> grouped = {};
        for (var job in parsedJobs) {
          // Client-side filtering by selected city
          final String jobCity = job['location'] ?? (job['user'] != null ? job['user']['city'] : 'Faisalabad');
          if (_selectedCity != 'All Cities' && jobCity.trim().toLowerCase() != _selectedCity.trim().toLowerCase()) {
            continue;
          }

          final serviceData = job['service'];
          final String cat = serviceData != null
              ? (serviceData['title'] ?? serviceData['name'] ?? 'General').toString()
              : 'General';
          if (!grouped.containsKey(cat)) {
            grouped[cat] = [];
          }
          grouped[cat]!.add(job);
        }

        if (mounted) {
          setState(() {
            _apiJobs = parsedJobs;
            _groupedJobs = grouped;
            _isLoadingJobs = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _apiJobs = [];
            _groupedJobs = {};
            _isLoadingJobs = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _apiJobs = [];
          _groupedJobs = {};
          _isLoadingJobs = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _jobsSliderController.dispose();
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
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final modalCities = query.trim().isEmpty
                ? _cities
                : _cities.where((c) => c.toLowerCase().contains(query.trim().toLowerCase())).toList();

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
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Search city (e.g. Lahore, Karachi...)',
                        prefixIcon: const Icon(Icons.search_rounded),
                        fillColor: isDark ? const Color(0xFF2C3034) : ClickFixTheme.primaryLight,
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          query = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _isLoadingCities
                        ? const Center(child: CircularProgressIndicator())
                        : () {
                            final baseTextStyle = GoogleFonts.outfit(
                              color: isDark ? Colors.white : Colors.black87,
                            );
                            return ListView.builder(
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
                                    style: baseTextStyle.copyWith(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? ClickFixTheme.primaryAmber : null,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(Icons.check_circle_rounded, color: ClickFixTheme.primaryAmber)
                                      : null,
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _selectedCity = city;
                                      LocationService.selectedCity = city;
                                    });
                                    _loadApiJobs();
                                  },
                                );
                              },
                            );
                          }(),
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
    final allServices = _apiServices.isNotEmpty ? _apiServices : ServiceModel.services;

    return Scaffold(
      body: SafeArea(
        // [SCREEN LAYOUT SETTINGS] 
        // SafeArea ensures content does not overlap with status bar and notch.
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero / Location Search Section
              Container(
                // [PADDINGS & MARGINS CONFIGURATION]
                // - Left & Right (20px): Sets the primary horizontal screen margin.
                // - Top (16px): Sets the spacing from the status bar area.
                // - Bottom (24px): Spacing before categories grid.
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                                      fontSize: 15,
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
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Reliable Home Services',
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        color: isDark ? Colors.white : ClickFixTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                          children: allServices
                              .where((s) => s.title.toLowerCase().contains(_searchQuery.toLowerCase()))
                              .map((service) {
                                final activeJobs = _groupedJobs[service.title] ?? [];
                                return ListTile(
                                  leading: Icon(service.iconData, color: ClickFixTheme.primaryAmber),
                                  title: Text(service.title),
                                  subtitle: Text(
                                    activeJobs.isNotEmpty
                                        ? '${activeJobs.length} active provider(s) in $_selectedCity'
                                        : 'No active providers in $_selectedCity',
                                    style: TextStyle(
                                      color: activeJobs.isNotEmpty ? Colors.green : Colors.orange,
                                      fontSize: 12,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _showCitySuggestions = false;
                                      _searchQuery = '';
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WorkerServicesScreen(
                                          serviceCategory: service.title,
                                          selectedCity: _selectedCity,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              })
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),

              // 2. Explore Services - 15 Grid Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Explore Services',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${allServices.length} Services',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: ClickFixTheme.primaryAmber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Select a service to display active worker listings below.',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: ClickFixTheme.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Grid displaying dynamically fetched services
              _isLoadingServices
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.15,
                      ),
                      itemCount: _isServicesExpanded
                          ? allServices.length
                          : (allServices.length > 6 ? 6 : allServices.length),
                      itemBuilder: (context, index) {
                        final service = allServices[index];
                        final isSelected = service.id == _selectedService.id;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedService = service;
                            });
                            _loadApiJobs();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ClickFixTheme.primaryAmber.withOpacity(0.15)
                                  : (isDark ? const Color(0xFF2C3034) : ClickFixTheme.primaryLight),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? ClickFixTheme.primaryAmber
                                    : (isDark ? Colors.white10 : ClickFixTheme.borderGray.withOpacity(0.5)),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  service.iconData,
                                  color: isSelected ? ClickFixTheme.primaryAmber : ClickFixTheme.textMuted,
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  service.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected
                                        ? (isDark ? Colors.white : ClickFixTheme.textDark)
                                        : (isDark ? Colors.white70 : ClickFixTheme.textDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isServicesExpanded = !_isServicesExpanded;
                    });
                  },
                  icon: Icon(
                    _isServicesExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: ClickFixTheme.primaryAmber,
                  ),
                  label: Text(
                    _isServicesExpanded ? 'Show Less' : 'Load More',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: ClickFixTheme.primaryAmber,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: ClickFixTheme.primaryAmber.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              _isLoadingJobs
                  ? const SizedBox(
                      height: 220,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
                        ),
                      ),
                    )
                  : _selectedService.id == 'all'
                      ? _buildGroupedCarousels(isDark)
                      : _buildSingleCategoryCarousel(_selectedService.title, isDark),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Displays consecutive horizontal lists for each category that has active listings
  Widget _buildGroupedCarousels(bool isDark) {
    final categories = _groupedJobs.keys.where((cat) => _groupedJobs[cat]!.isNotEmpty).toList();
    categories.shuffle(); // Shuffle the categories randomly
    
    if (categories.isEmpty) {
      return _buildEmptyJobsState(isDark);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final categoryTitle = categories[index];
        final jobs = _groupedJobs[categoryTitle] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Expert ',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : ClickFixTheme.textDark,
                            ),
                            children: [
                              TextSpan(
                                text: categoryTitle,
                                style: GoogleFonts.outfit(
                                  color: ClickFixTheme.primaryAmber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Professionals Worker in $categoryTitle',
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            color: ClickFixTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkerServicesScreen(
                            serviceCategory: categoryTitle,
                            selectedCity: _selectedCity,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side: const BorderSide(color: ClickFixTheme.primaryAmber, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      'View All',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: ClickFixTheme.primaryAmber,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(
              height: 285,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: jobs.length,
                itemBuilder: (context, jobIndex) {
                  final job = jobs[jobIndex];
                  return _buildServiceJobCard(job, isDark, context);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  /// Displays horizontal scroll carousel of jobs for a single chosen category
  Widget _buildSingleCategoryCarousel(String categoryTitle, bool isDark) {
    final jobs = _groupedJobs[categoryTitle] ?? [];
    if (jobs.isEmpty) {
      return _buildEmptyJobsState(isDark);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Expert ',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : ClickFixTheme.textDark,
                        ),
                        children: [
                          TextSpan(
                            text: categoryTitle,
                            style: GoogleFonts.outfit(
                              color: ClickFixTheme.primaryAmber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Professionals Worker in $categoryTitle',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        color: ClickFixTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 285,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: jobs.length,
            itemBuilder: (context, jobIndex) {
              final job = jobs[jobIndex];
              return _buildServiceJobCard(job, isDark, context);
            },
          ),
        ),
      ],
    );
  }

  /// Custom Service Card layout matching image specifications
  Widget _buildServiceJobCard(dynamic job, bool isDark, BuildContext context) {
    final int jobId = job['id'] as int? ?? 0;
    final String title = job['title'] ?? 'Job Service';
    final String price = job['price']?.toString() ?? '0';
    final String location = job['location'] ?? (job['user'] != null ? job['user']['city'] : 'Faisalabad');
    final String desc = job['description'] ?? 'Expert service provider.';
    
    final workerUser = job['user'];
    final int workerId = workerUser != null ? (workerUser['id'] as int? ?? 0) : 0;
    final String workerName = workerUser != null ? (workerUser['name'] ?? 'Pro Provider') : 'Pro Provider';
    
    final service = _getServiceModel(job['service']);
    final bool isWishlisted = _wishlistedWorkerIds.contains(workerId);

    // Format price
    String formattedPrice = price;
    try {
      final doubleVal = double.tryParse(price);
      if (doubleVal != null) {
        formattedPrice = doubleVal.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
      }
    } catch (_) {}

    final double cardWidth = (MediaQuery.of(context).size.width - 44) / 2;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C3034) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : ClickFixTheme.borderGray.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobProfileDetailsScreen(jobId: jobId),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Image Area
              Container(
                height: 90,
                width: double.infinity,
                color: isDark ? const Color(0xFF34383C) : Colors.grey.shade200,
                child: Stack(
                  children: [
                    // Cover placeholder text
                    Center(
                      child: Text(
                        'Service',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    
                    // Price Tag top-left
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Rs. $formattedPrice',
                          style: GoogleFonts.outfit(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: ClickFixTheme.primaryDark,
                          ),
                        ),
                      ),
                    ),
                    
                    // Wishlist button top-right
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () async {
                          if (workerId != 0) {
                            final res = await ApiService().toggleWishlist(workerId);
                            if (res['status'] == true) {
                              setState(() {
                                if (isWishlisted) {
                                  _wishlistedWorkerIds.remove(workerId);
                                } else {
                                  _wishlistedWorkerIds.add(workerId);
                                }
                              });
                              
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res['message'] ?? 'Wishlist updated'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isWishlisted ? Colors.red : Colors.black45,
                            size: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : ClickFixTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white60 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 8),
                    
                    // Worker Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: ClickFixTheme.primaryAmber,
                          child: Text(
                            workerName.isNotEmpty ? workerName[0].toUpperCase() : 'W',
                            style: GoogleFonts.outfit(
                              color: Colors.white, 
                              fontSize: 8, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            workerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : ClickFixTheme.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // View Button
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobProfileDetailsScreen(jobId: jobId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ClickFixTheme.primaryAmber,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          'View Service',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget displayed when there are no jobs returned from the live API
  Widget _buildEmptyJobsState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C3034) : ClickFixTheme.primaryLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : ClickFixTheme.borderGray.withOpacity(0.5),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.assignment_late_outlined,
                color: isDark ? Colors.white38 : ClickFixTheme.textMuted.withOpacity(0.5),
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                'No jobs available',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : ClickFixTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Check back later for new worker job listings.',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: ClickFixTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
