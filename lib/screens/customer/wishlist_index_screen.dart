import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/services/api_service.dart';
import 'package:clickfix/screens/customer/job_profile_details_screen.dart';

class WishlistIndexScreen extends StatefulWidget {
  const WishlistIndexScreen({super.key});

  @override
  State<WishlistIndexScreen> createState() => _WishlistIndexScreenState();
}

class _WishlistIndexScreenState extends State<WishlistIndexScreen> {
  List<dynamic> _wishlistWorkers = [];
  List<dynamic> _allJobs = [];
  bool _isLoading = true;

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

    try {
      // 1. Fetch wishlist workers from API
      final wishlistResponse = await ApiService().getWishlist();
      List<dynamic> workers = [];
      if (wishlistResponse['status'] == true && wishlistResponse.containsKey('data')) {
        workers = wishlistResponse['data'] as List? ?? [];
      }

      // 2. Fetch all jobs to resolve jobId for profile details navigation
      final jobsResponse = await ApiService().getJobs(category: null);
      List<dynamic> jobs = [];
      if (jobsResponse['status'] == true && jobsResponse.containsKey('data')) {
        final data = jobsResponse['data'];
        if (data is List) {
          jobs = data;
        } else if (data is Map && data.containsKey('data')) {
          jobs = data['data'] as List? ?? [];
        }
      }

      if (mounted) {
        setState(() {
          _wishlistWorkers = workers;
          _allJobs = jobs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading wishlist data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeFromWishlist(int workerId, String workerName) async {
    final res = await ApiService().toggleWishlist(workerId);
    if (res['status'] == true) {
      if (mounted) {
        setState(() {
          _wishlistWorkers.removeWhere((w) => w['id'] == workerId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$workerName removed from wishlist'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Wishlist',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
            tooltip: 'Refresh List',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
              ),
            )
          : _wishlistWorkers.isEmpty
              ? Center(
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
                            Icons.favorite_border_rounded,
                            size: 64,
                            color: ClickFixTheme.primaryAmber,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Your Wishlist is Empty',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Save your favorite service providers to hire them easily later.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: ClickFixTheme.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _wishlistWorkers.length,
                  itemBuilder: (context, index) {
                    final worker = _wishlistWorkers[index];
                    final String workerName = worker['name'] ?? 'Pro Provider';
                    final int workerId = worker['id'] ?? 0;
                    final String workerCity = worker['city'] ?? 'Faisalabad';
                    
                    // Resolve service title category
                    final serviceData = worker['service'];
                    final String serviceCategory = serviceData != null
                        ? (serviceData['title'] ?? serviceData['name'] ?? 'General').toString()
                        : 'General';

                    // Parse profile image url
                    final String imageUrl = worker['profile_picture'] != null && worker['profile_picture'].toString().isNotEmpty
                        ? (worker['profile_picture'].toString().startsWith('http')
                            ? worker['profile_picture'].toString()
                            : 'https://clickfix.hafiztalha.com/storage/${worker['profile_picture']}')
                        : '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: ClickFixTheme.primaryAmber, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.teal,
                            backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                            child: imageUrl.isEmpty
                                ? Text(
                                    workerName.isNotEmpty ? workerName[0].toUpperCase() : 'W',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                  )
                                : null,
                          ),
                        ),
                        title: Text(
                          workerName,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    serviceCategory,
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      color: ClickFixTheme.primaryAmber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 12, color: Colors.redAccent),
                                    const SizedBox(width: 2),
                                    Text(
                                      workerCity,
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        color: isDark ? Colors.white60 : ClickFixTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 24),
                          onPressed: () => _removeFromWishlist(workerId, workerName),
                          tooltip: 'Remove from Wishlist',
                        ),
                        onTap: () {
                          // Find matching job posted by this worker
                          final matchingJob = _allJobs.firstWhere(
                            (job) => job['user'] != null && job['user']['id'] == workerId,
                            orElse: () => null,
                          );

                          if (matchingJob != null) {
                            final int jobId = matchingJob['id'] ?? 0;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JobProfileDetailsScreen(jobId: jobId),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$workerName has no active job listings at the moment.'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.amber.shade900,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
