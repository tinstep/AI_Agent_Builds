"use server";

import { revalidatePath } from "next/cache";
import { upsertGitHubCredential } from "@/lib/server/github";

export interface GitHubPatState {
  success: boolean;
  message: string;
}

export async function saveGitHubPat(
  _prevState: GitHubPatState,
  formData: FormData,
): Promise<GitHubPatState> {
  const token = String(formData.get("token") ?? "").trim();

  if (!token) {
    return {
      success: false,
      message: "Please paste a GitHub personal access token.",
    };
  }

  try {
    const result = await upsertGitHubCredential(token);
    revalidatePath("/settings");
    revalidatePath("/");

    return {
      success: true,
      message: `Connected GitHub account ${result.viewer.login} and stored the PAT securely server-side.`,
    };
  } catch (error) {
    return {
      success: false,
      message: error instanceof Error ? error.message : "Failed to validate GitHub token.",
    };
  }
}
