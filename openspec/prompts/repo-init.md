# Universal Repository Initialization Guide & AI Prompt (OpenSpec + Unified Agent Skills + TDD)

This guide defines the **Terminal Initialization (Prerequisites)** and the **AI Coding Assistant Initialization Prompt** for setting up a clean, well-structured Java 21 project using **Gradle 9 (Groovy DSL — no Kotlin)**, **TOML Version Catalogs (`gradle/libs.versions.toml`)**, **JUnit 5**, **Fission-AI/OpenSpec**, **Red-Green-Refactor TDD**, and 12 unified single-file software engineering personas/skills formatted per the vendored **Agent Skills** specification (`.agents/spec/specification.md` & `.agents/spec/best-practices.md`).

---

## 1. Terminal Initialization (Prerequisites)

Run these commands in your terminal to scaffold the base Gradle project and install the OpenSpec CLI before opening your AI coding assistant:

```bash
# 1. Create project directory and initialize Gradle with Groovy DSL (no Kotlin) & JUnit 5
mkdir my-java-service && cd my-java-service
gradle init \
  --type java-application \
  --dsl groovy \
  --test-framework junit-jupiter \
  --package com.example.app \
  --project-name my-java-service \
  --java-version 21 \
  --no-split-project

# 2. Install OpenSpec CLI globally (requires Node.js 22.12+)
npm install -g @fission-ai/openspec@latest

# 3. Initialize OpenSpec in the repository (select your AI coding tool when prompted)
openspec init

# 4. Copy in workspace templates, vendored specs/schemas, & 12 unified single-file skills (.agents/skills/<name>/SKILL.md)
repo-init --lang java --name my-java-service
```

*(Tip: Running `gw-init` inside `my-java-service` automates steps 1, 3, and 4 in a single command without overwriting any existing customized files unless `--force` is passed.)*

---

## 2. AI Coding Assistant Initialization Prompt (`repo-init-prompt`)

Copy and paste (or pipe via `repo-init-prompt`) the following initialization prompt into your AI coding assistant:

```markdown
You are setting up a clean, well-structured Java 21 project using Gradle (Groovy DSL — no Kotlin), OpenSpec for spec-driven design, Red-Green-Refactor Test-Driven Development (TDD), and 12 unified single-file personas/skills formatted according to the vendored agent-agnostic Agent Skills specification (`.agents/spec/specification.md` and `.agents/skills/<name>/SKILL.md`). Inspect the current workspace and complete the following tasks (or run `gw-init` if workspace templates are available):

### 1. Gradle & Java Configuration
- **Version Catalog (`gradle/libs.versions.toml`)**: Ensure all dependency versions are centralized here (include JUnit Jupiter, AssertJ, and SLF4J/Logback).
- **Build Script (`build.gradle` — Groovy DSL, no Kotlin)**:
  - Enforce Java 21 via the Gradle Java Toolchain.
  - Enable compiler warnings (`-Xlint:all`, `-parameters`) for `compileJava` and `compileTestJava`.
  - Configure the `test` task to use `useJUnitPlatform()` and log test events (`passed`, `skipped`, `failed`).
- **Multi-Core & Build Cache (`gradle.properties` & `settings.gradle`)**:
  - Ensure `gradle.properties` enables parallel execution (`org.gradle.parallel=true`), build caching (`org.gradle.caching=true`), and configuration caching (`org.gradle.configuration-cache=true`).
  - Ensure `settings.gradle` configures the local `DirectoryBuildCache` (`.gradle/build-cache`).
- **Package Structure**: Under `src/main/java/com/example/app/`, create clean placeholder packages (`config`, `domain`, `service`) with `package-info.java` files documenting each layer's responsibility.
- **Verification**: Run `./gradlew check` (or `gwcheck`) to verify the build and existing JUnit 5 tests pass cleanly.

### 2. OpenSpec Baseline, Vendored Schemas & 12 Unified Skills Setup
- Verify that the vendored OpenSpec schemas (`openspec/schemas/spec-driven-reviewed/` and `openspec/schemas/spec-driven/`) and Agent Skills specification (`.agents/spec/specification.md` and `.agents/spec/best-practices.md`) are copied into the repository ("Copy In, Don't Link Out").
- Populate `openspec/project.md` and `openspec/config.yaml` (`schema: spec-driven-reviewed`) as our single source of truth with:
  - **Tech Stack**: Java 21, Gradle 9 (Groovy DSL, TOML Version Catalog), SLF4J/Logback, JUnit 5, AssertJ.
  - **Strict Role Separation**:
    - Designers, Spec Builders & Spec Reviewers (`first-principles-thinking`, `spec-builder`, `system-design`, `java-architect`, `openspec-reviewer`) NEVER write production or test code; they define specs, deep module interfaces, `GLOSSARY.md`, `docs/adr/`, and Confirmed Test Seams.
    - Developer (`java-expert` + `test-driven-development` + `systematic-debugging`) is the sole code author, executing vertical Red -> Green slices at pre-agreed seams and applying refactorings suggested by `code-review-expert`.
    - Code Reviewer (`code-review-expert`) NEVER writes code; it runs a read-only Two-Axis Review (Spec/Seams + Standards/Fowler Smells/Tech Debt) and feeds refactoring instructions back to `java-expert`.
- Verify that all 12 unified single-file software engineering skills are present in `.agents/skills/<name>/SKILL.md` (modifiable within this build repo as needed):
  1. `first-principles-thinking` — First-principles problem deconstruction, assumption testing & brainstorming (No-Code Role)
  2. `spec-builder` — Design-tree grilling, "Seams before prose", OpenSpec `proposal.md` / `specs/` authoring & vertical tracer-bullet `tasks.md` slicing (No-Code Role)
  3. `system-design` — End-to-end 5-phase system design, deep-module vocabulary (`codebase-design`), `GLOSSARY.md` & ADR (`docs/adr/`) authoring, and `design.md` creation (No-Code Role)
  4. `java-architect` — Deep-module & hexagonal Java 21 architecture designer + Confirmed Test Seam author (No-Code Role)
  5. `openspec-reviewer` — Pre-implementation `review.md` (`OPTIMAL` / `IMPROVABLE` / `RETHINK`) & seam/vertical-slice gate reviewer (No-Code Role)
  6. `test-driven-development` — Unified TDD discipline (Iron Law, pre-agreed seams, vertical Red -> Green slices, Gate Functions 1 & 2, Mutation Check)
  7. `java-expert` — Sole code author: Java 21 & Gradle 9 implementation + Red -> Green TDD execution + applying reviewer-suggested refactorings
  8. `code-review-expert` — Read-only Two-Axis code reviewer, Fowler refactoring advisor & Tech-Debt auditor feeding back to `java-expert` (No-Code Role)
  9. `systematic-debugging` — Tight red-capable feedback loops, backward call-stack root-cause tracing, 4-layer defense-in-depth validation & postmortems
  10. `readme-generator` — Zero-hallucination README, `package-info.java`, runbook & onboarding documenter
  11. `git-workflow-manager` — Branching & Conventional Commits manager
  12. `cicd-expert` — CI/CD, Gradle build cache & deployment/rollback checklist expert
- Create an initial baseline spec at `openspec/specs/core/spec.md` describing the current application entry point and health/startup behavior.

### 3. Next Step
Once `./gradlew check` succeeds and the OpenSpec and `.agents/skills/` files are written, summarize the changes and wait for my first feature request before writing any feature code.
```
