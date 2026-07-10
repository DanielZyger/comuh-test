import { useSyncExternalStore } from "react";
import type { ReactionType } from "./types";

const STORAGE_KEY = "comuh:reacted";
const listeners = new Set<() => void>();

function emitChange() {
  listeners.forEach((listener) => listener());
}

function subscribe(listener: () => void) {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

function getSnapshot() {
  return window.localStorage.getItem(STORAGE_KEY) ?? "[]";
}

function getServerSnapshot() {
  return "[]";
}

function key(messageId: number, reactionType: ReactionType) {
  return `${messageId}:${reactionType}`;
}

export function markReacted(messageId: number, reactionType: ReactionType) {
  const current = new Set(JSON.parse(getSnapshot()) as string[]);
  current.add(key(messageId, reactionType));
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify([...current]));
  emitChange();
}

export function unmarkReacted(messageId: number, reactionType: ReactionType) {
  const current = new Set(JSON.parse(getSnapshot()) as string[]);
  current.delete(key(messageId, reactionType));
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify([...current]));
  emitChange();
}

export function useReactedTypes(messageId: number): Set<ReactionType> {
  const raw = useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot);
  const prefix = `${messageId}:`;

  return new Set(
    (JSON.parse(raw) as string[])
      .filter((entry) => entry.startsWith(prefix))
      .map((entry) => entry.slice(prefix.length) as ReactionType),
  );
}
