"use client";

import { useState } from "react";
import { useSession } from "./SessionProvider";

export function SessionBar() {
  const { session, error, login, logout } = useSession();
  const [username, setUsername] = useState("");

  if (session) {
    return (
      <div className="flex items-center gap-3 text-sm">
        <span>
          Logado como <strong>{session.user.username}</strong>
        </span>
        <button type="button" onClick={logout} className="text-gray-600 hover:underline dark:text-gray-300">
          Sair
        </button>
      </div>
    );
  }

  return (
    <form
      onSubmit={(event) => {
        event.preventDefault();
        if (username.trim()) login(username.trim());
      }}
      className="flex items-center gap-2 text-sm"
    >
      <input
        type="text"
        placeholder="Seu username"
        value={username}
        onChange={(event) => setUsername(event.target.value)}
        className="rounded border border-gray-300 px-2 py-1 dark:border-gray-600 dark:bg-transparent"
      />
      <button type="submit" className="rounded bg-accent px-3 py-1 font-medium text-accent-foreground hover:brightness-95">
        Entrar
      </button>
      {error && <span className="text-red-600">{error}</span>}
    </form>
  );
}
