import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ride_sharing_app/app.dart';
import 'package:ride_sharing_app/firebase_options.dart';
import 'package:ride_sharing_app/services/fcm_service.dart';
// import 'package:ride_sharing_app/core/bloc_observer.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // Bloc.observer = AppBlocObserver();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FCMService().initialize();
  } catch (e) {
    debugPrint('🔥 Firebase initialization error: $e');
  }
  runApp(
    const RideSharingApp(),
    
  );
}
