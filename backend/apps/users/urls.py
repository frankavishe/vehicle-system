from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView, TokenVerifyView

from .views import (
    AdminUserListView,
    AdminUserRoleUpdateView,
    AdminUserStatusUpdateView,
    CustomTokenObtainPairView,
    MeView,
    RegisterView,
)

urlpatterns = [
    path("auth/register", RegisterView.as_view(), name="auth-register"),
    path("auth/login", CustomTokenObtainPairView.as_view(), name="auth-login"),
    path("auth/refresh", TokenRefreshView.as_view(), name="auth-refresh"),
    # simplejwt's standard "does this token validate" check — PLAN.md §4
    # lists /auth/verify without further definition and there's no OTP
    # infra yet; users.is_verified stays a separate, manually-set field.
    path("auth/verify", TokenVerifyView.as_view(), name="auth-verify"),
    path("users/me", MeView.as_view(), name="users-me"),
    path("admin/users", AdminUserListView.as_view(), name="admin-users-list"),
    path(
        "admin/users/<uuid:pk>/role",
        AdminUserRoleUpdateView.as_view(),
        name="admin-users-role",
    ),
    path(
        "admin/users/<uuid:pk>/status",
        AdminUserStatusUpdateView.as_view(),
        name="admin-users-status",
    ),
]
