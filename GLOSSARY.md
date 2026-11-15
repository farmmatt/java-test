# Domain Glossary (`java-test` — Falling Bricks Game)

This glossary defines the canonical ubiquitous language for the Falling Bricks console application. Every module, interface, record, test, and specification MUST use these exact terms.

---

## Block
A single indivisible unit within a `Brick` or occupying a single `Cell` on the `Grid`, marked with a validated printable ASCII `Symbol`. Once a `Brick` locks into the `Grid`, its `Block`s become independent stacked grid occupants (the original rigid `Brick` shape no longer applies when rows clear below them).
_Avoid:_ tile, square, piece-part, token, node

## Symbol
A validated printable non-whitespace 7-bit ASCII character (`0x21..0x7E`, within the configured `AllowedSymbolSet`) that identifies a `Block` for display and horizontal matching.
_Avoid:_ color, icon, unicodeChar, glyph

## Brick
An immutable 3-block game piece (`List<Block>` of exact length 3 in v1) controlled by the player while falling. While airborne, a `Brick` behaves as a **rigid bar** with an explicit `Orientation` (`HORIZONTAL` $1 \times 3$ or `VERTICAL` $3 \times 1$) and top-row random spawn column.
_Avoid:_ tetromino, shape, piece, triad

## Orientation
The spatial alignment of an airborne `Brick`: either `HORIZONTAL` (`widthSpan = 3, heightSpan = 1`) or `VERTICAL` (`widthSpan = 1, heightSpan = 3`).
_Avoid:_ direction, rotationAngle, layout, posture

## Grid
The 2D playing field of validated `GridDimensions` (`width` columns $\times$ `height` rows, where `min >= largestConfiguredBrickSpan [3]` and `max <= configuredMax [default 20x20]`). Row `0` is the bottom floor; row `height - 1` is the top spawn row.
_Avoid:_ board, matrix, canvas, table, arena, field

## Cell
A single coordinate `(row, column)` within the `Grid` that is either empty (`Optional.empty()`) or occupied by a single settled `Block` (`Optional<Block>`).
_Avoid:_ slot, box, point, pixel, bucket

## SeededBrickQueue
A finite, deterministic sequence of `Brick`s (and their initial top-row spawn columns) generated from a `long seed` via a pseudo-random stream (`java.util.Random(seed)`). Guaranteed by validation to contain enough bricks to potentially cause a **Vertical Overflow**. Reusing the same `seed` on **Retry** reproduces the exact same level.
_Avoid:_ randomDeck, infiniteStream, unseededGenerator

## Command
A validated instruction processed by the engine:
- `MOVE_LEFT` (`L`): Shift airborne `Brick` 1 column left (if unobstructed).
- `MOVE_RIGHT` (`R`): Shift airborne `Brick` 1 column right (if unobstructed).
- `ORIENT` (`O`): Toggle airborne `Brick` `HORIZONTAL` $\leftrightarrow$ `VERTICAL` (if unobstructed).
- `CYCLE` (`C`): Cycle the 3 `Block` symbols within the airborne `Brick`.
- `TICK` (`T` / Timer): Advance airborne `Brick` down 1 row as a **rigid bar** (locking if any block touches the floor or a stacked `Block` below it).
- `DROP` (`D`): Hard-drop airborne `Brick` straight down as a **rigid bar** until it locks.
- `RETRY` (`RETRY`): Reset the level with the **exact same `seed`**, grid dimensions, and brick count.
- `QUIT` (`Q`): End the session cleanly.
_Avoid:_ action, event, keystroke, inputString

## RowClear & Match
When a `Brick` locks into the `Grid`, any horizontal row that is **completely full** across all columns (or contains a horizontal contiguous match of identical `Symbol`s) clears. Once cleared, **original `Brick` rigidity no longer applies to stacked `Block`s**: all surviving `Block`s above cleared cells drop independently under column gravity.
_Avoid:_ combo, line, cluster, streak

## VerticalOverflow
The out-of-bounds condition (`ValidationErrorCode.VERTICAL_OVERFLOW`) that occurs when a locked `Brick` extends above `height - 1` (or cannot spawn at the top row because cells are already occupied), immediately transitioning the session to `GameStatus.GAME_OVER`.
_Avoid:_ ceilingCrash, stackOut, topOut

## GameConfiguration
An immutable, validated configuration record holding all tunable parameters (`width`, `height`, `maxWidth` [default `20`], `maxHeight` [default `20`], `brickCount`, `seed`, `tickIntervalMs`, `allowedSymbols`), loaded from `application.properties` and/or CLI arguments with zero hardcoded file paths.
_Avoid:_ globals, constants, settingsMap

## GameStateSnapshot
An immutable, defensively copied value object (`record`) representing the complete observable state of a game session at a point in time: `GridDimensions`, settled `cells`, airborne `ActiveBrick`, `seed`, `remainingBricks`, `rowsCleared`, `matchesCleared`, `score`, `GameStatus`, and `StepOutcome`.
_Avoid:_ context, mutableState, boardView, dump

## ValidationResult
A sealed algebraic result type (`Valid<T>` or `Invalid<T>`) returned by all configuration, dimension, brick, and command validators so invalid inputs are caught and reported deterministically on state.
_Avoid:_ booleanFlag, rawException, stringError
