"""RBAC permission classes, matching the per-role endpoint checks in
PLAN.md §6 (e.g. only MECHANIC/RECOVERY can PATCH availability; only
ADMIN can resolve disputes / manage users)."""

from rest_framework.permissions import BasePermission


class HasRole(BasePermission):
    """Base class: subclasses set `allowed_roles`. Use `role_permission()`
    below rather than subclassing directly in most cases."""

    allowed_roles: tuple[str, ...] = ()

    def has_permission(self, request, view):
        user = request.user
        return bool(
            user
            and user.is_authenticated
            and user.role in self.allowed_roles
        )


def role_permission(*roles: str) -> type[HasRole]:
    """Factory for a `HasRole` subclass restricted to the given roles.

    Usage: `IsAdmin = role_permission("ADMIN")`
           `IsProvider = role_permission("MECHANIC", "RECOVERY")`
    """
    name = f"Is{''.join(role.title() for role in roles)}"
    return type(name, (HasRole,), {"allowed_roles": roles})


IsAdmin = role_permission("ADMIN")
IsCustomer = role_permission("CUSTOMER")
IsMechanic = role_permission("MECHANIC")
IsRecovery = role_permission("RECOVERY")
IsProvider = role_permission("MECHANIC", "RECOVERY")


class IsSelfOrAdmin(BasePermission):
    """Object-level permission for `/users/me`-style endpoints: the
    requesting user may act on their own object, or an ADMIN may act on
    anyone's."""

    def has_object_permission(self, request, view, obj):
        user = request.user
        return bool(user and user.is_authenticated and (obj == user or user.role == "ADMIN"))
