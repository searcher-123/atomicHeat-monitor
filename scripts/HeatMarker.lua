require "scripts.HeatPalettes"


-------------------
--- HeatMarker ---
-------------------
HeatMarker = {}
local text_red, text_yellow, text_green = {1, 0, 0}, {1, 1, 0}, {0, 1, 0}
local transparent= {r=.3,g=.3,b=.3,a=.1}
local box_white = {
    r = 161 / 256,
    g = 161 / 256,
    b = 161 / 256,
    a = 0.1
}
local box_blue = {
    r = 0 / 256,
    g = 91 / 256,
    b = 196 / 256,
    a = 0.2
}
local box_red = {
    r = 168 / 256,
    g = 32 / 256,
    b = 44 / 256,
    a = 0.1
}
local draw_params_text = {
    target_offset = {0, -.375},
    forces = {},
    -- only_in_alt_mode = true,
    scale = 1.125,
    scale_with_zoom = false,
    alignment = "center",
    filled = true
}
local draw_params_box = {
    target_offset = {.2, -.375},
    forces = {},
    -- only_in_alt_mode = true,
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

function HeatMarker:new(entity, temperature)
    local box_id = HeatMarker.new_heat_box(entity, temperature)
    local text_id = HeatMarker.new_heat_text(entity, temperature)
    return {
        classname = "HeatMarker",
        --- Сущьности для которой мы рендерим Температуру
        lua_entity = entity,
        --- Показывать/Скрывать GUI todo - реализовать
        -- is_active = true,
        gui_box_id = box_id, -- :id от LuaGuiElement
        gui_text_id = text_id -- :id от LuaGuiElement
    }
    -- return obj
end


----------------------------------
--- prvate API fro HeatMarker ---
----------------------------------

function HeatMarker.calc_temperature_for_entity(entity) return math.floor(entity.temperature) end

function HeatMarker.approx_color(colorTo, colorFrom, weight)
    return {
        r = colorFrom.r * weight + colorTo.r * (1 - weight),
        g = colorFrom.g * weight + colorTo.g * (1 - weight),
        b = colorFrom.b * weight + colorTo.b * (1 - weight),
        a = colorFrom.a * weight + colorTo.a * (1 - weight)
    }
end



-------------------------
--- approx_color4_255 ---
-------------------------

function HeatMarker.approx_color4_255(color1, color2, weight)
    r = color1.r * weight + color2.r * (1 - weight)
    g = color1.g * weight + color2.g * (1 - weight)
    b = color1.b * weight + color2.b * (1 - weight)
    a = color1.a * weight + color2.a * (1 - weight)
	  return {r=r/255, g=g/255, b=b/255, a=a/255}
end

function HeatMarker.calc_color_from_palette_and_temperature (heat_palette_ranges,temperature)
	calc_color = {r=0,g=0,b=0,a=0}
	start_temp=0
	end_temp=1000
	target_range=heat_palette_ranges[1]
	for _,range_color in pairs (heat_palette_ranges) do
		if temperature<=range_color.range then
			end_temp=range_color.range
			target_range=range_color
			break
		else
			start_temp=range_color.range
		end
	end
	calc_color = HeatMarker.approx_color4_255(target_range.high,target_range.low , (temperature-start_temp)/(end_temp-start_temp) )
	return {calc_color.r,calc_color.g,calc_color.b,calc_color.a}
end

function HeatMarker.color_4_to_3(color_in)
	return {r=color_in[1],g=color_in[2],b=color_in[3]}
end


-----------------
--- GUI text ---
-----------------
function HeatMarker.approx_color_text(temperature)
   if heat_palette.b_need_numbers==true then
     color4=HeatMarker.calc_color_from_palette_and_temperature(heat_palette.ranges_numbers,temperature)
	 color3 =HeatMarker.color_4_to_3(color4)
   else
      color3 = transparent
   end
   return color3

--    if temperature < 250 then
  --      return text_red
   -- elseif temperature < 500 then
    --    return text_yellow
    --else
    --    return text_green
    --end
end

function HeatMarker.new_heat_text(heat_entity, temperature)
    draw_params_text.color = HeatMarker.approx_color_text(temperature)
    draw_params_text.text = temperature
    draw_params_text.surface = heat_entity.surface
    draw_params_text.target = heat_entity -- это важно, для обновления rendering_object.id после sale-load
    draw_params_text.forces[1] = heat_entity.force
    return rendering.draw_text(draw_params_text)
end

----------------
--- GUI box ---
----------------
function HeatMarker.approx_color_box(temperature)
--    if temperature < 500 then
--        return HeatMarker.approx_color(box_blue, box_white, temperature / 500)
--    else
--        return HeatMarker.approx_color(box_red, box_white, (1000 - temperature) / 500)
--    end
   if heat_palette.b_need_rects==true then
	   color =HeatMarker.calc_color_from_palette_and_temperature(heat_palette.ranges_rects,temperature)
   else
	color =transparent
   end
   return color
end

function HeatMarker.new_heat_box(heat_entity, temperature)
    draw_params_box.color = HeatMarker.approx_color_box(temperature)
    draw_params_box.left_top = heat_entity.selection_box.left_top
    draw_params_box.right_bottom = heat_entity.selection_box.right_bottom
    draw_params_box.surface = heat_entity.surface
    draw_params_box.target = heat_entity -- это важно, для обновления rendering_object.id после sale-load
    draw_params_box.forces[1] = heat_entity.force
    return rendering.draw_rectangle(draw_params_box)
end


HeatMarkerLogic = {}
 function HeatMarkerLogic.update_temperature_overlay(heat_marker)
        --- todo : временно! Если id не валидный, то пусть не работает корректно!
        if (rendering.is_valid(heat_marker.gui_box_id) == false or rendering.is_valid(heat_marker.gui_text_id) == false) then
            return
        end

        local temperature = HeatMarker.calc_temperature_for_entity(heat_marker.lua_entity)

        rendering.set_color(heat_marker.gui_box_id, HeatMarker.approx_color_box(temperature))

        rendering.set_text(heat_marker.gui_text_id, temperature)
        rendering.set_color(heat_marker.gui_text_id, HeatMarker.approx_color_text(temperature))
    end

    -- function HeatMarkerLogic.update_is_active(heat_marker, bool)
    --     -- TODO: - impl 
    --     -- todo: - 
    -- end

    function HeatMarkerLogic.destroy(heat_marker)
        rendering.destroy(heat_marker.gui_box_id)
        rendering.destroy(heat_marker.gui_text_id)
    end