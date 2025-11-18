--[[
    Special Rooms Trinkets
    - Bloody Crown
    - Silver Dollar
    - Wicked Crown
    - Holy Crown
]]

--fixed bugged enum
if RoomSubType.TREASURE_NORMAL == 1 then
    RoomSubType.TREASURE_NORMAL = 0
end

local mod = RgonBackport
local game = mod.Game

local Constants = {
    MAX_DIMENSION_ROOMS = 169,
}

---@param stage LevelStage
---@param stageType StageType
---@param roomType RoomType
---@return TrinketType
local function GetTrinketFromStage(stage, stageType, roomType)
    if stage == LevelStage.STAGE4_1 or stage == LevelStage.STAGE4_2 then
        if roomType == RoomType.ROOM_TREASURE then
            return TrinketType.TRINKET_BLOODY_CROWN
        elseif roomType == RoomType.ROOM_SHOP then
            return TrinketType.TRINKET_SILVER_DOLLAR
        end
    elseif stage == LevelStage.STAGE5 then
        return stageType == StageType.STAGETYPE_WOTL and TrinketType.TRINKET_HOLY_CROWN or TrinketType.TRINKET_WICKED_CROWN
    end

    return TrinketType.TRINKET_NULL
end

---@param slot LevelGeneratorRoom
---@param roomConfig RoomConfigRoom
---@param seed integer
function mod:HandleSpecialRoomReplacement(slot, roomConfig, seed)
    local level = game:GetLevel()
    local levelStage, stageType = level:GetStage(), level:GetStageType()

    --trinkets that adds special rooms in later stages are banned in greed mode anyway
    if game:IsGreedMode() or levelStage < LevelStage.STAGE4_1 then
        return
    end

    local stageID = roomConfig.StageID ---@type StbType
    local roomType = roomConfig.Type
    local roomSubtype = roomConfig.Subtype ---@type RoomSubType

    local trinketID = GetTrinketFromStage(levelStage, stageType, roomType)
    if trinketID ~= TrinketType.TRINKET_NULL then
        local shouldApplyRoomChange = PlayerManager.GetTotalTrinketMultiplier(trinketID) >= 2

        if shouldApplyRoomChange then
            local targetSubtype ---@type RoomSubType
            local targetRoomConfig ---@type RoomConfigRoom

            if roomType == RoomType.ROOM_TREASURE then
                if roomSubtype == RoomSubType.TREASURE_NORMAL or roomSubtype == RoomSubType.TREASURE_PAY_TO_PLAY then
                    targetSubtype = roomSubtype + 1

                    targetRoomConfig = RoomConfig.GetRandomRoom(seed, true, stageID, roomType, roomConfig.Shape, nil, nil, nil, nil, roomConfig.Doors, targetSubtype, 0)

                    if not targetRoomConfig then
                        targetRoomConfig = RoomConfig.GetRandomRoom(seed, true, StbType.SPECIAL_ROOMS, roomType, roomConfig.Shape, nil, nil, nil, nil, roomConfig.Doors, targetSubtype, 0)
                    end
                end
            elseif roomType == RoomType.ROOM_SHOP then
                local shopSubtypeOffset = roomSubtype >= 100 and 100 or 0
                local maxLevel = shopSubtypeOffset + 4

                if roomSubtype == RoomSubType.SHOP_KEEPER_RARE_GOOD or roomSubtype == RoomSubType.SHOP_RARE_GOOD then
                    return
                elseif roomSubtype == maxLevel or roomSubtype == RoomSubType.SHOP_RARE_BAD then
                    --room is good already :) (i don't know if buffed trinket changes bad layout to the good one)
                    targetSubtype = RoomSubType.SHOP_RARE_GOOD + shopSubtypeOffset
                else
                    targetSubtype = math.max(shopSubtypeOffset, math.min(roomSubtype + 1, maxLevel))
                end

                if targetSubtype then
                    targetRoomConfig = RoomConfig.GetRandomRoom(seed, true, StbType.SPECIAL_ROOMS, roomType, roomConfig.Shape, nil, nil, nil, nil, roomConfig.Doors, targetSubtype, 0)
                end
            end

            if targetRoomConfig then
                return targetRoomConfig
            end
        end
    end
end

---@param player EntityPlayer
function mod:SpecialRoomsMinimapReveal(player)
    local level = mod.Game:GetLevel()
    local levelStage, stageType = level:GetStage(), level:GetStageType()

    if game:IsGreedMode() or levelStage < LevelStage.STAGE4_1 then
        return
    end

    for i = 0, Constants.MAX_DIMENSION_ROOMS do
        local roomDesc = level:GetRoomByIdx(i, Dimension.NORMAL)
        local data = roomDesc.Data
        if data then
            local roomType = data.Type
            if roomType == RoomType.ROOM_TREASURE or roomType == RoomType.ROOM_SHOP then
                local trinketID = GetTrinketFromStage(levelStage, stageType, roomType)
                if trinketID ~= TrinketType.TRINKET_NULL then
                    local shouldDisplayRoom = player:GetTrinketMultiplier(trinketID) >= 3
                    if shouldDisplayRoom then
                        roomDesc.DisplayFlags = roomDesc.DisplayFlags | RoomDescriptor.DISPLAY_ICON
                        Minimap.Refresh()
                    end
                end
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, mod.HandleSpecialRoomReplacement)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, mod.SpecialRoomsMinimapReveal)
