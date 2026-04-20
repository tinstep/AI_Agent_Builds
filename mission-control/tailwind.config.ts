import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
    "./lib/**/*.{ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        mission: {
          bg: "#07111f",
          panel: "#0f172a",
          line: "rgba(255,255,255,0.08)",
          cyan: "#22d3ee",
          lime: "#84cc16",
          amber: "#f59e0b",
          rose: "#fb7185",
        },
      },
    },
  },
  plugins: [],
};

export default config;
