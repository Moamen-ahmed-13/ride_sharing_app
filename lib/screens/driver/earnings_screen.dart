import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_sharing_app/utils/constants/app_colors.dart';
import '../../cubits/driver/driver_cubit.dart';
import '../../models/ride_model.dart';
import '../../utils/helpers.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({Key? key}) : super(key: key);

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  Map<String, dynamic> _earningsData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    setState(() => _isLoading = true);
    final data = await context.read<DriverCubit>().getEarnings();
    if (mounted) {
      setState(() {
        _earningsData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings'), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEarnings,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Earnings', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 12),
                          Text(Helpers.formatCurrency(_earningsData['totalEarnings'] ?? 0.0), style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.directions_car, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text('${_earningsData['totalRides'] ?? 0} trips completed', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text('Recent Trips', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if ((_earningsData['rides'] as List?)?.isEmpty ?? true)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: [
                              Icon(Icons.assignment, size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text('No trips yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      )
                    else
                      ...(_earningsData['rides'] as List<RideModel>).map((ride) => Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(Helpers.formatDateTime(ride.timestamp), style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                      Text(Helpers.formatCurrency(ride.fare ?? 0), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.success)),
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
                                      Expanded(child: Text(ride.pickupLocation.address ?? 'Pickup', style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(color: AppColors.dropoffColor.withOpacity(0.1), shape: BoxShape.circle),
                                        child: const Icon(Icons.location_on, size: 8, color: AppColors.dropoffColor),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(ride.dropoffLocation.address ?? 'Dropoff', style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )),
                  ],
                ),
              ),
            ),
    );
  }
}
