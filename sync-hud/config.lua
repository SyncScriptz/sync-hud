
    -- sync-hud by kxirby
    -- please config this so you don't come to me with false bugs :)


Config = {}

-- server info (top right watermark)
Config.ServerName = "Your Server Name"
Config.ServerLogo = "logo.png"              -- put your logo in html/assets/
Config.LogoAnimation = "bounce"              -- none, pulse, glow, rotate, bounce (this will animate your watermark logo. it can cause some fps drop but looks good.)

-- discord
Config.ShowDiscord = true
Config.DiscordInvite = "discord.gg/syncscripts"  -- text that shows
Config.DiscordLink = "https://discord.gg/syncscripts"

-- framework (auto detects esx/qb/standalone)
Config.Framework = "auto"
Config.ESXExport = "es_extended"

-- update speed (lower = smoother but more resource use)
Config.UpdateInterval = 150
Config.HideInPauseMenu = true

-- keybinds
Config.DefaultKeybind = "F6"                -- open settings
Config.ToggleKeybind = "F7"                 -- toggle hud

-- minimap (off by default, vanilla gta map when on)
Config.ShowMinimap = false
Config.AllowMinimapToggle = true

-- seatbelt indicator (off by default since not all scripts work with it)
Config.ShowSeatbelt = false

-- default theme stuff
Config.DefaultTheme = "clean"               -- clean, darkness, neon, ocean, sunset, forest, blood, royal
Config.DefaultPosition = "bottom-center"    -- top-left, top-center, top-right, bottom-left, bottom-center, bottom-right
Config.DefaultShape = "square"              -- square, rounded, circle, diamond, hexagon
Config.DefaultSpeedoStyle = "minimal"       -- minimal, circle, digital
Config.StatusBarStyle = "shadow"            -- clean, shadow, outline, neon, gradient

-- speed unit
Config.UseKMH = false                        -- false for mph

-- what to show by default
Config.ShowHunger = true
Config.ShowThirst = true
Config.ShowOxygen = true
Config.ShowVehicleHUD = true
Config.ShowStatusBar = true
Config.ShowCash = true
Config.ShowBank = true
Config.ShowPlayerId = true

-- status bar animation
Config.StatusBarAnimation = "none"          -- none, pulse, glow

-- vehicle stuff
Config.HideFuelWhenFull = true
Config.HideEngineWhenFull = true
Config.FuelFullThreshold = 95

-- fuel system (auto detects)
Config.FuelSystem = "auto"

-- settings saving
Config.SaveSettings = true
Config.UseKVP = true                        -- saves to client, survives restarts

-- admin stuff
Config.AdminGroups = {"admin", "superadmin", "god"}
Config.AdminCommand = "synchud"
