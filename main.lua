local loadImmediately = RgonBackport and RgonBackport.LoadDataImmediately
RgonBackport = RegisterMod("Repentogon Backport", 1)
local mod = RgonBackport

RgonBackport.SFX = SFXManager()
RgonBackport.Game = Game()
RgonBackport.ItemConfig = Isaac.GetItemConfig()

local scripts = {
    util = {
        "savedata",
        "util"
    },
    features = {
        items = {
            "seraphim",
            "revelation",
            "plan_c",
            "pageant_boy",
            "stat_changes",
        },
        pills = {
            "addicted",
            "gulp",
            "percs",
        },
        trinkets = {
            "moms_toenail"
        }
    }
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

loadScripts(scripts)

if loadImmediately then
    mod:GetSaveData()
    mod:SetShouldRestore()
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
