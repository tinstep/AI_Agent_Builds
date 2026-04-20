import { GitHubPanel } from "@/components/github-panel";

export default function SettingsPage() {
  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-2xl font-semibold text-white">Settings</h1>
        <p className="muted">Credentials, integration health, and environment configuration.</p>
      </div>
      <GitHubPanel />
    </div>
  );
}
