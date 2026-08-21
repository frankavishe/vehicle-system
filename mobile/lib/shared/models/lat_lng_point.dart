import 'package:freezed_annotation/freezed_annotation.dart';

part 'lat_lng_point.freezed.dart';
part 'lat_lng_point.g.dart';

/// Mirrors the backend's `{"lat": ..., "lng": ...}` shape for every
/// PointField the API exposes (pickup/dropoff/current_location).
@freezed
class LatLngPoint with _$LatLngPoint {
  const factory LatLngPoint({required double lat, required double lng}) = _LatLngPoint;

  factory LatLngPoint.fromJson(Map<String, dynamic> json) => _$LatLngPointFromJson(json);
}
