# /onboard

Generate a personalised onboarding guide for a new team member.

## Usage
```
/onboard "Sarah — senior frontend engineer, strong React, new to AWS"
/onboard "Miguel — backend engineer, knows Node, new to the company"
```

## What gets generated
`artifacts/onboarding-<name>-YYYY-MM-DD.md` containing:

1. **Your lane** — which platforms and files are most relevant to their role
2. **Architecture tour** — annotated walk through `architecture/system-map.md`
3. **First tasks** — 3 suggested starter tasks calibrated to their experience
4. **Commands to learn first** — the 3 slash commands most relevant to their role
5. **Rules to read** — the specific `.claude/rules/` files for their domain
6. **How to ask for help** — how to use Claude Code effectively in this codebase

## Prompt sent to Claude
Read `architecture/system-map.md`, `CLAUDE.md`, all `.claude/rules/` files,
and the full `.claude/commands/` list.

Generate a personalised onboarding guide for: $ARGUMENTS

Tailor the content to their stated background:
- Don't explain things they already know
- Highlight the gaps between what they know and how we do things here
- Be specific — reference actual file paths, actual command names, actual rule files
- Keep it under 2 pages — dense and useful, not a wall of text
