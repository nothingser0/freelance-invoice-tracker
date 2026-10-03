import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        // Primary brand color (from DESIGN.md)
        primary: {
          DEFAULT: "#0891B2", // cyan-600
          hover: "#0E7490", // cyan-700
        },
      },
      fontFamily: {
        // UI font: Inter (from DESIGN.md)
        sans: ["var(--font-geist-sans)", "system-ui", "sans-serif"],
        // Monospace for numbers: JetBrains Mono
        mono: ["var(--font-geist-mono)", "monospace"],
      },
      boxShadow: {
        // Custom shadows (from DESIGN.md - max shadow-sm)
        sm: "0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px -1px rgba(0, 0, 0, 0.1)",
      },
      borderRadius: {
        // Custom radius values (from DESIGN.md)
        DEFAULT: "6px", // buttons
        lg: "8px", // cards
        full: "9999px", // badges
      },
    },
  },
  plugins: [],
};

export default config;
