import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/models/service_model.dart';

class BookingsIndexScreen extends StatefulWidget {
  const BookingsIndexScreen({super.key});

  @override
  State<BookingsIndexScreen> createState() => _BookingsIndexScreenState();
}

class _BookingsIndexScreenState extends State<BookingsIndexScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _dummyBookings = [
    {
      'id': 'BK-4821',
      'service': ServiceModel.services[0], // Electrician
      'date': '2026-06-20',
      'time': '10:00 AM - 12:00 PM',
      'status': 'Ongoing',
      'worker': 'Hafiz Muhammad Talha',
      'cost': 500.0,
      'address': 'D-Ground, Faisalabad',
    },
    {
      'id': 'BK-1029',
      'service': ServiceModel.services[2], // AC Repair
      'date': '2026-06-18',
      'time': '02:00 PM - 04:00 PM',
      'status': 'Completed',
      'worker': 'Sajid Mehmood',
      'cost': 1500.0,
      'address': 'Gulberg, Lahore',
    },
    {
      'id': 'BK-9932',
      'service': ServiceModel.services[4], // Cleaning
      'date': '2026-06-15',
      'time': '09:00 AM - 11:00 AM',
      'status': 'Cancelled',
      'worker': 'Awais Choudhary',
      'cost': 1200.0,
      'address': 'F-8, Islamabad',
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

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ClickFixTheme.primaryAmber,
          labelColor: ClickFixTheme.primaryAmber,
          unselectedLabelColor: isDark ? Colors.white60 : ClickFixTheme.textMuted,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList('Ongoing', isDark),
          _buildBookingList('Completed', isDark),
          _buildBookingList('Cancelled', isDark),
        ],
      ),
    );
  }

  Widget _buildBookingList(String filterStatus, bool isDark) {
    final list = _dummyBookings.where((b) => b['status'] == filterStatus).toList();

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_rounded, size: 64, color: ClickFixTheme.textMuted.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No bookings found',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final booking = list[index];
        final service = booking['service'] as ServiceModel;

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
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: ClickFixTheme.textMuted,
                      ),
                    ),
                    _buildStatusBadge(booking['status'] as String),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
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
                          const SizedBox(height: 4),
                          Text(
                            'Provider: ${booking['worker']}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : ClickFixTheme.textMuted,
                            ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: ClickFixTheme.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              '${booking['date']} at ${booking['time']}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white60 : ClickFixTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 14, color: ClickFixTheme.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              booking['address'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white60 : ClickFixTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      'Rs. ${booking['cost'].toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: ClickFixTheme.primaryAmber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    
    switch (status) {
      case 'Ongoing':
        bg = Colors.amber.withOpacity(0.12);
        fg = Colors.amber.shade700;
        break;
      case 'Completed':
        bg = Colors.green.withOpacity(0.12);
        fg = Colors.green;
        break;
      default:
        bg = Colors.red.withOpacity(0.12);
        fg = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
