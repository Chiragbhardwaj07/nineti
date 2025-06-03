import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nineti/constants/app_constants.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/todo.dart';

class UserRepository {
  final http.Client _client;

  // Hive boxes
  final Box<User> _usersBox = Hive.box<User>('usersBox');
  final Box<List> _postsBox = Hive.box<List>('postsBox');
  final Box<List> _todosBox = Hive.box<List>('todosBox');

  UserRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch paginated users. On success, cache into Hive; on failure, read from Hive.
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

    try {
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

      // Cache each user individually by ID
      for (var user in users) {
        _usersBox.put(user.id, user);
      }

      final int fetchedCount = users.length;
      final bool hasMore = (skip + fetchedCount) < (total ?? 0);

      return PaginatedUsers(users: users, hasMore: hasMore);
    } catch (_) {
      // On error (e.g. no network), fallback to local cache:
      final allCached = _usersBox.values.toList();
      if (allCached.isEmpty) {
        rethrow; // no cached data either
      }
      // Return “page” from cached list:
      final start = skip;
      final end = skip + limit;
      final sliced = allCached.sublist(
          start < allCached.length ? start : allCached.length,
          end < allCached.length ? end : allCached.length);
      final hasMore = end < allCached.length;
      return PaginatedUsers(users: sliced, hasMore: hasMore);
    }
  }

  /// Fetch a single user by ID. Cache on success; fallback to Hive on error.
  Future<User> fetchUserById(int userId) async {
    final Uri uri = Uri.parse(baseURL).replace(path: 'users/$userId');
    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch user (status ${response.statusCode})');
      }
      final Map<String, dynamic> jsonMap =
          json.decode(response.body) as Map<String, dynamic>;
      final user = User.fromJson(jsonMap);
      _usersBox.put(user.id, user);
      return user;
    } catch (_) {
      // Fallback to Hive if present
      final cached = _usersBox.get(userId);
      if (cached != null) return cached;
      rethrow;
    }
  }

  /// Fetch posts for a user. Cache into Hive; fallback to Hive on error.
  Future<List<Post>> fetchPostsForUser(int userId) async {
    final Uri uri = Uri.parse(baseURL).replace(path: 'posts/user/$userId');

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch posts (status ${response.statusCode})');
      }
      final Map<String, dynamic> jsonMap =
          json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> postsJson = (jsonMap['posts'] as List<dynamic>);
      final List<Post> posts = postsJson
          .map((p) => Post.fromJson(p as Map<String, dynamic>))
          .toList();

      // Cache entire list under key 'user_$userId'
      _postsBox.put('user_$userId', posts);
      return posts;
    } catch (_) {
      // Fallback to Hive
      final cached = _postsBox.get('user_$userId');
      if (cached != null && cached is List<Post>) {
        return cached;
      }
      rethrow;
    }
  }

  /// Fetch todos for a user. Cache into Hive; fallback to Hive on error.
  Future<List<Todo>> fetchTodosForUser(int userId) async {
    final Uri uri = Uri.parse(baseURL).replace(path: 'todos/user/$userId');

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch todos (status ${response.statusCode})');
      }

      final Map<String, dynamic> jsonMap =
          json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> todosJson = (jsonMap['todos'] as List<dynamic>);
      final List<Todo> todos = todosJson
          .map((t) => Todo.fromJson(t as Map<String, dynamic>))
          .toList();

      _todosBox.put('user_$userId', todos);
      return todos;
    } catch (_) {
      // Fallback to Hive
      final cached = _todosBox.get('user_$userId');
      if (cached != null && cached is List<Todo>) {
        return cached;
      }
      rethrow;
    }
  }
}

class PaginatedUsers {
  final List<User> users;
  final bool hasMore;

  PaginatedUsers({required this.users, required this.hasMore});
}
