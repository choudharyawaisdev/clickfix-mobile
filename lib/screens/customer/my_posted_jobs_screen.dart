import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/services/api_service.dart';
import 'package:clickfix/services/auth_service.dart';
import 'package:clickfix/screens/customer/post_job_screen.dart';
import 'package:clickfix/screens/chat/chat_screen.dart';
import 'package:clickfix/screens/booking_screen.dart';
import 'package:clickfix/models/service_model.dart';

class MyPostedJobsScreen extends StatefulWidget {
  const MyPostedJobsScreen({super.key});

  @override
  State<MyPostedJobsScreen> createState() => _MyPostedJobsScreenState();
}

class _MyPostedJobsScreenState extends State<MyPostedJobsScreen> {
  List<dynamic> _myJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyJobs();
  }

  Future<void> _fetchMyJobs() async {
    setState(() {
      _isLoading = true;
    });

    final response = await ApiService().getMyCustomerJobs();
    if (response['status'] == true && response.containsKey('data')) {
      setState(() {
        _myJobs = response['data'] as List;
        _isLoading = false;
      });
    } else {
      setState(() {
        _myJobs = [];
        _isLoading = false;
      });
    }
  }

  void _showBidsBottomSheet(dynamic job) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FutureBuilder<Map<String, dynamic>>(
              future: ApiService().getCustomerJobBids(job['id'] as int),
              builder: (context, snapshot) {
                final bidsLoading = snapshot.connectionState == ConnectionState.waiting;
                final response = snapshot.data;
                final List<dynamic> bids = (response != null && response['status'] == true) 
                    ? response['data'] as List 
                    : [];

                return Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: BoxDecoration(
                    color: isDark ? ClickFixTheme.primaryDark : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bids on this Job',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    job['title'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: ClickFixTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${bids.length} Bid${bids.length == 1 ? '' : 's'}',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: ClickFixTheme.primaryAmber,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      Expanded(
                        child: bidsLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
                                ),
                              )
                            : bids.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.gavel_rounded,
                                          size: 48,
                                          color: isDark ? Colors.white24 : Colors.black12,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No bids placed yet',
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Workers will bid on your job soon!',
                                          style: GoogleFonts.outfit(color: ClickFixTheme.textMuted, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: bids.length,
                                    itemBuilder: (context, index) {
                                      final bid = bids[index];
                                      final workerName = bid['worker_name'] ?? 'Pro Provider';
                                      final workerId = bid['worker_id'] as int? ?? 0;
                                      final amount = bid['amount']?.toString() ?? '0';
                                      final proposal = bid['proposal'] ?? '';

                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        child: Padding(
                                          padding: const EdgeInsets.all(14.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 16,
                                                        backgroundColor: ClickFixTheme.primaryAmber.withOpacity(0.2),
                                                        child: Text(
                                                          workerName.isNotEmpty ? workerName[0].toUpperCase() : 'W',
                                                          style: GoogleFonts.outfit(color: ClickFixTheme.primaryAmber, fontWeight: FontWeight.bold, fontSize: 12),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        workerName,
                                                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    'Rs. $amount',
                                                    style: GoogleFonts.outfit(
                                                      fontWeight: FontWeight.w900,
                                                      color: ClickFixTheme.primaryAmber,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                proposal,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 12,
                                                  color: isDark ? Colors.white70 : ClickFixTheme.textDark,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              const Divider(height: 1),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  // Contact / Chat Button
                                                  OutlinedButton.icon(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => ChatScreen(
                                                            receiverId: workerId,
                                                            receiverName: workerName,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    icon: const Icon(Icons.forum_rounded, size: 14),
                                                    label: const Text('Chat'),
                                                    style: OutlinedButton.styleFrom(
                                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                      textStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  // Book Now Button
                                                  ElevatedButton.icon(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      
                                                      // Map selected category to a ServiceModel
                                                      final jobCategory = job['category'] ?? 'Maintenance';
                                                      final matchingService = ServiceModel.services.firstWhere(
                                                        (s) => s.title.toLowerCase() == jobCategory.toString().toLowerCase(),
                                                        orElse: () => ServiceModel.services.first,
                                                      );

                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => BookingScreen(
                                                            initialService: matchingService,
                                                            workerId: workerId,
                                                            workerName: workerName,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    icon: const Icon(Icons.calendar_month_rounded, size: 14),
                                                    label: const Text('Hire & Book'),
                                                    style: ElevatedButton.styleFrom(
                                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                      textStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Posted Jobs',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: ClickFixTheme.primaryAmber),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PostJobScreen()),
              );
              if (result == true) {
                _fetchMyJobs();
              }
            },
            tooltip: 'Post a New Job',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMyJobs,
        color: ClickFixTheme.primaryAmber,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
                ),
              )
            : _myJobs.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: _myJobs.length,
                    itemBuilder: (context, index) {
                      final job = _myJobs[index];
                      final title = job['title'] ?? 'Job Request';
                      final category = job['category'] ?? 'Maintenance';
                      final budget = job['budget']?.toString() ?? '0';
                      final location = job['location'] ?? 'Faisalabad';
                      final desc = job['description'] ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () => _showBidsBottomSheet(job),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        category,
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          color: ClickFixTheme.primaryAmber,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Rs. $budget',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w900,
                                        color: ClickFixTheme.primaryAmber,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  desc,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: isDark ? Colors.white60 : ClickFixTheme.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_rounded, size: 14, color: ClickFixTheme.primaryAmber),
                                        const SizedBox(width: 4),
                                        Text(
                                          location,
                                          style: GoogleFonts.outfit(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    // Simulated bid count count trigger helper
                                    Row(
                                      children: [
                                        const Icon(Icons.gavel_rounded, size: 14, color: ClickFixTheme.primaryAmber),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Tap to view bids',
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: ClickFixTheme.primaryAmber,
                                          ),
                                        ),
                                      ],
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
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_rounded,
                  size: 64,
                  color: ClickFixTheme.primaryAmber,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Posted Jobs Yet',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Post your requirements to receive competitive quotes and bids from local experts.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: ClickFixTheme.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PostJobScreen()),
                    );
                    if (result == true) {
                      _fetchMyJobs();
                    }
                  },
                  child: const Text('Post a Job'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
