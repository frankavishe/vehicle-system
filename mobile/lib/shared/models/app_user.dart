import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

enum UserRole {
  @JsonValue('CUSTOMER')
  customer,
  @JsonValue('MECHANIC')
  mechanic,
  @JsonValue('RECOVERY')
  recovery,
  @JsonValue('ADMIN')
  admin,
}

/// Roles a user may pick for themselves at /auth/register — mirrors
/// backend apps/users/models.py's SELF_SERVICE_ROLES. ADMIN is granted
/// only server-side, never self-service.
const selfServiceRoles = [UserRole.customer, UserRole.mechanic, UserRole.recovery];

/// Mirrors apps/users/serializers.py's MeSerializer (GET/PATCH /users/me).
@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    required String phone,
    @JsonKey(name: 'full_name') required String fullName,
    required UserRole role,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'is_verified') required bool isVerified,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}
