from .base import *  # noqa: F401,F403

DEBUG = False

# Hosting target still undecided (PLAN.md §8) — kept minimal/portable until
# a concrete deploy target (AWS af-south-1 vs self-managed VPS) is chosen.
SECURE_SSL_REDIRECT = env.bool("SECURE_SSL_REDIRECT", default=True)  # noqa: F405
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
