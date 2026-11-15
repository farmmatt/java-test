# Universal Repository Initialization Guide & AI Prompt (OpenSpec + Agent Skills Format)

This guide defines the **Terminal Initialization (Prerequisites)** and the **AI Coding Assistant Initialization Prompt** for setting up a clean, well-structured Java 21 project using **Gradle 9 (Groovy DSL — no Kotlin)**, **TOML Version Catalogs (`gradle/libs.versions.toml`)**, **JUnit 5**, **Fission-AI/OpenSpec**, and personas/skills formatted per the vendored **Agent Skills** specification (`.agents/spec/specification.md` & `.agents/spec/best-practices.md`).

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

# 4. Copy in workspace templates, vendored specs/schemas, & default personas/skills (.agents/skills/<name>/)
repo-init --lang java --name my-java-service
```

*(Tip: Running `gw-init` inside `my-java-service` automates steps 1, 3, and 4 in a single command without overwriting any existing customized files unless `--force` is passed.)*

---

## 2. AI Coding Assistant Initialization Prompt (`repo-init-prompt`)

Copy and paste (or pipe via `repo-init-prompt`) the following initialization prompt into your AI coding assistant:

```markdown
You are setting up a clean, well-structured Java 21 project using Gradle (Groovy DSL — no Kotlin), OpenSpec for spec-driven development, and personas/skills formatted according to the vendored agent-agnostic Agent Skills specification (`.agents/spec/specification.md` and `.agents/skills/<name>/SKILL.md`). Inspect the current workspace and complete the following tasks (or run `gw-init` if workspace templates are available):

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

### 2. OpenSpec Baseline, Vendored Schemas & Personas/Skills Setup
- Verify that the vendored OpenSpec schemas (`openspec/schemas/spec-driven-reviewed/` and `openspec/schemas/spec-driven/`) and Agent Skills specification (`.agents/spec/specification.md` and `.agents/spec/best-practices.md`) are copied into the repository ("Copy In, Don't Link Out").
- Populate `openspec/project.md` and `openspec/config.yaml` (`schema: spec-driven-reviewed`) as our single source of truth with:
  - **Tech Stack**: Java 21, Gradle 9 (Groovy DSL, TOML Version Catalog), SLF4J/Logback, JUnit 5, AssertJ.
  - **Architecture Rules**: Keep domain models framework-agnostic; place orchestration in `service`; require unit tests for all new domain logic.
  - **Conventions**: Use constructor injection, Java records for immutable DTOs/value objects, and clear domain naming.
- Verify that the default personas and skills (plus their upstream source copies in `<skill>/references/upstream-source.md`) are present in `.agents/skills/<name>/SKILL.md` (formatted per `.agents/spec/specification.md`; agents/skills can be sourced from anywhere and modified within this build repo as needed):
  1. `first-principles-thinking` — First-principles problem deconstruction & assumption challenger
  2. `java-expert` — Java 21 & Gradle 9 implementation expert
  3. `java-architect` — Clean/hexagonal architecture & DDD boundary specialist
  4. `openspec-reviewer` — Pre-implementation `review.md` (`OPTIMAL` / `IMPROVABLE` / `RETHINK`) & spec/design gate reviewer
  5. `code-review-expert` — Post-implementation 5-pillar code & test reviewer
  6. `readme-generator` — Zero-hallucination README & package-info documenter
  7. `git-workflow-manager` — Branching & Conventional Commits manager
  8. `cicd-expert` — CI/CD & Gradle build cache pipeline expert
- Create an initial baseline spec at `openspec/specs/core/spec.md` describing the current application entry point and health/startup behavior.

### 3. Next Step
Once `./gradlew check` succeeds and the OpenSpec and `.agents/skills/` files are written, summarize the changes and wait for my first feature request before writing any feature code.
```
