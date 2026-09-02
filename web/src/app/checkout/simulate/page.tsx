import { redirect } from "next/navigation";

import { SimulatePayment } from "@/components/checkout/SimulatePayment";
import { getSession } from "@/lib/auth/session";

/** TEMPORARY — see PAYMENT_SIMULATION_MODE's docstring in
 * backend/config/settings/base.py; remove this page together with that
 * flag. `SimulatedGatewayClient.initiate_checkout`
 * (backend/apps/orders/gateways/simulated.py) sends the browser here
 * instead of a real Flutterwave/Selcom hosted checkout page. */
export default async function CheckoutSimulatePage({
  searchParams,
}: {
  searchParams: Promise<{ payment_id?: string; redirect_url?: string }>;
}) {
  const user = await getSession();
  if (!user) redirect("/login");

  const { payment_id: paymentId, redirect_url: redirectUrl } = await searchParams;
  if (!paymentId || !redirectUrl) redirect("/orders");

  return (
    <div className="mx-auto max-w-lg py-8">
      <SimulatePayment paymentId={paymentId} redirectUrl={redirectUrl} />
    </div>
  );
}
