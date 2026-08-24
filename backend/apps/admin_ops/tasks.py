from celery import shared_task

from .services.payout_batch import run_batch


@shared_task
def run_weekly_payout_batch():
    """Celery beat entrypoint — see config/settings/base.py's
    CELERY_BEAT_SCHEDULE (PLAN.md §5.5)."""
    run_batch(is_manual=False)
