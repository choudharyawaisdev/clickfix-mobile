import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/models/service_model.dart';
import 'package:clickfix/services/location_service.dart';

// Simple in-memory session manager for booked services
class BookingSession {
  static final List<Map<String, dynamic>> activeBookings = [
    {
      'id': 'BK-9821',
      'service': 'AC Repair',
      'icon': Icons.ac_unit_rounded,
      'date': '2026-06-21',
      'time': '10:00 AM - 12:00 PM',
      'address': 'D-Ground, Peoples Colony No. 1, Faisalabad',
      'status': 'Assigned',
      'price': 1500.0,
      'expert': 'Sajid Mehmood',
    },
    {
      'id': 'BK-7729',
      'service': 'Plumbing',
      'icon': Icons.plumbing_rounded,
      'date': '2026-06-18',
      'time': '02:00 PM - 04:00 PM',
      'address': 'Samanabad, Faisalabad',
      'status': 'Completed',
      'price': 600.0,
      'expert': 'Muhammad Rafiq',
    }
  ];
}

class BookingScreen extends StatefulWidget {
  final ServiceModel? initialService;

  const BookingScreen({super.key, this.initialService});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  ServiceModel? _selectedService;
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTimeSlot = '10:00 AM - 12:00 PM';
  String _selectedCity = 'Faisalabad';

  final List<String> _timeSlots = [
    '09:00 AM - 11:00 AM',
    '10:00 AM - 12:00 PM',
    '12:00 PM - 02:00 PM',
    '02:00 PM - 04:00 PM',
    '04:00 PM - 06:00 PM',
    '06:00 PM - 08:00 PM',
  ];

  List<String> _allCities = [];
  List<String> _filteredCities = [];
  bool _isLoadingCities = true;
  bool _showCityDropdown = false;
  final TextEditingController _citySearchController = TextEditingController(text: 'Faisalabad');

  List<String> _colonies = [];
  List<String> _filteredColonies = [];
  bool _isLoadingColonies = false;
  bool _showColonyDropdown = false;
  final TextEditingController _colonySearchController = TextEditingController();
  String _selectedColony = '';

  @override
  void initState() {
    super.initState();
    _selectedService = widget.initialService;
    _loadCities();
    _loadColonies('Faisalabad');
    
    _citySearchController.addListener(_onCitySearchChanged);
    _colonySearchController.addListener(_onColonySearchChanged);
  }

  void _onCitySearchChanged() {
    final query = _citySearchController.text.trim();
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

  void _onColonySearchChanged() {
    final query = _colonySearchController.text.trim();
    if (query.isNotEmpty && query != _selectedColony) {
      setState(() {
        _filteredColonies = _colonies
            .where((col) => col.toLowerCase().contains(query.toLowerCase()))
            .toList();
        _showColonyDropdown = true;
      });
    } else if (query.isEmpty) {
      setState(() {
        _filteredColonies = [];
        _showColonyDropdown = false;
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

  Future<void> _loadColonies(String city) async {
    setState(() {
      _isLoadingColonies = true;
      _selectedColony = '';
      _colonySearchController.clear();
    });
    final list = await LocationService.fetchColoniesForCity(city);
    if (mounted) {
      setState(() {
        _colonies = list;
        _isLoadingColonies = false;
      });
    }
  }

  @override
  void dispose() {
    _citySearchController.removeListener(_onCitySearchChanged);
    _colonySearchController.removeListener(_onColonySearchChanged);
    _citySearchController.dispose();
    _colonySearchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ClickFixTheme.primaryAmber,
              onPrimary: ClickFixTheme.primaryDark,
              onSurface: ClickFixTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitBooking() {
    if (_formKey.currentState!.validate()) {
      final newBooking = {
        'id': 'BK-${(1000 + (BookingSession.activeBookings.length * 12)).toString()}',
        'service': _selectedService!.title,
        'icon': _selectedService!.iconData,
        'date': '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
        'time': _selectedTimeSlot,
        'address': '${_addressController.text.trim()}, ${_colonySearchController.text.trim()}, $_selectedCity',
        'status': 'Requested',
        'price': _selectedService!.basePrice,
        'expert': 'Finding best match...',
      };

      setState(() {
        BookingSession.activeBookings.insert(0, newBooking);
        _selectedService = null; // Clear the scheduling form and return to dashboard
      });

      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 54,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Booking Confirmed!',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your service request has been received. Our expert will contact you shortly.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: ClickFixTheme.textMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('View My Bookings'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Mode 1: Scheduling form for a selected service
    if (_selectedService != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Book ${_selectedService!.title}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              setState(() {
                _selectedService = null;
              });
            },
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Brief Card
                  Card(
                    color: isDark ? const Color(0xFF2C3034) : ClickFixTheme.primaryLight,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ClickFixTheme.primaryAmber.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _selectedService!.iconData,
                              color: ClickFixTheme.primaryAmber,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedService!.title,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Base Rate: Rs. ${_selectedService!.basePrice.toStringAsFixed(0)}',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    color: ClickFixTheme.primaryAmber,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Text(
                    'Contact Information',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your full name',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Enter your mobile number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  Text(
                    'Location Details',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  // City Selector
                  Text(
                    'City',
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                  ),
                  const SizedBox(height: 6),
                  _isLoadingCities
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _citySearchController,
                              style: GoogleFonts.outfit(fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'Search city (e.g. Lahore, Karachi)',
                                prefixIcon: const Icon(Icons.location_city_outlined),
                                suffixIcon: _allCities.contains(_citySearchController.text.trim())
                                    ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                                    : null,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter or select a city';
                                }
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
                                          _citySearchController.text = city;
                                          _showCityDropdown = false;
                                        });
                                        _loadColonies(city);
                                      },
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                  
                  const SizedBox(height: 16),
                  
                  // Colony Selector
                  Text(
                    'Colony / Area / Sector',
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                  ),
                  const SizedBox(height: 6),
                  _isLoadingColonies
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _colonySearchController,
                              style: GoogleFonts.outfit(fontSize: 15),
                              decoration: const InputDecoration(
                                hintText: 'Search or type colony (e.g. DHA, Gulberg, D-Ground)',
                                prefixIcon: Icon(Icons.holiday_village_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter or select your colony/area';
                                }
                                return null;
                              },
                            ),
                            if (_showColonyDropdown && _filteredColonies.isNotEmpty)
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
                                  itemCount: _filteredColonies.length,
                                  itemBuilder: (context, index) {
                                    final col = _filteredColonies[index];
                                    return ListTile(
                                      title: Text(col, style: GoogleFonts.outfit(fontSize: 14)),
                                      onTap: () {
                                        setState(() {
                                          _selectedColony = col;
                                          _colonySearchController.text = col;
                                          _showColonyDropdown = false;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),

                  const SizedBox(height: 16),
                  
                  // Street Details
                  Text(
                    'Street / House Number / Suite',
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. House #102, Street 3',
                      prefixIcon: Icon(Icons.home_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your street address/house number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Schedule Service',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Date Picker Card
                  InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C3034) : ClickFixTheme.primaryLight,
                        border: Border.all(color: isDark ? Colors.white10 : ClickFixTheme.borderGray),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, color: ClickFixTheme.primaryAmber, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const Text(
                            'Change',
                            style: TextStyle(
                              color: ClickFixTheme.primaryAmber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Time slot dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedTimeSlot,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.access_time_rounded),
                    ),
                    items: _timeSlots.map((slot) {
                      return DropdownMenuItem(
                        value: slot,
                        child: Text(slot),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedTimeSlot = val!;
                      });
                    },
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Describe the Issue (Optional)',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _problemController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'E.g., kitchen faucet is dripping continuously...',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 40.0),
                        child: Icon(Icons.edit_note_rounded),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submitBooking,
                      child: Text(
                        'Confirm Booking',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Mode 2: General bookings history dashboard
    final bookings = BookingSession.activeBookings;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'My Bookings',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track your scheduled and past home services',
            style: GoogleFonts.outfit(
              color: ClickFixTheme.textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: bookings.isEmpty
                ? _buildBookingsEmptyState()
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final bk = bookings[index];
                      final isCompleted = bk['status'] == 'Completed';
                      final isRequested = bk['status'] == 'Requested';
                      final isAssigned = bk['status'] == 'Assigned';

                      Color statusColor = Colors.orange;
                      if (isCompleted) statusColor = Colors.green;
                      if (isRequested) statusColor = Colors.blue;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top header row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        bk['icon'] as IconData,
                                        color: ClickFixTheme.primaryAmber,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        bk['service'] as String,
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      bk['status'] as String,
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: Divider(height: 1),
                              ),
                              // Details grid
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month_outlined, size: 16, color: ClickFixTheme.textMuted),
                                  const SizedBox(width: 8),
                                  Text(
                                    bk['date'] as String,
                                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.access_time_rounded, size: 16, color: ClickFixTheme.textMuted),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      bk['time'] as String,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 16, color: ClickFixTheme.textMuted),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      bk['address'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white70 : ClickFixTheme.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.person_pin_rounded, size: 16, color: ClickFixTheme.textMuted),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Expert: ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white60 : ClickFixTheme.textMuted,
                                    ),
                                  ),
                                  Text(
                                    bk['expert'] as String,
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : ClickFixTheme.textDark,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Rs. ${bk['price']}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: ClickFixTheme.primaryAmber,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 64, color: ClickFixTheme.textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No Bookings Yet',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Book high-quality services directly from the Services tab.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: ClickFixTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
