# Conventions

## Folders and naming

Active game code lives under `game/` by feature. Keep each scene beside its behavior script and related resources. Paths, files, nodes used as data IDs, and resource IDs use `snake_case`; GDScript classes use `PascalCase`.

Art and VFX live under `assets/`. Documentation lives under `docs/`.

## Typed APIs and signals

Type exported properties, public method parameters, return values, and signal payloads. Prefer semantic signals such as `room_cleared` or `restart_requested` over exposing internal buttons. Use enums for closed action sets; do not route behavior with free-form strings.

## Scene ownership

Permanent node structure belongs in `.tscn` files. Collision shapes, visuals, areas, markers, and reusable panels must be visible in the editor. Scripts may instantiate reusable scenes and variable-length content, such as campaign cards or round buttons, but should not rebuild permanent scene trees in `_ready()`.

Controllers coordinate features; feature nodes own their local behavior. `GameController` must not reach into individual HUD buttons, and UI must not write raw save files.

## Testing

Every reusable gameplay scene needs a scene-contract assertion for named nodes and collision layers. Every level must instantiate through the catalog and supply exactly six already-unlocked bullets. Behavior changes need a focused core-loop test; menu, settings, save, or progression changes need a frontend test.

Before merging, run the editor parser/import pass, all headless suites, a main-scene smoke test, and a search for missing or legacy `res://` paths.
