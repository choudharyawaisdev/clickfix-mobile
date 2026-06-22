import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/models/service_model.dart';
import 'package:clickfix/services/location_service.dart';
import 'package:clickfix/services/api_service.dart';
import 'package:clickfix/screens/customer/job_details_screen.dart';
import 'package:clickfix/screens/booking_screen.dart';
import 'package:clickfix/widgets/clickfix_logo.dart';

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
    _selectedService = _allServicesOption;
    _loadCities();
    _loadServices();

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
        _cities = list;
        if (!_cities.contains(_selectedCity) && _cities.isNotEmpty) {
          _selectedCity = _cities.first;
        }
        _isLoadingCities = false;
      });
    }
  }

  Future<void> _loadApiJobs() async {
    setState(() {
      _isLoadingJobs = true;
    });

    try {
      final String? categoryFilter = _selectedService.id == 'all' ? null : _selectedService.title;
      final response = await ApiService().getJobs(category: categoryFilter);
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
        if (mounted) {
          setState(() {
            _apiJobs = parsedJobs;
            _isLoadingJobs = false;
            _activeJobIndex = 0;
          });
          _startAutoPlay();
        }
      } else {
        if (mounted) {
          setState(() {
            _apiJobs = [];
            _isLoadingJobs = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _apiJobs = [];
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
                        // [CLICKFIX BRANDING LOGO]
                        // Replaced the shopping cart button. Direct customer-to-pro marketplace without intermediate cart.
                        const ClickFixLogo(
                          vertical: false,
                          iconSize: 28,
                          fontSize: 14,
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
                              .map((service) => ListTile(
                                    leading: Icon(service.iconData, color: ClickFixTheme.primaryAmber),
                                    title: Text(service.title),
                                    subtitle: Text('Base Rate: Rs. ${service.basePrice.toStringAsFixed(0)}'),
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

              // 3. Worker Jobs Dynamic Slider Carousel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  '${_selectedService.title} Jobs Available',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _isLoadingJobs
                  ? const SizedBox(
                      height: 220,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
                        ),
                      ),
                    )
                  : _apiJobs.isEmpty
                      ? _buildEmptyJobsState(isDark)
                      : _buildLiveJobsCarousel(isDark),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Horizontal carousel displaying matching live jobs from API
  Widget _buildLiveJobsCarousel(bool isDark) {
    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _jobsSliderController,
        itemCount: _apiJobs.length,
        onPageChanged: (index) {
          setState(() {
            _activeJobIndex = index;
          });
          _startAutoPlay();
        },
        itemBuilder: (context, index) {
          final job = _apiJobs[index];
          final isSelected = index == _activeJobIndex;

          final String title = job['title'] ?? 'Job Post Request';
          final String price = job['price']?.toString() ?? '0';
          final String location = job['location'] ?? (job['user'] != null ? job['user']['city'] : 'Faisalabad');
          final String desc = job['description'] ?? 'No descriptions offered.';
          final String postedBy = job['user'] != null ? (job['user']['name'] ?? 'Provider') : 'Pro Provider';

          return AnimatedScale(
            scale: isSelected ? 1.0 : 0.96,
            duration: const Duration(milliseconds: 300),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Active Offer',
                            style: GoogleFonts.outfit(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          'Rs. $price',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: ClickFixTheme.primaryAmber, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : ClickFixTheme.textMuted),
                    ),
                    const SizedBox(height: 6),
                    const Divider(height: 1),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded, size: 14, color: ClickFixTheme.primaryAmber),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      location,
                                      style: const TextStyle(fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'By: $postedBy',
                                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: ClickFixTheme.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final service = _getServiceModel(job['service']);
                            final workerId = job['user'] != null ? job['user']['id'] as int? : null;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingScreen(
                                  initialService: service,
                                  workerId: workerId,
                                  workerName: postedBy,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Book Now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
                'No jobs available for ${_selectedService.title}',
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
