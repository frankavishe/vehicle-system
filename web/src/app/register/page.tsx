import { redirect } from "next/navigation";

import { RegisterForm } from "@/components/auth/RegisterForm";
import { getSession } from "@/lib/auth/session";

export default async function RegisterPage() {
  const user = await getSession();
  if (user) redirect("/");

  return (
    <div className="flex flex-col items-center gap-8 py-8">
      <h1 className="font-display text-4xl font-bold uppercase tracking-tight text-asphalt">
        Create your account
      </h1>
      <RegisterForm />
    </div>
  );
}
