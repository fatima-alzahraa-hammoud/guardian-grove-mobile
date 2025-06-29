import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavCubit extends Cubit<int> {
  BottomNavCubit() : super(0);

  void changeTab(int index) {
    emit(index);
  }

  void goToHome() => emit(0);
  void goToLeaderboard() => emit(1);
  void goToAIAssistant() => emit(2);
  void goToMessaging() => emit(3);
  void goToProfile() => emit(4);
}