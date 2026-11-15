# Proposal: Falling Bricks Console Game (`falling-bricks-game`)

- **Change ID**: `falling-bricks-game`
- **Status**: Spec Complete & Interview Resolved — Holding for TDD Plan Review
- **ADR & Decision Matrix**: `docs/adr/0001-falling-bricks-architecture-and-decision-matrix.md`
- **Ubiquitous Language**: `GLOSSARY.md`

---

## 1. Problem Statement & Motivation

Build a clean-architecture Java 21 console application for a **Falling Bricks Game** in which the player controls falling **bricks** composed of **three blocks**, each marked with a printable 7-bit ASCII symbol (`0x21..0x7E`, e.g., `@`, `#`, `$`, `%`, `&`). Bricks can be **`HORIZONTAL`** ($1 \times 3$) or **`VERTICAL`** ($3 \times 1$). Each brick spawns at a pseudo-random column on the top row of the grid (`Random(seed)`) and drops down on a configurable timer (`Command.TICK`) or immediately on player command (`Command.DROP`), while the player moves, rotates, or cycles the brick.

While falling, **all bricks behave as rigid 3-block bars**. Once a brick lands, its 3 blocks lock into the grid as **independent stacked blocks** (the original 3-block shape no longer applies to stacked blocks). Completing a horizontal row or matching horizontal contiguous symbols clears that row/match, and **all stacked blocks above drop independently based on column gravity**, triggering cascading clears. The goal is to place all bricks in a configurable finite seeded queue (always sized large enough to potentially overflow the grid) and clear as many rows/matches as possible without overflowing the top of the grid (`VERTICAL_OVERFLOW`). If a player asks to **Retry** (`R` / `RETRY`), they replay the exact same level using the **same random `seed`**.

### Non-Negotiable Engineering Guardrails
1. **Validate Everything**: Empty inputs, invalid symbols (`non-ASCII`, whitespace, control chars), invalid orientations, negative/zero/undersized/oversized grids (`min >= largestConfiguredBrickSpan [3]`, `max` configurable defaulting to `20 x 20`), brick counts too small to overflow the grid, out-of-bounds lateral moves, vertical overflow on spawn/lock, and dodgy commands must all be caught, logged via SLF4J, and reported cleanly.
2. **Clean, Immutable Domain Model**:
   - Zero mutable public fields on value types (`record`s and immutable value objects).
   - Defensive copies of all collections (`List.copyOf`) and grid arrays on input and output boundaries.
   - **Zero hardcoded file paths** anywhere in production or test code (configuration via `InputStream`/`Properties` and CLI flags; I/O via injected `Reader`/`Writer`).
3. **Test Actual State, Not Console Output**:
   - Primary tests assert directly against `GameSnapshot`, `Grid`, `Brick`, `PlacementOutcome`, and `ValidationResult`.
   - Include real multi-component integration tests (`FallingBricksIntegrationTest`) running real collaborators together without mocks.
4. **Clean Architecture, Logging & Code Style**:
   - Interfaces/ports (`BrickGenerator`, `CommandParser`, `GameRenderer`), constructor DI, `SLF4J + Logback` diagnostics separated from `STDOUT` UI rendering, consistent Java 21 style, zero unused code, and a clear `README.md`.

---

## 2. Sample Console Interface Mockups

All user-facing console output is produced exclusively by `AsciiGameRenderer` writing to an injected `java.io.Writer` (`STDOUT` in production), never via `System.out.println` scattered in domain classes or logger statements.

### Mockup 1: Startup / Level Banner & Active Board (Horizontal Rigid Brick Spawning at Top Row)

```text
========================================================================
                       FALLING BRICKS CONSOLE GAME                      
========================================================================
 Level Seed : 4291048192      Grid Size   : 6 x 12 (Max: 20 x 20)
 Bricks Left: 14 / 15         Timer Tick  : 1000 ms
 Symbols    : [@, #, $, %, &] Next Brick  : [$ % @] (VERTICAL)
========================================================================
 Score: 0                     Rows/Matches Cleared: 0     Status: ACTIVE

   11 | .  [@   #   $]  .   . |  <-- Active Brick (HORIZONTAL, Anchor: col=1, row=11)
   10 | .   .   .   .   .   . |
    9 | .   .   .   .   .   . |
    8 | .   .   .   .   .   . |
    7 | .   .   .   .   .   . |
    6 | .   .   .   .   .   . |
    5 | .   .   .   .   .   . |
    4 | .   .   .   .   .   . |
    3 | .   .   .   .   .   . |
    2 | .   .   .   .   .   . |
    1 | .   %   .   .   &   . |
    0 | #   @   @   $   #   % |
      +-----------------------+
        0   1   2   3   4   5

 Commands: [L]eft | [R]ight | [O]rient (H/V) | [C]ycle | [D]rop | [T]ick | [RETRY] Same Seed | [Q]uit
 Enter command > 
```

### Mockup 2: Rigid-Bar Drop Landing + Horizontal Row Clear & Individual-Block Gravity (`Q3` & `Q4`)

```text
------------------------------------------------------------------------
 EVENT: Dropped [@ # $] (HORIZONTAL) as rigid bar -> Locked at row 1!
 EVENT: Row 0 FULL CLEAR! (+100 pts) -> Gravity dropped 4 stacked blocks!
 EVENT: Cascade Chain x2! Horizontal match [@ @ @] cleared at row 0! (+300 pts)
------------------------------------------------------------------------
 Level Seed : 4291048192      Bricks Left : 11 / 15
 Score      : 400             Clears      : 2 (Max Chain: x2) Status: ACTIVE

   11 | .   .   .   #   .   . |  <-- Active Brick (VERTICAL, cols=3, rows=9..11)
   10 | .   .   .   $   .   . |
    9 | .   .   .   @   .   . |
    8 | .   .   .   .   .   . |
    7 | .   .   .   .   .   . |
    6 | .   .   .   .   .   . |
    5 | .   .   .   .   .   . |
    4 | .   .   .   .   .   . |
    3 | .   .   .   .   .   . |
    2 | .   .   .   .   .   . |
    1 | .   .   .   .   .   . |
    0 | .   %   #   $   &   . |  <-- Stacked blocks fell independently under gravity!
      +-----------------------+
        0   1   2   3   4   5

 Commands: [L]eft | [R]ight | [O]rient (H/V) | [C]ycle | [D]rop | [T]ick | [RETRY] Same Seed | [Q]uit
 Enter command > 
```

### Mockup 3: Validation / Error Rejection Banner (Dodgy Command or Out-of-Bounds Move)

```text
!----------------------------------------------------------------------!
! [VALIDATION ERROR - OUT_OF_BOUNDS_MOVE]                              !
! Cannot move HORIZONTAL brick (span 3) right from col=3 on width=6    !
! grid (rightmost block would occupy col=6, valid columns: 0..5).      !
! Board state unchanged. Please enter a valid command.                 !
!----------------------------------------------------------------------!
 Enter command > 
```

### Mockup 4: End-of-Level (`GAME_OVER - VERTICAL_OVERFLOW` or `COMPLETED`) & Same-Seed Retry Prompt (`Q1` & `Q5`)

```text
========================================================================
                 GAME OVER — VERTICAL OVERFLOW (OUT OF BOUNDS)          
========================================================================
 Reason      : Next brick [@ $ #] could not spawn/lock within height 12
               (occupied cell at col=2, row=11).
 Level Seed  : 4291048192 (Use RETRY to replay this exact level!)
 Final Score : 1,250          Rows/Matches Cleared: 7
 Bricks Used : 9 / 15         Status              : GAME_OVER
========================================================================
 Options: [RETRY] Replay Same Level (Seed 4291048192) | [N]ew Level (New Seed) | [Q]uit
 Enter choice > 
```

---

## 3. Configurable Parameters (`GameConfiguration`)

All game parameters are encapsulated in an immutable `GameConfiguration` record. Parameters can be configured via:
1. **Default values** (`GameConfiguration.defaults()`),
2. **Classpath or injected `Properties` stream** (`src/main/resources/application.properties` loaded via `InputStream` — **zero hardcoded file paths**), and
3. **Command-line arguments** (`--width=8`, `--height=14`, `--max-width=20`, `--max-height=20`, `--bricks=20`, `--seed=42`, `--tick-ms=750`, `--symbols=@#$%&*`).

| Parameter | Property Key | CLI Flag | Default | Validation Rule (`ValidationErrorCode`) |
| :--- | :--- | :--- | :--- | :--- |
| **Grid Width** | `game.grid.width` | `--width=<int>` | `6` | `maxBrickSpan (3) <= width <= maxWidth` (negative/zero/`<3` $\rightarrow$ `GRID_TOO_SMALL`; `> maxWidth` $\rightarrow$ `GRID_TOO_LARGE`) |
| **Grid Height** | `game.grid.height` | `--height=<int>` | `12` | `maxBrickSpan (3) <= height <= maxHeight` (negative/zero/`<3` $\rightarrow$ `GRID_TOO_SMALL`; `> maxHeight` $\rightarrow$ `GRID_TOO_LARGE`) |
| **Max Grid Width** | `game.grid.maxWidth` | `--max-width=<int>` | `20` | `maxWidth >= maxBrickSpan (3)` (`<3` $\rightarrow$ `GRID_TOO_SMALL`) |
| **Max Grid Height** | `game.grid.maxHeight` | `--max-height=<int>` | `20` | `maxHeight >= maxBrickSpan (3)` (`<3` $\rightarrow$ `GRID_TOO_SMALL`) |
| **Brick Queue Count** | `game.bricks.count` | `--bricks=<int>` | `15` | Must be finite and **large enough to potentially cause a vertical overflow**: `brickCount * maxBrickSpan > height` (i.e. `brickCount >= (height / 3) + 1`). Otherwise rejected with `INSUFFICIENT_BRICK_COUNT`. |
| **Random Seed** | `game.random.seed` | `--seed=<long>` | Current epoch millis | Any `long` value; persisted in `GameSnapshot.seed()` so `Command.RETRY` replays the exact same level (`Q1`). |
| **Timer Tick Interval** | `game.timer.tickMs` | `--tick-ms=<long>` | `1000` | `tickMs > 0` (or `0` to disable background timer thread in deterministic CLI/test mode; `<= -1` $\rightarrow$ `INVALID_CONFIGURATION`). |
| **Allowed ASCII Symbols** | `game.bricks.symbols` | `--symbols=<str>` | `"@#$%&"` | Non-empty string of at least 2 distinct printable non-whitespace 7-bit ASCII characters (`0x21..0x7E`); otherwise `INVALID_SYMBOL`. |

---

## 4. Logging Architecture (`SLF4J + Logback`)

To keep the console UI clean and testable while providing production-grade observability:
1. **UI vs. Telemetry Separation**:
   - `GameRenderer` writes the ASCII board and player prompts to the injected `Writer` (`STDOUT`).
   - `SLF4J` (`org.slf4j.LoggerFactory.getLogger(...)`) logs structured diagnostic events via `Logback` (`src/main/resources/logback.xml`) to a rolling log file (`logs/falling-bricks.log` configurable via system property with `STDERR` fallback for `WARN`/`ERROR`) so **log lines never interleave with or corrupt the ASCII grid on `STDOUT`**.
2. **Log Levels by Event**:
   - `INFO`: Application startup with effective `GameConfiguration`, level start with `seed`, level `RETRY` with same `seed`, and game completion (`COMPLETED` or `GAME_OVER` with final score and cleared count).
   - `DEBUG`: Brick spawn (`brick`, `spawnCol`, `spawnRow`, `remainingBricks`), timer `TICK` step, player command execution (`LEFT`, `RIGHT`, `ORIENT`, `CYCLE`, `DROP`), row/match clear details, and per-column gravity cascade counts.
   - `WARN`: Every caught validation rejection (`ValidationErrorCode`, raw input/parameters, and rejection reason).
   - `ERROR`: Unexpected I/O exceptions on input/output streams.

---

## 5. Confirmed Interview Decisions (`Q1`–`Q5`) & Future Expansion Points

All 5 interview questions (`Q1`–`Q5`) and both expansion points have been resolved by the user:
- **`Q1` (Seeded PRNG Queue, Overflow-Capable Finite Brick Count & Same-Seed Retry)**:
  - Use a seeded pseudo-random stream (`java.util.Random(seed)`) so tests are 100% predictive based on `seed` while gameplay feels random to end users.
  - Finite, configurable `brickCount` validated so there are always enough bricks to potentially cause a vertical overflow (`brickCount >= (height / 3) + 1`).
  - If the user asks to `RETRY`, the engine resets the grid and re-initializes `SeededBrickGenerator` with the **exact same `seed`** so the user re-attempts the exact same level.
- **`Q2` (Random Top-Row Spawn + Timer Drop)**:
  - Each brick spawns at a pseudo-random valid column on the top of the grid (`row = height - 1` for `HORIZONTAL`, `row = height - 3 .. height - 1` for `VERTICAL`) drawn from the seeded PRNG and drops down 1 row on each timer tick (`Command.TICK`) or all the way down on `Command.DROP`.
- **`Q3` (Rigid Bar While Dropping)**:
  - All bricks (`HORIZONTAL` $1 \times 3$ and `VERTICAL` $3 \times 1$) are **rigid bars while being dropped**. A horizontal $1 \times 3$ brick stops as a rigid horizontal bar at the highest row where *any* of its 3 blocks contacts the floor (`row == 0`) or a stacked block directly below.
- **`Q4` (Horizontal Row Matching / Full Row Clear + Individual-Block Gravity on Stacked Blocks)**:
  - Once a brick locks onto the grid, its original 3-block shape no longer applies to the stacked blocks.
  - When a horizontal row is completely full or contains a horizontal contiguous symbol match (`>= 3` matching symbols), that row/match clears completely and **all stacked blocks above drop independently based on column gravity**, cascading until no further horizontal matches/full rows exist.
- **`Q5` (ASCII Symbols, Grid Bounds & Vertical Overflow)**:
  - Printable non-whitespace 7-bit ASCII symbols (`0x21..0x7E`).
  - Negative or zero grid bounds are forbidden; minimum grid size must fit the largest configured brick (`minWidth >= 3`, `minHeight >= 3`); maximum grid size is configurable and defaults to `20 x 20`.
  - Vertical overflow causes the out-of-bounds error (`ValidationErrorCode.VERTICAL_OVERFLOW`) and transitions the game to `GameStatus.GAME_OVER`.
- **Future Expansion Point 1 (Level Winnability Validation)**:
  - Do **not** validate whether a seeded queue is guaranteed winnable in v1. Document `SeedWinnabilityValidator` as Future Expansion Point 1 in `design.md`.
- **Future Expansion Point 2 (More Brick Shapes & Sizes)**:
  - Note variable brick shapes/sizes as a design consideration in `design.md` (using `brick.widthSpan()`, `brick.heightSpan()`, and relative block offsets so collision/bounds logic is not hardcoded to magic number `3`), **but do NOT build more than the 3-block horizontal/vertical specification (strict YAGNI)**.

---

## 6. Pre-Agreed Test Seams (Agreed Before Implementation)

| Seam Layer | Target Type / Interface | Primary Responsibility | Tested How |
| :--- | :--- | :--- | :--- |
| **Config Seam** | `GameConfiguration` (`com.fallingbricks.config`) | Validates grid bounds (`min >= largestBrick`, `max` default `20x20`), overflow-capable `brickCount`, `seed`, `tickIntervalMs`, and ASCII symbol alphabet; loads from `InputStream`/`Properties` + CLI args | Pure unit tests (`GameConfigurationTest`) |
| **Domain Value Seam** | `Block`, `Brick`, `Orientation`, `Position`, `Grid`, `Command` (`com.fallingbricks.domain`) | Immutable state, printable 7-bit ASCII validation, defensive collection/array copying, rigid-bar airborne bounds checks, horizontal row/match clearing, and individual-block column gravity | Pure unit tests (`BlockTest`, `BrickTest`, `GridTest`) — zero mocks |
| **Port Seam (PRNG Queue)** | `BrickGenerator` / `SeededBrickGenerator` (`com.fallingbricks.port` / `service`) | Deterministic `Random(seed)` brick & top-spawn-column generation, finite overflow-capable queue, and `resetWithSameSeed()` for level retry | Unit tests (`SeededBrickGeneratorTest`) verifying identical sequences for identical seeds |
| **Port Seam (Input)** | `CommandParser` (`com.fallingbricks.port`) | Parses raw strings into `ValidationResult<Command>` (`LEFT`, `RIGHT`, `ORIENT`, `CYCLE`, `DROP`, `TICK`, `RETRY`, `NEW_GAME`, `QUIT`) | Unit tests (`TextCommandParserTest`) for valid, empty, whitespace, and dodgy inputs |
| **Service / Engine Seam** | `FallingBricksEngine` (`com.fallingbricks.service`) | Orchestrates active falling brick (`anchorCol`, `anchorRow`), lateral movement, orientation toggle, block cycling, rigid-bar `TICK`/`DROP`, row clearing + gravity cascade, score, `VERTICAL_OVERFLOW`, and `RETRY` | State-based unit & scenario tests (`FallingBricksEngineTest`) asserting on `GameSnapshot` |
| **End-to-End Seam** | `ConsoleGameRunner` (`com.fallingbricks.ui`) | Wires `GameConfiguration` + `SeededBrickGenerator` + `TextCommandParser` + `FallingBricksEngine` + `AsciiGameRenderer` over `Reader`/`Writer` | Real multi-component integration tests (`FallingBricksIntegrationTest`) — zero mocks |
