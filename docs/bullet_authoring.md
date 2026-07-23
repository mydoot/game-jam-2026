# Bullet authoring

Bullet types are `.tres` instances of `BulletDefinition` in `game/bullets/resources/`. Their editable properties are:

- `kind`: stable progression/save identifier
- `display_name` and `color`: planning, cylinder, and projectile presentation
- `speed` and `lifetime`: travel contract
- `damage`: reserved damage value
- `max_bounces`: wall ricochets available
- `pierces_enemies`: continues through defeated unarmored enemies
- `alters_terrain`: destroys `DestructibleWall`
- `breaks_armor`: allows a hit to defeat an armored enemy

Projectiles raycast against world layer 1 and enemy layer 4. New environmental collision must honor those layers or explicitly extend the projectile contract. A projectile must call `resolve()` exactly once so ammo failure waits for all in-flight shots.

To add a bullet safely:

1. Add a stable `Kind` value without reordering existing values.
2. Create a `.tres` resource; do not add a script factory branch.
3. Prefer expressing behavior through data. If a genuinely new collision behavior is required, add a focused property and test it in `core_loop_tests.gd`.
4. Add the resource as a level reward before any later level supplies it.
5. Give it a distinct accessible color and concise display name.
6. Run catalog, scene-contract, core-loop, frontend, and parser validation.

