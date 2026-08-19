from django.shortcuts import get_object_or_404
from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Notification
from .serializers import DeviceTokenSerializer, NotificationSerializer


class DeviceTokenUpsertView(generics.CreateAPIView):
    """POST /users/me/device-tokens — register/refresh an FCM token."""

    serializer_class = DeviceTokenSerializer
    permission_classes = [permissions.IsAuthenticated]


class NotificationListView(generics.ListAPIView):
    """GET /users/me/notifications"""

    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]
    filterset_fields = ["category", "read", "delivery_status"]

    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user)


class NotificationMarkReadView(APIView):
    """PATCH /notifications/{id}/read"""

    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, pk):
        notification = get_object_or_404(Notification, pk=pk, user=request.user)
        notification.read = True
        notification.save(update_fields=["read"])
        return Response(NotificationSerializer(notification).data)
