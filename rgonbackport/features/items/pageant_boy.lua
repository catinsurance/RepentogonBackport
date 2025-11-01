local mod = RgonBackport
local game = mod.Game

local Constants = {
    CoinTrinkets = {
        TrinketType.TRINKET_SWALLOWED_PENNY,
        TrinketType.TRINKET_BUTT_PENNY,
        TrinketType.TRINKET_SWALLOWED_PENNY,
        TrinketType.TRINKET_BURNT_PENNY,
        TrinketType.TRINKET_FLAT_PENNY,
        TrinketType.TRINKET_COUNTERFEIT_PENNY,
        TrinketType.TRINKET_ROTTEN_PENNY,
        TrinketType.TRINKET_BLESSED_PENNY,
        TrinketType.TRINKET_CHARGED_PENNY,
        TrinketType.TRINKET_CURSED_PENNY,
    }
}

local spawnedFromPageant = false
---@type EntityPickup[]
local pageantCoins = {}

---@param firstTime boolean
function mod:PrePageantCollect(_, _, firstTime)
    if firstTime then
        pageantCoins = {}
        spawnedFromPageant = true
    end
end

---@param pickup EntityPickup
function mod:PageantCoinsInit(pickup)
    if spawnedFromPageant then
        pageantCoins[#pageantCoins + 1] = pickup
    end
end

---@param itemID CollectibleType
---@param firstTime boolean
---@param player EntityPlayer
function mod:PageantCollect(itemID, _, firstTime, _, _, player)
    if firstTime then
        spawnedFromPageant = false
        local itemPool = game:GetItemPool()

        local availableTrinkets = {}
        for i = 1, #Constants.CoinTrinkets do
            if itemPool:HasTrinket(Constants.CoinTrinkets[i]) then
                availableTrinkets[#availableTrinkets + 1] = Constants.CoinTrinkets[i]
            end
        end

        print("added availableTrinkets", #availableTrinkets)
        if #availableTrinkets == 0 then
            return
        end

        local itemRNG = player:GetCollectibleRNG(itemID)
        local selectedCoin = pageantCoins[itemRNG:RandomInt(1, #pageantCoins)]

        local selectedTrinket = availableTrinkets[itemRNG:RandomInt(1, #availableTrinkets)]

        selectedCoin:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, selectedTrinket)
        itemPool:RemoveTrinket(selectedTrinket)
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, mod.PrePageantCollect, CollectibleType.COLLECTIBLE_PAGEANT_BOY)
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, mod.PageantCollect, CollectibleType.COLLECTIBLE_PAGEANT_BOY)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.PageantCoinsInit, PickupVariant.PICKUP_COIN)
