local QBCore = exports["qb-core"]:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local HudShow = false
local harness = false
local seatbeltOn = false

local speedMultiplier = 3.6
local hunger, thirst, oxygen, stress, moneyboost, armour, bleed, alcohol = 100, 100, 100, 0, 0, 0, 0, 0

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Citizen.Wait(500)
        if not QBCore.Functions.GetPlayerData().metadata then return end
		hunger = QBCore.Functions.GetPlayerData().metadata['hunger']
		thirst = QBCore.Functions.GetPlayerData().metadata['thirst']
		armour = QBCore.Functions.GetPlayerData().metadata['armor']
    end
end)


RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    PlayerData = QBCore.Functions.GetPlayerData()
    
    hunger = PlayerData.metadata['hunger']
    thirst = PlayerData.metadata['thirst']
    armour = PlayerData.metadata['armor']
end)

RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
    PlayerData = {}
end)

RegisterNetEvent("QBCore:Player:SetPlayerData", function(val)
    PlayerData = val
end)

RegisterNetEvent('seatbelt:client:ToggleSeatbelt', function() -- Triggered in smallresources
    seatbeltOn = not seatbeltOn
end)

RegisterNetEvent('seatbelt:client:ToggleCruise', function() -- Triggered in smallresources
    cruiseOn = not cruiseOn
end)

RegisterNetEvent('seatbelt:client:ToggleHarness', function(Newharness)
    harness = Newharness
end)

RegisterNetEvent('hud:client:UpdateNeeds')
AddEventHandler('hud:client:UpdateNeeds', function(newHunger, newThirst)
    hunger = newHunger
    thirst = newThirst
    if hunger > 100 then hunger = 100 end
    if thirst > 100 then thirst = 100 end
end)

RegisterNetEvent('hud:client:UpdateStress')
AddEventHandler('hud:client:UpdateStress', function(newStress)
    stress = newStress
end)

function CalculateCardinalDirection(heading)
    if heading >= 337.5 or heading < 22.5 then 
        return "N"
    elseif heading >= 22.5 and heading < 67.5 then 
        return "NE"
    elseif heading >= 67.5 and heading < 112.5 then 
        return "E"
    elseif heading >= 112.5 and heading < 157.5 then 
        return "SE"
    elseif heading >= 157.5 and heading < 202.5 then 
        return "S"
    elseif heading >= 202.5 and heading < 247.5 then 
        return "SW"
    elseif heading >= 247.5 and heading < 292.5 then 
        return "W"
    elseif heading >= 292.5 and heading < 337.5 then 
        return "NW"
    end
end


local lastFuelUpdate = 0
local lastFuelCheck = {}

local function GetFuelLevel(vehicle)
    local updateTick = GetGameTimer()
    if (updateTick - lastFuelUpdate) > 2000 then
        lastFuelUpdate = updateTick
        lastFuelCheck = math.floor(exports['LegacyFuel']:GetFuel(vehicle))
    end
    return lastFuelCheck
end

Citizen.CreateThread(function ()
    while true do
        if LocalPlayer.state.isLoggedIn then
            HudShow = true
            local playerId = PlayerId()
            local player = PlayerPedId()
            local sprint = GetEntitySpeed(player)
            local playerdied = IsPlayerDead(player)

            local vehicle = GetVehiclePedIsIn(player, false)
            local VehicleSpeed = math.ceil(GetEntitySpeed(vehicle) * speedMultiplier)
            local VehicleFuel = GetFuelLevel(vehicle)
            local CheckHarnass = exports['qb-smallresources']:HasHarness()
            local CheckSeatbelt = exports['qb-smallresources']:HasSeatbelt()

            if CheckHarnass or not CheckSeatbelt then harness = CheckHarnass end
            if CheckSeatbelt or not CheckSeatbelt then seatbeltOn = CheckSeatbelt end

            armour = GetPedArmour(player)
            health = GetEntityHealth(player) - 100
            
            local heading = GetEntityHeading(PlayerPedId())
            local compass = CalculateCardinalDirection(heading)

            if IsPauseMenuActive() then HudShow = false end
            if playerdied then HudShow = false end
            if not IsEntityInWater(player) then oxygen = 100 - GetPlayerSprintStaminaRemaining(playerId) end
            if IsEntityInWater(player) then oxygen = GetPlayerUnderwaterTimeRemaining(playerId) * 10 end

            local playerCoords = GetEntityCoords(player, true)
            local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z, currentStreetHash, intersectStreetHash)
            currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
            zone = tostring(GetNameOfZone(playerCoords))
            area = GetLabelText(zone)

            if area == "Fort Zancudo" then area = "Williamsburg" end
            
            local veh = GetVehiclePedIsIn(playerPed)
            if not (IsPedInAnyVehicle(player) and not IsThisModelABicycle(vehicle)) then
                DisplayRadar(false)
                SendNUIMessage({
                    action = HudShow,
                    type = 'OjxBurritosHud',
                    armour = armour,
                    health = health,
                    food = hunger,
                    thirst = thirst,
                    voice = NetworkIsPlayerTalking(PlayerId()),
                    stress = 10,
                    compass = compass,
                    stamina = oxygen, 

                    ojxass = area,
                })
            elseif IsPedInAnyVehicle(player) and not IsThisModelABicycle(vehicle) then
                local IsVehicleEngineRun = GetIsVehicleEngineRunning(vehicle)

                DisplayRadar(true)
                SendNUIMessage({
                    action = HudShow,
                    type = 'CarHud',
                    armour = armour,
                    health = health,
                    food = hunger,
                    thirst = thirst,
                    voice = NetworkIsPlayerTalking(PlayerId()),
                    stress = 10,
                    compass = compass,
                    stamina = oxygen,
                
                    ojxass = area,
                    seatbelt = seatbeltOn,
                    harness = harness,
                    fuel = VehicleFuel,
                    vehspeed = VehicleSpeed,
                    enginerun = IsVehicleEngineRun,
                })
            end
        end
        Citizen.Wait(100)
    end
end)

-- Configuration array for all HUD elements
local HUD_ELEMENTS = {
    HUD = { id = 0, hidden = false },
    HUD_WANTED_STARS = { id = 1, hidden = true },
    HUD_WEAPON_ICON = { id = 2, hidden = true },
    HUD_CASH = { id = 3, hidden = true },
    HUD_MP_CASH = { id = 4, hidden = true },
    HUD_MP_MESSAGE = { id = 5, hidden = true },
    HUD_VEHICLE_NAME = { id = 6, hidden = true },
    HUD_AREA_NAME = { id = 7, hidden = true },
    HUD_VEHICLE_CLASS = { id = 8, hidden = true },
    HUD_STREET_NAME = { id = 9, hidden = true },
    HUD_HELP_TEXT = { id = 10, hidden = false },
    HUD_FLOATING_HELP_TEXT_1 = { id = 11, hidden = false },
    HUD_FLOATING_HELP_TEXT_2 = { id = 12, hidden = false },
    HUD_CASH_CHANGE = { id = 13, hidden = true },
    HUD_RETICLE = { id = 14, hidden = true },
    HUD_SUBTITLE_TEXT = { id = 15, hidden = false },
    HUD_RADIO_STATIONS = { id = 16, hidden = false },
    HUD_SAVING_GAME = { id = 17, hidden = false },
    HUD_GAME_STREAM = { id = 18, hidden = false },
    HUD_WEAPON_WHEEL = { id = 19, hidden = false },
    HUD_WEAPON_WHEEL_STATS = { id = 20, hidden = false },
    MAX_HUD_COMPONENTS = { id = 21, hidden = false },
    MAX_HUD_WEAPONS = { id = 22, hidden = false },
    MAX_SCRIPTED_HUD_COMPONENTS = { id = 141, hidden = false }
}

-- -- Minimap update
-- CreateThread(function()
--     while true do
--         SetRadarBigmapEnabled(false, false)
--         SetRadarZoom(1000)
--         Wait(500)
--     end
-- end)

-- local function BlackBars()
--     DrawRect(0.0, 0.0, 2.0, w, 0, 0, 0, 255)
--     DrawRect(0.0, 1.0, 2.0, w, 0, 0, 0, 255)
-- end

-- CreateThread(function()
--     local minimap = RequestScaleformMovie("minimap")
--     if not HasScaleformMovieLoaded(minimap) then
--         RequestScaleformMovie(minimap)
--         while not HasScaleformMovieLoaded(minimap) do
--             Wait(1)
--         end
--     end
--     while true do
--         if w > 0 then
--             BlackBars()
--             DisplayRadar(0)
--         end
--         Wait(0)
--     end
-- end)

-- RegisterNetEvent("hud:client:LoadMap", function()
--     Wait(50)
--     local defaultAspectRatio = 1920/1080 -- Don't change this.
--     local resolutionX, resolutionY = GetActiveScreenResolution()
--     local aspectRatio = resolutionX/resolutionY
--     local minimapOffset = 0
--     if aspectRatio > defaultAspectRatio then
--         minimapOffset = ((defaultAspectRatio-aspectRatio)/3.6)-0.008
--     end
--     -- RequestStreamedTextureDict("squaremap", false)
--     -- if not HasStreamedTextureDictLoaded("squaremap") then
--     --     Wait(150)
--     -- end
--     -- SetMinimapClipType(0)
--     -- AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "squaremap", "radarmasksm")
--     -- AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "squaremap", "radarmasksm")
--     -- SetMinimapComponentPosition("minimap", "L", "B", 0.0 + minimapOffset, -0.047, 0.1638, 0.183)
--     -- SetMinimapComponentPosition("minimap_mask", "L", "B", 0.0 + minimapOffset, 0.0, 0.128, 0.20)
--     -- SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.01 + minimapOffset, 0.025, 0.262, 0.300)
--     -- SetBlipAlpha(GetNorthRadarBlip(), 0)
--     SetRadarBigmapEnabled(true, false)
--     -- SetMinimapClipType(0)
--     Wait(50)
--     SetRadarBigmapEnabled(false, false)
-- end)