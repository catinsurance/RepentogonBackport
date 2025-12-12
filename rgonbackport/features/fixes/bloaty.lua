local mod = RgonBackport

---@param player EntityPlayer
---@param source EntityRef
function mod:BloatyFix(player, _, flags, source)
    if source.Type == EntityType.ENTITY_BLOATY then
        -- Check if colliding with Bloaty.
        -- If we are, don't proceed with the damage cancelling.

        local playerCapsule = player:GetCollisionCapsule()
        for _, ent in ipairs(Isaac.FindInCapsule(playerCapsule, EntityPartition.ENEMY)) do
            if GetPtrHash(ent) == GetPtrHash(source.Entity) then
                return
            end
        end

        -- Damage Bloaty's attack while the player is flying looks like collision damage.
        -- Since we just confirmed it's not a collision, we can safely cancel the damage.
        return false
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, mod.BloatyFix)