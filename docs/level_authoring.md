# Level authoring

1. Duplicate `game/rooms/room_template.tscn` into `game/levels/rooms/` and give it the next snake_case room filename.
2. Open the room in the 2D editor. Move `PlayerSpawn` and `Exit`.
3. Add instances of `solid_wall.tscn` beneath `Walls` and `cracked_wall.tscn` beneath `CrackedWalls`. Set each instance's `size` in the inspector.
4. Add instances of `enemy.tscn` beneath `Enemies`. Set `facing`, `armored`, `vision_range`, `vision_half_angle_degrees`, movement speed, and attack values in the inspector.
5. Keep gameplay nodes within the 960 × 600 room bounds. The four boundary walls are inherited from the template.
6. Duplicate a `game/levels/level_XX.tres` resource. Set a stable `level_id`, player-facing title/tutorial/description, and the room scene.
7. Assign exactly six bullet resources to `supplied_rounds` in firing-order-neutral supply order. Every supplied type must already be unlocked before this level.
8. Assign `unlock_reward` only when clearing the room introduces a bullet used by later rooms.
9. Add the level resource to `game/levels/level_catalog.tres` at the intended campaign position.
10. Run all three test suites from the root README. The scene-contract suite checks the room, exit, enemies, loadout count, and campaign unlock ordering.

Use the stable ID for persistence or analytics. Titles may change without breaking saves.

