require "scripts.HeatPalettes"

--- @class HeatGroup
--- @field content table<string, HeatMarker>> @Map<unit_number: string, HeatMarker>
--- @field group_name string
HeatGroup = {}
--- @param name string Индификатор группы + имя группы для GUI
--- @param group_entities LuaEntity[] набор игровых сущьностей для которых группы будет показывать температуру.
--- @return HeatGroup
function HeatGroup:new(name, group_entities)
    local obj = {
        classname = "HeatGroup",
        content = {}, -- :Table<unit_number: string, HeatMarker>
        -- __entities = {}, -- :Table<unit_number: string, Entity>
        group_name = name
    }

    -- obj config
    HeatGroupLogic.add_entities(obj, group_entities)
    return obj
end

HeatGroupLogic = {}

--- @param entity LuaEntity
--- @return nil
function HeatGroupLogic.add_entity(heat_group, entity)
    -- кейс в выборке есть Бойлеры и реакторы, но у них нет работы с теплом, как у Атомок
    if entity.valid == false or entity.temperature == nil then return end
    local temperature = HeatMarker.calc_temperature_for_entity(entity)
    heat_group.content["" .. entity.unit_number] = HeatMarker:new(entity, temperature)
        GlobalTable.register_entity_on_destory(entity)
end

--- @param heat_group HeatGroup
--- @param entities LuaEntity[]
--- @return nil
function HeatGroupLogic.add_entities(heat_group, entities)
    for _, entity in pairs(entities) do HeatGroupLogic.add_entity(heat_group, entity) end
end

--- @param heat_group HeatGroup
--- @param entity_unit_number string | integer
--- @return nil
function HeatGroupLogic.remove_entity(heat_group, entity_unit_number)
    local entity_id = "" .. entity_unit_number
    local marker = heat_group.content[entity_id]
    if (marker == nil) then return end
    HeatMarkerLogic.destroy(marker)
    heat_group.content[entity_id] = nil -- garbage collector дальше сам справится
end

--- @param heat_group HeatGroup
--- @return nil
function HeatGroupLogic.update_temperature_values(heat_group)
    set_palette()
    for unit_number, heat_marker in pairs(heat_group.content) do
        HeatMarkerLogic.update_temperature_overlay(heat_marker)
    end
end
