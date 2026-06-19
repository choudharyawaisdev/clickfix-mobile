import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/models/service_model.dart';
import 'package:clickfix/screens/customer/job_details_screen.dart';

class WishlistIndexScreen extends StatelessWidget {
  const WishlistIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Let's populate the wishlist with some initial favorite services
    final wishlistItems = [
      ServiceModel.services[0], // Electrician
      ServiceModel.services[3], // Carpenter
      ServiceModel.services[4], // Deep Cleaning
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Wishlist',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: wishlistItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded, size: 64, color: ClickFixTheme.textMuted.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Your wishlist is empty',
                    style: GoogleFonts.outfit(fontSize: 16, color: ClickFixTheme.textMuted),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final service = wishlistItems[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(service.iconData, color: ClickFixTheme.primaryAmber, size: 28),
                    ),
                    title: Text(
                      service.title,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          service.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : ClickFixTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Rs. ${service.basePrice.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: ClickFixTheme.primaryAmber,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 20),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Item removed from wishlist'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobDetailsScreen(service: service),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
