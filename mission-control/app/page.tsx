import { CronPanel } from "@/components/cron-panel";
import { GitHubPanel } from "@/components/github-panel";
import { KanbanBoard } from "@/components/kanban-board";
import { LaunchesPanel } from "@/components/launches-panel";
import { MetricCard } from "@/components/metric-card";
import { ProjectList } from "@/components/project-list";

export default function HomePage() {
  return (
    <div className="space-y-6">
      <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <MetricCard label="Active Projects" value="2" detail="1 critical stream, 1 planned stream" />
        <MetricCard label="Running Sub-agents" value="2" detail="1 frontend, 1 backend-ops" />
        <MetricCard label="Launches Today" value="8" detail="0 failed, 2 elevated actions" />
        <MetricCard label="Cron Health" value="1 warning" detail="2 healthy, 1 disabled, 0 failing" />
      </section>

      <ProjectList />

      <section className="grid gap-6 xl:grid-cols-[1.2fr_0.8fr]">
        <LaunchesPanel />
        <CronPanel />
      </section>

      <GitHubPanel />

      <section>
        <div className="mb-3">
          <h2 className="text-lg font-semibold text-white">Kanban Snapshot</h2>
          <p className="muted">Current allocation across human and sub-agent work</p>
        </div>
        <KanbanBoard />
      </section>
    </div>
  );
}
