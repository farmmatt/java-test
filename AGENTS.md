# Project Agent Guidelines & Personas (`java-test`)

This repository uses **Fission-AI/OpenSpec** (`openspec/config.yaml` & `openspec/project.md`) along with personas and skills stored in `.agents/skills/<name>/SKILL.md`.

> **Format & Customizing Skills in This Repo**: Agents and skills can be sourced from anywhere (community libraries, team conventions, or custom definitions), provided they are formatted using the agent-agnostic [Agent Skills (`agentskills.io`)](https://agentskills.io/home) `<name>/SKILL.md` frontmatter specification. These default files were seeded from the workspace `dotfiles` and committed directly into `.agents/skills/` so you can freely modify them or add new ones inside this repository as needed.

---

## Installed Project Personas & Skills (`.agents/skills/`)

| Name (`name`) | Path | Role & Activation Stage |
| :--- | :--- | :--- |
| **`first-principles-thinking`** | [.agents/skills/first-principles-thinking/SKILL.md](.agents/skills/first-principles-thinking/SKILL.md) | **First-Principles Thinking Expert** — Challenges assumptions, isolates fundamental truths, and rebuilds solutions from the ground up during `proposal.md` and `design.md` |
| **`java-expert`** | [.agents/skills/java-expert/SKILL.md](.agents/skills/java-expert/SKILL.md) | **Java Development Expert** — Implements Java 21 LTS code (`record`, `sealed`, virtual threads), Gradle 9 Groovy DSL (`build.gradle` — no Kotlin), `gradle/libs.versions.toml`, and JUnit 5 + AssertJ tests |
| **`java-architect`** | [.agents/skills/java-architect/SKILL.md](.agents/skills/java-architect/SKILL.md) | **Java Architect** — Designs clean/hexagonal package boundaries (`config`, `domain`, `service`), DDD models, and OpenSpec `design.md` |
| **`openspec-reviewer`** | [.agents/skills/openspec-reviewer/SKILL.md](.agents/skills/openspec-reviewer/SKILL.md) | **Spec & Design Reviewer** — Enforces pre-implementation review gates across `proposal.md`, `specs/`, `design.md`, and `tasks.md` |
| **`code-review-expert`** | [.agents/skills/code-review-expert/SKILL.md](.agents/skills/code-review-expert/SKILL.md) | **Code Review Expert** — Audits implementation against OpenSpec scenarios, layer purity, Java 21/Gradle hygiene, and JUnit 5 coverage before archive/merge |
| **`readme-generator`** | [.agents/skills/readme-generator/SKILL.md](.agents/skills/readme-generator/SKILL.md) | **README Generator & Documenter** — Zero-hallucination scanning to keep `README.md` and `package-info.java` files accurate |
| **`git-workflow-manager`** | [.agents/skills/git-workflow-manager/SKILL.md](.agents/skills/git-workflow-manager/SKILL.md) | **Git Workflow Manager** — Manages feature branches, Conventional Commits linked to OpenSpec changes, and pre-commit verification |
| **`cicd-expert`** | [.agents/skills/cicd-expert/SKILL.md](.agents/skills/cicd-expert/SKILL.md) | **CI/CD Expert** — Designs and optimizes reproducible Java 21 + Gradle 9 build/test pipelines and caching |
