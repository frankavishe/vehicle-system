import { notFound } from "next/navigation";

import { AddToCart } from "@/components/catalog/AddToCart";
import { Badge } from "@/components/ui/Badge";
import { FitmentTag } from "@/components/ui/FitmentTag";
import { apiFetch } from "@/lib/api/server";
import { ApiError } from "@/lib/api/errors";
import { formatTZS } from "@/lib/format";
import type { SparePart } from "@/lib/types";

export default async function PartDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;

  let part: SparePart;
  try {
    part = await apiFetch<SparePart>(`/parts/${id}`);
  } catch (err) {
    if (err instanceof ApiError && err.status === 404) notFound();
    throw err;
  }

  return (
    <div className="grid grid-cols-1 gap-10 sm:grid-cols-2">
      <div className="flex aspect-square items-center justify-center overflow-hidden bg-surface-raised border border-line">
        {part.image_url ? (
          // eslint-disable-next-line @next/next/no-img-element -- remote vendor-hosted images
          <img src={part.image_url} alt={part.title} className="h-full w-full object-cover" />
        ) : (
          <span className="font-display text-6xl font-bold text-line">
            {part.category.slice(0, 2).toUpperCase()}
          </span>
        )}
      </div>

      <div className="flex flex-col gap-5">
        <div className="flex flex-col gap-2">
          <span className="text-xs font-semibold uppercase tracking-wide text-steel-soft">
            {part.category} · {part.vendor?.name ?? "Unlisted vendor"}
          </span>
          <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">
            {part.title}
          </h1>
          <p className="font-mono text-sm text-steel-soft">SKU {part.sku}</p>
        </div>

        <FitmentTag part={part} />

        <div className="flex items-center gap-3">
          <span className="font-mono text-2xl font-semibold text-asphalt">{formatTZS(part.price)}</span>
          {part.stock_quantity === 0 ? (
            <Badge tone="stop">Out of stock</Badge>
          ) : part.stock_quantity <= 3 ? (
            <Badge tone="stop">Only {part.stock_quantity} left</Badge>
          ) : (
            <Badge tone="go">{part.stock_quantity} in stock</Badge>
          )}
        </div>

        {part.description ? <p className="text-sm leading-relaxed text-steel">{part.description}</p> : null}

        <AddToCart sparePartId={part.id} stockQuantity={part.stock_quantity} />
      </div>
    </div>
  );
}
