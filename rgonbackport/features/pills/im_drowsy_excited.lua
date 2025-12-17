local mod = RgonBackport
local game = mod.Game

---@param player EntityPlayer
---@param useFlags UseFlag
---@param pillColor PillColor
function mod:HorseImDrowsyExcitedUse(pillEffect, player, useFlags, pillColor)
    if pillEffect ~= PillEffect.PILLEFFECT_IM_DROWSY and pillEffect ~= PillEffect.PILLEFFECT_IM_EXCITED then return end
    if pillColor & PillColor.PILL_GIANT_FLAG > 0 then
        local levelData = mod:GetLevelData()
        if pillEffect == PillEffect.PILLEFFECT_IM_DROWSY then
            levelData.PillFloorEffect = 1
        else
            levelData.PillFloorEffect = 2
        end
    end
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, mod.HorseImDrowsyExcitedUse)

function mod:ApplyHorseDrowsyExcitedEffect()
    local runData = mod:GetRunData()
    local effect = mod:GetLevelData().PillFloorEffect
    local room = game:GetRoom()
    if effect then
        room:SetBrokenWatchState(effect)
        if effect == 1 then
            room:SetSlowDown(0xffffff)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.ApplyHorseDrowsyExcitedEffect)

function mod:CancelHorseDrowsyExcitedEffect()
    local floorData = mod:GetLevelData()
    floorData.PillFloorEffect = nil
end
mod:AddCallback(ModCallbacks.MC_PRE_LEVEL_INIT, mod.CancelHorseDrowsyExcitedEffect)