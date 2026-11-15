# Project Single Source of Truth (`java-test`)

## 1. Tech Stack
- **Language**: Java 21 LTS (records, sealed interfaces, pattern matching, virtual threads)
- **Build System**: Gradle 9 (**Groovy DSL**: `build.gradle` & `settings.gradle` — no Kotlin)
- **Version Catalog**: `gradle/libs.versions.toml` (JUnit Jupiter, AssertJ, SLF4J, Logback)
- **Logging**: SLF4J API (`org.slf4j:slf4j-api`) + Logback Classic (`ch.qos.logback:logback-classic`)
- **Testing Framework**: JUnit 5 (`junit-jupiter`) + AssertJ (`assertj-core`)
- **Vendored Specs & Schemas**:
  - Agent Skills Specification: `.agents/spec/specification.md` & `.agents/spec/best-practices.md`
  - OpenSpec Schemas: `openspec/schemas/spec-driven-reviewed/schema.yaml` & `openspec/schemas/spec-driven/schema.yaml`

## 2. Strict Role Boundaries & Spec-Driven TDD Workflow
1. **Designers, Spec Builders & Spec Reviewers NEVER Write Code (`first-principles-thinking`, `spec-builder`, `system-design`, `java-architect`, `openspec-reviewer`)**:
   - Challenge assumptions, grill the design tree, maintain `GLOSSARY.md` and `docs/adr/`, design deep modules (`Module`, `Interface`, `Seam`, `Adapter`, `Depth`), and lock in **Pre-Agreed Test Seams** in `proposal.md`, `specs/`, `design.md`, and vertical tracer-bullet `tasks.md`.
2. **Developer Executes Vertical Red $\rightarrow$ Green TDD Slices (`java-expert` + `test-driven-development` + `systematic-debugging`)**:
   - Follows the Iron Law (`NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST`).
   - Builds one vertical slice at a time at a confirmed seam (`RED` $\rightarrow$ `Verify RED` $\rightarrow$ `GREEN` $\rightarrow$ `Verify GREEN + Mutation Check`).
3. **Code Reviewer NEVER Writes Code — Suggests Refactorings Fed Back to Developer (`code-review-expert` $\rightarrow$ `java-expert`)**:
   - `code-review-expert` performs a read-only **Two-Axis Review** (**Axis 1: Spec & Pre-Agreed Seam Compliance**; **Axis 2: Standards, Security, TDD Honesty, 12-Item Fowler Code Smell Baseline & Tech-Debt Priority**) and feeds concrete refactoring instructions back to `java-expert`, who applies them while keeping `./gradlew check` green.

## 3. Unified Software Engineering Tool Set (`.agents/skills/<name>/SKILL.md`)
All upstream sources are merged directly into a single self-contained `SKILL.md` file per skill (formatted per `.agents/spec/specification.md`) and can be customized locally within this repository:
1. **`first-principles-thinking`** (`.agents/skills/first-principles-thinking/SKILL.md`) — First-principles problem deconstruction, assumption testing, and brainstorming frameworks (No-Code Designer Role).
2. **`spec-builder`** (`.agents/skills/spec-builder/SKILL.md`) — Design-tree grilling, "Seams before prose", OpenSpec `proposal.md` / `specs/` authoring, and vertical tracer-bullet `tasks.md` slicing (No-Code Specification Builder Role).
3. **`system-design`** (`.agents/skills/system-design/SKILL.md`) — End-to-end 5-phase system design, deep-module vocabulary (`codebase-design`), `GLOSSARY.md` & ADR (`docs/adr/`) authoring, and `design.md` creation (No-Code System Designer Role).
4. **`java-architect`** (`.agents/skills/java-architect/SKILL.md`) — Java 21 clean/hexagonal package boundaries (`config`, `domain`, `service`), JVM/Spring architecture, and Confirmed Test Seam definition in `design.md` (No-Code Architect Role).
5. **`openspec-reviewer`** (`.agents/skills/openspec-reviewer/SKILL.md`) — Evidence-driven `review.md` (`OPTIMAL` / `IMPROVABLE` / `RETHINK`) and Gate 1–4 verifier (No-Code Reviewer Role).
6. **`test-driven-development`** (`.agents/skills/test-driven-development/SKILL.md`) — Unified TDD discipline (Iron Law, pre-agreed seams, vertical tracer-bullet Red $\rightarrow$ Green loop, Gate Functions 1 & 2, Mutation Check, and reviewer-driven refactoring).
7. **`java-expert`** (`.agents/skills/java-expert/SKILL.md`) — Developer Agent for Java 21, Gradle 9 Groovy DSL, TOML catalog, Red $\rightarrow$ Green JUnit 5/AssertJ implementation, and executing refactoring recommendations from `code-review-expert`.
8. **`code-review-expert`** (`.agents/skills/code-review-expert/SKILL.md`) — Read-only Two-Axis Reviewer, Fowler Refactoring Advisor & Tech-Debt Auditor that feeds refactoring tasks back to `java-expert` (No-Code Reviewer Role).
9. **`systematic-debugging`** (`.agents/skills/systematic-debugging/SKILL.md`) — Tight red-capable feedback loops, backward call-stack root-cause tracing, 4-layer defense-in-depth validation, and incident postmortems.
10. **`readme-generator`** (`.agents/skills/readme-generator/SKILL.md`) — Zero-hallucination `README.md`, `package-info.java`, runbook, and onboarding documenter.
11. **`git-workflow-manager`** (`.agents/skills/git-workflow-manager/SKILL.md`) — Branching, Conventional Commits, and pre-commit verification manager.
12. **`cicd-expert`** (`.agents/skills/cicd-expert/SKILL.md`) — CI/CD pipeline, Gradle build cache automation, and deployment/rollback checklist expert.

## 4. Architecture Rules & Conventions
- **Domain (`com.example.app.domain`)**: Keep domain models strictly framework-agnostic; encapsulate core business invariants here using Java 21 `record` and `sealed` types.
- **Service (`com.example.app.service`)**: Place application orchestration and public test seams in `service`.
- **Config (`com.example.app.config`)**: Keep configuration loading and constructor-based dependency wiring isolated in `config`.
- **Conventions**: Use constructor injection, Java `record` types for immutable DTOs/value objects, and centralize all library versions in `gradle/libs.versions.toml`.
