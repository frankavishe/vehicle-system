import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../../core/api/autoserve_api.dart';
import '../../../core/api/nominatim_client.dart';
import '../../../shared/models/captured_location.dart';
import '../../../shared/models/service_request.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_text_field.dart';
import 'my_requests_screen.dart';

/// GPS pickup via geolocator (flagged, not named in PLAN §6); dropoff
/// only collected for RECOVERY, per the backend's dropoff-required-for-
/// RECOVERY validation (apps/dispatch/serializers.py). Drop-off also
/// offers "Pick on map" (LocationPickerScreen) alongside GPS capture —
/// unlike pickup, which is always wherever the customer is standing
/// right now, drop-off is very often somewhere else entirely (the garage
/// the vehicle is being towed to), so a plain GPS capture can't express
/// it.
class RequestServiceScreen extends ConsumerStatefulWidget {
  const RequestServiceScreen({super.key});

  @override
  ConsumerState<RequestServiceScreen> createState() => _RequestServiceScreenState();
}

class _RequestServiceScreenState extends ConsumerState<RequestServiceScreen> {
  ServiceType _serviceType = ServiceType.mechanic;
  final _description = TextEditingController();
  final _nominatim = NominatimClient();
  CapturedLocation? _pickup;
  CapturedLocation? _dropoff;
  bool _locating = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<ll.LatLng?> _getCurrentPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      setState(() => _error = 'Location permission is required to request service.');
      return null;
    }
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() => _error = 'Please enable location services.');
      return null;
    }
    final position = await Geolocator.getCurrentPosition();
    return ll.LatLng(position.latitude, position.longitude);
  }

  Future<void> _capturePickup() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    final position = await _getCurrentPosition();
    setState(() {
      _pickup = position == null ? null : CapturedLocation(point: position, resolving: true);
      _locating = false;
    });
    if (position != null) _resolvePickupAddress(position);
  }

  Future<void> _captureDropoff() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    final position = await _getCurrentPosition();
    setState(() {
      _dropoff = position == null ? null : CapturedLocation(point: position, resolving: true);
      _locating = false;
    });
    if (position != null) _resolveDropoffAddress(position);
  }

  void _resolvePickupAddress(ll.LatLng point) {
    _nominatim.reverseGeocode(lat: point.latitude, lng: point.longitude).then((address) {
      // Guard against a slower, now-stale lookup overwriting a newer capture.
      if (!mounted || _pickup?.point != point) return;
      setState(() => _pickup = CapturedLocation(point: point, address: address));
    });
  }

  void _resolveDropoffAddress(ll.LatLng point) {
    _nominatim.reverseGeocode(lat: point.latitude, lng: point.longitude).then((address) {
      if (!mounted || _dropoff?.point != point) return;
      setState(() => _dropoff = CapturedLocation(point: point, address: address));
    });
  }

  /// Opens LocationPickerScreen (centered on pickup if we have it — the
  /// garage being towed to is usually somewhere near where the vehicle
  /// broke down, not on the opposite side of the map) and waits for the
  /// user to drop a pin, rather than assuming drop-off is wherever this
  /// device currently is.
  Future<void> _pickDropoffOnMap() async {
    final picked = await context.push<CapturedLocation>(
      '/customer/pick-location',
      extra: _pickup?.point,
    );
    if (picked != null && mounted) {
      setState(() {
        _dropoff = picked;
        _error = null;
      });
      // The picker screen's own lookup may not have finished before the
      // user tapped "Use this location" — finish it here rather than
      // leaving the tile stuck showing "locating address…" forever.
      if (picked.resolving) _resolveDropoffAddress(picked.point);
    }
  }

  Future<void> _submit() async {
    if (_pickup == null) {
      setState(() => _error = 'Capture your pickup location first.');
      return;
    }
    if (_serviceType == ServiceType.recovery && _dropoff == null) {
      setState(() => _error = 'Recovery requests need a drop-off location too.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(autoserveApiProvider)
          .createServiceRequest(
            serviceType: _serviceType,
            pickupLat: _pickup!.point.latitude,
            pickupLng: _pickup!.point.longitude,
            pickupAddress: _pickup!.address,
            dropoffLat: _dropoff?.point.latitude,
            dropoffLng: _dropoff?.point.longitude,
            dropoffAddress: _dropoff?.address,
            problemDescription: _description.text.trim().isEmpty ? null : _description.text.trim(),
          );
      if (!mounted) return;
      ref.invalidate(myRequestsProvider);
      setState(() {
        _pickup = null;
        _dropoff = null;
        _description.clear();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Request sent — nearby providers have been notified.')));
    } on DioException catch (e) {
      setState(() => _error = e.response?.data?['detail']?.toString() ?? 'Could not send request.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SegmentedButton<ServiceType>(
          segments: const [
            ButtonSegment(value: ServiceType.mechanic, label: Text('Mechanic'), icon: Icon(Icons.build)),
            ButtonSegment(
              value: ServiceType.recovery,
              label: Text('Towing'),
              icon: Icon(Icons.local_shipping),
            ),
          ],
          selected: {_serviceType},
          onSelectionChanged: (s) => setState(() => _serviceType = s.first),
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: "What's wrong?",
          controller: _description,
          maxLines: 3,
          hintText: "e.g. Flat tyre, engine won't start...",
        ),
        const SizedBox(height: 20),
        _LocationTile(
          label: 'Pickup location',
          position: _pickup,
          loading: _locating,
          onCapture: _capturePickup,
        ),
        if (_serviceType == ServiceType.recovery) ...[
          const SizedBox(height: 12),
          _LocationTile(
            label: 'Drop-off location',
            position: _dropoff,
            loading: _locating,
            onCapture: _captureDropoff,
            onPickMap: _pickDropoffOnMap,
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: 24),
        AppButton(
          label: 'Request now',
          onPressed: _submitting ? null : _submit,
          loading: _submitting,
          expand: true,
        ),
      ],
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.label,
    required this.position,
    required this.loading,
    required this.onCapture,
    this.onPickMap,
  });

  final String label;
  final CapturedLocation? position;
  final bool loading;
  final VoidCallback onCapture;
  // Only drop-off passes this — pickup is always "wherever the customer
  // currently is", so map-picking it wouldn't make sense.
  final VoidCallback? onPickMap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppCardPadding.sm,
      child: Row(
        children: [
          const Icon(Icons.my_location),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleSmall),
                Text(
                  position == null
                      ? 'Not captured yet'
                      : position!.resolving
                          ? 'Locating address…'
                          : position!.address ??
                              '${position!.point.latitude.toStringAsFixed(5)}, '
                                  '${position!.point.longitude.toStringAsFixed(5)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (loading)
            const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onPickMap != null) TextButton(onPressed: onPickMap, child: const Text('Pick on map')),
                TextButton(onPressed: onCapture, child: const Text('Capture')),
              ],
            ),
        ],
      ),
    );
  }
}
