# Command: /component

Scaffold a React component using design system tokens. Never raw values—always tokens. Includes tests, stories, and accessibility built-in.

---

## Usage

```
/component <ComponentName> [--variant <name>] [--description "..."]
```

### Parameters

| Parameter | Required | Options | Example |
|-----------|----------|---------|------------|
| `ComponentName` | Yes | PascalCase | `UserCard`, `ReviewBadge` |
| `--variant` | No | Any variant name | `--variant modal`, `--variant compact` |
| `--description` | No | Any string | `"Displays user profile with avatar and bio"` |

---

## What Gets Created

```
platforms/design-system/components/<ComponentName>/
├── <ComponentName>.tsx           ← React component (tokens only, no raw values)
├── <ComponentName>.test.tsx      ← RTL: render, interaction, accessibility
├── <ComponentName>.stories.tsx   ← Storybook story with all variants
├── index.ts                      ← Clean re-export
└── types.ts                      ← TypeScript props interface
```

---

## Quick Examples

```bash
# User profile card
/component UserCard --variant compact --description "Display user with avatar and bio"

# Product rating display
/component RatingBadge --description "Show product rating with sentiment colors"

# Review submission form
/component ReviewForm --variant modal --description "Modal form for product reviews"
```

---

## Token Usage Rules

**NEVER do this:**
```typescript
// ❌ Raw hex, px, font-size
style={{ color: "#e94560", padding: "16px", fontSize: "14px" }}
```

**ALWAYS do this:**
```typescript
// ✅ Use design system tokens
style={{
  color: tokens.color.error,
  padding: tokens.space[4],
  fontSize: tokens.text.sm,
}}
```

---

## Testing Requirements

Each component needs:
- **Render test** — Component displays correctly with props
- **Interaction test** — User actions (click, keyboard) work as expected
- **Accessibility test** — axe-core scan finds no violations
- **Variant test** — Different prop combinations render correctly

**Coverage floor:** 80% for design system components

---

## Accessibility Checklist

- [ ] Semantic HTML (button, input, etc., not just divs)
- [ ] Keyboard accessible (Enter, Space, Arrow keys)
- [ ] Color contrast meets WCAG AA (tokens enforce this)
- [ ] Images have alt text
- [ ] Form labels associated with inputs
- [ ] ARIA labels for interactive elements
- [ ] Tests include axe accessibility scanning

---

## Next Steps

1. **Edit `<ComponentName>.tsx`** — Add component logic and styling with tokens only
2. **Edit `<ComponentName>.test.tsx`** — Write tests (80%+ coverage)
3. **Edit `<ComponentName>.stories.tsx`** — Add variant combinations
4. **Run Storybook:** `npm run storybook` — See component in isolation
5. **Run tests:** `npm test` — Verify render, interaction, accessibility
6. **Use in a feature** — Import from design system, never copy-paste

---

## See Also

- [Design System Rules](../rules/design-system.md) — Tokens, color roles, typography
- [Testing Standards](../rules/testing.md#ui-component-tests) — RTL, axe, coverage requirements
- [Naming Conventions](../rules/naming.md#ui-components) — PascalCase, file structure
- [How to Add a Feature](../../../docs/HOW-TO-ADD-A-FEATURE.md) — Feature workflow
