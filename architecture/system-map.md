# System Architecture Map

> This file is read by Claude before making any cross-platform change.
> If your change affects a relationship shown here, update the diagram.
> Mermaid diagrams here are INPUT — they describe the current state of the system.

---

## Platform Layers

```mermaid
graph TD
    subgraph PRODUCTS["Product Layer  (built on top of platforms)"]
        P1[Customer Portal]
        P2[Admin Dashboard]
        P3[Mobile App]
    end

    subgraph APP["Application Platforms"]
        DS[Design System\ncomponents · tokens · patterns]
        AUTH[Auth Platform\nCognito · JWT · RBAC]
        NOTIFY[Notification Platform\nEmail · SMS · Push]
    end

    subgraph INFRA["Infrastructure Platform"]
        LAMBDA[Lambda Factory\ntemplates · Terraform modules]
        APIGW[API Gateway\nHTTP API · JWT auth]
        CDN[CDN / Edge\nCloudFront · WAF]
    end

    subgraph DATA["Data Platform"]
        EB[Event Bus\nEventBridge]
        DDB[DynamoDB\nshared table patterns]
        S3[S3\ndata lake · assets]
    end

    PRODUCTS --> APP
    APP --> INFRA
    APP --> DATA
    INFRA --> DATA

    style PRODUCTS fill:#1a1a2e,color:#eee
    style APP      fill:#16213e,color:#eee
    style INFRA    fill:#0f3460,color:#eee
    style DATA     fill:#0d4f2e,color:#eee
```

---

## Event Flow

```mermaid
sequenceDiagram
    participant Client
    participant APIGW as API Gateway
    participant Lambda
    participant DDB as DynamoDB
    participant EB as EventBridge
    participant Notify as Notification Platform

    Client->>APIGW: POST /users/profile  (JWT)
    APIGW->>Lambda: invoke user-profile-update-api
    Lambda->>Lambda: validate (Zod)
    Lambda->>DDB: PutItem
    Lambda->>EB: emit user.profile.updated
    Lambda->>APIGW: 200 OK
    APIGW->>Client: response

    EB->>Notify: route user.profile.updated
    Notify->>Client: "Your profile was updated" email
```

---

## Cross-Platform Contracts

```mermaid
erDiagram
    LAMBDA_FACTORY ||--o{ LAMBDA_FUNCTION : "generates"
    LAMBDA_FUNCTION ||--|| TERRAFORM_MODULE : "has"
    LAMBDA_FUNCTION ||--o{ EVENT : "emits"
    EVENT ||--o{ LAMBDA_FUNCTION : "triggers"
    LAMBDA_FUNCTION ||--|| IAM_ROLE : "assumes"

    DESIGN_SYSTEM ||--o{ COMPONENT : "exports"
    COMPONENT ||--|| TOKEN_SET : "uses"

    DATA_PLATFORM ||--|| EVENT_BUS : "owns"
    DATA_PLATFORM ||--|| DDB_TABLE : "owns"
```

---

## Deployment Pipeline

```mermaid
flowchart LR
    PR[Pull Request] --> CI[CI — test + lint]
    CI --> PREVIEW[Preview deploy\ndev environment]
    PREVIEW --> REVIEW[Human review\n+ Claude /review]
    REVIEW --> MERGE[Merge to main]
    MERGE --> STAGING[Auto-deploy staging]
    STAGING --> SMOKE[Smoke tests]
    SMOKE --> PROD[Manual approve\n→ prod deploy]
```

---

## How to use these diagrams

| Use case              | What to do                                                                  |
| --------------------- | --------------------------------------------------------------------------- |
| Building a new Lambda | Read Event Flow — understand where it fits                                  |
| Adding a new event    | Read Event Flow + Cross-Platform Contracts — update both if needed          |
| New UI component      | Read Platform Layers — confirm it belongs in Design System or product layer |
| New platform          | Read Platform Layers — update the diagram before writing any code           |

Claude will read this file when you run `/lambda`, `/component`, `/api`, or `/diagram`.
