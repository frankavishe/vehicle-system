import { redirect } from "next/navigation";

import { LoginForm } from "@/components/auth/LoginForm";
import { getSession } from "@/lib/auth/session";

export default async function LoginPage() {
  const user = await getSession();
  if (user) redirect("/");

  return (
    <div className="flex flex-col items-center gap-8 py-8">
      <h1 className="font-display text-4xl font-bold uppercase tracking-tight text-asphalt">Sign in</h1>
      <LoginForm />
    </div>
  );
}
