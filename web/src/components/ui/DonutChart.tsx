"use client";

import { Cell, Pie, PieChart, ResponsiveContainer } from "recharts";

export interface DonutDatum {
  label: string;
  value: number;
  color?: string;
}

interface DonutChartProps {
  data: DonutDatum[];
  size?: number;
  centerLabel?: string;
  centerValue?: string | number;
  emptyMessage?: string;
}

/** Brand green first, then a small rotation of accent hues. The danger-red
 * slot (index 5) is reserved for cancelled/failed/rejected-type slices so
 * "bad outcome" reads consistently across every donut in the app. */
export const DEFAULT_PALETTE = [
  "#123524",
  "#2563eb",
  "#e0a72e",
  "#1c7a4c",
  "#8a9099",
  "#d92d20",
];

/** Donut chart + colored-dot legend, matching the reference dashboard's
 * category-breakdown card. Renders an explicit empty state instead of a
 * broken zero-value ring when every value is zero (or data is empty). */
export function DonutChart({
  data,
  size = 160,
  centerLabel,
  centerValue,
  emptyMessage = "No data yet.",
}: DonutChartProps) {
  const total = data.reduce((sum, d) => sum + d.value, 0);

  if (total === 0) {
    return <p className="text-sm text-steel-soft">{emptyMessage}</p>;
  }

  return (
    <div className="flex flex-wrap items-center gap-6">
      <div style={{ width: size, height: size }} className="relative shrink-0">
        <ResponsiveContainer>
          <PieChart>
            <Pie
              data={data}
              dataKey="value"
              nameKey="label"
              innerRadius="70%"
              outerRadius="100%"
              paddingAngle={2}
              stroke="none"
            >
              {data.map((d, i) => (
                <Cell key={d.label} fill={d.color ?? DEFAULT_PALETTE[i % DEFAULT_PALETTE.length]} />
              ))}
            </Pie>
          </PieChart>
        </ResponsiveContainer>
        {centerLabel || centerValue != null ? (
          <div className="pointer-events-none absolute inset-0 flex flex-col items-center justify-center">
            <span className="font-display text-xl font-bold text-asphalt">{centerValue}</span>
            {centerLabel ? <span className="text-[11px] text-steel-soft">{centerLabel}</span> : null}
          </div>
        ) : null}
      </div>
      <ul className="flex flex-col gap-2 text-sm">
        {data.map((d, i) => (
          <li key={d.label} className="flex items-center gap-2">
            <span
              className="h-2.5 w-2.5 shrink-0 rounded-full"
              style={{ background: d.color ?? DEFAULT_PALETTE[i % DEFAULT_PALETTE.length] }}
            />
            <span className="text-steel">{d.label}</span>
            <span className="ml-auto font-medium text-asphalt">{d.value}</span>
          </li>
        ))}
      </ul>
    </div>
  );
}
