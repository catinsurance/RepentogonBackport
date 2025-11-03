local mod = RgonBackport
local game = mod.Game

--toggle once callback will be pushed for next pre-release
--[[
 ---@param dropPos Vector
---@param player EntityPlayer
---@param isGolden boolean
function mod:ToenailDrop(_, dropPos, player, isGolden)
    local trinketModif = 0

    if isGolden then
        trinketModif = trinketModif + 1
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
        trinketModif = trinketModif + 1
    end

    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MOM_FOOT_STOMP, 0, dropPos, Vector.Zero, player)
    if trinketModif > 0 then
        for i = 1, trinketModif do
            Isaac.CreateTimer(function()
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MOM_FOOT_STOMP, 0, dropPos, Vector.Zero, player)
            end, i * 15, 1, false)
        end
    end
end ]]

---@param player EntityPlayer
---@param trinketID TrinketType
function mod:ToenailRemove(player, trinketID)
    if (trinketID & TrinketType.TRINKET_ID_MASK) == TrinketType.TRINKET_MOMS_TOENAIL then
        local plrData = mod:GetData(player)
        plrData.RgonBackPortHasMomsBox = player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX)
        plrData.RgonBackPortPlayerWasHoldingDropAction = player:GetLastActionTriggers() & ActionTriggers.ACTIONTRIGGER_ITEMSDROPPED > 0
    end
end

---@param pick EntityPickup
function mod:ToenailDrop(pick)
    local room = game:GetRoom()

    -- Only functions in rooms with combat
    if room:IsClear() then
        return
    end

    if (pick.SubType & TrinketType.TRINKET_ID_MASK) == TrinketType.TRINKET_MOMS_TOENAIL then
        mod:Schedule(function()
            local player = pick.SpawnerEntity and pick.SpawnerEntity:ToPlayer()
            if player then
                local plrData = mod:GetData(player)
                local trinketModif = 0
                if plrData.RgonBackPortHasMomsBox then
                    trinketModif = trinketModif + 1
                end

                if pick.SubType & TrinketType.TRINKET_GOLDEN_FLAG > 0 then
                    trinketModif = trinketModif + 1
                end

                if plrData.RgonBackPortPlayerWasHoldingDropAction then
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MOM_FOOT_STOMP, 0, pick.Position, Vector.Zero, pick)
                    --for i = 1, trinketModif do
                    if trinketModif > 0 then
                        for i = 1, trinketModif do
                            Isaac.CreateTimer(function()
                                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MOM_FOOT_STOMP, 0, pick.Position, Vector.Zero, pick)
                            end, i * 15, 1, false)
                        end
                    end
                end
            end
        end, 2)
    end
end

local spawnedDuringFrame = false

---@param player EntityPlayer
function mod:ToenailDetection(player)
    if not player:HasTrinket(TrinketType.TRINKET_MOMS_TOENAIL) then
        return
    end

    local trinketMult = player:GetTrinketMultiplier(TrinketType.TRINKET_MOMS_TOENAIL)

    spawnedDuringFrame = player:IsFrame(600 / trinketMult, 2)
end

---@param eff EntityEffect
function mod:ToenailVanillaRemove(eff)
    if not spawnedDuringFrame then
        return
    end

    if not eff.SpawnerEntity then
        --maybe there is a better way to remove it
        eff.Visible = false
        eff:Remove()
    end
end

--mod:AddCallback(ModCallbacks.MC_POST_PLAYER_DROP_TRINKET, mod.ToenailDrop) ---@diagnostic disable-line:undefined-field
mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, mod.ToenailRemove)
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.ToenailDrop, PickupVariant.PICKUP_TRINKET)
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.ToenailDetection, PlayerVariant.PLAYER)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.ToenailVanillaRemove, EffectVariant.MOM_FOOT_STOMP)
