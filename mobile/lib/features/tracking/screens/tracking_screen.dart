import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/api/api_config.dart';
import '../../../core/api/autoserve_api.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/auth/secure_token_store.dart';
import '../../../shared/models/service_request.dart';

final _trackingDetailProvider =
    FutureProvider.autoDispose.family<ServiceRequestDto, String>((ref, id) {
  return ref.watch(autoserveApiProvider).getServiceRequest(id);
});

/// Live location tracking for one service_request (PLAN.md §5.2) — shared
/// between the customer (receive-only) and the assigned provider (also
/// publishes), mirroring apps.tracking.consumers' single-consumer design:
/// the backend itself gates who may publish, this screen just decides
/// whether to show the "share my location" control.
class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key, required this.requestId});
  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(_trackingDetailProvider(requestId));

    return Scaffold(
      appBar: AppBar(title: const Text('Live tracking')),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(_trackingDetailProvider(requestId)),
            child: const Text('Could not load this request — tap to retry'),
          ),
        ),
        data: (sr) => _TrackingBody(sr: sr),
      ),
    );
  }
}

enum _ConnectionState { connecting, open, closed }

class _TrackingBody extends ConsumerStatefulWidget {
  const _TrackingBody({required this.sr});
  final ServiceRequestDto sr;

  @override
  ConsumerState<_TrackingBody> createState() => _TrackingBodyState();
}

class _TrackingBodyState extends ConsumerState<_TrackingBody> {
  // Reconnects a fixed number of times with a flat delay — deliberately
  // minimal (matches web/'s TrackingMap.tsx), a tracking session is one
  // active job, not worth more machinery than that.
  static const _reconnectDelay = Duration(seconds: 3);
  static const _maxReconnectAttempts = 5;
  // PLAN.md §5.2: "emits lat/lng every 5s".
  static const _publishInterval = Duration(seconds: 5);

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _publishTimer;
  Timer? _reconnectTimer;
  _ConnectionState _connection = _ConnectionState.connecting;
  ll.LatLng? _live;
  bool _sharing = false;
  String? _shareError;
  int _reconnectAttempts = 0;
  bool _disposed = false;

  bool get _isProvider {
    final user = ref.read(authControllerProvider).value;
    return user != null && user.id == widget.sr.provider?.id;
  }

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    final token = await ref.read(secureTokenStoreProvider).readAccess();
    if (token == null || _disposed) return;

    setState(() => _connection = _ConnectionState.connecting);
    final uri = Uri.parse(
      '${ApiConfig.wsBaseUrl}/ws/api/v1/tracking/${widget.sr.id}/?token=$token',
    );
    final channel = WebSocketChannel.connect(uri);
    _channel = channel;

    unawaited(
      channel.ready.then((_) {
        if (!_disposed) {
          _reconnectAttempts = 0;
          setState(() => _connection = _ConnectionState.open);
        }
      }).catchError((_) {
        // Surfaced via the stream's onError below instead.
      }),
    );

    _sub = channel.stream.listen(
      (event) {
        if (_disposed) return;
        try {
          final data = jsonDecode(event as String) as Map<String, dynamic>;
          final lat = data['lat'];
          final lng = data['lng'];
          if (lat is num && lng is num) {
            setState(() => _live = ll.LatLng(lat.toDouble(), lng.toDouble()));
          }
        } catch (_) {
          // Ignore malformed frames rather than crashing the map.
        }
      },
      onDone: _handleClosed,
      onError: (_) => _handleClosed(),
    );
  }

  void _handleClosed() {
    if (_disposed) return;
    setState(() => _connection = _ConnectionState.closed);
    if (_reconnectAttempts >= _maxReconnectAttempts) return;
    _reconnectAttempts++;
    _reconnectTimer = Timer(_reconnectDelay, _connect);
  }

  Future<void> _toggleSharing() async {
    if (_sharing) {
      _publishTimer?.cancel();
      setState(() => _sharing = false);
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      setState(() => _shareError = 'Location permission is required to share your position.');
      return;
    }
    if (!mounted) return;

    setState(() {
      _shareError = null;
      _sharing = true;
    });
    unawaited(_publish());
    _publishTimer = Timer.periodic(_publishInterval, (_) => _publish());
  }

  Future<void> _publish() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      _channel?.sink.add(jsonEncode({'lat': position.latitude, 'lng': position.longitude}));
    } catch (_) {
      // A single failed fix isn't worth surfacing — the next tick retries.
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _publishTimer?.cancel();
    _reconnectTimer?.cancel();
    _sub?.cancel();
    unawaited(_channel?.sink.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sr = widget.sr;
    final pickup = ll.LatLng(sr.pickupLocation.lat, sr.pickupLocation.lng);
    final dropoff =
        sr.dropoffLocation != null ? ll.LatLng(sr.dropoffLocation!.lat, sr.dropoffLocation!.lng) : null;
    final center = _live ?? pickup;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              _ConnectionBadge(state: _connection),
              const Spacer(),
              if (_isProvider)
                FilledButton.tonal(
                  onPressed: _toggleSharing,
                  child: Text(_sharing ? 'Stop sharing location' : 'Share my location'),
                ),
            ],
          ),
        ),
        if (_shareError != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Text(_shareError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: FlutterMap(
            options: MapOptions(initialCenter: center, initialZoom: 13),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.autoserve.mobile',
              ),
              MarkerLayer(
                markers: [
                  Marker(point: pickup, width: 18, height: 18, child: _dot(Colors.blue)),
                  if (dropoff != null)
                    Marker(point: dropoff, width: 18, height: 18, child: _dot(Colors.green)),
                  if (_live != null)
                    Marker(point: _live!, width: 18, height: 18, child: _dot(Colors.orange)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dot(Color color) => Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      );
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({required this.state});
  final _ConnectionState state;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      _ConnectionState.open => ('Live', Colors.green),
      _ConnectionState.connecting => ('Connecting…', Colors.blue),
      _ConnectionState.closed => ('Disconnected', Colors.red),
    };
    return Chip(label: Text(label), backgroundColor: color.withValues(alpha: 0.15));
  }
}
