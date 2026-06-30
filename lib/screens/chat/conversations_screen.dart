import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/services/api_service.dart';
import 'package:clickfix/services/auth_service.dart';
import 'package:clickfix/screens/chat/chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  List<dynamic> _conversations = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearchingUsers = false;
  String? _searchError;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (query.trim().isEmpty) {
        setState(() {
          _searchResults.clear();
          _isSearchingUsers = false;
          _searchError = null;
        });
      } else {
        _searchUsers(query.trim());
      }
    });
  }

  Future<void> _searchUsers(String query) async {
    setState(() {
      _isSearchingUsers = true;
      _searchError = null;
    });

    try {
      final response = await ApiService().searchUsersForChat(query);
      if (response['status'] == true && response.containsKey('data')) {
        setState(() {
          _searchResults = response['data'] as List? ?? [];
          _isSearchingUsers = false;
        });
      } else {
        setState(() {
          _searchError = response['message'] ?? 'Failed to search users';
          _isSearchingUsers = false;
        });
      }
    } catch (e) {
      setState(() {
        _searchError = 'Error: $e';
        _isSearchingUsers = false;
      });
    }
  }

  Future<void> _loadConversations() async {
    if (!mounted) return;
    setState(() {
      _isLoading = _conversations.isEmpty; // Only show main loader if list is empty
      _errorMessage = null;
    });

    try {
      final response = await ApiService().getChatConversations();
      if (response['status'] == true && response.containsKey('data')) {
        setState(() {
          _conversations = response['data'] as List? ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load conversations.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  String _formatTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      final now = DateTime.now();
      
      if (dateTime.day == now.day && dateTime.month == now.month && dateTime.year == now.year) {
        // Formats as HH:MM
        final hour = dateTime.hour.toString().padLeft(2, '0');
        final minute = dateTime.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      } else {
        // Formats as Day/Month
        return '${dateTime.day}/${dateTime.month}';
      }
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // 🔍 Premium Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: GoogleFonts.outfit(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search people to start chat...',
                prefixIcon: const Icon(Icons.search_rounded, color: ClickFixTheme.primaryAmber),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: ClickFixTheme.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                filled: true,
                fillColor: isDark ? const Color(0xFF2C3034) : ClickFixTheme.primaryLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: _buildBodyContent(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(bool isDark) {
    if (_searchController.text.trim().isNotEmpty) {
      return _buildSearchResults(isDark);
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent.withOpacity(0.8)),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 14, color: ClickFixTheme.textMuted),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadConversations,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      color: ClickFixTheme.primaryAmber,
      child: _conversations.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.forum_outlined, size: 64, color: ClickFixTheme.textMuted.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      Text(
                        'No conversations yet',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Messages with clients and pros will appear here.',
                        style: GoogleFonts.outfit(fontSize: 12, color: ClickFixTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _conversations.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 76,
                endIndent: 16,
                color: isDark ? Colors.white.withOpacity(0.06) : ClickFixTheme.borderGray,
              ),
              itemBuilder: (context, index) {
                final conv = _conversations[index];
                final contactUser = conv['user'] ?? {};
                final lastMsg = conv['last_message'] ?? {};
                
                final String name = contactUser['name'] ?? 'User';
                final int contactId = contactUser['id'] ?? 0;
                final String lastMsgBody = lastMsg['body'] ?? (lastMsg['attachment'] != null ? 'Shared an attachment' : 'Empty message');
                final int unreadCount = conv['unread_count'] ?? 0;
                final String timeStr = _formatTime(lastMsg['created_at']);

                final List<Color> avatarColors = [
                  Colors.teal,
                  Colors.blue,
                  Colors.orange,
                  Colors.purple,
                  Colors.pink,
                  Colors.indigo,
                ];
                final avatarColor = avatarColors[contactId % avatarColors.length];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: avatarColor,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: unreadCount > 0 ? ClickFixTheme.primaryAmber : ClickFixTheme.textMuted,
                          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            lastMsgBody,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: unreadCount > 0
                                  ? (isDark ? Colors.white : ClickFixTheme.textDark)
                                  : ClickFixTheme.textMuted,
                              fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: ClickFixTheme.primaryAmber,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: GoogleFonts.outfit(
                                color: ClickFixTheme.primaryDark,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          receiverId: contactId,
                          receiverName: name,
                        ),
                      ),
                    );
                    _loadConversations();
                  },
                );
              },
            ),
    );
  }

  Widget _buildSearchResults(bool isDark) {
    if (_isSearchingUsers) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
          ),
        ),
      );
    }

    if (_searchError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _searchError!,
            style: GoogleFonts.outfit(color: ClickFixTheme.textMuted),
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_search_rounded, size: 48, color: ClickFixTheme.textMuted.withOpacity(0.4)),
              const SizedBox(height: 12),
              Text(
                'No users found matching "${_searchController.text}"',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 14, color: ClickFixTheme.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        indent: 76,
        endIndent: 16,
        color: isDark ? Colors.white.withOpacity(0.06) : ClickFixTheme.borderGray,
      ),
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        final String name = user['name'] ?? 'User';
        final int id = user['id'] ?? 0;
        final String role = (user['role'] ?? 'user').toString().toUpperCase();

        final List<Color> avatarColors = [
          Colors.teal,
          Colors.blue,
          Colors.orange,
          Colors.purple,
          Colors.pink,
          Colors.indigo,
        ];
        final avatarColor = avatarColors[id % avatarColors.length];

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: avatarColor,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          title: Text(
            name,
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              role,
              style: GoogleFonts.outfit(fontSize: 11, color: ClickFixTheme.primaryAmber, fontWeight: FontWeight.w600),
            ),
          ),
          onTap: () async {
            final receiverId = id;
            final receiverName = name;
            _searchController.clear();
            _onSearchChanged('');
            
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  receiverId: receiverId,
                  receiverName: receiverName,
                ),
              ),
            );
            _loadConversations();
          },
        );
      },
    );
  }
}
