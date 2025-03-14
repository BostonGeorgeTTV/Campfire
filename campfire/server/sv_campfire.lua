if Config.Framework == "esx" then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
end

if Config.Inventory == "ox" then
    ox_inventory = exports.ox_inventory
elseif Config.Inventory == "qb" then
    qbinventory = exports['qb-inventory']
end

local placedProps = {}
local propIdCounter = 0

RegisterServerEvent("campfire:saveProp")
AddEventHandler("campfire:saveProp", function(modelName, x, y, z, finalHeading)
    if Config.Framework == "esx" then
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
    elseif Config.Framework == "qb" then
        local src = source
        local player = QBCore.Functions.GetPlayer(src)
        if player then
            if Config.Inventory == "qb" then
                qbinventory:RemoveItem(src, Config.Item, 1, nil, nil)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Item], "remove")
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
            elseif Config.Inventory == "ox" then
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
        end
    end
end)

RegisterNetEvent("campfire:addTarget")
AddEventHandler("campfire:addTarget", function(propId, modelName, x, y, z, finalHeading)
    TriggerClientEvent("campfire:addTarget", -1, propId, modelName, x, y, z, finalHeading)
end)

RegisterNetEvent("campfire:oxRemoveTarget")
AddEventHandler("campfire:oxRemoveTarget", function(data)
    TriggerClientEvent("campfire:oxRemoveTarget", -1, data)
end)

RegisterNetEvent("campfire:qbRemoveTarget")
AddEventHandler("campfire:qbRemoveTarget", function(propId)
    TriggerClientEvent("campfire:qbRemoveTarget", -1, propId)
end)

RegisterServerEvent("campfire:removeProp")
AddEventHandler("campfire:removeProp", function(id)
    if Config.Framework == "esx" then
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer and placedProps[id] then
            if placedProps[id].owner ~= src then
                return
            end

            placedProps[id] = nil

            TriggerClientEvent("campfire:deletePropById", -1, id)

            ox_inventory:AddItem(src, Config.Item, 1)
        end
    elseif Config.Framework == "qb" then
        local src = source
        local player = QBCore.Functions.GetPlayer(src)
        if Config.Inventory == "qb" then
            if player and placedProps[id] then
                if placedProps[id].owner ~= src then
                    return
                end

                placedProps[id] = nil

                TriggerClientEvent("campfire:deletePropById", -1, id)

                qbinventory:AddItem(src, Config.Item, 1, nil, nil)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Item], "add")
            end
        elseif Config.Framework == "ox" then
            if placedProps[id].owner ~= src then
                return
            end

            placedProps[id] = nil

            TriggerClientEvent("campfire:deletePropById", -1, id)

            ox_inventory:AddItem(src, Config.Item, 1)
        end
    end
end)

RegisterNetEvent("campfire:startEffect")
AddEventHandler("campfire:startEffect", function(model, x, y, z)
    TriggerClientEvent("campfire:startEffect", -1, model, x, y, z)
end)

RegisterNetEvent("campfire:stopEffect")
AddEventHandler("campfire:stopEffect", function(x, y, z)
    TriggerClientEvent("campfire:stopEffect", -1, x, y, z)
end)

if Config.Framework == "qb" then
    QBCore.Functions.CreateUseableItem(Config.Item, function(source)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)

        if Config.Inventory == "qb" then
            if Player.Functions.GetItemByName(Config.Item) then
                TriggerClientEvent("campfire:useCampfire", src)
            end
        elseif Config.Inventory == "ox" then
            if ox_inventory:GetItem(src, Config.Item, nil, true) > 0 then
                TriggerClientEvent("campfire:useCampfire", src)
            end
        end
    end)
end
