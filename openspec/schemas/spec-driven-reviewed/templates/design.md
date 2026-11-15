<!-- STRICT ROLE BOUNDARY: The Designer / Architect (java-architect) NEVER writes production or test code. This document defines deep module interfaces, dependency categories, and confirmed test seams for the Developer Agent (java-expert). -->

## Context

<!-- Background, current state of config/domain/service packages, and domain invariants -->

## Goals / Non-Goals

**Goals:**
<!-- What this design aims to achieve -->

**Non-Goals:**
<!-- What is explicitly out of scope -->

## Deep Module & Interface Decisions ("Design It Twice")

<!-- Compare at least 2 candidate interface designs on Depth (leverage at the interface), Locality (where change concentrates), and Seam Placement before choosing. -->

| Candidate Design | Interface Surface | Depth & Locality Trade-offs | Verdict |
| :--- | :--- | :--- | :--- |
| **Option A (Minimal Interface / Max Depth)** | | | |
| **Option B (Alternative Seam / Ports)** | | | |

### Chosen Module Interface & Dependency Classification
<!-- Classify dependencies: 1. In-Process (pure domain), 2. Local-Substitutable, 3. Remote-but-Owned (Ports & Adapters), 4. True External (Mock/Stub at boundary) -->

## Confirmed Test Seams (Handshake to `test-driven-development` & `java-expert`)

<!-- No test may be written at an unconfirmed seam. Lock in the exact public seam(s) agreed with the user: -->

| Confirmed Seam & Public Interface | Dependency Category & Adapter Strategy | What This Seam Catches | What This Seam Misses |
| :--- | :--- | :--- | :--- |
| | | | |

## Risks / Trade-offs

<!-- Known risks and mitigations -->

## Migration & Rollback Plan

<!-- Safe deployment and revert steps -->
