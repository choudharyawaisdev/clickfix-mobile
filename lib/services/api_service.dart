import 'dart:convert';
import 'package:http/http.dart' as http;

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
  }) async {
    try {
      final body = {
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'city': city,
        'role': role.toLowerCase(),
        if (role.toLowerCase() == 'worker' && serviceId != null) 'service_id': serviceId,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      return _handleResponse(response);
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
      if (result['status'] == true && result.containsKey('access_token')) {
        token = result['access_token'];
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
  }) async {
    try {
      final body = {
        'name': name,
        'email': email,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (city != null) 'city': city,
        if (password != null) 'password': password,
        if (passwordConfirmation != null) 'password_confirmation': passwordConfirmation,
        if (serviceId != null) 'service_id': serviceId,
        if (description != null) 'description': description,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/profile/update'),
        headers: headers,
        body: json.encode(body),
      );
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
