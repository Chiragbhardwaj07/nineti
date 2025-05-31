// lib/features/user_management/domain/repository/user_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nineti/constants/app_constants.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/todo.dart';

class UserRepository {
  final http.Client _client;

  UserRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch a page of users (same as before).
  Future<PaginatedUsers> fetchUsers({
    int limit = 20,
    int skip = 0,
    String? search,
  }) async {
    final String path = (search != null && search.trim().isNotEmpty)
        ? 'users/search'
        : 'users';

    final Uri baseUri = Uri.parse(baseURL).replace(path: path);
    final Map<String, String> queryParameters = {
      'limit': '$limit',
      'skip': '$skip',
    };
    if (search != null && search.trim().isNotEmpty) {
      queryParameters['q'] = search.trim();
    }
    final Uri uri = baseUri.replace(queryParameters: queryParameters);

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch users (status ${response.statusCode})');
    }

    final Map<String, dynamic> jsonMap =
        json.decode(response.body) as Map<String, dynamic>;
    final List<dynamic> usersJson = (jsonMap['users'] as List<dynamic>);
    final int? total = jsonMap['total'] as int?;

    final List<User> users = usersJson
        .map((u) => User.fromJson(u as Map<String, dynamic>))
        .toList();
    final int fetchedCount = users.length;
    final bool hasMore = (skip + fetchedCount) < (total ?? 0);

    return PaginatedUsers(users: users, hasMore: hasMore);
  }

  /// Fetch a single user’s full details by ID.
  Future<User> fetchUserById(int userId) async {
    // Endpoint: GET https://dummyjson.com/users/{id}
    final Uri uri =
        Uri.parse(baseURL).replace(path: 'users/$userId');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch user (status ${response.statusCode})');
    }
    final Map<String, dynamic> jsonMap =
        json.decode(response.body) as Map<String, dynamic>;
    return User.fromJson(jsonMap);
  }

  /// Fetch posts for a given user.
  Future<List<Post>> fetchPostsForUser(int userId) async {
    final Uri uri =
        Uri.parse(baseURL).replace(path: 'posts/user/$userId');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to fetch posts (status ${response.statusCode})');
    }
    final Map<String, dynamic> jsonMap =
        json.decode(response.body) as Map<String, dynamic>;
    final List<dynamic> postsJson = (jsonMap['posts'] as List<dynamic>);
    return postsJson
        .map((p) => Post.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Fetch todos for a given user.
  Future<List<Todo>> fetchTodosForUser(int userId) async {
    final Uri uri =
        Uri.parse(baseURL).replace(path: 'todos/user/$userId');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to fetch todos (status ${response.statusCode})');
    }
    final Map<String, dynamic> jsonMap =
        json.decode(response.body) as Map<String, dynamic>;
    final List<dynamic> todosJson = (jsonMap['todos'] as List<dynamic>);
    return todosJson
        .map((t) => Todo.fromJson(t as Map<String, dynamic>))
        .toList();
  }
}

/// Wrapper for paginated user results
class PaginatedUsers {
  final List<User> users;
  final bool hasMore;

  PaginatedUsers({
    required this.users,
    required this.hasMore,
  });
}
