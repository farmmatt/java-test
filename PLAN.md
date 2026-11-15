# Dotfiles Repository Plan: Java 21, Gradle 9 (Groovy DSL + TOML), JUnit 5, AgentSkills.io Personas & Fission-AI/OpenSpec

This document captures the implementation plan for the workspace `dotfiles` repository (`https://github.com/farmmatt/Coder-Dotfiles`) and the spec-driven build setup for `https://github.com/farmmatt/java-test`.

---

## 1. Mandatory Agent-Agnostic Standard: AgentSkills.io (`SKILL.md`)

All 7 personas/skills follow the open [**agentskills.io**](https://agentskills.io/home) specification (`<skill-name>/SKILL.md` with YAML frontmatter: `name`, `description`, `license`, `compatibility`, `metadata`):
- **Installed as Global Workspace Defaults**: `install.sh` installs all default skills into `~/.gemini/config/skills/<skill-name>/SKILL.md` and `~/.config/workspace-dotfiles/templates/`.
- **Copied into Build Repos for Local Modification**: `gw-init` / `repo-init` copies each skill into `.agents/skills/<skill-name>/SKILL.md` inside the target build repo. If a build repo modifies its `.agents/skills/<skill-name>/SKILL.md`, `repo-init` preserves those repo-local changes (and project-level `.agents/skills/` automatically take precedence over global defaults).

| # | Skill Name (`name`) | Template Path | Role & Inspiration |
| :--- | :--- | :--- | :--- |
| **1** | `java-expert` | `templates/languages/java/skills/java-expert/SKILL.md` | **Java Development Expert** (`proflead/claude-code-agent-library`): Java 21 LTS (`record`, `sealed`, virtual threads), Gradle 9 Groovy DSL (`build.gradle` — no Kotlin), `gradle/libs.versions.toml`, SLF4J/Logback, JUnit 5 + AssertJ |
| **1.1** | `java-architect` | `templates/languages/java/skills/java-architect/SKILL.md` | **Java Architect** (`VoltAgent/awesome-claude-code-subagents`): Clean/hexagonal layering (`config`, `domain`, `service`), DDD boundaries, concurrency/resilience, and OpenSpec `design.md` |
| **2** | `code-review-expert` | `templates/common/skills/code-review-expert/SKILL.md` | **Code Review Expert**: 5-pillar post-implementation audit (OpenSpec scenario matrix, `domain/` purity, Java 21 & Gradle/TOML hygiene, JUnit 5 edge-case coverage, security) |
| **3** | `openspec-reviewer` | `templates/common/skills/openspec-reviewer/SKILL.md` | **Spec & Design Reviewer** (`griffithkk3-del/openspec-reviewed-workflow`): Pre-implementation review gates across `proposal.md` -> `specs/` -> `design.md` -> `tasks.md` |
| **4** | `readme-generator` | `templates/common/skills/readme-generator/SKILL.md` | **README Generator & Documenter** (`VoltAgent/awesome-claude-code-subagents`): Zero-hallucination scanning of `build.gradle`, `libs.versions.toml`, `openspec/`, and `src/` to maintain `README.md` and `package-info.java` |
| **5a** | `git-workflow-manager` | `templates/common/skills/git-workflow-manager/SKILL.md` | **Git Workflow Manager** (`VoltAgent/awesome-claude-code-subagents`): Feature branching, Conventional Commits linked to OpenSpec changes, and pre-commit verification gates |
| **5b** | `cicd-expert` | `templates/common/skills/cicd-expert/SKILL.md` | **CI/CD Expert** (`proflead/claude-code-agent-library`): Reproducible Java 21 + Gradle 9 pipelines, multi-layer Gradle caching, and JUnit 5 test reporting |

---

## 2. Default Initialized Java Repository Structure (`gw-init`)

```text
my-java-service/
├── .agents/
│   └── skills/                         # AgentSkills.io project skills (modifiable per build repo)
│       ├── java-expert/SKILL.md
│       ├── java-architect/SKILL.md
│       ├── code-review-expert/SKILL.md
│       ├── openspec-reviewer/SKILL.md
│       ├── readme-generator/SKILL.md
│       ├── git-workflow-manager/SKILL.md
│       └── cicd-expert/SKILL.md
├── gradle/
│   ├── libs.versions.toml              # Centralized versions (JUnit Jupiter, AssertJ, SLF4J, Logback)
│   └── wrapper/                        # Gradle wrapper binaries & properties
├── openspec/
│   ├── config.yaml                     # OpenSpec profile, skill gates, & project context
│   ├── project.md                      # Single source of truth: tech stack, skills, architecture rules
│   ├── specs/
│   │   └── core/
│   │       └── spec.md                 # Baseline spec describing entrypoint & startup behavior
│   └── changes/                        # Active feature proposals, designs, & tasks
├── src/
│   ├── main/
│   │   ├── java/com/example/app/
│   │   │   ├── App.java                # Application entry point
│   │   │   ├── config/package-info.java
│   │   │   ├── domain/package-info.java
│   │   │   └── service/package-info.java
│   │   └── resources/
│   │       └── application.properties
│   └── test/
│       ├── java/com/example/app/
│       │   └── AppTest.java            # JUnit 5 + AssertJ unit tests
│       └── resources/
├── AGENTS.md                           # Project-level rules wiring OpenSpec & .agents/skills/
├── .gitignore
├── build.gradle                        # Groovy DSL build config (Java 21 toolchain, -Xlint:all, JUnit 5)
├── gradle.properties                   # Multi-core parallel & local build cache settings
├── gradlew                             # Unix Gradle wrapper script
├── gradlew.bat                         # Windows Gradle wrapper script
└── settings.gradle                     # Root project name, local build cache & module includes (Groovy DSL)
```
