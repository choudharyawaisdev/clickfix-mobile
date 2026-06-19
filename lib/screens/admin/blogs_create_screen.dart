import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';

class AdminBlogsCreateScreen extends StatefulWidget {
  const AdminBlogsCreateScreen({super.key});

  @override
  State<AdminBlogsCreateScreen> createState() => _AdminBlogsCreateScreenState();
}

class _AdminBlogsCreateScreenState extends State<AdminBlogsCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

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
          'Write Blog Post',
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
                  'Publish content resources for home improvement & service guidance.',
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
                  decoration: const InputDecoration(hintText: 'e.g. Tips to prevent plumbing pipe bursts'),
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
                  decoration: const InputDecoration(hintText: 'Write your full blog post details here...'),
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
                            const SnackBar(content: Text('Draft saved successfully')),
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Save Draft'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Blog post published successfully!'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Publish Post'),
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
