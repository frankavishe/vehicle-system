/** Messages for the `?notice=` query param a redirect can attach to `/`
 * when it sends someone home instead of where they were headed — e.g. an
 * unverified mechanic/recovery account bounced out of its portal gate
 * (see mechanic/layout.tsx and recovery/layout.tsx). Keyed by code so the
 * redirect only needs to carry a short string, not a message body. */
const NOTICES: Record<string, string> = {
  "mechanic-pending":
    "Your mechanic account is created but not verified yet — the portal unlocks once an admin approves it.",
  "recovery-pending":
    "Your recovery operator account is created but not verified yet — the portal unlocks once an admin approves it.",
};

export function Notice({ code }: { code?: string }) {
  const message = code ? NOTICES[code] : undefined;
  if (!message) return null;

  return (
    <p className="border border-hazard/30 bg-hazard/10 px-4 py-3 text-sm font-medium text-hazard-dark">
      {message}
    </p>
  );
}
