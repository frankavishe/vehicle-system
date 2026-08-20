import Link from "next/link";

import { InventoryTable } from "@/components/admin/InventoryTable";
import { apiFetch } from "@/lib/api/server";
import type { SparePart } from "@/lib/types";

interface PartsPage {
  count: number;
  next: string | null;
  previous: string | null;
  results: SparePart[];
}

export default async function AdminInventoryPage({
  searchParams,
}: {
  searchParams: Promise<{ page?: string }>;
}) {
  const { page } = await searchParams;
  const parts = await apiFetch<PartsPage>(`/parts${page ? `?page=${page}` : ""}`);
  const current = Number(page ?? "1");

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-baseline justify-between">
        <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">Inventory</h1>
        <span className="text-sm text-steel-soft">{parts.count} parts</span>
      </div>

      <InventoryTable initialParts={parts.results} />

      {(parts.next || parts.previous) && (
        <div className="flex items-center justify-center gap-4 text-sm font-semibold">
          {parts.previous ? (
            <Link href={`/admin/inventory?page=${current - 1}`} className="text-signal hover:text-signal-dark">
              ← Previous
            </Link>
          ) : (
            <span className="text-steel-soft">← Previous</span>
          )}
          <span className="text-steel-soft">Page {current}</span>
          {parts.next ? (
            <Link href={`/admin/inventory?page=${current + 1}`} className="text-signal hover:text-signal-dark">
              Next →
            </Link>
          ) : (
            <span className="text-steel-soft">Next →</span>
          )}
        </div>
      )}
    </div>
  );
}
