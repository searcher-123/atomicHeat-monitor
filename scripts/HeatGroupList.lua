
--- @class HeatGroupList
HeatGroupList = {}
function HeatGroupList:new()
    return {
        classname = "HeatGroupList",
        content = {}, --- :Table <heat_group_name : string, HeatGroup>
        _next_elem_index = 1
    }
    -- return obj
end

HeatGroupStoreLogic = {}
 function HeatGroupStoreLogic.next_elem_index(heatGroupList)
        local curr_group_index = heatGroupList._next_elem_index
        heatGroupList._next_elem_index = curr_group_index + 1
        return curr_group_index
    end

    function HeatGroupStoreLogic.create_heat_group(heatGroupList, group_entites)
        local curr_group_index = HeatGroupStoreLogic.next_elem_index(heatGroupList)
        local heat_group_name = "Heat group " .. curr_group_index
        local rsl = HeatGroup:new(heat_group_name, group_entites)
        heatGroupList.content[heat_group_name] = rsl
        return rsl
    end

    function HeatGroupStoreLogic.delete_heat_group(heatGroupList, group_name)
        local heat_group = heatGroupList.content[group_name]
        if (heat_group == nil) then
            log("WARM! delete_heat_group(\"" .. group_name .. "\") -> nil   - Do nothing!")
            return
        end
        for _, heat_marker in pairs(heat_group.content) do
            log("marker_gui_text" .. heat_marker.gui_text_id)
            HeatMarkerLogic.destroy(heat_marker)
        end
        heatGroupList.content[group_name] = nil
    end
