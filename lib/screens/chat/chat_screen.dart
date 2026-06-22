import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/services/api_service.dart';
import 'package:clickfix/services/auth_service.dart';

class ChatScreen extends StatefulWidget {
  final int receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<dynamic> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;
  
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  
  Timer? _pollingTimer;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _markMessagesAsSeen();
    // Poll for new messages every 5 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _pollNewMessages());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await ApiService().getChatMessageHistory(widget.receiverId);
      if (response['status'] == true && response.containsKey('data')) {
        setState(() {
          _messages.clear();
          _messages.addAll(response['data'] as List? ?? []);
          _isLoading = false;
        });
        _scrollToBottom();
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load messages.';
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

  Future<void> _pollNewMessages() async {
    try {
      final response = await ApiService().getChatMessageHistory(widget.receiverId);
      if (response['status'] == true && response.containsKey('data')) {
        final newMsgs = response['data'] as List? ?? [];
        if (newMsgs.length != _messages.length) {
          setState(() {
            _messages.clear();
            _messages.addAll(newMsgs);
          });
          _scrollToBottom();
          _markMessagesAsSeen();
        }
      }
    } catch (_) {
      // Fail silently during background polling
    }
  }

  Future<void> _markMessagesAsSeen() async {
    try {
      // Trigger makeSeen endpoint if it exists
      await ApiService().makeMessagesSeen(widget.receiverId);
    } catch (_) {}
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
        // Prompt confirmation dialog
        _showImageConfirmDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showImageConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Send Image', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Send this image to ${widget.receiverName}?', style: GoogleFonts.outfit()),
              const SizedBox(height: 12),
              Icon(Icons.image_outlined, size: 64, color: ClickFixTheme.primaryAmber.withOpacity(0.8)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                });
                Navigator.pop(context);
              },
              child: Text('Cancel', style: GoogleFonts.outfit(color: ClickFixTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _sendMessage(attachmentPath: _selectedImage?.path);
              },
              child: Text('Send', style: GoogleFonts.outfit()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendMessage({String? attachmentPath}) async {
    final String body = _messageController.text.trim();
    
    if (body.isEmpty && attachmentPath == null) return;

    setState(() {
      _isSending = true;
    });

    try {
      // Clear input quickly
      _messageController.clear();
      
      final response = await ApiService().sendChatMessageNew(
        toId: widget.receiverId,
        body: body.isNotEmpty ? body : null,
        attachmentPath: attachmentPath,
      );

      if (response['status'] == true) {
        setState(() {
          _selectedImage = null;
        });
        _fetchMessages();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to send message'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  String _formatMessageTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final int currentUserId = AuthService().currentUser?.id ?? 0;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: ClickFixTheme.primaryAmber.withOpacity(0.2),
              child: Text(
                widget.receiverName.isNotEmpty ? widget.receiverName[0].toUpperCase() : 'U',
                style: GoogleFonts.outfit(color: ClickFixTheme.primaryAmber, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName,
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Active session',
                    style: GoogleFonts.outfit(fontSize: 10, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: ClickFixTheme.textMuted),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final int fromId = msg['from_id'] ?? 0;
                          final bool isMe = fromId == currentUserId;
                          final String body = msg['body'] ?? '';
                          final String time = _formatMessageTime(msg['created_at']);
                          final String? attachment = msg['attachment'];

                          return _buildMessageBubble(body, time, isMe, attachment, isDark);
                        },
                      ),
          ),
          
          // Send Loader Indicator
          if (_isSending)
            const LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ClickFixTheme.primaryAmber),
              backgroundColor: Colors.transparent,
              minHeight: 2,
            ),
          
          // Bottom Message Input
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
            decoration: BoxDecoration(
              color: isDark ? ClickFixTheme.primaryDark : Colors.white,
              border: Border(
                top: BorderSide(color: isDark ? Colors.white10 : ClickFixTheme.borderGray),
              ),
            ),
            child: Row(
              children: [
                // File/Attachment Button
                IconButton(
                  icon: const Icon(Icons.add_photo_alternate_outlined, color: ClickFixTheme.primaryAmber),
                  onPressed: _pickImage,
                  tooltip: 'Attach Image',
                ),
                
                // Input Field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: GoogleFonts.outfit(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2C3034) : ClickFixTheme.primaryLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Send Button
                CircleAvatar(
                  backgroundColor: ClickFixTheme.primaryAmber,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: ClickFixTheme.primaryDark, size: 18),
                    onPressed: () => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String body, String time, bool isMe, String? attachment, bool isDark) {
    // Bubble design system alignment
    final Color bg = isMe
        ? ClickFixTheme.primaryAmber
        : (isDark ? const Color(0xFF2C3034) : Colors.grey.shade200);
    final Color textCol = isMe
        ? ClickFixTheme.primaryDark
        : (isDark ? Colors.white : ClickFixTheme.textDark);
    final Color timeCol = isMe
        ? ClickFixTheme.primaryDark.withOpacity(0.6)
        : ClickFixTheme.textMuted;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Attachment rendering
            if (attachment != null && attachment.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  // Resolve domain links properly
                  attachment.startsWith('http') ? attachment : 'https://clickfix.hafiztalha.com/storage/$attachment',
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.black.withOpacity(0.05),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.image_not_supported_rounded, color: Colors.grey, size: 16),
                        const SizedBox(width: 6),
                        Text('Attachment failed', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
            
            if (body.isNotEmpty)
              Text(
                body,
                style: GoogleFonts.outfit(fontSize: 13, color: textCol),
              ),
            const SizedBox(height: 4),
            
            // Time Indicator
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: GoogleFonts.outfit(fontSize: 9, color: timeCol, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
