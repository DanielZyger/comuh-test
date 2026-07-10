"use client";

import { useState } from "react";
import { useReaction } from "@/hooks/useReaction";
import { useReactedTypes } from "@/lib/reacted-store";
import { REACTION_TYPES, type ReactionType } from "@/lib/types";
import { useSession } from "./SessionProvider";

const LABELS: Record<ReactionType, string> = {
  like: "👍 Gostei",
  love: "❤️ Amei",
  insightful: "💡 Brilhante",
};

export function ReactionButtons({
  messageId,
  initialCounts,
}: {
  messageId: number;
  initialCounts: Record<ReactionType, number>;
}) {
  const { session } = useSession();
  const [counts, setCounts] = useState(initialCounts);
  const reactedTypes = useReactedTypes(messageId);
  const { react, unreact, pendingType, error } = useReaction(session?.token ?? null);

  async function handleClick(type: ReactionType) {
    const alreadyReacted = reactedTypes.has(type);
    const result = alreadyReacted ? await unreact(messageId, type) : await react(messageId, type);
    if (result) setCounts(result.reactions);
  }

  return (
    <div className="flex flex-col gap-1">
      <div className="flex flex-wrap gap-2">
        {REACTION_TYPES.map((type) => {
          const active = reactedTypes.has(type);

          return (
            <button
              key={type}
              type="button"
              onClick={() => handleClick(type)}
              disabled={pendingType === type}
              title={
                !session
                  ? "Entre com um username para reagir"
                  : active
                    ? "Clique para remover sua reação"
                    : undefined
              }
              className={`rounded-full border px-3 py-1 text-sm transition-colors disabled:cursor-not-allowed ${
                active
                  ? "border-accent bg-accent text-accent-foreground"
                  : "border-gray-300 text-gray-700 hover:bg-gray-100 dark:border-gray-600 dark:text-gray-300 dark:hover:bg-gray-800"
              }`}
            >
              {LABELS[type]} · {counts[type]}
            </button>
          );
        })}
      </div>
      {error && <p className="text-xs text-red-600">{error}</p>}
    </div>
  );
}
