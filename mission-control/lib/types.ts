export type ProjectStatus =
  | "idea"
  | "planned"
  | "active"
  | "blocked"
  | "maintenance"
  | "completed";

export type TaskStatus =
  | "backlog"
  | "ready"
  | "in_progress"
  | "review"
  | "blocked"
  | "done";

export interface ProjectSummary {
  id: string;
  name: string;
  slug: string;
  status: ProjectStatus;
  priority: "low" | "medium" | "high" | "critical";
  summary: string;
  repo: string;
  activeTasks: number;
  runningAgents: number;
}

export interface TaskCardData {
  id: string;
  title: string;
  project: string;
  status: TaskStatus;
  assignee: string;
  githubRef?: string;
}

export interface LaunchableSummary {
  id: string;
  name: string;
  category: string;
  safetyLevel: string;
  lastRun: string;
}

export interface CronSummary {
  id: string;
  name: string;
  schedule: string;
  status: "healthy" | "warning" | "failing" | "disabled";
  nextRun: string;
}
