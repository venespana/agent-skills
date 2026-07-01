# GDScript Performance

Performance optimization techniques for GDScript and Godot 4. Based on official Godot docs, Context7 queries, and community benchmarks. Covers typed vs dynamic, node management, memory, rendering, and profiling.

---

## 1. Typed GDScript: The First Optimization

Static typing gives ~30–50% faster execution. The GDScript interpreter skips reflection when types are known. Enable type inference warnings in `Project Settings → debug/gdscript/warnings/`.

```gdscript
# BAD — dynamic, slower
func processMovement(delta):
    var speed = 300
    var velocity = Vector2(0, 0)
    velocity.x = speed * delta
    return velocity

# GOOD — statically typed, faster
func process_movement(delta: float) -> Vector2:
    var speed: float = 300.0
    var velocity: Vector2 = Vector2.ZERO
    velocity.x = speed * delta
    return velocity
```

**Why**: Typed GDScript uses optimized opcodes when operand and argument types are known at parse time. The compiler can skip runtime type checks and emit more efficient bytecode.

**Rule**: Type everything — function signatures, parameters, return types, member variables, and local variables. No mixing of `var x = 5` and `var y: int = 5` in the same project.

---

## 2. `_process` vs `_physics_process`

Choose the right callback for your use case.

### `_process(delta)` — frame-rate-dependent
- Called every visible frame
- `delta` varies with frame rate (slower machine = larger delta)
- Use for: visual updates, animations, UI logic

### `_physics_process(delta)` — fixed timestep
- Called at a fixed rate (default 60 Hz)
- `delta` is consistent regardless of frame rate
- Use for: physics calculations, kinematic movement, game logic that must be deterministic

```gdscript
# GOOD — physics in _physics_process
func _physics_process(delta: float) -> void:
    velocity += gravity * delta
    move_and_slide()

# GOOD — visual in _process
func _process(delta: float) -> void:
    sprite.rotation += rotation_speed * delta
```

### `_unhandled_input` over `_process` for input

```gdscript
# Anti-pattern — checking input every frame
func _process(delta: float) -> void:
    if Input.is_action_pressed("ui_accept"):
        shoot()

# GOOD — react only on actual input events
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):
        shoot()
```

**Why**: `_process` fires every frame regardless of input. If you only act on input, `_unhandled_input` fires only on frames with detected input — saving CPU.

---

## 3. Node Management Performance

### `call_group` vs individual calls

```gdscript
# Slow if many nodes — iterates all nodes and calls immediately
get_tree().call_group("enemies", "take_damage", 10)

# Safer for performance — deferred, avoids stutter
get_tree().call_group_flags(
    SceneTree.GROUP_CALL_DEFERRED | SceneTree.GROUP_CALL_REVERSE,
    "enemies", "take_damage", 10
)
```

**Why**: `call_group()` acts on all nodes immediately. For large groups, this can cause a visible frame hitch. Deferred calls execute at the end of the current frame.

### Cache node references — avoid repeated `get_node()`

```gdscript
# BAD — string lookup every call
func _process(delta: float) -> void:
    $Player/HealthBar.value = health

# GOOD — cached reference
@onready var health_bar: ProgressBar = $Player/HealthBar

func _process(delta: float) -> void:
    health_bar.value = health
```

**Why**: `get_node()` traverses the scene tree. Even though it's fast, doing it every frame is unnecessary. `@onready` resolves once at `_ready()`.

### String paths in `_process` — anti-pattern

```gdscript
# VERY BAD — string path every frame
func _process(delta: float) -> void:
    var hp = get_node("../../../UI/HealthBar").value

# GOOD — cached path
@onready var health_bar: ProgressBar = $HealthBar

func _process(delta: float) -> void:
    health_bar.value = current_health
```

**Why**: String-based `get_node()` parses the path string every call. For hot paths (`_process`, `_physics_process`), cache the reference.

---

## 4. Signal Performance

### Connect/disconnect lifecycle

```gdscript
# Connect in _enter_tree, disconnect in _exit_tree
func _enter_tree() -> void:
    player.died.connect(_on_player_died)

func _exit_tree() -> void:
    if player.died.is_connected(_on_player_died):
        player.died.disconnect(_on_player_died)

func _on_player_died() -> void:
    get_tree().reload_current_scene()
```

**Why**: Connected signals keep objects alive (reference cycle). Disconnecting before the node is freed prevents leaked references.

### One-shot connections

```gdscript
# Fire once, auto-disconnect
player.died.connect(_on_player_died, CONNECT_ONE_SHOT)

func _on_player_died() -> void:
    show_game_over_screen()
```

**Why**: One-shot connections auto-disconnect after firing. Useful for one-time events (death, level complete) without manual disconnect logic.

### Lambda connections and manual disconnection

```gdscript
# Lambda capturing a variable — MUST disconnect manually
var toughness_modifier: float = 1.5

func _enter_tree() -> void:
    enemy.damaged.connect(func(amount: int):
        apply_damage(amount * toughness_modifier)
    )

func _exit_tree() -> void:
    enemy.damaged.disconnect(Callable())  # Disconnect all lambdas
```

**Why**: Godot's auto-disconnect on free doesn't track lambdas that capture variables. You must disconnect explicitly.

---

## 5. Memory: `preload` vs `load`

```gdscript
# preload — loads at compile/script-load time
const PLAYER_SCENE = preload("res://player/player.tscn")

# load — loads when statement is reached (runtime)
var dynamic_scene = load("res://enemies/" + enemy_type + ".tscn")
```

**When to use `preload`**:
- Path is always the same (constant)
- Resource is always needed when the script loads
- You want the editor to provide autocompletion

**When to use `load`**:
- Path is only known at runtime
- Resource may never be needed (lazy loading)
- You want to allow the exported value to override the default

```gdscript
# Export overrides preload's value in scene instances
@export var enemy_scene: PackedScene = preload("res://enemies/goblin.tscn")
```

**Why**: `preload()` consumes memory at script-load time. If you have 50 preloaded scenes but only use 2, you wasted memory. `load()` fetches on demand.

### Resource caching

```gdscript
# All loads of the same path return the SAME in-memory object
var tex1 = load("res://icon.png")  # First load
var tex2 = load("res://icon.png")  # Returns cached reference
# tex1 == tex2  (same object)
```

**Why**: Godot caches loaded resources. `load()` doesn't re-read from disk. To get a fresh copy, use `duplicate()`.

### `queue_free()` vs `free()`

```gdscript
# queue_free() — deferred, safe, recommended
enemy.queue_free()  # Freed at end of frame after all references settled

# free() — immediate, dangerous
enemy.free()  # Frees NOW — children may orphan, references may break
```

**Why**: `queue_free()` defers deletion to a safe point in the frame. `free()` is immediate and can orphan children or break references in other nodes. **Never call `free()` on a node inside its own callback.**

---

## 6. Object Pooling

Instantiating and freeing nodes every frame is expensive. Pool objects instead.

```gdscript
class_name BulletPool
extends Node2D

const POOL_SIZE := 50

var _pool: Array[Bullet] = []
var _active: Array[Bullet] = []

@export var bullet_scene: PackedScene

func _ready() -> void:
    for i in POOL_SIZE:
        var bullet = bullet_scene.instantiate()
        bullet.visible = false
        _pool.append(bullet)
        add_child(bullet)

func spawn(position: Vector2, direction: Vector2) -> Bullet:
    var bullet: Bullet = _pool.pop_front()
    bullet.global_position = position
    bullet.direction = direction
    bullet.visible = true
    bullet.body.enter_tree()  # Re-activate
    _active.append(bullet)
    return bullet

func despawn(bullet: Bullet) -> void:
    var idx = _active.find(bullet)
    if idx >= 0:
        _active.remove_at(idx)
        _pool.append(bullet)
        bullet.visible = false
```

**Why**: Object pooling amortizes allocation cost. Pre-instantiate N objects, reuse them. For bullet hell games or particle systems, this is the difference between 60fps and 20fps.

---

## 7. Rendering Optimization

### `visible` vs `process_mode`

```gdscript
# Hiding vs pausing
node.visible = false      # Still updates in _process/_physics_process
node.process_mode = Node.PROCESS_MODE_DISABLED  # Completely paused
```

**Why**: `visible = false` only hides rendering. The node still runs its `_process`. For distant or disabled entities, use `PROCESS_MODE_DISABLED` to stop all processing.

### CanvasLayer for UI overlays

```gdscript
# UI on a separate CanvasLayer — not affected by world camera/transforms
var ui_layer: CanvasLayer = CanvasLayer.new()
add_child(ui_layer)
```

**Why**: UI elements on a `CanvasLayer` render independently of the world. Moving the world camera doesn't trigger UI re-renders.

### Batching and draw calls

- **Reduce unique materials**: Share materials across similar objects. Each unique material triggers a new draw call.
- **Use `MultiMeshInstance2D/3D`**: One draw call for thousands of instanced objects (trees, grass, particles).
- **Static content as baked**: Lightmaps (`LightmapGI`), navmesh baking, and baked shadows reduce runtime cost.

### Culling

Godot auto-culls objects outside the viewport. For large scenes:
- Use `OccluderShape2D/3D` for occlusion culling
- Set `geometry/standard_fallback/max_messages_per_frame` in Project Settings to diagnose culling issues

---

## 8. Physics Optimization

### Collision layers and masks

```gdscript
# Define what this object collides with
collision_layer = 0b0001  # Layer 1 only
collision_mask = 0b0010    # Collides with layer 2 only

# Disable layers you don't need
collision_layer = 0b0000  # No collision layer — used as trigger area
```

**Why**: Every collision check costs CPU. Fewer layers checked = less physics work. Design your collision layers explicitly, don't leave everything on layer 1.

### Shapes over bodies

```gdscript
# BAD — too many CollisionShape2D on separate Area2Ds
# GOOD — compound shape on one RigidBody2D
```

- One `RigidBody2D` with multiple `CollisionShape2D` children costs less than multiple separate bodies.
- Use `CollisionShape2D` (static) over `Area2D` (trigger) for static geometry.

### PhysicsServer direct access

```gdscript
# For advanced use: bypass the scene tree and talk to the server
PhysicsServer2D.body_set_state RigidBody2D
```

**When**: Only when you have thousands of physics objects and the scene tree overhead is measurable. For most games, the scene tree physics API is sufficient.

---

## 9. Profiling Tools

### Built-in profiler

`Debugger → Profiler` in the editor. Records:
- Function call counts and self-time
- Total time per frame
- Sortable by time/calls

### `print_stray_nodes()`

```gdscript
# Call this in _exit_tree to find leaked nodes
func _exit_tree() -> void:
    print_stray_nodes()  # Prints nodes still in memory
```

**Why**: Leaked nodes (not freed) accumulate over time and cause memory growth. `print_stray_nodes()` surfaces them.

### Frame budget monitoring

```gdscript
# Check if you're within frame budget
func _process(delta: float) -> void:
    var frame_ms = Time.get_ticks_msec()
    # ... game logic ...
    frame_ms = Time.get_ticks_msec() - frame_ms
    if frame_ms > 16:  # 60fps = ~16.6ms per frame
        print("OVER BUDGET: ", frame_ms, "ms")
```

**Target**: Stay under 11–12ms for 60fps on low-end hardware. Profile on the target device — desktop profiling doesn't reflect mobile.

---

## 10. Common Performance Anti-Patterns

| Anti-Pattern | Fix |
|---|---|
| `get_node("a/b/c")` in `_process` | `@onready var x = $a/b/c` |
| `var x = load(dynamic_path)` every frame | Load once, cache in member var |
| Instantiating scenes in `_process` loop | Object pool, or load at `_ready` |
| `visible = false` on 100s of nodes | `process_mode = DISABLED` |
| Checking `Input` every frame | `_unhandled_input` instead |
| String-based signal emit/connect | `.emit()` / `.connect()` directly |
| `free()` inside callbacks | `queue_free()` always |
| No object pooling for frequently spawned entities | Pre-instantiate N objects |
| 1000s of `Area2D` overlap checks | Collision layers to filter |
| `get_tree().get_nodes_in_group()` in `_process` | Cache the result in a member |

---

## Anti-Patterns Summary

- **Typed vs untyped in the same project**: Pick one, be consistent.
- **String paths in hot paths**: Cache node references.
- **Instantiation in loops**: Pool objects.
- **`free()` inside callbacks**: Use `queue_free()`.
- **`_process` for input checks**: Use `_unhandled_input`.
- **Overlapping collision layers**: Design them explicitly.
- **`preload()` for dynamic paths**: Use `load()`.
- **No profiling before optimizing**: Profile first, then fix what the profiler shows.
