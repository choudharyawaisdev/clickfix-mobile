import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/screens/worker/jobworker_create_screen.dart';
import 'package:clickfix/screens/worker/bookings_screen.dart';
import 'package:clickfix/services/auth_service.dart';
import 'package:clickfix/services/api_service.dart';

class WorkerJobworkerIndexScreen extends StatefulWidget {
  const WorkerJobworkerIndexScreen({super.key});

  @override
  State<WorkerJobworkerIndexScreen> createState() => _WorkerJobworkerIndexScreenState();
}

class _WorkerJobworkerIndexScreenState extends State<WorkerJobworkerIndexScreen> {
  bool _isLoading = true;
  List<dynamic> _workerJobs = [];
  double _totalEarnings = 0;
  int _jobsDone = 0;
  int _activeJobs = 0;
  String _offeredServiceTitle = 'Loading Service...';
  String _offeredServiceCategory = '...';
  String _offeredServicePrice = '...';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final currentUser = AuthService().currentUser;
    if (currentUser == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      // 1. Fetch available jobs for worker's city
      final jobsResponse = await ApiService().getJobs(city: currentUser.city);
      List<dynamic> loadedJobs = [];
      if (jobsResponse['status'] == true && jobsResponse.containsKey('data')) {
        final data = jobsResponse['data'];
        if (data is List) {
          loadedJobs = data;
        } else if (data is Map && data.containsKey('data')) {
          final innerData = data['data'];
          if (innerData is List) {
            loadedJobs = innerData;
          }
        }
      }

      // 2. Fetch bookings to calculate statistics
      final bookingsResponse = await ApiService().getMyBookings();
      double earnings = 0;
      int done = 0;
      int active = 0;
      if (bookingsResponse['status'] == true && bookingsResponse.containsKey('data')) {
        final data = bookingsResponse['data'];
        if (data is List) {
          for (var item in data) {
            final status = (item['status'] ?? '').toString().toLowerCase();
            final priceStr = item['price'] ?? item['cost'] ?? '0';
            final double price = double.tryParse(priceStr.toString()) ?? 0;
            if (status == 'completed') {
              earnings += price;
              done++;
            } else if (['pending', 'accepted', 'on the way', 'started', 'ongoing'].contains(status)) {
              active++;
            }
          }
        }
      }

      // 3. Fetch services to resolve worker's serviceId details
      String sTitle = 'No Service Offering Registered';
      String sCat = 'General';
      String sPrice = 'Rs. 0';
      if (currentUser.serviceId != null) {
        final servicesResponse = await ApiService().getServices();
        if (servicesResponse['status'] == true && servicesResponse.containsKey('data')) {
          final data = servicesResponse['data'];
          if (data is List) {
            final match = data.firstWhere(
              (element) => element['id'] == currentUser.serviceId,
              orElse: () => null,
            );
            if (match != null) {
              sTitle = match['name'] ?? match['title'] ?? 'Registered Service';
              sCat = match['category'] ?? 'Maintenance';
              final basePrice = match['base_price'] ?? match['basePrice'] ?? '0';
              sPrice = 'Rs. ${basePrice.toString()}';
            }
          }
        }
      } else if (currentUser.description != null && currentUser.description!.isNotEmpty) {
        sTitle = currentUser.description!;
      }

      if (mounted) {
        setState(() {
          _workerJobs = loadedJobs;
          _totalEarnings = earnings;
          _jobsDone = done;
          _activeJobs = active;
          _offeredServiceTitle = sTitle;
          _offeredServiceCategory = sCat;
          _offeredServicePrice = sPrice;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading worker dashboard: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = AuthService().currentUser;
    final String displayName = currentUser?.name ?? 'Worker Pro';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: ClickFixTheme.primaryAmber,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back,',
                          style: GoogleFonts.outfit(fontSize: 14, color: ClickFixTheme.textMuted),
                        ),
                        Text(
                          '$displayName (Pro)',
                          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(radius: 4, backgroundColor: Colors.green),
                          const SizedBox(width: 6),
                          Text(
                            'Online',
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Statistics Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildStatCard('Total Earnings', 'Rs. ${_totalEarnings.toStringAsFixed(0)}', Icons.account_balance_wallet_rounded, isDark),
                    _buildStatCard('Jobs Done', _jobsDone.toString(), Icons.task_alt_rounded, isDark),
                    _buildStatCard('Average Rating', '4.9 / 5.0', Icons.star_rounded, isDark),
                    _buildStatCard('Active Jobs', _activeJobs.toString(), Icons.directions_run_rounded, isDark),
                  ],
                ),
                const SizedBox(height: 28),

                // Offered Services Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Offered Services',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WorkerJobworkerCreateScreen(),
                          ),
                        ).then((_) => _loadData());
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Service'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                _buildOfferedServiceCard(_offeredServiceTitle, _offeredServiceCategory, _offeredServicePrice, isDark),

                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Job Requests',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WorkerBookingsScreen(),
                          ),
                        ).then((_) => _loadData());
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
                          ),
                        ),
                      )
                    : _workerJobs.isEmpty
                        ? _buildEmptyState(isDark)
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _workerJobs.length > 5 ? 5 : _workerJobs.length,
                            itemBuilder: (context, index) {
                              return _buildRequestCard(_workerJobs[index], isDark, context);
                            },
                          ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String val, IconData icon, bool isDark) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: ClickFixTheme.primaryAmber, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(val, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(label, style: GoogleFonts.outfit(fontSize: 11, color: ClickFixTheme.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferedServiceCard(String title, String category, String price, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(category, style: TextStyle(color: ClickFixTheme.textMuted, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(price, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber, fontSize: 14)),
            const SizedBox(width: 8),
            const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> job, bool isDark, BuildContext context) {
    final title = job['title'] ?? 'Job Post Request';
    final price = job['price']?.toString() ?? '0';
    final location = job['location'] ?? (job['user'] != null ? job['user']['city'] : 'Faisalabad');
    final desc = job['description'] ?? 'No description offered.';
    final jobId = job['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: ClickFixTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(location, style: TextStyle(color: ClickFixTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : ClickFixTheme.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Rs. $price', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (jobId != null) {
                      setState(() {
                        _isLoading = true;
                      });
                      final res = await ApiService().updateBookingStatus(jobId as int, 'accepted');
                      if (res['status'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Job request accepted successfully!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        _loadData();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res['message'] ?? 'Could not accept job request.'),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Accept', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final city = AuthService().currentUser?.city ?? 'your city';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.work_off_rounded, size: 48, color: ClickFixTheme.textMuted.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              'No jobs available in $city',
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Pull down to check for new requests.',
              style: GoogleFonts.outfit(fontSize: 12, color: ClickFixTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
