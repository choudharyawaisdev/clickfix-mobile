# Clickfix API Documentation

This document contains a complete and structured list of all API endpoints for the **ClickFix** application.

* **Base URL:** `https://clickfix.hafiztalha.com`
* **Default Request Headers:**
  ```http
  Accept: application/json
  Content-Type: application/json
  ```
* **Authentication Header:**
  For all protected routes, you must pass the Sanctum token obtained from Login/Register in the Authorization header:
  ```http
  Authorization: Bearer <your_access_token>
  ```

---

## Table of Contents
1. [Authentication & Registration APIs](#1-authentication--registration-apis)
2. [Profile & Account Management APIs](#2-profile--account-management-apis)
3. [Services & Job Search APIs](#3-services--job-search-apis)
4. [Worker Job & Portfolio Management APIs](#4-worker-job--portfolio-management-apis)
5. [Bookings & Reviews APIs](#5-bookings--reviews-apis)
6. [Wishlist APIs](#6-wishlist-apis)
7. [Blog APIs](#7-blog-apis)
8. [Admin-Specific APIs](#8-admin-specific-apis)
9. [Chat / Messenger APIs](#9-chat--messenger-apis)

---

## 1. Authentication & Registration APIs

### 1.1 Register User
Register a new customer or worker account.
* **Method:** `POST`
* **Endpoint:** `/api/register` (also supports `/api/auth/register`)
* **Headers:** `Content-Type: multipart/form-data` (if uploading profile picture)
* **Request Parameters:**
  | Field | Type | Required | Description / Rules |
  | :--- | :--- | :--- | :--- |
  | `name` | string | Yes | Max: 255 |
  | `email` | string | Yes | Email format, must be unique in `users` table |
  | `phone_number` | string | Yes | Max: 20, must be unique in `users` table |
  | `city` | string | Yes | Max: 255 |
  | `role` | string | Yes | `customer` or `worker` |
  | `service_id` | integer | Conditional | Required only if `role` is `worker`. Must exist in `services` table |
  | `profile_picture` | file | No | Image file (jpeg, png, jpg), max: 2MB (2048 KB) |
  | `password` | string | Yes | Min: 8 characters |
  | `password_confirmation` | string | Yes | Must match `password` |

* **Example Success Response (201 Created):**
  ```json
  {
    "status": true,
    "message": "User registered successfully.",
    "data": {
      "access_token": "1|abcdef123456...",
      "token_type": "Bearer",
      "user": {
        "id": 15,
        "name": "Awais Choudhary",
        "email": "awais@example.com",
        "phone_number": "03001234567",
        "city": "Lahore",
        "role": "worker",
        "service_id": 3,
        "profile_picture": "profile_pictures/abc.jpg",
        "account_status": "active",
        "created_at": "2026-06-20T16:00:00.000000Z"
      }
    }
  }
  ```

---

### 1.2 Login User
Authenticate credentials and receive an access token.
* **Method:** `POST`
* **Endpoint:** `/api/login` (also supports `/api/auth/login`)
* **Request Body:**
  ```json
  {
    "email": "awais@example.com",
    "password": "securepassword"
  }
  ```
* **Example Success Response (200 OK):**
  ```json
  {
    "status": true,
    "message": "Logged in successfully.",
    "data": {
      "access_token": "2|ghijk789...",
      "token_type": "Bearer",
      "user": {
        "id": 15,
        "name": "Awais Choudhary",
        "email": "awais@example.com",
        "role": "worker",
        "account_status": "active"
      }
    }
  }
  ```

---

### 1.3 Logout User
Revoke the current authenticated session token.
* **Method:** `POST`
* **Endpoint:** `/api/logout`
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):**
  ```json
  {
    "status": true,
    "message": "Logged out successfully.",
    "data": []
  }
  ```

---

## 2. Profile & Account Management APIs

### 2.1 Get User Profile
Retrieve details of the authenticated user.
* **Method:** `GET`
* **Endpoint:** `/api/profile`
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):**
  ```json
  {
    "status": true,
    "message": "Profile details retrieved successfully.",
    "data": {
      "id": 15,
      "name": "Awais Choudhary",
      "email": "awais@example.com",
      "role": "worker",
      "city": "Lahore",
      "is_online": true,
      "service": {
        "id": 3,
        "title": "Electrician",
        "status": "active"
      }
    }
  }
  ```

---

### 2.2 Update User Profile
* **Method:** `POST`
* **Endpoint:** `/api/profile/update`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: multipart/form-data` (if profile picture updated)
* **Request Parameters:**
  | Field | Type | Required | Description / Rules |
  | :--- | :--- | :--- | :--- |
  | `name` | string | Yes | Max: 255 |
  | `email` | string | Yes | Valid email, unique except current user |
  | `password` | string | No | Optional. Min: 8 characters |
  | `password_confirmation` | string | No | Required if password is sent |
  | `phone_number` | string | No | Max: 20 |
  | `city` | string | No | Max: 255 |
  | `service_id` | integer | No | Exists in `services` table |
  | `description` | string | No | Description / Bio |
  | `profile_picture` | file | No | Image file (jpeg, png, jpg), max: 2MB |
  | `pro_icon` | string | No | `blue`, `green`, `gold`, `purple` (Only saved if account status is `pro`) |

---

### 2.3 Toggle Online Status (Worker Only)
Toggle availability status to receive or block bookings.
* **Method:** `POST`
* **Endpoint:** `/api/profile/toggle-online-status`
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):**
  ```json
  {
    "status": true,
    "message": "You are now online to receive bookings.",
    "data": {
      "is_online": true
    }
  }
  ```

---

### 2.4 Switch User Role
Switch role dynamically between `customer` and `worker`.
* **Method:** `POST`
* **Endpoint:** `/api/switch-role`
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):**
  ```json
  {
    "status": true,
    "message": "User role switched successfully.",
    "data": {
      "role": "customer"
    }
  }
  ```

---

## 3. Services & Job Search APIs

### 3.1 Get Active Services List
Fetch all active service categories.
* **Method:** `GET`
* **Endpoint:** `/api/services`
* **Response (200 OK):**
  ```json
  {
    "status": true,
    "message": "Active services fetched successfully.",
    "data": [
      { "id": 1, "title": "Plumbing", "status": "active" },
      { "id": 2, "title": "Carpentry", "status": "active" }
    ]
  }
  ```

---

### 3.2 Search Worker Jobs
Search and paginate worker job postings.
* **Method:** `GET`
* **Endpoint:** `/api/jobs`
* **Query Parameters:**
  * `category` (optional | string) - Filter by matching category name.
  * `city` (optional | string) - Filter by worker city.
  * `online_only` (optional | boolean) - If `true`/`1`, returns only online workers.
* **Response (200 OK - Paginated):**
  ```json
  {
    "status": true,
    "message": "Worker jobs search complete.",
    "data": {
      "current_page": 1,
      "data": [
        {
          "id": 5,
          "title": "Home AC Installation",
          "price": 1500,
          "location": "Gulberg, Lahore",
          "user": { "name": "Awais", "city": "Lahore", "is_online": true }
        }
      ],
      "total": 12
    }
  }
  ```

---

### 3.3 Get Worker Job Details
Get details of a specific job posting.
* **Method:** `GET`
* **Endpoint:** `/api/jobs/{id}`
* **Response (200 OK):**
  ```json
  {
    "status": true,
    "message": "Job details fetched successfully.",
    "data": {
      "id": 5,
      "title": "Home AC Installation",
      "price": 1500,
      "description": "Professional installation service..."
    }
  }
  ```

---

## 4. Worker Job & Portfolio Management APIs

### 4.1 Fetch Worker's Own Jobs
Retrieve all jobs posted by the authenticated worker.
* **Method:** `GET`
* **Endpoint:** `/api/worker/jobs`
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):**
  ```json
  {
    "status": true,
    "message": "My jobs list retrieved successfully.",
    "data": [
      { "id": 5, "title": "Home AC Installation", "price": 1500 }
    ]
  }
  ```

---

### 4.2 Create a New Job Posting
* **Method:** `POST`
* **Endpoint:** `/api/worker/jobs`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`
* **Request Parameters:**
  | Field | Type | Required | Description / Rules |
  | :--- | :--- | :--- | :--- |
  | `title` | string | Yes | Max: 255 |
  | `service_id` | integer | Yes | Must exist in `services` table |
  | `price` | numeric | Yes | Min: 0 |
  | `location` | string | Yes | Max: 255 |
  | `description` | string | Yes | Detailed description |
  | `image` | file | No | Image file (jpeg, png, jpg), max: 2MB |

---

### 4.3 Update an Existing Job Posting
* **Method:** `POST`
* **Endpoint:** `/api/worker/jobs/{id}`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`
* **Note:** POST is used for compatibility with multipart/form-data payloads on update.
* **Request Parameters:** Same as [4.2 Create a New Job Posting](#42-create-a-new-job-posting).

---

### 4.4 Delete a Job Posting
* **Method:** `DELETE`
* **Endpoint:** `/api/worker/jobs/{id}`
* **Headers:** `Authorization: Bearer <token>`

---

### 4.5 Fetch Worker Portfolio Items
* **Method:** `GET`
* **Endpoint:** `/api/worker/portfolio`
* **Headers:** `Authorization: Bearer <token>`

---

### 4.6 Save a New Portfolio Item
* **Method:** `POST`
* **Endpoint:** `/api/worker/portfolio`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`
* **Request Parameters:**
  | Field | Type | Required | Description / Rules |
  | :--- | :--- | :--- | :--- |
  | `image` | file | Yes | Image file (jpeg, png, jpg), max: 2MB |
  | `title` | string | No | Max: 255 |
  | `description` | string | No | Detailed description |

---

### 4.7 Update a Portfolio Item
* **Method:** `POST`
* **Endpoint:** `/api/worker/portfolio/{id}`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`
* **Request Parameters:**
  | Field | Type | Required | Description / Rules |
  | :--- | :--- | :--- | :--- |
  | `image` | file | No | Image file (jpeg, png, jpg), max: 2MB |
  | `title` | string | No | Max: 255 |
  | `description` | string | No | Detailed description |

---

### 4.8 Remove a Portfolio Item
* **Method:** `DELETE`
* **Endpoint:** `/api/worker/portfolio/{id}`
* **Headers:** `Authorization: Bearer <token>`

---

## 5. Bookings & Reviews APIs

### 5.1 Create Booking Request
* **Method:** `POST`
* **Endpoint:** `/api/bookings`
* **Headers:** `Authorization: Bearer <token>`
* **Request Parameters:**
  | Field | Type | Required | Description / Rules |
  | :--- | :--- | :--- | :--- |
  | `worker_id` | integer | Yes | Must exist in `users` table |
  | `service_id` | integer | Yes | Must exist in `services` table |
  | `booking_date` | string | Yes | Format: YYYY-MM-DD, after_or_equal:today |
  | `booking_time` | string | Yes | e.g. "14:30" |
  | `address` | string | Yes | Job completion address |
  | `message` | string | No | Instructions/details |

* **Note:** Will fail if the worker's status is offline.

---

### 5.2 Get User Bookings List
Retrieve all bookings where user is the customer or worker.
* **Method:** `GET`
* **Endpoint:** `/api/my-bookings`
* **Headers:** `Authorization: Bearer <token>`

---

### 5.3 Update Booking Request Status (Worker Only)
Accept, complete, or cancel a customer's booking request.
* **Method:** `PATCH`
* **Endpoint:** `/api/bookings/{id}/status`
* **Headers:** `Authorization: Bearer <token>`
* **Request Body:**
  ```json
  {
    "status": "accepted" 
  }
  ```
  *(Status options: `accepted`, `completed`, `cancelled`)*

---

### 5.4 Submit Worker Review
Submit rating and feedback for a completed booking.
* **Method:** `POST`
* **Endpoint:** `/api/reviews`
* **Headers:** `Authorization: Bearer <token>`
* **Request Parameters:**
  | Field | Type | Required | Description / Rules |
  | :--- | :--- | :--- | :--- |
  | `worker_id` | integer | Yes | ID of the worker |
  | `booking_id` | integer | Yes | ID of the booking |
  | `rating` | integer | Yes | Value: 1 to 5 |
  | `comment` | string | No | Text description |

---

## 6. Wishlist APIs

### 6.1 Toggle Worker in Wishlist
* **Method:** `POST`
* **Endpoint:** `/api/wishlist/toggle`
* **Headers:** `Authorization: Bearer <token>`
* **Request Body:**
  ```json
  {
    "worker_id": 15
  }
  ```

---

### 6.2 Get User Wishlist
* **Method:** `GET`
* **Endpoint:** `/api/wishlist`
* **Headers:** `Authorization: Bearer <token>`

---

## 7. Blog APIs

### 7.1 Fetch Blogs List
* **Method:** `GET`
* **Endpoint:** `/api/blogs`

---

### 7.2 Fetch Blog Details
* **Method:** `GET`
* **Endpoint:** `/api/blogs/{slug}`

---

## 8. Admin-Specific APIs

### 8.1 Admin Update User Status
* **Method:** `PATCH`
* **Endpoint:** `/api/admin/users/{id}/status`
* **Request Body:**
  ```json
  {
    "account_status": "pro",
    "pro_icon": "gold"
  }
  ```
  *(Account status options: `active`, `disabled`, `blocked`, `pro`)*
  *(Pro icon options: `blue`, `green`, `gold`, `purple`)*

---

### 8.2 Fetch All Blogs (Admin List)
* **Method:** `GET`
* **Endpoint:** `/api/admin/blog/fetch`

---

### 8.3 Admin Create Blog
* **Method:** `POST`
* **Endpoint:** `/api/admin/blog/create`
* **Headers:** `Content-Type: multipart/form-data`
* **Request Parameters:**
  | Field | Type | Required | Description / Rules |
  | :--- | :--- | :--- | :--- |
  | `title` | string | Yes | Title, Max: 255 |
  | `content` | string | Yes | HTML or Text content |
  | `image` | file | No | Image file, max: 2MB |

---

### 8.4 Admin Fetch Blog Details
* **Method:** `GET`
* **Endpoint:** `/api/admin/blog/show/{id}`

---

### 8.5 Admin Update Blog
* **Method:** `POST`
* **Endpoint:** `/api/admin/blog/update/{id}`
* **Request Parameters:** Same as Admin Create Blog, plus optional `status` (boolean).

---

### 8.6 Admin Delete Blog
* **Method:** `DELETE`
* **Endpoint:** `/api/admin/blog/delete/{id}`

---

## 9. Chat / Messenger APIs

### 9.1 Pusher Authentication
Authenticate private channels.
* **Method:** `POST`
* **Endpoint:** `/api/chat/auth`
* **Request Body:** Passes socket connection variables (`socket_id`, `channel_name`)

---

### 9.2 Fetch Contact Info
Retrieve information about a chat partner (user/group).
* **Method:** `POST`
* **Endpoint:** `/api/idInfo`
* **Request Body:**
  ```json
  {
    "id": 12
  }
  ```

---

### 9.3 Send Message
Send a text message or file attachment.
* **Method:** `POST`
* **Endpoint:** `/api/sendMessage`
* **Headers:** `Content-Type: multipart/form-data`
* **Request Parameters:**
  | Field | Type | Required | Description / Rules |
  | :--- | :--- | :--- | :--- |
  | `id` | integer | Yes | Receiver user ID |
  | `message` | string | Conditional | Required if no attachment `file` sent |
  | `file` | file | No | Optional attachment file |
  | `temporaryMsgId` | string | Yes | For client message tracking |

---

### 9.4 Fetch Messages List
* **Method:** `POST`
* **Endpoint:** `/api/fetchMessages`
* **Request Body:**
  ```json
  {
    "id": 12
  }
  ```

---

### 9.5 Make Messages Seen
* **Method:** `POST`
* **Endpoint:** `/api/makeSeen`
* **Request Body:**
  ```json
  {
    "id": 12
  }
  ```

---

### 9.6 Get Contacts List
Retrieve contact chats.
* **Method:** `GET`
* **Endpoint:** `/api/getContacts`

---

### 9.7 Star/Favorite User
* **Method:** `POST`
* **Endpoint:** `/api/star`
* **Request Body:**
  ```json
  {
    "id": 12
  }
  ```

---

### 9.8 Fetch Favorites List
* **Method:** `POST`
* **Endpoint:** `/api/favorites`

---

### 9.9 Search Contacts/Messages
* **Method:** `GET`
* **Endpoint:** `/api/search`
* **Query Parameters:**
  * `input` (Required | string) - Search query

---

### 9.10 Fetch Shared Photos
* **Method:** `POST`
* **Endpoint:** `/api/shared`
* **Request Body:**
  ```json
  {
    "id": 12
  }
  ```

---

### 9.11 Delete Conversation
* **Method:** `POST`
* **Endpoint:** `/api/deleteConversation`
* **Request Body:**
  ```json
  {
    "id": 12
  }
  ```

---

### 9.12 Update Avatar Settings
* **Method:** `POST`
* **Endpoint:** `/api/updateSettings`
* **Headers:** `Content-Type: multipart/form-data`
* **Request Parameters:**
  * `avatar` (Required | file) - Avatar image file

---

### 9.13 Set Active Status
* **Method:** `POST`
* **Endpoint:** `/api/setActiveStatus`
* **Request Body:**
  ```json
  {
    "status": 1
  }
  ```
  *(Status: `1` for active/online, `0` for offline)*
