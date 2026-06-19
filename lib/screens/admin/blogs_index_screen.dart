import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/screens/admin/blogs_create_screen.dart';
import 'package:clickfix/screens/admin/blogs_edit_screen.dart';

class AdminBlogsIndexScreen extends StatefulWidget {
  const AdminBlogsIndexScreen({super.key});

  @override
  State<AdminBlogsIndexScreen> createState() => _AdminBlogsIndexScreenState();
}

class _AdminBlogsIndexScreenState extends State<AdminBlogsIndexScreen> {
  final List<Map<String, String>> _dummyBlogs = [
    {
      'id': '1',
      'title': '10 Essential Home Maintenance Tips for Monsoon Season',
      'date': 'June 18, 2026',
      'author': 'Admin',
      'status': 'Published',
    },
    {
      'id': '2',
      'title': 'How Solar Panel Installation Can Save 70% Electricity Cost',
      'date': 'June 15, 2026',
      'author': 'Admin',
      'status': 'Published',
    },
    {
      'id': '3',
      'title': 'Signs of Electrical Hazard in Your Home and How to Spot Them',
      'date': 'June 10, 2026',
      'author': 'Hafiz Talha',
      'status': 'Draft',
    }
  ];

  void _deleteBlog(int index) {
    setState(() {
      _dummyBlogs.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Blog post deleted successfully'),
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
          'Manage Platform Blogs',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: ClickFixTheme.primaryAmber),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminBlogsCreateScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _dummyBlogs.length,
        itemBuilder: (context, index) {
          final blog = _dummyBlogs[index];
          final isPublished = blog['status'] == 'Published';

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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPublished ? Colors.green.withOpacity(0.12) : Colors.amber.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          blog['status']!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isPublished ? Colors.green : Colors.amber.shade700,
                          ),
                        ),
                      ),
                      Text(
                        blog['date']!,
                        style: GoogleFonts.outfit(fontSize: 12, color: ClickFixTheme.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    blog['title']!,
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Author: ${blog['author']}',
                    style: TextStyle(fontSize: 12, color: ClickFixTheme.textMuted),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminBlogsEditScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: const Text('Edit'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _deleteBlog(index),
                        icon: const Icon(Icons.delete_forever_rounded, size: 16, color: Colors.redAccent),
                        label: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
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
