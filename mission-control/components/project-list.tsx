import { projectSummaries } from "@/lib/data";
import { StatusChip } from "@/components/status-chip";

export function ProjectList() {
  return (
    <div className="panel">
      <div className="panel-header">
        <div>
          <h2 className="text-lg font-semibold text-white">Projects</h2>
          <p className="muted">Active and planned delivery streams</p>
        </div>
      </div>
      <div className="divide-y divide-white/10">
        {projectSummaries.map((project) => (
          <div key={project.id} className="grid gap-4 px-5 py-4 md:grid-cols-[1.5fr_auto_auto_auto] md:items-center">
            <div>
              <div className="flex items-center gap-3">
                <h3 className="font-medium text-white">{project.name}</h3>
                <StatusChip value={project.status}>{project.status}</StatusChip>
                <StatusChip value={project.priority}>{project.priority}</StatusChip>
              </div>
              <p className="mt-2 text-sm text-slate-400">{project.summary}</p>
              <p className="mt-2 text-xs text-cyan-300">{project.repo}</p>
            </div>
            <div>
              <div className="text-xs uppercase tracking-wide text-slate-500">Active tasks</div>
              <div className="mt-1 text-lg font-semibold text-white">{project.activeTasks}</div>
            </div>
            <div>
              <div className="text-xs uppercase tracking-wide text-slate-500">Running agents</div>
              <div className="mt-1 text-lg font-semibold text-white">{project.runningAgents}</div>
            </div>
            <div className="text-right text-sm text-slate-300">Open project →</div>
          </div>
        ))}
      </div>
    </div>
  );
}
