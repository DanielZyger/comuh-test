function sentimentLabel(score: number | null) {
  if (score === null) return { emoji: "…", text: "sem análise", classes: "bg-gray-100 text-gray-500" };
  if (score > 0.2) return { emoji: "😊", text: "positivo", classes: "bg-green-100 text-green-700" };
  if (score < -0.2) return { emoji: "😞", text: "negativo", classes: "bg-red-100 text-red-700" };
  return { emoji: "😐", text: "neutro", classes: "bg-gray-100 text-gray-600" };
}

export function SentimentBadge({ score }: { score: number | null }) {
  const { emoji, text, classes } = sentimentLabel(score);

  return (
    <span className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-medium ${classes}`}>
      <span aria-hidden>{emoji}</span>
      {text}
    </span>
  );
}
