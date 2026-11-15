# Project Agent Guidelines & AgentSkills.io Personas (`java-test`)

This repository uses **Fission-AI/OpenSpec** (`openspec/config.yaml` & `openspec/project.md`) and agent-agnostic **AgentSkills.io (`https://agentskills.io`)** skills stored in `.agents/skills/<skill-name>/SKILL.md`.

> **Customizing Skills in This Repo**: These skills were seeded from the workspace `dotfiles` defaults and committed directly into `.agents/skills/`. You can freely modify any `.agents/skills/<skill-name>/SKILL.md` file in this repository to tailor its rules to this project; workspace-level `.agents/skills/` automatically override global dotfiles defaults.

---

## Installed Project Skills & Personas (`.agents/skills/`)

| Skill Name (`name`) | Path | Role & Activation Stage |
| :--- | :--- | :--- |
| **`java-expert`** | [.agents/skills/java-expert/SKILL.md](.agents/skills/java-expert/SKILL.md) | **Java Development Expert** — Implements Java 21 LTS code (`record`, `sealed`, virtual threads), Gradle 9 Groovy DSL (`build.gradle` — no Kotlin), `gradle/libs.versions.toml`, and JUnit 5 + AssertJ tests |
| **`java-architect`** | [.agents/skills/java-architect/SKILL.md](.agents/skills/java-architect/SKILL.md) | **Java Architect** — Designs clean/hexagonal package boundaries (`config`, `domain`, `service`), DDD models, and OpenSpec `design.md` |
| **`openspec-reviewer`** | [.agents/skills/openspec-reviewer/SKILL.md](.agents/skills/openspec-reviewer/SKILL.md) | **Spec & Design Reviewer** — Enforces pre-implementation review gates across `proposal.md`, `specs/`, `design.md`, and `tasks.md` |
| **`code-review-expert`** | [.agents/skills/code-review-expert/SKILL.md](.agents/skills/code-review-expert/SKILL.md) | **Code Review Expert** — Audits implementation against OpenSpec scenarios, layer purity, Java 21/Gradle hygiene, and JUnit 5 coverage before archive/merge |
| **`readme-generator`** | [.agents/skills/readme-generator/SKILL.md](.agents/skills/readme-generator/SKILL.md) | **README Generator & Documenter** — Zero-hallucination scanning to keep `README.md` and `package-info.java` files accurate |
| **`git-workflow-manager`** | [.agents/skills/git-workflow-manager/SKILL.md](.agents/skills/git-workflow-manager/SKILL.md) | **Git Workflow Manager** — Manages feature branches, Conventional Commits linked to OpenSpec changes, and pre-commit verification |
| **`cicd-expert`** | [.agents/skills/cicd-expert/SKILL.md](.agents/skills/cicd-expert/SKILL.md) | **CI/CD Expert** — Designs and optimizes reproducible Java 21 + Gradle 9 build/test pipelines and caching |
