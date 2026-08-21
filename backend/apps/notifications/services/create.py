"""Single reusable notification entrypoint — mirrors
`apps.orders.gateways.routing.select_gateway`'s role as the one place
that needs to know the send-flow shape. Every triggering event across the
codebase (job match, order status change, dispute update, ...) should
call this rather than constructing a `Notification` row by hand."""

from ..models import DeliveryStatus, Notification


def create_and_send(*, user, category, title, body):
    notification = Notification.objects.create(
        user=user, category=category, title=title, body=body, delivery_status=DeliveryStatus.PENDING
    )

    from ..tasks import send_notification

    send_notification.delay(str(notification.id))
    return notification
