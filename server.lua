-- ESX = nil
-- TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
ESX = exports['es_extended']:getSharedObject()

local haveStopZone = false

-- Vérifier si le joueur est LSPD
local function IsPlayerLSPD(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    return xPlayer and xPlayer.job.name == 'lspd'
end

-- Vérifier si le joueur est admin
local function IsPlayerAdmin(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    return xPlayer and xPlayer.getGroup() == 'admin'
end

-- Effacer une zone spécifique
local function ClearZone(playerId, radius)
    TriggerClientEvent('stopzone:clearAllZone', -1, playerId, radius)
end

-- fonction sendLogsAdvanced
local function sendLogsAdvanced(message, color, webhook, type, title, content)
    local embeds = {{
        ["title"] = title,
        ["type"] = "rich",
        ["color"] = color,
        ["description"] = content,
        ["footer"] = {
            ["text"] = "az0ox - Lspd Stop Zone logs"
        }
    }}
    if message == nil or message == '' then
        message = nil
    end
    if webhook ~= nil and webhook ~= '' then
        PerformHttpRequest(webhook, function(err, text, headers)
        end, 'POST', json.encode({
            username = 'LSPD logs - STOP ZONE',
            embeds = embeds,
            content = message
        }), {
            ['Content-Type'] = 'application/json'
        })
    end
end

-- Créer une zone d'arrêt
RegisterCommand('lspd-create-stopzone', function(source, args, rawCommand)
    if source == 0 or IsPlayerLSPD(source) or IsPlayerAdmin(source) and haveStopZone == false then

        local radius = 150 -- Rayon
        TriggerClientEvent('stopzone:set', -1, source, radius)

        -- send logs to discord
        local content = 'Zone créée par **' .. GetPlayerName(source) .. '**\n\n**Licence:** ' ..
                            GetPlayerIdentifiers(source)[1] .. '\n**Rayon:** ' .. radius .. '\n**Date:** ' .. os.date('%d/%m/%Y') .. '\n**Heure:** ' ..
                            os.date('%H:%M:%S')
        sendLogsAdvanced(nil, 65280, Config.webhook, 'rich', 'Zone créée', content)
        haveStopZone = true

        -- Effacer la zone après 25 minutes
        SetTimeout(1500000, function()
            TriggerClientEvent('stopzone:clearAllZone', -1)
            haveStopZone = false
        end)
    else
        if haveStopZone == true then
            TriggerClientEvent('chat:addMessage', source, {
                args = {'^1[Erreur] ', 'Une zone est déjà active.'}
            })
        else
            TriggerClientEvent('chat:addMessage', source, {
                args = {'^1[Erreur] ', 'Vous n\'avez pas la permission d\'utiliser cette commande.'}
            })
        end
    end
end, false)

-- effacer toute les zone d'arret sans radius particulier mais sur toute la map
RegisterCommand('lspd-delete-stopzone', function(source, args, rawCommand)
    if source == 0 or IsPlayerLSPD(source) or IsPlayerAdmin(source) then
        TriggerClientEvent('stopzone:clearAllZone', -1)
        haveStopZone = false
        -- send logs to discord
        content = 'Toutes les zones ont été effacées par **' .. GetPlayerName(source) .. '**\n\n**Licence:** ' ..
                      GetPlayerIdentifiers(source)[1] .. '\n**Discord ID:** ' .. GetPlayerIdentifiers(source)[2] ..
                      '\n**Date:** ' .. os.date('%d/%m/%Y') .. '\n**Heure:** ' .. os.date('%H:%M:%S')
        sendLogsAdvanced(nil, 16711680, Config.webhook, 'rich', 'Toutes les zones ont été effacées', content)
    end
end, false)
