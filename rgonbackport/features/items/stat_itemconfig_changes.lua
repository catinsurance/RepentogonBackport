local mod = RgonBackport

---@class ItemConfigChanges
---@field TagsAdd? ItemConfig
---@field CacheFlagsAdd? CacheFlag

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
---@field ItemConfigChanges? ItemConfigChanges Key is item config value to change. TagsAdd adds to tags instead of overwriting them.

---@type table<CollectibleType, ItemStats>
mod.ItemStatChanges = {
    [CollectibleType.COLLECTIBLE_BLOOD_RIGHTS] = {
        ItemConfigChanges = {
            CacheFlagsAdd = CacheFlag.CACHE_FIREDELAY,
        },
    },
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
    [TrinketType.TRINKET_EQUALITY] = {
        ItemConfigChanges = {
            CacheFlagsAdd = CacheFlag.CACHE_FIREDELAY,
        },
    },
}

local function updateItemConfig(config, stats)
    if stats.ItemConfigChanges then
        for property, val in pairs(stats.ItemConfigChanges) do
            if property == "TagsAdd" then
                if config.Tags & val ~= val then
                    config.Tags = config.Tags | val
                end
            elseif property == "CacheFlagsAdd" then
                if config.CacheFlags & val ~= val then
                    config.CacheFlags = config.CacheFlags | val
                end
            else
                config[property] = val
            end
        end
    end

    for property in pairs(stats) do
        if property == "FlatDamage" or property == "Damage" then
            config.CacheFlags = config.CacheFlags | CacheFlag.CACHE_DAMAGE
        elseif property == "ShotSpeed" then
            config.CacheFlags = config.CacheFlags | CacheFlag.CACHE_SHOTSPEED
        elseif property == "Range" then
            config.CacheFlags = config.CacheFlags | CacheFlag.CACHE_RANGE
        elseif property == "Luck" then
            config.CacheFlags = config.CacheFlags | CacheFlag.CACHE_LUCK
        elseif property == "FlatTears" or property == "Tears" then
            config.CacheFlags = config.CacheFlags | CacheFlag.CACHE_FIREDELAY
        end
    end
end

-- Handle item config changes
for itemId, stats in pairs(mod.ItemStatChanges) do
    local config = mod.ItemConfig:GetCollectible(itemId)
    updateItemConfig(config, stats)
end

for trinketId, stats in pairs(mod.TrinketStatChanges) do
    local config = mod.ItemConfig:GetTrinket(trinketId)
    updateItemConfig(config, stats)
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
---@param player EntityPlayer
---@param cacheFlag integer
---@param current number
---@return number?
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
                    (stat == "Tears" and cacheFlag == EvaluateStatStage.TEARS_UP)
                    or (stat == "FlatTears" and cacheFlag == EvaluateStatStage.FLAT_TEARS)
                    or (stat == "Damage" and cacheFlag == EvaluateStatStage.DAMAGE_UP)
                    or (stat == "FlatDamage" and cacheFlag == EvaluateStatStage.FLAT_DAMAGE)
                ) then
                    return current + amount
                end
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.ChangeStats)
mod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, mod.ChangeTearsDamage)
