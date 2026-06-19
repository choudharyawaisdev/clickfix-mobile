import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/widgets/clickfix_logo.dart';
import 'package:clickfix/models/service_model.dart';
import 'package:clickfix/services/auth_service.dart';
import 'package:clickfix/screens/auth/login_screen.dart';

// Customer screens
import 'package:clickfix/screens/customer/index_screen.dart';
import 'package:clickfix/screens/customer/worker_services_screen.dart';
import 'package:clickfix/screens/customer/job_details_screen.dart';
import 'package:clickfix/screens/customer/bookings_index_screen.dart';
import 'package:clickfix/screens/customer/wishlist_index_screen.dart';
import 'package:clickfix/screens/customer/profile_details_screen.dart';
import 'package:clickfix/screens/customer/profile_edit_screen.dart';

// Worker screens
import 'package:clickfix/screens/worker/jobworker_index_screen.dart';
import 'package:clickfix/screens/worker/jobworker_create_screen.dart';
import 'package:clickfix/screens/worker/jobworker_edit_screen.dart';
import 'package:clickfix/screens/worker/portfolio_screen.dart';
import 'package:clickfix/screens/worker/bookings_screen.dart';
import 'package:clickfix/screens/worker/profile_details_screen.dart';
import 'package:clickfix/screens/worker/profile_edit_screen.dart';

// Admin screens
import 'package:clickfix/screens/admin/dashboard_screen.dart';
import 'package:clickfix/screens/admin/services_index_screen.dart';
import 'package:clickfix/screens/admin/blogs_index_screen.dart';
import 'package:clickfix/screens/admin/blogs_create_screen.dart';
import 'package:clickfix/screens/admin/blogs_edit_screen.dart';
import 'package:clickfix/screens/admin/workers_index_screen.dart';
import 'package:clickfix/screens/admin/reviews_index_screen.dart';
import 'package:clickfix/screens/admin/profile_edit_screen.dart';

// Tabs
import 'package:clickfix/screens/services_tab.dart';
import 'package:clickfix/screens/booking_screen.dart';
import 'package:clickfix/screens/support_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Tabs for the main Customer App shell
  final List<Widget> _tabs = [
    const CustomerIndexScreen(),
    const ServicesTab(),
    const BookingScreen(),
    const SupportTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Get current logged in user details
    final user = AuthService().currentUser;
    final displayName = user?.name ?? 'Guest User';
    final displayEmail = user?.email ?? 'guest@clickfix.com';
    final role = user?.role ?? 'Customer';
    final avatarColor = user?.avatarColor ?? Colors.amber;
    final city = (user?.city.isNotEmpty == true) ? user!.city : 'Faisalabad';

    return Scaffold(
      appBar: AppBar(
        title: const ClickFixLogo(
          vertical: false,
          iconSize: 32,
          fontSize: 18,
        ),
        actions: [
          // Elegant Drawer Trigger Button
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: ClickFixTheme.primaryAmber),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: 'Open Sidebar Menu',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: isDark ? Colors.white.withOpacity(0.08) : ClickFixTheme.borderGray,
            height: 1.0,
          ),
        ),
      ),
      // Drawer adaptively rendering relative items for roles
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: ClickFixTheme.primaryDark,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: avatarColor,
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
                ),
              ),
              accountName: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: ClickFixTheme.primaryAmber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      role,
                      style: GoogleFonts.outfit(color: ClickFixTheme.primaryAmber, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              accountEmail: Text(
                '$displayEmail • $city',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // DYNAMIC ROLE SIDEBAR MENUS
                  if (role == 'Customer') ...[
                    _buildDrawerHeader('CUSTOMER MENU', Colors.blue, isDark),
                    _buildDrawerItem(context, 'Home Index Feed', const CustomerIndexScreen(), Icons.home_rounded),
                    _buildDrawerItem(
                      context,
                      'Available Services',
                      const WorkerServicesScreen(serviceCategory: 'Maintenance'),
                      Icons.engineering_rounded,
                    ),
                    _buildDrawerItem(
                      context,
                      'Job Inclusions Details',
                      JobDetailsScreen(service: ServiceModel.services[0]),
                      Icons.info_outline_rounded,
                    ),
                    _buildDrawerItem(context, 'Track My Bookings', const BookingsIndexScreen(), Icons.calendar_month_rounded),
                    _buildDrawerItem(context, 'Saved Wishlist', const WishlistIndexScreen(), Icons.favorite_rounded),
                    _buildDrawerItem(context, 'View My Profile', const CustomerProfileDetailsScreen(), Icons.account_circle_rounded),
                    _buildDrawerItem(context, 'Edit Preferences', const CustomerProfileEditScreen(), Icons.edit_note_rounded),
                  ] else if (role == 'Worker') ...[
                    _buildDrawerHeader('WORKER MENU', Colors.teal, isDark),
                    _buildDrawerItem(context, 'Dashboard Hub', const WorkerJobworkerIndexScreen(), Icons.space_dashboard_rounded),
                    _buildDrawerItem(context, 'Offer New Skill Listing', const WorkerJobworkerCreateScreen(), Icons.add_box_rounded),
                    _buildDrawerItem(context, 'Edit Offered Rates', const WorkerJobworkerEditScreen(), Icons.edit_attributes_rounded),
                    _buildDrawerItem(context, 'Showcase Portfolio', const WorkerPortfolioScreen(), Icons.auto_stories_rounded),
                    _buildDrawerItem(context, 'Manage Active Bookings', const WorkerBookingsScreen(), Icons.assignment_rounded),
                    _buildDrawerItem(context, 'View Worker Profile', const WorkerProfileDetailsScreen(), Icons.contact_page_rounded),
                    _buildDrawerItem(context, 'Edit Skills Bio', const WorkerProfileEditScreen(), Icons.edit),
                  ] else if (role == 'Admin') ...[
                    _buildDrawerHeader('ADMIN MENU', Colors.deepOrange, isDark),
                    _buildDrawerItem(context, 'Control Panel Dashboard', const AdminDashboardScreen(), Icons.admin_panel_settings_rounded),
                    _buildDrawerItem(context, 'Configure Services DB', const AdminServicesIndexScreen(), Icons.settings_applications_rounded),
                    _buildDrawerItem(context, 'Platform Blogs Board', const AdminBlogsIndexScreen(), Icons.rss_feed_rounded),
                    _buildDrawerItem(context, 'Compose New Article', const AdminBlogsCreateScreen(), Icons.post_add_rounded),
                    _buildDrawerItem(context, 'Modify Draft Blog', const AdminBlogsEditScreen(), Icons.edit_note_rounded),
                    _buildDrawerItem(context, 'Moderate Registered Pros', const AdminWorkersIndexScreen(), Icons.badge_rounded),
                    _buildDrawerItem(context, 'Approve & Moderate Reviews', const AdminReviewsIndexScreen(), Icons.rate_review_rounded),
                    _buildDrawerItem(context, 'Edit Admin Details', const AdminProfileEditScreen(), Icons.manage_accounts_rounded),
                  ],
                  const Divider(height: 24),
                  
                  // Logout Button
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                    title: Text(
                      'Logout Session',
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                    dense: true,
                    onTap: () {
                      AuthService().logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: isDark ? ClickFixTheme.primaryDark : Colors.white,
          indicatorColor: ClickFixTheme.primaryAmber.withOpacity(0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: ClickFixTheme.primaryAmber),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.category_outlined),
              selectedIcon: Icon(Icons.category_rounded, color: ClickFixTheme.primaryAmber),
              label: 'Services',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded, color: ClickFixTheme.primaryAmber),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: Icon(Icons.support_agent_outlined),
              selectedIcon: Icon(Icons.support_agent_rounded, color: ClickFixTheme.primaryAmber),
              label: 'Support',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(String title, Color accentColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white54 : ClickFixTheme.textMuted,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String name, Widget screen, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: ClickFixTheme.primaryAmber, size: 20),
      title: Text(
        name,
        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      dense: true,
      onTap: () {
        Navigator.pop(context); // Close the drawer
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }
}
