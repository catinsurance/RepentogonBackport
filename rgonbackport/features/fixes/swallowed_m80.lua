local mod = RgonBackport



---@param slot EntitySlot
---@param collider Entity
function mod:SwallowedM80Fix(slot, collider)
    if slot:GetState() == mod.SlotState.DESTROYED or slot:IsDead() then
        return
    end

    if collider.Type == EntityType.ENTITY_PLAYER and collider.Variant == PlayerVariant.PLAYER then
        local player = collider:ToPlayer()
        ---@diagnostic disable-next-line: need-check-nil
        if player:HasTrinket(TrinketType.TRINKET_SWALLOWED_M80) then
            -- Check for explosions on top of the player.
            -- If explosion, then this was blown up and should be removed.
            for _, explosion in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION)) do
                if explosion.Position:Distance(collider.Position) < 10 then
                    -- Explosion on player, should blow up.
                    slot:SetState(mod.SlotState.DESTROYED)
                    slot:SetSpriteFrame("Broken", 0)

                    -- Stop overlay animation (for Confessionals)
                    slot:GetSprite():StopOverlay()
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_SLOT_COLLISION, mod.SwallowedM80Fix, SlotVariant.BLOOD_DONATION_MACHINE)
mod:AddCallback(ModCallbacks.MC_POST_SLOT_COLLISION, mod.SwallowedM80Fix, SlotVariant.CONFESSIONAL)