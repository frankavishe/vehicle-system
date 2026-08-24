import { apiFetch } from "@/lib/api/server";
import { formatTZS } from "@/lib/format";
import type { AdminAnalytics } from "@/lib/types";

function StatTile({ label, value }: { label: string; value: string | number }) {
  return (
    <div className="flex flex-col gap-1 border border-line bg-surface-raised p-4">
      <span className="text-xs font-semibold uppercase tracking-wide text-steel-soft">{label}</span>
      <span className="font-mono text-2xl font-semibold text-asphalt">{value}</span>
    </div>
  );
}

function StatusBreakdown({ title, byStatus }: { title: string; byStatus: Record<string, number> }) {
  const entries = Object.entries(byStatus);
  return (
    <div className="flex flex-col gap-2 border border-line bg-surface-raised p-4">
      <h2 className="text-xs font-semibold uppercase tracking-wide text-steel">{title}</h2>
      {entries.length === 0 ? (
        <p className="text-sm text-steel-soft">No data yet.</p>
      ) : (
        <div className="flex flex-col divide-y divide-line">
          {entries.map(([status, count]) => (
            <div key={status} className="flex items-center justify-between py-1.5 text-sm">
              <span className="text-steel">{status}</span>
              <span className="font-mono text-asphalt">{count}</span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default async function AdminAnalyticsPage() {
  const analytics = await apiFetch<AdminAnalytics>("/admin/analytics");

  return (
    <div className="flex flex-col gap-6">
      <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">Analytics</h1>

      <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
        <StatTile label="Revenue" value={formatTZS(analytics.revenue)} />
        <StatTile label="Active providers" value={analytics.active_providers} />
        <StatTile label="Open disputes" value={analytics.open_disputes} />
        <StatTile
          label="Total orders"
          value={Object.values(analytics.orders_by_status).reduce((a, b) => a + b, 0)}
        />
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <StatusBreakdown title="Orders by status" byStatus={analytics.orders_by_status} />
        <StatusBreakdown title="Service requests by status" byStatus={analytics.service_requests_by_status} />
      </div>
    </div>
  );
}
