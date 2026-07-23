# Architecture

## Scene flow

`title_menu.tscn` opens the level select or asks `GameSession` to play the current continuation. `level_select.tscn` reads the catalog and selects an unlocked level. `game.tscn` owns `GameController`, one `RoomController`, the room container, HUD, and pause menu.

`SceneNavigator` owns fade transitions. UI and gameplay code request semantic destinations through `GameSession`; they do not change the scene tree directly.

## Services

- `GameSession` owns selected level, last-played level, completion, unlock state, and public progression queries.
- `ProfileStore` is the only class that reads or writes `user://profile.cfg`. Save version 1 remains compatible with the prototype format. Invalid entries fall back to safe defaults.
- `SettingsService` owns volume, mute, and fullscreen behavior.
- `SceneNavigator` owns fade overlays and scene changes.
- `LevelCatalog` is the ordered source for campaign count, room metadata, unlock bounds, menus, gameplay, and tests.

## Gameplay state flow

```text
PLANNING → PLAYING → EXIT_UNLOCKED → COMPLETE
               └──→ FAILED
```

`GameController` owns the high-level state and completion actions. `RoomController` owns the active room: player/enemy binding, live enemy count, outstanding projectile count, ammo failure, exit lock, and the temporary exit-camera reveal.

When the final enemy dies, shooting is disabled immediately but player movement remains enabled. The exit unlocks, the camera reveals it for 0.85 seconds, and then player follow resumes. A room fails only after the cylinder is empty and every fired projectile has resolved.

## Signals

`RoomController` emits:

- `room_started`
- `enemy_count_changed(remaining)`
- `room_cleared`
- `room_failed(reason)`
- `exit_entered`

The HUD exposes semantic start, restart, and typed completion-action signals. Feature panels own their internal controls.

## Collision layers

| Layer | Value | Owners |
| --- | ---: | --- |
| World | 1 | solid walls, cracked walls, locked exit |
| Player | 2 | player body |
| Enemy | 4 | enemy bodies |

Players collide with world and enemies. Enemies collide with world and player. Enemy attack areas monitor the player layer. Projectiles raycast against world and enemy layers. Sight rays test world occlusion before accepting the player hit.

## Save data flow

UI or gameplay mutates progression through `GameSession`. The session serializes a dictionary to `ProfileStore`, which writes the versioned `ConfigFile`. Loading validates level indices against `LevelCatalog`, always restores the three initial bullet types, and ignores unsupported save versions rather than exposing partially corrupt state.

