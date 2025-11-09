-- https://isaacblueprints.com/tutorials/concepts/entity_data/

local dataHolder = {
    Data = {},
}

---@param entity Entity
---@return table
function dataHolder:GetData(entity)
    local ptrHash = GetPtrHash(entity)
    if not dataHolder.Data[ptrHash] then
        dataHolder.Data[ptrHash] = {
            Pointer = EntityPtr(entity),
        }
    end

    return dataHolder.Data[ptrHash]
end

return dataHolder
