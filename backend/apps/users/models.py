import uuid

from django.contrib.auth.base_user import AbstractBaseUser, BaseUserManager
from django.contrib.auth.models import PermissionsMixin
from django.db import models


class UserRole(models.TextChoices):
    CUSTOMER = "CUSTOMER", "Customer"
    MECHANIC = "MECHANIC", "Mechanic"
    RECOVERY = "RECOVERY", "Recovery Operator"
    ADMIN = "ADMIN", "Admin"


# Roles a user may pick for themselves at /auth/register. ADMIN is granted
# only via `createsuperuser` or an existing admin's PATCH /admin/users/{id}/role
# — never self-service.
SELF_SERVICE_ROLES = (UserRole.CUSTOMER, UserRole.MECHANIC, UserRole.RECOVERY)


class UserManager(BaseUserManager):
    use_in_migrations = True

    def _create_user(self, email, phone, full_name, password, **extra_fields):
        if not email:
            raise ValueError("Users must have an email address.")
        email = self.normalize_email(email)
        user = self.model(email=email, phone=phone, full_name=full_name, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_user(self, email, phone, full_name, password=None, **extra_fields):
        extra_fields.setdefault("role", UserRole.CUSTOMER)
        extra_fields.setdefault("is_staff", False)
        extra_fields.setdefault("is_superuser", False)
        return self._create_user(email, phone, full_name, password, **extra_fields)

    def create_superuser(self, email, phone, full_name, password=None, **extra_fields):
        extra_fields.setdefault("role", UserRole.ADMIN)
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("is_verified", True)

        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser must have is_staff=True.")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser must have is_superuser=True.")

        return self._create_user(email, phone, full_name, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    """Matches PLAN.md §3.1's `users` table, with one deliberate deviation:
    Django's password field is named `password` (not `password_hash`) —
    Django owns hashing/salting itself, so renaming it would fight the
    framework for no functional benefit."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(unique=True, max_length=255)
    phone = models.CharField(unique=True, max_length=20)
    full_name = models.CharField(max_length=150)
    role = models.CharField(max_length=10, choices=UserRole.choices, default=UserRole.CUSTOMER)
    is_active = models.BooleanField(default=True)
    is_verified = models.BooleanField(default=False)
    # Required by Django admin / PermissionsMixin; forced True for ADMIN role.
    is_staff = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    objects = UserManager()

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["phone", "full_name"]

    class Meta:
        db_table = "users"

    def __str__(self):
        return f"{self.full_name} <{self.email}> ({self.role})"

    def save(self, *args, **kwargs):
        if self.role == UserRole.ADMIN:
            self.is_staff = True
        super().save(*args, **kwargs)
