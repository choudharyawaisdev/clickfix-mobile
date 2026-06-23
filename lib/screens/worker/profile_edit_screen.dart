import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/services/auth_service.dart';
import 'package:clickfix/services/location_service.dart';

class WorkerProfileEditScreen extends StatefulWidget {
  const WorkerProfileEditScreen({super.key});

  @override
  State<WorkerProfileEditScreen> createState() => _WorkerProfileEditScreenState();
}

class _WorkerProfileEditScreenState extends State<WorkerProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isSaving = false;
  File? _imageFile;

  List<String> _citiesList = [];
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _addressController = TextEditingController(text: user?.description ?? user?.address ?? '');

    final userCity = user?.city ?? 'Faisalabad';
    _citiesList = List<String>.from(LocationService.fallbackCities);
    if (!_citiesList.contains(userCity)) {
      _citiesList.add(userCity);
    }
    _citiesList.sort();
    _selectedCity = _citiesList.contains(userCity) ? userCity : _citiesList.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
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
                'Select Profile Picture',
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final success = await AuthService().updateUserProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      city: _selectedCity,
      description: _addressController.text.trim(),
      profilePicturePath: _imageFile?.path,
    );

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Professional profile updated successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile. Please try again.'),
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
    final user = AuthService().currentUser;

    final String imageUrl = user?.profilePicture != null && user!.profilePicture!.isNotEmpty
        ? (user.profilePicture!.startsWith('http')
            ? user.profilePicture!
            : 'https://clickfix.hafiztalha.com/storage/${user.profilePicture}')
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Pro Profile',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: ClickFixTheme.primaryAmber, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: user?.avatarColor ?? Colors.teal,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null) as ImageProvider?,
                              child: _imageFile == null && imageUrl.isEmpty
                                  ? Text(
                                      (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : 'U',
                                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: ClickFixTheme.primaryAmber,
                              radius: 18,
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: ClickFixTheme.primaryDark,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Full Name',
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please enter name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Email Address',
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please enter email';
                      if (!value.contains('@')) return 'Please enter valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phone Number',
                              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return 'Please enter phone';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'City',
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
                                if (value == null || value.isEmpty) return 'Please select city';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Professional Bio / Description',
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please enter description';
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      child: _isSaving
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryDark),
                            )
                          : Text(
                              'Save Professional Profile',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
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
