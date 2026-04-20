import { KanbanBoard } from "@/components/kanban-board";

export default function KanbanPage() {
  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-2xl font-semibold text-white">Kanban</h1>
        <p className="muted">Allocate work to humans and coding sub-agents.</p>
      </div>
      <KanbanBoard />
    </div>
  );
}
