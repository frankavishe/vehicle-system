"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { useState } from "react";

import { Button } from "@/components/ui/Button";
import { Field, Input, Select } from "@/components/ui/Field";
import type { Facets } from "@/lib/types";

export function FilterRail({ facets }: { facets: Facets }) {
  const router = useRouter();
  const searchParams = useSearchParams();

  const [make, setMake] = useState(searchParams.get("make") ?? "");
  const [model, setModel] = useState(searchParams.get("model") ?? "");
  const [year, setYear] = useState(searchParams.get("year") ?? "");
  const [category, setCategory] = useState(searchParams.get("category") ?? "");

  function apply(e: React.FormEvent) {
    e.preventDefault();
    const params = new URLSearchParams();
    if (make) params.set("make", make);
    if (model) params.set("model", model);
    if (year) params.set("year", year);
    if (category) params.set("category", category);
    router.push(`/catalog${params.toString() ? `?${params}` : ""}`);
  }

  function clear() {
    setMake("");
    setModel("");
    setYear("");
    setCategory("");
    router.push("/catalog");
  }

  return (
    <form onSubmit={apply} className="flex flex-col gap-4 border border-line bg-surface-raised p-4">
      <h2 className="text-xs font-semibold uppercase tracking-wide text-steel">Filter parts</h2>

      <Field label="Make" htmlFor="filter-make">
        <Select id="filter-make" value={make} onChange={(e) => setMake(e.target.value)}>
          <option value="">Any make</option>
          {facets.makes.map((m) => (
            <option key={m} value={m}>
              {m}
            </option>
          ))}
        </Select>
      </Field>

      <Field label="Model" htmlFor="filter-model">
        <Select id="filter-model" value={model} onChange={(e) => setModel(e.target.value)}>
          <option value="">Any model</option>
          {facets.models.map((m) => (
            <option key={m} value={m}>
              {m}
            </option>
          ))}
        </Select>
      </Field>

      <Field label="Year" htmlFor="filter-year">
        <Input
          id="filter-year"
          type="number"
          placeholder="e.g. 2018"
          value={year}
          onChange={(e) => setYear(e.target.value)}
        />
      </Field>

      <Field label="Category" htmlFor="filter-category">
        <Input
          id="filter-category"
          placeholder="e.g. Brakes"
          value={category}
          onChange={(e) => setCategory(e.target.value)}
        />
      </Field>

      <div className="flex gap-2">
        <Button type="submit" className="flex-1">
          Apply
        </Button>
        <Button type="button" variant="ghost" onClick={clear}>
          Clear
        </Button>
      </div>
    </form>
  );
}
