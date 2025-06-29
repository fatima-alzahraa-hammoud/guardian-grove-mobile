// lib/services/notes_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_app/core/constants/app_constants.dart';
import 'package:flutter_app/core/services/storage_service.dart';
import 'package:flutter_app/data/models/notes_model.dart';

class NotesService {
  static final Dio _dio = Dio();

  static void _setupDio() {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    final token = StorageService.getToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // Create a new note
  static Future<Note> createNote({
    required String title,
    required String content,
    required String type,
  }) async {
    try {
      _setupDio();

      final response = await _dio.post(
        '/notes',
        data: {'title': title, 'content': content, 'type': type},
      );

      if (response.statusCode == 201) {
        return Note.fromJson(response.data['note']);
      } else {
        throw Exception('Failed to create note');
      }
    } catch (e) {
      throw Exception('Error creating note: $e');
    }
  }

  // Get all notes for the current user
  static Future<List<Note>> getNotes({String? userId}) async {
    try {
      _setupDio();

      // Get current user to pass their ID
      final currentUser = StorageService.getUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Always pass userId (either provided or current user's ID)
      final targetUserId = userId ?? currentUser.id;

      final response = await _dio.post(
        '/notes',
        data: {'userId': targetUserId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> notesData = response.data['notes'] ?? [];
        return notesData.map((noteJson) => Note.fromJson(noteJson)).toList();
      } else {
        throw Exception('Failed to fetch notes');
      }
    } catch (e) {
      throw Exception('Error fetching notes: $e');
    }
  }

  // Update an existing note
  static Future<Note> updateNote({
    required String userId,
    required String noteId,
    String? title,
    String? content,
    bool? isPinned,
  }) async {
    try {
      _setupDio();

      final response = await _dio.put(
        '/notes',
        data: {
          'userId': userId,
          'noteId': noteId,
          if (title != null) 'title': title,
          if (content != null) 'content': content,
          if (isPinned != null) 'isPinned': isPinned,
        },
      );

      if (response.statusCode == 200) {
        return Note.fromJson(response.data['note']);
      } else {
        throw Exception('Failed to update note');
      }
    } catch (e) {
      throw Exception('Error updating note: $e');
    }
  }

  // Delete a note
  static Future<void> deleteNote({
    required String userId,
    required String noteId,
  }) async {
    try {
      _setupDio();

      final response = await _dio.delete(
        '/notes',
        data: {'userId': userId, 'noteId': noteId},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete note');
      }
    } catch (e) {
      throw Exception('Error deleting note: $e');
    }
  }
}
