# Command: /event

Define a new event on the data platform event bus. Creates Zod schema (the contract), typed publisher, consumer stub, and tests. Hands-on control over event-driven communication between services.

---

## Usage

```
/event <domain>.<entity>.<verb-past-tense>
```

### Pattern

```
<domain>       = business domain (user, product, payment, order)
<entity>       = what changed (profile, review, invoice, item)
<verb-tense>   = what happened (created, updated, deleted, shipped, paid)

Examples:
  user.profile.updated
  product.review.created
  payment.invoice.paid
  order.item.shipped
```

---

## What Gets Created

```
platforms/data-platform/events/<domain>.<entity>.<verb>/
├── schema.ts           ← Zod schema (the contract — breaking changes need PRD)
├── publisher.ts        ← Typed helper function to publish events
├── consumer.ts         ← EventBridge rule stub + Lambda handler
├── schema.test.ts      ← Tests validating example payloads
└── README.md           ← Documents the event purpose and usage
```

---

## Quick Examples

```bash
/event user.profile.updated
/event product.review.created
/event payment.invoice.paid
/event order.item.shipped
```

---

## Next Steps

1. **Create the schema** — Define what data this event carries
2. **Publish from producer** — Use `/lambda` to create the service that emits this event
3. **Consume in subscriber** — Use `/lambda` to create the handler that reacts to it
4. **Update architecture** — Use `/diagram` to show the event flow
5. **Test end-to-end** — `npm test` validates schema, then integration test the whole flow

---

## See Also

- [Naming Conventions](../rules/naming.md#events-event-bus) — Event naming patterns
- [Architecture](../../../docs/ARCHITECTURE.md) — Event flow diagrams
- [How to Add a Feature](../../../docs/HOW-TO-ADD-A-FEATURE.md) — Feature workflow
