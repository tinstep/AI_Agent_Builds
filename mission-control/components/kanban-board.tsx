import { taskBoard } from "@/lib/data";
import { StatusChip } from "@/components/status-chip";

const columns = [
  ["backlog", "Backlog"],
  ["ready", "Ready"],
  ["in_progress", "In Progress"],
  ["review", "Review"],
  ["blocked", "Blocked"],
  ["done", "Done"],
] as const;

export function KanbanBoard() {
  return (
    <div className="grid gap-4 xl:grid-cols-6">
      {columns.map(([key, label]) => (
        <div key={key} className="panel min-h-72">
          <div className="panel-header">
            <div>
              <h3 className="font-medium text-white">{label}</h3>
              <p className="muted">{taskBoard[key].length} cards</p>
            </div>
          </div>
          <div className="space-y-3 p-3">
            {taskBoard[key].map((card) => (
              <div key={card.id} className="rounded-xl border border-white/10 bg-white/5 p-3">
                <div className="text-sm font-medium text-white">{card.title}</div>
                <div className="mt-1 text-xs text-slate-400">{card.project}</div>
                <div className="mt-3 flex flex-wrap items-center gap-2">
                  <StatusChip value={card.status}>{card.status.replace("_", " ")}</StatusChip>
                  <span className="text-xs text-slate-300">{card.assignee}</span>
                </div>
                {card.githubRef ? <div className="mt-3 text-xs text-cyan-300">GitHub {card.githubRef}</div> : null}
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}
