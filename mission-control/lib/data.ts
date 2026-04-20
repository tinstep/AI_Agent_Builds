import { CronSummary, LaunchableSummary, ProjectSummary, TaskCardData } from "@/lib/types";

export const projectSummaries: ProjectSummary[] = [
  {
    id: "p1",
    name: "Mission Control",
    slug: "mission-control",
    status: "active",
    priority: "critical",
    summary: "Operator console for projects, sub-agents, launches, cron jobs, and GitHub linked delivery.",
    repo: "tinstep/mission-control",
    activeTasks: 7,
    runningAgents: 2,
  },
  {
    id: "p2",
    name: "Home Lab Automation",
    slug: "home-lab-automation",
    status: "planned",
    priority: "high",
    summary: "Reusable flows and scheduled operations for lab services and Home Assistant.",
    repo: "tinstep/home-lab",
    activeTasks: 3,
    runningAgents: 0,
  },
];

export const taskBoard: Record<string, TaskCardData[]> = {
  backlog: [
    { id: "t1", title: "Define launch handler registry", project: "Mission Control", status: "backlog", assignee: "Unassigned" },
  ],
  ready: [
    { id: "t2", title: "Wire GitHub PAT validation panel", project: "Mission Control", status: "ready", assignee: "Sub-agent: ui-builder", githubRef: "#12" },
  ],
  in_progress: [
    { id: "t3", title: "Draft Prisma schema", project: "Mission Control", status: "in_progress", assignee: "Cam" },
    { id: "t4", title: "Prototype cron mirror sync", project: "Home Lab Automation", status: "in_progress", assignee: "Sub-agent: backend-ops" },
  ],
  review: [
    { id: "t5", title: "Dashboard shell navigation", project: "Mission Control", status: "review", assignee: "Sub-agent: frontend" },
  ],
  blocked: [
    { id: "t6", title: "Real OpenClaw adapter contract", project: "Mission Control", status: "blocked", assignee: "Waiting on API details" },
  ],
  done: [
    { id: "t7", title: "Mission Control product specification", project: "Mission Control", status: "done", assignee: "Main session" },
  ],
};

export const launchables: LaunchableSummary[] = [
  { id: "l1", name: "Sync GitHub Mirrors", category: "GitHub", safetyLevel: "safe internal write", lastRun: "5m ago" },
  { id: "l2", name: "Dispatch Sub-agent Task", category: "OpenClaw", safetyLevel: "elevated internal action", lastRun: "12m ago" },
  { id: "l3", name: "Refresh Cron Inventory", category: "Operations", safetyLevel: "safe read-only", lastRun: "1h ago" },
];

export const cronSummaries: CronSummary[] = [
  { id: "c1", name: "Morning Briefing", schedule: "0 7 * * *", status: "healthy", nextRun: "Tomorrow 07:00" },
  { id: "c2", name: "Mission Control Sync", schedule: "*/15 * * * *", status: "warning", nextRun: "22:30" },
  { id: "c3", name: "Review Open PRs", schedule: "0 */2 * * *", status: "disabled", nextRun: "Disabled" },
];

export const githubConnection = {
  account: "tinstep",
  status: "connected",
  authModel: "Personal Access Token",
  scopes: ["repo", "read:org", "workflow"],
  linkedRepos: 2,
  lastValidated: "Just now",
};
