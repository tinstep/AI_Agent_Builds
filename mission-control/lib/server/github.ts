import { decryptSecret, encryptSecret } from "@/lib/server/crypto";
import { prisma } from "@/lib/server/prisma";

const GITHUB_API_URL = "https://api.github.com";

export interface GitHubViewer {
  id: number;
  login: string;
  name: string | null;
  avatar_url: string;
}

export async function validateGitHubToken(token: string) {
  const response = await fetch(`${GITHUB_API_URL}/user`, {
    headers: {
      Accept: "application/vnd.github+json",
      Authorization: `Bearer ${token}`,
      "X-GitHub-Api-Version": "2022-11-28",
      "User-Agent": "mission-control",
    },
    cache: "no-store",
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`GitHub token validation failed (${response.status}): ${errorText}`);
  }

  const viewer = (await response.json()) as GitHubViewer;
  const scopes = response.headers.get("x-oauth-scopes")?.split(",").map((scope) => scope.trim()).filter(Boolean) ?? [];

  return { viewer, scopes };
}

export async function upsertGitHubCredential(token: string) {
  const { viewer, scopes } = await validateGitHubToken(token);

  const encryptedToken = encryptSecret(token);
  const tokenHint = `${token.slice(0, 8)}…${token.slice(-4)}`;

  const credential = await prisma.gitHubCredential.upsert({
    where: { name: "default" },
    update: {
      encryptedToken,
      tokenHint,
      username: viewer.login,
      externalUserId: String(viewer.id),
      status: "VALID",
      lastValidatedAt: new Date(),
      lastError: null,
    },
    create: {
      name: "default",
      encryptedToken,
      tokenHint,
      username: viewer.login,
      externalUserId: String(viewer.id),
      status: "VALID",
      lastValidatedAt: new Date(),
    },
  });

  return { credential, viewer, scopes };
}

export async function getStoredGitHubCredential() {
  return prisma.gitHubCredential.findFirst({
    orderBy: { createdAt: "asc" },
  });
}

export async function getStoredGitHubViewer() {
  const credential = await getStoredGitHubCredential();

  if (!credential) {
    return null;
  }

  const token = decryptSecret(credential.encryptedToken);
  const { viewer, scopes } = await validateGitHubToken(token);

  await prisma.gitHubCredential.update({
    where: { id: credential.id },
    data: {
      username: viewer.login,
      externalUserId: String(viewer.id),
      status: "VALID",
      lastValidatedAt: new Date(),
      lastError: null,
    },
  });

  return {
    credential,
    viewer,
    scopes,
  };
}
