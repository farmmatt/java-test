# Vertical-Slice TDD Implementation Plan: Falling Bricks Console Game (`falling-bricks-game`)

- **OpenSpec Change**: `falling-bricks-game`
- **Status**: **HOLDING FOR USER REVIEW** (Do NOT execute until approved by user)
- **Methodology**: Strict Vertical-Slice Red-Green-Refactor TDD (`test-driven-development` + `java-expert` + `code-review-expert`)
- **Build & Test Command**: `./gradlew test check` (Java 21, Gradle 9 Groovy DSL, JUnit 5, AssertJ, SLF4J + Logback)

---

## Execution Rules for Every Slice
1. **RED**: Write ONE failing JUnit 5 test at the pre-agreed seam asserting on **actual domain/service state** (`ValidationResult`, `Block`, `Brick`, `Grid`, `GameConfiguration`, `GameSnapshot`), never console output strings. Run `./gradlew test` and confirm it fails for the expected reason.
2. **GREEN**: Write the minimal Java 21 production code required to pass the failing test.
3. **REFACTOR**: Run `code-review-expert` two-axis review (Spec/Seam compliance + Fowler smells/immutability/defensive copies) and apply cleanups while keeping `./gradlew test` green.

---

## Slice 1: Build Setup (`SLF4J + Logback`), `ValidationResult` & Printable 7-Bit ASCII `Block` / `Brick` (`Q5` & Expansion Point 2 Seam)

- **Target Seam**: `com.fallingbricks.domain.ValidationResult`, `ValidationErrorCode`, `Block`, `Orientation`, `Position`, `Brick`
- **Spec Requirements Covered**: Requirement 2 (`Scenarios 2.1–2.4`), `DEC-02`, `DEC-03`, `DEC-10`, `DEC-13`
- **Red-Green-Refactor Cycle**:
  - [ ] **Task 1.1 (Build & Logging Config)**: Add `slf4j-api` and `logback-classic` to `gradle/libs.versions.toml` and `build.gradle`; add `src/main/resources/logback.xml` routing `DEBUG+` to `logs/falling-bricks.log` and `WARN+` to `STDERR` (keeping `STDOUT` pure for UI).
  - [ ] **Task 1.2 (RED $\rightarrow$ GREEN)**: In `BlockTest`, test that `Block.create('@')` through `Block.create('~')` (`0x21..0x7E`) succeed, while whitespace (`' '`, `'\t'`, `'\n'`), control chars (`'\0'`, `0x7F`), and non-ASCII chars (`'★'`, `'é'`) return `ValidationResult.Invalid(ValidationErrorCode.INVALID_SYMBOL)`.
  - [ ] **Task 1.3 (RED $\rightarrow$ GREEN)**: In `BrickTest`, test `Brick.create(blocks, orientation)` validates non-null orientation (`INVALID_ORIENTATION`), exact 3-block count (`INVALID_BRICK_SIZE`), and defensive copying (`List.copyOf` — mutating caller `ArrayList` or calling `brick.blocks().add(...)` cannot mutate `Brick`).
  - [ ] **Task 1.4 (RED $\rightarrow$ GREEN)**: In `BrickTest`, test `brick.toggleOrientation()`, `brick.cycleBlocks()` (`[A,B,C] -> [C,A,B]`), `widthSpan()`, `heightSpan()`, and `occupiedPositions(anchorCol, anchorRow)` for `HORIZONTAL` ($1 \times 3$) and `VERTICAL` ($3 \times 1$).
  - [ ] **Task 1.5 (REFACTOR)**: Review `Block` and `Brick` for immutability, zero public mutable fields, and zero dead code.

---

## Slice 2: `GameConfiguration` (`application.properties` + CLI Overrides + Overflow-Capable Brick Count Validation) (`Q1` & `Q5`)

- **Target Seam**: `com.fallingbricks.config.GameConfiguration`
- **Spec Requirements Covered**: Requirement 1 (`Scenarios 1.1–1.4`), Requirement 3 (`Scenario 3.2`), `DEC-04`, `DEC-05`, `DEC-09`, `DEC-11`
- **Red-Green-Refactor Cycle**:
  - [ ] **Task 2.1 (RED $\rightarrow$ GREEN)**: In `GameConfigurationTest`, test default configuration (`width=6`, `height=12`, `maxWidth=20`, `maxHeight=20`, `brickCount=15`, `tickIntervalMs=1000`, `symbols="@#$%&"`, `maxBrickSpan=3`) and loading overrides from an in-memory `InputStream` (`Properties`) and CLI `String[]` args (`--width`, `--height`, `--max-width`, `--max-height`, `--bricks`, `--seed`, `--tick-ms`, `--symbols`) with **zero hardcoded file paths**.
  - [ ] **Task 2.2 (RED $\rightarrow$ GREEN)**: In `GameConfigurationTest`, test grid bound validation:
    - Negative or zero width/height (`-1`, `0`) or `< maxBrickSpan (3)` (`1`, `2`) rejected with `ValidationErrorCode.GRID_TOO_SMALL`.
    - `width > maxWidth` or `height > maxHeight` (default `> 20`, or custom configured max) rejected with `ValidationErrorCode.GRID_TOO_LARGE`.
  - [ ] **Task 2.3 (RED $\rightarrow$ GREEN)**: In `GameConfigurationTest`, test overflow-capable `brickCount` validation (`Q1`): `brickCount` must be large enough to potentially overflow grid height (`brickCount * maxBrickSpan > height`, i.e., `brickCount >= (height / 3) + 1`). Verify `brickCount = 4` on `height = 12` fails with `ValidationErrorCode.INSUFFICIENT_BRICK_COUNT`, while `brickCount = 5` succeeds.
  - [ ] **Task 2.4 (REFACTOR)**: Add `src/main/resources/application.properties` with documented default values and verify `GameConfiguration` purity.

---

## Slice 3: Immutable `Grid` Value Object & Defensive State Snapshots (`Q5`)

- **Target Seam**: `com.fallingbricks.domain.Grid`
- **Spec Requirements Covered**: Requirement 1 (`Scenarios 1.1–1.5`), `DEC-01`, `DEC-09`
- **Red-Green-Refactor Cycle**:
  - [ ] **Task 3.1 (RED $\rightarrow$ GREEN)**: In `GridTest`, test `Grid.create(width, height, maxWidth, maxHeight)` enforcing `min >= 3` (`GRID_TOO_SMALL`), `max <= maxWidth/maxHeight` (`GRID_TOO_LARGE`), and empty cell initialization (`row = 0` floor to `row = height - 1` top).
  - [ ] **Task 3.2 (RED $\rightarrow$ GREEN)**: In `GridTest`, test `grid.cellsSnapshot()` and `grid.cellAt(col, row)` defensive copying — mutating the returned 2D array never alters internal `Grid` state.
  - [ ] **Task 3.3 (RED $\rightarrow$ GREEN)**: In `GridTest`, test `grid.canOccupy(brick, anchorCol, anchorRow)` for horizontal and vertical bricks across left/right/bottom/top boundaries and occupied cells.
  - [ ] **Task 3.4 (REFACTOR)**: Verify `Grid` has no mutable public fields and clean coordinate helpers.

---

## Slice 4: Rigid-Bar Drop Physics (`Q3`) & Vertical Overflow Detection (`Q5`)

- **Target Seam**: `com.fallingbricks.domain.Grid` (`computeRigidDropRow`, `lockRigidBrick`)
- **Spec Requirements Covered**: Requirement 4 (`Scenario 4.2`), Requirement 6 (`Scenario 6.1`), `DEC-07`, `DEC-09`
- **Red-Green-Refactor Cycle**:
  - [ ] **Task 4.1 (RED $\rightarrow$ GREEN)**: In `GridTest`, test dropping a `VERTICAL` ($3 \times 1$) brick into an empty column (`lands at rows 0..2`) and onto an existing stack (`lands at rows stackTop+1 .. stackTop+3`).
  - [ ] **Task 4.2 (RED $\rightarrow$ GREEN)**: In `GridTest`, test dropping a `HORIZONTAL` ($1 \times 3$) brick as a **rigid bar** (`Q3`) over uneven columns (e.g., `col 1` has height 3 at `row = 2`, while `cols 2 and 3` are empty $\rightarrow$ horizontal brick stops as a rigid bar at `row = 3` across `cols 1, 2, 3`, creating an overhanging bridge at `(2,3)` and `(3,3)`).
  - [ ] **Task 4.3 (RED $\rightarrow$ GREEN)**: In `GridTest`, test that attempting to lock or spawn a brick when any of its 3 blocks overlaps an occupied cell or exceeds `height - 1` returns `ValidationResult.Invalid(ValidationErrorCode.VERTICAL_OVERFLOW)`.
  - [ ] **Task 4.4 (REFACTOR)**: Review `Grid` rigid-bar drop methods for clarity and immutability.

---

## Slice 5: Horizontal Row Clearing / Matching & Individual-Block Gravity Cascade (`Q4`)

- **Target Seam**: `com.fallingbricks.domain.Grid` & `PlacementOutcome`
- **Spec Requirements Covered**: Requirement 5 (`Scenarios 5.1–5.2`), `DEC-08`
- **Red-Green-Refactor Cycle**:
  - [ ] **Task 5.1 (RED $\rightarrow$ GREEN)**: In `GridTest`, test full horizontal row clearing: when all `width` cells in `row = 0` are filled, `row = 0` clears completely (`rowsOrMatchesCleared = 1`).
  - [ ] **Task 5.2 (RED $\rightarrow$ GREEN)**: In `GridTest`, test **individual-block column gravity after row clear (`Q4`)**: verify that a previously locked horizontal brick `[@, #, $]` bridging across `(1,2), (2,2), (3,2)` loses its original brick shape once stacked — when support beneath `(1,2)` is cleared (or when `row = 0` clears), `#` at `(2,2)` and `$` at `(3,2)` drop all the way to the floor (`row = 0`) in their respective columns under independent gravity!
  - [ ] **Task 5.3 (RED $\rightarrow$ GREEN)**: In `GridTest`, test horizontal contiguous symbol match clearing (`>= 3` identical symbols horizontally in the same row) and multi-step chain cascades (`chainCount == 2`), verifying points calculation.
  - [ ] **Task 5.4 (REFACTOR)**: Ensure clear + gravity resolution is a pure, deterministic method returning an immutable `PlacementOutcome`.

---

## Slice 6: `SeededBrickGenerator` (`Random(seed)`, Random Top Spawn & Same-Seed Reset) (`Q1` & `Q2`)

- **Target Seam**: `com.fallingbricks.port.BrickGenerator`, `com.fallingbricks.service.SeededBrickGenerator`
- **Spec Requirements Covered**: Requirement 3 (`Scenarios 3.1–3.3`), `DEC-05`, `DEC-06`
- **Red-Green-Refactor Cycle**:
  - [ ] **Task 6.1 (RED $\rightarrow$ GREEN)**: In `SeededBrickGeneratorTest`, test that two `SeededBrickGenerator` instances with the same `seed` produce the exact same finite sequence of `SpawnedBrick(Brick, spawnCol)` items, where `0 <= spawnCol <= gridWidth - brick.widthSpan()`.
  - [ ] **Task 6.2 (RED $\rightarrow$ GREEN)**: In `SeededBrickGeneratorTest`, test that `resetWithSameSeed()` rewinds the generator to the exact same `seed` and reproduces the identical brick and spawn-column sequence (`Q1`).
  - [ ] **Task 6.3 (RED $\rightarrow$ GREEN)**: In `SeededBrickGeneratorTest`, test that `remainingCount()` decrements to `0` and `nextSpawnedBrick()` returns `Optional.empty()` once all `brickCount` bricks are consumed.
  - [ ] **Task 6.4 (REFACTOR)**: Review `SeededBrickGenerator` and `BrickGenerator` interface for clean separation (noting Future Expansion Point 1 in Javadoc).

---

## Slice 7: `TextCommandParser` & `FallingBricksEngine` (`TICK`, `DROP`, `RETRY`, `VERTICAL_OVERFLOW` & SLF4J Logging)

- **Target Seam**: `com.fallingbricks.ui.TextCommandParser`, `com.fallingbricks.service.FallingBricksEngine`
- **Spec Requirements Covered**: Requirement 3 (`Scenario 3.3`), Requirement 4 (`Scenarios 4.1–4.3`), Requirement 6 (`Scenarios 6.1–6.2`)
- **Red-Green-Refactor Cycle**:
  - [ ] **Task 7.1 (RED $\rightarrow$ GREEN)**: In `TextCommandParserTest`, test parsing valid commands (`L`/`LEFT`, `R`/`RIGHT`, `O`/`ORIENT`, `C`/`CYCLE`, `D`/`DROP`, `T`/`TICK`, `RETRY`, `N`/`NEW`, `Q`/`QUIT` case-insensitively) and rejecting `null`, `""`, `"   "` (`EMPTY_INPUT`) and dodgy inputs (`"JUMP"`, `"123"`, `"L R"`) (`UNKNOWN_COMMAND`).
  - [ ] **Task 7.2 (RED $\rightarrow$ GREEN)**: In `FallingBricksEngineTest`, test random top-row spawn (`row = height - 1` for `HORIZONTAL`, `height - 3` for `VERTICAL`), lateral moves (`LEFT`, `RIGHT`), boundary/collision rejection (`OUT_OF_BOUNDS_MOVE`), orientation toggle (`ORIENT`), and block cycling (`CYCLE`).
  - [ ] **Task 7.3 (RED $\rightarrow$ GREEN)**: In `FallingBricksEngineTest`, test timer-driven descent (`Command.TICK` moves active rigid brick down 1 row per tick and locks when obstructed below) and immediate drop (`Command.DROP`), advancing to the next brick until queue exhaustion triggers `GameStatus.COMPLETED`.
  - [ ] **Task 7.4 (RED $\rightarrow$ GREEN)**: In `FallingBricksEngineTest`, test vertical overflow (`ValidationErrorCode.VERTICAL_OVERFLOW` $\rightarrow$ `GameStatus.GAME_OVER`) and `Command.RETRY` (resets board and replays the exact same level using the same `seed`).
  - [ ] **Task 7.5 (REFACTOR)**: Verify SLF4J logging calls (`INFO`, `DEBUG`, `WARN`) in `FallingBricksEngine` and ensure `GameSnapshot` is 100% immutable.

---

## Slice 8: Console UI (`AsciiGameRenderer`, `ConsoleGameRunner`), Real Multi-Component Integration Tests & `README.md`

- **Target Seam**: `com.fallingbricks.ui.AsciiGameRenderer`, `com.fallingbricks.ui.ConsoleGameRunner`, `com.fallingbricks.cli.FallingBricksApplication`
- **Spec Requirements Covered**: End-to-End Integration Requirement ("include some tests that run the real components together, not just mocks"), Clean Architecture & README
- **Red-Green-Refactor Cycle**:
  - [ ] **Task 8.1 (RED $\rightarrow$ GREEN)**: In `FallingBricksIntegrationTest`, wire real `GameConfiguration` + real `SeededBrickGenerator(seed)` + real `TextCommandParser` + real `FallingBricksEngine` + real `AsciiGameRenderer` + real `ConsoleGameRunner` over `StringReader`/`StringWriter` (zero mocks):
    - **Integration Scenario A**: Play a full deterministic seeded game to `GameStatus.COMPLETED`, asserting on final `GameSnapshot` state (`grid`, `score`, `totalClears`, `remainingBricks == 0`).
    - **Integration Scenario B**: Trigger dodgy commands, out-of-bounds lateral moves, and `VERTICAL_OVERFLOW` (`GameStatus.GAME_OVER`), then issue `RETRY` and verify the level restarts with the exact same `seed` and initial brick!
  - [ ] **Task 8.2 (Cleanup & Hygiene Audit)**: Run `code-review-expert` audit across all packages to strip any unused imports, dead methods, or unused classes, and verify `./gradlew test check` passes with zero warnings.
  - [ ] **Task 8.3 (Documentation)**: Generate maintainer-ready `README.md` (`readme-generator`) documenting game rules, ASCII UI mockups, configurable properties/CLI flags, architecture diagram, and `./gradlew test` / `./gradlew run` usage.
