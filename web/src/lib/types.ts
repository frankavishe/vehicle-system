// Shapes mirror the DRF serializers exactly (see backend/apps/*/serializers.py).
// Decimal fields (price, unit_price, total, total_amount, amount) render as
// strings — DRF's JSON encoder stringifies Decimal — so every money field
// here is typed `string` and formatted with formatTZS() before display.

export type UserRole = "CUSTOMER" | "MECHANIC" | "RECOVERY" | "ADMIN";

export const SELF_SERVICE_ROLES: { value: UserRole; label: string }[] = [
  { value: "CUSTOMER", label: "Customer" },
  { value: "MECHANIC", label: "Mechanic" },
  { value: "RECOVERY", label: "Recovery Operator" },
];

export interface SessionUser {
  id: string;
  role: UserRole;
  full_name: string;
  email: string;
  exp: number;
}

export interface Vendor {
  id: string;
  name: string;
  contact_email: string | null;
  contact_phone: string | null;
  is_active: boolean;
  created_at: string;
}

export interface VendorSummary {
  id: string;
  name: string;
}

export interface SparePart {
  id: string;
  title: string;
  sku: string;
  price: string;
  stock_quantity: number;
  category: string;
  compatible_make: string | null;
  compatible_model: string | null;
  year_start: number | null;
  year_end: number | null;
  image_url: string | null;
  vendor: VendorSummary | null;
  description?: string;
}

export interface Facets {
  makes: string[];
  models: string[];
}

export interface CartItem {
  id: string;
  spare_part: SparePart;
  quantity: number;
}

export interface Cart {
  id: string;
  items: CartItem[];
  total: string;
  updated_at: string;
}

export type OrderStatus = "PENDING" | "PAID" | "DISPATCHED" | "DELIVERED" | "CANCELLED";

export interface OrderItem {
  id: string;
  spare_part: SparePart;
  quantity: number;
  unit_price: string;
}

export interface Order {
  id: string;
  status: OrderStatus;
  total_amount: string;
  delivery_address: string | null;
  items: OrderItem[];
  created_at: string;
}

export interface OrderShipment {
  id: string;
  courier_name: string | null;
  tracking_ref: string | null;
  dispatched_at: string | null;
  delivered_at: string | null;
  current_location: { lat: number; lng: number } | null;
}

export type PaymentMethod = "CARD" | "AIRTEL_MONEY" | "TIGO_PESA" | "HALOPESA" | "MPESA";

export const PAYMENT_METHODS: { value: PaymentMethod; label: string }[] = [
  { value: "CARD", label: "Card (Visa / Mastercard)" },
  { value: "MPESA", label: "M-Pesa" },
  { value: "AIRTEL_MONEY", label: "Airtel Money" },
  { value: "TIGO_PESA", label: "Tigo Pesa" },
  { value: "HALOPESA", label: "HaloPesa" },
];

export interface InitiatePaymentResult {
  payment_id: string;
  checkout_url: string;
}

// --- Phase 4 ---

export type ServiceType = "MECHANIC" | "RECOVERY";
export type ServiceRequestStatus =
  | "PENDING"
  | "ACCEPTED"
  | "EN_ROUTE"
  | "IN_PROGRESS"
  | "COMPLETED"
  | "CANCELLED";

export interface LatLng {
  lat: number;
  lng: number;
}

export interface ServiceRequestParty {
  id: string;
  full_name: string;
  phone: string;
}

export interface ServiceRequest {
  id: string;
  customer: ServiceRequestParty;
  provider: ServiceRequestParty | null;
  service_type: ServiceType;
  status: ServiceRequestStatus;
  pickup_location: LatLng;
  dropoff_location: LatLng | null;
  problem_description: string | null;
  estimated_fare: string | null;
  final_fare: string | null;
  created_at: string;
  accepted_at: string | null;
  completed_at: string | null;
}

export interface ProviderPerformance {
  period_start: string;
  period_end: string;
  completed_count: number;
  cancelled_count: number;
  average_rating: number | null;
  average_response_time_seconds: number | null;
}

export interface ProviderMapEntry {
  id: string;
  full_name: string;
  role: UserRole;
  is_available: boolean;
  lat: number | null;
  lng: number | null;
  updated_at: string;
}

export type DisputeStatus = "OPEN" | "RESOLVED";

export interface Dispute {
  id: string;
  service_request: string;
  raised_by: string | null;
  reason: string | null;
  status: DisputeStatus;
  resolved_by: string | null;
  created_at: string;
}

export type PayoutStatus = "PENDING" | "PROCESSING" | "PAID" | "FAILED";

export interface PayoutItem {
  id: string;
  service_request: string | null;
  amount: string;
}

export interface Payout {
  id: string;
  provider: string;
  amount: string;
  period_start: string | null;
  period_end: string | null;
  is_manual: boolean;
  provider_gateway: "FLUTTERWAVE" | "SELCOM";
  gateway_transaction_id: string | null;
  status: PayoutStatus;
  created_at: string;
  paid_at: string | null;
  items: PayoutItem[];
}

// --- Mechanic web portal ---

export interface MeResponse {
  id: string;
  email: string;
  phone: string;
  full_name: string;
  role: UserRole;
  is_active: boolean;
  is_verified: boolean;
  created_at: string;
}

export interface ProviderDocument {
  id: string;
  doc_type: string | null;
  file_url: string;
  verified: boolean;
  uploaded_at: string;
}

export type PartsSourcingStatus = "PENDING" | "APPROVED" | "REJECTED" | "ORDERED";

export interface PartsSourcingRequest {
  id: string;
  service_request: string;
  requested_by: string | null;
  spare_part: string | null;
  quantity: number;
  status: PartsSourcingStatus;
  order: string | null;
  created_at: string;
}

export interface AdminAnalytics {
  orders_by_status: Record<string, number>;
  service_requests_by_status: Record<string, number>;
  revenue: number;
  active_providers: number;
  open_disputes: number;
}
