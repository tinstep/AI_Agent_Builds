# Mission Control Technical Architecture

## 1. Overview

Mission Control is a Next.js operator console that sits above three execution domains:
- project and task planning,
- OpenClaw-based agent orchestration and cron control,
- GitHub repository visibility and actions using a personal access token (PAT).

The architecture is intentionally split into a fast local application core and a set of thin integration adapters. The app owns the UX, local state model, audit trail, and operational mirrors. OpenClaw and GitHub remain external systems of record for execution-specific state.

## 2. Architecture Goals

- Keep the UI fast by querying local mirrored state first.
- Keep external integrations isolated behind adapter interfaces.
- Keep GitHub PAT handling server-side only.
- Make every write operation explicit, traceable, and reversible where possible.
- Support incremental delivery, starting with a single trusted operator.

## 3. High-Level System Diagram

```text
Browser UI
  -> Next.js App Router
    -> Server Actions / Route Handlers
      -> Application Services
        -> PostgreSQL
        -> OpenClaw Adapter
        -> GitHub Adapter (PAT)
        -> Internal Event / Sync Jobs
```

## 4. Runtime Components

### 4.1 Frontend
- Next.js App Router
- TypeScript
- Tailwind CSS
- component primitives via shadcn/ui or equivalent
- selective client components for drag and drop, live status panels, and command palette interactions

### 4.2 Backend-in-App Layer
Implemented inside the Next.js application for v1:
- route handlers for integration endpoints
- server actions for trusted mutations
- application service layer in `lib/server/*`
- validation via Zod
- auth guard middleware for operator access

### 4.3 Persistence
- PostgreSQL as the primary database
- Prisma ORM for schema definition and migrations
- local mirrors for GitHub, cron jobs, and selected OpenClaw session state

### 4.4 Integration Adapters
#### OpenClaw adapter
Responsibilities:
- dispatch sub-agent work
- inspect and mirror session status
- list and mirror cron jobs
- trigger cron runs
- register launches that are backed by OpenClaw actions

#### GitHub adapter
Responsibilities:
- validate PAT
- fetch authenticated user
- fetch repository metadata
- sync issues, pull requests, branches, commits
- perform explicit GitHub write operations when allowed

## 5. Logical Layers

### Presentation layer
- pages, layouts, components, view models
- reads optimized summary data
- uses actions for high-trust writes

### Application layer
- project service
- task service
- agent run service
- launch service
- cron mirror service
- GitHub integration service
- activity event service

### Integration layer
- `OpenClawClient`
- `GitHubClient`
- retry, error mapping, response normalization

### Data layer
- Prisma models
- repository functions for tailored query patterns
- event appenders

## 6. Primary Data Flows

### 6.1 Project and task flow
1. User creates project.
2. App writes Project, Board, and default Columns.
3. User creates tasks on board.
4. UI queries board view model from local database.

### 6.2 Task to sub-agent dispatch flow
1. Operator opens task and clicks dispatch.
2. Server action validates task state and operator permissions.
3. Application service calls OpenClaw adapter.
4. Adapter creates or resumes session.
5. App stores AgentRun and links it to Task.
6. Polling or webhook-like sync updates AgentRun status.
7. Completion summary is written to Task and ActivityEvent.

### 6.3 Launch flow
1. Operator selects Launchable and enters inputs.
2. Server validates input schema.
3. Launch service resolves execution handler.
4. Handler executes local or OpenClaw-backed action.
5. LaunchRun records status and summary.
6. UI reflects completion and artifacts.

### 6.4 Cron mirror flow
1. Scheduled sync calls OpenClaw cron list and run history.
2. Results are normalized into CronJobMirror and CronRunMirror.
3. UI reads mirror tables for fast filtering and detail views.
4. Explicit user actions call OpenClaw first, then refresh mirror state.

### 6.5 GitHub sync flow
1. PAT is stored encrypted in server-side credential storage.
2. Validation fetches authenticated viewer and repo visibility.
3. Linking a repo creates GitHubRepoLink.
4. Sync jobs fetch metadata from GitHub REST API.
5. Mirrors update GitHubIssueMirror, GitHubPullRequestMirror, GitHubBranchMirror, GitHubCommitMirror.
6. Project detail pages render local mirror data.

## 7. Integration Design

### 7.1 OpenClaw adapter interface
Suggested methods:
- `dispatchTask(taskId, payload)`
- `getSession(sessionKey)`
- `listSessions(filters)`
- `listCronJobs()`
- `getCronJob(jobId)`
- `runCronJob(jobId)`
- `enableCronJob(jobId)`
- `disableCronJob(jobId)`
- `createLaunchRun(handler, inputs)`

### 7.2 GitHub adapter interface
Suggested methods:
- `validateToken()`
- `getViewer()`
- `listRepositories()`
- `getRepository(owner, repo)`
- `listIssues(owner, repo)`
- `listPullRequests(owner, repo)`
- `listBranches(owner, repo)`
- `listCommits(owner, repo)`
- `createIssue(owner, repo, payload)`
- `createPullRequest(owner, repo, payload)` later phase

### 7.3 Secrets handling
- PAT stored encrypted, ideally via libsodium or application-level AES-GCM with a server-held master key
- local development may bootstrap from `GITHUB_TOKEN`
- no token values in browser responses, logs, or audit event payloads

## 8. Realtime Strategy

V1 should prefer simple and reliable approaches:
- periodic polling for active agent runs and cron status
- route-level revalidation for summary tiles
- optional SSE endpoint later for live activity feed

Recommendation:
- poll active agent runs every 5 to 10 seconds
- poll cron health every 30 to 60 seconds
- refresh GitHub mirrors on demand plus scheduled background sync

## 9. Background Jobs

The system needs internal scheduled jobs for:
- agent run status refresh
- cron mirror refresh
- GitHub repository sync
- GitHub issue/PR/commit sync
- stale run detection

Delivery options:
- in-process scheduler for local dev
- separate worker process in later phases
- database-backed queue if execution volume grows

## 10. API and Mutation Design

### Read patterns
- SSR for dashboard pages and project pages
- compact summary endpoints for card refreshes
- filtered queries for board views, cron views, and launch history

### Write patterns
- use server actions for trusted UI mutations
- use route handlers for machine-oriented integrations and webhook-like internal callbacks
- all writes generate ActivityEvent records

## 11. Security Model

### Authentication
For v1, a single trusted local operator model is acceptable. Future options:
- NextAuth or Auth.js for session auth
- GitHub OAuth for login, distinct from PAT integration
- local-only auth if this remains a private console

### Authorization
V1 roles:
- operator
- viewer later

### Sensitive actions
Require explicit confirmation for:
- external side effect launchables
- GitHub write operations
- destructive cron changes
- destructive project archival or deletion

## 12. Error Handling

All integration failures should be normalized into categories:
- configuration error
- credential error
- permission error
- rate limit error
- network error
- upstream service unavailable
- validation error

The UI should show clear operator-facing status while logging full diagnostic detail server-side.

## 13. Observability

Required telemetry:
- request ids
- integration latency
- sync success/failure counts
- background job durations
- agent state transition history
- cron failure counts
- GitHub API error categories

Recommended libraries:
- structured logging via pino
- OpenTelemetry later if needed

## 14. Deployment Shape

### Local-first deployment
- Next.js app on one host
- PostgreSQL local or nearby
- OpenClaw reachable from the same machine or network
- GitHub reached over HTTPS

### Environment variables
Minimum planned env set:
- `DATABASE_URL`
- `APP_ENCRYPTION_KEY`
- `GITHUB_TOKEN` optional bootstrap only
- `OPENCLAW_BASE_URL` optional if direct adapter needs it later
- `NEXT_PUBLIC_APP_NAME`

## 15. Repository Structure

Recommended structure:

```text
mission-control/
  app/
  components/
  lib/
    server/
      services/
      adapters/
      repositories/
    validation/
  prisma/
  public/
```

## 16. Technical Decisions for V1

- Next.js App Router
- TypeScript everywhere in app code
- Prisma with PostgreSQL
- Tailwind CSS for fast operator UI build-out
- polling first, SSE later
- GitHub REST API over PAT for all GitHub integration work
- OpenClaw adapter kept behind a service abstraction

## 17. Delivery Roadmap Mapping

### Milestone A
- scaffold app
- base layout
- projects list and detail views
- settings with PAT status

### Milestone B
- Kanban board
- task CRUD
- activity logging

### Milestone C
- sub-agent dispatch
- agent run monitor

### Milestone D
- launch registry and runs
- cron mirror center

### Milestone E
- GitHub repo linking
- issue and PR mirrors
- commit stream

## 18. Risks and Mitigations

### Risk: integration sprawl
Mitigation: keep adapters narrow and typed.

### Risk: PAT overreach
Mitigation: use least-privileged token practical, store encrypted, make writes explicit.

### Risk: stale mirrored state
Mitigation: show last sync time, allow manual resync, keep source-of-truth links visible.

### Risk: noisy operational UI
Mitigation: prioritize summaries, filters, and strong information hierarchy.

## 19. Recommended Next Build Step

Implement Milestone A first:
- app shell
- project data model
- settings screen showing GitHub PAT health
- placeholder cards for sub-agents, launches, and cron status

That gives a visible foundation quickly while preserving the architecture needed for the more interesting parts.