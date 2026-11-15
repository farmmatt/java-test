# Capability Specification: Falling Bricks Game (`falling-bricks`)

- **Change ID**: `falling-bricks-game`
- **Glossary**: [GLOSSARY.md](../../../../../GLOSSARY.md)
- **Decision Matrix**: [ADR-0001](../../../../../docs/adr/0001-falling-bricks-architecture-and-decision-matrix.md)

---

## ADDED Requirements

### Requirement 1: Grid Dimensions & Coordinate System Validation (`DEC-02`)
The system SHALL represent the playing field as a 2D `Grid` with validated `GridDimensions(width, height)` where `width` MUST be between `3` and `20` inclusive (`3 <= width <= 20`) and `height` MUST be between `3` and `30` inclusive (`3 <= height <= 30`). Row `0` SHALL represent the bottom floor of the grid, and column `0` SHALL represent the leftmost column. Any attempt to construct or parse undersized (`< 3`) or oversized (`> 20` width or `> 30` height) grid dimensions MUST be caught and reported with `ValidationErrorCode.GRID_DIMENSIONS_OUT_OF_BOUNDS`.

#### Scenario 1.1: Valid Grid Dimensions Accepted
- **GIVEN** a dimension specification of `width = 6` and `height = 8`
- **WHEN** `GameInputParser.parseDimensions("6x8")` (or `GridDimensions` validation) is invoked
- **THEN** it returns `ValidationResult.Valid(GridDimensions(6, 8))` and an empty `Grid` of `6` columns by `8` rows where every cell `(row, col)` is `Optional.empty()`

#### Scenario 1.2: Undersized Grid Rejected
- **GIVEN** a dimension specification of `width = 2` and `height = 8` (cannot fit a 3-block horizontal brick) or negative/zero values (`0x5`, `-3x6`)
- **WHEN** `GameInputParser.parseDimensions` is invoked
- **THEN** it returns `ValidationResult.Invalid` with error code `GRID_DIMENSIONS_OUT_OF_BOUNDS` and a descriptive message stating the allowed range (`3..20 x 3..30`)

#### Scenario 1.3: Oversized Grid Rejected
- **GIVEN** a dimension specification of `width = 25` and `height = 40`
- **WHEN** `GameInputParser.parseDimensions("25x40")` is invoked
- **THEN** it returns `ValidationResult.Invalid` with error code `GRID_DIMENSIONS_OUT_OF_BOUNDS`

---

### Requirement 2: Immutable 3-Block Bricks, Symbol Validation & Defensive Copying (`DEC-03`)
The system SHALL represent every `Block` as an immutable value object containing a single validated `Symbol` from `AllowedSymbolSet` (default printable symbols: `@, #, $, %, &, *, +, =, ?` and `A–Z`, `0–9`, strictly excluding whitespace and control characters). Every `Brick` SHALL be an immutable value object (`record`) containing an unmodifiable `List<Block>` of **exact size 3** (`List.copyOf`) and a non-null `Orientation` (`HORIZONTAL` or `VERTICAL`). Empty inputs, wrong block counts ($\ne 3$), invalid symbols, or invalid orientations MUST be caught and reported.

#### Scenario 2.1: Valid Horizontal and Vertical Bricks Parsed
- **GIVEN** the default `AllowedSymbolSet`
- **WHEN** `GameInputParser.parseBrick("@#* H")` and `GameInputParser.parseBrick("$$% V")` are invoked
- **THEN** they return `ValidationResult.Valid` with a `HORIZONTAL` `Brick([@, #, *])` and a `VERTICAL` `Brick([$, $, %])` respectively

#### Scenario 2.2: Mutating Input List Does Not Mutate Brick (Defensive Copy)
- **GIVEN** a mutable `ArrayList<Block>` containing `[Block('@'), Block('#'), Block('*')]` used to construct a `Brick`
- **WHEN** the caller mutates the original `ArrayList` after construction or attempts `brick.blocks().clear()`
- **THEN** the `Brick` retains `[Block('@'), Block('#'), Block('*')]` unchanged and `brick.blocks().clear()` throws `UnsupportedOperationException`

#### Scenario 2.3: Empty, Wrong-Length, Invalid-Symbol, or Invalid-Orientation Brick Rejected
- **GIVEN** malformed brick specifications `""`, `"   "`, `"@@ H"` (2 blocks), `"@@@@ V"` (4 blocks), `"@ ~ H"` (disallowed/whitespace symbol), or `"@#* DIAGONAL"` (invalid orientation)
- **WHEN** `GameInputParser.parseBrick` is invoked for each
- **THEN** each returns `ValidationResult.Invalid` with the corresponding error code (`EMPTY_INPUT`, `INVALID_BRICK_LENGTH`, `INVALID_SYMBOL`, or `INVALID_ORIENTATION`)

---

### Requirement 3: Active Brick Spawn & Command Validation (`DEC-01`, `DEC-04`, `DEC-08`)
The system SHALL spawn each `Brick` from the session's brick queue at the top of the `Grid` centered horizontally at column `col = (width - span) / 2` (where `span = 3` for `HORIZONTAL` and `span = 1` for `VERTICAL`). The system SHALL parse and execute simple commands:
- `L` or `LEFT` (`Command.MOVE_LEFT`): Decrement active brick column by `1`.
- `R` or `RIGHT` (`Command.MOVE_RIGHT`): Increment active brick column by `1`.
- `O` or `ORIENT` (`Command.ORIENT`): Toggle `HORIZONTAL` $\leftrightarrow$ `VERTICAL` at the current column.
- `C` or `CYCLE` (`Command.CYCLE`): Shift the 3 blocks `[b0, b1, b2]` $\rightarrow$ `[b2, b0, b1]`.
- `D` or `DROP` (`Command.DROP`): Drop and lock the active brick into the `Grid`.
- `Q` or `QUIT` (`Command.QUIT`): Terminate the session with `GameStatus.QUIT`.

Unrecognized/empty commands or moves that would place any part of the active brick outside columns `[0, width - 1]` MUST be caught and reported via `ValidationResult.Invalid` (at parse time) or `StepOutcome.REJECTED` (at engine execution time) without mutating the `Grid` or active brick.

#### Scenario 3.1: Moving Active Brick Within Bounds and Toggling Orientation
- **GIVEN** a `6x8` grid and an active `HORIZONTAL` brick `[@, #, *]` spawned at default column `(6 - 3) / 2 = 1` (occupying columns `1, 2, 3`)
- **WHEN** the player executes `MOVE_RIGHT`, `CYCLE`, and `ORIENT`
- **THEN** the active brick moves to column `2` (occupying `2, 3, 4`), cycles its blocks to `[*, @, #]`, and toggles to `VERTICAL` at column `2` with `StepOutcome.APPLIED`

#### Scenario 3.2: Out-of-Bounds Move or Wall-Blocked Orientation Toggle Rejected Safely
- **GIVEN** a `6x8` grid with a `VERTICAL` brick at the rightmost column `5`
- **WHEN** the player executes `MOVE_RIGHT` or `ORIENT` (which would require columns `5, 6, 7`, exceeding max column `5`)
- **THEN** the engine returns a `GameStateSnapshot` with `StepOutcome.REJECTED` (`ValidationErrorCode.OUT_OF_BOUNDS_MOVE`), and the active brick remains `VERTICAL` at column `5`

#### Scenario 3.3: Dodgy or Empty Command Strings Rejected
- **GIVEN** command strings `""`, `"   "`, `"JUMP"`, `"123"`, or `"DROP_NOW"`
- **WHEN** `GameInputParser.parseCommands` is invoked
- **THEN** it returns `ValidationResult.Invalid` with error code `EMPTY_INPUT` or `INVALID_COMMAND`

---

### Requirement 4: Drop Physics for Horizontal and Vertical Bricks (`DEC-05`)
When `Command.DROP` is executed on an active `Brick`:
- If `VERTICAL` ($3 \times 1$) at column `c` with blocks `[b0, b1, b2]` (from bottom `b0` to top `b2`), the blocks SHALL stack in column `c` at `row = firstFreeRow(c)`, `firstFreeRow(c) + 1`, and `firstFreeRow(c) + 2`.
- If `HORIZONTAL` ($1 \times 3$) at column `c` with blocks `[b0, b1, b2]` (left to right), block `b0` SHALL land at `(firstFreeRow(c), c)`, `b1` at `(firstFreeRow(c + 1), c + 1)`, and `b2` at `(firstFreeRow(c + 2), c + 2)`.

#### Scenario 4.1: Vertical Brick Drops onto Floor and Stacks
- **GIVEN** an empty `6x8` grid and a `VERTICAL` brick `[@, #, *]` at column `2`
- **WHEN** `Command.DROP` is executed
- **THEN** cell `(0, 2)` contains `@`, cell `(1, 2)` contains `#`, and cell `(2, 2)` contains `*`

#### Scenario 4.2: Horizontal Brick Drops Across Uneven Columns with Per-Block Gravity
- **GIVEN** a `6x8` grid where column `1` already has 2 blocks (`row 0` and `row 1` occupied) and columns `2` and `3` are empty, and an active `HORIZONTAL` brick `[@, #, *]` at column `1`
- **WHEN** `Command.DROP` is executed
- **THEN** `@` lands at `(2, 1)`, `#` lands at `(0, 2)`, and `*` lands at `(0, 3)`

---

### Requirement 5: Simultaneous Match Clearing & Gravity Cascades (`DEC-06`)
Immediately after a `Brick` is dropped onto the `Grid`, the engine SHALL repeatedly execute a **Match & Cascade Resolution Loop** until no matches remain:
1. Scan the `Grid` for all horizontal and vertical contiguous lines of **3 or more** identical `Symbol`s.
2. If one or more runs of $\ge 3$ exist, collect the union of all matched coordinates simultaneously, remove those `Block`s, increment `matchesCleared` by the number of distinct runs and `blocksCleared` by the number of unique cells removed, and add `100 * removedCellsInWave * waveIndex` to `score`.
3. Apply column gravity to every column so all remaining `Block`s above cleared cells shift down to fill empty spaces without changing their vertical order.
4. Repeat from Step 1 with `waveIndex + 1` to resolve chain-reaction `Cascade`s.

#### Scenario 5.1: Horizontal and Vertical 3-of-a-Kind Matches Clear Simultaneously
- **GIVEN** a `6x8` grid where dropping a brick forms a horizontal run of three `@` blocks at `(0, 0), (0, 1), (0, 2)`
- **WHEN** `Command.DROP` finishes resolution
- **THEN** cells `(0, 0), (0, 1), (0, 2)` are empty (`Optional.empty()`), `matchesCleared` increments by `1`, `blocksCleared` increments by `3`, and `score` increases by `300`

#### Scenario 5.2: Gravity Cascade Chain Reaction
- **GIVEN** a grid where clearing a bottom match of three `#` blocks causes a `#` block and two `$` blocks above them to fall and align with two existing `$` blocks on row `0`
- **WHEN** `Command.DROP` finishes resolution
- **THEN** both waves of matches are cleared in a single drop turn, no blocks remain floating above empty cells, and `score` reflects the cascade multiplier (`wave 1` + `wave 2`)

---

### Requirement 6: Game Completion & Grid Overflow (`DEC-07`)
- **Completion (`GameStatus.COMPLETED`)**: When all bricks in the `BrickSource` have been dropped and all matches/cascades resolved without exceeding the grid height, the session status SHALL transition to `GameStatus.COMPLETED`.
- **Overflow (`GameStatus.GAME_OVER`)**: If dropping a brick causes any of its 3 blocks to be placed at `row >= height`, the session status SHALL immediately transition to `GameStatus.GAME_OVER`, and subsequent movement/drop commands SHALL be rejected.

#### Scenario 6.1: Placing All Bricks Transitions to COMPLETED
- **GIVEN** a brick queue containing 2 bricks on a `6x8` grid
- **WHEN** both bricks are dropped within bounds
- **THEN** `snapshot().remainingBricks()` is `0` and `snapshot().status()` is `GameStatus.COMPLETED`

#### Scenario 6.2: Overflowing Column Transitions to GAME_OVER
- **GIVEN** a `6x4` grid where column `2` already contains 2 blocks (`rows 0, 1`) and a `VERTICAL` brick (3 blocks high) is dropped at column `2` (requiring rows `2, 3, 4` where max row is `3`)
- **WHEN** `Command.DROP` is executed
- **THEN** `snapshot().status()` transitions to `GameStatus.GAME_OVER`
