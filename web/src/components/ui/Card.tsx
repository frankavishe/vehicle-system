import type { HTMLAttributes } from "react";

type CardVariant = "default" | "highlight";
type CardPadding = "sm" | "md" | "lg";

interface CardProps extends HTMLAttributes<HTMLDivElement> {
  variant?: CardVariant;
  padding?: CardPadding;
}

const paddings: Record<CardPadding, string> = {
  sm: "p-4",
  md: "p-6",
  lg: "p-8",
};

const variants: Record<CardVariant, string> = {
  default: "border border-line bg-surface-raised text-asphalt",
  highlight: "border-none bg-primary text-white",
};

/** Base white rounded-shadow container — the app's one "card" primitive.
 * `highlight` is the green promo-card treatment (the reference design's
 * standing-orders/revenue tile look); text inside it should use
 * text-white / text-white/70 rather than the default asphalt/steel tones. */
export function Card({ variant = "default", padding = "md", className = "", ...props }: CardProps) {
  return (
    <div
      className={`rounded-2xl shadow-sm ${variants[variant]} ${paddings[padding]} ${className}`}
      {...props}
    />
  );
}
