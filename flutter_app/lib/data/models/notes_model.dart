// lib/models/note_model.dart
import 'package:flutter/material.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final String type; // 'personal' or 'family'
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final Color color;

  Note({
    String? id,
    required this.title,
    required this.content,
    required this.type,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPinned = false,
    Color? color,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        color = color ?? _getColorForType(type);

  static Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'family':
        return const Color(0xFFE8F5E8); // Light green for family
      case 'personal':
        return const Color(0xFFE3F2FD); // Light blue for personal
      default:
        return const Color(0xFFF5F5F5); // Light gray default
    }
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'personal',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      isPinned: json['isPinned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'type': type,
      'isPinned': isPinned,
    };
  }

  Note copyWith({
    String? title,
    String? content,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    Color? color,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      color: color ?? this.color,
    );
  }
}

