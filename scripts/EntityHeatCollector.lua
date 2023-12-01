--- @class EntityHeatCollector
--- @field heat_group_name string
--- @field is_recording boolean
--- @field columns EntityHeatDataColumn[]
--- @field _record_count integer
--- @field decimator integer охранять 1 тик из..
EntityHeatCollector = {}

--- @param heat_group_name string
--- @param entities LuaEntity[]
--- @return EntityHeatCollector
function EntityHeatCollector:new(heat_group_name, entities)
    return {
        heat_group_name = heat_group_name, --- @type string
        is_recording = false, --- @type boolean
        columns = EntityHeatCollectorLogic.map_entities_to_columns(entities), --- @type EntityHeatDataColumn[]
        _record_count = 1, --- @type integer 
        decimator = 60, --- @type integer сохранять 1 тик из..
    }
end

EntityHeatCollectorLogic = {}

--- @param recorder EntityHeatCollector
--- @param entities LuaEntity[]
--- @return EntityHeatCollector
function EntityHeatCollectorLogic.copy(recorder, entities)
    return {
        heat_group_name = recorder.heat_group_name,
        is_recording = recorder.is_recording,
        columns = EntityHeatCollectorLogic.map_entities_to_columns(entities),
        _record_count = recorder._record_count,
        decimator = recorder.decimator,
    }
end

--- @param collector EntityHeatCollector
--- @param player_name string
function EntityHeatCollectorLogic.start_record(collector, player_name)
    if collector.is_recording == true then return end -- типа миссклик
    game.print('AHM: player: "' .. player_name .. '"' .. " - heat group: \"" .. collector.heat_group_name ..
                   "\" - start recording")
    collector.is_recording = true
end

--- @param collector EntityHeatCollector
--- @param player_name string
function EntityHeatCollectorLogic.stop_record(collector, player_name)
    game.print('AHM: player: "' .. player_name .. '"' .. " - heat group: \"" .. collector.heat_group_name ..
                   "\" - stop recording")
    if collector.is_recording == false then return end -- типа миссклик
    collector.is_recording = false
    FileWriter.flush_to_file(collector, player_name)
end

--- Примичание: тут можно реализовать настройку "собирать данные с интервалом в N тиков",
--- то есть скипать тики, которые не нужно собирать данные.
--- @param collector EntityHeatCollector
function EntityHeatCollectorLogic.do_every_tick(collector, tick)
    if (tick % collector.decimator ~= 0) then return end
    game.print("AHM: heat group \"" .. collector.heat_group_name .. "\" is recording")
    for index, col in ipairs(collector.columns) do
        if col.entity.valid == false then goto continue end
        -- col["tick " .. tick] = HeatMarkerLogic.calc_temperature_for_entity(col.entity)
        col["tick " .. tick] = col.entity.temperature
        ::continue::
    end
end

--- @param entities LuaEntity[]
--- @return table<EntityHeatDataColumn>
function EntityHeatCollectorLogic.map_entities_to_columns(entities)
    --- @type table<EntityHeatDataColumn>
    local columns = {}
    for index, entity in ipairs(entities) do
        if entity.valid == true then table.insert(columns, EntityHeatDataColumn:new(entity)) end
    end
    return columns
end
-----------------------------------------------------------
-----------------------------------------------------------
-----------------------------------------------------------
FileWriter = {}

--- @param collector EntityHeatCollector
--- @param player_name string
function FileWriter.flush_to_file(collector, player_name)
    local world_seed = game.surfaces[1].map_gen_settings.seed
    local filename = 'ahm__' .. player_name .. '__' .. world_seed .. '__' .. collector.heat_group_name .. '__#' ..
                         collector._record_count .. '.csv'
    collector._record_count = collector._record_count + 1

    game.print('AHM: player: "' .. player_name .. '" - ' .. 'heat group: "' .. collector.heat_group_name .. '" - ' ..
                   'start write to file: "' .. filename .. '"')

    local content_buffer = ""
    local line = ""
    local columns = collector.columns

    --- @type string[]
    local ordered_field_names = {}
    for field_name, value in pairs(columns[1]) do table.insert(ordered_field_names, field_name) end

    for index, field_name in ipairs(ordered_field_names) do
        if (index == 1) then goto continue end
        line = field_name .. ";"
        for index, col in ipairs(columns) do line = line .. tostring(col[field_name]) .. ";" end
        content_buffer = content_buffer .. line .. "\r\n"
        ::continue::
    end

    game.write_file(filename, content_buffer)
    game.print('AHM: player: "' .. player_name .. '" - ' .. 'heat group: "' .. collector.heat_group_name .. '" - ' ..
                   'stop write to file: "' .. filename .. '"')
end

--- @param point2D table {x : double, y : double}
function FileWriter.point2D_to_string(point2D) return "x=" .. tostring(point2D.x) .. "," .. "y=" .. tostring(point2D.y) end

-----------------------------------------------------------
-----------------------------------------------------------
-----------------------------------------------------------

--- @class EntityHeatDataColumn
--- @field entity LuaEntity
--- @field unit_number string
--- @field entity_type string
--- @field entity_pos  string
--- @field bounding_box__right_bottom  string
--- @field bounding_box__left_top  string
EntityHeatDataColumn = {}

--- @param entity LuaEntity
--- @return EntityHeatDataColumn 
function EntityHeatDataColumn:new(entity)
    return {
        entity = entity,
        unit_number = "" .. entity.unit_number,
        entity_type = "" .. entity.type,
        entity_pos = FileWriter.point2D_to_string(entity.position),
        bounding_box__right_bottom = FileWriter.point2D_to_string(entity.bounding_box.right_bottom),
        bounding_box__left_top = FileWriter.point2D_to_string(entity.bounding_box.left_top)
    }
end

return EntityHeatCollector
