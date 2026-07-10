"use client";

import { useCallback, useState } from "react";
import { createMessage } from "@/lib/api";
import type { MessageDetail } from "@/lib/types";

async function getClientIp(): Promise<string> {
  const response = await fetch("/api/client-ip");
  const data = await response.json();
  return data.ip as string;
}

interface SubmitPayload {
  username: string;
  communityId: number;
  content: string;
  parentMessageId?: number;
}

export function useCreateMessage() {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const submit = useCallback(async (payload: SubmitPayload): Promise<MessageDetail | null> => {
    setIsSubmitting(true);
    setError(null);

    try {
      const userIp = await getClientIp();

      return await createMessage({
        username: payload.username,
        community_id: payload.communityId,
        content: payload.content,
        user_ip: userIp,
        parent_message_id: payload.parentMessageId,
      });
    } catch {
      setError("Não foi possível enviar a mensagem. Tente novamente.");
      return null;
    } finally {
      setIsSubmitting(false);
    }
  }, []);

  return { submit, isSubmitting, error };
}
