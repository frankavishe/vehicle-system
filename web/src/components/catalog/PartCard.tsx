import Link from "next/link";

import { Badge } from "@/components/ui/Badge";
import { FitmentTag } from "@/components/ui/FitmentTag";
import { formatTZS } from "@/lib/format";
import type { SparePart } from "@/lib/types";

export function PartCard({ part }: { part: SparePart }) {
  const lowStock = part.stock_quantity > 0 && part.stock_quantity <= 3;

  return (
    <Link
      href={`/catalog/${part.id}`}
      className="group flex flex-col gap-3 border border-line bg-surface-raised p-3 transition-colors hover:border-asphalt"
    >
      <div className="flex aspect-square items-center justify-center overflow-hidden bg-surface">
        {part.image_url ? (
          // eslint-disable-next-line @next/next/no-img-element -- remote vendor-hosted images, no fixed domain list to configure for next/image yet
          <img src={part.image_url} alt={part.title} className="h-full w-full object-cover" />
        ) : (
          <span className="font-display text-3xl font-bold text-line">{part.category.slice(0, 2).toUpperCase()}</span>
        )}
      </div>

      <FitmentTag part={part} />

      <div className="flex flex-1 flex-col gap-1">
        <h3 className="text-sm font-semibold text-asphalt group-hover:text-signal">{part.title}</h3>
        <p className="text-xs text-steel-soft">{part.vendor?.name ?? "Unlisted vendor"}</p>
      </div>

      <div className="flex items-center justify-between">
        <span className="font-mono text-sm font-semibold text-asphalt">{formatTZS(part.price)}</span>
        {part.stock_quantity === 0 ? (
          <Badge tone="stop">Out of stock</Badge>
        ) : lowStock ? (
          <Badge tone="stop">{part.stock_quantity} left</Badge>
        ) : (
          <Badge tone="go">In stock</Badge>
        )}
      </div>
    </Link>
  );
}
