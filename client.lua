-- Ajouter des suggestions de commandes au démarrage
Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/lspd-create-stopzone', 'Créer une zone d\'arrêt')
    TriggerEvent('chat:addSuggestion', '/lspd-delete-stopzone', 'Effacer la zone d\'arrêt')
end)

local stopZoneActive = false
local stopZoneCenter = nil
local stopZoneRadius = 0

-- Activer la zone d'arrêt
RegisterNetEvent('stopzone:set')
AddEventHandler('stopzone:set', function(playerId, radius)
    if playerId == GetPlayerServerId(PlayerId()) and not stopZoneActive then
        stopZoneCenter = GetEntityCoords(GetPlayerPed(-1))
        stopZoneRadius = radius
        stopZoneActive = true
    end
end)


-- Désactiver toutes les zones d'arrêt actives
RegisterNetEvent('stopzone:clearAllZone')
AddEventHandler('stopzone:clearAllZone', function()
    stopZoneCenter = nil
    stopZoneActive = false
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if stopZoneActive then
            local peds = GetNearbyPeds(stopZoneCenter.x, stopZoneCenter.y, stopZoneCenter.z, stopZoneRadius)
            print("stopZoneCenter coords: " .. stopZoneCenter.x .. " " .. stopZoneCenter.y .. " " .. stopZoneCenter.z)
            for i = 1, #peds do
                local ped = peds[i]
                if not IsPedAPlayer(ped) then
                    if IsPedInAnyVehicle(ped, false) then
                        -- Gestion des PNJ en véhicule
                        -- eteindre le véhicule
                        SetVehicleEngineOn(GetVehiclePedIsIn(ped, false), false, false, true)
                        -- activer les freins et freins a main
                        SetVehicleHandbrake(GetVehiclePedIsIn(ped, false), true)
                        SetVehicleBrake(GetVehiclePedIsIn(ped, false), true)
                    else
                        -- Gestion des PNJ à pied
                        ClearPedTasksImmediately(ped)
                        TaskStandStill(ped, -1)
                    end
                    SetBlockingOfNonTemporaryEvents(ped, true)
                end
            end
        else
            -- rallumer les véhicule des ped et activer les freins et freins a main
            activeZones = {}
            SetVehicleEngineOn(GetVehiclePedIsIn(ped, false), true, false, true)
            SetVehicleHandbrake(GetVehiclePedIsIn(ped, false), false)
            SetVehicleBrake(GetVehiclePedIsIn(ped, false), false)
        end
    end
end)

-- Fonction pour obtenir les PNJ à proximité
function GetNearbyPeds(x, y, z, radius)
    local peds = {}
    local pedHandle, ped = FindFirstPed()
    repeat
        local pedCoords = GetEntityCoords(ped)
        if #(pedCoords - vector3(x, y, z)) <= radius then
            table.insert(peds, ped)
        end
        success, ped = FindNextPed(pedHandle)
    until not success
    EndFindPed(pedHandle)
    return peds
end
