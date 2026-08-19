from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView

from apps.common.permissions import IsAdmin

from .models import User
from .serializers import (
    AdminUserListSerializer,
    AdminUserRoleSerializer,
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
