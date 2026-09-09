# Neon Strike: Arena

A self-contained Godot 4.7.2 first-person 3D arena shooter. The arena, lighting, weapon props, enemies, and interface are generated in code, so no art downloads or imports are required.

## Run

Open `project.godot` in Godot 4.7.2 and press F6/F5, or run:

```sh
godot --path .
```

## Controls

- `WASD`: move
- Mouse: look around and fire
- `R`: reload
- `Q`: use the selected character's tactical ability
- `Esc`: return to the character selection screen

## Characters

- Vanguard: invulnerable for 5 seconds
- Rapid: unlimited ammunition for 7 seconds
- Spectre: reveals the nearest enemy through walls for 6 seconds with a visible 3D marker

## Weapons

- Pistol: precise, high-damage sidearm
- Machine Gun: high-capacity suppression weapon
- AK-47: balanced automatic rifle with high impact

## Architecture

- `main.gd`: match flow, arena construction, combat resolution, and spawning
- `player_controller.gd`: first-person movement, mouse-look, weapon presentation, and input signals
- `enemy_agent.gd`: enemy visual setup, movement, firing cadence, damage, and wall-reveal marker
- `shot_tracer.gd`: short-lived, correctly oriented muzzle-to-impact visual effects
- `arena_hud.gd`: selection menus, HUD layout, and timed messages
- `game_data.gd`: character and weapon loadout definitions plus shared material creation
