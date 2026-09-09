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

- Duce: Minigun and temporary immortality
- Mock: Motorsaw and arena-wide Makita Radio slow
- Flo: Lasergun and forward teleport
- FBI: Grappling Hook and mini FBI combat robots
- Benni: Sticky Grenade Launcher and lifesteal
- Simon Kranzer: Rocket Launcher and mini panzer
- Fabian: Lemonator and healing/damaging lemon tree
- Stoan: Stoanschleider and giant rolling stone
- Marian: Lenkrakete and invulnerable enemy freeze
- Manuel: RGB LED Strips and 50-mana enemy blast
- Alan: Bomben and movement/fire-rate boost
- Danny: Pumpgun and deployable return teleporter

## Weapon Behaviors

- Mock's Motorsaw is a close-range, no-ammo melee weapon.
- FBI's Grappling Hook pulls the player to the aimed surface without reloading.
- Benni's Sticky Grenade Launcher sticks to surfaces or enemies before exploding.
- Simon's Rocket Launcher detonates with a larger blast radius on impact.
- Alan's Bomben launch arcing grenades with splash damage.

Each character also has one exclusive special weapon. The armory always offers the three standard weapons plus the selected operative's special weapon.

## Adding Characters

Add one entry to `GameData.characters()` in `game_data.gd`; the roster screen, selection briefing, and armory update automatically. Each entry needs:

- Identity: `name`, `role`, `symbol`
- Presentation: `color`, `accent`, `portrait_style` (`armored`, `runner`, `hooded`, `medic`, `demolition`, or `striker`)
- Ability: `ability`, `ability_effect`, `description`, `duration`, `cooldown`
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
