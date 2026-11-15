# java-test

Self-contained **Java 21 LTS** + **Gradle 9 (Groovy DSL — no Kotlin)** + **Fission-AI/OpenSpec** project initialized with local vendored specifications, schemas, and agent-agnostic skills formatted per the Agent Skills (`agentskills.io`) specification.

---

## 1. Tech Stack & Build Configuration

- **Language**: Java 21 LTS (`record`, `sealed`, pattern matching, virtual threads), enforced via the Gradle Java Toolchain with `-Xlint:all` and `-parameters`.
- **Build System**: Gradle 9 using **Groovy DSL** (`build.gradle` and `settings.gradle` — zero Kotlin).
- **Version Catalog**: Centralized dependency versions in [gradle/libs.versions.toml](gradle/libs.versions.toml) (JUnit 5 Jupiter, AssertJ, SLF4J API, Logback Classic).
- **Multi-Core & Build Cache**: Parallel execution, configuration cache, and project-local `DirectoryBuildCache` (`.gradle/build-cache`) configured in [gradle.properties](gradle.properties) and [settings.gradle](settings.gradle).
- **Spec-Driven Workflow**: Fission-AI/OpenSpec configured in [openspec/config.yaml](openspec/config.yaml) and [openspec/project.md](openspec/project.md), with both `spec-driven` and `spec-driven-reviewed` schemas vendored locally under `openspec/schemas/`.

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

All specifications, schemas, and upstream skill references are copied directly into this repository so the project has zero runtime dependency on external links or global dotfiles:

- **Agent Skills Specification**: [.agents/spec/specification.md](.agents/spec/specification.md) & [.agents/spec/best-practices.md](.agents/spec/best-practices.md)
- **OpenSpec Schemas**:
  - Reviewed Workflow (`proposal` -> `review` -> `specs`/`design` -> `tasks`): [openspec/schemas/spec-driven-reviewed/schema.yaml](openspec/schemas/spec-driven-reviewed/schema.yaml)
  - Standard Spec-Driven Workflow: [openspec/schemas/spec-driven/schema.yaml](openspec/schemas/spec-driven/schema.yaml)
- **AI Initialization Prompt**: [openspec/prompts/repo-init.md](openspec/prompts/repo-init.md)

---

## 4. Installed Project Personas & Skills (`.agents/skills/`)

Agents and skills can originate from any source, provided they are formatted using the agent-agnostic Agent Skills (`.agents/spec/specification.md`) `<name>/SKILL.md` frontmatter standard. Each skill includes its verbatim upstream reference in `<skill>/references/upstream-source.md` and can be customized locally inside this repository (`repo-init` preserves existing files unless `--force` is passed):

| Skill (`name`) | Skill Definition | Upstream Reference Copy | Role |
| :--- | :--- | :--- | :--- |
| **`first-principles-thinking`** | [.agents/skills/first-principles-thinking/SKILL.md](.agents/skills/first-principles-thinking/SKILL.md) | [upstream-source.md](.agents/skills/first-principles-thinking/references/upstream-source.md) | Socratic assumption challenging, root-cause decomposition, and ground-up design synthesis |
| **`java-expert`** | [.agents/skills/java-expert/SKILL.md](.agents/skills/java-expert/SKILL.md) | [upstream-source.md](.agents/skills/java-expert/references/upstream-source.md) | Java 21 LTS, Gradle 9 Groovy DSL, TOML catalog, and JUnit 5 + AssertJ implementation |
| **`java-architect`** | [.agents/skills/java-architect/SKILL.md](.agents/skills/java-architect/SKILL.md) | [upstream-source.md](.agents/skills/java-architect/references/upstream-source.md) | Clean/hexagonal package boundaries (`config`, `domain`, `service`), DDD, and `design.md` |
| **`openspec-reviewer`** | [.agents/skills/openspec-reviewer/SKILL.md](.agents/skills/openspec-reviewer/SKILL.md) | [upstream-source.md](.agents/skills/openspec-reviewer/references/upstream-source.md) | Pre-implementation review gate (`OPTIMAL` / `IMPROVABLE` / `RETHINK`) for proposals and specs |
| **`code-review-expert`** | [.agents/skills/code-review-expert/SKILL.md](.agents/skills/code-review-expert/SKILL.md) | [upstream-source.md](.agents/skills/code-review-expert/references/upstream-source.md) | Post-implementation 5-pillar code, architecture, security, and JUnit 5 test audit |
| **`readme-generator`** | [.agents/skills/readme-generator/SKILL.md](.agents/skills/readme-generator/SKILL.md) | [upstream-source.md](.agents/skills/readme-generator/references/upstream-source.md) | Zero-hallucination codebase scanning to maintain `README.md` and `package-info.java` |
| **`git-workflow-manager`** | [.agents/skills/git-workflow-manager/SKILL.md](.agents/skills/git-workflow-manager/SKILL.md) | [upstream-source.md](.agents/skills/git-workflow-manager/references/upstream-source.md) | Feature branching, Conventional Commits linked to OpenSpec changes, and pre-commit checks |
| **`cicd-expert`** | [.agents/skills/cicd-expert/SKILL.md](.agents/skills/cicd-expert/SKILL.md) | [upstream-source.md](.agents/skills/cicd-expert/references/upstream-source.md) | Reproducible Java 21 + Gradle 9 CI/CD pipelines, build cache tuning, and quality gates |
