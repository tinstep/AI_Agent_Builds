import { ReactNode } from "react";

const toneMap: Record<string, string> = {
  active: "border-cyan-400/30 bg-cyan-400/10 text-cyan-200",
  planned: "border-indigo-400/30 bg-indigo-400/10 text-indigo-200",
  blocked: "border-rose-400/30 bg-rose-400/10 text-rose-200",
  completed: "border-emerald-400/30 bg-emerald-400/10 text-emerald-200",
  healthy: "border-emerald-400/30 bg-emerald-400/10 text-emerald-200",
  warning: "border-amber-400/30 bg-amber-400/10 text-amber-200",
  failing: "border-rose-400/30 bg-rose-400/10 text-rose-200",
  disabled: "border-slate-500/30 bg-slate-500/10 text-slate-300",
  critical: "border-rose-400/30 bg-rose-400/10 text-rose-200",
  high: "border-amber-400/30 bg-amber-400/10 text-amber-200",
  medium: "border-sky-400/30 bg-sky-400/10 text-sky-200",
  low: "border-slate-500/30 bg-slate-500/10 text-slate-300",
};

export function StatusChip({ value, children }: { value: string; children?: ReactNode }) {
  return <span className={`status-chip ${toneMap[value] ?? "border-white/10 bg-white/5 text-white"}`}>{children ?? value}</span>;
}
