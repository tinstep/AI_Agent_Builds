# Mission Control

Mission Control is a Next.js operator dashboard for managing:
- projects,
- Kanban work allocation,
- coding sub-agents,
- launchable programs,
- cron jobs,
- GitHub-linked delivery using a personal access token.

## Included in this scaffold

- Next.js App Router shell
- dark operator-style dashboard layout
- placeholder pages for Projects, Kanban, Launch Pad, Cron, and Settings
- mock data layer for early UI iteration
- Prisma schema targeting PostgreSQL
- environment example file

## Quick start

```bash
cd mission-control
cp .env.example .env.local
npm install
npm run dev
```

Open `http://localhost:3000`.

## Planned next steps

1. install and migrate PostgreSQL schema
2. replace mock data with Prisma queries
3. add GitHub PAT validation route and encrypted credential storage
4. add OpenClaw adapter services for sub-agent and cron sync
5. implement task CRUD and board drag-and-drop

## Environment variables

- `DATABASE_URL` PostgreSQL connection string
- `APP_ENCRYPTION_KEY` key used to encrypt stored PAT values
- `GITHUB_TOKEN` optional local bootstrap token for development
- `NEXT_PUBLIC_APP_NAME` display name for the UI

## Notes

This scaffold assumes GitHub integration will always use a PAT server-side. The browser should never receive raw GitHub tokens.