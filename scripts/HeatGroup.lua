-- require "HeatMarker"
HeatGroup = {}
--- @param name string Индификатор группы + имя группы для GUI
--- @param group_entites Entity[] набор игровых сущьностей для которых группы будет показывать температуру.
function HeatGroup:new(name, group_entites)
    local obj = {
        classname = "HeatGroup",
        content = {}, -- :Table<unit_number: string, HeatMarker>
        -- __entities = {}, -- :Table<unit_number: string, Entity>
        group_name = name
    }

    -- obj config
    HeatGroupLogic.add_entities(obj, group_entites)
    -- obj:add_entities(group_entites)

    return obj
end

HeatGroupLogic = {}

--- @param entity Entity
function HeatGroupLogic.add_entity(heat_group, entity)
    -- кейс в выборке есть Бойлеры и реакторы, но у них нет работы с теплом, как у Атомок
    if entity.valid == false or entity.temperature == nil then return end
    local temperature = HeatMarker.calc_temperature_for_entity(entity)
    heat_group.content["" .. entity.unit_number] = HeatMarker:new(entity, temperature)
end

--- @param entities Entity[]
function HeatGroupLogic.add_entities(heat_group, entities)
    for _, entity in pairs(entities) do HeatGroupLogic.add_entity(heat_group, entity) end
end

function HeatGroupLogic.remove_entity(heat_group, entity)
    local entity_id = "" .. entity.unit_number
    local marker = heat_group.content[entity_id]
    marker.destroy()
    heat_group.content[entity_id] = nil -- garbage collector дальше сам справится
end

function HeatGroupLogic.update_temperature_values(heat_group)
    for unit_number, heat_marker in pairs(heat_group.content) do
        -- local entity = self:__entities()[unit_number]
        HeatMarkerLogic.update_temperature_overlay(heat_marker)
    end
end
