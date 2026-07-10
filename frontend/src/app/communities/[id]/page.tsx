import { notFound } from "next/navigation";
import { ApiError, getCommunity } from "@/lib/api";
import { CommunityTimeline } from "./CommunityTimeline";

export default async function CommunityPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  let data;
  try {
    data = await getCommunity(id);
  } catch (error) {
    if (error instanceof ApiError && error.status === 404) notFound();
    throw error;
  }

  return <CommunityTimeline community={data.community} initialMessages={data.messages} />;
}
