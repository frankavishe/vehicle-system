"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";

import { Button } from "@/components/ui/Button";
import { Field, Input, Select } from "@/components/ui/Field";
import { useAuth } from "@/lib/auth/AuthProvider";
import { SELF_SERVICE_ROLES, type SessionUser, type UserRole } from "@/lib/types";

export function RegisterForm() {
  const router = useRouter();
  const { setUser } = useAuth();
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [role, setRole] = useState<UserRole>("CUSTOMER");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      const res = await fetch("/api/auth/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ full_name: fullName, email, phone, role, password }),
      });
      const body = await res.json();
      if (!res.ok) {
        setError(extractRegisterError(body));
        return;
      }
      if (body.user) {
        setUser(body.user as SessionUser);
        router.push("/");
        router.refresh();
      } else {
        // Account created but the follow-up auto-login didn't land — see
        // src/app/api/auth/register/route.ts.
        router.push("/login");
      }
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} className="flex w-full max-w-sm flex-col gap-4">
      <Field label="Full name" htmlFor="full_name">
        <Input id="full_name" required value={fullName} onChange={(e) => setFullName(e.target.value)} />
      </Field>
      <Field label="Email" htmlFor="email">
        <Input
          id="email"
          type="email"
          autoComplete="email"
          required
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />
      </Field>
      <Field label="Phone" htmlFor="phone">
        <Input
          id="phone"
          type="tel"
          placeholder="0712 345 678"
          required
          value={phone}
          onChange={(e) => setPhone(e.target.value)}
        />
      </Field>
      <Field label="I am a" htmlFor="role">
        <Select id="role" value={role} onChange={(e) => setRole(e.target.value as UserRole)}>
          {SELF_SERVICE_ROLES.map((r) => (
            <option key={r.value} value={r.value}>
              {r.label}
            </option>
          ))}
        </Select>
      </Field>
      <Field label="Password" htmlFor="password">
        <Input
          id="password"
          type="password"
          autoComplete="new-password"
          minLength={8}
          required
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
      </Field>
      {error ? <p className="text-sm text-stop">{error}</p> : null}
      <Button type="submit" disabled={submitting}>
        {submitting ? "Creating account…" : "Create account"}
      </Button>
      <p className="text-sm text-steel">
        Already have an account?{" "}
        <Link href="/login" className="font-semibold text-signal hover:text-signal-dark">
          Sign in
        </Link>
      </p>
    </form>
  );
}

function extractRegisterError(body: Record<string, unknown>): string {
  if (typeof body.detail === "string") return body.detail;
  const lines = Object.entries(body).map(([field, value]) =>
    Array.isArray(value) ? `${field}: ${value.join(" ")}` : `${field}: ${value}`,
  );
  return lines.join(" ") || "Couldn't create that account.";
}
