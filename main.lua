local loadImmediately = RgonBackport and RgonBackport.LoadDataImmediately
---@class RgonBackport : ModReference
---@field LoadDataImmediately boolean
RgonBackport = RegisterMod("Repentogon Backport", 1)
local mod = RgonBackport

RgonBackport.SFX = SFXManager()
RgonBackport.Game = Game()
RgonBackport.ItemConfig = Isaac.GetItemConfig()

local scripts = {
    util = {
        "savedata",
        "constants",
        "util",
    },
    features = {
        items = {
            "blood_rights",
            "odd_mushroom_thin",
            "plan_c",
            "pageant_boy",
            "item_pool_changes",
            "stat_itemconfig_changes",
        },
        pills = {
            "addicted",
            "gulp",
            "percs",
        },
        trinkets = {
            "moms_toenail",
            "missing_poster",
            "equality",
            "louse",
            "special_rooms_trinkets",
        },
        fixes = {
            "dogma_bombs",
            "swallowed_m80"
        },
        misc = {

        },
    },
}

local function loadScripts(t, path)
    path = path or "rgonbackport."
    for i, v in pairs(t) do
        if type(v) == "table" then
            loadScripts(v, path .. i .. ".")
        else
            include(path .. v)
        end
    end
end

local dataHolder = require("rgonbackport.util.getdata")
RgonBackport.GetData = dataHolder.GetData

function mod:ClearDataOnRemoveOrDeath(entity)
    local ptrHash = GetPtrHash(entity)
    dataHolder.Data[ptrHash] = nil
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.ClearDataOnRemoveOrDeath)

function mod:ClearDataOnExit()
    dataHolder.Data = {}
end

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.ClearDataOnExit)

if REPENTOGON and REPENTANCE_PLUS then
    loadScripts(scripts)

    if loadImmediately then
        mod:GetSaveData()
        mod:SetShouldRestore()
    end
else
    -- Render a warning in the first room that the mod is not active
    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        local room = mod.Game:GetRoom()
        local level = mod.Game:GetLevel()
        if (
            room:IsFirstVisit()
            and level:GetCurrentRoomIndex() == level:GetStartingRoomIndex()
            and level:GetStage() == LevelStage.STAGE1_1
            and (not REPENTOGON or level:GetDimension() == Dimension.NORMAL)
        ) then
            Isaac.RenderText("You need to be in Repentance+ to use the Repentogon backport!", 50, 50, 1, 1, 1, 1)
        end
    end)
end

--[[
-- Save manager testing
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function ()
    if Input.IsButtonTriggered(Keyboard.KEY_T, 0) and Isaac.IsInGame() then
        local save = mod:GetRunData(Isaac.GetPlayer())
        save.Test = math.random()
    end

    if Input.IsButtonTriggered(Keyboard.KEY_G, 0) and Isaac.IsInGame() then
        mod:SaveSaveData()
    end

    if Input.IsButtonTriggered(Keyboard.KEY_B, 0) and Isaac.IsInGame() then
        local save = mod:GetRunData(Isaac.GetPlayer())
        print(save.Test)
    end
end)
]]
