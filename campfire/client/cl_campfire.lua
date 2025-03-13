ESX = exports["es_extended"]:getSharedObject()

local loadedModels, SpawnedProps, activeFires  = {}, {}, {}
local modelName = Config.Prop

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

    lib.showTextUI(Config.Translate.ControlsUI)

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
            elseif IsControlJustPressed(0, 322) then
                editing = false
                lib.hideTextUI()
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
        exports.ox_target:addBoxZone({
            coords = vec3(x, y, z),
            size = vec3(2, 2, 2),
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
                    name = "moonshine2_" .. propId,
                    icon = "fa-solid fa-wine-bottle",
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
                            exports.ox_target:removeZone(data.zone)
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
    end
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