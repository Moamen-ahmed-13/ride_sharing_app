import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_sharing_app/cubits/auth/auth_state.dart';
import 'package:ride_sharing_app/services/auth_service.dart';
import 'package:ride_sharing_app/services/firebase_database_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
 StreamSubscription? _userSubscription;
  AuthCubit() : super(AuthInitial()){
    _checkAuthStatus();
  }
Future<void> _checkAuthStatus() async {
    if (_authService.currentUser != null) {
      emit(AuthLoading());
      _listenToUser();
    }
  }
  Future<void> signUp(String email, String password, String role, String name, String phone, String? vehicleType, String? vehicleNumber, String? licenseNumber) async {
    emit(AuthLoading());
    try {
      await _authService.signUp(email, password, role, name, phone, vehicleType, vehicleNumber, licenseNumber);
      _listenToUser();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authService.signIn(email, password);
      _listenToUser();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
void _listenToUser() {
  if (_authService.currentUser != null) {
    final uid = _authService.currentUser!.uid;
    
    _dbService.getUserStream(uid).listen((user) {
      if (user != null) {
        print('✅ User loaded: ${user.email} (${user.role})');
        emit(AuthAuthenticated(user));
      } else {
        print('❌ User data not found in database');
        emit(AuthError('User data not found'));
      }
    }, onError: (error) {
      print('❌ Error listening to user: $error');
      emit(AuthError('Error loading user data: $error'));
    });
  }
}

  Future<void> signOut() async {
    await _authService.signOut();
    emit(AuthInitial());
  }
}