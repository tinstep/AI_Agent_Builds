import { NextResponse } from "next/server";
import { validateGitHubToken } from "@/lib/server/github";

export async function POST(request: Request) {
  try {
    const body = (await request.json()) as { token?: string };
    const token = body.token?.trim();

    if (!token) {
      return NextResponse.json({ ok: false, error: "Missing token" }, { status: 400 });
    }

    const result = await validateGitHubToken(token);

    return NextResponse.json({
      ok: true,
      viewer: result.viewer,
      scopes: result.scopes,
    });
  } catch (error) {
    return NextResponse.json(
      {
        ok: false,
        error: error instanceof Error ? error.message : "GitHub validation failed",
      },
      { status: 400 },
    );
  }
}
