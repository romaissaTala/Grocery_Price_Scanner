import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<CheckOnboardingStatus>(_onCheckOnboardingStatus);
  }
  
  Future<void> _onCheckOnboardingStatus(
    CheckOnboardingStatus event,
    Emitter<SplashState> emit,
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(AppConstants.keyOnboardingDone) ?? false;
    
    if (onboardingDone) {
      emit(NavigateToScanner());
    } else {
      emit(NavigateToOnboarding());
    }
  }
}