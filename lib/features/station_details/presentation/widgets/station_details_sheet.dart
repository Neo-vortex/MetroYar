import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../shared/enums/amenity.dart';
import '../../../../shared/models/station.dart';
import '../../../../shared/widgets/line_chip.dart';
import '../../../train_schedule/presentation/widgets/train_schedule_sheet.dart';

/// A bottom sheet showing everything known about a single [Station]:
/// the lines it sits on, its address, and a grid of every amenity it has
/// — pulled straight from the `stations` table's boolean columns.
class StationDetailsSheet extends StatelessWidget {
  final Station station;

  const StationDetailsSheet({super.key, required this.station});

  static Future<void> show(BuildContext context, Station station) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StationDetailsSheet(station: station),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final amenities = Amenity.presentOn(station);

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.train_rounded,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.displayName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (station.nameEn.isNotEmpty)
                          Text(
                            station.nameEn,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (station.lines.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: station.lines
                      .map((line) => LineChip(lineNumber: line))
                      .toList(),
                ),
              ],
              if (station.address != null && station.address!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 18, color: colors.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        station.address!,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openInMaps(station),
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text('نقشه'),
                    ),
                  ),
                  if (station.lines.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => TrainScheduleSheet.show(
                          context,
                          stationNameEn: station.nameEn,
                          stationNameFa: station.displayName,
                          lineNumber: station.lines.first,
                        ),
                        icon: const Icon(Icons.schedule_rounded, size: 18),
                        label: const Text('زمان‌بندی قطار'),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'امکانات ایستگاه',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              if (amenities.isEmpty)
                Text(
                  'امکانات ثبت‌شده‌ای برای این ایستگاه وجود ندارد.',
                  style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: amenities.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3.1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final amenity = amenities[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(amenity.icon, size: 17, color: colors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              amenity.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openInMaps(Station station) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query='
      '${station.latitude},${station.longitude}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
