import type { ReactNode } from "react";

export function Field({
  label,
  htmlFor,
  error,
  children,
}: {
  label: string;
  htmlFor: string;
  error?: string;
  children: ReactNode;
}) {
  return (
    <div className="flex flex-col gap-1.5">
      <label htmlFor={htmlFor} className="text-xs font-semibold uppercase tracking-wide text-steel">
        {label}
      </label>
      {children}
      {error ? <p className="text-xs text-stop">{error}</p> : null}
    </div>
  );
}

const controlClass =
  "w-full border border-line bg-surface-raised px-3 py-2.5 text-sm text-asphalt " +
  "placeholder:text-steel-soft focus:border-signal";

export function Input(props: React.InputHTMLAttributes<HTMLInputElement>) {
  return <input {...props} className={`${controlClass} ${props.className ?? ""}`} />;
}

export function Select(props: React.SelectHTMLAttributes<HTMLSelectElement>) {
  return <select {...props} className={`${controlClass} ${props.className ?? ""}`} />;
}

export function Textarea(props: React.TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return <textarea {...props} className={`${controlClass} ${props.className ?? ""}`} />;
}
