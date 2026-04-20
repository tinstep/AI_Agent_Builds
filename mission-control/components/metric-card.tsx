export function MetricCard({ label, value, detail }: { label: string; value: string; detail: string }) {
  return (
    <div className="kpi">
      <div className="text-sm text-slate-400">{label}</div>
      <div className="mt-2 text-3xl font-semibold text-white">{value}</div>
      <div className="mt-2 text-sm text-slate-500">{detail}</div>
    </div>
  );
}
