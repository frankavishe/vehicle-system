"use client";

import { useState } from "react";

import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Field, Input, Select } from "@/components/ui/Field";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";
import { formatDate } from "@/lib/format";
import type { AdminUser, UserRole } from "@/lib/types";

interface AdminUsersPage {
  results: AdminUser[];
}

/** Roles verification actually applies to — see mechanic/layout.tsx and
 * recovery/layout.tsx, the only two portal gates that check is_verified.
 * Kept in sync with AdminUserVerifyView's own role check on the backend. */
const VERIFIABLE_ROLES: UserRole[] = ["MECHANIC", "RECOVERY"];

type VerifiedFilter = "PENDING" | "VERIFIED" | "ALL";

export function UserManager({ initialUsers }: { initialUsers: AdminUser[] }) {
  const [users, setUsers] = useState(initialUsers);
  const [role, setRole] = useState<UserRole | "ALL">("ALL");
  const [verified, setVerified] = useState<VerifiedFilter>("PENDING");
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function applyFilters(e?: React.FormEvent) {
    e?.preventDefault();
    setLoading(true);
    setError(null);
    try {
      const params = new URLSearchParams();
      if (role !== "ALL") params.set("role", role);
      if (verified !== "ALL") params.set("is_verified", verified === "VERIFIED" ? "true" : "false");
      if (search.trim()) params.set("search", search.trim());
      const page = await apiFetch<AdminUsersPage>(`/admin/users?${params.toString()}`);
      setUsers(page.results);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Couldn't load users.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="flex flex-col gap-6">
      <form onSubmit={applyFilters} className="flex flex-col gap-3 border border-line bg-surface-raised p-4 sm:flex-row sm:items-end">
        <Field label="Search" htmlFor="user-search">
          <Input
            id="user-search"
            placeholder="Name or email"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </Field>
        <Field label="Role" htmlFor="user-role">
          <Select id="user-role" value={role} onChange={(e) => setRole(e.target.value as UserRole | "ALL")}>
            <option value="ALL">All roles</option>
            <option value="MECHANIC">Mechanic</option>
            <option value="RECOVERY">Recovery operator</option>
            <option value="CUSTOMER">Customer</option>
            <option value="ADMIN">Admin</option>
          </Select>
        </Field>
        <Field label="Verification" htmlFor="user-verified">
          <Select
            id="user-verified"
            value={verified}
            onChange={(e) => setVerified(e.target.value as VerifiedFilter)}
          >
            <option value="PENDING">Pending only</option>
            <option value="VERIFIED">Verified only</option>
            <option value="ALL">All</option>
          </Select>
        </Field>
        <Button type="submit" disabled={loading}>
          {loading ? "Loading…" : "Filter"}
        </Button>
        {error ? <p className="text-sm text-stop">{error}</p> : null}
      </form>

      <div className="flex flex-col divide-y divide-line border border-line bg-surface-raised">
        {users.length === 0 && <p className="p-4 text-sm text-steel-soft">No accounts match this filter.</p>}
        {users.map((user) => (
          <UserRow
            key={user.id}
            user={user}
            onSaved={(updated) => setUsers(users.map((u) => (u.id === updated.id ? updated : u)))}
          />
        ))}
      </div>
    </div>
  );
}

function UserRow({ user, onSaved }: { user: AdminUser; onSaved: (user: AdminUser) => void }) {
  const [busy, setBusy] = useState<"verify" | "status" | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function setVerified(nextVerified: boolean) {
    setBusy("verify");
    setError(null);
    try {
      const updated = await apiFetch<AdminUser>(`/admin/users/${user.id}/verify`, {
        method: "PATCH",
        body: { is_verified: nextVerified },
      });
      onSaved(updated);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Couldn't update verification.");
    } finally {
      setBusy(null);
    }
  }

  async function toggleActive() {
    setBusy("status");
    setError(null);
    try {
      const updated = await apiFetch<AdminUser>(`/admin/users/${user.id}/status`, {
        method: "PATCH",
        body: { is_active: !user.is_active },
      });
      onSaved(updated);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Couldn't update this account.");
    } finally {
      setBusy(null);
    }
  }

  const canVerify = VERIFIABLE_ROLES.includes(user.role);
  const canModerateStatus = user.role !== "ADMIN";

  return (
    <div className="flex flex-col gap-3 p-4 sm:flex-row sm:items-center sm:justify-between">
      <div className="flex flex-col gap-0.5">
        <span className="text-sm font-semibold text-asphalt">{user.full_name}</span>
        <span className="text-xs text-steel-soft">
          {user.email} · {user.phone} · joined {formatDate(user.created_at)}
        </span>
      </div>
      <div className="flex flex-wrap items-center gap-3">
        <Badge tone="neutral">{user.role}</Badge>
        <Badge tone={user.is_active ? "go" : "stop"}>{user.is_active ? "Active" : "Suspended"}</Badge>
        {canVerify && (
          <Badge tone={user.is_verified ? "go" : "signal"}>{user.is_verified ? "Verified" : "Pending"}</Badge>
        )}
        {canVerify &&
          (user.is_verified ? (
            <Button variant="ghost" disabled={busy !== null} onClick={() => setVerified(false)}>
              {busy === "verify" ? "Saving…" : "Revoke"}
            </Button>
          ) : (
            <Button variant="primary" disabled={busy !== null} onClick={() => setVerified(true)}>
              {busy === "verify" ? "Saving…" : "Verify"}
            </Button>
          ))}
        {canModerateStatus && (
          <Button
            variant={user.is_active ? "danger" : "secondary"}
            disabled={busy !== null}
            onClick={toggleActive}
          >
            {busy === "status" ? "Saving…" : user.is_active ? "Suspend" : "Reinstate"}
          </Button>
        )}
        {error ? <p className="text-sm text-stop">{error}</p> : null}
      </div>
    </div>
  );
}
