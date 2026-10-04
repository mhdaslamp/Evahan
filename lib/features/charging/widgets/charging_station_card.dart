import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/charging_station.dart';
import '../screens/charging_station_details_screen.dart';
import '../../../theme/app_theme.dart';

/// Compact list card for a single charging station.
/// Styled to match Evahan's existing card design system.
class ChargingStationCard extends StatelessWidget {
  final ChargingStation station;
  final VoidCallback? onTap;

  const ChargingStationCard({
    super.key,
    required this.station,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ChargingStationDetailsScreen(station: station),
                ),
              ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor, width: 0.8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bolt icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bolt, color: AppColors.green, size: 26),
              ),
              const SizedBox(width: 12),

              // Info column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + distance row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            station.name,
                            style: GoogleFonts.poppins(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (station.distanceLabel.isNotEmpty)
                          Text(
                            station.distanceLabel,
                            style: GoogleFonts.poppins(
                              color: AppColors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Address
                    if (station.address != null)
                      Text(
                        station.address!,
                        style: GoogleFonts.poppins(
                          color: AppColors.grey,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),

                    // Chips row
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Power chip
                        if (station.chargingPowerKw != null)
                          _Chip(
                            label:
                                '⚡ ${station.chargingPowerKw!.toStringAsFixed(0)} kW',
                            color: AppColors.green,
                          )
                        else
                          _Chip(
                            label: '⚡ Power N/A',
                            color: AppColors.grey,
                          ),

                        // Connector chips
                        if (station.connectorTypes != null &&
                            station.connectorTypes!.isNotEmpty)
                          ...station.connectorTypes!.take(2).map(
                                (c) => _Chip(label: '🔌 $c', color: AppColors.green),
                              )
                        else
                          _Chip(
                            label: '🔌 N/A',
                            color: AppColors.grey,
                          ),

                        // Open/closed badge
                        if (station.isOpenNow != null)
                          _Chip(
                            label: station.isOpenNow! ? 'Open' : 'Closed',
                            color: station.isOpenNow!
                                ? AppColors.green
                                : Colors.redAccent,
                          ),
                      ],
                    ),

                    // Rating
                    if (station.rating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Color(0xFFFFC107), size: 14),
                          const SizedBox(width: 3),
                          Text(
                            '${station.rating!.toStringAsFixed(1)}',
                            style: GoogleFonts.poppins(
                              color: AppColors.grey,
                              fontSize: 11,
                            ),
                          ),
                          if (station.reviewCount != null)
                            Text(
                              ' (${station.reviewCount})',
                              style: GoogleFonts.poppins(
                                color: AppColors.grey,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  color: AppColors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Skeleton loading card — shown while stations are loading.
class ChargingStationCardSkeleton extends StatelessWidget {
  const ChargingStationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _SkeletonBox(width: 44, height: 44, radius: 10),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SkeletonBox(width: double.infinity, height: 12, radius: 4),
                  const SizedBox(height: 6),
                  _SkeletonBox(width: 160, height: 10, radius: 4),
                  const SizedBox(height: 6),
                  Row(children: [
                    _SkeletonBox(width: 70, height: 18, radius: 4),
                    const SizedBox(width: 6),
                    _SkeletonBox(width: 50, height: 18, radius: 4),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonBox(
      {required this.width, required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.borderColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
