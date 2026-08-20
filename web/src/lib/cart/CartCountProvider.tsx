"use client";

import { createContext, useContext, useState, type ReactNode } from "react";

interface CartCountContextValue {
  count: number;
  setCount: (count: number) => void;
}

const CartCountContext = createContext<CartCountContextValue | null>(null);

export function CartCountProvider({
  initialCount,
  children,
}: {
  initialCount: number;
  children: ReactNode;
}) {
  const [count, setCount] = useState(initialCount);
  return (
    <CartCountContext.Provider value={{ count, setCount }}>{children}</CartCountContext.Provider>
  );
}

export function useCartCount() {
  const ctx = useContext(CartCountContext);
  if (!ctx) throw new Error("useCartCount() must be used within <CartCountProvider>");
  return ctx;
}
