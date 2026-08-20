import { redirect } from "next/navigation";

import { CheckoutStatus } from "@/components/checkout/CheckoutStatus";
import { getSession } from "@/lib/auth/session";

export default async function CheckoutCompletePage({
  searchParams,
}: {
  searchParams: Promise<{ order_id?: string }>;
}) {
  const user = await getSession();
  if (!user) redirect("/login");

  const { order_id: orderId } = await searchParams;
  if (!orderId) redirect("/orders");

  return (
    <div className="mx-auto max-w-lg py-8">
      <CheckoutStatus orderId={orderId} />
    </div>
  );
}
