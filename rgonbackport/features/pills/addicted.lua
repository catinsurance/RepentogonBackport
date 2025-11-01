local mod = RgonBackport
local game = mod.Game

---@param player EntityPlayer
---@param pillColor PillColor
---@return boolean?
function mod:HorseAddictedUse(_, player, _, pillColor)
    local isHorse = pillColor & PillColor.PILL_GIANT_FLAG > 0

    if isHorse then
        player:AddBrokenHearts(1)
    end
end

mod:AddCallback(ModCallbacks.MC_USE_PILL, mod.HorseAddictedUse, PillEffect.PILLEFFECT_ADDICTED)
