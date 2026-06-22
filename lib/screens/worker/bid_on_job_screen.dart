import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/services/api_service.dart';

class BidOnJobScreen extends StatefulWidget {
  final dynamic job;

  const BidOnJobScreen({super.key, required this.job});

  @override
  State<BidOnJobScreen> createState() => _BidOnJobScreenState();
}

class _BidOnJobScreenState extends State<BidOnJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _proposalController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Default bid amount to customer's budget
    final budget = widget.job['budget'];
    if (budget != null) {
      _amountController.text = budget.toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _proposalController.dispose();
    super.dispose();
  }

  Future<void> _submitBid() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final jobId = widget.job['id'] as int;

    final response = await ApiService().placeBid(
      jobId: jobId,
      amount: amount,
      proposal: _proposalController.text.trim(),
    );

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(response['message'] ?? 'Bid placed successfully!'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to trigger refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to place bid. Please try again.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final title = widget.job['title'] ?? 'Job Post Details';
    final category = widget.job['category'] ?? 'Maintenance';
    final budget = widget.job['budget']?.toString() ?? '0';
    final location = widget.job['location'] ?? 'Faisalabad';
    final desc = widget.job['description'] ?? '';
    final postedBy = widget.job['posted_by'] ?? 'Customer';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Place a Bid',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job details overview card
                  Card(
                    margin: EdgeInsets.zero,
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
                                'Budget: Rs. $budget',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w900,
                                  color: ClickFixTheme.primaryAmber,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            title,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            desc,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : ClickFixTheme.textMuted,
                              height: 1.4,
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
                              Text(
                                'By: $postedBy',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: ClickFixTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Text(
                    'Your Bid Offer (Rs.)',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ClickFixTheme.primaryAmber,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter your bidding price',
                      prefixIcon: Icon(Icons.payments_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a bid amount';
                      }
                      final numVal = double.tryParse(value);
                      if (numVal == null || numVal <= 0) {
                        return 'Please enter a valid positive number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Your Proposal / Message',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ClickFixTheme.primaryAmber,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _proposalController,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: 'Explain why you are the best fit for this job, your availability, etc.',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 60.0),
                        child: Icon(Icons.message_rounded),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please write a short proposal';
                      }
                      if (value.trim().length < 10) {
                        return 'Proposal must be at least 10 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 36),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitBid,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryDark),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.gavel_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Submit My Bid',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
