# /component

Scaffold a UI component using the design system. Never raw values, always tokens.

## Usage
```
/component UserCard
/component PaymentForm --variant modal
/component NotificationBanner --type alert
```

## What gets generated

```
platforms/design-system/components/<ComponentName>/
├── <ComponentName>.tsx         ← component using tokens throughout
├── <ComponentName>.test.tsx    ← RTL tests: render, interaction, a11y
├── <ComponentName>.stories.tsx ← Storybook story with all variants
└── index.ts                    ← clean re-export
```

## Prompt sent to Claude
Read `.claude/rules/design-system.md` and `.claude/rules/testing.md` before generating.
Check `platforms/design-system/components/` — if a similar component already exists, extend it rather than creating a new one.

Scaffold a component named: $ARGUMENTS

Apply all rules:
- Only design system tokens — zero raw hex, px, or font-size values
- RTL tests: render test, interaction test, axe accessibility test
- Storybook story showing default + any variants
- Accessible markup (aria labels, roles where needed)
- TypeScript props interface, no `any`

Write a log to `artifacts/component-<name>-YYYY-MM-DD.md`.
