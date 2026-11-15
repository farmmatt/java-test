# Change Proposal: Falling Bricks Console Game (`falling-bricks-game`)

- **Change ID**: `falling-bricks-game`
- **Schema**: `spec-driven-reviewed`
- **Target Repository**: `java-test` (`com.example.app`)
- **Authoring Personas**: `first-principles-thinking`, `spec-builder`, `system-design` (Strictly No-Code Phase)
- **Companion Documents**:
  - Domain Glossary: [GLOSSARY.md](../../../GLOSSARY.md)
  - ADR & Decision Matrix: [docs/adr/0001-falling-bricks-architecture-and-decision-matrix.md](../../../docs/adr/0001-falling-bricks-architecture-and-decision-matrix.md)
  - Spec Review Gate: [review.md](review.md)
  - Normative Capability Spec: [specs/falling-bricks/spec.md](specs/falling-bricks/spec.md)
  - System & Module Design: [design.md](design.md)
  - Vertical-Slice TDD Plan: [tasks.md](tasks.md)

---

## 1. Problem Statement & Why Now

We need to build a **Falling Bricks Console Application** in Java 21 (`com.example.app`) where a player controls falling 3-block `Brick`s (each `Block` marked with a special `Symbol`, oriented either `HORIZONTAL` or `VERTICAL`), moves or drops them onto a 2D `Grid` using simple commands, and aims to place all bricks while clearing as many symbol `Match`es as possible.

Prior reviewer feedback on similar submissions highlighted four critical engineering criteria that this specification enforces from first principles:
1. **Validate Everything**: Empty inputs, invalid symbols/orientations, undersized/oversized grids, out-of-bounds moves, and malformed commands must all be caught and reported cleanly.
2. **Clean, Immutable Domain Model**: Value types must never expose mutable public fields, collections/grids must be defensively copied, and zero hardcoded file paths may exist.
3. **State-Based TDD + Real-Component Integration Tests**: Tests must assert on actual `Grid` and `GameStateSnapshot` state (never console output strings), and include integration tests running the real components wired together without mocks.
4. **Clean Architecture & Hygiene**: Clear interfaces at I/O seams, constructor-based dependency injection (`config` $\rightarrow$ `service` $\rightarrow$ `domain`), ubiquitous naming ([GLOSSARY.md](../../../GLOSSARY.md)), zero dead code, and a clear `README.md`.

---

## 2. Obvious Requirements (Explicit + Reviewer-Feedback Derived)

### 2.1 Functional Requirements
- **FR-1 (Grid Initialization)**: Support a 2D `Grid` of configurable `width` and `height` (validated within `3..20` columns $\times$ `3..30` rows, default `6x8`).
- **FR-2 (3-Block Bricks & Symbols)**: Represent each `Brick` as an immutable triad of 3 `Block`s, each carrying a validated printable non-whitespace `Symbol` from an `AllowedSymbolSet`, plus an `Orientation` (`HORIZONTAL` $1 \times 3$ or `VERTICAL` $3 \times 1$).
- **FR-3 (Active Brick Positioning & Commands)**: Spawn bricks sequentially from a configured `BrickSource`. Support simple commands:
  - `L` / `LEFT`: Move active brick 1 column left (if within `[0, width - span]`).
  - `R` / `RIGHT`: Move active brick 1 column right (if within `[0, width - span]`).
  - `O` / `ORIENT`: Toggle `HORIZONTAL` $\leftrightarrow$ `VERTICAL` (if the new span fits within `[0, width - 1]`).
  - `C` / `CYCLE`: Cycle the 3 block symbols within the active brick (`[b0, b1, b2]` $\rightarrow$ `[b2, b0, b1]`).
  - `D` / `DROP`: Drop the active brick onto the `Grid`, resolve matches and gravity cascades, and advance to the next brick.
  - `Q` / `QUIT`: End the session cleanly with `GameStatus.QUIT`.
- **FR-4 (Drop Physics & Overflow Detection)**:
  - `VERTICAL` ($3 \times 1$) brick at column `c`: stacks its 3 blocks at the lowest 3 free rows in column `c`.
  - `HORIZONTAL` ($1 \times 3$) brick across columns `c, c+1, c+2`: drops each block under column gravity to the lowest free row in its respective column.
  - If any dropped block exceeds `height - 1`, transition immediately to `GameStatus.GAME_OVER`.
- **FR-5 (Simultaneous Match Clearing & Gravity Cascades)**:
  - After a brick lands, detect all horizontal and vertical contiguous runs of **$\ge 3$ identical `Symbol`s** simultaneously.
  - Clear all matched cells, apply column gravity so blocks above fall into empty spaces, and repeat until no new $\ge 3$ runs exist (chain-reaction `Cascade`s).
  - Track `matchesCleared`, `blocksCleared`, and `score` (`100 * blocksClearedInWave * cascadeWaveNumber`).
- **FR-6 (Completion Goal)**: When the last brick in the supply is dropped and all cascades finish without grid overflow, transition to `GameStatus.COMPLETED`.

### 2.2 Non-Goals (Scope-Creep Prevention)
- **NG-1**: Real-time asynchronous timer threads or `ncurses`/raw terminal keystroke polling (harms deterministic TDD and portability).
- **NG-2**: Graphical UI (Swing/JavaFX) or web endpoints (this is a pure console application with state-tested domain/service seams).
- **NG-3**: Persistent database storage or hardcoded external file paths.

---

## 3. High-Level Exploration of Similar Work

| Prior Art / Archetype | Mechanics Summary | Why Selected or Rejected |
| :--- | :--- | :--- |
| **1. Sega *Columns* / Turn-Based Console Kata** | 3-symbol vertical/horizontal jewel strips dropped into a bounded well; simultaneous orthogonal 3+ match clearing with gravity cascades. | **Selected**: Matches the user prompt (*"bricks made up of three blocks, each marked with a special symbol... horizontal or vertical... move or drop them using simple commands... clear as many matches as possible"*) and provides 100% deterministic state transitions for JUnit 5 TDD. |
| **2. Real-Time Arcade Loop** | Asynchronous gravity timer every $500\text{ ms}$ + non-blocking key listener. | **Rejected**: Introduces thread-timing flakiness and terminal incompatibilities. |
| **3. Rigid-Overhang Tetris Bar** | Horizontal pieces remain suspended in mid-air over empty cells when one end catches a ledge. | **Rejected as Default**: Creates unreachable dead spaces in symbol-matching games; per-block column gravity keeps the invariant that settled blocks never float over empty cells. |

---

## 4. Synthesis & Pre-Agreed Test Seams ("Seams Before Prose")

All TDD tests in `tasks.md` will be written exclusively against these **3 Pre-Agreed Test Seams**:

| Seam ID | Seam Interface / Class | Package | Dependency Category | What Tests Assert Here (State, Never `System.out`) |
| :--- | :--- | :--- | :--- | :--- |
| **Seam 1** | `FallingBricksEngine` (`execute(Command)`, `snapshot()`) | `com.example.app.domain` | **In-Process** (Zero Mocks) | `GameStateSnapshot` grid cells (`cellAt(row, col)`), active brick position/orientation, `matchesCleared`, `blocksCleared`, `score`, `remainingBricks`, `status`, and `StepOutcome` (`APPLIED` vs. `REJECTED`). |
| **Seam 2** | `GameInputParser` (`parseDimensions`, `parseBrick`, `parseBricks`, `parseCommand`) | `com.example.app.service` | **In-Process** (Zero Mocks) | Sealed `ValidationResult<T>` (`Valid<T>` vs. `Invalid<T>(ValidationErrorCode, String)`) for empty/null/blank inputs, invalid symbols, invalid orientations, $\ne 3$ blocks, undersized/oversized grids, and dodgy commands. |
| **Seam 3** | `GameSessionService` (`runSession()`) | `com.example.app.service` | **Local-Substitutable** (Real Parser + Real Engine + In-Memory/Stream Adapters) | End-to-end multi-brick sessions running all real components wired together via constructor DI (`AppConfig`), verifying final `GameStateSnapshot` and rendered view state without console scraping. |

---

## 5. Decision Matrix (Decisions Taken & Open Confirmation Items)

| ID | Decision Topic | Options Evaluated | Decision Taken | Status |
| :--- | :--- | :--- | :--- | :--- |
| **DEC-01** | **Turn & Command Loop** | A) Turn-based commands (`L`, `R`, `O`, `C`, `D`, `Q` + space-separated sequences)<br>B) Real-time timer ticks | **Option A**: Deterministic turn-based commands (`L`/`LEFT`, `R`/`RIGHT`, `O`/`ORIENT`, `C`/`CYCLE`, `D`/`DROP`, `Q`/`QUIT`), supporting single or space-separated batch commands per line. | **TAKEN (Confirmable)** |
| **DEC-02** | **Grid Bounds & Coordinate Origin** | A) Configurable `3..20` $\times$ `3..30` (default `6x8`), `row 0` = bottom floor<br>B) Unbounded or hardcoded size | **Option A**: Validated `GridDimensions(width, height)` with `MIN_WIDTH=3, MAX_WIDTH=20, MIN_HEIGHT=3, MAX_HEIGHT=30`, `row 0` at bottom floor. | **TAKEN (Confirmable)** |
| **DEC-03** | **Brick Value Type & Symbol Validation** | A) Immutable `Brick(List<Block>, Orientation)` of size 3 + `AllowedSymbolSet`<br>B) Unvalidated `char[]` | **Option A**: Java 21 `record` with `List.copyOf` defensive copy, exact length 3, and printable non-whitespace symbol validation against `AllowedSymbolSet` (default `@#$%&*+=?` + `A-Z0-9`). | **TAKEN (Confirmable)** |
| **DEC-04** | **Spawn Position & Orientation Toggle** | A) Top-center spawn `col = (width - span) / 2`, `O` toggles `H`/`V`, `C` cycles blocks<br>B) Fixed orientation after spawn | **Option A**: Top-center spawn; `O` toggles orientation if within bounds (or rejects if near right wall); `C` cycles the 3 symbols. | **TAKEN (Confirmable)** |
| **DEC-05** | **Horizontal Brick Drop Physics** | A) Independent per-block column gravity<br>B) Rigid bar overhang | **Option A**: Each of the 3 blocks in a `HORIZONTAL` brick drops to the lowest free row in its respective column (`c, c+1, c+2`). | **TAKEN (Confirmable)** |
| **DEC-06** | **Match Rule & Gravity Cascades** | A) Orthogonal (Horizontal + Vertical) $\ge 3$ simultaneous clear + column gravity cascades<br>B) Diagonal included / No cascades | **Option A**: Orthogonal Horizontal + Vertical runs of $\ge 3$ identical symbols clear simultaneously, followed by column gravity and chain-reaction cascades until stable. | **TAKEN (Confirmable)** |
| **DEC-07** | **End-of-Game & Scoring** | A) `COMPLETED` when queue empty, `GAME_OVER` on column overflow (`row >= height`), `QUIT` on `Q`; wave-multiplied score<br>B) Unlimited queue | **Option A**: Finite brick supply (`COMPLETED` when all bricks placed); `GAME_OVER` if any dropped block overflows `height`; `100 * blocksCleared * cascadeWave` scoring. | **TAKEN (Confirmable)** |
| **DEC-08** | **Validation & Error Reporting** | A) Sealed `ValidationResult<T>` + `StepOutcome.REJECTED` on state snapshot<br>B) Unchecked exceptions / `System.out` | **Option A**: Typed `ValidationResult<T>` for all parsers and `StepOutcome.REJECTED` with `ValidationErrorCode` for invalid in-game moves/commands. | **TAKEN** |
| **DEC-09** | **Clean Architecture & DI** | A) `domain` / `service` / `config` with constructor DI and zero hardcoded paths<br>B) Monolithic CLI class | **Option A**: Pure `domain`, port interfaces in `service` (`BrickSource`, `CommandSource`, `GameRenderer`), and constructor wiring in `config` (`AppConfig`). | **TAKEN** |

---

## 6. Review Focus (5 High-Risk Input Classes & Failure Modes)

Per `spec-builder`, every task in `tasks.md` pins tests for these 5 failure classes:
1. **Null, Empty & Whitespace-Only Inputs**: `null` or `"   "` passed to brick parser, command parser, or config loader $\rightarrow$ rejected with `ValidationErrorCode.EMPTY_INPUT`.
2. **Malformed Bricks & Invalid Symbols/Orientations**: Brick strings of length 0, 1, 2, or 4 (`"@@"`, `"@@@@"`), whitespace/control symbols (`"@ #"`), or invalid orientation (`"DIAGONAL"`, `"X"`) $\rightarrow$ rejected with `INVALID_BRICK_LENGTH`, `INVALID_SYMBOL`, or `INVALID_ORIENTATION`.
3. **Undersized & Oversized Grid Dimensions**: Grid sizes like `0x0`, `-5x10`, `2x8` (cannot fit a 3-block horizontal brick), or `25x100` (oversized) $\rightarrow$ rejected with `GRID_DIMENSIONS_OUT_OF_BOUNDS`.
4. **Boundary Moves & Wall Collisions**: Moving `LEFT` at column `0`, moving `RIGHT` at `width - span`, or toggling `ORIENT` from `VERTICAL` to `HORIZONTAL` at `col = width - 1` $\rightarrow$ rejected with `OUT_OF_BOUNDS_MOVE` while leaving the active brick and grid untouched.
5. **Intersecting Matches, Multi-Step Cascades & Column Overflow**: L/T-shaped 5-block intersections clearing simultaneously without double-counting, multi-wave gravity cascades after a drop, and dropping a vertical brick into a column with $< 3$ free rows triggering `GameStatus.GAME_OVER`.
