# Godot Project Organization

Directory structure, naming conventions, version control, and collaboration workflows. Based on official Godot best practices docs (sources 11–12).

---

## 1. Directory Structure

Godot has no enforced structure — but consistency matters for team projects. Group assets close to the scenes that use them.

### Recommended structure

```
project.godot
/docs/
    .gdignore  # Ignores /docs from import system
    learning.html
/models/
    town/
        house/
            house.dae
            window.png
            door.png
/characters/
    player/
        player.gd
        player.tscn
        player_sprite.png
    enemies/
        goblin/
            goblin.gd
            goblin.tscn
            goblin_sprite.png
/npcs/
    suzanne/
        suzanne.dae
/levels/
    riverdale/
        riverdale.tscn
/scripts/         # Shared utility scripts
    utils/
        math_utils.gd
        string_utils.gd
/resources/
    items/
        sword.tres
        shield.tres
    characters/
        player_stats.tres
/addons/          # Third-party plugins
    godot_curl/
/shaders/
    water.gdshader
    glow.gdshader
```

**Why**: Grouping by domain (characters, levels) rather than type (all_sprites, all_scripts) makes it easier to find related files. When you move a scene, you move its assets together.

### Root-level folders to avoid clutter

```
/images/      # ❌ all images together — hard to find what belongs where
/scripts/     # ❌ all scripts — split by domain

# ✅ Better: assets live next to the scenes that use them
/characters/player/player.gd + player.tscn + sprite.png
```

---

## 2. Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Folders and files | `snake_case` | `player_stats.tres`, `enemy_spawner.gd` |
| Node names | `PascalCase` | `Player`, `MainMenu`, `EnemySpawner` |
| Script class names | `PascalCase` | `class_name PlayerStats` |
| Constants | `SCREAMING_SNAKE_CASE` | `MAX_HEALTH`, `DEFAULT_SPEED` |
| Variables and functions | `snake_case` | `current_health`, `take_damage()` |
| Private members | `_snake_case` | `_cached_path`, `_internal_state` |
| Signals | `past_tense` | `health_changed`, `item_collected` |
| Booleans | `is_`/`has_`/`can_`/`should_` | `is_alive`, `has_key`, `can_jump` |
| Enums | `PascalCase` | `enum Facing { LEFT, RIGHT }` |

**Why**: `PascalCase` for nodes matches Godot's built-in node names in the inspector. `snake_case` for files avoids case-sensitivity issues on Windows after export.

### C# exception
C# scripts use `PascalCase` file names matching the class name (e.g., `PlayerController.cs` with `class PlayerController`).

---

## 3. The `.godot/` Folder

Created automatically when opening a project. **Do NOT commit** `.godot/` to version control — it contains:
- Imported asset cache
- Editor-specific settings
- Build artifacts

```
# .gitignore entry
.godot/
```

The `.godot/` folder is recreated from `project.godot` and `.import/` files when another developer opens the project.

---

## 4. Ignoring Folders with `.gdignore`

Place an empty `.gdignore` file in a folder to prevent Godot from importing its contents.

```
/docs/.gdignore  ← empty file
```

Once ignored:
- Resources in the folder **cannot** be loaded via `load()` or `preload()`
- The folder is hidden from the FileSystem dock
- Useful for documentation, raw assets not yet imported, or third-party files Godot shouldn't touch

**Note**: `.gdignore` does **not** support glob patterns like `.gitignore`. It ignores entire folders only.

---

## 5. Version Control with Git

Godot aims to be VCS-friendly. Scene files (`.tscn`) are text-based and mergeable. Binary files (`.scn`, imported assets) are not.

### Recommended `.gitignore`

```
# Godot project
.godot/
*.translation
export/
*.pck
*.exe

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.import
```

### Recommended `.gitattributes` (normalize line endings)

```
* text=auto eol=lf
```

Generated via: `Project → Version Control → Generate Version Control Metadata` in the Godot editor.

### Windows: disable `core.autocrlf`

```bash
git config --global core.autocrlf input
```

Godot's `.gitattributes` enforces `LF` line endings, but `autocrlf=true` can still cause spurious "modified" detections on Windows.

---

## 6. Scene File Merging (`.tscn`)

`.tscn` files are text-based YAML-ish format. They can be merged — but large scenes with many inline values cause merge conflicts.

### Strategies to reduce conflicts

1. **Externalize node references**: Use `@export` or `@export_file` for scene paths instead of hard-coding them in the `.tscn`.
2. **Prefab sub-scenes**: Extract commonly-changing branches into sub-scenes. Merging two small scenes is easier than merging one giant scene.
3. **Signal connections in code**: Editor-created signal connections are stored in `.tscn`. If two developers both edit signals, the merge is painful. Prefer wiring signals in `_ready()` via code.
4. **Lock scene files**: For large, stable scenes (levels, layouts), assign one person as owner. Others work on feature branches.

### Example: signal wiring in code vs editor

```gdscript
# GOOD — signals wired in code, editor just sets the export
@export var health_bar: ProgressBar

func _ready() -> void:
    player.health_changed.connect(_on_health_changed)

func _on_health_changed(new_hp: int, max_hp: int) -> void:
    health_bar.max_value = max_hp
    health_bar.value = new_hp
```

```gdscript
# The .tscn just has:
# [ext_resource type="Script" path="res://ui/health_display.gd" id="1"]
# [node name="HealthDisplay" type="Control"]
# layout("Preset0000000000000000000:/"):
# @export var health_bar: ProgressBar
# No connection data inline
```

---

## 7. Git LFS for Large Assets

Track binary assets (models, textures, audio) with Git LFS to avoid bloating the repository.

### Setup

```bash
git lfs install
git lfs track "*.png" "*.wav" "*.ogg" "*.glb" "*.gltf" "*.blend"
```

### Example `.gitattributes` for Godot projects

```
* text=auto eol=lf

# 3D Models
*.fbx filter=lfs diff=lfs merge=lfs -text
*.gltf filter=lfs diff=lfs merge=lfs -text
*.glb filter=lfs diff=lfs merge=lfs -text
*.blend filter=lfs diff=lfs merge=lfs -text

# Images
*.png filter=lfs diff=lfs merge=lfs -text
*.jpg filter=lfs diff=lfs merge=lfs -text
*.svg filter=lfs diff=lfs merge=lfs -text
*.webp filter=lfs diff=lfs merge=lfs -text

# Audio
*.mp3 filter=lfs diff=lfs merge=lfs -text
*.wav filter=lfs diff=lfs merge=lfs -text
*.ogg filter=lfs diff=lfs merge=lfs -text

# Fonts
*.ttf filter=lfs diff=lfs merge=lfs -text
*.otf filter=lfs diff=lfs merge=lfs -text

# Godot resources (some are binary)
*.scn filter=lfs diff=lfs merge=lfs -text
*.tres filter=lfs diff=lfs merge=lfs -text
```

**Why**: LFS stores file pointers in Git, actual content on a separate server. Clone times stay fast even with GBs of textures.

---

## 8. Scene Ownership and Collaboration

### Single-owner scenes
Assign one developer per scene folder. They are responsible for merges and structural decisions.

### Branching strategy
```
main
├── feature/player-combat
│   └── (player combat changes)
├── feature/new-enemy-type
│   └── (enemy implementation)
└── bugfix/health-bar-fix
    └── (fixes)
```

**Rule**: Small, frequent merges beat large, infrequent ones. The longer a branch lives, the harder the merge.

### Pre-commit checks
```bash
# Validate project.godot hasn't broken
godot --headless --check-only --quit project.godot

# Verify .tscn files are valid YAML
python3 -c "import yaml; yaml.safe_load(open('levels/level_1.tscn'))"
```

---

## Anti-Patterns

- **Mixing `PascalCase` and `snake_case` files**: Causes import issues on Windows export.
- **Committing `.godot/`**: Bloats repo, causes constant merge conflicts.
- **Large monolithic scenes**: Extract sub-scenes to reduce merge conflict surface.
- **Binary scene format (`.scn`)**: Use text-based `.tscn` instead.
- **Editor-only signal connections**: Prefer code-based wiring — it's merge-friendly and explicit.
- **No `.gdignore` for docs/assets**: Godot imports everything recursively, wasting time.
