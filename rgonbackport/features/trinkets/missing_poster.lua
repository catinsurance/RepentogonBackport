local mod = RgonBackport

local Constants = {
    MAX_DIMENSION_ROOMS = 169,
}

---@param player EntityPlayer
function mod:RevealSuperSecretRoom(player)
    local level = mod.Game:GetLevel()
    local posterMultiplier = player:GetTrinketMultiplier(TrinketType.TRINKET_MISSING_POSTER)
    if posterMultiplier > 0 then
        local trinketRNG = player:GetTrinketRNG(TrinketType.TRINKET_MISSING_POSTER)
        local roll = trinketRNG:RandomInt(3 - posterMultiplier)

        if roll == 0 then
            for i = 0, Constants.MAX_DIMENSION_ROOMS do
                local roomDesc = level:GetRoomByIdx(i, Dimension.NORMAL)
                local data = roomDesc.Data
                if data then
                    if data.Type == RoomType.ROOM_SUPERSECRET then
                        roomDesc.DisplayFlags = roomDesc.DisplayFlags | RoomDescriptor.DISPLAY_ICON
                        Minimap.Refresh()
                        break
                    end
                end
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, mod.RevealSuperSecretRoom)
