# Forgotten Village collision test

Open res://tests/forgotten_village_collision/village_collision_test.tscn.
Enable Debug > Visible Collision Shapes and press F6 (Run Current Scene).
Click the running game for keyboard focus. Use W up, A left, S down, D right.
Use F8 in the editor to stop. Do not select or change the project's main scene.

The cyan square is unshaded and drawn above scenery for visibility.
Its dark triangle points up; its circular collider has radius 8 pixels.
Speed defaults to 180 pixels/second and diagonal movement is normalized.
The camera follows without smoothing. Spawn uses PlayerSpawn's global position.

Walk into building bases, carts, rubble, tree trunks, the shrine pedestal and boundaries.
Check edge sliding and corners with collision shapes visible.
Decorative artwork without existing colliders remains passable.
This is a collision test, not a production depth-sorting test.

The wrapper instances the original village without overrides.
Physical WASD polling does not change the Input Map.
Remove this folder through Godot's FileSystem dock when finished.
Godot may generate script UID sidecars in this folder; they are disposable test metadata.
