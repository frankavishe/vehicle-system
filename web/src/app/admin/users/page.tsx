import { UserManager } from "@/components/admin/UserManager";
import { apiFetch } from "@/lib/api/server";
import type { AdminUser } from "@/lib/types";

interface AdminUsersPage {
  results: AdminUser[];
}

export default async function AdminUsersPage() {
  // AdminUserListView is a ListAPIView, so this goes through DRF's default
  // PageNumberPagination like /admin/vendors. Defaults to the pending
  // verification queue (UserManager's own initial filter state) — the
  // reason this page exists is approving mechanic/recovery signups.
  const page = await apiFetch<AdminUsersPage>("/admin/users?is_verified=false");

  return (
    <div className="flex flex-col gap-6">
      <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">Users</h1>
      <UserManager initialUsers={page.results} />
    </div>
  );
}
