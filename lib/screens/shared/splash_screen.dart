import 'package:flutter/material.dart';
import 'package:ride_sharing_app/utils/constants/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.local_taxi, size: 80, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Ride Sharing', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Text('Your journey starts here', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9), letterSpacing: 0.5)),
              const SizedBox(height: 60),
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8))),
              ),
              const SizedBox(height: 16),
              Text('Loading...', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
            ],
          ),
        ),
      ),
    );
  }
}