local mod = RgonBackport

local scheduled = {}
---@param func function
---@param frames integer
function RgonBackport:Schedule(func, frames)
    scheduled[#scheduled + 1] = {
        Count = mod.Game:GetFrameCount() + frames,
        Func = func,
    }
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    local current = mod.Game:GetFrameCount()
    for i = #scheduled, 1, -1 do
        local v = scheduled[i]
        if current >= v.Count then
            v.Func()
            scheduled[i] = nil
        end
    end
end)

---@param config ItemConfigPillEffect
---@param pillColor PillColor
---@param player EntityPlayer
---@param useFlags UseFlag
---@param isHorse? boolean
function RgonBackport:PerformPillUse(config, pillColor, player, useFlags, isHorse)
    isHorse = isHorse or pillColor & PillColor.PILL_GIANT_FLAG > 0

    local muteAnnouncer = Options.AnnouncerVoiceMode == AnnouncerVoiceMode.OFF
        or (useFlags & UseFlag.USE_NOANNOUNCER > 0)
    local announcerSfx = isHorse and config.AnnouncerVoiceSuper or config.AnnouncerVoice
    local announcerDelay = config.AnnouncerDelay
    local announcerFrameDelay = Options.AnnouncerVoiceMode == AnnouncerVoiceMode.RANDOM and 900 or 2

    if not muteAnnouncer then
        player:PlayDelayedSFX(announcerSfx, announcerDelay, announcerFrameDelay)
    end

    local pillName = Isaac.GetLocalizedString("PocketItems", config.Name, Options.Language)
    local ignoreStreak = useFlags & UseFlag.USE_NOHUD > 0

    if not ignoreStreak then
        mod.Game:GetHUD():ShowItemText(pillName)
    end

    mod.Game:SetBloom(30, 1)
    player:AnimatePill(pillColor, "UseItem")
end

---@param maxFireDelay number
function RgonBackport:ToTPS(maxFireDelay)
    return 30 / (maxFireDelay + 1)
end

---@param tearsPerSecond number
function RgonBackport:ToMFD(tearsPerSecond)
    return (30 / tearsPerSecond) - 1
end

-- Linearly scales chance from baseChance -> maxChance as rawLuck scales from 0 -> luckRequirement
-- Credit to Xalum and TearFlagLib
function RgonBackport:GetChance(rawLuck, baseChance, maxChance, luckRequirement, itemScalerN)
	local range = maxChance - baseChance
	local luck = math.max(math.min(rawLuck, luckRequirement), 0)
	local chance = baseChance + range * (luck / luckRequirement)

	if itemScalerN then -- Optionally stacks the chance based on a passed scaler, usually GetCollectibleNum
		chance = 1 - (1 - chance) ^ itemScalerN -- If itemScalerN is 0, the returned chance is 0%, which means that you don't *technically* have to check for item ownership if you pass a sensible itemScalerN
	end

	return chance
end