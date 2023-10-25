Stats = require("heat_palettes")

function set_palette ()
--uncomment one of next lines to change palette style
--bambino()
--baggins()
FaXiR()
--palette_just_rects()
--palette_just_green_digits()
end


local heat_selector = require("heat_selector").heat_selector
-- local selector_func = require("heat_selector").selector

local red, yellow, green = {1, 0, 0}, {1, 1, 0}, {0, 1, 0}

local awhite = {
    r = 161 / 256,
    g = 161 / 256,
    b = 161 / 256,
    a = 0.1
}
local ablue = {
    r = 0 / 256,
    g = 91 / 256,
    b = 196 / 256,
    a = 0.2
}
local ared = {
    r = 168 / 256,
    g = 32 / 256,
    b = 44 / 256,
    a = 0.1
}

local arr_ent = {}
arr_ent.arr_text = {}
arr_ent.arr_box = {}

local marker_time_to_live = 61 -- кол-во тиков
local radius_to_search_heat_from_player = 50 -- кол-во клеток от игрока

local draw_params = {
    time_to_live = 61,
    target_offset = {.2, -.375},
    forces = {},
    only_in_alt_mode = true,
    scale = 1.125,
    scale_with_zoom = false,
    alignment = "center",
    filled = true
}

-- draw_rectangle{color=…, width?=…, filled=…, left_top=…, left_top_offset?=…, right_bottom=…, right_bottom_offset?=…, surface=…, time_to_live?=…, forces?=…, players?=…, visible?=…, draw_on_ground?=…, only_in_alt_mode?=…} 
local draw_params_rect = {
    time_to_live = 61,
    target_offset = {.2, -.375},
    forces = {},
    only_in_alt_mode = true,
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

function approx_color4(color1, color2, weight)
    r = color1.r * weight + color2.r * (1 - weight)
    g = color1.g * weight + color2.g * (1 - weight)
    b = color1.b * weight + color2.b * (1 - weight)
    a = color1.a * weight + color2.a * (1 - weight)
  
    return {r, g, b, a}
end

function approx_color4_255(color1, color2, weight)	
    r = color1.r * weight + color2.r * (1 - weight)
    g = color1.g * weight + color2.g * (1 - weight)
    b = color1.b * weight + color2.b * (1 - weight)
    a = color1.a * weight + color2.a * (1 - weight)	
	  return {r/255, g/255, b/255, a/255}
end

function color_4_to_3(color_in)
	return {color_in[1],color_in[2],color_in[3]}
end

function log_file(text_to_Log) game.write_file("atomicHeat-monitor.txt", text_to_Log .. "\r\n", true) end

function draw_heat_amount_for_entity(heat_entity)
    if heat_entity.valid == false then return end
    local temperature = math.floor(heat_entity.temperature)

    draw_params.target = heat_entity
    draw_params.surface = heat_entity.surface
    draw_params.forces[1] = heat_entity.force
    draw_params.color = green

    draw_params_rect.surface = heat_entity.surface	
    update_heat_rect(heat_entity, temperature)
    update_heat_text(heat_entity, temperature)

end

function calc_color_from_palette_and_temperature (heat_palette_ranges,temperature)

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
	
	calc_color = approx_color4_255(target_range.high,target_range.low , (temperature-start_temp)/(end_temp-start_temp) )
	return calc_color
end

function update_heat_rect(heat_entity, temperature)
	if heat_palette.b_need_rects==false then  return end
	--защита от неудачного расчёта температуры
	draw_params_rect.color = {r=0,g=0,b=0,a=0}
	start_temp=0
	end_temp=1000
	
	draw_params_rect.color =calc_color_from_palette_and_temperature(heat_palette.ranges_rects,temperature)
	--target_range=heat_palette.ranges_rects[1]
	-- for _,range_color in pairs (heat_palette.ranges_rects) do		
		-- if temperature< range_color.range then 
			-- end_temp=range_color.range
			-- target_range=range_color			
			-- break 
		-- else
			-- start_temp=range_color.range
		-- end
	-- end
	-- draw_params_rect.color = approx_color4_255(target_range.high,target_range.low , (temperature-start_temp)/(end_temp-start_temp) )
    --if temperature < 500 then
    --    draw_params_rect.color = approx_color4(awhite, ablue, temperature / 500)
    --else
    --   draw_params_rect.color = approx_color4(awhite, ared, (1000 - temperature) / 500)
    --end

    if arr_ent.arr_box["" .. heat_entity.unit_number] == nil then
        draw_params_rect.left_top = heat_entity.selection_box.left_top
        draw_params_rect.right_bottom = heat_entity.selection_box.right_bottom
        arr_ent.arr_box["" .. heat_entity.unit_number] = rendering.draw_rectangle(draw_params_rect)        
    else
        id = arr_ent.arr_box["" .. heat_entity.unit_number]
        if rendering.is_valid(id) then
            rendering.set_color(id, draw_params_rect.color)
            rendering.set_time_to_live(id, marker_time_to_live)
        else
            arr_ent.arr_box["" .. heat_entity.unit_number] = nil
        end
    end
end

function update_heat_text(heat_entity, temperature)
	if heat_palette.b_need_numbers==false then return end 
	start_temp=0
	end_temp=1000
	
	 draw_params.color =color_4_to_3(calc_color_from_palette_and_temperature(heat_palette.ranges_numbers,temperature))	
	      -- if temperature < 250 then
         -- draw_params.color = red
     -- elseif temperature < 500 then
        -- draw_params.color = yellow
     -- else
        -- draw_params.color = green
     -- end
	

    if arr_ent.arr_text["" .. heat_entity.unit_number] == nil then
        draw_params.text = temperature
        arr_ent.arr_text["" .. heat_entity.unit_number] = rendering.draw_text(draw_params)      
    else
        id = arr_ent.arr_text["" .. heat_entity.unit_number]
        if rendering.is_valid(id) then
            rendering.set_text(id, temperature)
            rendering.set_color(id, draw_params.color)
            rendering.set_time_to_live(id, marker_time_to_live)
        else
            arr_ent.arr_text["" .. heat_entity.unit_number] = nil
        end
    end
end

function find_heat_entity_near_player(player)
    return player.surface.find_entities_filtered {
        type = {"reactor", "boiler", "heat-pipe"},
        position = player.position,
        radius = radius_to_search_heat_from_player,
        force = player.force
    }
end

script.on_nth_tick(60, function(e)
	set_palette ()--костыль .перенести в однократный пуск
    for _, player in pairs(game.connected_players) do
        -- update_heat_enities_near_player(player) --- todo откоментить
        update_heat_selector__heat_groups__entities(player)
    end
	--heat_palette_export()
end)

function update_heat_enities_near_player(player)
    i = 0
    for _, heat_entity in pairs(find_heat_entity_near_player(player)) do
        --log(heat_entity.temperature .. " i=" .. i .. " " .. heat_entity.name .. " id=" .. heat_entity.unit_number ..                 "\r\n")
        draw_heat_amount_for_entity(heat_entity)
        i = i + 1
    end
    --log("box =" .. count_table_elements(arr_ent.arr_box) .. "\r\n")
    --log("text=" .. count_table_elements(arr_ent.arr_text) .. "\r\n")

    -- l=1

    -- for i, p in pairs(arr_ent.arr_box) do
    --		log ("arr box id "..l.."->"..p)
    -- l=l+1
    -- end
end

function update_heat_selector__heat_groups__entities(player)
    heat_groups = heat_selector.players_heat_groups[player.index]
    -- если у Игрока ещё нет выделенных групп, то и обрабатывать ничего не нужно
    if heat_groups == nil then return end
    for _, heat_group in pairs(heat_groups) do
        for _, heat_entity in pairs(heat_group.entities) do 
            draw_heat_amount_for_entity(heat_entity) 
        end
    end
    -- for heat_entity in heat_group_entities do draw_heat_amount_for_entity(heat_entity) end
    -- for heat_entity in heat_selector[player.index].entities do draw_heat_amount_for_entity(heat_entity) end

end

-- debug
function count_table_elements(table)
    size = 0
    for _, p in pairs(table) do size = size + 1 end
    return size
end

