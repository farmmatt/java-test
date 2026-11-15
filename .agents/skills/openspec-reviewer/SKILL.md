---
name: openspec-reviewer
description: >-
  Review an OpenSpec proposal and specification artifacts with mandatory
  evidence-driven codebase investigation before advancing to specs, design, or
  implementation. Enforces pre-agreed test seams and vertical Red-Green TDD tasks.
  Never writes production or test code.
license: MIT
compatibility: >-
  Agent-agnostic Agent Skills format. Unifies griffithkk3-del/openspec-reviewed-workflow
  (SKILL.md & review-template.md) and mattpocock/skills (to-spec seam discipline).
metadata:
  role: "OpenSpec Proposal, Seam & Design Gate Reviewer (No-Code Role)"
  category: "spec-driven-workflow"
  version: "3.0.0"
---

# OpenSpec Evidence-Driven Reviewer (`openspec-reviewer`)

Review an OpenSpec proposal (`proposal.md`) and downstream specification artifacts (`specs/`, `design.md`, `tasks.md`) by investigating the actual codebase, producing an evidence-driven `review.md` report, and verifying that **Pre-Agreed Test Seams** and **Vertical Red-Green TDD Slices** are locked in before any code is written.

---

## 1. Strict Role & Investigation Constraints (NON-NEGOTIABLE)

1. **No-Code Reviewer Role & Disk-Artifact Mandate**:
   - You **NEVER** write or modify production code (`src/main/java/`) or test code (`src/test/java/`).
   - **Printing to the chat window is never a valid output**: Your review MUST be written to `openspec/changes/<change>/review.md` on disk, and you must verify that `proposal.md`, `specs/`, `design.md`, `tasks.md`, `GLOSSARY.md`, and `docs/adr/` exist on disk and include a complete **Decision Matrix** of all decisions taken.
2. **Mandatory Codebase Search**:
   - You **MUST** execute at least 2 codebase search/read operations (`Grep` / `Read`) before filling `2. Research & Evidence` in `review.md`.
   - If you claim no reusable code exists, you **MUST** list every search keyword you attempted.
   - You **MUST** include at least one actual codebase snippet or file reference in `Code Evidence`.
3. **Evidence-Grounded `RETHINK`**:
   - When issuing a `RETHINK` verdict, you **MUST** provide a concrete replacement approach in `3. Alternative Analysis` grounded in code/files actually found in the repository.
4. **Actionable `IMPROVABLE`**:
   - When issuing an `IMPROVABLE` verdict, you **MUST** specify the exact section of `proposal.md` (or `specs/` / `design.md` / `tasks.md`) to edit and the exact change required.

---

## 2. The 7-Step Proposal Review Process (Gate 1: `proposal.md` $\rightarrow$ `review.md`)

1. **Read the Proposal (`proposal.md`)**:
   Extract the key claims:
   - What problem does it solve (from the user/caller perspective)?
   - What packages/files (`config`, `domain`, `service`) does it target?
   - What new capabilities (`New Capabilities`) or modified capabilities (`Modified Capabilities`) does it introduce?
   - What existing mechanisms does it reference?

2. **Execute Codebase Investigation (MANDATORY — Minimum 2 Searches)**:
   - Search for classes/methods mentioned in the proposal's `Impact` section.
   - Search for similar patterns, domain records, or services in `src/` that could be reused or deepened.
   - Read target files, `openspec/project.md`, and `openspec/specs/` to verify the proposal's claims and check for conflicts.
   - Record every search keyword, file path, and supporting code snippet.

3. **Evaluate Alternatives**:
   - Can the problem be solved by adjusting existing configuration or parameters?
   - Can it be solved by reusing or deepening an existing domain/service module rather than adding a new shallow layer?
   - Is there a simpler first-principles approach (`first-principles-thinking`) that the proposal missed?
   - Build a comparison table (`Approach | Pros | Cons | Complexity`) comparing **Proposed**, **Alternative A**, and **Alternative B**.

4. **Perform Feasibility & Convention Checks**:
   - **Dependency Check**: Are all referenced modules/APIs available, and are any new libraries declared for `gradle/libs.versions.toml` under the **Groovy DSL (`build.gradle` — no Kotlin)** rule?
   - **Performance Impact**: No hot-path deep copying, no unbounded collection/map growth, no blocking calls on non-virtual threads.
   - **Testability at Public Seams**: Can the proposed change be verified deterministically through a public seam using JUnit 5 + AssertJ without mocking internal collaborators?

5. **Produce Verdict**:
   Rate as exactly one of:
   - **`OPTIMAL`**: Best approach for the codebase. No material improvements needed. Unlocks `specs/` and `design.md`.
   - **`IMPROVABLE`**: Direction is sound, but specific edits to `proposal.md` are required in `Action Items` before advancing.
   - **`RETHINK`**: Fundamental issues (wrong assumptions, missed existing solution, shallow pass-through module, or layer violation). Provide a concrete code-backed alternative in `Alternative Analysis`.

6. **Write `openspec/changes/<change>/review.md`**:
   Fill all 6 sections of the embedded template in **Section 4** below.

7. **Report Status & Next Step**:
   - If `OPTIMAL`: *"Gate 1 Review passed (`OPTIMAL`). `specs` and `design` are unlocked."*
   - If `IMPROVABLE`: *"Gate 1 Review found required improvements (`IMPROVABLE`). Update `proposal.md` with the listed Action Items and re-run review."*
   - If `RETHINK`: *"Gate 1 Review recommends rethinking the approach (`RETHINK`). See Alternative Analysis for the evidence-backed replacement direction."*

---

## 3. Downstream Gate Verifications (Gates 2, 3 & 4)

### Gate 2: Reviewing `specs/<capability>/spec.md` (Synthesis & Test Seams)
- **Decision Record**: Specs synthesize agreed decisions without inventing unrequested scope; check that an explicit out-of-scope boundary is respected.
- **Format & Literal Expectations**: Every requirement uses `### Requirement: <name>` with SHALL/MUST and at least one `#### Scenario: <name>` (4 `#` marks) with **GIVEN** / **WHEN** / **THEN** bullets containing **independent literal expected values** (so tests never recompute expected values using implementation formulas).
- **Proposed Test Seams**: Verify the spec identifies the highest existing or proposed public seam(s) where the capability will be tested (ideal number of seams: 1).

### Gate 3: Reviewing `design.md` (Deep Modules & Confirmed Seams)
- Verify `java-architect` evaluated alternatives (**Design It Twice**), kept `domain/` framework-agnostic with Java 21 `record`/`sealed` types and constructor injection, and included the **`## Confirmed Test Seams`** table (`Seam Name & Public Interface | Dependency Category & Adapter Strategy | What It Catches | What It Misses`).
- Verify zero production or test code was written during the design phase.

### Gate 4: Reviewing `tasks.md` (Vertical Red-Green Slices + Review-Driven Refactor)
- **Reject Horizontal Slicing**: Reject any `tasks.md` that separates "Write all production classes" from "Write unit tests later".
- **Enforce Vertical Tracer-Bullet Slices**: Every implementation task must represent one vertical slice at a confirmed seam following `RED (failing JUnit 5 test)` $\rightarrow$ `Verify RED` $\rightarrow$ `GREEN (minimal Java 21 code)` $\rightarrow$ `Verify GREEN (./gradlew check + Mutation Check)`.
- **Enforce Final Review & Refactor Loop**: Confirm `tasks.md` ends with a read-only `code-review-expert` audit that feeds refactoring recommendations back to `java-expert`, followed by `readme-generator` sync and `git-workflow-manager` commit.

---

## 4. Embedded `review.md` Artifact Template (All 6 Sections Mandatory)

```markdown
## 1. Executive Summary

- **Status**: <!-- OPTIMAL | IMPROVABLE | RETHINK -->
- **Reviewer**: AI Architect (`openspec-reviewer`)
- **Target Proposal**: <!-- proposal title or path -->
- **Summary**: <!-- Brief review conclusion. If not OPTIMAL, explain the core blocker or improvement in one sentence. -->

## 2. Research & Evidence

<!-- Before filling this section, you MUST execute at least 2 codebase search/read operations. -->

### Existing Logic / Utilities
<!-- Reusable classes, records, services, or code paths found during investigation. -->

### Related Patterns
<!-- Similar patterns found elsewhere in the repository and how they relate to the proposal. -->

### Potential Conflicts
<!-- Modules, interfaces, or architectural rules in openspec/project.md that conflict with the proposal. -->

### Code Evidence
```text
# Paste at least one relevant code snippet or search result from the repository.
```

### Search Keywords Attempted
<!-- List every keyword or pattern searched, even if some returned no result. -->

## 3. Alternative Analysis

| Approach | Pros | Cons | Complexity |
| :--- | :--- | :--- | :--- |
| **Proposed** | | | |
| **Alternative A** | | | |
| **Alternative B** | | | |

### Conclusion
<!-- Explain why the proposed or alternative path is the best fit for the current codebase. -->

## 4. Feasibility Check

- [ ] **Dependency Check**: <!-- Are required dependencies available or declared for gradle/libs.versions.toml (Groovy DSL)? -->
- [ ] **Performance Impact**: <!-- Any hot-path cost, unbounded growth, or heavy copying risk? -->
- [ ] **Testability & Seam Clarity**: <!-- Can this be verified deterministically at a single public seam with JUnit 5 + AssertJ? -->

## 5. Detailed Verdict & Action Items

### Verdict
<!-- Explain why the proposal is OPTIMAL / IMPROVABLE / RETHINK. -->

### Action Items
<!-- If OPTIMAL: state that no proposal changes are required and identify the primary test seam to carry into specs/ and design.md. -->
<!-- If IMPROVABLE: list exact section-by-section edits required in proposal.md. -->
<!-- If RETHINK: list the invalidated assumptions and provide a concrete code-grounded replacement direction. -->

## 6. Review Metadata

- **Review Date**: <!-- YYYY-MM-DD -->
- **Context Depth**: <!-- Number of files read / searches executed -->
- **Tools Used**: <!-- Grep, Read, Glob, etc. -->
```
