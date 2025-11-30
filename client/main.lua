

local Framework = nil
local PlayerData = nil
local PlayerLoaded = false


local currentHealth = 100
local currentArmor = 0
local currentHunger = 100
local currentThirst = 100
local currentStamina = 100
local currentOxygen = 100
local currentStress = 0
local isInVehicle = false
local vehicleSpeed = 0
local vehicleFuel = 100
local vehicleHealth = 100
local isSeatbeltOn = false
local settingsOpen = false
local isDead = false


CreateThread(function()
    local framework = Config.Framework
    
    if framework == "auto" then
        if GetResourceState('es_extended') == 'started' then
            framework = 'esx'
        elseif GetResourceState('qb-core') == 'started' then
            framework = 'qb'
        elseif GetResourceState('ox_core') == 'started' then
            framework = 'ox'
        else
            framework = 'standalone'
        end
    end
    
    print('[SYNC-HUD] Detected framework: ' .. framework)
    
    if framework == 'esx' then
        -- Try new export method first
        if exports['es_extended'] then
            Framework = exports['es_extended']:getSharedObject()
        else
            -- Fallback to trigger event
            TriggerEvent('esx:getSharedObject', function(obj) Framework = obj end)
            Wait(100)
        end
        
        if Framework then
            while Framework.GetPlayerData() == nil do
                Wait(100)
            end
            PlayerData = Framework.GetPlayerData()
            PlayerLoaded = true
        end
        
        RegisterNetEvent('esx:playerLoaded')
        AddEventHandler('esx:playerLoaded', function(xPlayer)
            PlayerData = xPlayer
            PlayerLoaded = true
        end)
        
        RegisterNetEvent('esx:setJob')
        AddEventHandler('esx:setJob', function(job)
            if PlayerData then PlayerData.job = job end
        end)
        
    elseif framework == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        Framework = QBCore
        
        while QBCore.Functions.GetPlayerData() == nil or QBCore.Functions.GetPlayerData().citizenid == nil do
            Wait(100)
        end
        
        PlayerData = QBCore.Functions.GetPlayerData()
        PlayerLoaded = true
        
        RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
        AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
            PlayerData = QBCore.Functions.GetPlayerData()
            PlayerLoaded = true
        end)
        
        RegisterNetEvent('QBCore:Client:OnPlayerUnload')
        AddEventHandler('QBCore:Client:OnPlayerUnload', function()
            PlayerLoaded = false
        end)
        
        RegisterNetEvent('QBCore:Player:SetPlayerData')
        AddEventHandler('QBCore:Player:SetPlayerData', function(val)
            PlayerData = val
        end)
        
    elseif framework == 'ox' then
     
        PlayerLoaded = true
        
    else
        
        PlayerLoaded = true
    end
    
    
    TriggerServerEvent('sync-hud:requestConfig')
    
    print('[SYNC-HUD] Framework initialized, player loaded: ' .. tostring(PlayerLoaded))
end)


local minimapEnabled = false

CreateThread(function()
    Wait(500)
    minimapEnabled = Config.ShowMinimap
    DisplayRadar(minimapEnabled)
end)

RegisterNUICallback('toggleMinimap', function(data, cb)
    minimapEnabled = data.show
    DisplayRadar(data.show)
    cb('ok')
end)

exports('ToggleMinimap', function(state)
    minimapEnabled = state
    DisplayRadar(state)
end)


RegisterNetEvent('sync-hud:receiveConfig')
AddEventHandler('sync-hud:receiveConfig', function(serverConfig)
    SendNUIMessage({
        action = 'setConfig',
        config = serverConfig
    })
end)


local function GetFuel(vehicle)
    local fuel = 100
    
    -- LegacyFuel
    if GetResourceState('LegacyFuel') == 'started' then
        local success, result = pcall(function() return exports['LegacyFuel']:GetFuel(vehicle) end)
        if success and result then return math.floor(result) end
    end
    
    -- ox_fuel
    if GetResourceState('ox_fuel') == 'started' then
        local success, result = pcall(function() return Entity(vehicle).state.fuel end)
        if success and result then return math.floor(result) end
    end
    
    -- cdn-fuel
    if GetResourceState('cdn-fuel') == 'started' then
        local success, result = pcall(function() return exports['cdn-fuel']:GetFuel(vehicle) end)
        if success and result then return math.floor(result) end
    end
    
    -- ps-fuel
    if GetResourceState('ps-fuel') == 'started' then
        local success, result = pcall(function() return exports['ps-fuel']:GetFuel(vehicle) end)
        if success and result then return math.floor(result) end
    end
    
    -- lj-fuel
    if GetResourceState('lj-fuel') == 'started' then
        local success, result = pcall(function() return exports['lj-fuel']:GetFuel(vehicle) end)
        if success and result then return math.floor(result) end
    end
    
    -- okokGasStation
    if GetResourceState('okokGasStation') == 'started' then
        local success, result = pcall(function() return exports['okokGasStation']:GetFuel(vehicle) end)
        if success and result then return math.floor(result) end
    end
    
    -- Renewed-Fuel
    if GetResourceState('Renewed-Fuel') == 'started' then
        local success, result = pcall(function() return Entity(vehicle).state.fuel end)
        if success and result then return math.floor(result) end
    end
    
    -- Native fallback
    return math.floor(GetVehicleFuelLevel(vehicle) or 100)
end



local function GetMoney()
    local cash, bank = 0, 0
    
    if not Framework then return cash, bank end
    
 
    if GetResourceState('es_extended') == 'started' then
        local playerData = Framework.GetPlayerData()
        if playerData and playerData.accounts then
            for _, account in ipairs(playerData.accounts) do
                if account.name == 'money' or account.name == 'cash' then
                    cash = account.money or 0
                elseif account.name == 'bank' then
                    bank = account.money or 0
                end
            end
        end
        return cash, bank
    end

    if GetResourceState('qb-core') == 'started' then
        local playerData = Framework.Functions.GetPlayerData()
        if playerData and playerData.money then
            cash = playerData.money.cash or 0
            bank = playerData.money.bank or 0
        end
        return cash, bank
    end
    
    return cash, bank
end


-- Direct state setter (most reliable)
local function SetSeatbeltState(state)
    isSeatbeltOn = state
end


RegisterNetEvent('esx_seatbelt:onEnter')
AddEventHandler('esx_seatbelt:onEnter', function()
    SetSeatbeltState(true)
end)

RegisterNetEvent('esx_seatbelt:onExit')
AddEventHandler('esx_seatbelt:onExit', function()
    SetSeatbeltState(false)
end)

-- esx_seatbelt toggle variant
RegisterNetEvent('esx_seatbelt:toggle')
AddEventHandler('esx_seatbelt:toggle', function()
    SetSeatbeltState(not isSeatbeltOn)
end)

-- esx_seatbelt with state
RegisterNetEvent('esx_seatbelt:setBelt')
AddEventHandler('esx_seatbelt:setBelt', function(state)
    SetSeatbeltState(state)
end)

RegisterNetEvent('seatbelt:client:ToggleSeatbelt')
AddEventHandler('seatbelt:client:ToggleSeatbelt', function()
    SetSeatbeltState(not isSeatbeltOn)
end)

RegisterNetEvent('seatbelt:client:SetSeatbelt')
AddEventHandler('seatbelt:client:SetSeatbelt', function(state)
    SetSeatbeltState(state)
end)



RegisterNetEvent('qb-seatbelt:client:ToggleSeatbelt')
AddEventHandler('qb-seatbelt:client:ToggleSeatbelt', function()
    SetSeatbeltState(not isSeatbeltOn)
end)

RegisterNetEvent('seatbelt:client:Toggle')
AddEventHandler('seatbelt:client:Toggle', function()
    SetSeatbeltState(not isSeatbeltOn)
end)



RegisterNetEvent('cd_seatbelt:toggle')
AddEventHandler('cd_seatbelt:toggle', function()
    SetSeatbeltState(not isSeatbeltOn)
end)

RegisterNetEvent('cd_seatbelt:client:toggle')
AddEventHandler('cd_seatbelt:client:toggle', function()
    SetSeatbeltState(not isSeatbeltOn)
end)

RegisterNetEvent('r_seatbelt:client:ToggleSeatbelt')
AddEventHandler('r_seatbelt:client:ToggleSeatbelt', function()
    SetSeatbeltState(not isSeatbeltOn)
end)

RegisterNetEvent('okokSeatbelt:toggled')
AddEventHandler('okokSeatbelt:toggled', function(state)
    SetSeatbeltState(state)
end)

RegisterNetEvent('jg-seatbelt:client:ToggleSeatbelt')
AddEventHandler('jg-seatbelt:client:ToggleSeatbelt', function()
    SetSeatbeltState(not isSeatbeltOn)
end)

RegisterNetEvent('hud:client:UpdateSeatbelt')
AddEventHandler('hud:client:UpdateSeatbelt', function(state)
    SetSeatbeltState(state)
end)

RegisterNetEvent('seatbelt:update')
AddEventHandler('seatbelt:update', function(state)
    SetSeatbeltState(state)
end)

RegisterNetEvent('player:seatbelt')
AddEventHandler('player:seatbelt', function(state)
    SetSeatbeltState(state)
end)

RegisterNetEvent('ps-seatbelt:client:ToggleSeatbelt')
AddEventHandler('ps-seatbelt:client:ToggleSeatbelt', function()
    SetSeatbeltState(not isSeatbeltOn)
end)

RegisterNetEvent('mx-seatbelt:client:ToggleSeatbelt')
AddEventHandler('mx-seatbelt:client:ToggleSeatbelt', function()
    SetSeatbeltState(not isSeatbeltOn)
end)


RegisterNetEvent('Seatbelt:Toggle')
AddEventHandler('Seatbelt:Toggle', function()
    SetSeatbeltState(not isSeatbeltOn)
end)

RegisterNetEvent('seatbelt:toggle')
AddEventHandler('seatbelt:toggle', function()
    SetSeatbeltState(not isSeatbeltOn)
end)

RegisterNetEvent('ToggleSeatbelt')
AddEventHandler('ToggleSeatbelt', function()
    SetSeatbeltState(not isSeatbeltOn)
end)

if GetResourceState('ox_lib') == 'started' then
    AddStateBagChangeHandler('seatbelt', ('player:%s'):format(GetPlayerServerId(PlayerId())), function(_, _, value)
        if value ~= nil then
            SetSeatbeltState(value)
        end
    end)
end

AddStateBagChangeHandler('seatbelt', nil, function(bagName, key, value)
    if bagName == ('player:%s'):format(GetPlayerServerId(PlayerId())) then
        if value ~= nil then
            SetSeatbeltState(value)
        end
    end
end)

CreateThread(function()
    local wasInVehicle = false
    while true do
        Wait(200)
        local inVehicle = IsPedInAnyVehicle(PlayerPedId(), false)
        if wasInVehicle and not inVehicle then
            SetSeatbeltState(false)
        end
        wasInVehicle = inVehicle
    end
end)

CreateThread(function()
    Wait(2000)
    while true do
        Wait(1000)
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            -- Try to get seatbelt state from various resources
            if GetResourceState('qb-seatbelt') == 'started' then
                local success, result = pcall(function() return exports['qb-seatbelt']:GetSeatbelt() end)
                if success and result ~= nil then SetSeatbeltState(result) end
            elseif GetResourceState('esx_seatbelt') == 'started' then
                local success, result = pcall(function() return exports['esx_seatbelt']:IsWearing() end)
                if success and result ~= nil then SetSeatbeltState(result) end
            end
        end
    end
end)



RegisterNetEvent('esx_status:onTick')
AddEventHandler('esx_status:onTick', function(data)
    for i = 1, #data do
        if data[i].name == 'hunger' then
            currentHunger = math.floor(data[i].percent)
        elseif data[i].name == 'thirst' then
            currentThirst = math.floor(data[i].percent)
        end
    end
end)

RegisterNetEvent('esx_basicneeds:onTick')
AddEventHandler('esx_basicneeds:onTick', function(data)
    for i = 1, #data do
        if data[i].name == 'hunger' then
            currentHunger = math.floor(data[i].percent)
        elseif data[i].name == 'thirst' then
            currentThirst = math.floor(data[i].percent)
        end
    end
end)

RegisterNetEvent('hud:client:UpdateNeeds')
AddEventHandler('hud:client:UpdateNeeds', function(hunger, thirst)
    if hunger then currentHunger = math.floor(hunger) end
    if thirst then currentThirst = math.floor(thirst) end
end)

RegisterNetEvent('hud:client:UpdateStress')
AddEventHandler('hud:client:UpdateStress', function(stress)
    if stress then currentStress = math.floor(stress) end
end)

RegisterNetEvent('okokNeeds:update')
AddEventHandler('okokNeeds:update', function(hunger, thirst)
    if hunger then currentHunger = math.floor(hunger) end
    if thirst then currentThirst = math.floor(thirst) end
end)

RegisterNetEvent('Metabolic:UpdateHunger')
AddEventHandler('Metabolic:UpdateHunger', function(hunger)
    if hunger then currentHunger = math.floor(hunger) end
end)

RegisterNetEvent('Metabolic:UpdateThirst')
AddEventHandler('Metabolic:UpdateThirst', function(thirst)
    if thirst then currentThirst = math.floor(thirst) end
end)



RegisterNetEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function()
    isDead = true
    SendNUIMessage({ action = 'setDead', dead = true })
end)

RegisterNetEvent('esx:onPlayerSpawn')
AddEventHandler('esx:onPlayerSpawn', function()
    isDead = false
    SendNUIMessage({ action = 'setDead', dead = false })
end)

RegisterNetEvent('hospital:client:SetDeathState')
AddEventHandler('hospital:client:SetDeathState', function(state)
    isDead = state
    SendNUIMessage({ action = 'setDead', dead = state })
end)

RegisterNetEvent('ambulancejob:client:SetDeathState')
AddEventHandler('ambulancejob:client:SetDeathState', function(state)
    isDead = state
    SendNUIMessage({ action = 'setDead', dead = state })
end)



CreateThread(function()
    while true do
        Wait(Config.UpdateInterval)
        
        if PlayerLoaded then
            local playerPed = PlayerPedId()
            
            if Config.HideInPauseMenu and IsPauseMenuActive() then
                SendNUIMessage({ action = 'hide' })
            else
                SendNUIMessage({ action = 'show' })
                
                -- Health
                local health = GetEntityHealth(playerPed)
                local maxHealth = GetEntityMaxHealth(playerPed)
                
                if maxHealth > 100 then
                    currentHealth = math.floor(((health - 100) / (maxHealth - 100)) * 100)
                else
                    currentHealth = math.floor((health / maxHealth) * 100)
                end
                currentHealth = math.max(0, math.min(100, currentHealth))
                
                -- Check if dead
                local wasNotDead = not isDead
                isDead = IsEntityDead(playerPed) or currentHealth <= 0
                
                if wasNotDead and isDead then
                    SendNUIMessage({ action = 'setDead', dead = true })
                elseif not wasNotDead and not isDead then
                    SendNUIMessage({ action = 'setDead', dead = false })
                end
                
                -- Armor
                currentArmor = GetPedArmour(playerPed)
                
                -- Stamina
                currentStamina = math.floor(100 - GetPlayerSprintStaminaRemaining(PlayerId()))
                
                -- Oxygen
                local isUnderwater = IsEntityInWater(playerPed) and GetEntitySubmergedLevel(playerPed) > 0.8
                if isUnderwater then
                    currentOxygen = math.floor(GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10)
                    currentOxygen = math.min(100, currentOxygen)
                else
                    currentOxygen = 100
                end
                
                -- Vehicle data
                isInVehicle = IsPedInAnyVehicle(playerPed, false)
                
                if isInVehicle then
                    local vehicle = GetVehiclePedIsIn(playerPed, false)
                    
                    local speed = GetEntitySpeed(vehicle)
                    if Config.UseKMH then
                        vehicleSpeed = math.floor(speed * 3.6)
                    else
                        vehicleSpeed = math.floor(speed * 2.236936)
                    end
                    
                    local vehHealth = GetVehicleEngineHealth(vehicle)
                    vehicleHealth = math.floor(vehHealth / 10)
                    vehicleHealth = math.max(0, math.min(100, vehicleHealth))
                    
                    vehicleFuel = GetFuel(vehicle)
                end
                
                -- Money
                local cash, bank = GetMoney()
                
                -- Send update to NUI
                SendNUIMessage({
                    action = 'update',
                    health = currentHealth,
                    armor = currentArmor,
                    hunger = currentHunger,
                    thirst = currentThirst,
                    stamina = currentStamina,
                    oxygen = currentOxygen,
                    stress = currentStress,
                    showOxygen = isUnderwater,
                    inVehicle = isInVehicle,
                    speed = vehicleSpeed,
                    fuel = vehicleFuel,
                    vehicleHealth = vehicleHealth,
                    seatbelt = Config.ShowSeatbelt and isSeatbeltOn or true,  -- if seatbelt disabled, always show as "on" (hidden)
                    showSeatbelt = Config.ShowSeatbelt,
                    isDead = isDead,
                    cash = cash,
                    bank = bank,
                    playerId = GetPlayerServerId(PlayerId()),
                })
            end
        end
    end
end)



RegisterCommand('hudsettings', function()
    if not settingsOpen then
        settingsOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'openSettings' })
    end
end, false)

RegisterKeyMapping('hudsettings', 'Open HUD Settings', 'keyboard', Config.DefaultKeybind)

RegisterCommand('togglehud', function()
    SendNUIMessage({ action = 'toggleHud' })
end, false)

RegisterKeyMapping('togglehud', 'Toggle HUD', 'keyboard', Config.ToggleKeybind)



RegisterNUICallback('closeSettings', function(data, cb)
    settingsOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('saveSettings', function(data, cb)
    if Config.SaveSettings then
        if Config.UseKVP then
            SetResourceKvp('sync-hud:settings', json.encode(data))
        end
        TriggerServerEvent('sync-hud:saveSettings', data)
    end
    cb('ok')
end)

RegisterNUICallback('loadSettings', function(data, cb)
    if Config.UseKVP then
        local saved = GetResourceKvpString('sync-hud:settings')
        if saved then
            cb(json.decode(saved))
            return
        end
    end
    cb(nil)
end)


RegisterNetEvent('sync-hud:reload')
AddEventHandler('sync-hud:reload', function()
    TriggerServerEvent('sync-hud:requestConfig')
end)

RegisterNetEvent('sync-hud:resetSettings')
AddEventHandler('sync-hud:resetSettings', function()
    if Config.UseKVP then
        DeleteResourceKvp('sync-hud:settings')
    end
    SendNUIMessage({ action = 'resetSettings' })
end)



exports('ToggleHUD', function(state)
    SendNUIMessage({ action = state and 'show' or 'hide' })
end)

exports('IsHUDVisible', function()
    return not settingsOpen
end)

exports('seatbelt', function(state)
    SetSeatbeltState(state)
end)

exports('SetSeatbelt', function(state)
    SetSeatbeltState(state)
end)

exports('GetSeatbelt', function()
    return isSeatbeltOn
end)

exports('OpenSettings', function()
    if not settingsOpen then
        settingsOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'openSettings' })
    end
end)

exports('SetMoney', function(cash, bank)
    SendNUIMessage({
        action = 'updateMoney',
        cash = cash,
        bank = bank
    })
end)

exports('SetHunger', function(value)
    currentHunger = math.floor(value)
end)

exports('SetThirst', function(value)
    currentThirst = math.floor(value)
end)

exports('SetStress', function(value)
    currentStress = math.floor(value)
end)

exports('SetDead', function(state)
    isDead = state
    SendNUIMessage({ action = 'setDead', dead = state })
end)

print('^2[SYNC-HUD]^0 Client loaded - Full compatibility mode')
