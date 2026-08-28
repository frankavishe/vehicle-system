"use client";

import { Field, Input } from "@/components/ui/Field";

export interface PayoutPeriod {
  periodStart: string;
  periodEnd: string;
}

export function PayoutPeriodPicker({
  period,
  onChange,
}: {
  period: PayoutPeriod;
  onChange: (period: PayoutPeriod) => void;
}) {
  return (
    <div className="flex flex-col gap-3 border border-line bg-surface-raised p-4 sm:flex-row sm:items-end">
      <Field label="From" htmlFor="payout-period-start">
        <Input
          id="payout-period-start"
          type="date"
          value={period.periodStart}
          onChange={(e) => onChange({ ...period, periodStart: e.target.value })}
        />
      </Field>
      <Field label="To" htmlFor="payout-period-end">
        <Input
          id="payout-period-end"
          type="date"
          value={period.periodEnd}
          onChange={(e) => onChange({ ...period, periodEnd: e.target.value })}
        />
      </Field>
    </div>
  );
}
