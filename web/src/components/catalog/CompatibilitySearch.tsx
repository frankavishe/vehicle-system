"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";

import { apiFetch } from "@/lib/api/client";
import { Select } from "@/components/ui/Field";
import { Button } from "@/components/ui/Button";
import type { Facets } from "@/lib/types";

/** The hero's fitment lookup — mirrors how a real parts counter works:
 * pick a make, then a model scoped to it, then an optional year, and go
 * straight to the filtered catalog. Backed by GET /parts/facets, which
 * exists precisely because there's no fixed make/model vocabulary table
 * to draw a static dropdown list from. */
export function CompatibilitySearch({ initialFacets }: { initialFacets: Facets }) {
  const router = useRouter();
  const [make, setMake] = useState("");
  const [model, setModel] = useState("");
  const [year, setYear] = useState("");
  const [models, setModels] = useState(initialFacets.models);
  const [loadingModels, setLoadingModels] = useState(false);

  async function handleMakeChange(value: string) {
    setMake(value);
    setModel("");
    setLoadingModels(true);
    try {
      const facets = await apiFetch<Facets>(`/parts/facets${value ? `?make=${encodeURIComponent(value)}` : ""}`);
      setModels(facets.models);
    } finally {
      setLoadingModels(false);
    }
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const params = new URLSearchParams();
    if (make) params.set("make", make);
    if (model) params.set("model", model);
    if (year) params.set("year", year);
    router.push(`/catalog${params.toString() ? `?${params}` : ""}`);
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="grid grid-cols-1 gap-3 border border-line bg-surface-raised p-4 sm:grid-cols-[1fr_1fr_120px_auto] sm:p-5"
    >
      <Select value={make} onChange={(e) => handleMakeChange(e.target.value)} aria-label="Make">
        <option value="">Any make</option>
        {initialFacets.makes.map((m) => (
          <option key={m} value={m}>
            {m}
          </option>
        ))}
      </Select>
      <Select
        value={model}
        onChange={(e) => setModel(e.target.value)}
        disabled={loadingModels}
        aria-label="Model"
      >
        <option value="">Any model</option>
        {models.map((m) => (
          <option key={m} value={m}>
            {m}
          </option>
        ))}
      </Select>
      <Select value={year} onChange={(e) => setYear(e.target.value)} aria-label="Year">
        <option value="">Year</option>
        {Array.from({ length: 30 }, (_, i) => new Date().getFullYear() - i).map((y) => (
          <option key={y} value={y}>
            {y}
          </option>
        ))}
      </Select>
      <Button type="submit" className="whitespace-nowrap">
        Find parts
      </Button>
    </form>
  );
}
