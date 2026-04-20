import { GitHubPatForm } from "@/app/settings/_components/github-pat-form";
import { getStoredGitHubViewer } from "@/lib/server/github";

async function GitHubStatusCard() {
  try {
    const result = await getStoredGitHubViewer();

    if (!result) {
      return (
        <div className="panel">
          <div className="panel-header">
            <div>
              <h2 className="text-lg font-semibold text-white">Stored GitHub identity</h2>
              <p className="muted">No PAT has been saved in Mission Control yet.</p>
            </div>
          </div>
          <div className="panel-body text-sm text-slate-400">
            Save a PAT below to connect the dashboard to GitHub using the server-side credential store.
          </div>
        </div>
      );
    }

    return (
      <div className="panel">
        <div className="panel-header">
          <div>
            <h2 className="text-lg font-semibold text-white">Stored GitHub identity</h2>
            <p className="muted">Validated from the encrypted PAT stored in PostgreSQL.</p>
          </div>
        </div>
        <div className="panel-body grid gap-4 md:grid-cols-2">
          <div>
            <div className="text-sm text-slate-400">GitHub account</div>
            <div className="mt-1 text-xl font-semibold text-white">{result.viewer.login}</div>
          </div>
          <div>
            <div className="text-sm text-slate-400">Token hint</div>
            <div className="mt-1 text-white">{result.credential.tokenHint ?? "Stored"}</div>
          </div>
          <div>
            <div className="text-sm text-slate-400">Credential status</div>
            <div className="mt-1 text-emerald-300">{result.credential.status}</div>
          </div>
          <div>
            <div className="text-sm text-slate-400">Scopes</div>
            <div className="mt-1 flex flex-wrap gap-2">
              {result.scopes.length ? result.scopes.map((scope) => (
                <span key={scope} className="status-chip border-sky-400/20 bg-sky-400/10 text-sky-200">{scope}</span>
              )) : <span className="text-slate-400">No scopes returned by GitHub</span>}
            </div>
          </div>
        </div>
      </div>
    );
  } catch (error) {
    return (
      <div className="panel">
        <div className="panel-header">
          <div>
            <h2 className="text-lg font-semibold text-white">Stored GitHub identity</h2>
            <p className="muted">The credential check failed.</p>
          </div>
        </div>
        <div className="panel-body text-sm text-rose-300">
          {error instanceof Error ? error.message : "Unable to validate the stored GitHub credential."}
        </div>
      </div>
    );
  }
}

export default async function SettingsPage() {
  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-2xl font-semibold text-white">Settings</h1>
        <p className="muted">Credentials, integration health, and environment configuration.</p>
      </div>
      <GitHubStatusCard />
      <GitHubPatForm />
    </div>
  );
}
