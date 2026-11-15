# Project Agent Guidelines & Personas (`java-test`)

This repository uses **Fission-AI/OpenSpec** ([openspec/config.yaml](openspec/config.yaml) & [openspec/project.md](openspec/project.md)) along with 12 unified, single-file software engineering skills stored in `.agents/skills/<name>/SKILL.md`.

> **Format & Customizing Skills in This Repo ("Copy In, Don't Link Out")**: Every skill merges its upstream references directly into a single self-contained `<name>/SKILL.md` file formatted per the vendored Agent Skills specification ([.agents/spec/specification.md](.agents/spec/specification.md) and [.agents/spec/best-practices.md](.agents/spec/best-practices.md)). You can freely modify any skill inside this repository (`repo-init` will not overwrite existing files unless `--force` is passed).

---

## Strict Role Separation: Spec-Driven Design $\rightarrow$ Red-Green TDD $\rightarrow$ Reviewer-Suggested Refactor

1. **Designers, Spec Builders & Spec Reviewers NEVER Write Code (`first-principles-thinking`, `spec-builder`, `system-design`, `java-architect`, `openspec-reviewer`)**:
   - Produce and validate `proposal.md`, `review.md`, `specs/`, `GLOSSARY.md`, `docs/adr/`, `design.md` (with **Confirmed Test Seams**), and `tasks.md`.
2. **Developer Runs the Red $\rightarrow$ Green Loop & Applies Refactorings (`java-expert` + `test-driven-development` + `systematic-debugging`)**:
   - Executes vertical tracer-bullet slices at pre-agreed seams (`RED` $\rightarrow$ `Verify RED` $\rightarrow$ `GREEN` $\rightarrow$ `Verify GREEN + Mutation Check`) and implements refactoring recommendations fed back by `code-review-expert`.
3. **Code Reviewer NEVER Writes Code (`code-review-expert`)**:
   - Performs a strictly read-only **Two-Axis Audit** (**Axis 1: Spec & Agreed Seam Compliance**; **Axis 2: Standards, Security, TDD Honesty, 12-Item Fowler Code Smell Baseline & Tech-Debt Priority**) and feeds concrete refactoring tasks back to `java-expert`.

---

## Installed Software Engineering Tool Set (`.agents/skills/`)

| Name (`name`) | Unified Skill File | Role & Code-Writing Boundary |
| :--- | :--- | :--- |
| **`first-principles-thinking`** | [.agents/skills/first-principles-thinking/SKILL.md](.agents/skills/first-principles-thinking/SKILL.md) | **First-Principles Thinking & Brainstorming (No-Code Role)** — Challenges assumptions, isolates fundamental truths, and runs SCAMPER/OODA/First-Principles decomposition |
| **`spec-builder`** | [.agents/skills/spec-builder/SKILL.md](.agents/skills/spec-builder/SKILL.md) | **Specification & Plan Builder (No-Code Role)** — Interviews on the design tree, sketches **Seams before prose**, and authors `proposal.md`, `specs/<capability>/spec.md`, and vertical tracer-bullet `tasks.md` |
| **`system-design`** | [.agents/skills/system-design/SKILL.md](.agents/skills/system-design/SKILL.md) | **System & Software Designer (No-Code Role)** — 5-phase system design, deep-module vocabulary (`codebase-design`), `GLOSSARY.md` & ADR (`docs/adr/`) authoring, and `design.md` creation |
| **`java-architect`** | [.agents/skills/java-architect/SKILL.md](.agents/skills/java-architect/SKILL.md) | **Java Architect & Deep-Module Designer (No-Code Role)** — Designs clean/hexagonal package boundaries (`config`, `domain`, `service`), deep module interfaces, and **Confirmed Test Seams** in `design.md` |
| **`openspec-reviewer`** | [.agents/skills/openspec-reviewer/SKILL.md](.agents/skills/openspec-reviewer/SKILL.md) | **Spec & Design Reviewer (No-Code Role)** — Enforces pre-implementation `review.md` gates (`OPTIMAL` / `IMPROVABLE` / `RETHINK`), seam definitions, and vertical-slice `tasks.md` |
| **`test-driven-development`** | [.agents/skills/test-driven-development/SKILL.md](.agents/skills/test-driven-development/SKILL.md) | **TDD Discipline** — Enforces the Iron Law (`NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST`), pre-agreed test seams, vertical Red $\rightarrow$ Green tracer-bullet slices, Gate Functions 1 & 2, and Mutation Checks |
| **`java-expert`** | [.agents/skills/java-expert/SKILL.md](.agents/skills/java-expert/SKILL.md) | **Java Development Expert (Sole Code Author)** — Executes the Red $\rightarrow$ Green loop in Java 21 LTS, Gradle 9 Groovy DSL, `gradle/libs.versions.toml`, and JUnit 5 + AssertJ, and applies refactorings suggested by `code-review-expert` |
| **`code-review-expert`** | [.agents/skills/code-review-expert/SKILL.md](.agents/skills/code-review-expert/SKILL.md) | **Code Review, Refactoring & Tech-Debt Advisor (No-Code Role)** — Read-only Two-Axis Audit (Spec/Seams + Standards/Fowler Smells/Tech Debt) that feeds concrete refactoring instructions back to `java-expert` |
| **`systematic-debugging`** | [.agents/skills/systematic-debugging/SKILL.md](.agents/skills/systematic-debugging/SKILL.md) | **Systematic Debugging & Incident Diagnosis** — Tight red-capable feedback loops, backward call-stack root-cause tracing, 4-layer defense-in-depth validation, and SEV1–4 postmortems |
| **`readme-generator`** | [.agents/skills/readme-generator/SKILL.md](.agents/skills/readme-generator/SKILL.md) | **README & Technical Documentation Generator** — Zero-hallucination scanning to keep `README.md`, `package-info.java`, runbooks, and onboarding guides accurate |
| **`git-workflow-manager`** | [.agents/skills/git-workflow-manager/SKILL.md](.agents/skills/git-workflow-manager/SKILL.md) | **Git Workflow Manager** — Manages feature branches, Conventional Commits linked to OpenSpec changes, and pre-commit verification |
| **`cicd-expert`** | [.agents/skills/cicd-expert/SKILL.md](.agents/skills/cicd-expert/SKILL.md) | **CI/CD & Deployment Readiness Expert** — Designs and optimizes reproducible Java 21 + Gradle 9 build/test pipelines, caching, and pre/post-deploy rollback checklists |
