Gui = {
    root = nil, --- :LuaGuiElement @lateint
    toolbar = nil, --- :LuaGuiElement @lateint
    heat_group_container = nil, --- :LuaGuiElement @lateinit
    button_action_register = {} --- :Table<button_name : string, do_on_ress : function(event) -> Unit>
}

-- script.on_init(function()
--     log("gui init\r\n")
-- 	-- global.players = {}
-- 	-- ---@type State[]
-- 	-- global.tasks = {}
-- 	-- conf.initialize_deconstruction_filter()

-- 	for _, player in pairs(game.players) do
-- 		-- conf.initialize_global(player.index)
--         gui.create_interface(player)
-- 	end
-- end)
--- https://lua-api.factorio.com/latest/concepts.html#GuiElementType
function Gui.create_interface(player)
    ---@type LuaGuiElement
    -- local root_frame = player.gui.screen.add {
    Gui.root = player.gui.screen.add {
        type = "frame",
        name = "ahm__root__frame",
        direction = "vertical",
        caption = "atomic heat monitor",
        children = {}
    }
    Gui.heat_group_container = Gui.root.add {
        type = "scroll-pane",
        -- type = "table",
        -- column_count = "1",
        name = "ahm__heat_group_container__scroll-pane",
        direction = "vertical"
    }
    Gui.init_toolbar()
    -- HeatGroupDispetcher.addGroup(Gui.heat_group_container)
    -- HeatGroupDispetcher.addGroup(Gui.heat_group_container)
end

function Gui.init_toolbar()
    Gui.toolbar = Gui.root.add {
        type = "scroll-pane",
        name = "ahm__toolbar",
        direction = "horizontal"
    }
    local create_new_group_btn = Gui.toolbar.add {
        type = "sprite-button",
        name = "ahm__create_new_group_button",
        sprite = "heat_group_add_blueprint_icon",
        tooltip = "Создать группу" -- todo local text resource
    }
    Gui.button_action_register[create_new_group_btn.name] = Gui.set_selector_create_group
end

---------------------------
--- HeatGroupDispetcher ---
---------------------------
HeatGroupDispetcher = {
    player_and_heat_group_containers = {} -- :Table<player_index: number, HeatGroupList>
}
--- Обновляет Цифру температуры и Цвет фона для всех HeatGroup в группе.
function HeatGroupDispetcher:update_temperature_for_overlay(event)
    local player_heat_group_list = self.player_and_heat_group_containers[event.player_index]
    for _, heat_group in ipairs(player_heat_group_list.content) do heat_group.update_temperature_values() end
end
function HeatGroupDispetcher:add_group_for_player(player_index, group_entites) 
    
end

HeatGroupList = {
    content = {}, -- :HeatGroup[]
    next_elem_index = 1
}

function HeatGroupList.next_elem_index()
    local curr_group_index = HeatGroupList.next_elem_index
    HeatGroupList.next_elem_index = HeatGroupList.next_elem_index + 1
    return curr_group_index
end

function HeatGroupList.add_group(gui_groups_container)
    local curr_group_index = HeatGroupList.next_elem_index()

    local group = gui_groups_container.add {
        type = "frame",
        name = "ahm__heat_group_root_#" .. curr_group_index,
        direction = "vertical",
        caption = "Heat group " .. curr_group_index
    }
    group.add {
        type = "sprite-button",
        name = "ahm__heat_group_" .. curr_group_index .. "__add_blueprint",
        sprite = "heat_group_add_blueprint_icon",
        direction = "horizontal",
        tooltip = "Выбрать/Перезаписать сущности для группы"
    }
    -- todo - impl logic: connect GUI with service layer
end

--- Buttons:
--- - active/desible - active/desible heat group markers
--- - stop/start - stop/start recording into buffeer, then stop - write to file
--- - select entities(add/delete)
--- - new group content - replace existed heat-group content
--- - edit group name
--- - delete group
--- - - delete markers
--- - - delete event callback links
--- - show filer - show/hide entity category
--- - - reactor button
--- - - heat-exchanger button
--- - - pipe button
--- -
--- - TODO 
--- - on_entity_destoyed() + registry
--- - alt select
--- - 
--- - Edit heat group selector
--- - New heat group selector (shortcut & monitor button)
HeatGroup = {}

function HeatGroup:new(name)
    local obj = {
        classname = "HeatGroupDispetcher",
        content = {}, -- :Table<unit_number: string, HeatMarker>
        -- __entities = {}, -- :Table<unit_number: string, Entity>
        group_name = name
    }

    function obj:add_entity(entity)
        -- кейс в выборке есть Бойлеры и реакторы, но у них нет работы с теплом, как у Атомок
        if entity.valid == false or entity.temperature == nil then return end
        local temperature = HeatMarker.calc_temperature_for_entity(entity)
        self.content["" .. entity.unit_number] = HeatMarker:new(entity, temperature)
    end

    --- @param entities Entity[]
    function obj:add_entities(entities) for _, entity in pairs(entities) do self:add_entity(entity) end end

    function obj:remove_entity(entity)
        local entity_id = "" .. entity.unit_number
        local marker = self.content[entity_id]
        marker.destroy()
        self.content[entity_id] = nil -- garbage collector дальше сам справится

    end

    function obj:update_temperature_values()
        for unit_number, heat_marker in pairs(self.content) do
            -- local entity = self:__entities()[unit_number]
            heat_marker.update_temperature_overlay()
        end
    end

    return obj
end

--- todo - всё что ниже, вынести в отдельный файл heat_marker.lua

-------------------
--- HeatMarker ---
-------------------
HeatMarker = {}
local text_red, text_yellow, text_green = {1, 0, 0}, {1, 1, 0}, {0, 1, 0}
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
    target_offset = {.2, -.375},
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
    local text_id = HeatMarker.new_heat_box(entity, temperature)
    local box_id = HeatMarker.new_heat_box(entity, temperature)
    local obj = {
        --- Сущьности для которой мы рендерим Температуру
        lua_entity = entity,
        --- Показывать/Скрывать GUI todo - реализовать
        is_active = true,
        gui_text_id = text_id, -- :id от LuaGuiElement
        gui_box_id = box_id -- :id от LuaGuiElement
    }

    function obj:update_temperature_overlay()
        local temperature = HeatMarker.calc_temperature_for_entity(self.lua_entity)
        rendering.set_text(self.text_id, temperature)
        rendering.set_color(self.text_id, HeatMarker.approx_color_text(temperature))

        rendering.set_color(self.box_id, HeatMarker.approx_color_box(temperature))
    end

    function obj:update_is_active(bool)
        -- todo - impl 
    end

    function obj:destroy()
        rendering.set_time_to_live(self.text_id, 0)
        rendering.set_time_to_live(self.box_id, 0)
    end

    return obj
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

-----------------
--- GUI text ---
-----------------
function HeatMarker.approx_color_text(temperature)
    if temperature < 250 then
        return text_red
    elseif temperature < 500 then
        return text_yellow
    else
        return text_green
    end
end

--- todo а как указывается позиция для gui text???
function HeatMarker.new_heat_text(heat_entity, temperature)
    draw_params_text.color = HeatMarker.approx_color_text(temperature)
    draw_params_text.text = temperature
    return rendering.draw_text(draw_params_text)
end

----------------
--- GUI box ---
----------------
function HeatMarker.approx_color_box(temperature)
    if temperature < 500 then
        return HeatMarker.approx_color(box_blue, box_white, temperature / 500)
    else
        return HeatMarker.approx_color(box_red, box_white, (1000 - temperature) / 500)
    end
end

--- todo - test this
function HeatMarker.new_heat_box(heat_entity, temperature)
    draw_params_box.color = HeatMarker.approx_color_box(temperature)
    draw_params_box.left_top = heat_entity.selection_box.left_top
    draw_params_box.right_bottom = heat_entity.selection_box.right_bottom
    return "" .. rendering.draw_rectangle(draw_params_box)
end

--------------------
--- GUI trigger ---
--------------------
script.on_nth_tick(60, HeatGroupDispetcher.update_temperature_for_overlay -- function(e)
-- for _, player in pairs(game.connected_players) do
-- todo - impl
-- update_heat_enities_near_player(player) --- todo откоментить
-- update_heat_selector__heat_groups__entities(player)
-- end
-- end
)

-----------------------
--- Buttons actions ---
-----------------------

--- @type ItemStackIdentification
local selector__create_group = {
    name = 'monitor__selector__create_group'
}

function Gui.set_selector_create_group(gui_event)
    print("create_group - RUN")
    local player = game.players[gui_event.player_index]
    if player.clear_cursor() then -- ?  сброс выделенного предмата, если он есть
        local stack = player.cursor_stack
        if stack and stack.can_set_stack(selector__create_group) then stack.set_stack(selector__create_group) end
    end
end


function Gui.process_on_gui_click(gui_event)
    print("process_on_gui_click - RUN")
    local button_action = Gui.button_action_register[gui_event.name]
    if (~button_action) then error("err! button_action is not found for button '" .. gui_event.name .. "'!") end
    button_action() -- todo test
end

-- todo impl
-- https://lua-api.factorio.com/latest/events.html#on_gui_click
script.on_gui_click(Gui.process_on_gui_click)

-- https://lua-api.factorio.com/latest/events.html#on_player_selected_area
function Gui.on_player_selected_area(event, is_alt_select)
    if (event.name == "heat-monitor__selector__create_group") then
        if (~is_alt_select) then
        -- player -> dispetcher -> new group.apply {add entities}
        -- HeatGroupDispetcher.update_temperature_for_overlay
             player = game.players[event.player_index]
        else 

        end
    elseif (event.name == "heat-monitor__selector__edit_group") then
        if (~is_alt_select) then
            
        end
    end
end

-- https://lua-api.factorio.com/latest/events.html#on_player_selected_area
script.on_event(defines.events.on_player_selected_area, on_player_selected_area)
