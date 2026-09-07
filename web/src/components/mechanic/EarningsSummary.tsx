"use client";

import { useEffect, useState } from "react";

import { Badge } from "@/components/ui/Badge";
import { Card } from "@/components/ui/Card";
import { DonutChart, DEFAULT_PALETTE } from "@/components/ui/DonutChart";
import { Stat } from "@/components/ui/Stat";
import { PayoutPeriodPicker, type PayoutPeriod } from "@/components/mechanic/PayoutPeriodPicker";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";
import { formatDate, formatTZS } from "@/lib/format";
import type { Payout, PayoutStatus } from "@/lib/types";

const STATUS_COLOR: Record<PayoutStatus, string> = {
  PENDING: DEFAULT_PALETTE[4],
  PROCESSING: DEFAULT_PALETTE[1],
  PAID: DEFAULT_PALETTE[0],
  FAILED: DEFAULT_PALETTE[5],
};

const statusTone: Record<PayoutStatus, "go" | "stop" | "signal" | "neutral"> = {
  PENDING: "neutral",
  PROCESSING: "signal",
  PAID: "go",
  FAILED: "stop",
};

function defaultPeriod(): PayoutPeriod {
  const end = new Date();
  const start = new Date();
  start.setDate(start.getDate() - 30);
  const iso = (d: Date) => d.toISOString().slice(0, 10);
  return { periodStart: iso(start), periodEnd: iso(end) };
}

export function EarningsSummary({ initialPayouts }: { initialPayouts: Payout[] }) {
  const [period, setPeriod] = useState<PayoutPeriod>(defaultPeriod);
  const [payouts, setPayouts] = useState(initialPayouts);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    // eslint-disable-next-line react-hooks/set-state-in-effect -- intentional loading/error reset before the period-scoped refetch below, guarded by `cancelled`
    setLoading(true);
    setError(null);

    const params = new URLSearchParams({
      period_start: period.periodStart,
      period_end: period.periodEnd,
    });

    apiFetch<{ results: Payout[] }>(`/providers/me/payouts?${params}`)
      .then((page) => {
        if (!cancelled) setPayouts(page.results);
      })
      .catch((err) => {
        if (!cancelled) setError(err instanceof ApiError ? err.message : "Couldn't load earnings.");
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [period]);

  const total = payouts.reduce((sum, payout) => sum + Number(payout.amount), 0);

  const byStatus = payouts.reduce(
    (acc, payout) => {
      acc[payout.status] = (acc[payout.status] ?? 0) + 1;
      return acc;
    },
    {} as Record<PayoutStatus, number>,
  );

  return (
    <div className="flex flex-col gap-6">
      <PayoutPeriodPicker period={period} onChange={setPeriod} />

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <Stat tone="highlight" label="Total for this period" value={formatTZS(total)} loading={loading} />
        <Card>
          <h2 className="mb-4 text-sm font-medium text-steel">Payouts by status</h2>
          <DonutChart
            data={Object.entries(byStatus).map(([label, value]) => ({
              label,
              value,
              color: STATUS_COLOR[label as PayoutStatus],
            }))}
            centerValue={payouts.length}
            centerLabel="payouts"
            emptyMessage="No payouts in this period yet."
          />
        </Card>
      </div>

      {error && <p className="text-sm text-stop">{error}</p>}

      <div className="flex flex-col divide-y divide-line rounded-2xl border border-line bg-surface-raised shadow-sm">
        {!loading && payouts.length === 0 && (
          <p className="p-4 text-sm text-steel-soft">No payouts in this period yet.</p>
        )}
        {payouts.map((payout) => (
          <div key={payout.id} className="flex items-center justify-between gap-4 p-4">
            <div className="flex flex-col gap-0.5">
              <span className="text-xs text-steel-soft">{formatDate(payout.created_at)}</span>
              <span className="text-sm text-steel">{payout.items.length} job(s)</span>
            </div>
            <div className="flex items-center gap-3">
              <span className="text-sm text-asphalt">{formatTZS(payout.amount)}</span>
              <Badge tone={statusTone[payout.status]}>{payout.status}</Badge>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
