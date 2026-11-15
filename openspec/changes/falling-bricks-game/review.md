# OpenSpec Review: Falling Bricks Console Game (`falling-bricks-game`)

- **Reviewer Skill**: `openspec-reviewer`
- **Date**: 2026-11-15
- **Verdict**: **APPROVED FOR TDD PLAN REVIEW** (All Interview Questions `Q1`–`Q5`, Mockups, Logging, Configurability & Expansion Points Captured on Disk)

---

## 1. Evidence-Driven Repository & Spec Audit

| Check | Requirement / Guardrail | Artifact Evidence | Status |
| :--- | :--- | :--- | :--- |
| **1. Disk Persistence** | Nothing printed only to chat; all specs, mockups & decision matrix written to repo files | `GLOSSARY.md`, `docs/adr/0001-falling-bricks-architecture-and-decision-matrix.md`, `proposal.md`, `specs/falling-bricks/spec.md`, `design.md`, `tasks.md` | **PASS** |
| **2. Sample UI Mockups** | Concrete console mockups for Startup/Config, Active Board, Validation Error, and Game Over / Retry | `proposal.md` §2 (Mockups 1–4) | **PASS** |
| **3. Logging Strategy** | `SLF4J + Logback` separated from `STDOUT` console UI (`GameRenderer`) | `ADR 0001` (`DEC-10`), `proposal.md` §4, `design.md` §3 | **PASS** |
| **4. Configurability** | All parameters configurable via `application.properties` (`InputStream`) + CLI overrides, zero hardcoded paths | `ADR 0001` (`DEC-04`, `DEC-11`), `proposal.md` §3, `spec.md` Req 1 | **PASS** |
| **5. `Q1` Seeded PRNG, Overflow Count & Retry** | `Random(seed)`, finite configurable `brickCount` large enough to overflow (`brickCount >= (height/3)+1`), `RETRY` reuses exact same `seed` | `ADR 0001` (`DEC-05`), `spec.md` Req 3 (Scenarios 3.1–3.3) | **PASS** |
| **6. `Q2` Random Top Spawn & Timer Drop** | Random valid top-row spawn column from seeded PRNG + timer step (`Command.TICK`) + immediate drop (`Command.DROP`) | `ADR 0001` (`DEC-06`), `spec.md` Req 3 & Req 4 (Scenario 4.3) | **PASS** |
| **7. `Q3` Rigid Bar While Dropping** | All bricks (`HORIZONTAL` and `VERTICAL`) are rigid bars while falling/dropping | `ADR 0001` (`DEC-07`), `spec.md` Req 4 (Scenario 4.2), `design.md` §2.2 | **PASS** |
| **8. `Q4` Horizontal Row Clear & Gravity** | Full horizontal row or horizontal match clears; stacked blocks above lose original brick shape and drop independently under gravity | `ADR 0001` (`DEC-08`), `spec.md` Req 5 (Scenarios 5.1–5.2), `design.md` §2.3 | **PASS** |
| **9. `Q5` ASCII Symbols, Bounds & Overflow** | Printable 7-bit ASCII (`0x21..0x7E`), negative/zero forbidden, `min >= largestBrick (3)`, `max` configurable default `20x20`, vertical overflow $\rightarrow$ `VERTICAL_OVERFLOW` (`GAME_OVER`) | `ADR 0001` (`DEC-02`, `DEC-09`), `spec.md` Req 1, Req 2 & Req 6 | **PASS** |
| **10. Expansion Points 1 & 2** | Expansion Point 1 (Winnability validation deferred) & Expansion Point 2 (Variable brick shapes/sizes noted in design via span methods without overbuilding) | `ADR 0001` (`DEC-12`, `DEC-13`), `design.md` §4.1–4.2 | **PASS** |
| **11. State-Based Testing & Real Integration** | Assert on domain state (`Grid`, `GameSnapshot`, `ValidationResult`), not console output; include real multi-component integration tests | `tasks.md` Deliveries `D1–D8` | **PASS** |
| **12. Trackable Delivery Breakdown** | Master Trackable Delivery Matrix (`D1–D8`) with Spec/ADR links, deliverables, review gates, commit checkpoints, status, and SHA tracking | `tasks.md` §1–§4 | **PASS** |

---

## 2. Gate Status

- **Specification & Design Gate**: **PASSED**
- **Next Step**: User review of the Vertical-Slice Red-Green-Refactor TDD Plan in `openspec/changes/falling-bricks-game/tasks.md`. No `.java` code will be written until the user approves `tasks.md`.
