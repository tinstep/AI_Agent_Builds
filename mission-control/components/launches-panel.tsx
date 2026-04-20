import { launchables } from "@/lib/data";
import { StatusChip } from "@/components/status-chip";

export function LaunchesPanel() {
  return (
    <div className="panel">
      <div className="panel-header">
        <div>
          <h2 className="text-lg font-semibold text-white">Launch Pad</h2>
          <p className="muted">Registered programs and reusable flows</p>
        </div>
      </div>
      <div className="divide-y divide-white/10">
        {launchables.map((launchable) => (
          <div key={launchable.id} className="flex items-center justify-between gap-4 px-5 py-4">
            <div>
              <div className="font-medium text-white">{launchable.name}</div>
              <div className="mt-1 text-sm text-slate-400">{launchable.category}</div>
            </div>
            <StatusChip value={launchable.safetyLevel.includes("elevated") ? "warning" : "healthy"}>{launchable.safetyLevel}</StatusChip>
            <div className="text-sm text-slate-400">Last run {launchable.lastRun}</div>
          </div>
        ))}
      </div>
    </div>
  );
}
