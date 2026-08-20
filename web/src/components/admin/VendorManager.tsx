"use client";

import { useState } from "react";

import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Field, Input } from "@/components/ui/Field";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";
import type { Vendor } from "@/lib/types";

export function VendorManager({ initialVendors }: { initialVendors: Vendor[] }) {
  const [vendors, setVendors] = useState(initialVendors);

  return (
    <div className="flex flex-col gap-6">
      <NewVendorForm onCreated={(vendor) => setVendors([vendor, ...vendors])} />
      <div className="flex flex-col divide-y divide-line border border-line bg-surface-raised">
        {vendors.map((vendor) => (
          <VendorRow
            key={vendor.id}
            vendor={vendor}
            onSaved={(updated) => setVendors(vendors.map((v) => (v.id === updated.id ? updated : v)))}
          />
        ))}
      </div>
    </div>
  );
}

function NewVendorForm({ onCreated }: { onCreated: (vendor: Vendor) => void }) {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      const vendor = await apiFetch<Vendor>("/admin/vendors", {
        method: "POST",
        body: { name, contact_email: email || null, contact_phone: phone || null },
      });
      onCreated(vendor);
      setName("");
      setEmail("");
      setPhone("");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Couldn't create that vendor.");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-3 border border-line bg-surface-raised p-4 sm:flex-row sm:items-end">
      <Field label="Vendor name" htmlFor="new-vendor-name">
        <Input id="new-vendor-name" required value={name} onChange={(e) => setName(e.target.value)} />
      </Field>
      <Field label="Contact email" htmlFor="new-vendor-email">
        <Input id="new-vendor-email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} />
      </Field>
      <Field label="Contact phone" htmlFor="new-vendor-phone">
        <Input id="new-vendor-phone" value={phone} onChange={(e) => setPhone(e.target.value)} />
      </Field>
      <Button type="submit" disabled={submitting}>
        {submitting ? "Adding…" : "Add vendor"}
      </Button>
      {error ? <p className="text-sm text-stop">{error}</p> : null}
    </form>
  );
}

function VendorRow({ vendor, onSaved }: { vendor: Vendor; onSaved: (vendor: Vendor) => void }) {
  const [editing, setEditing] = useState(false);
  const [name, setName] = useState(vendor.name);
  const [email, setEmail] = useState(vendor.contact_email ?? "");
  const [phone, setPhone] = useState(vendor.contact_phone ?? "");
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function save(patch: Partial<Pick<Vendor, "name" | "contact_email" | "contact_phone" | "is_active">>) {
    setSaving(true);
    setError(null);
    try {
      const updated = await apiFetch<Vendor>(`/admin/vendors/${vendor.id}`, { method: "PATCH", body: patch });
      onSaved(updated);
      setEditing(false);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Couldn't save that vendor.");
    } finally {
      setSaving(false);
    }
  }

  if (!editing) {
    return (
      <div className="flex items-center justify-between gap-4 p-4">
        <div className="flex flex-col gap-0.5">
          <span className="text-sm font-semibold text-asphalt">{vendor.name}</span>
          <span className="text-xs text-steel-soft">{vendor.contact_email || vendor.contact_phone || "No contact on file"}</span>
        </div>
        <div className="flex items-center gap-3">
          <Badge tone={vendor.is_active ? "go" : "stop"}>{vendor.is_active ? "Active" : "Inactive"}</Badge>
          <Button variant="ghost" onClick={() => setEditing(true)}>
            Edit
          </Button>
          <Button
            variant={vendor.is_active ? "danger" : "secondary"}
            disabled={saving}
            onClick={() => save({ is_active: !vendor.is_active })}
          >
            {vendor.is_active ? "Deactivate" : "Activate"}
          </Button>
        </div>
      </div>
    );
  }

  return (
    <form
      onSubmit={(e) => {
        e.preventDefault();
        save({ name, contact_email: email || null, contact_phone: phone || null });
      }}
      className="flex flex-col gap-3 p-4 sm:flex-row sm:items-end"
    >
      <Field label="Vendor name" htmlFor={`vendor-name-${vendor.id}`}>
        <Input id={`vendor-name-${vendor.id}`} value={name} onChange={(e) => setName(e.target.value)} />
      </Field>
      <Field label="Contact email" htmlFor={`vendor-email-${vendor.id}`}>
        <Input id={`vendor-email-${vendor.id}`} value={email} onChange={(e) => setEmail(e.target.value)} />
      </Field>
      <Field label="Contact phone" htmlFor={`vendor-phone-${vendor.id}`}>
        <Input id={`vendor-phone-${vendor.id}`} value={phone} onChange={(e) => setPhone(e.target.value)} />
      </Field>
      <div className="flex gap-2">
        <Button type="submit" disabled={saving}>
          {saving ? "Saving…" : "Save"}
        </Button>
        <Button type="button" variant="ghost" onClick={() => setEditing(false)}>
          Cancel
        </Button>
      </div>
      {error ? <p className="text-sm text-stop">{error}</p> : null}
    </form>
  );
}
