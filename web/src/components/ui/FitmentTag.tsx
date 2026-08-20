import type { SparePart } from "@/lib/types";

type FitmentInfo = Pick<
  SparePart,
  "sku" | "compatible_make" | "compatible_model" | "year_start" | "year_end"
>;

/** The signature "parts-ticket" element — compatibility data styled like
 * a die-cut tag from a real parts counter. Every field shown is the
 * actual fitment spec, not decoration. */
export function FitmentTag({ part }: { part: FitmentInfo }) {
  const fitment = [part.compatible_make, part.compatible_model].filter(Boolean).join(" ");
  const years =
    part.year_start || part.year_end
      ? `${part.year_start ?? "—"}–${part.year_end ?? "present"}`
      : null;

  return (
    <div className="fitment-tag px-2.5 py-1.5 text-xs leading-tight">
      <div className="flex items-center justify-between gap-2 text-steel-soft">
        <span className="tracking-wide">FITS</span>
        <span>{part.sku}</span>
      </div>
      <div className="font-semibold text-asphalt">
        {fitment || "Universal fit"}
        {years ? ` · ${years}` : ""}
      </div>
    </div>
  );
}
