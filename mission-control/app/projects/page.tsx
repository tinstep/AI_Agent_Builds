import { ProjectList } from "@/components/project-list";

export default function ProjectsPage() {
  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-2xl font-semibold text-white">Projects</h1>
        <p className="muted">Project registry with linked delivery context and GitHub repos.</p>
      </div>
      <ProjectList />
    </div>
  );
}
