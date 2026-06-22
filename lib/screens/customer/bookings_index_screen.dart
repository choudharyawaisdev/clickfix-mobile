import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/models/service_model.dart';
import 'package:clickfix/services/api_service.dart';

class BookingsIndexScreen extends StatefulWidget {
  const BookingsIndexScreen({super.key});

  @override
  State<BookingsIndexScreen> createState() => _BookingsIndexScreenState();
}

class _BookingsIndexScreenState extends State<BookingsIndexScreen> with SingleTickerProviderStateMixin {
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
      debugPrint('Error loading customer bookings: $e');
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showReviewDialog(int bookingId, int workerId, String workerName) {
    int selectedRating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rate $workerName',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'How was your experience with this service provider?',
                      style: GoogleFonts.outfit(fontSize: 13, color: ClickFixTheme.textMuted),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starIndex = index + 1;
                          return IconButton(
                            icon: Icon(
                              starIndex <= selectedRating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: ClickFixTheme.primaryAmber,
                              size: 36,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                selectedRating = starIndex;
                              });
                            },
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your Review (Optional)',
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Share details of your experience...',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel', style: GoogleFonts.outfit(color: ClickFixTheme.textMuted)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            final comment = commentController.text.trim();
                            final response = await ApiService().submitReview(
                              workerId: workerId,
                              bookingId: bookingId,
                              rating: selectedRating,
                              comment: comment.isNotEmpty ? comment : null,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(response['message'] ?? 'Review submitted successfully!'),
                                  backgroundColor: response['status'] == true ? Colors.green : Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: Text('Submit', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  ServiceModel _getServiceModel(dynamic serviceData) {
    if (serviceData == null) return ServiceModel.services.first;
    final String serviceId = (serviceData['id'] ?? '').toString();
    return ServiceModel.services.firstWhere(
      (element) => element.id == serviceId,
      orElse: () => ServiceModel(
        id: serviceId,
        title: serviceData['title'] ?? serviceData['name'] ?? 'Service Booking',
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(['pending', 'accepted', 'on the way', 'started', 'ongoing'], isDark),
                _buildBookingList(['completed'], isDark),
                _buildBookingList(['cancelled', 'rejected'], isDark),
              ],
            ),
    );
  }

  Widget _buildBookingList(List<String> statuses, bool isDark) {
    final list = _bookings.where((b) {
      final status = (b['status'] ?? '').toString().toLowerCase();
      return statuses.contains(status);
    }).toList();

    if (list.isEmpty) {
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
                  Icon(Icons.calendar_today_rounded, size: 64, color: ClickFixTheme.textMuted.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No bookings found',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
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
        itemCount: list.length,
        itemBuilder: (context, index) {
          final booking = list[index];
          final service = _getServiceModel(booking['service']);
          final int bookingId = booking['id'] as int? ?? 0;
          final rawStatus = (booking['status'] ?? 'pending').toString();
          
          String displayStatus = 'Active';
          if (rawStatus == 'completed') displayStatus = 'Completed';
          if (rawStatus == 'cancelled' || rawStatus == 'rejected') displayStatus = 'Cancelled';

          final workerName = booking['worker'] != null ? (booking['worker']['name'] ?? 'Professional') : 'Finding best expert...';
          final address = booking['address'] ?? 'Address details';
          final date = booking['booking_date'] ?? booking['date'] ?? '';
          final time = booking['booking_time'] ?? booking['time'] ?? '';
          final cost = double.tryParse((booking['price'] ?? booking['cost'] ?? '0').toString()) ?? 0.0;

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
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: ClickFixTheme.textMuted,
                        ),
                      ),
                      _buildStatusBadge(displayStatus),
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
                              'Provider: $workerName',
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 14, color: ClickFixTheme.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  '$date at $time',
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
                                Expanded(
                                  child: Text(
                                    address,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.white60 : ClickFixTheme.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Rs. ${cost.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: ClickFixTheme.primaryAmber,
                        ),
                      ),
                    ],
                  ),
                  if (displayStatus == 'Completed') ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final worker = booking['worker'];
                          final wId = worker != null ? worker['id'] as int? : null;
                          if (wId != null) {
                            _showReviewDialog(bookingId, wId, workerName);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Worker details not found for this review.'),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.star_rounded, size: 18),
                        label: const Text('Leave a Review'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: ClickFixTheme.primaryAmber,
                          foregroundColor: ClickFixTheme.primaryDark,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    
    switch (status) {
      case 'Active':
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
