"use client";

import { createContext, useContext, useState, type ReactNode } from "react";

import type { SessionUser } from "@/lib/types";

interface AuthContextValue {
  user: SessionUser | null;
  /** Client-side components call this right after login/register/logout
   * so nav etc. update without waiting for a full page reload. The real
   * cookie is already set by the /api/auth/* route handler by then — this
   * only updates what the UI has in memory. */
  setUser: (user: SessionUser | null) => void;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({
  initialUser,
  children,
}: {
  initialUser: SessionUser | null;
  children: ReactNode;
}) {
  const [user, setUser] = useState(initialUser);
  return <AuthContext.Provider value={{ user, setUser }}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth() must be used within <AuthProvider>");
  return ctx;
}
