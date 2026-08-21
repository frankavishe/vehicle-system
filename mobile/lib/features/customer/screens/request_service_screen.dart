import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/api/autoserve_api.dart';
import '../../../shared/models/service_request.dart';
import 'my_requests_screen.dart';

/// GPS pickup via geolocator (flagged, not named in PLAN §6); dropoff
/// only collected for RECOVERY, per the backend's dropoff-required-for-
/// RECOVERY validation (apps/dispatch/serializers.py).
class RequestServiceScreen extends ConsumerStatefulWidget {
  const RequestServiceScreen({super.key});

  @override
  ConsumerState<RequestServiceScreen> createState() => _RequestServiceScreenState();
}

class _RequestServiceScreenState extends ConsumerState<RequestServiceScreen> {
  ServiceType _serviceType = ServiceType.mechanic;
  final _description = TextEditingController();
  Position? _pickup;
  Position? _dropoff;
  bool _locating = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<Position?> _getCurrentPosition() async {
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
    return Geolocator.getCurrentPosition();
  }

  Future<void> _capturePickup() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    final position = await _getCurrentPosition();
    setState(() {
      _pickup = position;
      _locating = false;
    });
  }

  Future<void> _captureDropoff() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    final position = await _getCurrentPosition();
    setState(() {
      _dropoff = position;
      _locating = false;
    });
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
      await ref.read(autoserveApiProvider).createServiceRequest(
            serviceType: _serviceType,
            pickupLat: _pickup!.latitude,
            pickupLng: _pickup!.longitude,
            dropoffLat: _dropoff?.latitude,
            dropoffLng: _dropoff?.longitude,
            problemDescription: _description.text.trim().isEmpty ? null : _description.text.trim(),
          );
      if (!mounted) return;
      ref.invalidate(myRequestsProvider);
      setState(() {
        _pickup = null;
        _dropoff = null;
        _description.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent — nearby providers have been notified.')),
      );
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
                value: ServiceType.recovery, label: Text('Towing'), icon: Icon(Icons.local_shipping)),
          ],
          selected: {_serviceType},
          onSelectionChanged: (s) => setState(() => _serviceType = s.first),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _description,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'What\'s wrong?',
            hintText: 'e.g. Flat tyre, engine won\'t start...',
            border: OutlineInputBorder(),
          ),
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
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Request now'),
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
  });

  final String label;
  final Position? position;
  final bool loading;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.my_location),
        title: Text(label),
        subtitle: Text(
          position == null
              ? 'Not captured yet'
              : '${position!.latitude.toStringAsFixed(5)}, ${position!.longitude.toStringAsFixed(5)}',
        ),
        trailing: loading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : TextButton(onPressed: onCapture, child: const Text('Capture')),
      ),
    );
  }
}
