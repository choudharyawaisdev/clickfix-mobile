import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';

class WorkerJobworkerCreateScreen extends StatefulWidget {
  const WorkerJobworkerCreateScreen({super.key});

  @override
  State<WorkerJobworkerCreateScreen> createState() => _WorkerJobworkerCreateScreenState();
}

class _WorkerJobworkerCreateScreenState extends State<WorkerJobworkerCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'Maintenance';
  final List<String> _categories = ['Maintenance', 'Appliances', 'Cleaning', 'Renovation', 'Security', 'Energy', 'Tech Support'];
  
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
          'Register New Service',
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
                  'Define your expertise, price, and descriptions to attract customers.',
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
                  'Category',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  items: _categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategory = val!;
                    });
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
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Service registered successfully and pending approval'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'Submit Listing',
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
