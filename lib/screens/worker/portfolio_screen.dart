import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clickfix/services/api_service.dart';

class WorkerPortfolioScreen extends StatefulWidget {
  const WorkerPortfolioScreen({super.key});

  @override
  State<WorkerPortfolioScreen> createState() => _WorkerPortfolioScreenState();
}

class _WorkerPortfolioScreenState extends State<WorkerPortfolioScreen> {
  bool _isLoading = true;
  List<dynamic> _portfolioItems = [];

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService().getPortfolio();
      if (response['status'] == true && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          _portfolioItems = data;
        }
      }
    } catch (e) {
      debugPrint('Error loading portfolio: $e');
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _createDummyImageFile() async {
    // Create a tiny valid 1x1 transparent PNG file in the temporary directory
    final path = '${Directory.systemTemp.path}/dummy_portfolio_item.png';
    final file = File(path);
    final pngBytes = [
      137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
      0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137,
      0, 0, 0, 10, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5,
      0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66,
      96, 130
    ];
    await file.writeAsBytes(pngBytes);
    return path;
  }

  void _showAddPortfolioDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;
    File? selectedImageFile;

    Widget buildSourceTile(IconData icon, String label, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: ClickFixTheme.primaryAmber.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: ClickFixTheme.primaryAmber, size: 32),
              const SizedBox(height: 8),
              Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    Future<void> pickImage(StateSetter setDialogState) async {
      final picker = ImagePicker();
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
          return Container(
            decoration: BoxDecoration(
              color: isDark ? ClickFixTheme.primaryDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Project Image',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildSourceTile(Icons.photo_library_rounded, 'Gallery', () async {
                      Navigator.pop(sheetContext);
                      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                      if (picked != null) {
                        setDialogState(() {
                          selectedImageFile = File(picked.path);
                        });
                      }
                    }),
                    buildSourceTile(Icons.camera_alt_rounded, 'Camera', () async {
                      Navigator.pop(sheetContext);
                      final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                      if (picked != null) {
                        setDialogState(() {
                          selectedImageFile = File(picked.path);
                        });
                      }
                    }),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final bgColor = isDark ? ClickFixTheme.primaryDark : Colors.white;
            final textColor = isDark ? Colors.white : ClickFixTheme.textDark;
            final inputBg = isDark ? const Color(0xFF1E2124) : Colors.grey.shade50;
            final borderColor = isDark ? Colors.white12 : Colors.black12;

            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                color: ClickFixTheme.primaryAmber,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Add New Project',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Divider
                      Container(
                        height: 1,
                        color: borderColor,
                        width: double.infinity,
                      ),

                      // Form content
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title Field
                              Text(
                                'Project Title',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: ClickFixTheme.primaryAmber,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: titleController,
                                style: GoogleFonts.outfit(fontSize: 14, color: textColor),
                                decoration: InputDecoration(
                                  hintText: 'e.g. Living Room AC Installation',
                                  filled: true,
                                  fillColor: inputBg,
                                  prefixIcon: const Icon(Icons.title_rounded, color: ClickFixTheme.primaryAmber, size: 20),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: borderColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: ClickFixTheme.primaryAmber, width: 1.5),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.redAccent),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Please enter project title';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Description Field
                              Text(
                                'Description',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: ClickFixTheme.primaryAmber,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: descController,
                                style: GoogleFonts.outfit(fontSize: 14, color: textColor),
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Describe what work you performed, materials used, etc.',
                                  filled: true,
                                  fillColor: inputBg,
                                  prefixIcon: const Icon(Icons.description_outlined, color: ClickFixTheme.primaryAmber, size: 20),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: borderColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: ClickFixTheme.primaryAmber, width: 1.5),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.redAccent),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Please enter project description';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Project Image Upload Area
                              Text(
                                'Project Image',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: ClickFixTheme.primaryAmber,
                                ),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => pickImage(setDialogState),
                                child: Container(
                                  height: 140,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: inputBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: selectedImageFile != null 
                                          ? ClickFixTheme.primaryAmber.withOpacity(0.5) 
                                          : borderColor,
                                      width: selectedImageFile != null ? 1.5 : 1,
                                    ),
                                  ),
                                  child: selectedImageFile != null
                                      ? Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: Image.file(
                                                selectedImageFile!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              ),
                                            ),
                                            // Semi-transparent overlay on hover/tap hint
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.4),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(Icons.photo_library_rounded, color: Colors.white, size: 28),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Change Image',
                                                      style: GoogleFonts.outfit(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Close button to remove image
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setDialogState(() {
                                                    selectedImageFile = null;
                                                  });
                                                },
                                                child: const CircleAvatar(
                                                  backgroundColor: Colors.black54,
                                                  radius: 12,
                                                  child: Icon(Icons.close, color: Colors.white, size: 14),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_photo_alternate_rounded,
                                              size: 40,
                                              color: ClickFixTheme.primaryAmber.withOpacity(0.8),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Tap to upload project image',
                                              style: GoogleFonts.outfit(
                                                color: ClickFixTheme.textMuted,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Supports Camera or Gallery',
                                              style: GoogleFonts.outfit(
                                                color: ClickFixTheme.textMuted.withOpacity(0.6),
                                                fontSize: 10,
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

                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isSaving ? null : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  side: BorderSide(color: borderColor),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isDark ? Colors.white70 : ClickFixTheme.textDark,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isSaving
                                    ? null
                                    : () async {
                                        if (formKey.currentState!.validate()) {
                                          if (selectedImageFile == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Please upload a project image'),
                                                behavior: SnackBarBehavior.floating,
                                                backgroundColor: Colors.redAccent,
                                              ),
                                            );
                                            return;
                                          }

                                          setDialogState(() {
                                            isSaving = true;
                                          });

                                          try {
                                            final response = await ApiService().storePortfolio(
                                              imagePath: selectedImageFile!.path,
                                              title: titleController.text,
                                              description: descController.text,
                                            );

                                            if (response['status'] == true) {
                                              Navigator.pop(context);
                                              _loadPortfolio();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Portfolio item added successfully!'),
                                                  backgroundColor: Colors.green,
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(response['message'] ?? 'Failed to add portfolio item.'),
                                                  backgroundColor: Colors.redAccent,
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Error: $e'),
                                                backgroundColor: Colors.redAccent,
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          } finally {
                                            setDialogState(() {
                                              isSaving = false;
                                            });
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ClickFixTheme.primaryAmber,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryDark),
                                        ),
                                      )
                                    : Text(
                                        'Save Project',
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: ClickFixTheme.primaryDark,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deletePortfolioItem(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Project', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this portfolio project?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      try {
        final response = await ApiService().destroyPortfolio(id);
        if (response['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project deleted successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to delete project.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error deleting item: $e');
      }
      _loadPortfolio();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Portfolio',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadPortfolio,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPortfolioDialog,
        backgroundColor: ClickFixTheme.primaryAmber,
        child: const Icon(Icons.add, color: ClickFixTheme.primaryDark),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMiniStat('${_portfolioItems.length}', 'Projects Added'),
                            _buildMiniStat('100%', 'Job Success'),
                            _buildMiniStat('3+', 'Years Exp'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Showcase Projects',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    _portfolioItems.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.auto_stories_outlined,
                                    size: 48,
                                    color: ClickFixTheme.textMuted.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No showcase projects yet',
                                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Click the + button to showcase your work.',
                                    style: GoogleFonts.outfit(fontSize: 12, color: ClickFixTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _portfolioItems.length,
                            itemBuilder: (context, index) {
                              final proj = _portfolioItems[index];
                              final String title = proj['title'] ?? 'Showcase Project';
                              final String description = proj['description'] ?? '';
                              final int id = proj['id'] ?? 0;

                              // Construct absolute url of uploaded image
                              final String imageUrl = proj['image'] != null
                                  ? (proj['image'].toString().startsWith('http')
                                      ? proj['image'].toString()
                                      : 'https://clickfix.hafiztalha.com/storage/${proj['image']}')
                                  : '';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          height: 140,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                            image: imageUrl.isNotEmpty
                                                ? DecorationImage(
                                                    image: NetworkImage(imageUrl),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                          child: imageUrl.isEmpty
                                              ? Icon(
                                                  Icons.home_repair_service_rounded,
                                                  size: 48,
                                                  color: ClickFixTheme.primaryAmber.withOpacity(0.6),
                                                )
                                              : null,
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.black54,
                                            radius: 18,
                                            child: IconButton(
                                              icon: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 18),
                                              onPressed: () => _deletePortfolioItem(id),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            description,
                                            style: GoogleFonts.outfit(
                                              fontSize: 13,
                                              color: isDark ? Colors.white60 : ClickFixTheme.textMuted,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMiniStat(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, color: ClickFixTheme.primaryAmber),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, color: ClickFixTheme.textMuted),
        ),
      ],
    );
  }
}
