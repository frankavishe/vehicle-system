"""
Base settings shared by every environment. Environment-specific settings
(dev/prod/test) import * from here and override only what differs.
"""
from datetime import timedelta
from pathlib import Path

import environ

BASE_DIR = Path(__file__).resolve().parent.parent.parent

env = environ.Env(DEBUG=(bool, False))
environ.Env.read_env(BASE_DIR / ".env")

SECRET_KEY = env("SECRET_KEY", default="change-me-in-dev")
DEBUG = env.bool("DEBUG", default=False)
ALLOWED_HOSTS = env.list("ALLOWED_HOSTS", default=[])

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "django.contrib.gis",
    # third-party
    "rest_framework",
    "rest_framework_simplejwt",
    "corsheaders",
    "drf_spectacular",
    "django_filters",
    # local apps
    "apps.common",
    "apps.users",
    "apps.providers",
    "apps.notifications",
    "apps.catalog",
    "apps.orders",
    "apps.dispatch",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "corsheaders.middleware.CorsMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "config.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "config.wsgi.application"
ASGI_APPLICATION = "config.asgi.application"

# --- Database ---
# `postgis://` URL scheme -> django.contrib.gis.db.backends.postgis (django-environ)
DATABASES = {
    "default": env.db(
        "DATABASE_URL",
        default="postgis://autoserve:autoserve@localhost:5432/autoserve",
    )
}

# --- Redis (Phase 3+ Celery, Phase 4 Channels pub/sub — reserved now per PLAN.md §7) ---
REDIS_URL = env("REDIS_URL", default="redis://localhost:6379/0")

# --- Auth ---
AUTH_USER_MODEL = "users.User"

AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

# --- I18n ---
LANGUAGE_CODE = "en-us"
TIME_ZONE = "Africa/Dar_es_Salaam"
USE_I18N = True
USE_TZ = True

# --- Static files ---
STATIC_URL = "static/"

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# --- CORS (web/ storefront + portals, Phase 2+) ---
CORS_ALLOWED_ORIGINS = env.list("CORS_ALLOWED_ORIGINS", default=[])

# --- DRF ---
REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": (
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ),
    "DEFAULT_PERMISSION_CLASSES": (
        "rest_framework.permissions.IsAuthenticated",
    ),
    "DEFAULT_SCHEMA_CLASS": "drf_spectacular.openapi.AutoSchema",
    "DEFAULT_FILTER_BACKENDS": (
        "django_filters.rest_framework.DjangoFilterBackend",
    ),
    "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.PageNumberPagination",
    "PAGE_SIZE": 20,
}

SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=15),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=7),
    "ROTATE_REFRESH_TOKENS": True,
    "BLACKLIST_AFTER_ROTATION": False,
    "AUTH_HEADER_TYPES": ("Bearer",),
    "USER_ID_FIELD": "id",
    "USER_ID_CLAIM": "user_id",
}

SPECTACULAR_SETTINGS = {
    "TITLE": "AutoServe API",
    "DESCRIPTION": "E-commerce spares, mechanic dispatch, and recovery/towing platform for Tanzania.",
    "VERSION": "0.1.0",
    "SERVE_INCLUDE_SCHEMA": False,
}

# --- Business settings ---
DEFAULT_CURRENCY = env("DEFAULT_CURRENCY", default="TZS")

# --- Phase 2/4: Flutterwave + Selcom (dual-gateway, see PLAN.md §5.3/§8) ---
# Human account-setup action item — PLAN.md §7 Phase 1 checklist.
# Phase 2 is where these finally get read (apps/orders/gateways/*).
FLUTTERWAVE_PUBLIC_KEY = env("FLUTTERWAVE_PUBLIC_KEY", default="")
FLUTTERWAVE_SECRET_KEY = env("FLUTTERWAVE_SECRET_KEY", default="")
FLUTTERWAVE_ENCRYPTION_KEY = env("FLUTTERWAVE_ENCRYPTION_KEY", default="")
FLUTTERWAVE_WEBHOOK_SECRET_HASH = env("FLUTTERWAVE_WEBHOOK_SECRET_HASH", default="")
FLUTTERWAVE_BASE_URL = env("FLUTTERWAVE_BASE_URL", default="https://api.flutterwave.com")
SELCOM_API_KEY = env("SELCOM_API_KEY", default="")
SELCOM_API_SECRET = env("SELCOM_API_SECRET", default="")
SELCOM_VENDOR_ID = env("SELCOM_VENDOR_ID", default="")
SELCOM_WEBHOOK_SECRET = env("SELCOM_WEBHOOK_SECRET", default="")
SELCOM_BASE_URL = env("SELCOM_BASE_URL", default="https://apigw.selcommobile.com")

# Where the checkout gateways redirect the customer back to after hosted
# payment (Next.js storefront's /checkout/complete page).
FRONTEND_BASE_URL = env("FRONTEND_BASE_URL", default="http://localhost:3000")

# --- Phase 3/4: Firebase Cloud Messaging + web push (see PLAN.md §5.4) ---
# Human account-setup action item — PLAN.md §7 Phase 1 checklist.
# No integration code reads these yet (Phase 3-4).
FIREBASE_SERVICE_ACCOUNT_JSON_PATH = env(
    "FIREBASE_SERVICE_ACCOUNT_JSON_PATH", default="./secrets/firebase-service-account.json"
)
FIREBASE_PROJECT_ID = env("FIREBASE_PROJECT_ID", default="")
FIREBASE_WEB_VAPID_PUBLIC_KEY = env("FIREBASE_WEB_VAPID_PUBLIC_KEY", default="")

# --- Phase 3: Beem Africa SMS fallback, dispatch-critical only (see PLAN.md §5.4) ---
# Human account-setup action item — PLAN.md §7 Phase 1 checklist.
BEEM_API_KEY = env("BEEM_API_KEY", default="")
BEEM_SECRET_KEY = env("BEEM_SECRET_KEY", default="")
BEEM_VENDOR_ID = env("BEEM_VENDOR_ID", default="")
BEEM_SENDER_ID = env("BEEM_SENDER_ID", default="")
BEEM_BASE_URL = env("BEEM_BASE_URL", default="https://apisms.beem.africa")

# --- Phase 3: Celery (broker only — no result backend, every task here is
# fire-and-forget). Reuses Phase 1's Redis instance. ---
CELERY_BROKER_URL = REDIS_URL
CELERY_TIMEZONE = TIME_ZONE
CELERY_TASK_ALWAYS_EAGER = env.bool("CELERY_TASK_ALWAYS_EAGER", default=False)
CELERY_BROKER_CONNECTION_RETRY_ON_STARTUP = True

# --- Phase 3: apps.dispatch radius matching (PLAN.md §5.1) ---
# Index-backed prefilter radius (km) before the per-provider
# service_radius_km cut — see apps/dispatch/services/matching.py.
DISPATCH_MAX_RADIUS_KM = env.int("DISPATCH_MAX_RADIUS_KM", default=50)

# --- Phase 3: apps.providers.ProviderDocument uploads ---
# Local disk storage only this phase — no S3/object storage, consistent
# with §8's open hosting question. `backend/media/` is gitignored.
MEDIA_URL = "/media/"
MEDIA_ROOT = BASE_DIR / "media"
