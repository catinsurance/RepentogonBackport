local mod = RgonBackport

Isaac.ReworkTrinket(TrinketType.TRINKET_MOMS_TOENAIL)

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
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_DROP_TRINKET, mod.ToenailDrop) ---@diagnostic disable-line:undefined-field
