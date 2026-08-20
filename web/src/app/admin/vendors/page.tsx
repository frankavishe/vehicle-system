import { VendorManager } from "@/components/admin/VendorManager";
import { apiFetch } from "@/lib/api/server";
import type { Vendor } from "@/lib/types";

interface VendorsPage {
  results: Vendor[];
}

export default async function AdminVendorsPage() {
  // AdminVendorListCreateView is a generics.ListCreateAPIView, so it goes
  // through DRF's default PageNumberPagination (PAGE_SIZE=20) unlike the
  // plain-array order/cart endpoints below.
  const page = await apiFetch<VendorsPage>("/admin/vendors");

  return (
    <div className="flex flex-col gap-6">
      <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">Vendors</h1>
      <VendorManager initialVendors={page.results} />
    </div>
  );
}
