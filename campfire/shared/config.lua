Config = {}

Config.Debug = false

Config.Framework = "esx" -- "esx" = es_extended  or  "qb" = qb_core

Config.Inventory = "ox" -- "ox" = ox_inventory  or  "qb" = qb-inventory

Config.Target = "ox" -- "ox" = ox_target  or  "qb" = qb-target

Config.Prop = 'log_campfire'

Config.Item = 'campfire'

Config.ProgressTime = 5000

Config.Translate = {
    Success = "You have placed the campfire!",
    Disassemble = "You have dismantle the campfire!",
    TargetDisassembleLabel = "Dismantle campfire",
    TargetFireOn = "Light a fire",
    TargetFireOff = "Put out the fire",
    ControlsUI = "[Q]    - Move UP  \n" ..
                "[E]    - Move Down  \n" ..
                "[ARROWS] - Move  \n" ..
                "[Mouse Scroll] - Rotate  \n" ..
                "[LALT] - Adjust Height  \n" ..
                "[ENTER]  - End Edit  \n"
}

Notify = function(msg, type, time)
    -- insert your notification system
    ESX.ShowNotification(msg, type, time) -- esx
    --QBCore.Functions.Notify(msg, type, time)  -- qb-core
end
