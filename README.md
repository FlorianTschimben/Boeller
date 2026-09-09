# Neon Strike: Arena

A self-contained Godot 4.7.2 first-person 3D arena shooter. The arena, lighting, weapon props, enemies, and interface are generated in code, so no art downloads or imports are required.

## Run

Open `project.godot` in Godot 4.7.2 and press F6/F5, or run:

```sh
godot --path .
```

## Controls

- `WASD`: move
- `Space`: jump
- Mouse: look around and fire
- `R`: reload
- `Q`: use the selected character's tactical ability
- `Esc`: pause or resume the current match

Aim for an enemy's head for double damage and a headshot elimination bonus.

## Pause And Settings

Press `Esc` during a match to pause. The pause menu can resume or restart the match, return to loadout selection, or open settings. Settings apply immediately and are persisted in `user://settings.cfg`:

- Mouse sensitivity
- Field of view
- Master volume
- Fullscreen mode

## Characters

- Vanguard: invulnerable for 5 seconds
- Rapid: unlimited ammunition for 7 seconds
- Spectre: reveals the nearest enemy through walls for 6 seconds with a visible 3D marker

Each character also has one exclusive special weapon. The armory always offers the three standard weapons plus the selected operative's special weapon.

## Adding Characters

Add one entry to `GameData.characters()` in `game_data.gd`; the roster screen, selection briefing, and armory update automatically. Each entry needs:

- Identity: `name`, `role`, `symbol`
- Presentation: `color`, `accent`, `portrait_style` (`armored`, `runner`, or `hooded`)
- Ability: `ability`, `description`, `duration`, `cooldown`
- `special_weapon`: a weapon dictionary using the standard fields: `name`, `tag`, `damage`, `fire_rate`, `magazine`, `reserve`, `reload_time`, `color`, `automatic`, `spread`, and `model_size`

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
