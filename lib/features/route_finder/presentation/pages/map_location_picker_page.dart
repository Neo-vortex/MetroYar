import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../shared/models/station.dart';

/// A Google-Maps-style picker: pan/zoom a real street map, tap anywhere to
/// drop a pin, then confirm. Returns the picked [LatLng] via
/// `Navigator.pop`, or `null` if the user backs out.
///
/// Known metro stations are shown as small markers purely for orientation
/// — tapping the map (not a marker) is what sets the pin; the caller is
/// the one that resolves the pin to the nearest station.
class MapLocationPickerPage extends StatefulWidget {
  final List<Station> stations;
  final LatLng initialCenter;
  final String title;

  const MapLocationPickerPage({
    super.key,
    required this.stations,
    required this.initialCenter,
    required this.title,
  });

  @override
  State<MapLocationPickerPage> createState() => _MapLocationPickerPageState();
}

class _MapLocationPickerPageState extends State<MapLocationPickerPage> {
  late LatLng? _picked = widget.initialCenter;
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialCenter,
              initialZoom: 12,
              minZoom: 9,
              maxZoom: 18,
              onTap: (tapPosition, point) =>
                  setState(() => _picked = point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'ir.neovortex.metro_yar',
              ),
              MarkerLayer(
                markers: [
                  for (final station in widget.stations)
                    Marker(
                      point: LatLng(station.latitude, station.longitude),
                      width: 8,
                      height: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  if (_picked != null)
                    Marker(
                      point: _picked!,
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 44,
                        color: colors.error,
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      margin: EdgeInsets.only(left: 170),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Text(
                          'روی نقشه ضربه بزنید تا نقطهٔ موردنظر انتخاب شود.'
                          ' نزدیک‌ترین ایستگاه به‌طور خودکار پیدا می‌شود.',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _picked == null
            ? null
            : () => Navigator.of(context).pop(_picked),
        icon: const Icon(Icons.check_rounded),
        label: const Text('تأیید این نقطه'),
      ),
    );
  }
}
