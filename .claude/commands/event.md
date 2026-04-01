# /event

Define a new event on the data platform event bus. Creates schema, publisher helper, and consumer stub.

## Usage
```
/event user.profile.updated
/event payment.invoice.created
/event order.item.shipped
```

## What gets generated

```
platforms/data-platform/events/<domain>.<entity>.<verb>/
├── schema.ts        ← Zod schema (the contract — do not change without a PRD)
├── publisher.ts     ← typed helper: publishUserProfileUpdated(payload)
├── consumer.ts      ← stub EventBridge rule + Lambda handler
└── schema.test.ts   ← validates example payloads against schema
```

## Prompt sent to Claude
Read `.claude/rules/naming.md`, `architecture/system-map.md`.
Check `platforms/data-platform/events/` for existing events in the same domain.

Create event: $ARGUMENTS

Rules:
- Event name must match pattern `<domain>.<entity>.<verb-past-tense>`
- Schema must include: `eventId`, `timestamp`, `version`, `payload`
- Schema is a contract — add a comment: "BREAKING CHANGE requires a PRD"
- Publisher is typed — no `any`, no raw EventBridge client usage in callers
- Update `architecture/system-map.md` event flow diagram if this is a new event type
