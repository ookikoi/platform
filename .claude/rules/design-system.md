# Rule: Design System Usage

## Tokens — always use tokens, never raw values

```tsx
// WRONG
<div style={{ color: '#e94560', padding: '16px', fontSize: '14px' }} />

// RIGHT
<div style={{ color: tokens.color.error, padding: tokens.space[4], fontSize: tokens.text.sm }} />
```

Token files live in `platforms/design-system/tokens/`.

## Components — use the design system first

Before building a new component, check `platforms/design-system/components/`.
If a component exists there, use it. Do not rebuild it.

If you need a variant that doesn't exist:
1. Check if a prop can extend the existing component
2. If not, raise it with the design system team — do NOT create a one-off local version

## Spacing scale
| Token | Value |
|---|---|
| `tokens.space[1]` | 4px |
| `tokens.space[2]` | 8px |
| `tokens.space[3]` | 12px |
| `tokens.space[4]` | 16px |
| `tokens.space[6]` | 24px |
| `tokens.space[8]` | 32px |

## Typography
- Body: `tokens.text.base` (16px)
- Small: `tokens.text.sm` (14px)
- Heading levels: `tokens.text.h1` through `tokens.text.h4`
- Never use `font-size` directly in components

## Colour roles (not hex values)
| Role | Token |
|---|---|
| Primary action | `tokens.color.primary` |
| Destructive / error | `tokens.color.error` |
| Success | `tokens.color.success` |
| Warning | `tokens.color.warning` |
| Surface background | `tokens.color.surface` |
| Text primary | `tokens.color.text` |

## Accessibility
- All interactive elements must have an accessible label
- Colour contrast must meet WCAG AA (4.5:1 for text)
- Never rely on colour alone to convey meaning
