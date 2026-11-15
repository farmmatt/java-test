---
name: openspec-reviewer
description: >-
  Review an OpenSpec proposal and specification artifacts with mandatory
  evidence-driven codebase investigation before advancing to specs, design, or
  implementation. Use when reviewing proposal.md, generating review.md, or validating
  OpenSpec change gates (OPTIMAL / IMPROVABLE / RETHINK).
license: MIT
compatibility: >-
  Agent-agnostic Agent Skills format. Works with OpenSpec (spec-driven and
  spec-driven-reviewed schemas).
metadata:
  role: "OpenSpec Proposal & Design Reviewer"
  category: "spec-driven-workflow"
  version: "2.0.0"
---

# OpenSpec Evidence-Driven Reviewer (`openspec-reviewer`)

Review an OpenSpec proposal (`proposal.md`) and downstream artifacts (`specs/`, `design.md`, `tasks.md`) by investigating the actual codebase and producing an evidence-driven `review.md` report before implementation begins.

- Full 6-section `review.md` template: [references/review-template.md](references/review-template.md)
- Verbatim upstream skill definition: [references/upstream-source.md](references/upstream-source.md)
- Installed schema definition: `openspec/schemas/spec-driven-reviewed/schema.yaml`

---

## Hard Constraints (Non-Negotiable)

1. **Mandatory Codebase Search**: You **MUST** execute at least 2 codebase search/read operations (`Grep` / `Read`) before filling `2. Research & Evidence`. If you claim no reusable code exists, you **MUST** list the exact search keywords you attempted.
2. **Evidence-Grounded `RETHINK`**: For a `RETHINK` verdict, you **MUST** provide a concrete alternative approach in `3. Alternative Analysis`, grounded in actual codebase files found during investigation.
3. **Actionable `IMPROVABLE`**: For an `IMPROVABLE` verdict, you **MUST** list the exact section and edits required in `proposal.md` under `5. Detailed Verdict & Action Items`.

---

## 7-Step Review Process

1. **Read the Proposal (`proposal.md`)**
   Extract the key claims:
   - What problem does it solve?
   - What files/packages (`config`, `domain`, `service`) does it target?
   - What new abstractions or capabilities (`New Capabilities` / `Modified Capabilities`) does it introduce?

2. **Execute Codebase Investigation (MANDATORY)**
   - Search for classes/methods mentioned in the proposal's `Impact` section.
   - Search for similar patterns or utilities in `src/` that could be reused.
   - Read target files and `openspec/project.md` / `openspec/specs/` to verify the proposal's claims.
   - Record every search keyword, file path, and a supporting code snippet.

3. **Evaluate Alternatives**
   - Can the problem be solved by adjusting existing configuration or parameters?
   - Can it be solved by reusing an existing domain/service mechanism?
   - Is there a simpler approach (using First-Principles Thinking) that the proposal missed?
   - Build a comparison table (`Approach | Pros | Cons | Complexity`) comparing **Proposed**, **Alternative A**, and **Alternative B**.

4. **Perform Feasibility & Convention Checks**
   - **Dependency Check**: Are required dependencies declared in `gradle/libs.versions.toml`? Does it respect the **Groovy DSL (`build.gradle` — no Kotlin)** rule?
   - **Performance Impact**: Any hot-path overhead, unbounded collection growth, or unnecessary copying?
   - **Testability**: Can every capability be verified via deterministic JUnit 5 + AssertJ tests?

5. **Produce Verdict**
   Rate as exactly one of:
   - **`OPTIMAL`**: Best approach for the codebase. Proceed to `specs/` and `design.md`.
   - **`IMPROVABLE`**: Direction is sound, but specific edits to `proposal.md` are required before proceeding.
   - **`RETHINK`**: Fundamental issues (wrong assumptions, missed existing utility, architectural boundary violation). Rework proposal using the concrete alternative.

6. **Write `review.md` & Verify Downstream Gates**
   - Fill all 6 sections of [references/review-template.md](references/review-template.md) (`1. Executive Summary`, `2. Research & Evidence`, `3. Alternative Analysis`, `4. Feasibility Check`, `5. Detailed Verdict & Action Items`, `6. Review Metadata`) into `openspec/changes/<change>/review.md`.
   - When reviewing `specs/**/*.md`: Ensure every requirement uses `### Requirement: <name>` with SHALL/MUST and at least one `#### Scenario: <name>` (exactly 4 `#` characters) with **WHEN** / **THEN** bullets.
   - When reviewing `tasks.md`: Ensure every task uses `- [ ] X.Y Task description` checkbox format and ends with `./gradlew check --build-cache --parallel`.

7. **Guardrails**
   - NEVER skip codebase investigation or write an evidence-free verdict.
   - NEVER rubber-stamp `OPTIMAL` to speed things along.
   - NEVER give `RETHINK` without a concrete code-backed alternative.
