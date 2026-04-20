import Link from "next/link";
import { notFound } from "next/navigation";
import { projectDetails } from "@/lib/data";
import { StatusChip } from "@/components/status-chip";

export function generateStaticParams() {
  return Object.keys(projectDetails).map((slug) => ({ slug }));
}

export default async function ProjectDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const project = projectDetails[slug];

  if (!project) {
    notFound();
  }

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between gap-4">
        <div>
          <div className="mb-2">
            <Link href="/projects" className="text-sm text-cyan-300 hover:text-cyan-200">
              ← Back to Projects
            </Link>
          </div>
          <h1 className="text-3xl font-semibold text-white">{project.name}</h1>
          <p className="mt-2 max-w-3xl text-slate-400">{project.description}</p>
          <div className="mt-4 flex flex-wrap gap-2">
            <StatusChip value={project.status}>{project.status}</StatusChip>
            <StatusChip value={project.priority}>{project.priority}</StatusChip>
          </div>
        </div>
        <div className="panel min-w-64">
          <div className="panel-body space-y-3">
            <div>
              <div className="text-xs uppercase tracking-wide text-slate-500">Repository</div>
              <div className="mt-1 text-white">{project.repo}</div>
            </div>
            <div>
              <div className="text-xs uppercase tracking-wide text-slate-500">Active tasks</div>
              <div className="mt-1 text-2xl font-semibold text-white">{project.activeTasks}</div>
            </div>
            <div>
              <div className="text-xs uppercase tracking-wide text-slate-500">Running agents</div>
              <div className="mt-1 text-2xl font-semibold text-white">{project.runningAgents}</div>
            </div>
          </div>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <div className="panel">
          <div className="panel-header">
            <div>
              <h2 className="text-lg font-semibold text-white">Project notes</h2>
              <p className="muted">Current context and decisions</p>
            </div>
          </div>
          <div className="panel-body">
            <ul className="space-y-3 text-slate-300">
              {project.notes.map((note) => (
                <li key={note} className="rounded-xl border border-white/10 bg-white/5 px-4 py-3">
                  {note}
                </li>
              ))}
            </ul>
          </div>
        </div>

        <div className="panel">
          <div className="panel-header">
            <div>
              <h2 className="text-lg font-semibold text-white">Linked repositories</h2>
              <p className="muted">GitHub or local source locations</p>
            </div>
          </div>
          <div className="panel-body space-y-3">
            {project.linkedRepos.map((repo) => (
              <div key={repo} className="rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-cyan-300">
                {repo}
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <div className="panel">
          <div className="panel-header">
            <div>
              <h2 className="text-lg font-semibold text-white">Launchables</h2>
              <p className="muted">Programs and flows tied to this project</p>
            </div>
          </div>
          <div className="panel-body space-y-3">
            {project.launchables.length ? (
              project.launchables.map((item) => (
                <div key={item} className="rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-white">
                  {item}
                </div>
              ))
            ) : (
              <div className="text-slate-400">No launchables linked yet.</div>
            )}
          </div>
        </div>

        <div className="panel">
          <div className="panel-header">
            <div>
              <h2 className="text-lg font-semibold text-white">Cron jobs</h2>
              <p className="muted">Scheduled automation linked to this project</p>
            </div>
          </div>
          <div className="panel-body space-y-3">
            {project.cronJobs.length ? (
              project.cronJobs.map((item) => (
                <div key={item} className="rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-white">
                  {item}
                </div>
              ))
            ) : (
              <div className="text-slate-400">No cron jobs linked yet.</div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
