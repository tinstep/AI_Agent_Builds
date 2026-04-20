import { githubConnection, projectSummaries } from "@/lib/data";
import { StatusChip } from "@/components/status-chip";

export function GitHubPanel() {
  return (
    <div className="panel">
      <div className="panel-header">
        <div>
          <h2 className="text-lg font-semibold text-white">GitHub Integration</h2>
          <p className="muted">PAT-backed identity and linked repositories</p>
        </div>
      </div>
      <div className="grid gap-5 p-5 lg:grid-cols-[1fr_1.2fr]">
        <div className="rounded-xl border border-white/10 bg-white/5 p-4">
          <div className="text-sm text-slate-400">Connected account</div>
          <div className="mt-2 flex items-center gap-3">
            <div className="text-2xl font-semibold text-white">{githubConnection.account}</div>
            <StatusChip value="healthy">{githubConnection.status}</StatusChip>
          </div>
          <div className="mt-4 text-sm text-slate-300">Auth model: {githubConnection.authModel}</div>
          <div className="mt-2 text-sm text-slate-400">Last validated: {githubConnection.lastValidated}</div>
          <div className="mt-4 flex flex-wrap gap-2">
            {githubConnection.scopes.map((scope) => (
              <span key={scope} className="status-chip border-sky-400/20 bg-sky-400/10 text-sky-200">{scope}</span>
            ))}
          </div>
        </div>
        <div className="rounded-xl border border-white/10 bg-white/5 p-4">
          <div className="text-sm text-slate-400">Linked repositories</div>
          <div className="mt-4 space-y-3">
            {projectSummaries.map((project) => (
              <div key={project.id} className="flex items-center justify-between rounded-lg border border-white/10 px-3 py-3">
                <div>
                  <div className="font-medium text-white">{project.name}</div>
                  <div className="text-sm text-cyan-300">{project.repo}</div>
                </div>
                <div className="text-sm text-slate-400">Sync enabled</div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
