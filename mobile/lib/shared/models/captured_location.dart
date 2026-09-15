import 'package:latlong2/latlong.dart' as ll;

/// Pairs a picked map point with its (optional, in-flight) reverse-geocoded
/// display name. Never crosses a JSON boundary — it's a pure UI-state
/// helper for the capture screens, unlike [LatLngPoint] which mirrors the
/// backend's wire shape — so this is a plain class, not `@freezed`.
class CapturedLocation {
  const CapturedLocation({required this.point, this.address, this.resolving = false});

  final ll.LatLng point;
  final String? address;
  final bool resolving;

  CapturedLocation copyWith({ll.LatLng? point, String? address, bool? resolving}) {
    return CapturedLocation(
      point: point ?? this.point,
      address: address ?? this.address,
      resolving: resolving ?? this.resolving,
    );
  }
}
