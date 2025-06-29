
// lib/bloc/notes_cubit.dart
import 'package:flutter_app/core/services/notes_service.dart';
import 'package:flutter_app/core/services/storage_service.dart';
import 'package:flutter_app/data/models/notes_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
 
// States
abstract class NotesState {}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Note> notes;
  final List<String> noteTypes;
  final int filterIndex;

  NotesLoaded({
    required this.notes,
    required this.noteTypes,
    this.filterIndex = 0,
  });

  NotesLoaded copyWith({
    List<Note>? notes,
    List<String>? noteTypes,
    int? filterIndex,
  }) {
    return NotesLoaded(
      notes: notes ?? this.notes,
      noteTypes: noteTypes ?? this.noteTypes,
      filterIndex: filterIndex ?? this.filterIndex,
    );
  }
}

class NotesError extends NotesState {
  final String message;
  NotesError(this.message);
}

// Cubit
class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesInitial()) {
    loadNotes();
  }

  final List<String> _noteTypes = ['All', 'Personal', 'Family'];

  Future<void> loadNotes() async {
    try {
      emit(NotesLoading());
      final notes = await NotesService.getNotes();
      emit(NotesLoaded(
        notes: notes,
        noteTypes: _noteTypes,
        filterIndex: 0,
      ));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> addNote(Note note) async {
    try {
      final currentUser = StorageService.getUser();
      if (currentUser == null) {
        emit(NotesError('User not authenticated'));
        return;
      }

      await NotesService.createNote(
        title: note.title,
        content: note.content,
        type: note.type,
      );

      // Reload notes to get the updated list
      await loadNotes();
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> updateNote({
    required String noteId,
    String? title,
    String? content,
    bool? isPinned,
  }) async {
    try {
      final currentUser = StorageService.getUser();
      if (currentUser == null) {
        emit(NotesError('User not authenticated'));
        return;
      }

      await NotesService.updateNote(
        userId: currentUser.id,
        noteId: noteId,
        title: title,
        content: content,
        isPinned: isPinned,
      );

      // Reload notes to get the updated list
      await loadNotes();
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      final currentUser = StorageService.getUser();
      if (currentUser == null) {
        emit(NotesError('User not authenticated'));
        return;
      }

      await NotesService.deleteNote(
        userId: currentUser.id,
        noteId: noteId,
      );

      // Reload notes to get the updated list
      await loadNotes();
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  void changeFilter(int index) {
    final currentState = state;
    if (currentState is NotesLoaded) {
      emit(currentState.copyWith(filterIndex: index));
    }
  }

  Future<void> refreshNotes() async {
    await loadNotes();
  }
}
