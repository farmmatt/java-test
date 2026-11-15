# Domain Glossary (`java-test` — Falling Bricks Game)

This glossary defines the canonical ubiquitous language for the Falling Bricks console application. Every module, interface, record, test, and specification MUST use these exact terms.

---

## Block
A single indivisible unit within a `Brick` or occupying a single `Cell` on the `Grid`, marked with a validated non-whitespace character `Symbol`.
_Avoid:_ tile, square, piece-part, token, node

## Symbol
A validated printable non-whitespace character (from the configured `AllowedSymbolSet`) that identifies the type of a `Block` for matching purposes.
_Avoid:_ color, icon, charCode, glyph

## Brick
An immutable 3-block game piece (`List<Block>` of exact length 3) controlled by the player before being dropped onto the `Grid`, possessing an explicit `Orientation` (`HORIZONTAL` or `VERTICAL`) and a current spawn column index.
_Avoid:_ tetromino, shape, piece, bar, triad

## Orientation
The spatial alignment of a `Brick`: either `HORIZONTAL` ($1 \text{ row} \times 3 \text{ columns}$) or `VERTICAL` ($3 \text{ rows} \times 1 \text{ column}$).
_Avoid:_ direction, rotationAngle, layout, posture

## Grid
The 2D playing field of validated `GridDimensions` (`width` columns $\times$ `height` rows) where dropped `Block`s come to rest, matches are detected and cleared, and column gravity is applied. Row `0` is the bottom floor; row `height - 1` is the top row.
_Avoid:_ board, matrix, canvas, table, arena, field

## Cell
A single coordinate `(row, column)` within the `Grid` that is either empty (`Optional.empty()`) or occupied by a single `Block` (`Optional<Block>`).
_Avoid:_ slot, box, point, pixel, bucket

## Command
A validated player instruction issued during a turn: `MOVE_LEFT` (`L`), `MOVE_RIGHT` (`R`), `ORIENT` (`O` — toggles `HORIZONTAL` $\leftrightarrow$ `VERTICAL`), `CYCLE` (`C` — shifts the 3 block symbols within the brick), `DROP` (`D` — drops and locks the active brick onto the `Grid`), or `QUIT` (`Q`).
_Avoid:_ action, event, keystroke, inputString, move

## Match
A contiguous horizontal or vertical run of **3 or more** occupied `Cell`s on the `Grid` containing identical `Block` `Symbol`s. All contiguous runs of $\ge 3$ present on the `Grid` at the same step are cleared simultaneously.
_Avoid:_ combo, line, group, cluster, streak

## Cascade
A chain reaction that occurs when clearing one or more `Match`es causes unsupported `Block`s above the cleared coordinates to fall under column gravity and form new contiguous `Match`es of $\ge 3$ identical `Symbol`s.
_Avoid:_ avalanche, reflow, secondaryClear, ripple

## GameStateSnapshot
An immutable, defensively copied value object (`record`) representing the complete observable state of a game session at a point in time: `GridDimensions`, immutable 2D cell snapshot, active `Brick` (if any), remaining `Brick` queue count, total `matchesCleared`, total `blocksCleared`, `score`, `GameStatus` (`IN_PROGRESS`, `COMPLETED`, `GAME_OVER`, `QUIT`), and last `StepOutcome`.
_Avoid:_ context, mutableState, boardView, dump

## ValidationResult
A sealed algebraic result type (`Valid<T>` or `Invalid<T>`) returned by all configuration, brick, grid-dimension, and command validators so invalid inputs are caught and reported deterministically without unchecked crashes or console-output scraping.
_Avoid:_ booleanFlag, rawException, stringError
