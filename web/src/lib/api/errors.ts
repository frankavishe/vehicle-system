export class ApiError extends Error {
  status: number;
  body: unknown;

  constructor(status: number, body: unknown) {
    super(extractMessage(body));
    this.name = "ApiError";
    this.status = status;
    this.body = body;
  }
}

/** DRF errors show up as {"detail": "..."} (auth/permission/404), as a
 * field-error dict, e.g. {"payment_method": ["This field is required."]},
 * or as a bare array, e.g. ["Insufficient stock for 'X': ..."] — DRF's
 * default exception handler sends `exc.detail` as-is whenever a view
 * raises `ValidationError("some string")` outside a serializer field, and
 * a plain string becomes a one-element list. Flatten any of these shapes
 * into one human-readable line. */
function extractMessage(body: unknown): string {
  if (!body) return "Something went wrong. Please try again.";
  if (typeof body === "string") return body;
  if (Array.isArray(body)) {
    return body.length ? body.map(String).join(" ") : "Something went wrong. Please try again.";
  }
  if (typeof body === "object") {
    const obj = body as Record<string, unknown>;
    if (typeof obj.detail === "string") return obj.detail;
    const lines = Object.entries(obj).map(([field, value]) => {
      const text = Array.isArray(value) ? value.join(" ") : String(value);
      return field === "non_field_errors" ? text : `${field}: ${text}`;
    });
    if (lines.length) return lines.join(" ");
  }
  return "Something went wrong. Please try again.";
}
