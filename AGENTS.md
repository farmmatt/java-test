# Project Agent Guidelines & Personas (`java-test`)

This repository uses **Fission-AI/OpenSpec** ([openspec/config.yaml](openspec/config.yaml) & [openspec/project.md](openspec/project.md)) along with self-contained personas and skills stored in `.agents/skills/<name>/SKILL.md`.

> **Format & Customizing Skills in This Repo ("Copy In, Don't Link Out")**: Agents and skills can be sourced from anywhere (community libraries, team conventions, or custom definitions), provided they are formatted using the agent-agnostic Agent Skills `<name>/SKILL.md` frontmatter specification vendored at [.agents/spec/specification.md](.agents/spec/specification.md) and [.agents/spec/best-practices.md](.agents/spec/best-practices.md). Each default skill and its verbatim upstream source (`references/upstream-source.md`) are copied directly into `.agents/skills/` so you can freely modify them or add new ones inside this repository as needed (`repo-init` will not overwrite existing files unless `--force` is passed).

---

## Vendored Specifications & Schemas

- **Agent Skills Specification**: [.agents/spec/specification.md](.agents/spec/specification.md) & [.agents/spec/best-practices.md](.agents/spec/best-practices.md)
- **OpenSpec Reviewed Workflow Schema (`spec-driven-reviewed`)**: [openspec/schemas/spec-driven-reviewed/schema.yaml](openspec/schemas/spec-driven-reviewed/schema.yaml)
- **OpenSpec Standard Workflow Schema (`spec-driven`)**: [openspec/schemas/spec-driven/schema.yaml](openspec/schemas/spec-driven/schema.yaml)
- **AI Repository Initialization Prompt**: [openspec/prompts/repo-init.md](openspec/prompts/repo-init.md)

---

## Installed Project Personas & Skills (`.agents/skills/`)

| Name (`name`) | Skill Path | Upstream Source Copy | Role & Activation Stage |
| :--- | :--- | :--- | :--- |
| **`first-principles-thinking`** | [.agents/skills/first-principles-thinking/SKILL.md](.agents/skills/first-principles-thinking/SKILL.md) | [upstream-source.md](.agents/skills/first-principles-thinking/references/upstream-source.md) | **First-Principles Thinking Expert** — Challenges assumptions (5 Whys, Socratic questioning), isolates fundamental truths, and rebuilds solutions from scratch during `proposal.md` and `design.md` |
| **`java-expert`** | [.agents/skills/java-expert/SKILL.md](.agents/skills/java-expert/SKILL.md) | [upstream-source.md](.agents/skills/java-expert/references/upstream-source.md) | **Java Development Expert** — Implements Java 21 LTS code (`record`, `sealed`, virtual threads), Gradle 9 Groovy DSL (`build.gradle` — no Kotlin), `gradle/libs.versions.toml`, and JUnit 5 + AssertJ tests |
| **`java-architect`** | [.agents/skills/java-architect/SKILL.md](.agents/skills/java-architect/SKILL.md) | [upstream-source.md](.agents/skills/java-architect/references/upstream-source.md) | **Java Architect** — Designs clean/hexagonal package boundaries (`config`, `domain`, `service`), DDD models, and OpenSpec `design.md` |
| **`openspec-reviewer`** | [.agents/skills/openspec-reviewer/SKILL.md](.agents/skills/openspec-reviewer/SKILL.md) | [upstream-source.md](.agents/skills/openspec-reviewer/references/upstream-source.md) | **Spec & Design Reviewer** — Enforces pre-implementation `review.md` gates (`OPTIMAL` / `IMPROVABLE` / `RETHINK`) across `proposal.md`, `specs/`, `design.md`, and `tasks.md` |
| **`code-review-expert`** | [.agents/skills/code-review-expert/SKILL.md](.agents/skills/code-review-expert/SKILL.md) | [upstream-source.md](.agents/skills/code-review-expert/references/upstream-source.md) | **Code Review Expert** — Audits implementation against OpenSpec scenarios, layer purity, security, Java 21/Gradle hygiene, and JUnit 5 coverage before archive/merge |
| **`readme-generator`** | [.agents/skills/readme-generator/SKILL.md](.agents/skills/readme-generator/SKILL.md) | [upstream-source.md](.agents/skills/readme-generator/references/upstream-source.md) | **README Generator & Documenter** — Zero-hallucination scanning to keep `README.md` and `package-info.java` files accurate |
| **`git-workflow-manager`** | [.agents/skills/git-workflow-manager/SKILL.md](.agents/skills/git-workflow-manager/SKILL.md) | [upstream-source.md](.agents/skills/git-workflow-manager/references/upstream-source.md) | **Git Workflow Manager** — Manages feature branches, Conventional Commits linked to OpenSpec changes, and pre-commit verification |
| **`cicd-expert`** | [.agents/skills/cicd-expert/SKILL.md](.agents/skills/cicd-expert/SKILL.md) | [upstream-source.md](.agents/skills/cicd-expert/references/upstream-source.md) | **CI/CD Expert** — Designs and optimizes reproducible Java 21 + Gradle 9 build/test pipelines and caching |
