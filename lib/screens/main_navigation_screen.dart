import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:url_launcher/url_launcher.dart';
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
import 'package:clickfix/screens/customer/my_posted_jobs_screen.dart';
import 'package:clickfix/screens/customer/post_job_screen.dart';

// Worker screens
import 'package:clickfix/screens/worker/jobworker_index_screen.dart';
import 'package:clickfix/screens/worker/jobworker_create_screen.dart';
import 'package:clickfix/screens/worker/jobworker_edit_screen.dart';
import 'package:clickfix/screens/worker/portfolio_screen.dart';
import 'package:clickfix/screens/worker/bookings_screen.dart';
import 'package:clickfix/screens/worker/profile_details_screen.dart';
import 'package:clickfix/screens/worker/profile_edit_screen.dart';
import 'package:clickfix/screens/worker/customer_jobs_feed_screen.dart';

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
import 'package:clickfix/screens/chat/conversations_screen.dart';
import 'package:clickfix/screens/customer/notification_screen.dart';

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

  Future<void> _handleRoleSwitch(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
        ),
      ),
    );

    final success = await AuthService().switchRole();
    
    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.swap_horiz_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text('Switched to ${AuthService().currentUser?.role.toUpperCase()} Mode!'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to switch role. Please try again.'),
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

    // Get current logged in user details
    final user = AuthService().currentUser;
    final displayName = user?.name ?? 'Guest User';
    final displayEmail = user?.email ?? 'guest@clickfix.com';
    final role = (user?.role ?? 'customer').toLowerCase();
    final displayRole = role.isNotEmpty ? (role[0].toUpperCase() + role.substring(1)) : 'Customer';
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
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
                      displayRole,
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
            
            // Dynamic Switch Role Card
            if (role == 'customer' || role == 'worker')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  elevation: 0,
                  color: ClickFixTheme.primaryAmber.withOpacity(0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: ClickFixTheme.primaryAmber.withOpacity(0.3), width: 1.5),
                  ),
                  child: InkWell(
                    onTap: () => _handleRoleSwitch(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                      child: Row(
                        children: [
                          Icon(
                            role == 'customer' ? Icons.engineering_rounded : Icons.person_rounded,
                            color: ClickFixTheme.primaryAmber,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  role == 'customer' ? 'Switch to Worker Mode' : 'Switch to Customer Mode',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isDark ? Colors.white : ClickFixTheme.textDark,
                                  ),
                                ),
                                Text(
                                  role == 'customer' ? 'Offer services & bid on jobs' : 'Post jobs & book services',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    color: ClickFixTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.swap_horiz_rounded,
                            color: ClickFixTheme.primaryAmber,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  // DYNAMIC ROLE SIDEBAR MENUS
                  if (role == 'customer') ...[
                    _buildDrawerHeader('CUSTOMER MENU', Colors.blue, isDark),
                    _buildDrawerItem(context, 'Home Index Feed', CustomerIndexScreen(), Icons.home_rounded),
                    _buildDrawerItem(
                      context,
                      'Available Services',
                      WorkerServicesScreen(serviceCategory: 'Maintenance'),
                      Icons.engineering_rounded,
                    ),
                    _buildDrawerItem(context, 'Post a Job', PostJobScreen(), Icons.add_circle_outline_rounded),
                    _buildDrawerItem(context, 'My Posted Jobs & Bids', MyPostedJobsScreen(), Icons.gavel_rounded),
                    _buildDrawerItem(context, 'Track My Bookings', BookingsIndexScreen(), Icons.calendar_month_rounded),
                    _buildDrawerItem(context, 'Chat Inbox', ConversationsScreen(), Icons.forum_rounded),
                    _buildDrawerItem(context, 'Saved Wishlist', WishlistIndexScreen(), Icons.favorite_rounded),
                    _buildDrawerItem(context, 'View My Profile', CustomerProfileDetailsScreen(), Icons.account_circle_rounded),
                    _buildDrawerItem(context, 'Edit Preferences', CustomerProfileEditScreen(), Icons.edit_note_rounded),
                  ] else if (role == 'worker') ...[
                    _buildDrawerHeader('WORKER MENU', Colors.teal, isDark),
                    _buildDrawerItem(context, 'Dashboard Hub', WorkerJobworkerIndexScreen(), Icons.space_dashboard_rounded),
                    _buildDrawerItem(context, 'Customer Jobs Feed', CustomerJobsFeedScreen(), Icons.gavel_rounded),
                    _buildDrawerItem(context, 'Offer New Skill Listing', WorkerJobworkerCreateScreen(), Icons.add_box_rounded),
                    _buildDrawerItem(context, 'Edit Offered Rates', WorkerJobworkerEditScreen(), Icons.edit_attributes_rounded),
                    _buildDrawerItem(context, 'Showcase Portfolio', WorkerPortfolioScreen(), Icons.auto_stories_rounded),
                    _buildDrawerItem(context, 'Manage Active Bookings', WorkerBookingsScreen(), Icons.assignment_rounded),
                    _buildDrawerItem(context, 'Chat Inbox', ConversationsScreen(), Icons.forum_rounded),
                    _buildDrawerItem(context, 'View Worker Profile', WorkerProfileDetailsScreen(), Icons.contact_page_rounded),
                    _buildDrawerItem(context, 'Edit Skills Bio', WorkerProfileEditScreen(), Icons.edit),
                  ] else if (role == 'admin') ...[
                    _buildDrawerHeader('ADMIN MENU', Colors.deepOrange, isDark),
                    _buildDrawerItem(context, 'Control Panel Dashboard', AdminDashboardScreen(), Icons.admin_panel_settings_rounded),
                    _buildDrawerItem(context, 'Configure Services DB', AdminServicesIndexScreen(), Icons.settings_applications_rounded),
                    _buildDrawerItem(context, 'Platform Blogs Board', AdminBlogsIndexScreen(), Icons.rss_feed_rounded),
                    _buildDrawerItem(context, 'Compose New Article', AdminBlogsCreateScreen(), Icons.post_add_rounded),
                    _buildDrawerItem(context, 'Modify Draft Blog', AdminBlogsEditScreen(), Icons.edit_note_rounded),
                    _buildDrawerItem(context, 'Moderate Registered Pros', AdminWorkersIndexScreen(), Icons.badge_rounded),
                    _buildDrawerItem(context, 'Approve & Moderate Reviews', AdminReviewsIndexScreen(), Icons.rate_review_rounded),
                    _buildDrawerItem(context, 'Edit Admin Details', AdminProfileEditScreen(), Icons.manage_accounts_rounded),
                  ],
                  const Divider(height: 24),
                  
                  // Privacy Policy Button
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_rounded, color: ClickFixTheme.primaryAmber, size: 20),
                    title: Text(
                      'Privacy Policy',
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    dense: true,
                    onTap: () async {
                      final uri = Uri.parse('https://clickfix.hafiztalha.com/privacy-policy');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not open Privacy Policy link.')),
                          );
                        }
                      }
                    },
                  ),

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
