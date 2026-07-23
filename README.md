# Dead Reckoning

Dead Reckoning is a six-room tactical stealth puzzle built with Godot 4.6. Preview the room, order the six supplied rounds, evade enemy sight, and clear the locked exit. Ricochet, piercing, terrain-altering, and armor-breaking ammunition turn each cylinder into a small sequencing puzzle.

## Run the game

Open `project.godot` in Godot 4.6 or newer and run the project, or use:

```sh
godot --path .
```

The active entry scene is `game/ui/title_menu.tscn`.

## Controls

- Move: W, A, S, D
- Aim: mouse
- Fire: left mouse button
- Pause/back: Escape, controller Start, or controller B
- Menu navigation: arrows or D-pad
- Confirm: Enter, Space, or controller A

## Tests

Run the headless suites from the repository root:

```sh
godot --headless --path . --script res://game/tests/scene_contract_tests.gd
godot --headless --path . --script res://game/tests/core_loop_tests.gd
godot --headless --path . --script res://game/tests/frontend_tests.gd
```

## Where to start

- Campaign order and metadata: `game/levels/level_catalog.tres`
- Visual room layouts: `game/levels/rooms/`
- High-level flow: `game/app/game_controller.gd`
- Room rules: `game/rooms/room_controller.gd`
- Profile and settings APIs: `game/app/game_session.gd`
- Reusable gameplay scenes: `game/player/`, `game/enemies/`, `game/bullets/`, and `game/environment/`

See `docs/architecture.md` for system boundaries and `docs/level_authoring.md` for the editor workflow.

