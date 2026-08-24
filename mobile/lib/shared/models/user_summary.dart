import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_summary.freezed.dart';
part 'user_summary.g.dart';

/// Mirrors dispatch/serializers.py's `_user_summary()` — the minimal
/// customer/provider shape nested inside a ServiceRequest.
@freezed
class UserSummary with _$UserSummary {
  const factory UserSummary({
    required String id,
    required String fullName,
    required String phone,
  }) = _UserSummary;

  factory UserSummary.fromJson(Map<String, dynamic> json) => _$UserSummaryFromJson(json);
}
