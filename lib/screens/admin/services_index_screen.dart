import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/models/service_model.dart';

class AdminServicesIndexScreen extends StatefulWidget {
  const AdminServicesIndexScreen({super.key});

  @override
  State<AdminServicesIndexScreen> createState() => _AdminServicesIndexScreenState();
}

class _AdminServicesIndexScreenState extends State<AdminServicesIndexScreen> {
  final List<ServiceModel> _services = List.from(ServiceModel.services);
  final Map<String, bool> _activeStatuses = {};

  @override
  void initState() {
    super.initState();
    // Default all services to active
    for (var s in _services) {
      _activeStatuses[s.id] = true;
    }
  }

  void _toggleService(String id, bool active) {
    setState(() {
      _activeStatuses[id] = active;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Service status updated: ${active ? "Active" : "Inactive"}'),
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
          'Manage Core Services',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Creating a new global service...')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          final isActive = _activeStatuses[service.id] ?? true;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(service.iconData, color: ClickFixTheme.primaryAmber),
              ),
              title: Text(
                service.title,
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Category: ${service.category}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    'Rs. ${service.basePrice.toStringAsFixed(0)} Base Cost',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber, fontSize: 13),
                  ),
                ],
              ),
              trailing: Switch(
                value: isActive,
                activeColor: ClickFixTheme.primaryAmber,
                onChanged: (val) => _toggleService(service.id, val),
              ),
            ),
          );
        },
      ),
    );
  }
}
