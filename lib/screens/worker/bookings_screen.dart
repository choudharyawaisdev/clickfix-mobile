import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/models/service_model.dart';
import 'package:clickfix/services/api_service.dart';

class WorkerBookingsScreen extends StatefulWidget {
  const WorkerBookingsScreen({super.key});

  @override
  State<WorkerBookingsScreen> createState() => _WorkerBookingsScreenState();
}

class _WorkerBookingsScreenState extends State<WorkerBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService().getMyBookings();
      if (response['status'] == true && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          setState(() {
            _bookings = data;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching worker bookings: $e');
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(int bookingId, String newStatus) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService().updateBookingStatus(bookingId, newStatus);
      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Job status updated to $newStatus'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        _loadBookings();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to update job status'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error updating booking status: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  ServiceModel _getServiceModel(dynamic serviceData) {
    if (serviceData == null) return ServiceModel.services.first;
    final String serviceId = (serviceData['id'] ?? '').toString();
    return ServiceModel.services.firstWhere(
      (element) => element.id == serviceId,
      orElse: () => ServiceModel(
        id: serviceId,
        title: serviceData['title'] ?? serviceData['name'] ?? 'Service Request',
        category: serviceData['category'] ?? 'Maintenance',
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
          'Assigned Jobs',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ClickFixTheme.primaryAmber,
          labelColor: ClickFixTheme.primaryAmber,
          unselectedLabelColor: isDark ? Colors.white60 : ClickFixTheme.textMuted,
          tabs: const [
            Tab(text: 'Incoming'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildJobListView(['pending'], isDark),
                _buildJobListView(['accepted', 'on the way', 'started', 'ongoing'], isDark),
                _buildJobListView(['completed'], isDark),
              ],
            ),
    );
  }

  Widget _buildJobListView(List<String> statuses, bool isDark) {
    final filtered = _bookings.where((b) {
      final status = (b['status'] ?? '').toString().toLowerCase();
      return statuses.contains(status);
    }).toList();

    if (filtered.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadBookings,
        color: ClickFixTheme.primaryAmber,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_rounded, size: 64, color: ClickFixTheme.textMuted.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No jobs found',
                    style: GoogleFonts.outfit(fontSize: 16, color: ClickFixTheme.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: ClickFixTheme.primaryAmber,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final booking = filtered[index];
          final service = _getServiceModel(booking['service']);
          final int bookingId = booking['id'] as int? ?? 0;
          final rawStatus = (booking['status'] ?? 'pending').toString();
          final displayStatus = rawStatus.isNotEmpty ? (rawStatus[0].toUpperCase() + rawStatus.substring(1)) : 'Pending';
          
          final customerName = booking['user'] != null ? (booking['user']['name'] ?? 'Client') : 'Client';
          final address = booking['address'] ?? 'Faisalabad';
          final date = booking['booking_date'] ?? booking['date'] ?? '';
          final time = booking['booking_time'] ?? booking['time'] ?? '';

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BK-$bookingId',
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: ClickFixTheme.textMuted),
                      ),
                      _buildStatusLabel(displayStatus),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(service.iconData, color: ClickFixTheme.primaryAmber),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.title,
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Client: $customerName',
                              style: GoogleFonts.outfit(fontSize: 12, color: ClickFixTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: ClickFixTheme.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(address, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 14, color: ClickFixTheme.textMuted),
                      const SizedBox(width: 4),
                      Text('$date at $time', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildActionButtons(rawStatus, bookingId),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusLabel(String status) {
    Color color = Colors.amber;
    final normalized = status.toLowerCase();
    if (normalized == 'completed') color = Colors.green;
    if (normalized == 'pending') color = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildActionButtons(String status, int bookingId) {
    final normalized = status.toLowerCase();
    if (normalized == 'pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateStatus(bookingId, 'rejected'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Decline'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatus(bookingId, 'accepted'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Accept'),
            ),
          ),
        ],
      );
    } else if (normalized == 'accepted') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _updateStatus(bookingId, 'on the way'),
          child: const Text('Start Travel (On the Way)'),
        ),
      );
    } else if (normalized == 'on the way') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _updateStatus(bookingId, 'started'),
          child: const Text('Start Work'),
        ),
      );
    } else if (normalized == 'started' || normalized == 'ongoing') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _updateStatus(bookingId, 'completed'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          child: const Text('Mark Job Completed'),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
