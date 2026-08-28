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

    def validate_phone(self, value):
        try:
            normalized = normalize_tz_phone(value)
        except DjangoValidationError as exc:
            raise serializers.ValidationError(exc.message) from exc
        # DRF's auto-generated UniqueValidator (from the model's
        # unique=True) already ran on the raw, un-normalized `value` before
        # this method — so e.g. "0798765432" and "255798765432" (the same
        # number in two formats) both sail through it. Re-check uniqueness
        # here, against the normalized form that's actually saved, so a
        # genuine duplicate is a clean 400 instead of an unhandled
        # IntegrityError (500) from the DB constraint.
        if User.objects.filter(phone=normalized).exists():
            raise serializers.ValidationError("This phone number is already registered.")
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


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """Adds `role` and `full_name` claims to the JWT access token, per
    PLAN.md §6 ("`role` claim embedded")."""

    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token["role"] = user.role
        token["full_name"] = user.full_name
        return token
