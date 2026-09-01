from django.core.exceptions import ValidationError as DjangoValidationError
from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

from .models import SELF_SERVICE_ROLES, User, UserRole
from .validators import normalize_tz_phone


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    role = serializers.ChoiceField(choices=[(r.value, r.label) for r in SELF_SERVICE_ROLES])

    class Meta:
        model = User
        fields = ["id", "email", "phone", "full_name", "role", "password"]
        read_only_fields = ["id"]
        # DRF's auto-generated UniqueValidator runs on the raw input value,
        # before validate_phone below normalizes it — so "0712345678" would
        # sail past uniqueness even though it normalizes to an already-used
        # "255712345678", and the create_user() call would then crash with
        # an unhandled IntegrityError. Uniqueness is checked manually below,
        # post-normalization, instead.
        extra_kwargs = {"phone": {"validators": []}}

    def validate_phone(self, value):
        try:
            normalized = normalize_tz_phone(value)
        except DjangoValidationError as exc:
            raise serializers.ValidationError(exc.message) from exc
        if User.objects.filter(phone=normalized).exists():
            raise serializers.ValidationError("A user with this phone number already exists.")
        return normalized

    def validate_password(self, value):
        try:
            validate_password(value)
        except DjangoValidationError as exc:
            raise serializers.ValidationError(exc.messages) from exc
        return value

    def create(self, validated_data):
        return User.objects.create_user(**validated_data)


class MeSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            "id", "email", "phone", "full_name", "role",
            "is_active", "is_verified", "created_at",
        ]
        read_only_fields = ["id", "email", "role", "is_active", "is_verified", "created_at"]

    def validate_phone(self, value):
        try:
            return normalize_tz_phone(value)
        except DjangoValidationError as exc:
            raise serializers.ValidationError(exc.message) from exc


class AdminUserListSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            "id", "email", "phone", "full_name", "role",
            "is_active", "is_verified", "created_at",
        ]
        read_only_fields = fields


class AdminUserRoleSerializer(serializers.ModelSerializer):
    role = serializers.ChoiceField(choices=UserRole.choices)

    class Meta:
        model = User
        fields = ["role"]


class AdminUserStatusSerializer(serializers.ModelSerializer):
    """003-admin-mobile-app FR-005 — suspend (`is_active=False`) /
    reinstate (`is_active=True`). Sibling of AdminUserRoleSerializer
    above, not folded into it — see plan.md's Complexity Tracking for why
    a `/role`-named endpoint shouldn't also silently accept `is_active`.

    Returns the full user (contracts/admin-mobile-api.md: "the updated
    user, same shape as the list item above") rather than just
    `is_active` — the mobile client parses this response straight into
    `AdminUserSummaryDto`, which requires those other fields."""

    # Explicitly required — the model's own `default=True` would
    # otherwise make DRF infer this field as optional, which would let a
    # PATCH with an empty body silently no-op instead of erroring.
    is_active = serializers.BooleanField()

    class Meta:
        model = User
        fields = [
            "id", "email", "phone", "full_name", "role",
            "is_active", "is_verified", "created_at",
        ]
        read_only_fields = ["id", "email", "phone", "full_name", "role", "is_verified", "created_at"]


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """Adds `role` and `full_name` claims to the JWT access token, per
    PLAN.md §6 ("`role` claim embedded")."""

    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token["role"] = user.role
        token["full_name"] = user.full_name
        return token
