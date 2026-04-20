-- CreateEnum
CREATE TYPE "ProjectStatus" AS ENUM ('IDEA', 'PLANNED', 'ACTIVE', 'BLOCKED', 'MAINTENANCE', 'COMPLETED', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "ProjectPriority" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');

-- CreateEnum
CREATE TYPE "TaskStatus" AS ENUM ('BACKLOG', 'READY', 'IN_PROGRESS', 'REVIEW', 'BLOCKED', 'DONE', 'CANCELLED');

-- CreateEnum
CREATE TYPE "AssigneeType" AS ENUM ('HUMAN', 'SUB_AGENT', 'UNASSIGNED');

-- CreateEnum
CREATE TYPE "AgentRunStatus" AS ENUM ('QUEUED', 'STARTING', 'RUNNING', 'WAITING', 'BLOCKED', 'FAILED', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "LaunchSafetyLevel" AS ENUM ('SAFE_READ_ONLY', 'SAFE_INTERNAL_WRITE', 'ELEVATED_INTERNAL_ACTION', 'EXTERNAL_SIDE_EFFECT');

-- CreateEnum
CREATE TYPE "LaunchRunStatus" AS ENUM ('PENDING', 'RUNNING', 'SUCCEEDED', 'FAILED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "CronHealthStatus" AS ENUM ('HEALTHY', 'WARNING', 'FAILING', 'DISABLED', 'UNKNOWN');

-- CreateEnum
CREATE TYPE "GitHubCredentialStatus" AS ENUM ('VALID', 'INVALID', 'EXPIRED', 'REVOKED', 'UNKNOWN');

-- CreateEnum
CREATE TYPE "ActivityObjectType" AS ENUM ('PROJECT', 'BOARD', 'COLUMN', 'TASK', 'AGENT_RUN', 'LAUNCHABLE', 'LAUNCH_RUN', 'CRON_JOB', 'CRON_RUN', 'GITHUB_CREDENTIAL', 'GITHUB_REPO', 'GITHUB_ISSUE', 'GITHUB_PULL_REQUEST', 'SYSTEM');

-- CreateTable
CREATE TABLE "User" (
    "id" UUID NOT NULL,
    "email" TEXT,
    "name" TEXT NOT NULL,
    "role" TEXT NOT NULL DEFAULT 'operator',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Project" (
    "id" UUID NOT NULL,
    "slug" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "status" "ProjectStatus" NOT NULL,
    "priority" "ProjectPriority" NOT NULL,
    "tags" JSONB NOT NULL DEFAULT '[]',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "archivedAt" TIMESTAMP(3),

    CONSTRAINT "Project_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProjectNote" (
    "id" UUID NOT NULL,
    "projectId" UUID NOT NULL,
    "title" TEXT,
    "body" TEXT NOT NULL,
    "createdBy" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ProjectNote_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Board" (
    "id" UUID NOT NULL,
    "projectId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Board_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BoardColumn" (
    "id" UUID NOT NULL,
    "boardId" UUID NOT NULL,
    "key" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "position" INTEGER NOT NULL,
    "color" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BoardColumn_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Task" (
    "id" UUID NOT NULL,
    "projectId" UUID NOT NULL,
    "boardId" UUID NOT NULL,
    "columnId" UUID NOT NULL,
    "parentTaskId" UUID,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "acceptanceCriteria" TEXT,
    "status" "TaskStatus" NOT NULL,
    "priority" "ProjectPriority" NOT NULL,
    "estimatePoints" INTEGER,
    "assigneeType" "AssigneeType" NOT NULL,
    "assigneeLabel" TEXT,
    "githubIssueNumber" INTEGER,
    "githubBranchName" TEXT,
    "githubPullRequestNumber" INTEGER,
    "dueAt" TIMESTAMP(3),
    "sortOrder" DECIMAL(65,30),
    "createdBy" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "Task_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskComment" (
    "id" UUID NOT NULL,
    "taskId" UUID NOT NULL,
    "authorId" UUID,
    "body" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TaskComment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskAttachment" (
    "id" UUID NOT NULL,
    "taskId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "storageType" TEXT NOT NULL,
    "storagePath" TEXT NOT NULL,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TaskAttachment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AgentRun" (
    "id" UUID NOT NULL,
    "taskId" UUID NOT NULL,
    "sessionKey" TEXT NOT NULL,
    "externalRunId" TEXT,
    "status" "AgentRunStatus" NOT NULL,
    "agentLabel" TEXT,
    "dispatchPrompt" TEXT,
    "summary" TEXT,
    "artifacts" JSONB NOT NULL DEFAULT '[]',
    "linkedBranch" TEXT,
    "linkedPullRequestNumber" INTEGER,
    "startedAt" TIMESTAMP(3),
    "lastUpdateAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "failureReason" TEXT,
    "rawPayload" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AgentRun_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Launchable" (
    "id" UUID NOT NULL,
    "projectId" UUID,
    "slug" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "category" TEXT NOT NULL,
    "executionType" TEXT NOT NULL,
    "handler" TEXT NOT NULL,
    "inputSchema" JSONB,
    "defaultInputs" JSONB,
    "environmentRequirements" JSONB,
    "safetyLevel" "LaunchSafetyLevel" NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "tags" JSONB NOT NULL DEFAULT '[]',
    "version" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Launchable_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LaunchRun" (
    "id" UUID NOT NULL,
    "launchableId" UUID NOT NULL,
    "projectId" UUID,
    "taskId" UUID,
    "initiatedBy" UUID,
    "status" "LaunchRunStatus" NOT NULL,
    "inputPayload" JSONB,
    "stdoutSummary" TEXT,
    "stderrSummary" TEXT,
    "logsRef" TEXT,
    "artifacts" JSONB NOT NULL DEFAULT '[]',
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "LaunchRun_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CronJobMirror" (
    "id" UUID NOT NULL,
    "projectId" UUID,
    "externalJobId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "scheduleKind" TEXT NOT NULL,
    "schedulePayload" JSONB NOT NULL,
    "payloadKind" TEXT NOT NULL,
    "payloadSummary" TEXT,
    "deliveryPayload" JSONB,
    "enabled" BOOLEAN NOT NULL,
    "healthStatus" "CronHealthStatus" NOT NULL DEFAULT 'UNKNOWN',
    "lastRunAt" TIMESTAMP(3),
    "nextRunAt" TIMESTAMP(3),
    "lastSyncAt" TIMESTAMP(3),
    "rawPayload" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CronJobMirror_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CronRunMirror" (
    "id" UUID NOT NULL,
    "cronJobId" UUID NOT NULL,
    "externalRunId" TEXT,
    "status" TEXT NOT NULL,
    "summary" TEXT,
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "rawPayload" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CronRunMirror_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GitHubCredential" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "provider" TEXT NOT NULL DEFAULT 'github',
    "authType" TEXT NOT NULL DEFAULT 'pat',
    "encryptedToken" TEXT NOT NULL,
    "tokenHint" TEXT,
    "username" TEXT,
    "externalUserId" TEXT,
    "status" "GitHubCredentialStatus" NOT NULL DEFAULT 'UNKNOWN',
    "lastValidatedAt" TIMESTAMP(3),
    "lastError" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "GitHubCredential_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GitHubRepoLink" (
    "id" UUID NOT NULL,
    "projectId" UUID NOT NULL,
    "credentialId" UUID NOT NULL,
    "owner" TEXT NOT NULL,
    "repo" TEXT NOT NULL,
    "defaultBranch" TEXT,
    "purpose" TEXT,
    "syncEnabled" BOOLEAN NOT NULL DEFAULT true,
    "syncIssues" BOOLEAN NOT NULL DEFAULT true,
    "syncPullRequests" BOOLEAN NOT NULL DEFAULT true,
    "syncCommits" BOOLEAN NOT NULL DEFAULT true,
    "lastSyncAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "GitHubRepoLink_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GitHubIssueMirror" (
    "id" UUID NOT NULL,
    "repoLinkId" UUID NOT NULL,
    "externalNodeId" TEXT,
    "issueNumber" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "state" TEXT NOT NULL,
    "authorLogin" TEXT,
    "assignees" JSONB NOT NULL DEFAULT '[]',
    "labels" JSONB NOT NULL DEFAULT '[]',
    "url" TEXT NOT NULL,
    "bodyExcerpt" TEXT,
    "createdAtGitHub" TIMESTAMP(3),
    "updatedAtGitHub" TIMESTAMP(3),
    "lastSyncAt" TIMESTAMP(3),
    "rawPayload" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "GitHubIssueMirror_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GitHubPullRequestMirror" (
    "id" UUID NOT NULL,
    "repoLinkId" UUID NOT NULL,
    "externalNodeId" TEXT,
    "pullRequestNumber" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "state" TEXT NOT NULL,
    "authorLogin" TEXT,
    "headBranch" TEXT,
    "baseBranch" TEXT,
    "url" TEXT NOT NULL,
    "draft" BOOLEAN NOT NULL DEFAULT false,
    "mergeableState" TEXT,
    "createdAtGitHub" TIMESTAMP(3),
    "updatedAtGitHub" TIMESTAMP(3),
    "lastSyncAt" TIMESTAMP(3),
    "rawPayload" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "GitHubPullRequestMirror_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GitHubBranchMirror" (
    "id" UUID NOT NULL,
    "repoLinkId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "sha" TEXT,
    "protected" BOOLEAN NOT NULL DEFAULT false,
    "lastCommitAt" TIMESTAMP(3),
    "lastSyncAt" TIMESTAMP(3),
    "rawPayload" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "GitHubBranchMirror_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GitHubCommitMirror" (
    "id" UUID NOT NULL,
    "repoLinkId" UUID NOT NULL,
    "sha" TEXT NOT NULL,
    "authorName" TEXT,
    "authorLogin" TEXT,
    "message" TEXT NOT NULL,
    "committedAt" TIMESTAMP(3),
    "url" TEXT,
    "lastSyncAt" TIMESTAMP(3),
    "rawPayload" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "GitHubCommitMirror_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ActivityEvent" (
    "id" UUID NOT NULL,
    "actorId" UUID,
    "actionType" TEXT NOT NULL,
    "objectType" "ActivityObjectType" NOT NULL,
    "objectId" TEXT NOT NULL,
    "projectId" UUID,
    "summary" TEXT NOT NULL,
    "metadata" JSONB,
    "occurredAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ActivityEvent_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "Project_slug_key" ON "Project"("slug");

-- CreateIndex
CREATE INDEX "ProjectNote_projectId_idx" ON "ProjectNote"("projectId");

-- CreateIndex
CREATE UNIQUE INDEX "Board_projectId_key" ON "Board"("projectId");

-- CreateIndex
CREATE UNIQUE INDEX "BoardColumn_boardId_key_key" ON "BoardColumn"("boardId", "key");

-- CreateIndex
CREATE UNIQUE INDEX "BoardColumn_boardId_position_key" ON "BoardColumn"("boardId", "position");

-- CreateIndex
CREATE INDEX "Task_projectId_idx" ON "Task"("projectId");

-- CreateIndex
CREATE INDEX "Task_boardId_idx" ON "Task"("boardId");

-- CreateIndex
CREATE INDEX "Task_columnId_idx" ON "Task"("columnId");

-- CreateIndex
CREATE INDEX "Task_status_idx" ON "Task"("status");

-- CreateIndex
CREATE INDEX "Task_dueAt_idx" ON "Task"("dueAt");

-- CreateIndex
CREATE INDEX "AgentRun_taskId_idx" ON "AgentRun"("taskId");

-- CreateIndex
CREATE INDEX "AgentRun_sessionKey_idx" ON "AgentRun"("sessionKey");

-- CreateIndex
CREATE INDEX "AgentRun_status_idx" ON "AgentRun"("status");

-- CreateIndex
CREATE UNIQUE INDEX "Launchable_slug_key" ON "Launchable"("slug");

-- CreateIndex
CREATE INDEX "LaunchRun_launchableId_idx" ON "LaunchRun"("launchableId");

-- CreateIndex
CREATE INDEX "LaunchRun_projectId_idx" ON "LaunchRun"("projectId");

-- CreateIndex
CREATE INDEX "LaunchRun_status_idx" ON "LaunchRun"("status");

-- CreateIndex
CREATE INDEX "LaunchRun_createdAt_idx" ON "LaunchRun"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "CronJobMirror_externalJobId_key" ON "CronJobMirror"("externalJobId");

-- CreateIndex
CREATE INDEX "CronJobMirror_projectId_idx" ON "CronJobMirror"("projectId");

-- CreateIndex
CREATE INDEX "CronJobMirror_enabled_idx" ON "CronJobMirror"("enabled");

-- CreateIndex
CREATE INDEX "CronJobMirror_nextRunAt_idx" ON "CronJobMirror"("nextRunAt");

-- CreateIndex
CREATE INDEX "CronRunMirror_cronJobId_idx" ON "CronRunMirror"("cronJobId");

-- CreateIndex
CREATE INDEX "CronRunMirror_startedAt_idx" ON "CronRunMirror"("startedAt");

-- CreateIndex
CREATE UNIQUE INDEX "GitHubCredential_name_key" ON "GitHubCredential"("name");

-- CreateIndex
CREATE INDEX "GitHubRepoLink_credentialId_idx" ON "GitHubRepoLink"("credentialId");

-- CreateIndex
CREATE INDEX "GitHubRepoLink_projectId_idx" ON "GitHubRepoLink"("projectId");

-- CreateIndex
CREATE UNIQUE INDEX "GitHubRepoLink_projectId_owner_repo_key" ON "GitHubRepoLink"("projectId", "owner", "repo");

-- CreateIndex
CREATE UNIQUE INDEX "GitHubIssueMirror_repoLinkId_issueNumber_key" ON "GitHubIssueMirror"("repoLinkId", "issueNumber");

-- CreateIndex
CREATE UNIQUE INDEX "GitHubPullRequestMirror_repoLinkId_pullRequestNumber_key" ON "GitHubPullRequestMirror"("repoLinkId", "pullRequestNumber");

-- CreateIndex
CREATE UNIQUE INDEX "GitHubBranchMirror_repoLinkId_name_key" ON "GitHubBranchMirror"("repoLinkId", "name");

-- CreateIndex
CREATE UNIQUE INDEX "GitHubCommitMirror_repoLinkId_sha_key" ON "GitHubCommitMirror"("repoLinkId", "sha");

-- CreateIndex
CREATE INDEX "ActivityEvent_projectId_idx" ON "ActivityEvent"("projectId");

-- CreateIndex
CREATE INDEX "ActivityEvent_objectType_idx" ON "ActivityEvent"("objectType");

-- CreateIndex
CREATE INDEX "ActivityEvent_occurredAt_idx" ON "ActivityEvent"("occurredAt" DESC);

-- AddForeignKey
ALTER TABLE "ProjectNote" ADD CONSTRAINT "ProjectNote_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProjectNote" ADD CONSTRAINT "ProjectNote_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Board" ADD CONSTRAINT "Board_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BoardColumn" ADD CONSTRAINT "BoardColumn_boardId_fkey" FOREIGN KEY ("boardId") REFERENCES "Board"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Task" ADD CONSTRAINT "Task_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Task" ADD CONSTRAINT "Task_boardId_fkey" FOREIGN KEY ("boardId") REFERENCES "Board"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Task" ADD CONSTRAINT "Task_columnId_fkey" FOREIGN KEY ("columnId") REFERENCES "BoardColumn"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Task" ADD CONSTRAINT "Task_parentTaskId_fkey" FOREIGN KEY ("parentTaskId") REFERENCES "Task"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Task" ADD CONSTRAINT "Task_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskComment" ADD CONSTRAINT "TaskComment_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES "Task"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskComment" ADD CONSTRAINT "TaskComment_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskAttachment" ADD CONSTRAINT "TaskAttachment_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES "Task"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AgentRun" ADD CONSTRAINT "AgentRun_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES "Task"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Launchable" ADD CONSTRAINT "Launchable_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LaunchRun" ADD CONSTRAINT "LaunchRun_launchableId_fkey" FOREIGN KEY ("launchableId") REFERENCES "Launchable"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LaunchRun" ADD CONSTRAINT "LaunchRun_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LaunchRun" ADD CONSTRAINT "LaunchRun_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES "Task"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LaunchRun" ADD CONSTRAINT "LaunchRun_initiatedBy_fkey" FOREIGN KEY ("initiatedBy") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CronJobMirror" ADD CONSTRAINT "CronJobMirror_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CronRunMirror" ADD CONSTRAINT "CronRunMirror_cronJobId_fkey" FOREIGN KEY ("cronJobId") REFERENCES "CronJobMirror"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GitHubRepoLink" ADD CONSTRAINT "GitHubRepoLink_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GitHubRepoLink" ADD CONSTRAINT "GitHubRepoLink_credentialId_fkey" FOREIGN KEY ("credentialId") REFERENCES "GitHubCredential"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GitHubIssueMirror" ADD CONSTRAINT "GitHubIssueMirror_repoLinkId_fkey" FOREIGN KEY ("repoLinkId") REFERENCES "GitHubRepoLink"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GitHubPullRequestMirror" ADD CONSTRAINT "GitHubPullRequestMirror_repoLinkId_fkey" FOREIGN KEY ("repoLinkId") REFERENCES "GitHubRepoLink"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GitHubBranchMirror" ADD CONSTRAINT "GitHubBranchMirror_repoLinkId_fkey" FOREIGN KEY ("repoLinkId") REFERENCES "GitHubRepoLink"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GitHubCommitMirror" ADD CONSTRAINT "GitHubCommitMirror_repoLinkId_fkey" FOREIGN KEY ("repoLinkId") REFERENCES "GitHubRepoLink"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ActivityEvent" ADD CONSTRAINT "ActivityEvent_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ActivityEvent" ADD CONSTRAINT "ActivityEvent_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE SET NULL ON UPDATE CASCADE;
