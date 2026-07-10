"use client";

import { useCallback, useState } from "react";
import { ApiError, createReaction, deleteReaction } from "@/lib/api";
import { markReacted, unmarkReacted } from "@/lib/reacted-store";
import type { ReactionType } from "@/lib/types";

export function useReaction(token: string | null) {
  const [pendingType, setPendingType] = useState<ReactionType | null>(null);
  const [error, setError] = useState<string | null>(null);

  const react = useCallback(
    async (messageId: number, reactionType: ReactionType) => {
      if (!token) {
        setError("Entre com um username para reagir.");
        return null;
      }

      setPendingType(reactionType);
      setError(null);

      try {
        const result = await createReaction({ message_id: messageId, reaction_type: reactionType }, token);
        markReacted(messageId, reactionType);
        return result;
      } catch (err) {
        const isDuplicate = err instanceof ApiError && (err.status === 409 || err.status === 422);

        if (isDuplicate) {
          markReacted(messageId, reactionType);
          setError("Você já reagiu com esse tipo de reação.");
        } else {
          setError("Não foi possível reagir. Tente novamente.");
        }

        return null;
      } finally {
        setPendingType(null);
      }
    },
    [token],
  );

  const unreact = useCallback(
    async (messageId: number, reactionType: ReactionType) => {
      if (!token) {
        setError("Entre com um username para reagir.");
        return null;
      }

      setPendingType(reactionType);
      setError(null);

      try {
        const result = await deleteReaction({ message_id: messageId, reaction_type: reactionType }, token);
        unmarkReacted(messageId, reactionType);
        return result;
      } catch (err) {
        if (err instanceof ApiError && err.status === 404) {
          unmarkReacted(messageId, reactionType);
          return null;
        }

        setError("Não foi possível remover a reação. Tente novamente.");
        return null;
      } finally {
        setPendingType(null);
      }
    },
    [token],
  );

  return { react, unreact, pendingType, error };
}
