import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/services/api_service.dart';
import 'package:clickfix/services/auth_service.dart';
import 'package:clickfix/services/location_service.dart';

class WorkerJobworkerCreateScreen extends StatefulWidget {
  const WorkerJobworkerCreateScreen({super.key});

  @override
  State<WorkerJobworkerCreateScreen> createState() => _WorkerJobworkerCreateScreenState();
}

class _WorkerJobworkerCreateScreenState extends State<WorkerJobworkerCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  List<dynamic> _apiServices = [];
  bool _isLoadingServices = true;
  int? _selectedServiceId;
  bool _isSubmitting = false;

  File? _imageFile;
  List<String> _citiesList = [];
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _loadServices();

    final user = AuthService().currentUser;
    final userCity = user?.city ?? 'Faisalabad';
    _citiesList = List<String>.from(LocationService.fallbackCities);
    if (!_citiesList.contains(userCity)) {
      _citiesList.add(userCity);
    }
    _citiesList.sort();
    _selectedCity = _citiesList.contains(userCity) ? userCity : _citiesList.first;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? ClickFixTheme.primaryDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Listing Image',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceTile(Icons.photo_library_rounded, 'Gallery', () async {
                    Navigator.pop(context);
                    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                    if (picked != null) {
                      setState(() {
                        _imageFile = File(picked.path);
                      });
                    }
                  }),
                  _buildSourceTile(Icons.camera_alt_rounded, 'Camera', () async {
                    Navigator.pop(context);
                    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                    if (picked != null) {
                      setState(() {
                        _imageFile = File(picked.path);
                      });
                    }
                  }),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSourceTile(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: ClickFixTheme.primaryAmber.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: ClickFixTheme.primaryAmber, size: 32),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _loadServices() async {
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
            _isLoadingServices = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading services: $e');
    }
    setState(() {
      _isLoadingServices = false;
    });
  }
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Define job details, price, and descriptions to attract bookings.',
                  style: GoogleFonts.outfit(color: ClickFixTheme.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 24),

                Text(
                  'Service Title',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(hintText: 'e.g. UPS Board Replacement & Servicing'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter service title';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Text(
                  'Service',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
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
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        items: _apiServices.map((service) {
                          final name = service['name'] ?? service['title'] ?? 'Service';
                          return DropdownMenuItem<int>(
                            value: service['id'] as int?,
                            child: Text(name.toString()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedServiceId = val;
                          });
                        },
                        validator: (val) {
                          if (val == null) return 'Please select service';
                          return null;
                        },
                      ),
                const SizedBox(height: 20),

                Text(
                  'Base Price (Rs.)',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'e.g. 1200'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter price';
                    if (double.tryParse(value) == null) return 'Please enter valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Text(
                  'Detailed Description',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'Describe exactly what is included in this price (e.g. diagnostic, testing, parts extra)'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter description';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Text(
                  'Job Location (City)',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  items: _citiesList.map((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCity = val;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please select location city';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Text(
                  'Service Listing Image (Optional)',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C3034) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ClickFixTheme.primaryAmber.withOpacity(0.3),
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 48,
                                color: ClickFixTheme.primaryAmber,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to upload an image for this service',
                                style: GoogleFonts.outfit(
                                  color: ClickFixTheme.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isSubmitting = true;
                              });

                              try {
                                final double price = double.tryParse(_priceController.text) ?? 0.0;
                                final location = _selectedCity ?? 'Faisalabad';

                                final response = await ApiService().storeJob(
                                  title: _titleController.text,
                                  serviceId: _selectedServiceId!,
                                  price: price,
                                  location: location,
                                  description: _descController.text,
                                  imagePath: _imageFile?.path,
                                );

                                if (mounted) {
                                  setState(() {
                                    _isSubmitting = false;
                                  });

                                  if (response['status'] == true) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Job posted successfully!'),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(response['message'] ?? 'Failed to post job.'),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (mounted) {
                                  setState(() {
                                    _isSubmitting = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('An error occurred: $e'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                    child: _isSubmitting
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text(
                            'Post Job',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
