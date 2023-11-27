--- @class HeatGroupList
--- @field content table<string, HeatGroup> @Map<heat_group_name : string, HeatGroup>
--- @field _next_elem_index number @
HeatGroupList = {}
--- @return HeatGroupList
function HeatGroupList:new()
    return {
        classname = "HeatGroupList",
        content = {}, --- @type table<string, HeatGroup> @Map<heat_group_name : string, HeatGroup>
        _next_elem_index = 1
    }
end

HeatGroupStoreLogic = {}
--- @param heat_group_list HeatGroupList
--- @return number
function HeatGroupStoreLogic.next_elem_index(heat_group_list)
    local curr_group_index = heat_group_list._next_elem_index
    heat_group_list._next_elem_index = curr_group_index + 1
    return curr_group_index
end

--- @param heat_group_list HeatGroupList
--- @param group_entites LuaEntity[]
--- @return HeatGroup
function HeatGroupStoreLogic.create_heat_group(heat_group_list, group_entites)
    local curr_group_index = HeatGroupStoreLogic.next_elem_index(heat_group_list)
    local heat_group_name = "Heat group " .. curr_group_index
    local rsl = HeatGroup:new(heat_group_name, group_entites)
    heat_group_list.content[heat_group_name] = rsl
    return rsl
end

--- @param heat_group_list HeatGroupList
--- @param heat_group_name string
--- @return nil
function HeatGroupStoreLogic.delete_heat_group(heat_group_list, heat_group_name)
    local heat_group = heat_group_list.content[heat_group_name]
    local heat_marker = heat_group.content["asd"]
    -- heat_marker.
    if (heat_group == nil) then
        log("WARM! delete_heat_group(\"" .. heat_group_name .. "\") -> nil   - Do nothing!")
        return
    end
    for _, heat_marker in pairs(heat_group.content) do
        -- log("marker_gui_text" .. heat_marker.gui_text_id)
        HeatMarkerLogic.destroy(heat_marker)
    end
    heat_group_list.content[heat_group_name] = nil
end
--- @param heat_group_list HeatGroupList
--- @param delete_entity_unit_number string
function HeatGroupStoreLogic.remove_entity_from_all_groups(heat_group_list, delete_entity_unit_number)

    --- @type table<HeatGroup, string>[] группа и entity.unit_number который нужно удалить из группы. 
    local modify_heat_groups = {}

    for group_name, heat_group in pairs(heat_group_list.content) do
        for entity_unit_number, heat_marker in pairs(heat_group.content) do
            log("lh : " .. entity_unit_number .. " - " .. delete_entity_unit_number .. "\r\n")
            if (entity_unit_number == "" .. delete_entity_unit_number) then
                table.insert(modify_heat_groups, {heat_group, entity_unit_number})
                goto next_group
                log("lh : " .. "inside" .. "\r\n")
            end
        end
        ::next_group::
    end
    for index, pair in ipairs(modify_heat_groups) do
        local heat_group = pair[1] --- @type HeatGroup
        local entity_unit_number = pair[2] --- @type string
        HeatGroupLogic.remove_entity(heat_group, entity_unit_number)
    end
end
