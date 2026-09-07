import { Card } from "@/components/ui/Card";
import { DonutChart } from "@/components/ui/DonutChart";
import { Stat } from "@/components/ui/Stat";
import { apiFetch } from "@/lib/api/server";
import { formatTZS } from "@/lib/format";
import type { AdminAnalytics } from "@/lib/types";

function StatusDonut({ title, byStatus, unit }: { title: string; byStatus: Record<string, number>; unit: string }) {
  const total = Object.values(byStatus).reduce((a, b) => a + b, 0);
  return (
    <Card>
      <h2 className="mb-4 text-sm font-medium text-steel">{title}</h2>
      <DonutChart
        data={Object.entries(byStatus).map(([label, value]) => ({ label, value }))}
        centerValue={total}
        centerLabel={unit}
        emptyMessage="No data yet."
      />
    </Card>
  );
}

export default async function AdminAnalyticsPage() {
  const analytics = await apiFetch<AdminAnalytics>("/admin/analytics");

  return (
    <div className="flex flex-col gap-6">
      <h1 className="font-display text-3xl font-bold text-asphalt">Analytics</h1>

      <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
        <Stat tone="highlight" label="Revenue" value={formatTZS(analytics.revenue)} />
        <Stat label="Active providers" value={analytics.active_providers} />
        <Stat label="Open disputes" value={analytics.open_disputes} />
        <Stat
          label="Total orders"
          value={Object.values(analytics.orders_by_status).reduce((a, b) => a + b, 0)}
        />
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <StatusDonut title="Orders by status" byStatus={analytics.orders_by_status} unit="orders" />
        <StatusDonut
          title="Service requests by status"
          byStatus={analytics.service_requests_by_status}
          unit="requests"
        />
      </div>
    </div>
  );
}
