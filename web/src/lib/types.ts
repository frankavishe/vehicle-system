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
