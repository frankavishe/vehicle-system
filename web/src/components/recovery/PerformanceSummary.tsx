"use client";

import { useEffect, useState } from "react";

import { Field, Input } from "@/components/ui/Field";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";
import type { ProviderPerformance } from "@/lib/types";

interface Period {
  periodStart: string;
  periodEnd: string;
}

function defaultPeriod(): Period {
  const end = new Date();
  const start = new Date();
  start.setDate(start.getDate() - 30);
  const iso = (d: Date) => d.toISOString().slice(0, 10);
  return { periodStart: iso(start), periodEnd: iso(end) };
}

function formatResponseTime(seconds: number): string {
  const minutes = Math.round(seconds / 60);
  if (minutes < 1) return `${Math.round(seconds)}s`;
  if (minutes < 60) return `${minutes}m`;
  const hours = Math.floor(minutes / 60);
  return `${hours}h ${minutes % 60}m`;
}

/** Period selector plus the operator's own completed/cancelled counts,
 * average rating, and average response time (Story 3) — with an explicit
 * empty state (not `0` or a broken chart) whenever the underlying data is
 * genuinely absent, distinct from "0 completed, N cancelled" (FR-008). */
export function PerformanceSummary({ initialPerformance }: { initialPerformance: ProviderPerformance }) {
  const [period, setPeriod] = useState<Period>(defaultPeriod);
  const [performance, setPerformance] = useState(initialPerformance);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    // eslint-disable-next-line react-hooks/set-state-in-effect -- intentional loading/error reset before the period-scoped refetch below, guarded by `cancelled` (mirrors EarningsSummary.tsx)
    setLoading(true);
    setError(null);

    const params = new URLSearchParams({
      period_start: period.periodStart,
      period_end: period.periodEnd,
    });

    apiFetch<ProviderPerformance>(`/providers/me/performance?${params}`)
      .then((data) => {
        if (!cancelled) setPerformance(data);
      })
      .catch((err) => {
        if (!cancelled) setError(err instanceof ApiError ? err.message : "Couldn't load performance.");
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [period]);

  const noActivity = performance.completed_count === 0 && performance.cancelled_count === 0;

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-col gap-3 border border-line bg-surface-raised p-4 sm:flex-row sm:items-end">
        <Field label="From" htmlFor="performance-period-start">
          <Input
            id="performance-period-start"
            type="date"
            value={period.periodStart}
            onChange={(e) => setPeriod((p) => ({ ...p, periodStart: e.target.value }))}
          />
        </Field>
        <Field label="To" htmlFor="performance-period-end">
          <Input
            id="performance-period-end"
            type="date"
            value={period.periodEnd}
            onChange={(e) => setPeriod((p) => ({ ...p, periodEnd: e.target.value }))}
          />
        </Field>
      </div>

      {error && <p className="text-sm text-stop">{error}</p>}

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <div className="flex flex-col gap-1 border border-line bg-surface-raised p-4">
          <span className="text-xs font-semibold uppercase tracking-wide text-steel">Completed tows</span>
          <span className="font-display text-3xl font-bold text-asphalt">
            {loading ? "…" : performance.completed_count}
          </span>
          {!loading && performance.completed_count === 0 && performance.cancelled_count > 0 && (
            // "0 completed" must read as distinct from "no data" — a
            // non-zero cancelled_count alongside it makes that explicit.
            <span className="text-xs text-steel-soft">
              {performance.cancelled_count} cancelled in this period
            </span>
          )}
        </div>
        <div className="flex flex-col gap-1 border border-line bg-surface-raised p-4">
          <span className="text-xs font-semibold uppercase tracking-wide text-steel">Average rating</span>
          <span className="font-display text-3xl font-bold text-asphalt">
            {loading ? "…" : performance.average_rating != null ? performance.average_rating.toFixed(2) : "—"}
          </span>
          {!loading && performance.average_rating == null && (
            <span className="text-xs text-steel-soft">No reviews in this period</span>
          )}
        </div>
        <div className="flex flex-col gap-1 border border-line bg-surface-raised p-4">
          <span className="text-xs font-semibold uppercase tracking-wide text-steel">Avg. response time</span>
          <span className="font-display text-3xl font-bold text-asphalt">
            {loading
              ? "…"
              : performance.average_response_time_seconds != null
                ? formatResponseTime(performance.average_response_time_seconds)
                : "—"}
          </span>
          {!loading && performance.average_response_time_seconds == null && (
            <span className="text-xs text-steel-soft">No completed tows in this period</span>
          )}
        </div>
      </div>

      {!loading && noActivity && (
        <p className="border border-line bg-surface-raised p-4 text-sm text-steel-soft">
          No activity in this period yet.
        </p>
      )}
    </div>
  );
}
