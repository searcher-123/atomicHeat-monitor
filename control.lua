local red, yellow, green = {1, 0, 0}, {1, 1, 0}, {0, 1, 0}

local awhite={r=161/256,g=161/256,b=161/256,a=0.1}
local ablue={r=0/256,g=91/256,b=196/256,a=0.2}
local ared={r=168/256,g=32/256,b=44/256,a=0.1}

local drawparams = {
    time_to_live = 61,
    target_offset = {.2, -.375},
    forces = {},
    only_in_alt_mode = true,
    scale = 1.125,
    scale_with_zoom = false,
    alignment = "center",
	filled=true
}

local arr_ent={}
arr_ent.arr_text={}
arr_ent.arr_box={}

--draw_rectangle{color=…, width?=…, filled=…, left_top=…, left_top_offset?=…, right_bottom=…, right_bottom_offset?=…, surface=…, time_to_live?=…, forces?=…, players?=…, visible?=…, draw_on_ground?=…, only_in_alt_mode?=…} 
local drawparams_rect = {
    time_to_live = 61,
    target_offset = {.2, -.375},
    forces = {},
    only_in_alt_mode = true,
    scale = 1.125,
    scale_with_zoom = true,
    alignment = "center",
	filled=true,
	left_top={x=0,y=0},
	right_bottom={x=0,y=0}
}

function approx_color4 (color1,color2,weight)
	r=color1.r*weight+color2.r*(1-weight)
	g=color1.g*weight+color2.g*(1-weight)
	b=color1.b*weight+color2.b*(1-weight)
	a=color1.a*weight+color2.a*(1-weight)
	log("color4 ")
	log("color1 ".."."..color1.r..","..color1.g..","..color1.b..","..a)
	log("color2 ".."."..color2.r..","..color2.g..","..color2.b..","..a)
	log("color and num "..weight..", "..r..", "..g..", "..b..", "..a)
	return {r,g	,b,a}
end



function log_file(text_to_Log)
game.write_file("pomogatel_temperature.txt",text_to_Log.."\r\n",true)
end

local function draw_heat_amount_for_entity(t)
    local num = math.floor(t.temperature)
    drawparams.target = t
    drawparams.surface = t.surface
    drawparams.forces[1] = t.force
    drawparams.color = green
	drawparams_rect.surface = t.surface
	color={r=0,g=0,b=0,a=0}
    --	limit = 
    if num < 250 then
        drawparams.color = red
    elseif num < 500 then
        drawparams.color = yellow
    else
        drawparams.color = green
    end
	if num <500 then
		drawparams_rect.color=approx_color4(awhite,ablue,num/500)
		color=approx_color4(awhite,ablue,num/500)		
	else
		drawparams_rect.color=approx_color4(awhite,ared,(1000-num)/500)
		color=approx_color4(awhite,ared,(1000-num)/500)
		
	end
	if color~=nil then
		if arr_ent.arr_box[t.unit_number]==nil  then			
			drawparams_rect.left_top=t.selection_box.left_top
			drawparams_rect.right_bottom=t.selection_box.right_bottom
			arr_ent.arr_box[t.unit_number]=rendering.draw_rectangle(drawparams_rect)
			log("new rect")
		else
			id=arr_ent.arr_box[t.unit_number]
			if rendering.is_valid (id) then 			
				rendering.set_color(id,color)			
				rendering.set_time_to_live(id, 61)
			else
				arr_ent.arr_box[t.unit_number]=nil
			end
		end
		if arr_ent.arr_text[t.unit_number]==nil then
			drawparams.text = num	    
			arr_ent.arr_text[t.unit_number]=rendering.draw_text(drawparams)
			log("new text")
		else
			id=arr_ent.arr_text[t.unit_number]
			if rendering.is_valid (id) then 			
				rendering.set_text(id,num)
				rendering.set_color(id,drawparams.color)
				rendering.set_time_to_live(id, 61)
			else
				arr_ent.arr_text[t.unit_number]=nil
			end
		end
	
		---rendering.draw_rectangle(drawparams_rect)
		--rendering.draw_text(drawparams)
	end
end



local function find(type)
    p = game.connected_players[1]
    return p.surface.find_entities_filtered {
        type = {"reactor", "boiler", "heat-pipe"},
		--type = {"boiler"},
        position = p.position,
        radius = 25,
        force = p.force
    }
end

script.on_nth_tick(60, function(e)
    local turrets = {}
	i=0
    for _, p in pairs(game.connected_players) do
        for _, heatable in pairs(find("fluid-product-prototype")) do
            log(heatable.temperature.." i="..i.." "..heatable.name.." id="..heatable.unit_number)
            draw_heat_amount_for_entity(heatable)
			i=i+1
        end
    end
	l=1
	--for i, p in pairs(arr_ent.arr_box) do
--		log ("arr box id "..l.."->"..p)
		--l=l+1
	--end
end)

