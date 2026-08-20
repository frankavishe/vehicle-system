import type { ReactNode } from "react";

type Tone = "go" | "stop" | "signal" | "neutral";

const tones: Record<Tone, string> = {
  go: "bg-go-bg text-go",
  stop: "bg-stop-bg text-stop",
  signal: "bg-signal/10 text-signal-dark",
  neutral: "bg-line/60 text-steel",
};

export function Badge({ tone = "neutral", children }: { tone?: Tone; children: ReactNode }) {
  return (
    <span
      className={`inline-block px-2 py-0.5 text-xs font-semibold uppercase tracking-wide ${tones[tone]}`}
    >
      {children}
    </span>
  );
}
