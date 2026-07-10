import { useSyncExternalStore } from "react";
import type { Session } from "./types";

const STORAGE_KEY = "comuh:session";
const listeners = new Set<() => void>();

function emitChange() {
  listeners.forEach((listener) => listener());
}

function subscribe(listener: () => void) {
  listeners.add(listener);
  window.addEventListener("storage", listener);
  return () => {
    listeners.delete(listener);
    window.removeEventListener("storage", listener);
  };
}

function getSnapshot() {
  return window.localStorage.getItem(STORAGE_KEY);
}

function getServerSnapshot() {
  return null;
}

export function saveSession(session: Session) {
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(session));
  emitChange();
}

export function clearSession() {
  window.localStorage.removeItem(STORAGE_KEY);
  emitChange();
}

export function useSessionToken() {
  return useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot);
}
