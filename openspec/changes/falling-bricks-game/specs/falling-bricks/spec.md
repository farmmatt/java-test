# Capability Specification: Falling Bricks Game (`falling-bricks`)

- **OpenSpec Change**: `falling-bricks-game`
- **ADR Reference**: `docs/adr/0001-falling-bricks-architecture-and-decision-matrix.md`
- **Ubiquitous Language**: `GLOSSARY.md`

---

## ADDED Requirements

### Requirement 1: Configurable Parameters, Grid Bounds & Defensive State Encapsulation (`Q5`)
The system SHALL configure game parameters via an immutable `GameConfiguration` value object loaded from defaults, an optional `InputStream`/`Properties` stream (`application.properties`), and optional CLI flag overrides (`--width`, `--height`, `--max-width`, `--max-height`, `--bricks`, `--seed`, `--tick-ms`, `--symbols`) with zero hardcoded file paths.
The system SHALL represent the playing field as an immutable `Grid` value object with configurable `width` and `height`.
- Negative or zero grid bounds SHALL NEVER be allowed (`ValidationErrorCode.GRID_TOO_SMALL`).
- Minimum grid dimensions SHALL fit the largest configured brick (`minWidth >= maxBrickSpan` [3] and `minHeight >= maxBrickSpan` [3]; otherwise `ValidationErrorCode.GRID_TOO_SMALL`).
- Maximum grid dimensions SHALL be configurable (`maxWidth`, `maxHeight`) and SHALL default to `20 x 20` (`width <= maxWidth` and `height <= maxHeight`; otherwise `ValidationErrorCode.GRID_TOO_LARGE`).
- `Grid` SHALL never expose mutable internal arrays or collections; any snapshot of grid cells SHALL be a defensive copy.

#### Scenario 1.1: Create Valid Grid Within Configurable Bounds
- **GIVEN** a `GameConfiguration` with default `maxWidth = 20`, `maxHeight = 20`, and `maxBrickSpan = 3`
- **WHEN** `Grid.create(6, 12)` or `Grid.create(20, 20)` is invoked
- **THEN** the result SHALL be `ValidationResult.Valid<Grid>` with all cells initialized to empty (`Optional.empty()`).

#### Scenario 1.2: Reject Negative, Zero, or Undersized Grid Dimensions (`< Largest Brick`)
- **GIVEN** largest configured brick span `maxBrickSpan = 3`
- **WHEN** `Grid.create(width, height)` is invoked with `width <= 0`, `height <= 0`, `width < 3`, or `height < 3` (e.g., `Grid.create(-5, 10)`, `Grid.create(0, 10)`, or `Grid.create(2, 10)`)
- **THEN** the result SHALL be `ValidationResult.Invalid` with error code `ValidationErrorCode.GRID_TOO_SMALL`.

#### Scenario 1.3: Reject Oversized Grid Dimensions Beyond Configurable Max (`Default 20x20`)
- **GIVEN** a `GameConfiguration` with default `maxWidth = 20` and `maxHeight = 20`
- **WHEN** `GameConfiguration.validate(...)` or `Grid.create(width, height, maxWidth, maxHeight)` is invoked with `width = 21, height = 12` or `width = 6, height = 25`
- **THEN** the result SHALL be `ValidationResult.Invalid` with error code `ValidationErrorCode.GRID_TOO_LARGE`.

#### Scenario 1.4: Support Custom Configured Maximum Grid Size
- **GIVEN** a `GameConfiguration` with custom `maxWidth = 30` and `maxHeight = 30`
- **WHEN** a grid of `width = 25, height = 25` is validated
- **THEN** the result SHALL be `ValidationResult.Valid`.

#### Scenario 1.5: Defensive Copy of Grid State
- **GIVEN** a valid `Grid` containing placed blocks
- **WHEN** a caller obtains `grid.cellsSnapshot()` and mutates the returned 2D array or list
- **THEN** the internal state of the original `Grid` instance SHALL remain completely unmodified.

---

### Requirement 2: Immutable 3-Block Brick Value Type & Printable 7-Bit ASCII Validation (`Q5`)
The system SHALL represent each `Brick` as an immutable value object containing an ordered list of 3 `Block` elements and a non-null `Orientation` (`HORIZONTAL` or `VERTICAL`).
- Each `Block` SHALL validate that its symbol is a printable, non-whitespace **7-bit ASCII** character (`0x21 <= symbol <= 0x7E`).
- `Brick` SHALL defensively copy its `List<Block>` on construction via `List.copyOf` and expose no mutable fields.
- To support Future Expansion Point 2 without overbuilding, `Brick` SHALL expose `widthSpan()`, `heightSpan()`, and `occupiedPositions(anchorCol, anchorRow)` computed from its blocks and orientation.

#### Scenario 2.1: Create Valid 3-Block Brick with Printable ASCII Symbols
- **GIVEN** three valid blocks `[Block('@'), Block('#'), Block('$')]` and `Orientation.HORIZONTAL`
- **WHEN** `Brick.create(blocks, Orientation.HORIZONTAL)` is called
- **THEN** the result SHALL be `ValidationResult.Valid<Brick>` with `widthSpan() == 3` and `heightSpan() == 1`.

#### Scenario 2.2: Defensive Copy of Caller Block Collection
- **GIVEN** a mutable `ArrayList<Block>` passed to `Brick.create(mutableList, Orientation.VERTICAL)`
- **WHEN** `mutableList.clear()` or `mutableList.set(0, ...)` is called after creation
- **THEN** `brick.blocks()` SHALL still contain the original 3 blocks in their original order, and calling `brick.blocks().add(...)` SHALL throw `UnsupportedOperationException`.

#### Scenario 2.3: Reject Blank, Control, or Non-ASCII Block Symbols
- **GIVEN** a character that is whitespace (`' '`, `'\t'`, `'\n'`), an ASCII control character (`'\0'`, `0x7F`), or a non-ASCII Unicode character (`'★'`, `0x00E9`)
- **WHEN** `Block.create(ch)` is called
- **THEN** the result SHALL be `ValidationResult.Invalid` with error code `ValidationErrorCode.INVALID_SYMBOL`.

#### Scenario 2.4: Reject Invalid Orientation or Wrong Block Count
- **GIVEN** a null `Orientation` or a list of `0`, `1`, `2`, or `4` blocks
- **WHEN** `Brick.create(blocks, orientation)` is called
- **THEN** the result SHALL be `ValidationResult.Invalid` with `ValidationErrorCode.INVALID_ORIENTATION` or `ValidationErrorCode.INVALID_BRICK_SIZE`.

---

### Requirement 3: Seeded Pseudo-Random Queue, Overflow-Capable Brick Count & Same-Seed Retry (`Q1` & `Q2`)
The system SHALL generate bricks and their initial top-row spawn columns using a deterministic pseudo-random stream based on a configurable `long seed` (`java.util.Random(seed)`).
- The total number of bricks in a level (`brickCount`) SHALL be finite and configurable.
- `GameConfiguration` and `SeededBrickGenerator` SHALL validate that `brickCount` is large enough to potentially cause a vertical overflow on the configured grid: `brickCount * maxBrickSpan > grid.height` (i.e., `brickCount >= (grid.height / 3) + 1`). If `brickCount` is smaller, validation SHALL fail with `ValidationErrorCode.INSUFFICIENT_BRICK_COUNT`.
- Each brick SHALL spawn at a pseudo-random valid column (`0 <= spawnCol <= grid.width - brick.widthSpan()`) on the top of the grid (`anchorRow = grid.height - 1` for `HORIZONTAL`, `anchorRow = grid.height - 3` for `VERTICAL`).
- When a user executes `Command.RETRY`, the engine SHALL reset the level using the **exact same `seed`**, producing the identical sequence of bricks and top spawn columns.

#### Scenario 3.1: Predictive Determinism from Identical Seed
- **GIVEN** two `SeededBrickGenerator` instances initialized with `seed = 987654321L`, `brickCount = 15`, `gridWidth = 6`, and `symbols = "@#$%&"`
- **WHEN** all 15 bricks and spawn columns are drawn from both generators
- **THEN** both generators SHALL produce the exact same sequence of `Brick` symbols, orientations, and `spawnCol` coordinates.

#### Scenario 3.2: Reject Brick Count Too Small to Cause Overflow
- **GIVEN** a grid of `height = 12` (requiring at least `(12 / 3) + 1 = 5` bricks of span 3 to potentially overflow vertically)
- **WHEN** `GameConfiguration` or `SeededBrickGenerator` is initialized with `brickCount = 4` (or `<= 0`)
- **THEN** validation SHALL return `ValidationResult.Invalid` with error code `ValidationErrorCode.INSUFFICIENT_BRICK_COUNT`.

#### Scenario 3.3: Same-Seed Level Retry (`Command.RETRY`)
- **GIVEN** an active or finished game session started with `seed = 42L` where several bricks have been placed
- **WHEN** `engine.execute(Command.RETRY)` is invoked
- **THEN** the grid SHALL reset to empty, `score` and `clearedCount` SHALL reset to `0`, `status` SHALL be `GameStatus.ACTIVE`, `snapshot().seed()` SHALL remain `42L`, and the spawned brick sequence SHALL exactly match the initial run of `seed = 42L`.

---

### Requirement 4: Command Validation, Timer-Driven Fall (`TICK`), & Rigid-Bar Drop Physics (`Q2` & `Q3`)
The system SHALL parse raw player commands via `CommandParser` and reject empty, null, whitespace-only, or unknown commands with `ValidationErrorCode.EMPTY_INPUT` or `ValidationErrorCode.UNKNOWN_COMMAND`.
While a brick is airborne:
- **`LEFT` (`L`) / `RIGHT` (`R`)**: Moves the active brick 1 column left or right if all 3 blocks remain within `0 .. width - 1` and do not collide with existing stacked blocks; otherwise returns `ValidationErrorCode.OUT_OF_BOUNDS_MOVE` (or `COLLISION_BLOCKED`) without mutating state.
- **`ORIENT` (`O`)**: Toggles between `HORIZONTAL` and `VERTICAL` around the current anchor position if all 3 blocks fit within grid bounds without collision; otherwise returns `ValidationErrorCode.OUT_OF_BOUNDS_MOVE` without mutating state.
- **`CYCLE` (`C`)**: Cyclically shifts the 3 blocks within the active brick (`[b0, b1, b2] -> [b2, b0, b1]`).
- **`TICK` (`T` / Timer Step)**: Moves the active brick down by 1 row as a **rigid 3-block bar** if all 3 blocks can occupy `row - 1` without hitting the floor (`row < 0`) or any stacked block; if any of its 3 blocks cannot move down 1 row, the entire brick locks in place as a rigid bar at its current row.
- **`DROP` (`D`)**: Immediately drops the active brick straight down as a **rigid 3-block bar** to the lowest row where all 3 blocks remain unobstructed above the floor/stack, and locks all 3 blocks into the `Grid`.

#### Scenario 4.1: Reject Empty and Dodgy Commands
- **GIVEN** a `TextCommandParser`
- **WHEN** `parse("")`, `parse("   ")`, or `parse(null)` is called
- **THEN** it SHALL return `ValidationResult.Invalid(ValidationErrorCode.EMPTY_INPUT)`
- **AND WHEN** `parse("JUMP 99")` or `parse("$$$")` is called
- **THEN** it SHALL return `ValidationResult.Invalid(ValidationErrorCode.UNKNOWN_COMMAND)`.

#### Scenario 4.2: Rigid-Bar Drop of Horizontal Brick Over Uneven Stack (`Q3`)
- **GIVEN** a `6 x 12` grid where column `1` has stacked blocks up to `row = 2` (`(1,0), (1,1), (1,2)` occupied) while columns `2` and `3` are completely empty
- **AND** an active `HORIZONTAL` brick `[Block('@'), Block('#'), Block('$')]` spanning columns `1, 2, 3` at top row `11`
- **WHEN** `engine.execute(Command.DROP)` is called
- **THEN** the brick SHALL stop as a **rigid horizontal bar** at `row = 3` (because its leftmost block at `col = 1` contacts the stacked block at `(1, 2)`), locking `(1, 3) = '@'`, `(2, 3) = '#'`, and `(3, 3) = '$'`.

#### Scenario 4.3: Timer `TICK` Steps Down One Row Until Contact Locks Brick (`Q2` & `Q3`)
- **GIVEN** an empty `6 x 6` grid with a `HORIZONTAL` brick spawned at `row = 5, col = 1`
- **WHEN** `engine.execute(Command.TICK)` is invoked 5 times
- **THEN** the active brick's `anchorRow` SHALL decrement from `5` to `4`, `3`, `2`, `1`, and `0` while remaining `ACTIVE`
- **AND WHEN** `engine.execute(Command.TICK)` is invoked a 6th time at `row = 0`
- **THEN** the brick SHALL lock into `row = 0` and the next brick in the seeded queue SHALL spawn at the top of the grid.

---

### Requirement 5: Horizontal Row Clearing / Matching & Individual-Block Gravity on Stacked Blocks (`Q4`)
Once a brick locks into the `Grid`, its 3 blocks become independent stacked `Block` cells (the original rigid 3-block brick shape is no longer applied to stacked blocks).
After every brick lock:
1. The system SHALL detect all **full horizontal rows** (every column `0 .. width - 1` in row `r` is occupied) AND all **horizontal contiguous symbol matches** (`>= 3` adjacent cells in the same horizontal row `r` containing the identical block symbol).
2. All matched/full horizontal cells SHALL be cleared simultaneously.
3. **Individual-Block Gravity**: Every remaining stacked block above a cleared cell SHALL drop straight down in its own column until it rests on `row = 0` or another stacked block directly beneath it — regardless of what brick it originally belonged to.
4. Steps 1–3 SHALL repeat in a chain-cascade loop until no further horizontal full rows or horizontal matches exist.

#### Scenario 5.1: Full Horizontal Row Clear Drops Stacked Blocks Above via Individual Gravity (`Q4`)
- **GIVEN** a `6 x 12` grid where a rigid horizontal brick `[@, #, $]` was previously locked as a bridge at `row = 2, cols = 1..3` (supported only at `(1, 1)` and `(1, 0)`), and `row = 0` becomes completely filled across all columns `0..5`
- **WHEN** `row = 0` clears
- **THEN** all blocks above `row = 0` SHALL lose their original brick rigidity and drop independently under column gravity:
  - `(1, 1)` drops to `(1, 0)` and `(1, 2) = '@'` drops to `(1, 1)`,
  - `(2, 2) = '#'` (which had empty cells at `(2, 1)` and `(2, 0)`) drops all the way to the floor at `(2, 0)`, and
  - `(3, 2) = '$'` drops all the way to the floor at `(3, 0)`.

#### Scenario 5.2: Horizontal Contiguous Symbol Match Clear & Chain Cascade
- **GIVEN** a grid where locking a brick creates 3 contiguous `'@'` blocks horizontally at `(1, 0), (2, 0), (3, 0)`, and above them sit blocks that will form another horizontal match once dropped
- **WHEN** the lock resolution executes
- **THEN** the first horizontal match SHALL clear, individual-block column gravity SHALL drop the blocks above, the secondary horizontal match SHALL clear in chain step 2, and `PlacementOutcome.chainCount()` SHALL equal `2`.

---

### Requirement 6: Vertical Overflow Out-of-Bounds Error (`Q5`), Level Completion & SLF4J Logging
- **Vertical Overflow**: If a newly spawned brick at the top of the grid overlaps an already-occupied cell, or if a locked brick extends beyond `height - 1` after row clearing, the engine SHALL return `ValidationErrorCode.VERTICAL_OVERFLOW` and transition the game status to `GameStatus.GAME_OVER`.
- **Level Completion**: When the finite seeded queue is exhausted and the final brick locks and resolves without vertical overflow, the engine SHALL transition the game status to `GameStatus.COMPLETED`.
- **Structured Logging**: The system SHALL log session lifecycle, seed, brick spawns, commands, clears, and validation errors via `SLF4J` (`org.slf4j.Logger`) without writing log output to the player's `GameRenderer` stream.

#### Scenario 6.1: Vertical Overflow Triggers Out-of-Bounds Game Over (`Q5`)
- **GIVEN** a `6 x 6` grid where column `2` is stacked up to the top row (`row = 5`)
- **WHEN** a brick locks or spawns requiring cell `(2, 5)` (or `row >= 6`)
- **THEN** the engine SHALL report `ValidationErrorCode.VERTICAL_OVERFLOW` and `engine.snapshot().status()` SHALL be `GameStatus.GAME_OVER`.

#### Scenario 6.2: Exhausting the Seeded Brick Queue Completes the Level
- **GIVEN** a valid seeded queue with 1 brick remaining and an unobstructed grid
- **WHEN** the player drops (`Command.DROP`) the final brick and it locks within bounds
- **THEN** `engine.snapshot().status()` SHALL transition to `GameStatus.COMPLETED`.
