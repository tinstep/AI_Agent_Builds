import { LaunchesPanel } from "@/components/launches-panel";

export default function LaunchPadPage() {
  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-2xl font-semibold text-white">Launch Pad</h1>
        <p className="muted">Registered programs, workflows, and execution history.</p>
      </div>
      <LaunchesPanel />
    </div>
  );
}
