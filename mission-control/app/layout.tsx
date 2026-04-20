import "./globals.css";
import type { Metadata } from "next";
import { Sidebar } from "@/components/sidebar";
import { Topbar } from "@/components/topbar";

export const metadata: Metadata = {
  title: "Mission Control",
  description: "Operator dashboard for projects, sub-agents, launches, cron, and GitHub-linked delivery.",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>
        <div className="flex min-h-screen bg-mission-bg">
          <Sidebar />
          <main className="flex-1">
            <Topbar />
            <div className="container-shell">{children}</div>
          </main>
        </div>
      </body>
    </html>
  );
}
