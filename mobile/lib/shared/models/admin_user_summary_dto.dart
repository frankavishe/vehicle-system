import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_user_summary_dto.freezed.dart';
part 'admin_user_summary_dto.g.dart';

/// Mirrors apps/users/serializers.py's AdminUserListSerializer — used by
/// both `GET /admin/users` (search) and `PATCH .../status`'s response
/// (contracts/admin-mobile-api.md). Shows enough detail (name, email,
/// role, active/verification status) to disambiguate similarly-named
/// accounts before acting, per spec.md FR-005.
@freezed
class AdminUserSummaryDto with _$AdminUserSummaryDto {
  const factory AdminUserSummaryDto({
    required String id,
    required String email,
    String? phone,
    @JsonKey(name: 'full_name') required String fullName,
    required String role, // CUSTOMER | MECHANIC | RECOVERY | ADMIN
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'is_verified') required bool isVerified,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _AdminUserSummaryDto;

  factory AdminUserSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$AdminUserSummaryDtoFromJson(json);
}
