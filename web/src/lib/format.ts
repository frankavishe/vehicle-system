/** DEFAULT_CURRENCY is TZS everywhere in the backend (config/settings/base.py).
 * `currencyDisplay: "code"` renders "TZS 12,000" rather than a symbol, which
 * stays unambiguous regardless of the visitor's locale. */
export function formatTZS(value: string | number): string {
  const amount = typeof value === "string" ? Number(value) : value;
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "TZS",
    currencyDisplay: "code",
    maximumFractionDigits: 0,
  }).format(amount);
}

export function formatDate(value: string): string {
  return new Date(value).toLocaleDateString("en-GB", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}
