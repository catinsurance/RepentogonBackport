local mod = RgonBackport

---@class ItemStats
---@field Tears? number
---@field FlatTears? number
---@field ShotSpeed? number
---@field Range? number
---@field Luck? number
---@field FireRate? number
---@field Damage? number
---@field FlatDamage? number
---@field ShouldStack boolean? Defaults to true, determines if stat changes should stack or not.
---@field ItemConfigChanges? table Key is item config value to change. TagsAdd adds to tags instead of overwriting them.

---@type table<CollectibleType, ItemStats>
mod.ItemStatChanges = {
    [CollectibleType.COLLECTIBLE_2SPOOKY] = {
        FlatTears = 0.5,
        ShotSpeed = 0.2,
        ItemConfigChanges = {
            TagsAdd = ItemConfig.TAG_TEARS_UP,
        },
    },
    [CollectibleType.COLLECTIBLE_REVELATION] = {
        ItemConfigChanges = {
            AddSoulHearts = 0,
        },
    },
    [CollectibleType.COLLECTIBLE_SERAPHIM] = {
        ItemConfigChanges = {
            TagsAdd = ItemConfig.TAG_ANGEL,
        },
    },
}

---@type table<TrinketType, ItemStats>
mod.TrinketStatChanges = {
    [TrinketType.TRINKET_LAZY_WORM] = {
        Damage = .5,

    },
    [TrinketType.TRINKET_BOBS_BLADDER] = {
        ItemConfigChanges = {
            TagsAdd = ItemConfig.TAG_BOB,
        },
    },
}

-- Handle item config changes
for itemId, stats in pairs(mod.ItemStatChanges) do
    local config = mod.ItemConfig:GetCollectible(itemId)
    if stats.ItemConfigChanges then
        for property, val in pairs(stats.ItemConfigChanges) do
            if property == "TagsAdd" then
                if config.Tags & val ~= val then
                    config.Tags = config.Tags | val
                end
            else
                config[property] = val
            end
        end
    end

    for property in pairs(stats) do
        if property == "Damage" then
            config.CacheFlags = config.CacheFlags | CacheFlag.CACHE_DAMAGE
        elseif property == "ShotSpeed" then
            config.CacheFlags = config.CacheFlags | CacheFlag.CACHE_SHOTSPEED
        elseif property == "Range" then
            config.CacheFlags = config.CacheFlags | CacheFlag.CACHE_RANGE
        elseif property == "Luck" then
            config.CacheFlags = config.CacheFlags | CacheFlag.CACHE_LUCK
        elseif property == "FireRate" or property == "Tears" then
            config.CacheFlags = config.CacheFlags | CacheFlag.CACHE_FIREDELAY
            print("hi")
        end
    end
end

---@param player EntityPlayer
---@param trinketType TrinketType
function mod:UpdateTrinketCache(player, trinketType)
    ---@type TrinketType
    local maskedTrinketType = trinketType & TrinketType.TRINKET_ID_MASK
    if maskedTrinketType == TrinketType.TRINKET_LAZY_WORM then
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE) -- probably should be changed with different approach to not constantly calling AddCacheFlags
    end

    player:EvaluateItems()
end

---@param player EntityPlayer
---@param cacheFlag CacheFlag
function mod:ChangeStats(player, cacheFlag)
    if cacheFlag & CacheFlag.CACHE_DAMAGE > 0 then
        local lazyWormMult = player:GetTrinketMultiplier(TrinketType.TRINKET_LAZY_WORM)
        if lazyWormMult > 0 then
            player.Damage = player.Damage + (mod.TrinketStatChanges[TrinketType.TRINKET_LAZY_WORM].Damage * lazyWormMult)
        end
    end

    for itemId, stats in pairs(mod.ItemStatChanges) do
        local count = player:GetCollectibleNum(itemId)
        if count > 0 then
            local shouldStack = stats.ShouldStack ~= false
            for stat, val in pairs(stats) do
                local amount
                if type(val) == "number" then
                    amount = shouldStack and val * count or val
                end

                if stat == "Damage" and cacheFlag == CacheFlag.CACHE_DAMAGE then
                    player.Damage = player.Damage + amount
                elseif stat == "ShotSpeed" and cacheFlag == CacheFlag.CACHE_SHOTSPEED then
                    player.ShotSpeed = player.ShotSpeed + amount
                elseif stat == "Range" and cacheFlag == CacheFlag.CACHE_RANGE then
                    player.TearRange = player.TearRange + amount
                elseif stat == "Luck" and cacheFlag == CacheFlag.CACHE_LUCK then
                    player.Luck = player.Luck + amount
                elseif stat == "FireRate" and cacheFlag == CacheFlag.CACHE_FIREDELAY then
                    local tears = mod:ToTPS(player.MaxFireDelay) + amount
                    player.MaxFireDelay = mod:ToMFD(tears)
                end

                -- Normal tears up is handled in a different callback so that it abides by vanilla limits.
            end
        end
    end
end

-- Only handles different tears ups and damage ups.
function mod:ChangeTearsDamage(player, cacheFlag, current)
    for itemId, stats in pairs(mod.ItemStatChanges) do
        local count = player:GetCollectibleNum(itemId)
        if count > 0 then
            local shouldStack = stats.ShouldStack ~= false
            for stat, val in pairs(stats) do
                local amount
                if type(val) == "number" then
                    amount = shouldStack and val * count or val
                end

                if (
                    stat == "Tears"
                    or stat == "FlatTears"
                    or stat == "Damage"
                    or stat == "FlatDamage"
                ) then
                    return current + amount
                end
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, mod.UpdateTrinketCache)
mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, mod.UpdateTrinketCache)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.ChangeStats)
mod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, mod.ChangeTearsDamage)
