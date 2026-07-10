"use client";

import { useState } from "react";
import { Breadcrumbs } from "@/components/Breadcrumbs";
import { MessageCard } from "@/components/MessageCard";
import { MessageForm } from "@/components/MessageForm";
import type { CommunityDetail, MessageDetail, MessageSummary } from "@/lib/types";

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

export function CommunityTimeline({
  community,
  initialMessages,
}: {
  community: CommunityDetail;
  initialMessages: MessageSummary[];
}) {
  const [messages, setMessages] = useState(initialMessages);

  function handleCreated(message: MessageDetail) {
    setMessages((current) => [toSummary(message), ...current]);
  }

  return (
    <div className="flex flex-col gap-6">
      <Breadcrumbs items={[{ label: "Início", href: "/" }, { label: community.name }]} />

      <div>
        <h1 className="text-2xl font-bold">{community.name}</h1>
        {community.description && (
          <p className="mt-1 text-sm text-gray-600 dark:text-gray-400">{community.description}</p>
        )}
      </div>

      <MessageForm communityId={community.id} onCreated={handleCreated} />

      {messages.length === 0 ? (
        <p className="text-sm text-gray-500">Nenhuma mensagem por aqui ainda. Seja o primeiro a postar!</p>
      ) : (
        <div className="flex flex-col gap-4">
          {messages.map((message) => (
            <MessageCard key={message.id} message={message} />
          ))}
        </div>
      )}
    </div>
  );
}
