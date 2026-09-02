from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import filters, generics, permissions, status
from rest_framework.exceptions import PermissionDenied
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView

from apps.common.permissions import IsAdmin

from .models import User, UserRole
from .serializers import (
    AdminUserListSerializer,
    AdminUserRoleSerializer,
    AdminUserStatusSerializer,
    AdminUserVerifySerializer,
    CustomTokenObtainPairSerializer,
    MeSerializer,
    RegisterSerializer,
)


class RegisterView(generics.CreateAPIView):
    """POST /auth/register — self-service signup, role restricted to
    CUSTOMER/MECHANIC/RECOVERY (see SELF_SERVICE_ROLES)."""

    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]


class CustomTokenObtainPairView(TokenObtainPairView):
    """POST /auth/login"""

    serializer_class = CustomTokenObtainPairSerializer
    permission_classes = [permissions.AllowAny]


class MeView(APIView):
    """GET/PATCH /users/me"""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        return Response(MeSerializer(request.user).data)

    def patch(self, request):
        serializer = MeSerializer(request.user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


class AdminUserListView(generics.ListAPIView):
    """GET /admin/users"""

    queryset = User.objects.all().order_by("-created_at")
    serializer_class = AdminUserListSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdmin]
    filterset_fields = ["role", "is_active", "is_verified"]
    # 003-admin-mobile-app FR-005 — locate an account by name/email.
    # filter_backends is redeclared (not just appended-to) here because
    # setting it on a view overrides DEFAULT_FILTER_BACKENDS entirely —
    # DjangoFilterBackend has to be listed again so filterset_fields
    # above keeps working alongside search.
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    search_fields = ["email", "full_name"]


class AdminUserRoleUpdateView(generics.UpdateAPIView):
    """PATCH /admin/users/{id}/role"""

    queryset = User.objects.all()
    serializer_class = AdminUserRoleSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdmin]
    http_method_names = ["patch"]

    def patch(self, request, *args, **kwargs):
        response = super().update(request, *args, partial=True, **kwargs)
        response.status_code = status.HTTP_200_OK
        return response


class AdminUserStatusUpdateView(generics.UpdateAPIView):
    """PATCH /admin/users/{id}/status — 003-admin-mobile-app FR-005.
    Suspend/reinstate. ADMIN-role accounts are never a valid target
    (spec.md FR-005 — prevents an admin locking out another admin, or
    themselves, by mistake) — checked here, not left to the client."""

    queryset = User.objects.all()
    serializer_class = AdminUserStatusSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdmin]
    http_method_names = ["patch"]

    def patch(self, request, *args, **kwargs):
        if self.get_object().role == UserRole.ADMIN:
            raise PermissionDenied("ADMIN accounts cannot be moderated through this endpoint.")
        response = super().update(request, *args, partial=True, **kwargs)
        response.status_code = status.HTTP_200_OK
        return response


class AdminUserVerifyView(generics.UpdateAPIView):
    """PATCH /admin/users/{id}/verify — approve (or revoke) a MECHANIC/
    RECOVERY account's verification. `is_verified` was previously a
    manually-set-only field (see urls.py's note by /auth/verify below);
    this is the first API path that flips it, unlocking the portal gate
    in mechanic/layout.tsx and recovery/layout.tsx on web. Restricted to
    those two roles — verification isn't a meaningful concept for
    CUSTOMER/ADMIN accounts."""

    queryset = User.objects.all()
    serializer_class = AdminUserVerifySerializer
    permission_classes = [permissions.IsAuthenticated, IsAdmin]
    http_method_names = ["patch"]

    def patch(self, request, *args, **kwargs):
        if self.get_object().role not in (UserRole.MECHANIC, UserRole.RECOVERY):
            raise PermissionDenied("Only mechanic and recovery accounts can be verified here.")
        response = super().update(request, *args, partial=True, **kwargs)
        response.status_code = status.HTTP_200_OK
        return response
