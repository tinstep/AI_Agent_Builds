import { CronPanel } from "@/components/cron-panel";

export default function CronPage() {
  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-2xl font-semibold text-white">Cron Center</h1>
        <p className="muted">Mirror, inspect, and control scheduled jobs.</p>
      </div>
      <CronPanel />
    </div>
  );
}
