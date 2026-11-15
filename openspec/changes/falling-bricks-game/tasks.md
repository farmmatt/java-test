# Vertical-Slice TDD Implementation Plan (`tasks.md`): Falling Bricks Console Game

- **Change ID**: `falling-bricks-game`
- **Status**: **HOLD FOR USER REVIEW (Zero Production or Test Code Written Yet)**
- **Goal**: Build a clean, state-tested Falling Bricks console application in Java 21 (`com.example.app`) with total input validation, immutable domain records with defensive copying, simultaneous orthogonal 3+ match clearing with gravity cascades, and real-component integration tests.
- **Spec**: [proposal.md](proposal.md) & [specs/falling-bricks/spec.md](specs/falling-bricks/spec.md)
- **Design & Seams**: [design.md](design.md) & [ADR-0001 Decision Matrix](../../../docs/adr/0001-falling-bricks-architecture-and-decision-matrix.md)
- **Glossary**: [GLOSSARY.md](../../../GLOSSARY.md)

---

## Global Constraints
- **Language & Build**: Java 21 LTS (`Eclipse Temurin 21`), Gradle 9.0.0 Groovy DSL (`build.gradle`, `settings.gradle`, `gradle/libs.versions.toml` — zero Kotlin), `-Xlint:all -parameters` (zero compiler warnings).
- **Testing Stack**: JUnit 5 (`org.junit.jupiter`) + AssertJ (`org.assertj.core.api.Assertions.assertThat`).
- **Role Boundaries**:
  - `java-expert` + `test-driven-development` is the sole code author during execution.
  - `code-review-expert` runs a strictly read-only Two-Axis Review and feeds refactoring instructions back to `java-expert`.
- **Testing Rules**:
  - Test **actual domain/service state** (`GameStateSnapshot`, `ValidationResult`), **never** console output strings.
  - Test only at the **3 Pre-Agreed Test Seams** (`FallingBricksEngine`, `GameInputParser`, `GameSessionService`).
  - Include integration tests running all real components wired together without mocks.

---

## Review Focus (5 High-Risk Input Classes & Edge Cases Pinned Across Tasks)
1. **Null, Empty & Whitespace-Only Inputs** $\rightarrow$ Pinned in **Task 1** & **Task 2** (`ValidationErrorCode.EMPTY_INPUT`).
2. **Malformed Bricks, Invalid Symbols/Orientations & Defensive Copying** $\rightarrow$ Pinned in **Task 1** (`INVALID_BRICK_LENGTH`, `INVALID_SYMBOL`, `INVALID_ORIENTATION`, `List.copyOf` immutability).
3. **Undersized (`< 3x3`) & Oversized (`> 20x30`) Grid Dimensions** $\rightarrow$ Pinned in **Task 1** (`GRID_DIMENSIONS_OUT_OF_BOUNDS`).
4. **Out-of-Bounds Moves, Wall-Blocked Orientation Toggles & Dodgy Commands** $\rightarrow$ Pinned in **Task 2** (`OUT_OF_BOUNDS_MOVE`, `INVALID_COMMAND`, state preserved unchanged).
5. **Uneven Horizontal Drops, Intersecting L/T Matches, Multi-Wave Gravity Cascades & Grid Overflow (`GAME_OVER`)** $\rightarrow$ Pinned in **Task 3**, **Task 4**, and **Task 5**.

---

## Vertical Tracer-Bullet Slices

### Task 1: Grid Dimensions, Immutable 3-Block Bricks & Input Validation (`P0`)
- **Blocked by**: None (Frontier Ready)
- **Demoable Behavior**: Validating grid sizes (`3..20 x 3..30`), allowed symbols, and horizontal/vertical 3-block bricks via `GameInputParser` and immutable domain records with full defensive copying (`Scenario 1.1–1.3`, `Scenario 2.1–2.3`).
- **Pre-Agreed Seam**: **Seam 2** (`com.example.app.service.GameInputParser`) & **Seam 1** (`GridDimensions`, `AllowedSymbolSet`, `Block`, `Brick` value records).
- **Files**:
  - Create:
    - `src/main/java/com/example/app/domain/ValidationErrorCode.java`
    - `src/main/java/com/example/app/domain/GridDimensions.java`
    - `src/main/java/com/example/app/domain/AllowedSymbolSet.java`
    - `src/main/java/com/example/app/domain/Block.java`
    - `src/main/java/com/example/app/domain/Orientation.java`
    - `src/main/java/com/example/app/domain/Brick.java`
    - `src/main/java/com/example/app/service/ValidationResult.java`
    - `src/main/java/com/example/app/service/GameInputParser.java`
  - Test:
    - `src/test/java/com/example/app/service/GameInputParserTest.java`
- **Interfaces**:
  - *Consumes*: None (foundation slice)
  - *Produces*:
    - `ValidationResult<GridDimensions> GameInputParser.parseDimensions(String raw)`
    - `ValidationResult<Brick> GameInputParser.parseBrick(String raw, AllowedSymbolSet allowedSymbols)`
    - `ValidationResult<List<Brick>> GameInputParser.parseBrickLines(List<String> lines, AllowedSymbolSet allowedSymbols)`

- [ ] **Step 1 (RED)**: Write failing JUnit 5 + AssertJ tests in `GameInputParserTest` covering valid `6x8` dimensions, undersized (`2x8`, `0x5`, `-3x6`) and oversized (`25x40`) rejection (`GRID_DIMENSIONS_OUT_OF_BOUNDS`), valid horizontal/vertical bricks (`"@#* H"`, `"$$% V"`), empty/null/blank rejection (`EMPTY_INPUT`), wrong block count (`"@@ H"`, `"@@@@ V"` $\rightarrow$ `INVALID_BRICK_LENGTH`), invalid symbols (`"@ ~ H"` $\rightarrow$ `INVALID_SYMBOL`), invalid orientation (`"@#* DIAG"` $\rightarrow$ `INVALID_ORIENTATION`), and defensive copying of `Brick.blocks()` and `AllowedSymbolSet.symbols()`.
- [ ] **Step 2 (Verify RED)**: Run `./gradlew test --tests "com.example.app.service.GameInputParserTest"` and verify failure.
- [ ] **Step 3 (GREEN)**: Implement the minimal immutable Java 21 records and `GameInputParser` to pass all assertions.
- [ ] **Step 4 (Verify GREEN + Mutation Check)**: Run `./gradlew check --build-cache --parallel` (0 warnings, 0 failures) and verify mutating bounds or `List.copyOf` breaks the tests.

---

### Task 2: Active Brick Spawning, Command Parsing & Boundary-Safe Movement (`P0`)
- **Blocked by**: Task 1
- **Demoable Behavior**: Spawning the active brick at the top-center of an empty grid and executing `MOVE_LEFT` (`L`), `MOVE_RIGHT` (`R`), `ORIENT` (`O`), `CYCLE` (`C`), and `QUIT` (`Q`), while catching dodgy commands (`INVALID_COMMAND`) and out-of-bounds moves/orientations (`OUT_OF_BOUNDS_MOVE`) without corrupting `GameStateSnapshot` (`Scenario 3.1–3.3`).
- **Pre-Agreed Seam**: **Seam 1** (`FallingBricksEngine#execute`, `FallingBricksEngine#snapshot`) & **Seam 2** (`GameInputParser#parseCommandLine`).
- **Files**:
  - Create:
    - `src/main/java/com/example/app/domain/Command.java`
    - `src/main/java/com/example/app/domain/GameStatus.java`
    - `src/main/java/com/example/app/domain/StepOutcome.java`
    - `src/main/java/com/example/app/domain/ActiveBrick.java`
    - `src/main/java/com/example/app/domain/Position.java`
    - `src/main/java/com/example/app/domain/GameStateSnapshot.java`
    - `src/main/java/com/example/app/domain/FallingBricksEngine.java`
  - Modify:
    - `src/main/java/com/example/app/service/GameInputParser.java`
  - Test:
    - `src/test/java/com/example/app/domain/ActiveBrickMovementTest.java`
- **Interfaces**:
  - *Consumes*: `GridDimensions`, `Brick`, `Block`, `Orientation`, `ValidationResult` from Task 1
  - *Produces*:
    - `ValidationResult<List<Command>> GameInputParser.parseCommandLine(String rawLine)`
    - `GameStateSnapshot FallingBricksEngine.snapshot()`
    - `GameStateSnapshot FallingBricksEngine.execute(Command command)`

- [ ] **Step 1 (RED)**: Write failing tests in `ActiveBrickMovementTest` verifying top-center spawn (`col = (width - span)/2`), `L`/`R` movement within bounds, `CYCLE` shifting `[b0, b1, b2] -> [b2, b0, b1]`, `ORIENT` toggling `HORIZONTAL <-> VERTICAL`, rejection of `MOVE_LEFT` at `col 0`, rejection of `MOVE_RIGHT` at right wall, rejection of `ORIENT` (`V -> H`) at `col >= width - 2` (`StepOutcome.REJECTED` + `OUT_OF_BOUNDS_MOVE`), deep defensive copying of `GameStateSnapshot.cells()`, and `parseCommandLine` rejecting empty/unknown commands (`""`, `"JUMP"`).
- [ ] **Step 2 (Verify RED)**: Run `./gradlew test --tests "com.example.app.domain.ActiveBrickMovementTest"` and verify failure.
- [ ] **Step 3 (GREEN)**: Implement `Command`, `ActiveBrick`, `GameStateSnapshot`, `FallingBricksEngine` (spawn + movement + quit), and `GameInputParser.parseCommandLine`.
- [ ] **Step 4 (Verify GREEN + Mutation Check)**: Run `./gradlew check --build-cache --parallel` and confirm 100% green and zero warnings.

---

### Task 3: Horizontal & Vertical Drop Physics, Queue Progression & Overflow (`GAME_OVER` / `COMPLETED`) (`P0`)
- **Blocked by**: Task 2
- **Demoable Behavior**: Dropping `VERTICAL` ($3 \times 1$) and `HORIZONTAL` ($1 \times 3$) bricks onto empty and uneven columns (`Scenario 4.1–4.2`), advancing through the brick queue to `GameStatus.COMPLETED` (`Scenario 6.1`), and detecting column overflow to `GameStatus.GAME_OVER` (`Scenario 6.2`).
- **Pre-Agreed Seam**: **Seam 1** (`FallingBricksEngine#execute(Command.DROP)`).
- **Files**:
  - Modify:
    - `src/main/java/com/example/app/domain/FallingBricksEngine.java`
  - Test:
    - `src/test/java/com/example/app/domain/BrickDropPhysicsTest.java`
- **Interfaces**:
  - *Consumes*: `FallingBricksEngine`, `GameStateSnapshot`, `Command.DROP` from Task 2
  - *Produces*: Complete drop placement, queue progression, `COMPLETED` and `GAME_OVER` state transitions on `GameStateSnapshot`.

- [ ] **Step 1 (RED)**: Write failing tests in `BrickDropPhysicsTest` asserting exact `snapshot().cellAt(row, col)` state after dropping vertical bricks, dropping horizontal bricks across uneven columns (per-block column gravity), completing a multi-brick queue (`status() == COMPLETED`, `remainingBricks() == 0`), and overflowing a column (`status() == GAME_OVER`, subsequent commands rejected with `GAME_ALREADY_FINISHED`).
- [ ] **Step 2 (Verify RED)**: Run `./gradlew test --tests "com.example.app.domain.BrickDropPhysicsTest"` and verify failure.
- [ ] **Step 3 (GREEN)**: Implement vertical and horizontal drop placement, overflow detection, and next-brick spawning in `FallingBricksEngine`.
- [ ] **Step 4 (Verify GREEN + Mutation Check)**: Run `./gradlew check --build-cache --parallel` and confirm 0 failures.

---

### Task 4: Simultaneous Orthogonal Match Clearing, Scoring & Multi-Wave Gravity Cascades (`P0`)
- **Blocked by**: Task 3
- **Demoable Behavior**: Detecting and clearing all horizontal and vertical runs of $\ge 3$ identical symbols simultaneously (including 4-in-a-row and intersecting L/T shapes), dropping unsupported blocks under column gravity, and resolving multi-wave chain-reaction `Cascade`s with wave-multiplied scoring (`Scenario 5.1–5.2`).
- **Pre-Agreed Seam**: **Seam 1** (`FallingBricksEngine#execute(Command.DROP)`).
- **Files**:
  - Create:
    - `src/main/java/com/example/app/domain/MatchDetector.java` (package-private helper inside `domain` deep module)
  - Modify:
    - `src/main/java/com/example/app/domain/FallingBricksEngine.java`
  - Test:
    - `src/test/java/com/example/app/domain/MatchAndCascadeTest.java`
- **Interfaces**:
  - *Consumes*: `FallingBricksEngine` drop placement from Task 3
  - *Produces*: Populated `matchesCleared()`, `blocksCleared()`, `lastCascadeWaves()`, and `score()` on `GameStateSnapshot`.

- [ ] **Step 1 (RED)**: Write failing tests in `MatchAndCascadeTest` asserting exact grid state and counters for:
  1. Horizontal 3-of-a-kind clear (`300` points, `1` match, `3` blocks cleared).
  2. Vertical 3-of-a-kind and 4-of-a-kind clear.
  3. Simultaneous L-shape / T-shape intersecting horizontal + vertical matches (both runs cleared together, shared corner counted once in `blocksCleared`).
  4. Multi-wave gravity cascade where clearing wave 1 drops blocks into a new 3-of-a-kind in wave 2 (`lastCascadeWaves() == 2`, wave 2 scored with $2\times$ multiplier).
- [ ] **Step 2 (Verify RED)**: Run `./gradlew test --tests "com.example.app.domain.MatchAndCascadeTest"` and verify failure.
- [ ] **Step 3 (GREEN)**: Implement simultaneous orthogonal mark-and-sweep, column gravity compaction, and the cascade loop inside `domain`.
- [ ] **Step 4 (Verify GREEN + Mutation Check)**: Run `./gradlew check --build-cache --parallel` and confirm 0 failures.

---

### Task 5: Clean Architecture Ports, Constructor DI (`AppConfig`), CLI & Real-Component Integration Tests (`P0`)
- **Blocked by**: Task 4
- **Demoable Behavior**: Running complete multi-brick game sessions through `GameSessionService` and `AppConfig` with real components wired together (real `GameInputParser` + real `FallingBricksEngine` + stream/in-memory adapters for `BrickSource`, `CommandSource`, and `GameRenderer`), including graceful recovery from invalid command inputs mid-session and clean `App` entrypoint execution.
- **Pre-Agreed Seam**: **Seam 3** (`com.example.app.service.GameSessionService#runSession` & `com.example.app.config.AppConfig`).
- **Files**:
  - Create:
    - `src/main/java/com/example/app/service/BrickSource.java`
    - `src/main/java/com/example/app/service/CommandSource.java`
    - `src/main/java/com/example/app/service/GameRenderer.java`
    - `src/main/java/com/example/app/service/GameSessionService.java`
    - `src/main/java/com/example/app/config/AppConfig.java`
    - `src/main/java/com/example/app/config/ConsoleGameRenderer.java`
  - Modify:
    - `src/main/java/com/example/app/App.java`
    - `src/test/java/com/example/app/AppTest.java`
  - Test:
    - `src/test/java/com/example/app/service/GameSessionIntegrationTest.java`
- **Interfaces**:
  - *Consumes*: `FallingBricksEngine`, `GameInputParser`, `ValidationResult` from Tasks 1–4
  - *Produces*:
    - `ValidationResult<GameStateSnapshot> GameSessionService.runSession()`
    - `GameSessionService AppConfig.createSessionService(GridDimensions, BrickSource, CommandSource, GameRenderer)`

- [ ] **Step 1 (RED)**: Write failing integration tests in `GameSessionIntegrationTest` running all real components together (zero mocks) across:
  1. A full winning game session placing all bricks, clearing matches/cascades, and finishing in `GameStatus.COMPLETED`.
  2. A session containing dodgy commands and out-of-bounds moves mid-game that reports the errors via `GameRenderer#renderError`, preserves the board state, and completes the remaining valid commands.
  3. A session with invalid initial brick definitions returning `ValidationResult.Invalid` before engine start.
  4. `AppTest` verifying `App` wiring and non-interactive/stream execution without hardcoded file paths.
- [ ] **Step 2 (Verify RED)**: Run `./gradlew test --tests "com.example.app.service.GameSessionIntegrationTest"` and verify failure.
- [ ] **Step 3 (GREEN)**: Implement `BrickSource`, `CommandSource`, `GameRenderer`, `GameSessionService`, `AppConfig`, `ConsoleGameRenderer`, and `App`.
- [ ] **Step 4 (Verify GREEN + Mutation Check)**: Run `./gradlew check --build-cache --parallel` and confirm 100% green and zero warnings.

---

### Task 6: Two-Axis Code Review (`code-review-expert`), Developer Refactoring (`java-expert`) & Documentation Sync (`readme-generator`) (`P0`)
- **Blocked by**: Task 5
- **Demoable Behavior**: Read-only Two-Axis Review report auditing Spec/Seam compliance and the 12 Fowler code smells, execution of all recommended refactorings by `java-expert`, updated `package-info.java` and `README.md`, and clean Git commit/push via `git-workflow-manager`.
- [ ] **Step 1**: Run `code-review-expert` (strictly read-only) against `git diff` and `openspec/changes/falling-bricks-game/`.
- [ ] **Step 2**: Feed any refactoring or smell recommendations back to `java-expert` and re-verify with `./gradlew check --build-cache --parallel --no-daemon`.
- [ ] **Step 3**: Run `readme-generator` to document the Falling Bricks architecture, commands, validation rules, and sample session in `README.md` and `package-info.java`.
- [ ] **Step 4**: Commit and push via `git-workflow-manager`.
