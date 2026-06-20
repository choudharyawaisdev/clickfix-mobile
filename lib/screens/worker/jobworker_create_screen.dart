import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/services/api_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadServices();
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
