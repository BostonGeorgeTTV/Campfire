if Config.Framework == "esx" then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
end

local loadedModels, SpawnedProps, activeFires  = {}, {}, {}
local modelName = Config.Prop

RegisterNetEvent("campfire:useCampfire")
AddEventHandler("campfire:useCampfire", function()
    StartPropPlacement()
end)

StartPropPlacement = function(slot)
    if not loadedModels[modelName] then
        if not IsModelInCdimage(modelName) then
            return
        end

        RequestModel(modelName)
        while not HasModelLoaded(modelName) do Wait(100) end
        loadedModels[modelName] = true 
    end

    local playerPed = PlayerPedId()
    local forwardVector = GetEntityForwardVector(playerPed)
    local playerCoords = GetEntityCoords(playerPed)

    local propCoords = vector3(playerCoords.x + forwardVector.x * 1.5, playerCoords.y + forwardVector.y * 1.5, playerCoords.z)
    local prop = CreateObjectNoOffset(modelName, propCoords.x, propCoords.y, propCoords.z, false, false, false)

    SetEntityCollision(prop, false, false)
    SetEntityAlpha(prop, 200, false)
    FreezeEntityPosition(prop, true)

    local editing = true

    if Config.Framework == "esx" then
        lib.showTextUI(Config.Translate.ControlsUI)
    elseif Config.Framework == "qb" then
        exports['qb-core']:DrawText(Config.Translate.ControlsUI, 'right')
    end

    Citizen.CreateThread(function()
        while DoesEntityExist(prop) and editing do
            Citizen.Wait(0)
            local x, y, z = table.unpack(GetEntityCoords(prop))
            local heading = GetEntityHeading(prop)

            if Config.Debug then
                print(string.format("Prop position:\nX=%.2f\nY=%.2f\nZ=%.2f\nHeading=%.2f", x, y, z, heading))
            end

            if IsControlPressed(0, 172) then SetEntityCoords(prop, x, y + 0.1, z)
            elseif IsControlPressed(0, 173) then SetEntityCoords(prop, x, y - 0.1, z)
            elseif IsControlPressed(0, 174) then SetEntityCoords(prop, x - 0.1, y, z)
            elseif IsControlPressed(0, 175) then SetEntityCoords(prop, x + 0.1, y, z)
            elseif IsControlPressed(0, 44) then SetEntityCoords(prop, x, y, z + 0.1)
            elseif IsControlPressed(0, 38) then SetEntityCoords(prop, x, y, z - 0.1)
            elseif IsControlPressed(0, 241) then SetEntityHeading(prop, heading + 1.5)
            elseif IsControlPressed(0, 242) then SetEntityHeading(prop, heading - 1.5)
            elseif IsControlPressed(0, 19) then
                local playerZ = GetEntityCoords(playerPed)
                SetEntityCoords(prop, x, y, playerZ.z - 1.0)
            elseif IsControlJustPressed(0, 201) then
                editing = false
                if Config.Framework == "esx" then
                    lib.hideTextUI()
                elseif Config.Framework == "qb" then
                    exports['qb-core']:HideText()
                end
                PlaceObjectOnGroundProperly(prop)
                FreezeEntityPosition(prop, false)
                local finalCoords = GetEntityCoords(prop)
                local finalHeading = GetEntityHeading(prop)
                TriggerServerEvent("campfire:saveProp", modelName, finalCoords.x, finalCoords.y, finalCoords.z, finalHeading)
                Citizen.Wait(200)
                DeleteEntity(prop)
                Notify(Config.Translate.Success, "success", 5000)
            end
        end
    end)
end
exports("StartPropPlacement", StartPropPlacement)

RegisterNetEvent("campfire:startEffect")
AddEventHandler("campfire:startEffect", function(model, x, y, z)
    local key = string.format("%.2f_%.2f_%.2f", x, y, z)

    if not HasNamedPtfxAssetLoaded("core") then
        RequestNamedPtfxAsset("core")
        while not HasNamedPtfxAssetLoaded("core") do
            Wait(10)
        end
    end
    UseParticleFxAsset("core")

    local fireFx = StartParticleFxLoopedAtCoord(
        "ent_amb_beach_campfire",
        x, y - 0.15, z,
        0.0, 0.0, 0.0,
        1.0,
        false, false, false, false
    )

    activeFires[key] = fireFx
end)

RegisterNetEvent("campfire:stopEffect")
AddEventHandler("campfire:stopEffect", function(x, y, z)
    local key = string.format("%.2f_%.2f_%.2f", x, y, z)

    if activeFires[key] then
        StopParticleFxLooped(activeFires[key], false)
        activeFires[key] = nil
    end
end)

RegisterNetEvent("campfire:spawnProps")
AddEventHandler("campfire:spawnProps", function(propId, modelName, x, y, z, finalHeading)
    if not DoesEntityExist(GetHashKey(modelName)) then
        local obj = CreateObject(GetHashKey(modelName), x, y, z, true, true, true)
        SetEntityHeading(obj, finalHeading)
        PlaceObjectOnGroundProperly(obj)
        FreezeEntityPosition(obj, true)
        SetEntityCollision(obj, true, true)

        table.insert(SpawnedProps, { id = propId, object = obj })
        TriggerServerEvent("campfire:addTarget", propId, modelName, x, y, z, finalHeading)
    end
end)

RegisterNetEvent("campfire:addTarget")
AddEventHandler("campfire:addTarget", function(propId, modelName, x, y, z, finalHeading)
    if Config.Target == "ox" then
        exports.ox_target:addBoxZone({
            coords = vec3(x, y, z),
            size = vec3(1, 1, 1),
            rotation = finalHeading,
            debug = Config.Debug,

            options = {
                {
                    name = "fx01" .. propId,
                    icon = "fa-solid fa-fire",
                    label = Config.Translate.TargetFireOn,
                    distance = 3.0,
                    onSelect = function(data)
                        TriggerServerEvent("campfire:startEffect", modelName, x, y, z)
                    end,
                    canInteract = function(entity, distance, coords, name, bone)
                        local key = string.format("%.2f_%.2f_%.2f", x, y, z)
                        return fireFx == nil and activeFires[key] == nil
                    end
                },
                {
                    name = "fx02_" .. propId,
                    icon = "fa-solid fa-fire-extinguisher",
                    label = Config.Translate.TargetFireOff,
                    distance = 3.0,
                    onSelect = function(data)
                        TriggerServerEvent("campfire:stopEffect", x, y, z)
                    end,
                    canInteract = function(entity, distance, coords, name, bone)
                        local key = string.format("%.2f_%.2f_%.2f", x, y, z)
                        return activeFires[key] ~= nil
                    end
                },
                {
                    name = "campfire_" .. propId,
                    icon = "fa-solid fa-hand",
                    label = Config.Translate.TargetDisassembleLabel,
                    distance = 3.0,
                    onSelect = function(data)
                        if lib.progressCircle({
                            duration = Config.ProgressTime,
                            label = Config.Translate.TargetDisassembleLabel,
                            position = "bottom",
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                car = true,
                                combat = true,
                                mouse = false,
                                move = true,
                            },
                            anim = {
                                dict = 'mini@repair',
                                clip = 'fixing_a_ped' 
                            },
                        }) then
                            for i, spawnProp in ipairs(SpawnedProps) do
                                if spawnProp.id == propId then
                                    DeleteEntity(spawnProp.object)
                                    table.remove(SpawnedProps, i)
                                    break
                                end
                            end

                            TriggerServerEvent("campfire:removeProp", propId)
                            TriggerServerEvent("campfire:oxRemoveTarget", data)
                            Notify(Config.Translate.Disassemble, "success", 5000)
                        end
                    end,
                    canInteract = function(entity, distance, coords, name, bone)
                        local key = string.format("%.2f_%.2f_%.2f", x, y, z)
                        return fireFx == nil and activeFires[key] == nil
                    end
                },
            }
        })
    elseif Config.Target == "qb" then
        exports['qb-target']:AddCircleZone("campfire"..propId, vector3(x, y, z), 1.0, {
            name = "campfire"..propId,
            debugPoly = Config.Debug,
            }, {
            options = {
                {
                    icon = 'fas fa-fire',
                    label = Config.Translate.TargetFireOn,
                    action = function(entity)
                        TriggerServerEvent("campfire:startEffect", modelName, x, y, z)
                    end,
                    canInteract = function(entity, distance, data)
                        local key = string.format("%.2f_%.2f_%.2f", x, y, z)
                        if activeFires[key] ~= nil then return false end
                        return true
                    end,
                },
                {
                    icon = 'fas fa-fire-extinguisher',
                    label = Config.Translate.TargetFireOff,
                    action = function(entity)
                        TriggerServerEvent("campfire:stopEffect", x, y, z)
                    end,
                    canInteract = function(entity, distance, data)
                        local key = string.format("%.2f_%.2f_%.2f", x, y, z)
                        if activeFires[key] == nil then return false end
                        return true
                    end,
                },
                {
                    icon = 'fas fa-hand',
                    label = Config.Translate.TargetDisassembleLabel,
                    action = function(entity)
                        exports['progressbar']:Progress({
                            name = "campfire_takeFire",
                            duration = Config.ProgressTime,
                            label = Config.Translate.TargetDisassembleLabel,
                            useWhileDead = false,
                            canCancel = true,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            },
                            animation = {
                                animDict = "mini@repair",
                                anim = "fixing_a_ped",
                                flags = 49,
                            },
                            prop = {},
                            propTwo = {}
                         }, function(cancelled)
                            if not cancelled then
                                for i, spawnProp in ipairs(SpawnedProps) do
                                    if spawnProp.id == propId then
                                        DeleteEntity(spawnProp.object)
                                        table.remove(SpawnedProps, i)
                                        break
                                    end
                                end

                                TriggerServerEvent("campfire:removeProp", propId)
                                TriggerServerEvent("campfire:qbRemoveTarget", propId)
                                Notify(Config.Translate.Disassemble, "success", 5000)
                            else
                                StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
                                return
                            end
                         end)
                    end,
                    canInteract = function(entity, distance, data)
                        local key = string.format("%.2f_%.2f_%.2f", x, y, z)
                        if fireFx ~= nil and activeFires[key] ~= nil then return false end
                        return true
                    end,
                }
            },
            distance = 3.0,
        })
    end
end)

RegisterNetEvent("campfire:oxRemoveTarget")
AddEventHandler("campfire:oxRemoveTarget", function(data)
    exports.ox_target:removeZone(data.zone)
end)

RegisterNetEvent("campfire:qbRemoveTarget")
AddEventHandler("campfire:qbRemoveTarget", function(propId)
    exports['qb-target']:RemoveZone("campfire"..propId)
end)

RegisterNetEvent("campfire:deletePropById")
AddEventHandler("campfire:deletePropById", function(id)
    for i, prop in ipairs(SpawnedProps) do
        if prop.id == id then
            DeleteEntity(prop.object)
            table.remove(SpawnedProps, i)
            break
        end
    end
end)
