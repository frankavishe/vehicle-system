import type { ReactNode } from "react";

import { Card } from "@/components/ui/Card";

interface StatProps {
  label: string;
  value: ReactNode;
  helper?: ReactNode;
  tone?: "default" | "highlight";
  loading?: boolean;
}

/** A single stat tile: label + big display-font number, optionally a
 * highlighted green promo-card variant for the one number on a screen
 * that deserves emphasis (e.g. revenue, total earnings for the period). */
export function Stat({ label, value, helper, tone = "default", loading }: StatProps) {
  const highlight = tone === "highlight";
  return (
    <Card variant={highlight ? "highlight" : "default"} padding="md" className="flex flex-col gap-1">
      <span className={`text-xs font-medium ${highlight ? "text-white/70" : "text-steel"}`}>{label}</span>
      <span className={`font-display text-3xl font-bold ${highlight ? "text-white" : "text-asphalt"}`}>
        {loading ? "…" : value}
      </span>
      {helper ? (
        <span className={`text-xs ${highlight ? "text-white/70" : "text-steel-soft"}`}>{helper}</span>
      ) : null}
    </Card>
  );
}
