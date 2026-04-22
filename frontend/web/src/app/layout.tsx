import type { Metadata } from "next";
import { Plus_Jakarta_Sans } from "next/font/google";
import "./globals.css";

const plusJakarta = Plus_Jakarta_Sans({
  subsets: ["latin"],
  variable: "--font-sans",
  display: "swap",
});

export const metadata: Metadata = {
  title: "DeepFract — Neural Fractal Compression",
  description:
    "AI-powered image compression using learned latent fractal transforms. Achieve 100:1+ compression ratios with neural synthesis reconstruction.",
  keywords: ["image compression", "neural network", "fractal", "deep learning", "codec"],
};

import { ThemeProvider } from "@/context/ThemeContext";
import { CompressionProvider } from "@/context/CompressionContext";

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <link rel="icon" href="/logo.png" />
        <script
          dangerouslySetInnerHTML={{
            __html: `
              (function() {
                try {
                  const saved = localStorage.getItem('deepfract-theme');
                  if (saved === 'light') {
                    document.documentElement.classList.add('light-theme');
                    document.documentElement.style.colorScheme = 'light';
                  } else {
                    document.documentElement.classList.remove('light-theme');
                    document.documentElement.style.colorScheme = 'dark';
                  }
                } catch (e) {}
              })()
            `,
          }}
        />
      </head>
      <body className={`${plusJakarta.variable} font-sans antialiased`} suppressHydrationWarning>
        <ThemeProvider>
          <CompressionProvider>
            {children}
          </CompressionProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
