import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../../core/api/nominatim_client.dart';
import '../../../shared/models/captured_location.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';

/// Lets the customer drop a pin anywhere on the map, instead of only
/// capturing wherever the device currently is. Needed for RECOVERY
/// drop-off in particular: the customer is standing next to their broken
/// vehicle, not at the garage they want it towed to, so a plain GPS
/// capture (as pickup uses) can never express that point. Returns the
/// picked point via `context.pop(CapturedLocation)`; null if backed out
/// of without picking one.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, this.initialCenter});

  /// Where to center the map before the user has tapped anything —
  /// typically the already-captured pickup point, so drop-off starts
  /// nearby rather than defaulting to a fixed fallback city.
  final ll.LatLng? initialCenter;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // Dar es Salaam — matches the backend's own test/demo fixture
  // (apps/dispatch/tests/factories.py's DAR_ES_SALAAM) used when there's
  // no better starting point (no initialCenter, GPS not available yet).
  static const _fallbackCenter = ll.LatLng(-6.7924, 39.2083);

  final _mapController = MapController();
  final _nominatim = NominatimClient();
  CapturedLocation? _picked;
  bool _locating = false;
  String? _error;

  void _pickPoint(ll.LatLng point) {
    setState(() {
      _error = null;
      _picked = CapturedLocation(point: point, resolving: true);
    });
    _nominatim.reverseGeocode(lat: point.latitude, lng: point.longitude).then((address) {
      // Guard against a slower, now-stale lookup overwriting a newer pick.
      if (!mounted || _picked?.point != point) return;
      setState(() => _picked = CapturedLocation(point: point, address: address));
    });
  }

  Future<void> _useMyLocation() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() => _error = 'Location permission is required.');
        return;
      }
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() => _error = 'Please enable location services.');
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      final point = ll.LatLng(position.latitude, position.longitude);
      _mapController.move(point, 15);
      _pickPoint(point);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.initialCenter ?? _fallbackCenter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose drop-off location'),
        actions: [
          IconButton(
            tooltip: 'Use my current location',
            icon: _locating
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location),
            onPressed: _locating ? null : _useMyLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13,
              onTap: (_, point) => _pickPoint(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.autoserve.mobile',
              ),
              if (_picked != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _picked!.point,
                      width: 40,
                      height: 40,
                      alignment: Alignment.topCenter,
                      child: Icon(Icons.location_pin, size: 40, color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_error != null)
                    AppCard(
                      padding: AppCardPadding.sm,
                      child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    )
                  else if (_picked != null)
                    AppCard(
                      padding: AppCardPadding.sm,
                      child: Text(
                        _picked!.resolving
                            ? 'Locating address…'
                            : _picked!.address ??
                                '${_picked!.point.latitude.toStringAsFixed(5)}, '
                                    '${_picked!.point.longitude.toStringAsFixed(5)}',
                      ),
                    )
                  else
                    const AppCard(
                      padding: AppCardPadding.sm,
                      child: Text('Tap the map to drop a pin, or use your current location.'),
                    ),
                  const SizedBox(height: 8),
                  AppButton(
                    label: 'Use this location',
                    onPressed: _picked == null ? null : () => context.pop(_picked),
                    expand: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
