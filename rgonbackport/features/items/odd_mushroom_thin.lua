local mod = RgonBackport

if Isaac.ReworkCollectible ~= nil then
    Isaac.ReworkCollectible(CollectibleType.COLLECTIBLE_ODD_MUSHROOM_THIN)
end

---@param player EntityPlayer
---@param cacheFlag integer
---@param current number
---@return number?
function mod:ThinOddMushroomStats(player, cacheFlag, current)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_ODD_MUSHROOM_THIN) then
        if cacheFlag == EvaluateStatStage.FLAT_TEARS then
            return current + 1
        elseif cacheFlag == EvaluateStatStage.FLAT_DAMAGE then
            return current * 0.9 - 0.4
        end
    end
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, mod.ThinOddMushroomStats)