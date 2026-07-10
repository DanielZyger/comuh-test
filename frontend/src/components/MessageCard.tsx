import Link from "next/link";
import type { MessageSummary } from "@/lib/types";
import { ReactionButtons } from "./ReactionButtons";
import { SentimentBadge } from "./SentimentBadge";

function formatDate(iso: string) {
  return new Date(iso).toLocaleString("pt-BR", { dateStyle: "short", timeStyle: "short" });
}

export function MessageCard({
  message,
  showThreadLink = true,
}: {
  message: MessageSummary;
  showThreadLink?: boolean;
}) {
  return (
    <article className="flex flex-col gap-3 rounded-lg border border-gray-200 p-4 dark:border-gray-700">
      <div className="flex items-center justify-between gap-2">
        <span className="font-semibold">{message.user.username}</span>
        <SentimentBadge score={message.ai_sentiment_score} />
      </div>

      <p className="whitespace-pre-wrap text-sm text-gray-800 dark:text-gray-200">{message.content}</p>

      <ReactionButtons messageId={message.id} initialCounts={message.reactions} />

      <div className="flex items-center justify-between text-xs text-gray-500 dark:text-gray-400">
        {showThreadLink ? (
          <Link href={`/messages/${message.id}`} className="hover:underline">
            {message.reply_count} {message.reply_count === 1 ? "comentário" : "comentários"}
          </Link>
        ) : (
          <span>
            {message.reply_count} {message.reply_count === 1 ? "comentário" : "comentários"}
          </span>
        )}
        <time dateTime={message.created_at}>{formatDate(message.created_at)}</time>
      </div>
    </article>
  );
}
