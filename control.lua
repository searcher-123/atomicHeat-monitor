local heat_selector = require("heat_selector").heat_selector
-- local gui = require("gui")
local gui = require("gui2")

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

function approx_color(color1, color2, weight)
    r = color1.r * weight + color2.r * (1 - weight)
    g = color1.g * weight + color2.g * (1 - weight)
    b = color1.b * weight + color2.b * (1 - weight)
    a = color1.a * weight + color2.a * (1 - weight)
    -- log("color4 ")
    -- log("color1 " .. "." .. color1.r .. "," .. color1.g .. "," .. color1.b ..
    -- "," .. a)
    -- log("color2 " .. "." .. color2.r .. "," .. color2.g .. "," .. color2.b ..
    -- "," .. a)
    -- log("color and num " .. weight .. ", " .. r .. ", " .. g .. ", " .. b ..
    -- ", " .. a)
    return {r, g, b, a}
end

function log_file(text_to_Log) game.write_file("atomicHeat-monitor.txt", text_to_Log .. "\r\n", true) end

function draw_heat_amount_for_entity(heat_entity)
    if heat_entity.valid == false or heat_entity.temperature == nil -- кейс в выборке есть Бойлеры и реакторы, но у них нет работы с теплом, как у Атомок
    then return end
    local temperature = math.floor(heat_entity.temperature)

    draw_params.target = heat_entity
    draw_params.surface = heat_entity.surface
    draw_params.forces[1] = heat_entity.force
    draw_params.color = green

    draw_params_rect.surface = heat_entity.surface

    new_heat_box(heat_entity, temperature)
    update_heat_text(heat_entity, temperature)

end

function new_heat_box(heat_entity, temperature)
    if temperature < 500 then
        draw_params_rect.color = approx_color(awhite, ablue, temperature / 500)
    else
        draw_params_rect.color = approx_color(awhite, ared, (1000 - temperature) / 500)
    end

    if arr_ent.arr_box["" .. heat_entity.unit_number] == nil then
        draw_params_rect.left_top = heat_entity.selection_box.left_top
        draw_params_rect.right_bottom = heat_entity.selection_box.right_bottom
        arr_ent.arr_box["" .. heat_entity.unit_number] = rendering.draw_rectangle(draw_params_rect)
        log("new rect")
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
    if temperature < 250 then
        draw_params.color = red
    elseif temperature < 500 then
        draw_params.color = yellow
    else
        draw_params.color = green
    end

    if arr_ent.arr_text["" .. heat_entity.unit_number] == nil then
        draw_params.text = temperature
        arr_ent.arr_text["" .. heat_entity.unit_number] = rendering.draw_text(draw_params)
        log("new text")
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
    for _, player in pairs(game.connected_players) do
        -- update_heat_enities_near_player(player) --- todo откоментить
        update_heat_selector__heat_groups__entities(player)
    end
end)

function update_heat_enities_near_player(player)
    i = 0
    for _, heat_entity in pairs(find_heat_entity_near_player(player)) do
        log(heat_entity.temperature .. " i=" .. i .. " " .. heat_entity.name .. " id=" .. heat_entity.unit_number ..
                "\r\n")
        draw_heat_amount_for_entity(heat_entity)
        i = i + 1
    end
    log("box =" .. count_table_elements(arr_ent.arr_box) .. "\r\n")
    log("text=" .. count_table_elements(arr_ent.arr_text) .. "\r\n")

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
        for _, heat_entity in pairs(heat_group.entities) do draw_heat_amount_for_entity(heat_entity) end
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


-- script.on_configuration_changed(function()
    
--     for _, player in pairs(game.players) do
--         -- conf.initialize_global(player.index)
--         -- gui.create_interface(player)
--         gui.create_buttons(player)
--     end
--     log("on_configuration_changed\r\n")
-- end)

script.on_init(function()
    print("init control ")

    -- for _, player in pairs(game.players) do
    --     gui.create_interface(player)
    --     -- gui.create_buttons(player)
    -- end
    PlayerGuiDispatcher:on_init_event() -- todo import gui2
    
end)
-- script.on_load(function()
    -- log("control gui init\r\n")
    -- global.players = {}
    -- ---@type State[]
    -- global.tasks = {}
    -- conf.initialize_deconstruction_filter()

    -- for _, player in pairs(game.players) do
        -- conf.initialize_global(player.index)
        -- gui.create_interface(player)
        -- gui.create_buttons(player)
    -- end
-- end)

function gui.create_buttons(player)
    local root = player.gui.top.pomogatel_temperature_root
    if root then root.destroy() end

    --    if not root or destroyed then
    root = player.gui.top.add {
        type = "frame",
        name = "pomogatel_temperature_root",
        direction = "horizontal"
        -- direction = "vertical"
        -- ,		column_count=2
    }

    local action_buttons = root.add {
        type = "flow",
        name = "pomogatel_temperature_action_buttons",
        direction = "vertical"
    }
    action_buttons.add {
        type = "button",
        name = "pomogatel_temperature_start_button",
        caption = "start"
    }
    action_buttons.add {
        type = "button",
        name = "pomogatel_temperature_stop_button",
        caption = "stop"
    }
    action_buttons.add {
        type = "button",
        name = "pomogatel_temperature_init",
        caption = "init"
    }

    --    end
end
