import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/services/api_service.dart';
import 'package:clickfix/services/auth_service.dart';
import 'package:clickfix/screens/worker/bid_on_job_screen.dart';
import 'package:clickfix/models/service_model.dart';

class CustomerJobsFeedScreen extends StatefulWidget {
  const CustomerJobsFeedScreen({super.key});

  @override
  State<CustomerJobsFeedScreen> createState() => _CustomerJobsFeedScreenState();
}

class _CustomerJobsFeedScreenState extends State<CustomerJobsFeedScreen> {
  List<dynamic> _jobs = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    setState(() {
      _isLoading = true;
    });

    final response = await ApiService().getAllCustomerJobs();
    if (response['status'] == true && response.containsKey('data')) {
      final loadedJobs = response['data'] as List;

      // Filter: Only show jobs matching worker's service category
      final worker = AuthService().currentUser;
      final workerService = ServiceModel.services.firstWhere(
        (s) => s.id == worker?.serviceId?.toString(),
        orElse: () => const ServiceModel(
          id: '',
          title: '',
          category: '',
          iconData: Icons.engineering_rounded,
          description: '',
          basePrice: 0,
        ),
      );
      final workerServiceTitle = workerService.title.toLowerCase().trim();

      final filteredJobs = loadedJobs.where((job) {
        final jobCategory = (job['category'] ?? '').toString().toLowerCase().trim();
        return workerServiceTitle.isEmpty || jobCategory == workerServiceTitle;
      }).toList();

      // Extract unique categories from jobs
      final cats = {'All'};
      for (var job in filteredJobs) {
        if (job['category'] != null) {
          cats.add(job['category'].toString());
        }
      }

      setState(() {
        _jobs = filteredJobs;
        _categories = cats.toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _jobs = [];
        _categories = ['All'];
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredJobs {
    return _jobs.where((job) {
      final categoryMatches = _selectedCategory == 'All' || 
          job['category']?.toString().toLowerCase() == _selectedCategory.toLowerCase();
      
      final title = (job['title'] ?? '').toString().toLowerCase();
      final desc = (job['description'] ?? '').toString().toLowerCase();
      final searchMatches = _searchQuery.isEmpty || 
          title.contains(_searchQuery.toLowerCase()) || 
          desc.contains(_searchQuery.toLowerCase());

      return categoryMatches && searchMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final list = _filteredJobs;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Customer Jobs Feed',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchJobs,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search jobs (e.g. AC service, wiring...)',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Horizontal category chips
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = cat == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected 
                                  ? ClickFixTheme.primaryDark 
                                  : (isDark ? Colors.white70 : ClickFixTheme.textDark),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: ClickFixTheme.primaryAmber,
                          backgroundColor: isDark ? const Color(0xFF2C3034) : ClickFixTheme.primaryLight,
                          checkmarkColor: ClickFixTheme.primaryDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected 
                                  ? ClickFixTheme.primaryAmber 
                                  : (isDark ? Colors.white10 : ClickFixTheme.borderGray),
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Stream listings
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
                    ),
                  )
                : list.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final job = list[index];
                          final int jobId = job['id'] ?? 0;
                          final title = job['title'] ?? 'Job Request';
                          final category = job['category'] ?? 'Maintenance';
                          final budget = job['budget']?.toString() ?? '0';
                          final location = job['location'] ?? 'Faisalabad';
                          final desc = job['description'] ?? '';
                          final postedBy = job['posted_by'] ?? 'Customer';

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
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    desc,
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
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on_rounded, size: 12, color: ClickFixTheme.primaryAmber),
                                                const SizedBox(width: 4),
                                                Text(
                                                  location,
                                                  style: GoogleFonts.outfit(fontSize: 11),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Posted by: $postedBy',
                                              style: GoogleFonts.outfit(
                                                fontSize: 10,
                                                color: ClickFixTheme.textMuted,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => BidOnJobScreen(job: job),
                                            ),
                                          );
                                          if (result == true) {
                                            _fetchJobs();
                                          }
                                        },
                                        icon: const Icon(Icons.gavel_rounded, size: 14),
                                        label: const Text('Bid Now'),
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
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.gavel_rounded,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'No Jobs Found',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no active customer jobs matching your criteria right now.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: ClickFixTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
