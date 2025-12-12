local mod = RgonBackport

Isaac.ReworkTrinket(TrinketType.TRINKET_SUPER_BALL)

local Constants = {
    MAX_LUCK = 18,
    BASE_CHANCE = 0.1,
}

---@param player EntityPlayer
---@param params TearParams
function mod:ReimplementSuperBall(player, params)
    local rng = player:GetTrinketRNG(TrinketType.TRINKET_SUPER_BALL)
    local chance = mod:GetChance(player.Luck, Constants.BASE_CHANCE, 1, Constants.MAX_LUCK)
    if player:HasTrinket(TrinketType.TRINKET_SUPER_BALL) and rng:RandomFloat() < chance then
        params.TearFlags = params.TearFlags | TearFlags.TEAR_BOUNCE
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, mod.ReimplementSuperBall)