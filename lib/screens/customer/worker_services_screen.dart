import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/models/service_model.dart';
import 'package:clickfix/screens/booking_screen.dart';
import 'package:clickfix/screens/customer/job_details_screen.dart';
import 'package:clickfix/screens/customer/job_profile_details_screen.dart';
import 'package:clickfix/services/api_service.dart';

class WorkerServicesScreen extends StatefulWidget {
  final String serviceCategory;

  const WorkerServicesScreen({
    super.key,
    required this.serviceCategory,
  });

  @override
  State<WorkerServicesScreen> createState() => _WorkerServicesScreenState();
}

class _WorkerServicesScreenState extends State<WorkerServicesScreen> {
  bool _isLoading = true;
  List<dynamic> _apiJobs = [];
  List<ServiceModel> _categoryServices = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Resolve local service models matching category
      final localServices = ServiceModel.services
          .where((s) => s.category.toLowerCase() == widget.serviceCategory.toLowerCase())
          .toList();

      // 2. Fetch worker jobs matching the category from API
      final response = await ApiService().getJobs(category: widget.serviceCategory);
      List<dynamic> loadedJobs = [];
      if (response['status'] == true && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          loadedJobs = data;
        } else if (data is Map && data.containsKey('data')) {
          final innerData = data['data'];
          if (innerData is List) {
            loadedJobs = innerData;
          }
        }
      }

      setState(() {
        _categoryServices = localServices;
        _apiJobs = loadedJobs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading worker services: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  ServiceModel _getServiceModel(dynamic serviceData) {
    if (serviceData == null) return ServiceModel.services.first;
    final String serviceId = (serviceData['id'] ?? '').toString();
    return ServiceModel.services.firstWhere(
      (element) => element.id == serviceId,
      orElse: () => ServiceModel(
        id: serviceId,
        title: serviceData['title'] ?? serviceData['name'] ?? 'Service',
        category: serviceData['category'] ?? widget.serviceCategory,
        description: serviceData['description'] ?? '',
        basePrice: double.tryParse((serviceData['base_price'] ?? serviceData['basePrice'] ?? '0').toString()) ?? 0,
        iconData: Icons.engineering_rounded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.serviceCategory,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Services',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _categoryServices.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'No services in this category.',
                              style: GoogleFonts.outfit(color: ClickFixTheme.textMuted),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _categoryServices.length,
                            itemBuilder: (context, index) {
                              final service = _categoryServices[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(service.iconData, color: ClickFixTheme.primaryAmber),
                                  ),
                                  title: Text(
                                    service.title,
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Starts from Rs. ${service.basePrice.toStringAsFixed(0)}',
                                    style: TextStyle(color: ClickFixTheme.primaryAmber, fontWeight: FontWeight.w600),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => JobDetailsScreen(service: service),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 24),
                    Text(
                      'Featured Service Providers',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _apiJobs.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C3034) : ClickFixTheme.primaryLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.people_outline_rounded, size: 40, color: ClickFixTheme.textMuted.withOpacity(0.5)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No providers currently active.',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    'Please check back later.',
                                    style: GoogleFonts.outfit(color: ClickFixTheme.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _apiJobs.length,
                            itemBuilder: (context, index) {
                              final job = _apiJobs[index];
                              final workerUser = job['user'];
                              final workerName = workerUser != null ? (workerUser['name'] ?? 'Professional') : 'Professional';
                              final workerCity = workerUser != null ? (workerUser['city'] ?? 'Faisalabad') : 'Faisalabad';
                              final workerId = workerUser != null ? (workerUser['id'] as int?) : null;

                              final service = _getServiceModel(job['service']);
                              final price = double.tryParse((job['price'] ?? '0').toString()) ?? service.basePrice;
                              final desc = job['description'] ?? 'Expert home service provider.';

                              final int jobId = job['id'] as int? ?? 0;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => JobProfileDetailsScreen(jobId: jobId),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 26,
                                            backgroundColor: Colors.teal,
                                            child: Text(
                                              workerName.isNotEmpty ? workerName[0].toUpperCase() : 'P',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        workerName,
                                                        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: ClickFixTheme.primaryAmber.withOpacity(0.15),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Text(
                                                        'Verified Pro',
                                                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.star_rounded, color: ClickFixTheme.primaryAmber, size: 14),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      '4.9 (Live Pro)',
                                                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Icon(Icons.location_on_rounded, size: 14, color: ClickFixTheme.textMuted),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      workerCity,
                                                      style: GoogleFonts.outfit(fontSize: 12, color: ClickFixTheme.textMuted),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        desc,
                                        style: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.white60 : ClickFixTheme.textMuted),
                                      ),
                                      const SizedBox(height: 12),
                                      const Divider(height: 1),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Estimated Cost', style: TextStyle(fontSize: 10, color: ClickFixTheme.textMuted)),
                                              Text(
                                                'Rs. ${price.toStringAsFixed(0)}',
                                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: ClickFixTheme.primaryAmber),
                                              ),
                                            ],
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => BookingScreen(
                                                    initialService: service,
                                                    workerId: workerId,
                                                    workerName: workerName,
                                                  ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            child: const Text('Hire Expert'),
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
                  ],
                ),
              ),
            ),
    );
  }
}
