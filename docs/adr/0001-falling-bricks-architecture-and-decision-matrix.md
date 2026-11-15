# ADR-0001: Falling Bricks Architecture, Game Mechanics & Complete Decision Matrix

**Status:** Proposed (Ready for User Review)
**Date:** 2026-11-15
**Deciders:** Project Owner (`farmmatt`), `first-principles-thinking`, `spec-builder`, `system-design`, `java-architect`
**Related OpenSpec Change:** `openspec/changes/falling-bricks-game/`

---

## 1. Context & Obvious Requirements Extracted

We are building a **Falling Bricks Console Game** inside `java-test` (`com.example.app`) under strict **Spec-Driven Design $\rightarrow$ Red-Green-Refactor TDD** rules.

### 1.1 Explicit Functional Requirements
1. **3-Block Bricks**: Every `Brick` consists of **exact 3 `Block`s**, each marked with a special `Symbol`.
2. **Brick Orientation**: Every `Brick` can be `HORIZONTAL` ($1 \times 3$) or `VERTICAL` ($3 \times 1$).
3. **Simple Movement & Drop Commands**: Players position the active brick (`MOVE_LEFT`, `MOVE_RIGHT`, `ORIENT`, `CYCLE`) and drop it (`DROP`) onto a 2D `Grid`.
4. **Objective**: Place all bricks from the brick supply and clear as many `Match`es of identical symbols as possible without overflowing the `Grid`.

### 1.2 Explicit Engineering & Reviewer-Feedback Requirements
1. **Validate Everything**:
   - Empty, `null`, or whitespace-only inputs MUST be caught and reported.
   - Invalid symbols, invalid orientations, and bricks with $\ne 3$ blocks MUST be caught and reported.
   - Undersized ($< 3 \times 3$) and oversized ($> 20 \times 30$) grids MUST be caught and reported.
   - Malformed/unknown commands and out-of-bounds movement attempts MUST be caught and reported without corrupting `Grid` state.
2. **Clean, Immutable Domain Model**:
   - Zero mutable public fields on value types (`record` types with compact-constructor validation).
   - Defensive copying (`List.copyOf(...)`) on all collection/grid boundaries.
   - Zero hardcoded file paths anywhere in production or test code.
3. **Test Actual State (Never Console Output) + Real-Component Integration Tests**:
   - Unit and vertical-slice tests assert on `GameStateSnapshot` / `Grid` cell state and `ValidationResult` — never by scraping `System.out`.
   - Integration tests run the real parsers, real `FallingBricksEngine`, and real `GameSessionService` wired together without mocks.
4. **Clean Architecture & Hygiene**:
   - Interfaces at real boundaries (`BrickSource`, `CommandSource`, `GameRenderer`), constructor-based dependency injection in `config/`, consistent naming (`GLOSSARY.md`), zero dead/unused code (`-Xlint:all`), and a maintainer-grade `README.md`.

---

## 2. High-Level Exploration of Similar Work & Archetypes

We evaluated three industry archetypes for 3-block symbol falling-brick games:

| Archetype | Reference Prior Art | Control & Physics Model | Suitability for Console + State-Driven TDD |
| :--- | :--- | :--- | :--- |
| **Archetype 1: Turn-Based Spawn-Row Aim & Drop** | Classic *Columns* / Coding Assessment Console Katas | Active brick spawns above/at top of grid; player issues discrete commands (`L`, `R`, `O`, `C`, `D`) via console input; `D` drops the brick under column gravity, resolves simultaneous 3+ orthogonal matches and gravity cascades, and advances to the next brick. | **Optimal (`Selected`)**: 100% deterministic, zero thread/timer flakiness, supports interactive CLI and scripted batch runs, and exposes clean state transitions per command. |
| **Archetype 2: Real-Time Asynchronous Tick Loop** | Arcade *Tetris* / *Columns* with `ScheduledExecutorService` | Background thread ticks brick down every $N\text{ ms}$ while reading raw terminal keystrokes. | **Rejected**: Requires non-portable terminal raw mode (`stty`), introduces timing race conditions, and violates deterministic state-first console testing. |
| **Archetype 3: Stateless One-Shot Coordinate Placement** | Static board puzzle (`place(brick, row, col)`) | Caller specifies arbitrary `(row, col)` coordinates rather than moving/dropping from the top. | **Rejected**: Violates the prompt requirement *"falling bricks game... you can move or drop them using simple commands."* |

---

## 3. Synthesis & Pre-Agreed Test Seams ("Seams Before Prose")

To satisfy both clean architecture and state-based TDD without mocks of internal classes, the system is decomposed into **3 deep modules** across `domain`, `service`, and `config`, exposing **3 Pre-Agreed Test Seams**:

1. **Seam 1 — Domain Engine Seam (`com.example.app.domain.FallingBricksEngine`)**:
   - Pure Java 21 state machine & `Grid` engine.
   - **Dependency Category**: In-Process (zero mocks, zero I/O).
   - **Test Surface**: `FallingBricksEngine#execute(Command)` and `FallingBricksEngine#snapshot()` returning an immutable `GameStateSnapshot`.
2. **Seam 2 — Input & Configuration Validation Seam (`com.example.app.service.GameInputParser`)**:
   - Pure parser/validator for `GridDimensions`, `AllowedSymbolSet`, `Brick` definitions, and `Command` tokens.
   - **Dependency Category**: In-Process.
   - **Test Surface**: Returns sealed `ValidationResult<T>` (`Valid<T>` or `Invalid<T>(ErrorCode, String)`), allowing every invalid input scenario to be verified on state without catching raw strings or scraping `System.out`.
3. **Seam 3 — Real-Component Application Service Seam (`com.example.app.service.GameSessionService`)**:
   - Orchestrates a complete game session by wiring the real `GameInputParser`, real `FallingBricksEngine`, and constructor-injected port interfaces (`BrickSource`, `CommandSource`, `GameRenderer`).
   - **Dependency Category**: Local-Substitutable I/O (`Reader`/`Writer` or in-memory `BrickSource`/`CommandSource` adapters).
   - **Test Surface**: `GameSessionService#runSession()` returning the final `GameStateSnapshot` (plus step-by-step state history) with all real components running together.

---

## 4. Complete Decision Matrix (Decisions Taken & Open Confirmation Items)

Every architectural, domain, validation, and testing decision is recorded in this matrix:

| Decision ID | Decision Area | Options Considered | Trade-Off Analysis | Decision Taken | Status | Rationale & Spec Link |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **DEC-01** | **Game Loop & Interaction Model** | **A)** Turn-based command loop (`L`, `R`, `O`, `C`, `D`, `Q`)<br>**B)** Real-time timed gravity loop<br>**C)** Direct coordinate placement | **A** is 100% deterministic in JUnit 5 and standard `Scanner`/`Reader` CLI; **B** is flaky in standard stdin/stdout; **C** skips movement commands. | **Option A**: Turn-based command loop supporting both single commands (`L`, `R`, `O`, `C`, `D`, `Q`) and space-separated command sequences (e.g., `R R D`). | **TAKEN (Confirmable)** | Matches *"move or drop them using simple commands"* and enables deterministic state testing (`specs/falling-bricks/spec.md` Req 3 & 4). |
| **DEC-02** | **Grid Coordinate System & Dimensions Bounds** | **A)** Bounded configurable grid (`min 3x3`, `max 20x30`, default `6x8`), row `0` = bottom floor<br>**B)** Fixed hardcoded `10x20` grid<br>**C)** Unbounded grid | **A** satisfies reviewer requirement *"oversized grids... should all be caught and reported"* while keeping row `0` as the natural gravity floor. | **Option A**: `GridDimensions(width, height)` validated to `3 <= width <= 20` and `3 <= height <= 30` (default `6x8`), with `row = 0` at the bottom and `col = 0` at the left. | **TAKEN (Confirmable)** | Directly enforces undersized/oversized grid validation (`specs/falling-bricks/spec.md` Req 1). |
| **DEC-03** | **Brick Structure & Allowed Symbols** | **A)** Immutable `Brick(List<Block>, Orientation)` of exact size 3; configurable printable non-whitespace symbol set (default `@ # $ % & * + = ? A-Z 0-9`)<br>**B)** Unvalidated `char[]` array<br>**C)** Enum of 4 hardcoded colors only | **A** prevents mutable array leaks, enforces defensive copying (`List.copyOf`), and validates invalid/whitespace/control symbols cleanly. | **Option A**: `Brick` is a Java 21 `record` enforcing `blocks.size() == 3`, non-null `Orientation`, and symbols validated against `AllowedSymbolSet` (rejecting whitespace, control chars, or unknown symbols). | **TAKEN (Confirmable)** | Satisfies *"Avoid mutable public fields on value types, copy collections defensively"* and *"invalid symbols/orientations... caught and reported"* (Req 2). |
| **DEC-04** | **Brick Spawn Position & Orientation Toggle (`O`)** | **A)** Spawns at top of grid centered at `col = (width - brickWidth) / 2` (or `col = 0`); `ORIENT` (`O`) toggles `HORIZONTAL` $\leftrightarrow$ `VERTICAL` (clamping or rejecting if near right wall); `CYCLE` (`C`) shifts `[b0, b1, b2]` $\rightarrow$ `[b2, b0, b1]`<br>**B)** Orientation fixed forever at creation | **A** gives the player full control over horizontal/vertical placement and symbol alignment while validating wall boundaries when toggling from `VERTICAL` ($w=1$) to `HORIZONTAL` ($w=3$). | **Option A**: Bricks spawn with their initial `Orientation` centered at `col = (width - span) / 2`; player can move `L`/`R`, toggle `O` (`HORIZONTAL` $\leftrightarrow$ `VERTICAL` if within bounds, or report invalid move if blocked by wall), cycle symbols `C`, and `D` (`DROP`). | **TAKEN (Confirmable)** | Fulfils *"Bricks can be horizontal or vertical, and you can move or drop them using simple commands"* (Req 3 & 4). |
| **DEC-05** | **Horizontal Brick ($1 \times 3$) Drop Physics** | **A)** Independent Per-Block Column Gravity (each of the 3 blocks falls to the lowest free row in its respective column `c, c+1, c+2`)<br>**B)** Rigid-Bar Stopping (stops as a flat bar when any of the 3 blocks hits an occupied cell below) | **A** prevents floating unreachable air pockets and unifies drop physics with post-match gravity; **B** leaves overhang gaps unless secondary gravity runs. | **Option A**: Independent Per-Block Column Gravity on drop (for `HORIZONTAL` across `c, c+1, c+2`, each block settles on top of existing blocks in its column; for `VERTICAL` in column `c`, the 3 blocks stack at `top(c), top(c)+1, top(c)+2`). | **TAKEN (Confirmable)** | Cleanest invariant: *a settled grid never contains floating blocks above empty cells* (Req 5). |
| **DEC-06** | **Match Detection, Simultaneous Clearing & Gravity Cascades** | **A)** Orthogonal (Horizontal + Vertical) contiguous runs of $\ge 3$ identical symbols cleared simultaneously, followed by column gravity and chain-reaction cascades<br>**B)** Orthogonal + Diagonal $\ge 3$<br>**C)** Exact 3 only, no cascades | **A** is the canonical grid-matching rule, deterministic to test (including intersecting L/T shapes and multi-step cascades), and rewards strategic placement. | **Option A**: Simultaneous mark-and-sweep of all horizontal and vertical contiguous runs of $\ge 3$ identical `Symbol`s, followed by column gravity and iterative cascade resolution until no $\ge 3$ runs remain. | **TAKEN (Confirmable)** | Satisfies *"The goal is to place all bricks and clear as many matches as possible"* (Req 6). |
| **DEC-07** | **Scoring & End-of-Game States** | **A)** Track `matchesCleared`, `blocksCleared`, and `score` (`100 * clearedBlocks * cascadeStepMultiplier`); end states: `COMPLETED` (all bricks placed), `GAME_OVER` (column overflow `targetRow >= height`), `QUIT`<br>**B)** Boolean win/lose only | **A** provides rich, inspectable domain metrics for state assertions and clear termination reasons. | **Option A**: `GameStateSnapshot` tracks `matchesCleared`, `blocksCleared`, `score`, `remainingBricks`, and `GameStatus` (`IN_PROGRESS`, `COMPLETED`, `GAME_OVER`, `QUIT`). If any block of a dropped brick lands at `row >= height`, the game ends immediately as `GAME_OVER`. | **TAKEN (Confirmable)** | Enables precise assertions on game progress and completion/overflow edge cases (Req 5, 6, 7). |
| **DEC-08** | **Error Handling & Validation Architecture** | **A)** Sealed `ValidationResult<T>` (`Valid<T>` / `Invalid<T>`) + `StepOutcome` on `GameStateSnapshot` for non-fatal command errors<br>**B)** Unchecked exceptions thrown to `main`<br>**C)** Printing errors directly to `System.out` inside domain | **A** keeps the domain pure, avoids exceptions for expected user input mistakes, and lets tests assert on exact error codes/messages without capturing `System.out`. | **Option A**: All parsers return `ValidationResult<T>`, and invalid in-game commands/moves return a `GameStateSnapshot` with `StepOutcome.REJECTED` + descriptive `errorMessage` while preserving the board state unchanged. | **TAKEN** | Directly satisfies *"Validate everything... caught and reported"* and *"Test the actual state, not console output"* (Req 1–4, 8). |
| **DEC-09** | **Clean Architecture & Dependency Injection** | **A)** 3-package modular architecture (`domain`, `service`, `config`) with port interfaces (`BrickSource`, `CommandSource`, `GameRenderer`) and constructor DI<br>**B)** Single monolithic `App` class reading `System.in` | **A** cleanly isolates pure domain logic from I/O, avoids hardcoded file paths, and allows real-component integration tests using in-memory `BrickSource`/`CommandSource` adapters. | **Option A**: `domain` has zero I/O imports; `service` defines ports and orchestrates the session; `config` wires CLI/stream adapters via constructor injection. | **TAKEN** | Directly satisfies reviewer feedback on clean architecture, interfaces, DI, and zero hardcoded paths (Req 8). |
