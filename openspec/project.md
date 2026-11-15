# Project Single Source of Truth (`java-test`)

## 1. Tech Stack
- **Language**: Java 21 LTS (records, sealed interfaces, pattern matching, virtual threads)
- **Build System**: Gradle 9 (**Groovy DSL**: `build.gradle` & `settings.gradle` — no Kotlin)
- **Version Catalog**: `gradle/libs.versions.toml` (JUnit Jupiter, AssertJ, SLF4J, Logback)
- **Logging**: SLF4J API (`org.slf4j:slf4j-api`) + Logback Classic (`ch.qos.logback:logback-classic`)
- **Testing Framework**: JUnit 5 (`junit-jupiter`) + AssertJ (`assertj-core`)

## 2. Personas & Skills (`.agents/skills/` — Formatted per Agent Skills Spec)
Agents and skills can originate from any source or library, but must be formatted using the agent-agnostic [Agent Skills (`agentskills.io`)](https://agentskills.io/home) `SKILL.md` frontmatter specification. Default definitions are copied into `.agents/skills/<name>/SKILL.md` and can be customized directly within this repository:
1. **`java-expert`** (`.agents/skills/java-expert/SKILL.md`) — Java 21, Gradle 9 Groovy DSL, TOML catalog, and JUnit 5 + AssertJ implementation specialist.
2. **`java-architect`** (`.agents/skills/java-architect/SKILL.md`) — Clean/hexagonal architecture, DDD boundaries, and `design.md` lead.
3. **`code-review-expert`** (`.agents/skills/code-review-expert/SKILL.md`) — Post-implementation 5-pillar code, architecture, and JUnit 5 test reviewer.
4. **`openspec-reviewer`** (`.agents/skills/openspec-reviewer/SKILL.md`) — Pre-implementation spec & design gate reviewer (`proposal.md` $\rightarrow$ `specs/` $\rightarrow$ `design.md` $\rightarrow$ `tasks.md`).
5. **`readme-generator`** (`.agents/skills/readme-generator/SKILL.md`) — Zero-hallucination `README.md` and `package-info.java` documenter.
6. **`git-workflow-manager`** (`.agents/skills/git-workflow-manager/SKILL.md`) — Branching, Conventional Commits, and pre-commit verification manager.
7. **`cicd-expert`** (`.agents/skills/cicd-expert/SKILL.md`) — CI/CD pipeline and Gradle build cache automation expert.
8. **`first-principles-thinking`** (`.agents/skills/first-principles-thinking/SKILL.md`) — First-principles problem deconstruction, assumption challenging, and ground-up solution synthesis.

## 3. Architecture Rules
- **Domain (`com.example.app.domain`)**: Keep domain models strictly framework-agnostic; encapsulate core business invariants here.
- **Service (`com.example.app.service`)**: Place application orchestration and use cases in `service`.
- **Config (`com.example.app.config`)**: Keep configuration loading and constructor-based dependency wiring isolated in `config`.
- **Testing Requirement**: Require JUnit 5 unit tests (and AssertJ assertions) for all new domain logic and service orchestration, verified via `./gradlew check`.

## 4. Conventions
- Use constructor injection for all service and component dependencies.
- Use Java `record` types for immutable DTOs and value objects.
- Use clear, ubiquitous domain naming across packages, classes, and methods (`package-info.java` documents each layer's responsibility).
- Centralize all library and plugin versions in `gradle/libs.versions.toml`.
