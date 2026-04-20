"use client";

import { useActionState } from "react";
import { saveGitHubPat, type GitHubPatState } from "@/app/settings/actions";

const initialState: GitHubPatState = {
  success: false,
  message: "",
};

export function GitHubPatForm() {
  const [state, formAction, pending] = useActionState(saveGitHubPat, initialState);

  return (
    <form action={formAction} className="panel">
      <div className="panel-header">
        <div>
          <h2 className="text-lg font-semibold text-white">GitHub PAT</h2>
          <p className="muted">Store and validate the personal access token used by Mission Control.</p>
        </div>
      </div>
      <div className="panel-body space-y-4">
        <div>
          <label htmlFor="token" className="mb-2 block text-sm font-medium text-slate-200">
            Personal access token
          </label>
          <input
            id="token"
            name="token"
            type="password"
            placeholder="github_pat_..."
            className="w-full rounded-xl border border-white/10 bg-slate-950/80 px-4 py-3 text-sm text-white outline-none ring-0 placeholder:text-slate-500"
          />
        </div>
        <div className="text-sm text-slate-400">
          The token is validated against GitHub and then encrypted before being stored in PostgreSQL.
        </div>
        {state.message ? (
          <div className={`rounded-xl border px-4 py-3 text-sm ${state.success ? "border-emerald-400/30 bg-emerald-400/10 text-emerald-200" : "border-rose-400/30 bg-rose-400/10 text-rose-200"}`}>
            {state.message}
          </div>
        ) : null}
        <button
          type="submit"
          disabled={pending}
          className="rounded-xl bg-cyan-400 px-4 py-2 text-sm font-medium text-slate-950 transition hover:bg-cyan-300 disabled:cursor-not-allowed disabled:opacity-60"
        >
          {pending ? "Validating..." : "Save GitHub PAT"}
        </button>
      </div>
    </form>
  );
}
