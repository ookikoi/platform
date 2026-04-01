// Design System Tokens — source of truth
// Rule: .claude/rules/design-system.md — always use tokens, never raw values

export const tokens = {
  color: {
    primary:  "#0f3460",
    error:    "#e94560",
    success:  "#4ecca3",
    warning:  "#f0a500",
    surface:  "#16213e",
    text:     "#eeeeee",
    textMuted:"#aaaaaa",
    border:   "#0f3460",
  },
  space: {
    1: "4px",
    2: "8px",
    3: "12px",
    4: "16px",
    6: "24px",
    8: "32px",
    12: "48px",
  },
  text: {
    sm:   "14px",
    base: "16px",
    lg:   "18px",
    h4:   "20px",
    h3:   "24px",
    h2:   "30px",
    h1:   "36px",
  },
  radius: {
    sm: "4px",
    md: "8px",
    lg: "16px",
    full: "9999px",
  },
} as const;
