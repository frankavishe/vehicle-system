"""Standard Django+Celery app factory. Broker = the same Redis instance
Phase 1 already reserved (`settings.REDIS_URL`); no result backend —
every task here is fire-and-forget (notification sends), nothing waits on
a task's return value."""

import os

from celery import Celery

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings.dev")

app = Celery("autoserve")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks()
