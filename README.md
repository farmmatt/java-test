# java-test

Self-contained **Java 21 LTS** + **Gradle 9 (Groovy DSL — no Kotlin)** + **Fission-AI/OpenSpec** project initialized with local vendored specifications, schemas, and 12 unified single-file software engineering skills formatted per the Agent Skills (`agentskills.io`) specification.

---

## 1. Tech Stack & Build Configuration

- **Language**: Java 21 LTS (`record`, `sealed`, pattern matching, virtual threads), enforced via the Gradle Java Toolchain with `-Xlint:all` and `-parameters`.
- **Build System**: Gradle 9 using **Groovy DSL** (`build.gradle` and `settings.gradle` — zero Kotlin).
- **Version Catalog**: Centralized dependency versions in [gradle/libs.versions.toml](gradle/libs.versions.toml) (JUnit 5 Jupiter, AssertJ, SLF4J API, Logback Classic).
- **Multi-Core & Build Cache**: Parallel execution, configuration cache, and project-local `DirectoryBuildCache` (`.gradle/build-cache`) configured in [gradle.properties](gradle.properties) and [settings.gradle](settings.gradle).
- **Spec-Driven Design + Red-Green-Refactor TDD**: Configured in [openspec/config.yaml](openspec/config.yaml) and [openspec/project.md](openspec/project.md), with both `spec-driven` and `spec-driven-reviewed` schemas vendored locally under `openspec/schemas/`.

---

## 2. Quick Start & Verification

```bash
# Run full verification (compileJava with -Xlint:all, JUnit 5 tests)
./gradlew check --build-cache --parallel

# Run the application
./gradlew run

# Optional: load project-local Gradle shortcuts (gwb, gwt, gwcheck, gwc)
source scripts/gradle-shortcuts.sh
gwcheck
```

---

## 3. Vendored Specifications & Schemas ("Copy In, Don't Link Out")

All specifications, schemas, and unified skills are copied directly into this repository so the project has zero runtime dependency on external links or global dotfiles:

- **Agent Skills Specification**: [.agents/spec/specification.md](.agents/spec/specification.md) & [.agents/spec/best-practices.md](.agents/spec/best-practices.md)
- **OpenSpec Schemas**:
  - Reviewed Workflow (`proposal` -> `review` -> `specs`/`design` -> `tasks`): [openspec/schemas/spec-driven-reviewed/schema.yaml](openspec/schemas/spec-driven-reviewed/schema.yaml)
  - Standard Spec-Driven Workflow: [openspec/schemas/spec-driven/schema.yaml](openspec/schemas/spec-driven/schema.yaml)
- **AI Initialization Prompt**: [openspec/prompts/repo-init.md](openspec/prompts/repo-init.md)

---

## 4. Installed Software Engineering Tool Set (`.agents/skills/`)

Each skill merges its upstream sources into a **single unified `SKILL.md` file** formatted per [.agents/spec/specification.md](.agents/spec/specification.md) and can be customized locally inside this repository (`repo-init` preserves existing files unless `--force` is passed):

| Skill (`name`) | Unified Skill Definition | Role & Boundary |
| :--- | :--- | :--- |
| **`first-principles-thinking`** | [.agents/skills/first-principles-thinking/SKILL.md](.agents/skills/first-principles-thinking/SKILL.md) | **No-Code Designer**: Socratic assumption challenging, root-cause decomposition, and structured product/engineering brainstorming |
| **`spec-builder`** | [.agents/skills/spec-builder/SKILL.md](.agents/skills/spec-builder/SKILL.md) | **No-Code Specification Builder**: Design-tree grilling, "Seams before prose", OpenSpec `proposal.md` / `specs/` authoring, and vertical tracer-bullet `tasks.md` slicing |
| **`system-design`** | [.agents/skills/system-design/SKILL.md](.agents/skills/system-design/SKILL.md) | **No-Code System Designer**: 5-phase system design, deep-module vocabulary (`codebase-design`), `GLOSSARY.md` & ADR (`docs/adr/`) authoring, and `design.md` creation |
| **`java-architect`** | [.agents/skills/java-architect/SKILL.md](.agents/skills/java-architect/SKILL.md) | **No-Code Architect**: Clean/hexagonal package boundaries (`config`, `domain`, `service`), deep modules, and Confirmed Test Seams in `design.md` |
| **`openspec-reviewer`** | [.agents/skills/openspec-reviewer/SKILL.md](.agents/skills/openspec-reviewer/SKILL.md) | **No-Code Reviewer**: Pre-implementation `review.md` gate (`OPTIMAL` / `IMPROVABLE` / `RETHINK`), seam verification, and vertical-slice `tasks.md` gate |
| **`test-driven-development`** | [.agents/skills/test-driven-development/SKILL.md](.agents/skills/test-driven-development/SKILL.md) | **TDD Discipline**: Enforces the Iron Law, pre-agreed seams, vertical tracer-bullet Red $\rightarrow$ Green loop, Gate Functions 1 & 2, and Mutation Check |
| **`java-expert`** | [.agents/skills/java-expert/SKILL.md](.agents/skills/java-expert/SKILL.md) | **Developer Agent (Sole Code Author)**: Executes the Red $\rightarrow$ Green loop in Java 21 + Gradle 9 Groovy DSL + JUnit 5/AssertJ and applies refactorings suggested by `code-review-expert` |
| **`code-review-expert`** | [.agents/skills/code-review-expert/SKILL.md](.agents/skills/code-review-expert/SKILL.md) | **No-Code Reviewer**: Read-only Two-Axis Audit (Spec/Seams + Standards/Fowler Smells/Tech Debt) that feeds concrete refactoring instructions back to `java-expert` |
| **`systematic-debugging`** | [.agents/skills/systematic-debugging/SKILL.md](.agents/skills/systematic-debugging/SKILL.md) | **Debugging & Incident Diagnosis**: Tight red-capable feedback loops, backward call-stack root-cause tracing, 4-layer defense-in-depth validation, and postmortems |
| **`readme-generator`** | [.agents/skills/readme-generator/SKILL.md](.agents/skills/readme-generator/SKILL.md) | Zero-hallucination codebase scanning to maintain `README.md`, `package-info.java`, runbooks, and onboarding docs |
| **`git-workflow-manager`** | [.agents/skills/git-workflow-manager/SKILL.md](.agents/skills/git-workflow-manager/SKILL.md) | Feature branching, Conventional Commits linked to OpenSpec changes, and pre-commit checks |
| **`cicd-expert`** | [.agents/skills/cicd-expert/SKILL.md](.agents/skills/cicd-expert/SKILL.md) | Reproducible Java 21 + Gradle 9 CI/CD pipelines, build cache tuning, and pre/post-deploy rollback gates |
