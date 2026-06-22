import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String baseUrl = 'https://clickfix.hafiztalha.com/api';
  
  // Bearer authentication token stored in memory
  String? token;

  // Set the Bearer token
  void setToken(String? newToken) {
    token = newToken;
  }

  // Generate request headers
  Map<String, String> get headers {
    final Map<String, String> headersMap = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headersMap['Authorization'] = 'Bearer $token';
    }
    return headersMap;
  }

  // Generate request headers for Multipart requests (no Content-Type specified manually)
  Map<String, String> get multipartHeaders {
    final Map<String, String> headersMap = {
      'Accept': 'application/json',
    };
    if (token != null) {
      headersMap['Authorization'] = 'Bearer $token';
    }
    return headersMap;
  }

  // ── 1. Authentication APIs ──────────────────────────────────────────────

  /// POST /api/register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String city,
    required String role,
    int? serviceId,
    required String password,
    required String passwordConfirmation,
    String? profilePicturePath,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/register');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(multipartHeaders);

      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['phone_number'] = phoneNumber;
      request.fields['city'] = city;
      request.fields['role'] = role.toLowerCase();
      if (role.toLowerCase() == 'worker' && serviceId != null) {
        request.fields['service_id'] = serviceId.toString();
      }
      request.fields['password'] = password;
      request.fields['password_confirmation'] = passwordConfirmation;

      if (profilePicturePath != null && profilePicturePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('profile_picture', profilePicturePath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      final result = _handleResponse(response);
      if (result['status'] == true && result.containsKey('data')) {
        final data = result['data'];
        if (data is Map && data.containsKey('access_token')) {
          token = data['access_token'];
        } else if (result.containsKey('access_token')) {
          token = result['access_token'];
        }
      }
      return result;
    } catch (e) {
      return {'status': false, 'message': 'Registration request failed: $e'};
    }
  }

  /// POST /api/login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final result = _handleResponse(response);
      if (result['status'] == true) {
        if (result.containsKey('access_token')) {
          token = result['access_token'];
        } else if (result.containsKey('data') && result['data'] is Map && result['data'].containsKey('access_token')) {
          token = result['data']['access_token'];
        }
      }
      return result;
    } catch (e) {
      return {'status': false, 'message': 'Login request failed: $e'};
    }
  }

  /// POST /api/logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: headers,
      );
      
      final result = _handleResponse(response);
      token = null;
      return result;
    } catch (e) {
      token = null;
      return {'status': false, 'message': 'Logout request failed: $e'};
    }
  }

  // ── 2. Profile Management APIs ──────────────────────────────────────────

  /// GET /api/profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch profile: $e'};
    }
  }

  /// POST /api/profile/update
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? phoneNumber,
    String? city,
    String? password,
    String? passwordConfirmation,
    int? serviceId,
    String? description,
    String? profilePicturePath,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/profile/update');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(multipartHeaders);

      request.fields['name'] = name;
      request.fields['email'] = email;
      if (phoneNumber != null) request.fields['phone_number'] = phoneNumber;
      if (city != null) request.fields['city'] = city;
      if (password != null) request.fields['password'] = password;
      if (passwordConfirmation != null) request.fields['password_confirmation'] = passwordConfirmation;
      if (serviceId != null) request.fields['service_id'] = serviceId.toString();
      if (description != null) request.fields['description'] = description;

      if (profilePicturePath != null && profilePicturePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('profile_picture', profilePicturePath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to update profile: $e'};
    }
  }

  /// POST /api/switch-role
  Future<Map<String, dynamic>> switchRole() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/switch-role'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to switch role: $e'};
    }
  }

  // ── 3. Public Services & Jobs APIs ──────────────────────────────────────

  /// GET /api/services
  Future<Map<String, dynamic>> getServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch services: $e'};
    }
  }

  /// GET /api/jobs
  Future<Map<String, dynamic>> getJobs({String? category, String? city}) async {
    try {
      String query = '';
      if (category != null && city != null) {
        query = '?category=${Uri.encodeComponent(category)}&city=${Uri.encodeComponent(city)}';
      } else if (category != null) {
        query = '?category=${Uri.encodeComponent(category)}';
      } else if (city != null) {
        query = '?city=${Uri.encodeComponent(city)}';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/jobs$query'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch jobs: $e'};
    }
  }

  /// GET /api/jobs/{id}
  Future<Map<String, dynamic>> getJobDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jobs/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch job details: $e'};
    }
  }

  // ── 4. Protected Bookings & Reviews APIs ────────────────────────────────

  /// POST /api/bookings
  Future<Map<String, dynamic>> createBooking({
    required int workerId,
    required int serviceId,
    required String bookingDate,
    required String bookingTime,
    required String address,
    String? message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: headers,
        body: json.encode({
          'worker_id': workerId,
          'service_id': serviceId,
          'booking_date': bookingDate,
          'booking_time': bookingTime,
          'address': address,
          if (message != null) 'message': message,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to create booking: $e'};
    }
  }

  /// GET /api/my-bookings
  Future<Map<String, dynamic>> getMyBookings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my-bookings'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch bookings: $e'};
    }
  }

  /// PATCH /api/bookings/{id}/status
  Future<Map<String, dynamic>> updateBookingStatus(int id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/bookings/$id/status'),
        headers: headers,
        body: json.encode({
          'status': status.toLowerCase(),
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to update booking status: $e'};
    }
  }

  /// POST /api/reviews
  Future<Map<String, dynamic>> submitReview({
    required int workerId,
    required int bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: headers,
        body: json.encode({
          'worker_id': workerId,
          'booking_id': bookingId,
          'rating': rating,
          if (comment != null) 'comment': comment,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to submit review: $e'};
    }
  }

  // ── 5. Wishlist APIs ────────────────────────────────────────────────────

  /// POST /api/wishlist/toggle
  Future<Map<String, dynamic>> toggleWishlist(int workerId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wishlist/toggle'),
        headers: headers,
        body: json.encode({
          'worker_id': workerId,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to toggle wishlist: $e'};
    }
  }

  /// GET /api/wishlist
  Future<Map<String, dynamic>> getWishlist() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wishlist'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch wishlist: $e'};
    }
  }

  // ── 6. Public Blogs APIs ────────────────────────────────────────────────

  /// GET /api/blogs
  Future<Map<String, dynamic>> getBlogs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/blogs'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch blogs: $e'};
    }
  }

  /// GET /api/blogs/{slug}
  Future<Map<String, dynamic>> getBlogDetails(String slug) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/blogs/$slug'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch blog details: $e'};
    }
  }

  // ── 2.3 Online Status Toggle (Worker Only) ──
  /// POST /api/profile/toggle-online-status
  Future<Map<String, dynamic>> toggleWorkerOnlineStatus() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile/toggle-online-status'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to toggle online status: $e'};
    }
  }

  // ── 4. Worker Jobs API ──
  /// GET /api/worker/jobs
  Future<Map<String, dynamic>> getMyJobs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/worker/jobs'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch my jobs: $e'};
    }
  }

  /// POST /api/worker/jobs
  Future<Map<String, dynamic>> storeJob({
    required String title,
    required int serviceId,
    required double price,
    required String location,
    required String description,
    String? imagePath,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/worker/jobs');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.fields['title'] = title;
      request.fields['service_id'] = serviceId.toString();
      request.fields['price'] = price.toString();
      request.fields['location'] = location;
      request.fields['description'] = description;

      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to store job: $e'};
    }
  }

  /// POST /api/worker/jobs/{id}
  Future<Map<String, dynamic>> updateJob({
    required int id,
    required String title,
    required int serviceId,
    required double price,
    required String location,
    required String description,
    String? imagePath,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/worker/jobs/$id');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.fields['title'] = title;
      request.fields['service_id'] = serviceId.toString();
      request.fields['price'] = price.toString();
      request.fields['location'] = location;
      request.fields['description'] = description;

      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to update job: $e'};
    }
  }

  /// DELETE /api/worker/jobs/{id}
  Future<Map<String, dynamic>> destroyJob(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/worker/jobs/$id'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to delete job: $e'};
    }
  }

  // ── 4.5 Worker Portfolio API ──
  /// GET /api/worker/portfolio
  Future<Map<String, dynamic>> getPortfolio() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/worker/portfolio'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch portfolio: $e'};
    }
  }

  /// POST /api/worker/portfolio
  Future<Map<String, dynamic>> storePortfolio({
    required String imagePath,
    String? title,
    String? description,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/worker/portfolio');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      if (title != null) request.fields['title'] = title;
      if (description != null) request.fields['description'] = description;
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to store portfolio item: $e'};
    }
  }

  /// POST /api/worker/portfolio/{id}
  Future<Map<String, dynamic>> updatePortfolio({
    required int id,
    String? imagePath,
    String? title,
    String? description,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/worker/portfolio/$id');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      if (title != null) request.fields['title'] = title;
      if (description != null) request.fields['description'] = description;
      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to update portfolio item: $e'};
    }
  }

  /// DELETE /api/worker/portfolio/{id}
  Future<Map<String, dynamic>> destroyPortfolio(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/worker/portfolio/$id'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to delete portfolio item: $e'};
    }
  }

  // ── 8. Admin APIs ──
  /// PATCH /api/admin/users/{id}/status
  Future<Map<String, dynamic>> adminUpdateUserStatus({
    required int userId,
    required String accountStatus,
    String? proIcon,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/users/$userId/status'),
        headers: headers,
        body: json.encode({
          'account_status': accountStatus.toLowerCase(),
          if (proIcon != null) 'pro_icon': proIcon.toLowerCase(),
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to update user status: $e'};
    }
  }

  // ── 9. Chat / Messenger APIs ──
  /// POST /api/chat/auth
  Future<Map<String, dynamic>> chatAuth({required String socketId, required String channelName}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/auth'),
        headers: headers,
        body: json.encode({
          'socket_id': socketId,
          'channel_name': channelName,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Chat auth failed: $e'};
    }
  }

  /// POST /api/idInfo
  Future<Map<String, dynamic>> getChatIdInfo(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/idInfo'),
        headers: headers,
        body: json.encode({'id': id}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch contact details: $e'};
    }
  }

  /// POST /api/sendMessage
  Future<Map<String, dynamic>> sendChatMessage({
    required int id,
    String? message,
    String? filePath,
    required String temporaryMsgId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/sendMessage');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.fields['id'] = id.toString();
      request.fields['temporaryMsgId'] = temporaryMsgId;
      if (message != null) request.fields['message'] = message;

      if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath('file', filePath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to send message: $e'};
    }
  }

  /// POST /api/fetchMessages
  Future<Map<String, dynamic>> fetchChatMessages(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fetchMessages'),
        headers: headers,
        body: json.encode({'id': id}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch chat messages: $e'};
    }
  }

  /// POST /api/makeSeen
  Future<Map<String, dynamic>> makeMessagesSeen(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/makeSeen'),
        headers: headers,
        body: json.encode({'id': id}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to mark messages as seen: $e'};
    }
  }

  /// GET /api/getContacts
  Future<Map<String, dynamic>> getChatContacts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getContacts'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch chat contacts: $e'};
    }
  }

  /// POST /api/star
  Future<Map<String, dynamic>> toggleFavoriteContact(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/star'),
        headers: headers,
        body: json.encode({'id': id}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to toggle favorite: $e'};
    }
  }

  /// POST /api/favorites
  Future<Map<String, dynamic>> getFavoriteContacts() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/favorites'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch favorites: $e'};
    }
  }

  /// GET /api/search
  Future<Map<String, dynamic>> searchChat(String input) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?input=${Uri.encodeComponent(input)}'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Search request failed: $e'};
    }
  }

  /// POST /api/shared
  Future<Map<String, dynamic>> getSharedPhotos(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/shared'),
        headers: headers,
        body: json.encode({'id': id}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch shared photos: $e'};
    }
  }

  /// POST /api/deleteConversation
  Future<Map<String, dynamic>> deleteChatConversation(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/deleteConversation'),
        headers: headers,
        body: json.encode({'id': id}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to delete conversation: $e'};
    }
  }

  /// POST /api/updateSettings
  Future<Map<String, dynamic>> updateChatAvatar(String avatarPath) async {
    try {
      final uri = Uri.parse('$baseUrl/updateSettings');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath('avatar', avatarPath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to update chat avatar: $e'};
    }
  }

  /// POST /api/setActiveStatus
  Future<Map<String, dynamic>> setChatActiveStatus(int status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/setActiveStatus'),
        headers: headers,
        body: json.encode({'status': status}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to set active status: $e'};
    }
  }

  // ── 9. New Chat / Messenger APIs (REST API Directory Flow) ─────────────────

  /// GET /api/chat/conversations
  Future<Map<String, dynamic>> getChatConversations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/conversations'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch conversations: $e'};
    }
  }

  /// GET /api/chat/messages/{user_id}
  Future<Map<String, dynamic>> getChatMessageHistory(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/messages/$userId'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch message history: $e'};
    }
  }

  /// POST /api/chat/send
  Future<Map<String, dynamic>> sendChatMessageNew({
    required int toId,
    String? body,
    String? attachmentPath,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/chat/send');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(multipartHeaders);

      request.fields['to_id'] = toId.toString();
      if (body != null) {
        request.fields['body'] = body;
      }

      if (attachmentPath != null && attachmentPath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('attachment', attachmentPath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to send chat message: $e'};
    }
  }

  // ── 10. Live Notification Center ─────────────────────────────────────────

  /// GET /api/notifications
  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Failed to retrieve notifications: $e'};
    }
  }

  // ── 11. Mock Customer Job Posting & Bidding APIs ─────────────────────────

  /// POST /api/customer/jobs (Mocked via SharedPreferences)
  Future<Map<String, dynamic>> postCustomerJob({
    required String title,
    required String description,
    required double budget,
    required String category,
    required String location,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jobsStr = prefs.getString('mock_customer_jobs') ?? '[]';
      final List<dynamic> jobs = json.decode(jobsStr);

      final newJob = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'title': title,
        'description': description,
        'budget': budget,
        'category': category,
        'location': location,
        'status': 'open',
        'created_at': DateTime.now().toIso8601String(),
        'user_id': 0,
      };

      final userDataStr = prefs.getString('user_data');
      if (userDataStr != null) {
        final userData = json.decode(userDataStr);
        newJob['user_id'] = userData['id'] ?? 0;
        newJob['posted_by'] = userData['name'] ?? 'Customer';
      } else {
        newJob['posted_by'] = 'Customer';
      }

      jobs.add(newJob);
      await prefs.setString('mock_customer_jobs', json.encode(jobs));

      return {
        'status': true,
        'message': 'Customer job posted successfully.',
        'data': newJob,
      };
    } catch (e) {
      return {'status': false, 'message': 'Failed to post customer job: $e'};
    }
  }

  /// GET /api/customer/jobs (Mocked)
  Future<Map<String, dynamic>> getMyCustomerJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jobsStr = prefs.getString('mock_customer_jobs') ?? '[]';
      final List<dynamic> allJobs = json.decode(jobsStr);

      int currentUserId = 0;
      final userDataStr = prefs.getString('user_data');
      if (userDataStr != null) {
        final userData = json.decode(userDataStr);
        currentUserId = userData['id'] ?? 0;
      }

      final myJobs = allJobs.where((job) => job['user_id'] == currentUserId).toList();
      return {
        'status': true,
        'message': 'Customer jobs retrieved successfully.',
        'data': myJobs,
      };
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch customer jobs: $e'};
    }
  }

  /// GET /api/customer/all-jobs (Mocked)
  Future<Map<String, dynamic>> getAllCustomerJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jobsStr = prefs.getString('mock_customer_jobs') ?? '[]';
      final List<dynamic> allJobs = json.decode(jobsStr);

      final openJobs = allJobs.where((job) => job['status'] == 'open').toList();
      return {
        'status': true,
        'message': 'All customer jobs retrieved successfully.',
        'data': openJobs,
      };
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch all customer jobs: $e'};
    }
  }

  /// POST /api/customer/jobs/{id}/bids (Mocked)
  Future<Map<String, dynamic>> placeBid({
    required int jobId,
    required double amount,
    required String proposal,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bidsStr = prefs.getString('mock_worker_bids') ?? '[]';
      final List<dynamic> bids = json.decode(bidsStr);

      final newBid = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'job_id': jobId,
        'amount': amount,
        'proposal': proposal,
        'created_at': DateTime.now().toIso8601String(),
        'worker_id': 0,
        'worker_name': 'Worker',
      };

      final userDataStr = prefs.getString('user_data');
      if (userDataStr != null) {
        final userData = json.decode(userDataStr);
        newBid['worker_id'] = userData['id'] ?? 0;
        newBid['worker_name'] = userData['name'] ?? 'Worker';
      }

      bids.add(newBid);
      await prefs.setString('mock_worker_bids', json.encode(bids));

      return {
        'status': true,
        'message': 'Bid placed successfully.',
        'data': newBid,
      };
    } catch (e) {
      return {'status': false, 'message': 'Failed to place bid: $e'};
    }
  }

  /// GET /api/customer/jobs/{id}/bids (Mocked)
  Future<Map<String, dynamic>> getCustomerJobBids(int jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bidsStr = prefs.getString('mock_worker_bids') ?? '[]';
      final List<dynamic> allBids = json.decode(bidsStr);

      final jobBids = allBids.where((bid) => bid['job_id'] == jobId).toList();
      return {
        'status': true,
        'message': 'Bids retrieved successfully.',
        'data': jobBids,
      };
    } catch (e) {
      return {'status': false, 'message': 'Failed to fetch bids: $e'};
    }
  }

  // ── 7. Internal Helpers ──────────────────────────────────────────────────

  /// Parses HTTP response into JSON map and captures status errors
  Map<String, dynamic> _handleResponse(http.Response response) {
    final String body = response.body;
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        // Ensure status field is aligned with Laravel responses
        if (!decoded.containsKey('status')) {
          decoded['status'] = response.statusCode >= 200 && response.statusCode < 300;
        }
        return decoded;
      } else {
        return {
          'status': response.statusCode >= 200 && response.statusCode < 300,
          'data': decoded,
        };
      }
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to decode server response. Status code: ${response.statusCode}',
        'body_raw': body,
      };
    }
  }
}
