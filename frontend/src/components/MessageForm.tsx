"use client";

import { useEffect, useRef, useState, type FormEvent } from "react";
import { useCreateMessage } from "@/hooks/useCreateMessage";
import type { MessageDetail } from "@/lib/types";
import { useSession } from "./SessionProvider";

export function MessageForm({
  communityId,
  parentMessageId,
  onCreated,
}: {
  communityId: number;
  parentMessageId?: number;
  onCreated: (message: MessageDetail) => void;
}) {
  const { session } = useSession();
  const usernameRef = useRef<HTMLInputElement>(null);
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const [content, setContent] = useState("");
  const { submit, isSubmitting, error } = useCreateMessage();

  // Sincroniza a altura do textarea (DOM) com o conteúdo digitado: cresce
  // conforme o texto, e volta ao mínimo assim que o form é limpo no envio.
  useEffect(() => {
    const textarea = textareaRef.current;
    if (!textarea) return;

    textarea.style.height = "auto";
    textarea.style.height = `${textarea.scrollHeight}px`;
  }, [content]);

  async function handleSubmit(event: FormEvent) {
    event.preventDefault();

    const username = session?.user.username ?? usernameRef.current?.value.trim() ?? "";
    const message = await submit({ username, communityId, content, parentMessageId });
    if (message) {
      onCreated(message);
      setContent("");
    }
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-2 rounded-lg border border-gray-200 p-4 dark:border-gray-700">
      {session ? (
        <p className="text-xs text-gray-500 dark:text-gray-400">
          Postando como <strong>{session.user.username}</strong>
        </p>
      ) : (
        <input
          ref={usernameRef}
          type="text"
          placeholder="Seu username"
          required
          className="rounded border border-gray-300 px-3 py-2 text-sm dark:border-gray-600 dark:bg-transparent"
        />
      )}
      <textarea
        ref={textareaRef}
        placeholder={parentMessageId ? "Escreva um comentário..." : "O que você quer compartilhar?"}
        value={content}
        onChange={(event) => setContent(event.target.value)}
        required
        rows={1}
        className="resize-none overflow-hidden rounded border border-gray-300 px-3 py-2 text-sm dark:border-gray-600 dark:bg-transparent"
      />
      <button
        type="submit"
        disabled={isSubmitting}
        className="self-start rounded bg-accent px-4 py-2 text-sm font-medium text-accent-foreground hover:brightness-95 disabled:opacity-50"
      >
        {isSubmitting ? "Enviando..." : "Enviar"}
      </button>
      {error && <p className="text-xs text-red-600">{error}</p>}
    </form>
  );
}
