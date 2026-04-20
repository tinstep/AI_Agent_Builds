import { cronSummaries } from "@/lib/data";
import { StatusChip } from "@/components/status-chip";

export function CronPanel() {
  return (
    <div className="panel">
      <div className="panel-header">
        <div>
          <h2 className="text-lg font-semibold text-white">Cron Center</h2>
          <p className="muted">Scheduled jobs mirrored from OpenClaw</p>
        </div>
      </div>
      <div className="divide-y divide-white/10">
        {cronSummaries.map((cron) => (
          <div key={cron.id} className="grid gap-3 px-5 py-4 md:grid-cols-[1.4fr_auto_auto] md:items-center">
            <div>
              <div className="font-medium text-white">{cron.name}</div>
              <div className="mt-1 text-sm text-slate-400">{cron.schedule}</div>
            </div>
            <StatusChip value={cron.status}>{cron.status}</StatusChip>
            <div className="text-sm text-slate-400">Next run {cron.nextRun}</div>
          </div>
        ))}
      </div>
    </div>
  );
}
