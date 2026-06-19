import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';

class AdminBlogsEditScreen extends StatefulWidget {
  const AdminBlogsEditScreen({super.key});

  @override
  State<AdminBlogsEditScreen> createState() => _AdminBlogsEditScreenState();
}

class _AdminBlogsEditScreenState extends State<AdminBlogsEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: '10 Essential Home Maintenance Tips for Monsoon Season');
    _bodyController = TextEditingController(text: 'Monsoon season brings unique maintenance challenges for homeowners. High humidity, heavy downpours, and clogged drainage networks can lead to extensive structural dampness. Inspecting pipelines, clean gutters, checking wire short-circuits, and sealing window leaks early is critical to safety.');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Blog Post',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update the blog listing content details.',
                  style: GoogleFonts.outfit(color: ClickFixTheme.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 24),

                Text(
                  'Post Title',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter post title';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Text(
                  'Article Body Content',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _bodyController,
                  maxLines: 10,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please write some content';
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Changes discarded')),
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Blog post updated successfully!'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Update Post'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
