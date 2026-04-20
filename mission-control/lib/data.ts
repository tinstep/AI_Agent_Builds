import { CronSummary, LaunchableSummary, ProjectDetail, ProjectSummary, TaskCardData } from "@/lib/types";

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
  {
    id: "p3",
    name: "Music Genre Playlist",
    slug: "app_music_genre_playlist",
    status: "active",
    priority: "medium",
    summary: "Playlist generation and merging tools for genre-based music workflows, backed by the existing workspace folder.",
    repo: "local/app_music_genre_playlist",
    activeTasks: 2,
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

export const projectDetails: Record<string, ProjectDetail> = {
  "mission-control": {
    ...projectSummaries[0],
    description:
      "Mission Control is the operator dashboard for managing projects, sub-agents, launches, cron jobs, and GitHub-linked delivery from one console.",
    notes: [
      "Build the operator-first UI before wiring every integration.",
      "Use GitHub PAT as the canonical GitHub auth model.",
    ],
    launchables: ["Sync GitHub Mirrors", "Dispatch Sub-agent Task"],
    cronJobs: ["Mission Control Sync"],
    linkedRepos: ["tinstep/mission-control"],
  },
  "home-lab-automation": {
    ...projectSummaries[1],
    description:
      "Automation work for the home lab and Home Assistant, with reusable scheduled flows and operational jobs.",
    notes: [
      "Keep cron-backed maintenance visible in Mission Control.",
      "Prefer reusable launchables over one-off scripts.",
    ],
    launchables: ["Refresh Cron Inventory"],
    cronJobs: ["Morning Briefing"],
    linkedRepos: ["tinstep/home-lab"],
  },
  app_music_genre_playlist: {
    ...projectSummaries[2],
    description:
      "Existing playlist generation and merge tooling in the workspace for genre-based music workflows.",
    notes: [
      "Backed by the existing openclaw workspace folder.",
      "Needs project-level task tracking and launch registration.",
    ],
    launchables: ["Generate Genre Playlist", "Merge Playlists"],
    cronJobs: [],
    linkedRepos: ["local/app_music_genre_playlist"],
  },
};
