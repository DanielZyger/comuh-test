export type ReactionType = "like" | "love" | "insightful";

export const REACTION_TYPES: ReactionType[] = ["like", "love", "insightful"];

export interface User {
  id: number;
  username: string;
}

export interface Community {
  id: number;
  name: string;
  description: string | null;
  message_count: number;
}

export interface CommunityDetail {
  id: number;
  name: string;
  description: string | null;
}

export interface MessageSummary {
  id: number;
  content: string;
  user: User;
  community_id: number;
  ai_sentiment_score: number | null;
  reactions: Record<ReactionType, number>;
  reply_count: number;
  created_at: string;
}

export interface MessageDetail {
  id: number;
  content: string;
  user: User;
  community_id: number;
  parent_message_id: number | null;
  ai_sentiment_score: number | null;
  created_at: string;
}

export interface Session {
  token: string;
  user: User;
}
