ESX = exports["es_extended"]:getSharedObject()

local ox_inventory = exports.ox_inventory
local placedProps = {}
local propIdCounter = 0

RegisterServerEvent("campfire:saveProp")
AddEventHandler("campfire:saveProp", function(modelName, x, y, z, finalHeading)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        ox_inventory:RemoveItem(src, Config.Item, 1)

        propIdCounter = propIdCounter + 1
        local propId = propIdCounter

        placedProps[propId] = {
            model = modelName,
            x = x,
            y = y,
            z = z,
            heading = finalHeading,
            owner = src
        }

        TriggerClientEvent("campfire:spawnProps", -1, propId, modelName, x, y, z, finalHeading)
    end
end)

RegisterServerEvent("campfire:removeProp")
AddEventHandler("campfire:removeProp", function(id)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer and placedProps[id] then
        if placedProps[id].owner ~= src then
            return
        end

        placedProps[id] = nil

        TriggerClientEvent("campfire:deletePropById", -1, id)
    end
    ox_inventory:AddItem(src, Config.Item, 1)
end)

RegisterNetEvent("campfire:startEffect")
AddEventHandler("campfire:startEffect", function(model, x, y, z)
    TriggerClientEvent("campfire:startEffect", -1, model, x, y, z)
end)

RegisterNetEvent("campfire:stopEffect")
AddEventHandler("campfire:stopEffect", function(x, y, z)
    TriggerClientEvent("campfire:stopEffect", -1, x, y, z)
end)