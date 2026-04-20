import { Bell, Search } from "lucide-react";

export function Topbar() {
  return (
    <div className="flex items-center justify-between gap-4 border-b border-white/10 px-6 py-4">
      <div>
        <div className="text-xs uppercase tracking-[0.28em] text-slate-400">Mission status</div>
        <h1 className="text-2xl font-semibold text-white">Control the work, not just the backlog</h1>
      </div>
      <div className="flex items-center gap-3">
        <div className="flex min-w-80 items-center gap-2 rounded-xl border border-white/10 bg-white/5 px-3 py-2 text-slate-400">
          <Search className="h-4 w-4" />
          <span className="text-sm">Search projects, tasks, agents, cron, GitHub</span>
        </div>
        <button className="rounded-xl border border-white/10 bg-white/5 p-2 text-slate-300 hover:bg-white/10">
          <Bell className="h-4 w-4" />
        </button>
      </div>
    </div>
  );
}
