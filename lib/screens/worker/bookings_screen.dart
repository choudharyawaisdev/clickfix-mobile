import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/models/service_model.dart';

class WorkerBookingsScreen extends StatefulWidget {
  const WorkerBookingsScreen({super.key});

  @override
  State<WorkerBookingsScreen> createState() => _WorkerBookingsScreenState();
}

class _WorkerBookingsScreenState extends State<WorkerBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _dummyBookings = [
    {
      'id': 'BK-4821',
      'service': ServiceModel.services[0], // Electrician
      'date': '2026-06-20',
      'time': '10:00 AM - 12:00 PM',
      'status': 'Accepted',
      'customer': 'Hafiz Muhammad Talha',
      'phone': '+92 300 1234567',
      'cost': 500.0,
      'address': 'D-Ground, Faisalabad',
    },
    {
      'id': 'BK-9911',
      'service': ServiceModel.services[1], // Plumbing
      'date': '2026-06-21',
      'time': '01:00 PM - 03:00 PM',
      'status': 'Pending',
      'customer': 'Ali Khan',
      'phone': '+92 321 7654321',
      'cost': 600.0,
      'address': 'Kohinoor Flats, Faisalabad',
    },
    {
      'id': 'BK-1029',
      'service': ServiceModel.services[2], // AC Repair
      'date': '2026-06-18',
      'time': '02:00 PM - 04:00 PM',
      'status': 'Completed',
      'customer': 'Sajid Mehmood',
      'phone': '+92 333 9988776',
      'cost': 1500.0,
      'address': 'Gulberg, Lahore',
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateStatus(int index, String newStatus) {
    setState(() {
      _dummyBookings[index]['status'] = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Job status updated to $newStatus'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJobListView(['Pending'], isDark),
          _buildJobListView(['Accepted', 'On the Way', 'Started'], isDark),
          _buildJobListView(['Completed'], isDark),
        ],
      ),
    );
  }

  Widget _buildJobListView(List<String> statuses, bool isDark) {
    final filtered = _dummyBookings.where((b) => statuses.contains(b['status'])).toList();

    if (filtered.isEmpty) {
      return Center(
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
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final booking = filtered[index];
        final service = booking['service'] as ServiceModel;
        // Find original index in _dummyBookings to update status
        final originalIndex = _dummyBookings.indexOf(booking);

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
                      booking['id'] as String,
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: ClickFixTheme.textMuted),
                    ),
                    _buildStatusLabel(booking['status'] as String),
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
                            'Client: ${booking['customer']}',
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
                    Text(booking['address'] as String, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 14, color: ClickFixTheme.textMuted),
                    const SizedBox(width: 4),
                    Text('${booking['date']} at ${booking['time']}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildActionButtons(booking['status'] as String, originalIndex),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusLabel(String status) {
    Color color = Colors.amber;
    if (status == 'Completed') color = Colors.green;
    if (status == 'Pending') color = Colors.blue;

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

  Widget _buildActionButtons(String status, int originalIndex) {
    if (status == 'Pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateStatus(originalIndex, 'Rejected'),
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
              onPressed: () => _updateStatus(originalIndex, 'Accepted'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Accept'),
            ),
          ),
        ],
      );
    } else if (status == 'Accepted') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _updateStatus(originalIndex, 'On the Way'),
          child: const Text('Start Travel (On the Way)'),
        ),
      );
    } else if (status == 'On the Way') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _updateStatus(originalIndex, 'Started'),
          child: const Text('Start Work'),
        ),
      );
    } else if (status == 'Started') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _updateStatus(originalIndex, 'Completed'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          child: const Text('Mark Job Completed'),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
