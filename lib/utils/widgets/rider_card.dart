import 'package:flutter/material.dart';
import 'package:ride_sharing_app/models/user_model.dart';
import 'package:ride_sharing_app/utils/constants/app_colors.dart';

class RiderCard extends StatelessWidget {
  final UserModel rider;
  final VoidCallback? onTap;
  final VoidCallback? onCall;

  const RiderCard({Key? key, required this.rider, this.onTap, this.onCall}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.accent.withOpacity(0.2),
                child: Text(rider.name[0].toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.accent)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rider.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: AppColors.ratingGold),
                        const SizedBox(width: 4),
                        Text(rider.rating?.toStringAsFixed(1) ?? '5.0', style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    if (rider.phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(rider.phone, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ],
                ),
              ),
              if (onCall != null)
                Container(
                  decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
                  child: IconButton(icon: const Icon(Icons.phone, color: AppColors.success), onPressed: onCall),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
