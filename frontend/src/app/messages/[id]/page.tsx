import { notFound } from "next/navigation";
import { ApiError, getMessage } from "@/lib/api";
import { MessageThread } from "./MessageThread";

export default async function MessagePage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  let data;
  try {
    data = await getMessage(id);
  } catch (error) {
    if (error instanceof ApiError && error.status === 404) notFound();
    throw error;
  }

  return <MessageThread message={data.message} initialReplies={data.replies} />;
}
