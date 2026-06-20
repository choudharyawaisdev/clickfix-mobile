import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/services/api_service.dart';

class WorkerJobworkerEditScreen extends StatefulWidget {
  const WorkerJobworkerEditScreen({super.key});

  @override
  State<WorkerJobworkerEditScreen> createState() => _WorkerJobworkerEditScreenState();
}

class _WorkerJobworkerEditScreenState extends State<WorkerJobworkerEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descController;

  List<dynamic> _apiServices = [];
  bool _isLoadingServices = true;
  int? _selectedServiceId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'AC Master Cleaning');
    _priceController = TextEditingController(text: '1500');
    _descController = TextEditingController(text: 'AC installation, gas charging, master cleaning, service inspection, compressor repairs.');
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
              final acService = _apiServices.firstWhere(
                (element) => element['name']?.toString().toLowerCase().contains('ac') == true,
                orElse: () => _apiServices.first,
              );
              _selectedServiceId = acService['id'] as int?;
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
          'Edit Service Listing',
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
                  'Update your service offerings and save changes.',
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
                            content: Text('Service details updated successfully'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'Save Changes',
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
