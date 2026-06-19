import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';

class AdminReviewsIndexScreen extends StatefulWidget {
  const AdminReviewsIndexScreen({super.key});

  @override
  State<AdminReviewsIndexScreen> createState() => _AdminReviewsIndexScreenState();
}

class _AdminReviewsIndexScreenState extends State<AdminReviewsIndexScreen> {
  final List<Map<String, dynamic>> _dummyReviews = [
    {
      'id': '1',
      'author': 'Mariam Bibi',
      'worker': 'Awais Choudhary',
      'rating': 5,
      'content': 'Awais was extremely fast. Solved our kitchen pipe clogging in under 15 minutes! Clean work.',
      'flagged': false,
    },
    {
      'id': '2',
      'author': 'Zainab Jameel',
      'worker': 'Hafiz Talha',
      'rating': 1,
      'content': 'SPAM CONTENT!!! Fake technician did not arrive at my home! Please ban this app.',
      'flagged': true,
    },
    {
      'id': '3',
      'author': 'Ali Khan',
      'worker': 'Sajid Mehmood',
      'rating': 4,
      'content': 'Decent experience. Sofa cleaning took around 2 hours, but it was thorough.',
      'flagged': false,
    }
  ];

  void _toggleFlag(int index) {
    setState(() {
      _dummyReviews[index]['flagged'] = !_dummyReviews[index]['flagged'];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Review moderation status updated'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteReview(int index) {
    setState(() {
      _dummyReviews.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review deleted permanently'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Moderate Reviews',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _dummyReviews.length,
        itemBuilder: (context, index) {
          final review = _dummyReviews[index];
          final isFlagged = review['flagged'] as bool;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Client: ${review['author']}',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            'To: ${review['worker']}',
                            style: TextStyle(color: ClickFixTheme.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isFlagged ? Colors.red.withOpacity(0.12) : Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isFlagged ? 'Flagged SPAM' : 'Approved',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: isFlagged ? Colors.redAccent : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(
                      review['rating'] as int,
                      (index) => const Icon(Icons.star_rounded, color: ClickFixTheme.primaryAmber, size: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"${review['content']}"',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                      color: isDark ? Colors.white70 : ClickFixTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _toggleFlag(index),
                        icon: Icon(isFlagged ? Icons.check_circle_outline_rounded : Icons.outlined_flag_rounded, size: 14),
                        label: Text(isFlagged ? 'Unflag' : 'Flag Spam'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          foregroundColor: isFlagged ? Colors.green : Colors.amber.shade700,
                          side: BorderSide(color: isFlagged ? Colors.green : Colors.amber.shade700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _deleteReview(index),
                        icon: const Icon(Icons.delete_forever_rounded, size: 14),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
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
    );
  }
}
