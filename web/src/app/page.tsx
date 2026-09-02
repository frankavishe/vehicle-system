import Link from "next/link";

import { CompatibilitySearch } from "@/components/catalog/CompatibilitySearch";
import { PartCard } from "@/components/catalog/PartCard";
import { Notice } from "@/components/layout/Notice";
import { apiFetch } from "@/lib/api/server";
import type { Facets, SparePart } from "@/lib/types";

interface PartsPage {
  results: SparePart[];
  count: number;
}

async function getFacets(): Promise<Facets> {
  try {
    return await apiFetch<Facets>("/parts/facets");
  } catch {
    return { makes: [], models: [] };
  }
}

async function getFeaturedParts(): Promise<PartsPage> {
  try {
    return await apiFetch<PartsPage>("/parts");
  } catch {
    return { results: [], count: 0 };
  }
}

export default async function HomePage({
  searchParams,
}: {
  searchParams: Promise<{ notice?: string }>;
}) {
  const [{ notice }, facets, parts] = await Promise.all([
    searchParams,
    getFacets(),
    getFeaturedParts(),
  ]);

  return (
    <div className="flex flex-col gap-16">
      <Notice code={notice} />
      <section className="grid gap-8 py-4 sm:grid-cols-[1.1fr_0.9fr] sm:items-center">
        <div className="flex flex-col gap-5">
          <span className="text-xs font-semibold uppercase tracking-[0.2em] text-hazard">
            {parts.count > 0 ? `${parts.count} parts in stock` : "Tanzania spare parts counter"}
          </span>
          <h1 className="font-display text-5xl font-extrabold uppercase leading-[0.95] tracking-tight text-asphalt sm:text-6xl">
            The right part,
            <br />
            fitted right.
          </h1>
          <p className="max-w-md text-base text-steel">
            Search by make, model and year — every listing carries its own
            fitment tag, so you know it fits before you pay. Check out with
            card or mobile money.
          </p>
        </div>
        <CompatibilitySearch initialFacets={facets} />
      </section>

      {parts.results.length > 0 && (
        <section className="flex flex-col gap-5">
          <div className="flex items-baseline justify-between">
            <h2 className="font-display text-2xl font-bold uppercase tracking-tight text-asphalt">
              Recently listed
            </h2>
            <Link href="/catalog" className="text-sm font-semibold text-signal hover:text-signal-dark">
              Browse full catalog →
            </Link>
          </div>
          <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4">
            {parts.results.slice(0, 8).map((part) => (
              <PartCard key={part.id} part={part} />
            ))}
          </div>
        </section>
      )}
    </div>
  );
}
