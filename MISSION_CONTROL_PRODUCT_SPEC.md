# Mission Control Product Specification

## 1. Purpose

Mission Control is a Next.js based operations dashboard for planning, dispatching, running, and monitoring software work across projects, coding sub-agents, reusable programs, and scheduled cron jobs.

It is designed to be the single operator console for:
- tracking active and planned projects,
- allocating work through a Kanban workflow,
- dispatching coding sub-agents to execute tasks,
- launching previously created programs and flows,
- reviewing and controlling cron jobs,
- connecting project work to GitHub using a personal access token (PAT).

This product is intended for a single primary operator initially, with future support for multiple users.

## 2. Product Goals

### Primary goals
- Provide one place to see all active work.
- Make it easy to allocate tasks to coding sub-agents.
- Make launches of reusable programs safe, visible, and repeatable.
- Make cron jobs visible and manageable from the same interface.
- Tie project execution back to GitHub repositories, issues, pull requests, and commits.

### Secondary goals
- Maintain a clean operational history of what was launched, assigned, changed, and completed.
- Support real-time or near real-time awareness of work in progress.
- Reduce friction between planning and execution.

### Non-goals for v1
- Multi-tenant SaaS support.
- Complex enterprise RBAC.
- Full replacement for GitHub Projects.
- Full CI/CD platform replacement.
- Arbitrary remote code execution without allowlisting.

## 3. Guiding Principles

- Operator-first UX, dense and efficient.
- Every action should leave an audit trail.
- GitHub PAT is the canonical GitHub credential for this product.
- Sensitive credentials remain server-side only.
- OpenClaw remains the execution/orchestration backend where appropriate.
- The dashboard mirrors external state locally for speed, filtering, and history.

## 4. Users

### Primary user
- Cam, acting as planner, dispatcher, operator, and reviewer.

### Future users
- Trusted collaborators with limited access.
- Human reviewers.
- Additional operators.

## 5. Core User Stories

### Project management
- As an operator, I want to create and organize projects so I can see current and upcoming work.
- As an operator, I want each project to have linked GitHub repos, tasks, launches, cron jobs, and activity.

### Kanban and sub-agents
- As an operator, I want to move work items across a Kanban board.
- As an operator, I want to assign a task to a coding sub-agent and track its progress.
- As an operator, I want completed sub-agent output linked back to the task.

### Launch pad
- As an operator, I want a registry of reusable programs and workflows.
- As an operator, I want to run a program with parameters and see logs, status, and history.

### Cron management
- As an operator, I want to review all cron jobs in one place.
- As an operator, I want to enable, disable, edit, run, and inspect cron jobs.
- As an operator, I want cron jobs grouped by project or function.

### GitHub integration
- As an operator, I want to connect GitHub using a personal access token.
- As an operator, I want to link a project to one or more GitHub repositories.
- As an operator, I want to view issues, pull requests, branches, and recent commits related to each project.
- As an operator, I want sub-agent work to map to GitHub branches and pull requests where relevant.

## 6. Scope Overview

Mission Control will contain the following major modules:
- Dashboard Home
- Projects
- Kanban / Work Allocation
- Sub-agent Dispatch and Monitoring
- Launch Pad
- Cron Center
- GitHub Integration Center
- Activity and Audit Log
- Settings

## 7. Functional Requirements

### 7.1 Dashboard Home

The home screen must show:
- active projects,
- tasks in progress,
- blocked tasks,
- currently running sub-agents,
- recent launches,
- recent cron failures,
- upcoming cron runs,
- recent GitHub activity,
- a global activity stream.

The dashboard should support:
- filtering by project,
- filtering by status,
- quick search,
- quick actions such as create task, dispatch agent, launch program, run cron job.

### 7.2 Projects Module

Each project record must support:
- name,
- slug,
- description,
- status,
- priority,
- tags,
- linked GitHub repositories,
- linked Kanban board,
- linked launchables,
- linked cron jobs,
- notes,
- activity timeline.

Project statuses should include:
- idea,
- planned,
- active,
- blocked,
- maintenance,
- completed,
- archived.

Project detail page should include:
- summary panel,
- task board,
- linked repositories,
- linked pull requests,
- linked launches,
- linked cron jobs,
- recent events,
- notes and decisions.

### 7.3 Kanban / Work Allocation

The system must support a Kanban board with configurable columns.

Default columns:
- Backlog
- Ready
- In Progress
- Review
- Blocked
- Done

Each task card must support:
- title,
- description,
- acceptance criteria,
- priority,
- estimate,
- labels,
- project,
- linked GitHub issue,
- linked GitHub branch,
- linked pull request,
- assignee type,
- assignee identity,
- current state,
- due date,
- attachments,
- comments,
- run history.

Assignee types:
- human,
- coding sub-agent,
- unassigned.

Task actions:
- create,
- edit,
- move between columns,
- assign,
- dispatch to sub-agent,
- mark blocked,
- link GitHub issue,
- open GitHub branch or PR context,
- close task.

### 7.4 Sub-agent Dispatch and Monitoring

Mission Control must support dispatching work from a task to a coding sub-agent.

Dispatch flow:
1. Operator opens task.
2. Operator selects an agent template or execution mode.
3. Operator submits task instructions.
4. System creates or resumes an agent session via OpenClaw.
5. Session metadata is stored against the task.
6. Status updates are reflected in the UI.
7. Completion output is attached to the task.

Tracked fields:
- session id,
- run id,
- started at,
- last update at,
- ended at,
- current status,
- summary,
- artifacts,
- linked branch,
- linked pull request.

Sub-agent statuses:
- queued,
- starting,
- running,
- waiting,
- blocked,
- failed,
- completed,
- cancelled.

The UI should provide:
- live or near-live status,
- readable progress summaries,
- jump-to-session links,
- rerun and follow-up actions.

### 7.5 Launch Pad

Launch Pad is a registry of reusable programs, scripts, workflows, and automations.

Each launchable must support:
- name,
- slug,
- description,
- category,
- project association,
- execution type,
- command or handler,
- input schema,
- default inputs,
- environment requirements,
- safety level,
- allowed operators,
- enabled flag,
- tags,
- version,
- last run summary.

Execution types may include:
- local command,
- OpenClaw action,
- workflow definition,
- script wrapper,
- future remote runner.

Each run record must include:
- launchable id,
- run id,
- initiator,
- input payload,
- start time,
- end time,
- status,
- stdout summary,
- stderr summary,
- full logs reference,
- artifacts,
- related project,
- related task.

Safety levels:
- safe read-only,
- safe internal write,
- elevated internal action,
- external side effect.

The UI must make the safety level obvious before execution.

### 7.6 Cron Center

Cron Center is the operational view over scheduled jobs.

It must support:
- list all cron jobs,
- filter by project,
- filter by enabled or disabled,
- filter by failing or healthy,
- inspect schedule,
- inspect next run,
- inspect recent run history,
- run now,
- enable,
- disable,
- edit,
- delete,
- create new cron job.

Mission Control should mirror cron job metadata locally while using OpenClaw as the execution source of truth.

Cron job detail page should show:
- name,
- description,
- owning project,
- schedule,
- payload summary,
- delivery mode,
- enabled state,
- last run,
- next run,
- recent failures,
- run history.

### 7.7 GitHub Integration Center

GitHub integration will use a GitHub personal access token as the standard and always-on credential model for this product.

#### Credential model
- The GitHub PAT is stored server-side only.
- The PAT is never sent to the browser.
- The PAT is stored encrypted at rest.
- The PAT is injected into server-side GitHub API calls only.
- The PAT is treated as the single source of GitHub API authentication for Mission Control.

#### Supported capabilities
Using the PAT, Mission Control must support:
- validating token connectivity,
- retrieving the connected user,
- listing accessible repositories,
- linking repositories to projects,
- reading issues,
- reading pull requests,
- reading branches,
- reading commits,
- creating issues,
- creating branches where supported by implementation,
- creating pull requests in later phases,
- syncing GitHub metadata into local mirrors.

#### Connection center UI
The GitHub settings page should show:
- connection status,
- authenticated user,
- token scope summary if available,
- last validation time,
- accessible repositories,
- linked repositories,
- sync health,
- recent GitHub API errors.

#### Repository linking
A project may link to one or more repositories.

Each repository link should support:
- owner,
- repo name,
- default branch,
- purpose,
- sync enabled flag,
- issue sync enabled flag,
- PR sync enabled flag,
- commit sync enabled flag.

### 7.8 Activity and Audit Log

Every meaningful action must create an activity record, including:
- project changes,
- task changes,
- agent dispatches,
- launches,
- cron changes,
- GitHub syncs,
- GitHub write actions,
- failures,
- manual overrides.

Each activity record should include:
- actor,
- action type,
- object type,
- object id,
- timestamp,
- summary,
- metadata payload.

## 8. Data Model

### Core entities
- User
- Project
- ProjectNote
- Board
- Column
- Task
- TaskComment
- TaskAttachment
- AgentRun
- Launchable
- LaunchRun
- CronJobMirror
- CronRunMirror
- GitHubCredential
- GitHubRepoLink
- GitHubIssueMirror
- GitHubPullRequestMirror
- GitHubBranchMirror
- GitHubCommitMirror
- ActivityEvent

### Key relationships
- Project has many Tasks
- Project has many Launchables
- Project has many CronJobMirrors
- Project has many GitHubRepoLinks
- Task may have one active AgentRun
- Task may link to one GitHub issue and one pull request initially
- LaunchRun may link to Project and Task
- ActivityEvent may reference any top-level object

## 9. Suggested Schema Details

### Project
- id
- name
- slug
- description
- status
- priority
- tags
- createdAt
- updatedAt

### Task
- id
- projectId
- columnId
- title
- description
- acceptanceCriteria
- priority
- estimate
- status
- assigneeType
- assigneeId
- githubIssueNumber
- githubBranchName
- githubPullRequestNumber
- dueAt
- createdAt
- updatedAt

### AgentRun
- id
- taskId
- sessionKey
- runStatus
- summary
- artifactsJson
- startedAt
- lastHeartbeatAt
- completedAt
- failureReason

### Launchable
- id
- projectId
- name
- slug
- description
- category
- executionType
- handler
- inputSchemaJson
- defaultInputsJson
- safetyLevel
- enabled
- version
- createdAt
- updatedAt

### CronJobMirror
- id
- projectId
- externalJobId
- name
- description
- scheduleJson
- payloadJson
- deliveryJson
- enabled
- lastRunAt
- nextRunAt
- lastSyncAt

### GitHubCredential
- id
- provider
- authType
- encryptedToken
- username
- externalUserId
- lastValidatedAt
- status
- createdAt
- updatedAt

### GitHubRepoLink
- id
- projectId
- owner
- repo
- defaultBranch
- purpose
- syncIssues
- syncPullRequests
- syncCommits
- enabled
- createdAt
- updatedAt

## 10. System Architecture

### Frontend
- Next.js App Router
- TypeScript
- Tailwind CSS
- component library such as shadcn/ui
- drag and drop board support
- server-rendered summaries where practical
- client-side live panels where needed

### Backend
- Next.js route handlers and server actions for v1
- PostgreSQL database
- ORM via Prisma or Drizzle
- background sync jobs for GitHub and cron mirrors
- OpenClaw integration service layer

### Integration layers
- OpenClaw adapter for sessions, sub-agents, cron jobs, and launches
- GitHub adapter using PAT-authenticated API calls
- internal event ingestion and normalization layer

## 11. GitHub Technical Design

### Authentication approach
Mission Control will use a GitHub PAT for all GitHub API operations.

Preferred storage options:
1. encrypted database credential record,
2. secret manager,
3. environment variable for local development only.

For local development, `.env.local` may include:
- GITHUB_TOKEN
- GITHUB_OWNER default if useful
- GITHUB_API_URL optional for enterprise compatibility later

### API usage
The system should initially use:
- GitHub REST API for repository, issue, pull request, branch, and commit operations
- optional GraphQL for richer dashboards later

### PAT assumptions
The PAT should have sufficient permissions for:
- repo metadata access,
- issue read/write,
- pull request read/write if enabled later,
- contents read/write if branch or file operations are implemented.

### Sync model
- On connection, validate PAT and fetch viewer info.
- On linking a repo, do an initial metadata pull.
- Periodically sync issues, pull requests, branches, and recent commits.
- Cache summaries in local mirror tables.
- Allow manual resync from UI.

### Failure handling
The system must handle:
- expired token,
- revoked token,
- insufficient scope,
- repository access removed,
- rate limiting,
- transient network failure.

The UI should clearly surface these conditions.

## 12. UX Requirements

### Design characteristics
- dark mode first is acceptable
- high-density layouts
- strong status visibility
- low-friction quick actions
- keyboard shortcuts for key operator actions

### Visual patterns
- left navigation for major modules
- top command bar for global search and quick actions
- split panes for details and logs
- status chips for agents, launches, cron jobs, and GitHub syncs
- activity stream visible globally and per project

### Important views
- Mission overview
- Project detail cockpit
- Board view
- Agent run inspector
- Launch run inspector
- Cron inspector
- GitHub connection and repo browser

## 13. Permissions and Safety

### v1 permissions
- single trusted operator by default
- optional read-only viewer role later

### Safety rules
- Launchables with external side effects must require confirmation.
- GitHub write actions should require explicit user initiation.
- PAT must never be visible in logs, UI, browser responses, or exported audit records.
- Sensitive outputs should be redacted in summaries when needed.

## 14. Observability

The system should capture:
- request logs,
- integration errors,
- sync latency,
- agent status update latency,
- launch success/failure rate,
- cron success/failure rate,
- GitHub API error rates.

A lightweight admin diagnostics panel is desirable.

## 15. Performance Requirements

- Dashboard initial load under 2 seconds on normal local network conditions once data exists.
- Project page load under 2.5 seconds.
- Kanban interactions should feel immediate.
- Status refresh for active work should occur within a few seconds.
- Background sync should not block foreground actions.

## 16. Proposed Delivery Phases

### Phase 1: Foundation
- scaffold Next.js app
- add database and ORM
- add project CRUD
- add basic dashboard layout
- add settings and GitHub PAT connection storage
- validate GitHub connectivity

### Phase 2: Kanban and Tasks
- implement boards and tasks
- implement drag-and-drop
- implement project detail page
- implement task comments and history

### Phase 3: Sub-agent Dispatch
- OpenClaw adapter for session dispatch
- task to sub-agent workflow
- agent run status tracking
- completion summaries on cards

### Phase 4: Launch Pad
- launchable registry
- input forms
- run execution pipeline
- run history and logs

### Phase 5: Cron Center
- cron mirror sync
- cron listing and details
- run-now, enable, disable, edit flows

### Phase 6: GitHub Deep Integration
- repo linking
- issue and PR mirrors
- commit stream
- branch and PR creation flows where desired
- project-to-repo automation patterns

### Phase 7: Polish
- activity stream improvements
- keyboard shortcuts
- filters and saved views
- diagnostics panel
- export/reporting options

## 17. Open Questions

- Should GitHub PAT be entered manually in the UI, loaded from env, or both?
- Should one PAT support all projects, or should the app support multiple GitHub credentials later?
- Should task creation be able to auto-create GitHub issues in v1 or later?
- Should Launch Pad support arbitrary shell execution in v1, or only registered allowlisted handlers?
- How tightly should cron jobs be modeled as project objects versus global infrastructure objects?
- Should Mission Control include embedded logs from OpenClaw sessions directly, or only summaries and deep links initially?

## 18. Recommended Decisions for v1

- Use one operator account.
- Use one GitHub PAT as the canonical GitHub credential.
- Store the PAT server-side and encrypted.
- Use local environment variables for development bootstrap only.
- Build around allowlisted launchables, not arbitrary command entry.
- Mirror external state locally for speed and auditability.
- Keep GitHub writes explicit, not automatic.

## 19. Acceptance Criteria for v1

Mission Control v1 is successful when:
- a project can be created and viewed,
- tasks can be created and moved on a Kanban board,
- a task can be dispatched to a coding sub-agent,
- a reusable program can be launched and its result inspected,
- cron jobs can be listed and reviewed,
- a GitHub PAT can be configured and validated,
- at least one GitHub repo can be linked to a project,
- project pages show linked GitHub repo metadata,
- all major actions generate activity records.

## 20. Summary

Mission Control should be built as a practical operator console for managing work from idea through execution. The product should combine planning, dispatch, runtime control, scheduling, and GitHub awareness in one coherent dashboard.

For this implementation, GitHub integration should consistently use a personal access token as the standard authentication model, with all token handling kept server-side and all GitHub interactions auditable and explicit.
