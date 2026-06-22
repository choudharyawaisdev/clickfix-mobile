import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/services/api_service.dart';
import 'package:clickfix/services/auth_service.dart';
import 'package:clickfix/screens/worker/jobworker_create_screen.dart';

class WorkerJobworkerEditScreen extends StatefulWidget {
  final Map<String, dynamic>? job;
  const WorkerJobworkerEditScreen({super.key, this.job});

  @override
  State<WorkerJobworkerEditScreen> createState() => _WorkerJobworkerEditScreenState();
}

class _WorkerJobworkerEditScreenState extends State<WorkerJobworkerEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descController;

  List<dynamic> _apiServices = [];
  bool _isLoading = true;
  bool _isLoadingServices = true;
  bool _isSubmitting = false;
  int? _selectedServiceId;
  int? _jobId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _priceController = TextEditingController();
    _descController = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isLoadingServices = true;
    });

    try {
      // 1. Fetch available services
      final servicesResponse = await ApiService().getServices();
      if (servicesResponse['status'] == true && servicesResponse.containsKey('data')) {
        final data = servicesResponse['data'];
        if (data is List) {
          _apiServices = data;
        }
      }

      // 2. Fetch the job details
      Map<String, dynamic>? targetJob = widget.job;
      if (targetJob == null) {
        final myJobsResponse = await ApiService().getMyJobs();
        if (myJobsResponse['status'] == true && myJobsResponse.containsKey('data')) {
          final data = myJobsResponse['data'];
          if (data is List && data.isNotEmpty) {
            targetJob = data.first as Map<String, dynamic>;
          } else if (data is Map && data.containsKey('data')) {
            final inner = data['data'];
            if (inner is List && inner.isNotEmpty) {
              targetJob = inner.first as Map<String, dynamic>;
            }
          }
        }
      }

      if (targetJob != null) {
        _jobId = targetJob['id'] as int?;
        _titleController.text = (targetJob['title'] ?? '').toString();
        _priceController.text = (targetJob['price'] ?? '').toString();
        _descController.text = (targetJob['description'] ?? '').toString();
        _selectedServiceId = targetJob['service_id'] as int?;
      }
    } catch (e) {
      debugPrint('Error loading edit data: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isLoadingServices = false;
        if (_selectedServiceId == null && _apiServices.isNotEmpty) {
          _selectedServiceId = _apiServices.first['id'] as int?;
        }
      });
    }
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
              ),
            )
          : _jobId == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.work_off_rounded,
                          size: 64,
                          color: ClickFixTheme.textMuted.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Active Service Offerings Found',
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You haven\'t registered any services yet. Create one to start offering your rates.',
                          style: GoogleFonts.outfit(color: ClickFixTheme.textMuted, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WorkerJobworkerCreateScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_box_rounded),
                          label: const Text('Offer New Service'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
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
                              onPressed: _isSubmitting
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          _isSubmitting = true;
                                        });

                                        try {
                                          final currentUser = AuthService().currentUser;
                                          final double price = double.tryParse(_priceController.text) ?? 0.0;
                                          final location = currentUser?.city ?? 'Lahore';

                                          final response = await ApiService().updateJob(
                                            id: _jobId!,
                                            title: _titleController.text,
                                            serviceId: _selectedServiceId!,
                                            price: price,
                                            location: location,
                                            description: _descController.text,
                                          );

                                          if (mounted) {
                                            setState(() {
                                              _isSubmitting = false;
                                            });

                                            if (response['status'] == true) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Service details updated successfully'),
                                                  behavior: SnackBarBehavior.floating,
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                              Navigator.pop(context);
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(response['message'] ?? 'Failed to update service.'),
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
