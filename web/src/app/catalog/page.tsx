import Link from "next/link";

import { FilterRail } from "@/components/catalog/FilterRail";
import { PartCard } from "@/components/catalog/PartCard";
import { apiFetch } from "@/lib/api/server";
import type { Facets, SparePart } from "@/lib/types";

interface PartsPage {
  count: number;
  next: string | null;
  previous: string | null;
  results: SparePart[];
}

export default async function CatalogPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | undefined>>;
}) {
  const params = await searchParams;
  const query = new URLSearchParams();
  for (const key of ["make", "model", "year", "category", "page"] as const) {
    if (params[key]) query.set(key, params[key]!);
  }

  const [parts, facets] = await Promise.all([
    apiFetch<PartsPage>(`/parts${query.toString() ? `?${query}` : ""}`),
    apiFetch<Facets>("/parts/facets").catch(() => ({ makes: [], models: [] })),
  ]);

  const page = Number(params.page ?? "1");

  return (
    <div className="grid grid-cols-1 gap-8 sm:grid-cols-[220px_1fr]">
      <FilterRail facets={facets} />

      <div className="flex flex-col gap-5">
        <div className="flex items-baseline justify-between">
          <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">
            Catalog
          </h1>
          <span className="text-sm text-steel-soft">{parts.count} parts</span>
        </div>

        {parts.results.length === 0 ? (
          <p className="border border-dashed border-line bg-surface-raised p-8 text-center text-sm text-steel">
            No parts match those filters. Try widening the search.
          </p>
        ) : (
          <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4">
            {parts.results.map((part) => (
              <PartCard key={part.id} part={part} />
            ))}
          </div>
        )}

        {(parts.next || parts.previous) && (
          <div className="flex items-center justify-center gap-4 pt-4 text-sm font-semibold">
            {parts.previous ? (
              <Link href={pageHref(query, page - 1)} className="text-signal hover:text-signal-dark">
                ← Previous
              </Link>
            ) : (
              <span className="text-steel-soft">← Previous</span>
            )}
            <span className="text-steel-soft">Page {page}</span>
            {parts.next ? (
              <Link href={pageHref(query, page + 1)} className="text-signal hover:text-signal-dark">
                Next →
              </Link>
            ) : (
              <span className="text-steel-soft">Next →</span>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

function pageHref(query: URLSearchParams, page: number): string {
  const next = new URLSearchParams(query);
  next.set("page", String(page));
  return `/catalog?${next}`;
}
