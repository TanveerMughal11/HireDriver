import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class TripItem {
  final String title;
  final String tag;
  final String amount;
  final String status;
  final String route;
  final String distance;
  final String time;
  final DateTime createdAt;
  final IconData icon;
  final Color iconColor;
  final int rating;

  TripItem({
    required this.title,
    required this.tag,
    required this.amount,
    required this.status,
    required this.route,
    required this.distance,
    required this.time,
    required this.createdAt,
    required this.icon,
    required this.iconColor,
    required this.rating,
  });

  factory TripItem.fromRide(Map<String, dynamic> ride) {
    final createdAtString = ride['createdAt'] ?? '';
    return TripItem(
      title: 'Book a Ride',
      tag: ride['vehicleLabel'] ?? 'Ride',
      amount: 'PKR ${ride['pricing']?['offeredFare'] ?? 0}',
      status: ride['status'] ?? 'draft',
      route:
          '${ride['pickup']?['address'] ?? 'Pickup'} → ${ride['dropoff']?['address'] ?? 'Dropoff'}',
      distance:
          '${ride['route']?['distanceKm']?.toStringAsFixed(1) ?? ''} km',
      time: _formatDate(createdAtString),
      createdAt: _parseDate(createdAtString),
      icon: Icons.directions_car_rounded,
      iconColor: AppColors.primary,
      rating: 0,
    );
  }

  factory TripItem.fromHire(Map<String, dynamic> hire) {
    final createdAtString = hire['createdAt'] ?? '';
    return TripItem(
      title: 'Hire Driver',
      tag: hire['serviceOption']?['title'] ?? 'Hire',
      amount: 'PKR ${hire['pricing']?['totalFare'] ?? 0}',
      status: hire['status'] ?? 'draft',
      route:
          '${hire['pickup']?['address'] ?? 'Pickup'} → ${hire['dropoff']?['address'] ?? 'Dropoff'}',
      distance:
          '${hire['route']?['estimatedDistanceKm']?.toStringAsFixed(1) ?? ''} km',
      time: _formatDate(createdAtString),
      createdAt: _parseDate(createdAtString),
      icon: Icons.local_taxi_rounded,
      iconColor: const Color(0xFFF2B42E),
      rating: 0,
    );
  }

  static DateTime _parseDate(String isoDate) {
    try {
      return DateTime.parse(isoDate).toLocal();
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  static String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date).inDays;
      if (difference == 0) return 'Today';
      if (difference == 1) return 'Yesterday';
      return '$difference days ago';
    } catch (_) {
      return isoDate;
    }
  }
}