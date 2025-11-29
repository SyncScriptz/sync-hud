# sync-hud

clean customizable hud for fivem. made by kxirby at sync scripts.

<img width="626" height="399" alt="Screenshot_2025-11-29_141612-removebg-preview" src="https://github.com/user-attachments/assets/47686a12-7cf1-486a-bf10-9dc7d2bb3b23" />

<img width="372" height="244" alt="Screenshot_2025-11-29_141642-removebg-preview" src="https://github.com/user-attachments/assets/b582e4b9-a3d2-4d1c-8f6b-cc0748b619bc" />



## features

- 8 color themes (clean, darkness, neon, ocean, sunset, forest, blood, royal)
- 5 icon shapes (square, rounded, circle, diamond, hexagon)
- 5 status bar styles (clean, shadow, outline, neon, gradient)
- 3 speedometer styles (minimal, circle, digital)
- full rgb color customization
- in-game settings menu (F6)
- top right watermark with server logo, name, id, cash, bank, discord
- death state (health turns red when dead)
- works with esx, qbcore, qbox, standalone

## install

1. drop sync-hud in your resources
2. add `ensure sync-hud` to server.cfg
3. put your logo in `html/assets/logo.png`
4. edit `config.lua`
5. restart

## config

everything is in config.lua with comments explaining what each thing does.

## compatible with

**frameworks:** esx, qbcore, qbox, ox core, standalone

**fuel:** legacyfuel, ox_fuel, cdn-fuel, ps-fuel, lj-fuel, okokgasstation, renewed-fuel

**needs:** esx_status, esx_basicneeds, qbcore metadata, okokneeds

## exports

```lua
exports['sync-hud']:ToggleHUD(true/false)
exports['sync-hud']:OpenSettings()
exports['sync-hud']:SetSeatbelt(true/false)
exports['sync-hud']:SetMoney(cash, bank)
exports['sync-hud']:SetHunger(value)
exports['sync-hud']:SetThirst(value)
exports['sync-hud']:ToggleMinimap(true/false)
exports['sync-hud']:SetDead(true/false)
```

## commands

- `/hudsettings` or F6 - open settings
- `/togglehud` or F7 - toggle hud
- `/synchud reload` - admin reload
- `/synchud reset [id]` - admin reset player settings

## notes

- minimap is off by default, players can turn it on in settings
- seatbelt indicator is off by default in config since not all seatbelt scripts trigger the right events. if yours works, turn it on in config
- settings save to client and persist through restarts

---
made by kxirby | sync scripts
