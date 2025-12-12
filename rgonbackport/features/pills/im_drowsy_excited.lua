local mod = RgonBackport
local game = mod.Game

---@param player EntityPlayer
---@param useFlags UseFlag
---@param pillColor PillColor
function mod:HorseImDrowsyExcitedUse(pillEffect, player, useFlags, pillColor)
    if pillEffect ~= PillEffect.PILLEFFECT_IM_DROWSY and pillEffect ~= PillEffect.PILLEFFECT_IM_EXCITED then return end
    if pillColor & PillColor.PILL_GIANT_FLAG > 0 then
        mod:GetLevelData().PillFloorEffect = pillEffect - 40
    end
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, mod.HorseImDrowsyExcitedUse)

function mod:ApplyHorseDrowsyExitedEffect()
    local effect = mod:GetLevelData().PillFloorEffect
    if effect then
        game:GetRoom():SetBrokenWatchState(effect)
        if effect == 1 then
            game:GetRoom():SetSlowDown(0xffffff)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.ApplyHorseDrowsyExitedEffect)