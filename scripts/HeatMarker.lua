require "scripts.HeatPalettes"

-------------------
--- Draw Params ---
-------------------

-- local text_red, text_yellow, text_green = { 1, 0, 0 }, { 1, 1, 0 }, { 0, 1, 0 }
-- local box_white = {
--     r = 161 / 256,
--     g = 161 / 256,
--     b = 161 / 256,
--     a = 0.1
-- }
-- local box_blue = {
--     r = 0 / 256,
--     g = 91 / 256,
--     b = 196 / 256,
--     a = 0.2
-- }
-- local box_red = {
--     r = 168 / 256,
--     g = 32 / 256,
--     b = 44 / 256,
--     a = 0.1
-- }
local transparent = {
    r = .1,
    g = .1,
    b = .1,
    a = .01
}
local draw_params_text = {
    target_offset = {0, -.375},
    forces = {},
    scale = 1.125,
    scale_with_zoom = false,
    alignment = "center",
    filled = true
}
local draw_params_box = {
    target_offset = {.2, -.375},
    forces = {},
    scale = 1.125,
    scale_with_zoom = true,
    alignment = "center",
    filled = true,
    left_top = {
        x = 0,
        y = 0
    },
    right_bottom = {
        x = 0,
        y = 0
    }
}

-------------------
--- HeatMarker ---
-------------------

--- @class HeatMarker
--- @field lua_entity LuaEntity Сущьности для которой мы рендерим Температуру
--- @field gui_box_id number id от LuaGuiElement
--- @field gui_text_id number id от LuaGuiElement
HeatMarker = {}
--- @param entity LuaEntity
--- @param temperature number
--- @return HeatMarker
function HeatMarker:new(entity, temperature)
    local box_id = HeatMarker.new_heat_box(entity, temperature)
    local text_id = HeatMarker.new_heat_text(entity, temperature)
    return {
        classname = "HeatMarker",
        lua_entity = entity,
        gui_box_id = box_id, -- :id от LuaGuiElement
        gui_text_id = text_id -- :id от LuaGuiElement
    }
end

----------------------------------
--- prvate API fro HeatMarker ---
----------------------------------

function HeatMarker.calc_temperature_for_entity(entity) return math.floor(entity.temperature) end

function HeatMarker.new_heat_text(heat_entity, temperature)
    draw_params_text.color = HeatMarkerLogic.approx_color_text(temperature)
    draw_params_text.text = temperature
    draw_params_text.surface = heat_entity.surface
    draw_params_text.target = heat_entity -- это важно, для обновления rendering_object.id после sale-load
    draw_params_text.forces[1] = heat_entity.force
    return rendering.draw_text(draw_params_text)
end

function HeatMarker.new_heat_box(heat_entity, temperature)
    draw_params_box.color = HeatMarkerLogic.approx_color_box(temperature)
    draw_params_box.left_top = heat_entity.selection_box.left_top
    draw_params_box.right_bottom = heat_entity.selection_box.right_bottom
    draw_params_box.surface = heat_entity.surface
    draw_params_box.forces[1] = heat_entity.force
    return rendering.draw_rectangle(draw_params_box)
end

HeatMarkerLogic = {}
-----------------
--- GUI text ---
-----------------
function HeatMarkerLogic.approx_color_text(temperature)
    if heat_palette.b_need_numbers == true then
        color4 = HeatMarkerLogic.calc_color_from_palette_and_temperature(heat_palette.ranges_numbers, temperature)
        color3 = HeatMarkerLogic.color_4_to_3(color4)
    else
        color3 = transparent
    end
    return color3

    --    if temperature < 250 then
    --      return text_red
    -- elseif temperature < 500 then
    --    return text_yellow
    -- else
    --    return text_green
    -- end
end

----------------
--- GUI box ---
----------------
function HeatMarkerLogic.approx_color_box(temperature)
    --    if temperature < 500 then
    --        return HeatMarkerLogic.approx_color(box_blue, box_white, temperature / 500)
    --    else
    --        return HeatMarkerLogic.approx_color(box_red, box_white, (1000 - temperature) / 500)
    --    end    

    if heat_palette.b_need_rects == true then
        color = HeatMarkerLogic.calc_color_from_palette_and_temperature(heat_palette.ranges_rects, temperature)

    else
        color = transparent
    end
    return color
end

function HeatMarkerLogic.calc_temperature_for_entity(entity) return math.floor(entity.temperature) end

----------------------------------------------------
--- mixing from two colors. colors  in range 0-1 ---
----------------------------------------------------

function HeatMarkerLogic.approx_color(colorTo, colorFrom, weight)
    return {
        r = colorFrom.r * weight + colorTo.r * (1 - weight),
        g = colorFrom.g * weight + colorTo.g * (1 - weight),
        b = colorFrom.b * weight + colorTo.b * (1 - weight),
        a = colorFrom.a * weight + colorTo.a * (1 - weight)
    }
end

--------------------------------------------
--- mixing from two colors. colors 0-255 ---
--------------------------------------------

function HeatMarkerLogic.approx_color4_255(color1, color2, weight)
    return {
        r = color1.r * weight + color2.r * (1 - weight),
        g = color1.g * weight + color2.g * (1 - weight),
        b = color1.b * weight + color2.b * (1 - weight),
        a = color1.a * weight + color2.a * (1 - weight)
    }
end

--------------------------------------------
--- Make color from palette              ---
--------------------------------------------

function HeatMarkerLogic.calc_color_from_palette_and_temperature(heat_palette_ranges, temperature)
    local calc_color = {
        r = 0,
        g = 0,
        b = 0,
        a = 0
    }
    local start_temp = 0
    local end_temp = 1000
    local target_range = heat_palette_ranges[1]
    for _, range_color in pairs(heat_palette_ranges) do
        if temperature <= range_color.range then
            end_temp = range_color.range
            target_range = range_color
            break
        else
            start_temp = range_color.range
        end
    end
    calc_color = HeatMarkerLogic.approx_color4_255(target_range.high, target_range.low,
                                                   (temperature - start_temp) / (end_temp - start_temp))
    return {calc_color.r, calc_color.g, calc_color.b, calc_color.a}
end

--------------------------------------------
--- Convert color for using by draw_text ---
--------------------------------------------

function HeatMarkerLogic.color_4_to_3(color_in)
    return {
        r = color_in[1],
        g = color_in[2],
        b = color_in[3]
    }
end

--- @param heat_marker HeatMarker
function HeatMarkerLogic.update_temperature_overlay(heat_marker)
    --- todo : временно! Если id не валидный, то пусть не работает корректно!
    if (rendering.is_valid(heat_marker.gui_box_id) == false or rendering.is_valid(heat_marker.gui_text_id) == false) then
        return
    end

    local temperature = HeatMarkerLogic.calc_temperature_for_entity(heat_marker.lua_entity)

    rendering.set_color(heat_marker.gui_box_id, HeatMarkerLogic.approx_color_box(temperature))

    rendering.set_text(heat_marker.gui_text_id, temperature)
    rendering.set_color(heat_marker.gui_text_id, HeatMarkerLogic.approx_color_text(temperature))
end

--- @param heat_marker HeatMarker
function HeatMarkerLogic.destroy(heat_marker)
    if (rendering.is_valid(heat_marker.gui_box_id) == true) then rendering.destroy(heat_marker.gui_box_id) end
    if (rendering.is_valid(heat_marker.gui_text_id) == true) then rendering.destroy(heat_marker.gui_text_id) end
end
