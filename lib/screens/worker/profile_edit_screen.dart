import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';

class WorkerProfileEditScreen extends StatefulWidget {
  const WorkerProfileEditScreen({super.key});

  @override
  State<WorkerProfileEditScreen> createState() => _WorkerProfileEditScreenState();
}

class _WorkerProfileEditScreenState extends State<WorkerProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _skillsController;
  late TextEditingController _experienceController;
  late TextEditingController _hoursController;
  late TextEditingController _areaController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Hafiz Muhammad Talha');
    _skillsController = TextEditingController(text: 'AC Repair, Fan Wiring, UPS Diagnostic');
    _experienceController = TextEditingController(text: '5 Years');
    _hoursController = TextEditingController(text: '09:00 AM - 08:00 PM');
    _areaController = TextEditingController(text: 'Faisalabad, Pakistan');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skillsController.dispose();
    _experienceController.dispose();
    _hoursController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Pro Profile',
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
                Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ClickFixTheme.primaryAmber, width: 3),
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.teal,
                          child: Text(
                            'T',
                            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: ClickFixTheme.primaryAmber, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt_rounded, size: 18, color: ClickFixTheme.primaryDark),
                        ),
                      ),
                    ],
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
                  'Skills (comma separated)',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _skillsController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter skills';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Text(
                  'Years of Experience',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _experienceController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter experience';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Text(
                  'Working Hours',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _hoursController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter working hours';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Text(
                  'Service Region Area',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _areaController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter service region area';
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Professional profile updated successfully'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
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
    );
  }
}
