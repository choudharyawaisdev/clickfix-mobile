import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';

class AdminWorkersIndexScreen extends StatefulWidget {
  const AdminWorkersIndexScreen({super.key});

  @override
  State<AdminWorkersIndexScreen> createState() => _AdminWorkersIndexScreenState();
}

class _AdminWorkersIndexScreenState extends State<AdminWorkersIndexScreen> {
  final List<Map<String, dynamic>> _dummyWorkersList = [
    {
      'name': 'Hafiz Muhammad Talha',
      'skill': 'AC Repair & Electrical',
      'status': 'Verified',
      'city': 'Faisalabad',
      'jobs': 142,
    },
    {
      'name': 'Awais Choudhary',
      'skill': 'Plumbing Specialist',
      'status': 'Verified',
      'city': 'Karachi',
      'jobs': 98,
    },
    {
      'name': 'Zahid Mahmood',
      'skill': 'Carpentry Expert',
      'status': 'Pending Approval',
      'city': 'Lahore',
      'jobs': 0,
    },
    {
      'name': 'Imran Khan',
      'skill': 'IT Network Support',
      'status': 'Suspended',
      'city': 'Islamabad',
      'jobs': 56,
    }
  ];

  void _verifyWorker(int index) {
    setState(() {
      _dummyWorkersList[index]['status'] = 'Verified';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Worker status updated: Verified'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _suspendWorker(int index) {
    setState(() {
      _dummyWorkersList[index]['status'] = 'Suspended';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Worker suspended'),
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
          'Manage Workers',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _dummyWorkersList.length,
        itemBuilder: (context, index) {
          final worker = _dummyWorkersList[index];
          final status = worker['status'] as String;
          Color statusColor;

          switch (status) {
            case 'Verified':
              statusColor = Colors.green;
              break;
            case 'Suspended':
              statusColor = Colors.redAccent;
              break;
            default:
              statusColor = Colors.amber.shade700;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: ClickFixTheme.primaryAmber.withOpacity(0.12),
                        child: Text(
                          worker['name'][0],
                          style: const TextStyle(fontWeight: FontWeight.bold, color: ClickFixTheme.primaryAmber, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              worker['name'] as String,
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${worker['skill']} • ${worker['city']}',
                              style: TextStyle(color: ClickFixTheme.textMuted, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Jobs Completed: ${worker['jobs']}',
                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: GoogleFonts.outfit(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (status == 'Pending Approval')
                        ElevatedButton.icon(
                          onPressed: () => _verifyWorker(index),
                          icon: const Icon(Icons.verified_rounded, size: 14),
                          label: const Text('Approve Pro'),
                        ),
                      if (status == 'Verified')
                        OutlinedButton.icon(
                          onPressed: () => _suspendWorker(index),
                          icon: const Icon(Icons.block_rounded, size: 14),
                          label: const Text('Suspend'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                          ),
                        ),
                      if (status == 'Suspended')
                        ElevatedButton.icon(
                          onPressed: () => _verifyWorker(index),
                          icon: const Icon(Icons.settings_backup_restore_rounded, size: 14),
                          label: const Text('Activate Account'),
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
