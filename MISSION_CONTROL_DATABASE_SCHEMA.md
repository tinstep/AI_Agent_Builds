# Mission Control Database Schema

## 1. Overview

This document defines the initial relational schema for Mission Control. It is optimized for:
- project-centric navigation,
- Kanban task workflows,
- OpenClaw sub-agent tracking,
- Launch Pad execution history,
- cron job mirrors,
- GitHub integration using a personal access token.

Primary database target: PostgreSQL.
ORM target: Prisma.

## 2. Design Principles

- Use stable UUID identifiers.
- Keep source-of-truth external ids where integrations require them.
- Use mirror tables for external state snapshots.
- Store audit records append-only.
- Prefer explicit join tables where cardinality may expand later.
- Use JSON columns for integration payloads that may evolve.

## 3. Core Enums

### ProjectStatus
- IDEA
- PLANNED
- ACTIVE
- BLOCKED
- MAINTENANCE
- COMPLETED
- ARCHIVED

### ProjectPriority
- LOW
- MEDIUM
- HIGH
- CRITICAL

### TaskStatus
- BACKLOG
- READY
- IN_PROGRESS
- REVIEW
- BLOCKED
- DONE
- CANCELLED

### AssigneeType
- HUMAN
- SUB_AGENT
- UNASSIGNED

### AgentRunStatus
- QUEUED
- STARTING
- RUNNING
- WAITING
- BLOCKED
- FAILED
- COMPLETED
- CANCELLED

### LaunchSafetyLevel
- SAFE_READ_ONLY
- SAFE_INTERNAL_WRITE
- ELEVATED_INTERNAL_ACTION
- EXTERNAL_SIDE_EFFECT

### LaunchRunStatus
- PENDING
- RUNNING
- SUCCEEDED
- FAILED
- CANCELLED

### CronHealthStatus
- HEALTHY
- WARNING
- FAILING
- DISABLED
- UNKNOWN

### GitHubCredentialStatus
- VALID
- INVALID
- EXPIRED
- REVOKED
- UNKNOWN

### ActivityObjectType
- PROJECT
- BOARD
- COLUMN
- TASK
- AGENT_RUN
- LAUNCHABLE
- LAUNCH_RUN
- CRON_JOB
- CRON_RUN
- GITHUB_CREDENTIAL
- GITHUB_REPO
- GITHUB_ISSUE
- GITHUB_PULL_REQUEST
- SYSTEM

## 4. Tables

### 4.1 users
Represents local operators and later viewers.

Fields:
- id UUID PK
- email TEXT UNIQUE nullable in v1
- name TEXT
- role TEXT default `operator`
- created_at TIMESTAMP
- updated_at TIMESTAMP

### 4.2 projects
Fields:
- id UUID PK
- slug TEXT UNIQUE
- name TEXT
- description TEXT nullable
- status ProjectStatus
- priority ProjectPriority
- tags JSONB default []
- created_at TIMESTAMP
- updated_at TIMESTAMP
- archived_at TIMESTAMP nullable

Indexes:
- unique slug
- index on status
- index on priority

### 4.3 project_notes
Fields:
- id UUID PK
- project_id UUID FK -> projects.id
- title TEXT nullable
- body TEXT
- created_by UUID FK -> users.id nullable
- created_at TIMESTAMP
- updated_at TIMESTAMP

Indexes:
- index on project_id

### 4.4 boards
One board per project initially, extensible later.

Fields:
- id UUID PK
- project_id UUID UNIQUE FK -> projects.id
- name TEXT
- created_at TIMESTAMP
- updated_at TIMESTAMP

### 4.5 board_columns
Fields:
- id UUID PK
- board_id UUID FK -> boards.id
- key TEXT
- name TEXT
- position INTEGER
- color TEXT nullable
- created_at TIMESTAMP
- updated_at TIMESTAMP

Indexes:
- unique(board_id, key)
- unique(board_id, position)

### 4.6 tasks
Fields:
- id UUID PK
- project_id UUID FK -> projects.id
- board_id UUID FK -> boards.id
- column_id UUID FK -> board_columns.id
- parent_task_id UUID FK -> tasks.id nullable
- title TEXT
- description TEXT nullable
- acceptance_criteria TEXT nullable
- status TaskStatus
- priority ProjectPriority
- estimate_points INTEGER nullable
- assignee_type AssigneeType
- assignee_label TEXT nullable
- github_issue_number INTEGER nullable
- github_branch_name TEXT nullable
- github_pull_request_number INTEGER nullable
- due_at TIMESTAMP nullable
- sort_order DECIMAL nullable
- created_by UUID FK -> users.id nullable
- created_at TIMESTAMP
- updated_at TIMESTAMP
- completed_at TIMESTAMP nullable

Indexes:
- index on project_id
- index on board_id
- index on column_id
- index on status
- index on due_at

### 4.7 task_comments
Fields:
- id UUID PK
- task_id UUID FK -> tasks.id
- author_id UUID FK -> users.id nullable
- body TEXT
- created_at TIMESTAMP
- updated_at TIMESTAMP

### 4.8 task_attachments
Fields:
- id UUID PK
- task_id UUID FK -> tasks.id
- name TEXT
- storage_type TEXT
- storage_path TEXT
- metadata JSONB nullable
- created_at TIMESTAMP

### 4.9 agent_runs
Fields:
- id UUID PK
- task_id UUID FK -> tasks.id
- session_key TEXT
- external_run_id TEXT nullable
- status AgentRunStatus
- agent_label TEXT nullable
- dispatch_prompt TEXT nullable
- summary TEXT nullable
- artifacts JSONB default []
- linked_branch TEXT nullable
- linked_pull_request_number INTEGER nullable
- started_at TIMESTAMP nullable
- last_update_at TIMESTAMP nullable
- completed_at TIMESTAMP nullable
- failure_reason TEXT nullable
- raw_payload JSONB nullable
- created_at TIMESTAMP
- updated_at TIMESTAMP

Indexes:
- index on task_id
- index on session_key
- index on status

### 4.10 launchables
Fields:
- id UUID PK
- project_id UUID FK -> projects.id nullable
- slug TEXT UNIQUE
- name TEXT
- description TEXT nullable
- category TEXT
- execution_type TEXT
- handler TEXT
- input_schema JSONB nullable
- default_inputs JSONB nullable
- environment_requirements JSONB nullable
- safety_level LaunchSafetyLevel
- enabled BOOLEAN default true
- tags JSONB default []
- version TEXT nullable
- created_at TIMESTAMP
- updated_at TIMESTAMP

### 4.11 launch_runs
Fields:
- id UUID PK
- launchable_id UUID FK -> launchables.id
- project_id UUID FK -> projects.id nullable
- task_id UUID FK -> tasks.id nullable
- initiated_by UUID FK -> users.id nullable
- status LaunchRunStatus
- input_payload JSONB nullable
- stdout_summary TEXT nullable
- stderr_summary TEXT nullable
- logs_ref TEXT nullable
- artifacts JSONB default []
- started_at TIMESTAMP nullable
- completed_at TIMESTAMP nullable
- created_at TIMESTAMP
- updated_at TIMESTAMP

Indexes:
- index on launchable_id
- index on project_id
- index on status
- index on created_at

### 4.12 cron_job_mirrors
Fields:
- id UUID PK
- project_id UUID FK -> projects.id nullable
- external_job_id TEXT UNIQUE
- name TEXT
- description TEXT nullable
- schedule_kind TEXT
- schedule_payload JSONB
- payload_kind TEXT
- payload_summary TEXT nullable
- delivery_payload JSONB nullable
- enabled BOOLEAN
- health_status CronHealthStatus default UNKNOWN
- last_run_at TIMESTAMP nullable
- next_run_at TIMESTAMP nullable
- last_sync_at TIMESTAMP nullable
- raw_payload JSONB nullable
- created_at TIMESTAMP
- updated_at TIMESTAMP

Indexes:
- unique external_job_id
- index on project_id
- index on enabled
- index on next_run_at

### 4.13 cron_run_mirrors
Fields:
- id UUID PK
- cron_job_id UUID FK -> cron_job_mirrors.id
- external_run_id TEXT nullable
- status TEXT
- summary TEXT nullable
- started_at TIMESTAMP nullable
- completed_at TIMESTAMP nullable
- raw_payload JSONB nullable
- created_at TIMESTAMP

Indexes:
- index on cron_job_id
- index on started_at

### 4.14 github_credentials
For v1 there may be a single active PAT, but schema supports expansion.

Fields:
- id UUID PK
- name TEXT
- provider TEXT default `github`
- auth_type TEXT default `pat`
- encrypted_token TEXT
- token_hint TEXT nullable
- username TEXT nullable
- external_user_id TEXT nullable
- status GitHubCredentialStatus default UNKNOWN
- last_validated_at TIMESTAMP nullable
- last_error TEXT nullable
- created_at TIMESTAMP
- updated_at TIMESTAMP

### 4.15 github_repo_links
Fields:
- id UUID PK
- project_id UUID FK -> projects.id
- credential_id UUID FK -> github_credentials.id
- owner TEXT
- repo TEXT
- default_branch TEXT nullable
- purpose TEXT nullable
- sync_enabled BOOLEAN default true
- sync_issues BOOLEAN default true
- sync_pull_requests BOOLEAN default true
- sync_commits BOOLEAN default true
- last_sync_at TIMESTAMP nullable
- created_at TIMESTAMP
- updated_at TIMESTAMP

Constraints:
- unique(project_id, owner, repo)

Indexes:
- index on credential_id
- index on project_id

### 4.16 github_issue_mirrors
Fields:
- id UUID PK
- repo_link_id UUID FK -> github_repo_links.id
- external_node_id TEXT nullable
- issue_number INTEGER
- title TEXT
- state TEXT
- author_login TEXT nullable
- assignees JSONB default []
- labels JSONB default []
- url TEXT
- body_excerpt TEXT nullable
- created_at_github TIMESTAMP nullable
- updated_at_github TIMESTAMP nullable
- last_sync_at TIMESTAMP nullable
- raw_payload JSONB nullable
- created_at TIMESTAMP
- updated_at TIMESTAMP

Constraints:
- unique(repo_link_id, issue_number)

### 4.17 github_pull_request_mirrors
Fields:
- id UUID PK
- repo_link_id UUID FK -> github_repo_links.id
- external_node_id TEXT nullable
- pull_request_number INTEGER
- title TEXT
- state TEXT
- author_login TEXT nullable
- head_branch TEXT nullable
- base_branch TEXT nullable
- url TEXT
- draft BOOLEAN default false
- mergeable_state TEXT nullable
- created_at_github TIMESTAMP nullable
- updated_at_github TIMESTAMP nullable
- last_sync_at TIMESTAMP nullable
- raw_payload JSONB nullable
- created_at TIMESTAMP
- updated_at TIMESTAMP

Constraints:
- unique(repo_link_id, pull_request_number)

### 4.18 github_branch_mirrors
Fields:
- id UUID PK
- repo_link_id UUID FK -> github_repo_links.id
- name TEXT
- sha TEXT nullable
- protected BOOLEAN default false
- last_commit_at TIMESTAMP nullable
- last_sync_at TIMESTAMP nullable
- raw_payload JSONB nullable
- created_at TIMESTAMP
- updated_at TIMESTAMP

Constraints:
- unique(repo_link_id, name)

### 4.19 github_commit_mirrors
Fields:
- id UUID PK
- repo_link_id UUID FK -> github_repo_links.id
- sha TEXT
- author_name TEXT nullable
- author_login TEXT nullable
- message TEXT
- committed_at TIMESTAMP nullable
- url TEXT nullable
- last_sync_at TIMESTAMP nullable
- raw_payload JSONB nullable
- created_at TIMESTAMP

Constraints:
- unique(repo_link_id, sha)

### 4.20 activity_events
Append-only event log.

Fields:
- id UUID PK
- actor_id UUID FK -> users.id nullable
- action_type TEXT
- object_type ActivityObjectType
- object_id TEXT
- project_id UUID FK -> projects.id nullable
- summary TEXT
- metadata JSONB nullable
- occurred_at TIMESTAMP
- created_at TIMESTAMP

Indexes:
- index on project_id
- index on object_type
- index on occurred_at desc

## 5. Recommended Defaults

### Default board columns
On project creation, create a board with columns:
1. backlog
2. ready
3. in_progress
4. review
5. blocked
6. done

### Default single credential behavior
If exactly one GitHub credential exists and is valid, use it as the active credential for repo linking by default.

## 6. Normalization Notes

- Tags, labels, assignees, artifacts, and integration payload fragments may remain JSONB for v1.
- If query complexity grows, normalize labels and tags later.
- Store excerpts for heavy text payloads and preserve raw payload JSON for debugging.

## 7. Retention and Cleanup

- Activity events should be retained indefinitely unless policy changes.
- Launch run logs may be summarized in DB and stored externally if large.
- GitHub mirrors should be refreshable and not treated as irreversible history.
- Agent artifacts should prefer references over blob storage in the database.

## 8. Migration Strategy

Start with:
- users
- projects
- boards
- board_columns
- tasks
- activity_events
- github_credentials
- github_repo_links
- cron_job_mirrors
- launchables

Add later if delivery speed matters:
- mirror tables for issues, PRs, branches, commits
- comments and attachments
- run detail tables

## 9. Prisma Mapping Guidance

- Map UUID fields with `@db.Uuid`
- Map JSON payloads with `Json`
- Use Prisma enums for the status domains above
- Use `@updatedAt` on mutable timestamp columns
- Use `@@index` and `@@unique` to match the constraints listed here

## 10. V1 Acceptance for Schema

The schema is sufficient for v1 when it can:
- store projects and their boards,
- store tasks and board movement,
- store sub-agent dispatch records,
- store launchable definitions and runs,
- mirror cron jobs and their recent runs,
- store one or more GitHub PAT credentials,
- link repos to projects,
- mirror GitHub issues, pull requests, branches, and commits,
- record append-only activity events.