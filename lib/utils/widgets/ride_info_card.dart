import 'package:flutter/material.dart';
import 'package:ride_sharing_app/models/ride_model.dart';
import 'package:ride_sharing_app/utils/constants/app_colors.dart';
import 'package:ride_sharing_app/utils/helpers.dart';

class RideInfoCard extends StatelessWidget {
  final RideModel ride;
  final VoidCallback? onTap;

  const RideInfoCard({Key? key, required this.ride, this.onTap}) : super(key: key);

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Helpers.getRideStatusColor(ride.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Helpers.getRideStatusIcon(ride.status), size: 14, color: Helpers.getRideStatusColor(ride.status)),
                        const SizedBox(width: 4),
                        Text(ride.status.toUpperCase(), style: TextStyle(color: Helpers.getRideStatusColor(ride.status), fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Text(Helpers.formatCurrency(ride.fare ?? 0), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.success)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppColors.pickupColor.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.circle, size: 8, color: AppColors.pickupColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(ride.pickupLocation.address ?? 'Pickup location', style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Container(width: 2, height: 16, color: Colors.grey[300]),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppColors.dropoffColor.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.location_on, size: 8, color: AppColors.dropoffColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(ride.dropoffLocation.address ?? 'Dropoff location', style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.route, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(Helpers.formatDistance(ride.distance ?? 0), style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(Helpers.formatDuration(ride.estimatedTime ?? 0), style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
