--[[
    SYNC HUD - Server Side
    by kxirby
]]

-- Send config to client on join
RegisterNetEvent('sync-hud:requestConfig')
AddEventHandler('sync-hud:requestConfig', function()
    local src = source
    TriggerClientEvent('sync-hud:receiveConfig', src, {
        serverName = Config.ServerName,
        serverLogo = Config.ServerLogo,
        logoAnimation = Config.LogoAnimation,
        showDiscord = Config.ShowDiscord,
        discordLink = Config.DiscordLink,
        discordInvite = Config.DiscordInvite,
        defaultTheme = Config.DefaultTheme,
        defaultPosition = Config.DefaultPosition,
        defaultShape = Config.DefaultShape,
        defaultSpeedoStyle = Config.DefaultSpeedoStyle,
        statusBarStyle = Config.StatusBarStyle,
        useKmh = Config.UseKMH,
        showHunger = Config.ShowHunger,
        showThirst = Config.ShowThirst,
        showOxygen = Config.ShowOxygen,
        showVehicleHUD = Config.ShowVehicleHUD,
        showStatusBar = Config.ShowStatusBar,
        showCash = Config.ShowCash,
        showBank = Config.ShowBank,
        showPlayerId = Config.ShowPlayerId,
        statusBarAnimation = Config.StatusBarAnimation,
        hideFuelWhenFull = Config.HideFuelWhenFull,
        hideEngineWhenFull = Config.HideEngineWhenFull,
        showMinimap = Config.ShowMinimap,
        allowMinimapToggle = Config.AllowMinimapToggle,
        showSeatbelt = Config.ShowSeatbelt,
    })
end)

-- Save player settings
RegisterNetEvent('sync-hud:saveSettings')
AddEventHandler('sync-hud:saveSettings', function(settings)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    
    if identifier and Config.SaveSettings then
        -- You can save to database here if needed
        -- For now we rely on client-side KVP
        print('[SYNC-HUD] Settings saved for ' .. GetPlayerName(src))
    end
end)

-- Admin command
if Config.AdminCommand then
    RegisterCommand(Config.AdminCommand, function(source, args, rawCommand)
        local src = source
        
        if src == 0 then
            print('[SYNC-HUD] Server console - use in-game')
            return
        end
        
        -- Check admin
        local isAdmin = false
        
        -- ESX Admin check
        if GetResourceState('es_extended') == 'started' then
            local ESX = exports['es_extended']:getSharedObject()
            local xPlayer = ESX.GetPlayerFromId(src)
            if xPlayer then
                local group = xPlayer.getGroup()
                for _, adminGroup in ipairs(Config.AdminGroups) do
                    if group == adminGroup then
                        isAdmin = true
                        break
                    end
                end
            end
        end
        
        -- QB Admin check
        if GetResourceState('qb-core') == 'started' then
            local QBCore = exports['qb-core']:GetCoreObject()
            local Player = QBCore.Functions.GetPlayer(src)
            if Player then
                local permission = QBCore.Functions.GetPermission(src)
                for _, adminGroup in ipairs(Config.AdminGroups) do
                    if permission[adminGroup] then
                        isAdmin = true
                        break
                    end
                end
            end
        end
        
        -- Ace permission fallback
        if IsPlayerAceAllowed(src, 'command.' .. Config.AdminCommand) then
            isAdmin = true
        end
        
        if not isAdmin then
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 0, 0},
                args = {'SYNC-HUD', 'You do not have permission to use this command.'}
            })
            return
        end
        
        local action = args[1]
        
        if action == 'reload' then
            TriggerClientEvent('sync-hud:reload', -1)
            TriggerClientEvent('chat:addMessage', src, {
                color = {0, 255, 0},
                args = {'SYNC-HUD', 'HUD reloaded for all players.'}
            })
        elseif action == 'reset' then
            local targetId = tonumber(args[2])
            if targetId then
                TriggerClientEvent('sync-hud:resetSettings', targetId)
                TriggerClientEvent('chat:addMessage', src, {
                    color = {0, 255, 0},
                    args = {'SYNC-HUD', 'Reset settings for player ' .. targetId}
                })
            else
                TriggerClientEvent('chat:addMessage', src, {
                    color = {255, 255, 0},
                    args = {'SYNC-HUD', 'Usage: /' .. Config.AdminCommand .. ' reset [player_id]'}
                })
            end
        else
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 255, 255},
                args = {'SYNC-HUD', 'Commands: reload, reset [id]'}
            })
        end
    end, false)
end

print('^2[SYNC-HUD]^0 Server started - ' .. Config.ServerName)
