import Link from "next/link";
import { getCommunities } from "@/lib/api";

export default async function HomePage() {
  const { communities } = await getCommunities();

  return (
    <div className="flex flex-col gap-6">
      <h1 className="text-2xl font-bold">Comunidades</h1>

      {communities.length === 0 ? (
        <p className="text-sm text-gray-500">Nenhuma comunidade cadastrada ainda.</p>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2">
          {communities.map((community) => (
            <Link
              key={community.id}
              href={`/communities/${community.id}`}
              className="flex flex-col gap-2 rounded-lg border border-gray-200 p-4 transition-colors hover:border-accent dark:border-gray-700"
            >
              <h2 className="font-semibold">{community.name}</h2>
              {community.description && (
                <p className="text-sm text-gray-600 dark:text-gray-400">{community.description}</p>
              )}
              <span className="text-xs text-gray-500">
                {community.message_count} {community.message_count === 1 ? "mensagem" : "mensagens"}
              </span>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
