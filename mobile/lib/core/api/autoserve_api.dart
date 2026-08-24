import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/app_user.dart';
import '../../shared/models/notification_item.dart';
import '../../shared/models/parts_sourcing_request.dart';
import '../../shared/models/provider_document.dart';
import '../../shared/models/service_request.dart';
import '../../shared/models/spare_part_summary.dart';
import 'dio_client.dart';

/// Every backend call the app makes, in one place — the client-side
/// analog of the backend's views.py per-app organization. Feature
/// screens go through this rather than holding a raw Dio reference.
class AutoserveApi {
  AutoserveApi(this._dio);

  final Dio _dio;

  // --- Profile ---
  Future<AppUser> me() async {
    final response = await _dio.get('/users/me');
    return AppUser.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AppUser> updateMe(Map<String, dynamic> patch) async {
    final response = await _dio.patch('/users/me', data: patch);
    return AppUser.fromJson(response.data as Map<String, dynamic>);
  }

  // --- Provider profile ---
  Future<void> setAvailability(bool isAvailable) =>
      _dio.patch('/providers/me/availability', data: {'is_available': isAvailable});

  Future<void> updateLocation({required double lat, required double lng}) =>
      _dio.patch('/providers/me/location', data: {'lat': lat, 'lng': lng});

  Future<List<ProviderDocumentDto>> myDocuments() async {
    final response = await _dio.get('/providers/me/documents');
    final data = response.data;
    final results = data is Map ? data['results'] as List : data as List;
    return results
        .map((e) => ProviderDocumentDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProviderDocumentDto> uploadDocument({required String filePath, String? docType}) async {
    final form = FormData.fromMap({
      'doc_type': ?docType,
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post('/providers/me/documents', data: form);
    return ProviderDocumentDto.fromJson(response.data as Map<String, dynamic>);
  }

  // --- Service requests ---
  Future<List<ServiceRequestDto>> listServiceRequests({String? status}) async {
    final response = await _dio.get(
      '/service-requests',
      queryParameters: status != null ? {'status': status} : null,
    );
    return (response.data as List)
        .map((e) => ServiceRequestDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ServiceRequestDto> getServiceRequest(String id) async {
    final response = await _dio.get('/service-requests/$id');
    return ServiceRequestDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ServiceRequestDto> createServiceRequest({
    required ServiceType serviceType,
    required double pickupLat,
    required double pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    String? problemDescription,
  }) async {
    final response = await _dio.post('/service-requests', data: {
      'service_type': serviceType == ServiceType.mechanic ? 'MECHANIC' : 'RECOVERY',
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'dropoff_lat': ?dropoffLat,
      'dropoff_lng': ?dropoffLng,
      'problem_description': ?problemDescription,
    });
    return ServiceRequestDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// Returns null on a 409 (someone else already accepted) rather than
  /// throwing — callers show "already taken" instead of a generic error.
  Future<ServiceRequestDto?> acceptServiceRequest(String id) async {
    try {
      final response = await _dio.post('/service-requests/$id/accept');
      return ServiceRequestDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) return null;
      rethrow;
    }
  }

  Future<ServiceRequestDto> updateServiceRequestStatus(String id, ServiceStatus status) async {
    final response = await _dio.patch(
      '/service-requests/$id/status',
      data: {'status': serviceStatusWireValue(status)},
    );
    return ServiceRequestDto.fromJson(response.data as Map<String, dynamic>);
  }

  // --- Catalog (read-only lookup for the parts-sourcing picker) ---
  // No free-text search filter exists on GET /parts (apps/catalog/filters.py
  // only supports make/model/category/year) — fetches the first page and
  // filters client-side by title. Flagged simplification: fine at this
  // project's catalog scale, not a real search experience.
  Future<List<SparePartSummary>> browseSpareParts() async {
    final response = await _dio.get('/parts');
    final data = response.data;
    final results = data is Map ? data['results'] as List : data as List;
    return results.map((e) => SparePartSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  // --- Parts sourcing ---
  Future<List<PartsSourcingRequestDto>> listPartsRequests(String serviceRequestId) async {
    final response = await _dio.get('/service-requests/$serviceRequestId/parts-requests');
    return (response.data as List)
        .map((e) => PartsSourcingRequestDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PartsSourcingRequestDto> createPartsRequest({
    required String serviceRequestId,
    required String sparePartId,
    required int quantity,
  }) async {
    final response = await _dio.post(
      '/service-requests/$serviceRequestId/parts-requests',
      data: {'spare_part_id': sparePartId, 'quantity': quantity},
    );
    return PartsSourcingRequestDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PartsSourcingRequestDto> approvePartsRequest(String id, bool approved) async {
    final response = await _dio.patch('/parts-requests/$id/approve', data: {'approved': approved});
    return PartsSourcingRequestDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// Returns the new order's id; the caller (parts-approval screen) hands
  /// this straight to url_launcher against the existing hosted checkout —
  /// no native payment UI (flagged decision, PLAN §7 item 9).
  Future<String> convertPartsRequestToOrder(String id, {String? deliveryAddress}) async {
    final response = await _dio.post(
      '/parts-requests/$id/order',
      data: {'delivery_address': ?deliveryAddress},
    );
    return response.data['order_id'] as String;
  }

  // --- Notifications ---
  Future<List<NotificationItem>> listNotifications() async {
    final response = await _dio.get('/users/me/notifications');
    final data = response.data;
    final results = data is Map ? data['results'] as List : data as List;
    return results.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> markNotificationRead(String id) => _dio.patch('/notifications/$id/read');

  Future<void> registerDeviceToken({required String fcmToken, required String platform}) =>
      _dio.post('/users/me/device-tokens', data: {'fcm_token': fcmToken, 'platform': platform});
}

final autoserveApiProvider = Provider<AutoserveApi>((ref) {
  return AutoserveApi(ref.watch(dioProvider));
});
