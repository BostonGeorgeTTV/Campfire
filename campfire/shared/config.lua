Config = {}

Config.Debug = false

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
                "[ESC]  - End Edit  \n"
}

Notify = function(msg, type, time)
    -- insert your notification system
    ESX.ShowNotification(msg, type, time)
end