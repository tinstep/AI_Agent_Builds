import Link from "next/link";
import { Activity, CalendarClock, FolderKanban, Github, Home, PlaySquare, Settings2 } from "lucide-react";

const items = [
  { href: "/", label: "Overview", icon: Home },
  { href: "/projects", label: "Projects", icon: FolderKanban },
  { href: "/kanban", label: "Kanban", icon: Activity },
  { href: "/launchpad", label: "Launch Pad", icon: PlaySquare },
  { href: "/cron", label: "Cron", icon: CalendarClock },
  { href: "/settings", label: "Settings", icon: Settings2 },
];

export function Sidebar() {
  return (
    <aside className="panel h-full min-h-screen w-72 rounded-none border-y-0 border-l-0 border-r border-white/10 bg-slate-950/80">
      <div className="border-b border-white/10 px-5 py-5">
        <div className="text-xs uppercase tracking-[0.28em] text-cyan-300">Mission Control</div>
        <div className="mt-2 text-2xl font-semibold text-white">Operator Console</div>
        <div className="mt-2 flex items-center gap-2 text-sm text-slate-400">
          <Github className="h-4 w-4" /> GitHub PAT linked
        </div>
      </div>
      <nav className="space-y-2 p-4">
        {items.map(({ href, label, icon: Icon }) => (
          <Link
            key={href}
            href={href}
            className="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm text-slate-300 transition hover:bg-white/5 hover:text-white"
          >
            <Icon className="h-4 w-4" />
            {label}
          </Link>
        ))}
      </nav>
    </aside>
  );
}
