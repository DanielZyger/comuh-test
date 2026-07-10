"use client";

import { useState } from "react";
import { Breadcrumbs } from "@/components/Breadcrumbs";
import { MessageCard } from "@/components/MessageCard";
import { MessageForm } from "@/components/MessageForm";
import type { MessageDetail, MessageSummary } from "@/lib/types";

function toSummary(message: MessageDetail): MessageSummary {
  return {
    id: message.id,
    content: message.content,
    user: message.user,
    community_id: message.community_id,
    ai_sentiment_score: message.ai_sentiment_score,
    reactions: { like: 0, love: 0, insightful: 0 },
    reply_count: 0,
    created_at: message.created_at,
  };
}

export function MessageThread({
  message,
  initialReplies,
}: {
  message: MessageSummary;
  initialReplies: MessageSummary[];
}) {
  const [replies, setReplies] = useState(initialReplies);

  function handleCreated(reply: MessageDetail) {
    setReplies((current) => [...current, toSummary(reply)]);
  }

  return (
    <div className="flex flex-col gap-6">
      <Breadcrumbs
        items={[
          { label: "Início", href: "/" },
          { label: "Comunidade", href: `/communities/${message.community_id}` },
          { label: "Mensagem" },
        ]}
      />

      <MessageCard message={message} showThreadLink={false} />

      <MessageForm communityId={message.community_id} parentMessageId={message.id} onCreated={handleCreated} />

      <div className="flex flex-col gap-1">
        <h2 className="text-sm font-semibold text-gray-600 dark:text-gray-400">
          {replies.length === 0
            ? "Nenhum comentário ainda"
            : `${replies.length} ${replies.length === 1 ? "comentário" : "comentários"}`}
        </h2>

        <div className="flex flex-col gap-4 border-l-2 border-gray-200 pl-4 dark:border-gray-700">
          {replies.map((reply) => (
            <MessageCard key={reply.id} message={reply} />
          ))}
        </div>
      </div>
    </div>
  );
}
