local mod = RgonBackport
local itemPool = mod.Game:GetItemPool()

---@type table<CollectibleType, ItemPoolStats>
---@class ItemPoolStats
---@field Weight? number
---@field DecreaseBy? number
---@field RemoveOn? number
---@field ShouldRemove boolean? -- Defaults to false, determines if item should be removed from current item pool

---@type table<ItemPoolType, table<CollectibleType, ItemPoolStats>>
mod.ItemPoolChanges = {
	[ItemPoolType.POOL_DEVIL] = {
		[CollectibleType.COLLECTIBLE_DRY_BABY] = {
			DecreaseBy = 1,
		},
		[CollectibleType.COLLECTIBLE_BROTHER_BOBBY] = {
			ShouldRemove = true,
		},
		[CollectibleType.COLLECTIBLE_SISTER_MAGGY] = {
			ShouldRemove = true,
		},
	},
}

for poolType, pools in pairs(mod.ItemPoolChanges) do
	local collectibles = {}
	for collectible, pool_stats in pairs(pools) do
		if not pool_stats.ShouldRemove then
			collectibles[#collectibles + 1] = {itemID = collectible, weight = pool_stats.Weight or 1.0, decreaseBy = pool_stats.DecreaseBy or 0.5, removeOn = pool_stats.RemoveOn or 0.1}
		end
	end
	itemPool:AddCollectible(poolType, collectibles)
end

function mod:RerollRemovedItemsFromPool(selectedCollectible, poolType, decrease, seed)
	local shouldChange = false
	local newCollectible = selectedCollectible
	local antisoftlockCounter = 0
	local rng = RNG(seed)
	while mod.ItemPoolChanges[poolType] and mod.ItemPoolChanges[poolType][newCollectible]
	and mod.ItemPoolChanges[poolType][newCollectible].ShouldRemove and antisoftlockCounter <= 100 do
		rng:Next()
		newCollectible = itemPool:GetCollectible(poolType, false, rng:GetSeed())
		antisoftlockCounter = antisoftlockCounter + 1
	end
	if antisoftlockCounter > 100 then
		newCollectible = CollectibleType.COLLECTIBLE_BREAKFAST
		shouldChange = true
	end
	if newCollectible ~= selectedCollectible then
		newCollectible = itemPool:GetCollectible(poolType, decrease, rng:GetSeed())
		shouldChange = true
	end
	if shouldChange then
		return newCollectible
	end
end

mod:AddPriorityCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, CallbackPriority.LATE, mod.RerollRemovedItemsFromPool)
