import Link from "next/link";

interface Crumb {
  label: string;
  href?: string;
}

export function Breadcrumbs({ items }: { items: Crumb[] }) {
  return (
    <nav aria-label="Breadcrumb" className="flex flex-wrap items-center gap-1.5 text-sm text-gray-500 dark:text-gray-400">
      {items.map((item, index) => (
        <span key={item.label} className="flex items-center gap-1.5">
          {index > 0 && <span aria-hidden>/</span>}
          {item.href ? (
            <Link href={item.href} className="hover:underline hover:decoration-accent">
              {item.label}
            </Link>
          ) : (
            <span className="text-gray-700 dark:text-gray-300">{item.label}</span>
          )}
        </span>
      ))}
    </nav>
  );
}
