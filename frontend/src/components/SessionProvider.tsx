"use client";

import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from "react";
import { createSession } from "@/lib/api";
import { clearSession, saveSession, useSessionToken } from "@/lib/session-store";
import type { Session } from "@/lib/types";

interface SessionContextValue {
  session: Session | null;
  error: string | null;
  login: (username: string) => Promise<void>;
  logout: () => void;
}

const SessionContext = createContext<SessionContextValue | null>(null);

export function SessionProvider({ children }: { children: ReactNode }) {
  const rawToken = useSessionToken();
  const [error, setError] = useState<string | null>(null);

  const session = useMemo<Session | null>(() => {
    if (!rawToken) return null;

    try {
      return JSON.parse(rawToken) as Session;
    } catch {
      return null;
    }
  }, [rawToken]);

  const login = useCallback(async (username: string) => {
    setError(null);

    try {
      const newSession = await createSession(username);
      saveSession(newSession);
    } catch {
      setError("Não foi possível entrar. Tente novamente.");
    }
  }, []);

  const logout = useCallback(() => {
    clearSession();
  }, []);

  return (
    <SessionContext.Provider value={{ session, error, login, logout }}>{children}</SessionContext.Provider>
  );
}

export function useSession() {
  const context = useContext(SessionContext);
  if (!context) throw new Error("useSession must be used within a SessionProvider");
  return context;
}
