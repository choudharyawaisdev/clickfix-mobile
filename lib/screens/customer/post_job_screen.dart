import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/models/service_model.dart';
import 'package:clickfix/services/api_service.dart';
import 'package:clickfix/services/auth_service.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _locationController = TextEditingController();
  
  String? _selectedCategory;
  bool _isSubmitting = false;

  final List<String> _categories = ServiceModel.services.map((s) => s.title).toList();

  String? _selectedCity;
  String? _selectedArea;

  final Map<String, List<String>> _cityAreas = {
    'Faisalabad': [
      'Peoples Colony No. 1',
      'Peoples Colony No. 2',
      'Ghulam Muhammad Abad',
      'D Ground',
      'Kohinoor City',
      'Madina Town',
      'Canal Road',
      'Sargodha Road',
      'Samanabad',
      'Civil Lines',
    ],
    'Karachi': [
      'Clifton',
      'DHA',
      'Gulshan-e-Iqbal',
      'North Nazimabad',
      'Saddar',
      'Bahadurabad',
      'Federal B Area',
      'PECHS',
      'Korangi',
      'Malir',
    ],
    'Lahore': [
      'Gulberg',
      'DHA',
      'Model Town',
      'Johar Town',
      'Iqbal Town',
      'Samanabad',
      'Walled City',
      'Cantt',
      'Bahria Town',
      'Faisal Town',
    ],
    'Islamabad': [
      'Blue Area',
      'F-6',
      'F-7',
      'F-8',
      'G-9',
      'G-11',
      'I-8',
      'E-7',
      'Bahria Town',
      'DHA',
    ],
    'Rawalpindi': [
      'Saddar',
      'Satellite Town',
      'Bahria Town',
      'Chaklala Scheme',
      'Commercial Market',
      'Peshawar Road',
      'Adiala Road',
      'Westridge',
      'Tench Bhata',
    ],
  };

  void _updateLocationText() {
    if (_selectedArea != null && _selectedCity != null) {
      _locationController.text = '$_selectedArea, $_selectedCity';
    }
  }

  @override
  void initState() {
    super.initState();
    final city = AuthService().currentUser?.city;
    if (city != null && _cityAreas.containsKey(city)) {
      _selectedCity = city;
    } else {
      _selectedCity = 'Faisalabad';
    }
    _selectedArea = _cityAreas[_selectedCity]!.first;
    _updateLocationText();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a service category'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final budget = double.tryParse(_budgetController.text.trim()) ?? 0.0;

    final response = await ApiService().postCustomerJob(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      budget: budget,
      category: _selectedCategory!,
      location: _locationController.text.trim(),
    );

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(response['message'] ?? 'Job posted successfully!'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to trigger refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to post job. Please try again.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post a New Job',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form header card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [ClickFixTheme.primaryAmber.withOpacity(0.05), Colors.transparent]
                            : [ClickFixTheme.primaryAmber.withOpacity(0.12), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ClickFixTheme.primaryAmber.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: ClickFixTheme.primaryAmber.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.campaign_rounded,
                            color: ClickFixTheme.primaryAmber,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Describe your needs',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : ClickFixTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Get competitive bids from qualified local service pros.',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: ClickFixTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Job Title
                  Text(
                    'Job Title',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ClickFixTheme.primaryAmber,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Need AC Service and Installation',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a job title';
                      }
                      if (value.trim().length < 5) {
                        return 'Title must be at least 5 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Category Dropdown
                  Text(
                    'Service Category',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ClickFixTheme.primaryAmber,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    hint: Text(
                      'Select Category',
                      style: GoogleFonts.outfit(color: isDark ? Colors.white54 : ClickFixTheme.textMuted, fontSize: 14),
                    ),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.category_rounded),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    dropdownColor: isDark ? ClickFixTheme.primaryDark : Colors.white,
                    style: GoogleFonts.outfit(color: isDark ? Colors.white : ClickFixTheme.textDark, fontSize: 15),
                    items: _categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Budget & Location side-by-side
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Budget
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Budget (Rs.)',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: ClickFixTheme.primaryAmber,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _budgetController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Budget (PKR)',
                                prefixIcon: Icon(Icons.payments_rounded),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter budget';
                                }
                                final numValue = double.tryParse(value);
                                if (numValue == null || numValue <= 0) {
                                  return 'Invalid budget';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // City selection
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'City',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: ClickFixTheme.primaryAmber,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _selectedCity,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.location_city_rounded),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              ),
                              dropdownColor: isDark ? ClickFixTheme.primaryDark : Colors.white,
                              style: GoogleFonts.outfit(color: isDark ? Colors.white : ClickFixTheme.textDark, fontSize: 14),
                              items: _cityAreas.keys.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedCity = newValue;
                                  _selectedArea = _cityAreas[newValue]!.first;
                                  _updateLocationText();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Famous Area dropdown
                  Text(
                    'Famous Area',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ClickFixTheme.primaryAmber,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedArea,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_on_rounded),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    dropdownColor: isDark ? ClickFixTheme.primaryDark : Colors.white,
                    style: GoogleFonts.outfit(color: isDark ? Colors.white : ClickFixTheme.textDark, fontSize: 14),
                    items: (_selectedCity != null ? _cityAreas[_selectedCity]! : <String>[]).map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedArea = newValue;
                        _updateLocationText();
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'Detailed Description',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ClickFixTheme.primaryAmber,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: 'Enter all details, required parts, timing preferences, etc.',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 80.0),
                        child: Icon(Icons.description_rounded),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please provide a detailed description';
                      }
                      if (value.trim().length < 15) {
                        return 'Description must be at least 15 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 36),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitJob,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryDark),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.post_add_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Post Job Now',
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
        ),
      ),
    );
  }
}
