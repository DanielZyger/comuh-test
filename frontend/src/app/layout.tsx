import type { Metadata } from "next";
import Link from "next/link";
import { Geist, Geist_Mono } from "next/font/google";
import { SessionBar } from "@/components/SessionBar";
import { SessionProvider } from "@/components/SessionProvider";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Comuh",
  description: "Plataforma de gestão de comunidades",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="pt-BR"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
    >
      <body className="flex min-h-full flex-col">
        <SessionProvider>
          <header className="border-b border-gray-200 dark:border-gray-700">
            <div className="mx-auto flex max-w-3xl items-center justify-between gap-4 px-4 py-3">
              <Link href="/" className="text-lg font-bold">
                Comuh
              </Link>
              <SessionBar />
            </div>
          </header>
          <main className="mx-auto w-full max-w-3xl flex-1 px-4 py-6">{children}</main>
        </SessionProvider>
      </body>
    </html>
  );
}
