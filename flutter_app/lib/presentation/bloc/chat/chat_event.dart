import 'package:equatable/equatable.dart';
import '../../../data/models/chat_models.dart'; // ADDED: Import for Chat model

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object> get props => [];
}

class ChatInitialized extends ChatEvent {}

class ChatMessageSent extends ChatEvent {
  final String message;
  const ChatMessageSent(this.message);
  @override
  List<Object> get props => [message];
}

class ChatCleared extends ChatEvent {}

class ChatHistoryRequested extends ChatEvent {}

class ChatHistoryLoaded extends ChatEvent {
  final List<Chat> chats;
  const ChatHistoryLoaded(this.chats);
  @override
  List<Object> get props => [chats];
}

// ADDED: AI Feature Events
class AIFeatureRequested extends ChatEvent {
  final AIFeatureType featureType;
  const AIFeatureRequested(this.featureType);
  @override
  List<Object> get props => [featureType];
}

// ADDED: Enum for AI Features (matching your backend)
enum AIFeatureType {
  growthPlans,      // /users/generatePlan
  learningZone,     // /users/generateLearningZone  
  trackDay,         // /users/generateTrackDay
  story,            // /users/generateStory
  viewTasks,        // /users/generateViewTasks
  quickTip,         // /users/generateQuickTip
}