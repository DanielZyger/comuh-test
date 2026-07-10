import type {
  Community,
  CommunityDetail,
  MessageDetail,
  MessageSummary,
  ReactionType,
  Session,
} from "./types";

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:3000";

export class ApiError extends Error {
  status: number;
  body: unknown;

  constructor(status: number, body: unknown) {
    super(`Erro na API (status ${status})`);
    this.status = status;
    this.body = body;
  }
}

interface ApiFetchOptions extends RequestInit {
  token?: string | null;
}

async function apiFetch<T>(path: string, options: ApiFetchOptions = {}): Promise<T> {
  const { token, headers, ...rest } = options;

  const response = await fetch(`${API_URL}${path}`, {
    ...rest,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...headers,
    },
    cache: "no-store",
  });

  const body = await response.json().catch(() => null);

  if (!response.ok) {
    throw new ApiError(response.status, body);
  }

  return body as T;
}

export function getCommunities() {
  return apiFetch<{ communities: Community[] }>("/api/v1/communities");
}

export function getCommunity(id: number | string) {
  return apiFetch<{ community: CommunityDetail; messages: MessageSummary[] }>(
    `/api/v1/communities/${id}`,
  );
}

export function getMessage(id: number | string) {
  return apiFetch<{ message: MessageSummary; replies: MessageSummary[] }>(
    `/api/v1/messages/${id}`,
  );
}

export function createMessage(payload: {
  username: string;
  community_id: number;
  content: string;
  user_ip: string;
  parent_message_id?: number;
}) {
  return apiFetch<MessageDetail>("/api/v1/messages", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function createReaction(
  payload: { message_id: number; reaction_type: ReactionType },
  token: string,
) {
  return apiFetch<{ message_id: number; reactions: Record<ReactionType, number> }>(
    "/api/v1/reactions",
    { method: "POST", body: JSON.stringify(payload), token },
  );
}

export function deleteReaction(
  payload: { message_id: number; reaction_type: ReactionType },
  token: string,
) {
  const query = new URLSearchParams({
    message_id: String(payload.message_id),
    reaction_type: payload.reaction_type,
  });

  return apiFetch<{ message_id: number; reactions: Record<ReactionType, number> }>(
    `/api/v1/reactions?${query}`,
    { method: "DELETE", token },
  );
}

export function createSession(username: string) {
  return apiFetch<Session>("/api/v1/sessions", {
    method: "POST",
    body: JSON.stringify({ username }),
  });
}
