<!-- STRICT WORKFLOW RULES:
1. No Horizontal Slicing: Never separate "write all code" from "write all tests". Every slice is a vertical Red -> Green tracer bullet at a Confirmed Test Seam from design.md.
2. Role Separation:
   - Designer (java-architect / openspec-reviewer) NEVER writes code.
   - Developer (java-expert + test-driven-development) executes the Red -> Green vertical slices and applies refactorings recommended by code-review-expert.
   - Code Reviewer (code-review-expert) NEVER writes or edits code; it performs the Two-Axis Review and feeds refactoring recommendations back to java-expert.
-->

## 1. Vertical Slice 1: <!-- Capability / Scenario Name at Confirmed Seam -->

- [ ] 1.1 **RED (`java-expert` + `test-driven-development`)**: Pass Gate Function 1 (Name the Break) and write one failing JUnit 5 + AssertJ test at the confirmed seam using independent literal expected values from `specs/`.
- [ ] 1.2 **Verify RED (`java-expert`)**: Run `./gradlew test --tests <TestClass> --build-cache --parallel` and confirm the test fails for the expected reason.
- [ ] 1.3 **GREEN (`java-expert`)**: Write the minimal Java 21 production code (`domain/`, `service/`, `config/`) required to make the failing test pass (no speculative generality / YAGNI).
- [ ] 1.4 **Verify GREEN + Mutation Check (`java-expert`)**: Run `./gradlew check --build-cache --parallel`, confirm 100% green suite and zero `-Xlint:all` warnings, and verify realistic code mutations fail at least one test.

## 2. Vertical Slice 2: <!-- Next Scenario / Edge Case at Confirmed Seam -->

- [ ] 2.1 **RED (`java-expert` + `test-driven-development`)**: Write the next failing JUnit 5 + AssertJ test at the confirmed seam.
- [ ] 2.2 **Verify RED (`java-expert`)**: Watch the test fail via `./gradlew test --tests <TestClass> --build-cache --parallel`.
- [ ] 2.3 **GREEN (`java-expert`)**: Write minimal production code to pass the test.
- [ ] 2.4 **Verify GREEN + Mutation Check (`java-expert`)**: Run `./gradlew check --build-cache --parallel` and perform the Mutation Check.

## 3. Two-Axis Code Review, Reviewer-Suggested Refactoring & Delivery

- [ ] 3.1 **Two-Axis Read-Only Audit (`code-review-expert` — NEVER writes code)**: Audit `git diff` across **Axis 1 (Spec & Pre-Agreed Seam Compliance)** and **Axis 2 (Standards, Security, TDD Honesty & 12-Item Fowler Code Smell Baseline)**, producing concrete Refactoring & Fix Recommendations for `java-expert`.
- [ ] 3.2 **Developer Refactoring Execution (`java-expert`)**: Apply all refactoring and fix recommendations from `code-review-expert` while keeping `./gradlew check --build-cache --parallel` 100% green with zero warnings.
- [ ] 3.3 **Documentation Sync (`readme-generator`)**: Update `README.md` and `package-info.java` to reflect exact repository reality.
- [ ] 3.4 **Commit & Push (`git-workflow-manager`)**: Verify clean working tree and commit using Conventional Commits linked to this OpenSpec change.
