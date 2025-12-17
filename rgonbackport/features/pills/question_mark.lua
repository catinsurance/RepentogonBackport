local mod = RgonBackport
local game = mod.Game

-- Mods can feel free to add to this
mod.QuestionMarkPillCurses = {
    LevelCurse.CURSE_OF_DARKNESS,
    LevelCurse.CURSE_OF_THE_LOST,
    LevelCurse.CURSE_OF_THE_UNKNOWN,
    LevelCurse.CURSE_OF_BLIND,
}

---@param player EntityPlayer
---@param useFlags UseFlag
---@param pillColor PillColor
function mod:HorseQuestionMarkUse(pillEffect, player, useFlags, pillColor)
    if pillColor & PillColor.PILL_GIANT_FLAG > 0 then
        local level = game:GetLevel()
        local outcome = WeightedOutcomePicker()
        local curses = level:GetCurses()
        for _, curse in ipairs(mod.QuestionMarkPillCurses) do
            if curses & curse == 0 then
                outcome:AddOutcomeWeight(curse, 1)
            end
        end
        if outcome:GetNumOutcomes() > 0 then
            local curse = outcome:PickOutcome(player:GetPillRNG(pillEffect))
            level:AddCurse(curse, false)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, mod.HorseQuestionMarkUse, PillEffect.PILLEFFECT_QUESTIONMARK)