import { redirect } from "next/navigation";

import { RequestServiceForm } from "@/components/requests/RequestServiceForm";
import { getSession } from "@/lib/auth/session";

export default async function NewRequestPage() {
  const user = await getSession();
  if (!user) redirect("/login?next=/requests/new");
  if (user.role !== "CUSTOMER") redirect("/");

  return (
    <div className="flex flex-col items-center gap-8 py-8">
      <h1 className="font-display text-4xl font-bold uppercase tracking-tight text-asphalt">
        Request a mechanic or tow
      </h1>
      <RequestServiceForm />
    </div>
  );
}
