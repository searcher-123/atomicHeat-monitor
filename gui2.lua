--- todo "atomic heat monitor" close button https://forums.factorio.com/viewtopic.php?t=98713
---------------------------
--- HeatGroupDispatcher ---
---------------------------
--- Глобальный объект.
--- Слушает все Gui events и отвечает за распределение event.player_index -> player.gui.
--- Всё что находится (абстрактно) глубже, в теории не должно знать что есть другие игроки.
PlayerGuiDispatcher = {
    classname = "PlayerGuiDispatcher",
    player_and_heat_group_list__array = {}, -- :Table<player_index: number, HeatGroupList>
    player_and_gui_array = {} -- :Table<player_index: number, PlayerGui>
}

---------------
--- Getters ---
---------------

function PlayerGuiDispatcher:get_or_create_heat_group_list(player_index)
    local heat_group_list = self.player_and_heat_group_list__array[player_index]
    if (heat_group_list == nil) then
        heat_group_list = HeatGroupList:new()
        self.player_and_heat_group_list__array[player_index] = heat_group_list
    end
    return heat_group_list
end
function PlayerGuiDispatcher:get_or_create_Gui(player_index)
    local player_gui = self.player_and_gui_array[player_index]
    if (player_gui == nil) then
        player_gui = PlayerGui:new(game.players[player_index])
        self.player_and_gui_array[player_index] = player_gui
    end
    return player_gui
end

---------------------
--- Event process ---
---------------------

function PlayerGuiDispatcher:on_init_event()
    for _, player in pairs(game.players) do
        table.insert(self.player_and_heat_group_list__array, HeatGroupList:new())
        table.insert(self.player_and_gui_array, PlayerGui:new(player))
    end
end


-- https://lua-api.factorio.com/latest/events.html#on_player_selected_area
function PlayerGuiDispatcher:on_player_selected_area(event, is_alt_select)
    local player_index = event.player_index
    local group_entities = event.entities
    local player_gui = self:get_or_create_Gui(player_index)
    local heat_group_list = self:get_or_create_heat_group_list(player_index)

    if (event.item == "heat-monitor__selector__create_group") then
        if (is_alt_select == false) then
            self:add_group_for_player(player_index, group_entities)
        else

        end
    elseif (event.item == "heat-monitor__selector__edit_group") then
        if (is_alt_select == false) then end
    end
end

function PlayerGuiDispatcher:on_nth_tick_update_temperature(arg)
    for player_index, player_heat_groups in pairs(PlayerGuiDispatcher.player_and_heat_group_list__array) do
        for _, heat_group in ipairs(player_heat_groups.content) do heat_group:update_temperature_values() end
    end
end

--- Точка входа для обработки нажатия Любой Кнопки(GuiElement{type="button"})
function PlayerGuiDispatcher:process_on_gui_click(gui_event)
    local btn_name = gui_event.element.name
    print("process_on_gui_click - RUN")
    -- скипаем нажатия на Чужие кнопки, все наши кнопки начинаются на "ahm"
    if (string.sub(btn_name, 1, 3) ~= "ahm") then return end
    local player_gui = self:get_or_create_Gui(gui_event.player_index)
    local player_groups = self:get_or_create_heat_group_list(gui_event.player_index)

    if string.find(btn_name, "->create_group") then
        player_gui:set_selector_create_group(gui_event)
    elseif string.find(btn_name, "->edit_content") then
    elseif string.find(btn_name, "->delete_group") then
        -- важен порядок действий - сначала логика, и в конце gui
        player_groups:delete_heat_group(gui_event.element.tags.group_name)
        player_gui:process_delete_group(gui_event)
    end
end


local hotkey_event__create_group = "ahm_pressed-create_group_hotkey"

function PlayerGuiDispatcher.on_hotkey_pressed__create_group(event)
    PlayerGuiDispatcher:set_selector_tool(event.player_index)
end

local selector__shortcut = "heat-monitor__shortcut"
-- ссылка на функцию передаётся в как callback в движок и там, нет возможности передать 
-- self первым аргументов, первый аргумент всегда event
-- поэтому без сахара в виде self
function PlayerGuiDispatcher.on_lua_shortcut(event)
    local self = PlayerGuiDispatcher
    if event.prototype_name ~= selector__shortcut then return end

    self:set_selector_tool(event.player_index)
end

--------------------
--- Bussines API ---
--------------------

function PlayerGuiDispatcher:add_group_for_player(player_index, group_entites)
    local player_gui = self:get_or_create_Gui(player_index)
    local heat_group_list = self:get_or_create_heat_group_list(player_index)

    local new_heat_group = heat_group_list:create_heat_group(group_entites)
    player_gui:create_gui_for_heat_group(new_heat_group)
end

function PlayerGuiDispatcher:set_selector_tool(player_index)
     local player_gui = self.player_and_gui_array[player_index]
    -- делаем вид, что передаём gui_event. Мимикрируем под gui_event XD
    player_gui:set_selector_create_group({
        player_index = player_index
    })
end

------------------------
--- @file: PlayerGui ---
------------------------

--- Класс отвечает за Создание, Настройку, Изменение, Действия кнопок GUI для Определённого юзера.
PlayerGui = {}
--- @param player LuaPlayer 
function PlayerGui:new(player)
    local obj = {
        classname = "PlayerGui",
        player = player, --- @type LuaPlayer
        root = nil, --- @type LuaGuiElement @lateint
        toolbar = nil, --- @type LuaGuiElement @lateint
        heat_group_container = nil, --- @type LuaGuiElement @lateinit
        --- таблица с Именеим Кнопки + ссылка на функцию, что должна отработать при её нажатии.
        button_action_register = {} --- :Table<button_name : string, do_on_ress : function(event) -> Unit>
    }

    --- @param player LuaPlayer 
    function obj:init_interface(player)
        self.root = player.gui.screen.add {
            type = "frame",
            name = "ahm__root__frame",
            direction = "vertical",
            caption = "atomic heat monitor",
            children = {}
        }
        self.heat_group_container = self.root.add {
            type = "scroll-pane",
            -- type = "table",
            -- column_count = "1",
            name = "ahm__heat_group_container__scroll-pane",
            direction = "vertical"
        }
    end

    function obj:init_toolbar()
        self.toolbar = self.root.add {
            type = "scroll-pane",
            name = "ahm__toolbar",
            direction = "horizontal"
        }
        local create_new_group_btn = self.toolbar.add {
            type = "sprite-button",
            name = "ahm__toolbar__->create_group",
            sprite = "heat_group_add_blueprint_icon",
            tooltip = "Создать группу" -- todo local text resource
        }
    end

    function obj:create_gui_for_heat_group(heat_group)
        local group = self.heat_group_container.add {
            type = "frame",
            name = "ahm__heat_group_root_#" .. heat_group.group_name,
            direction = "horizontal",
            caption = heat_group.group_name
        }
        group.add {
            type = "sprite-button",
            name = "ahm__heat_group_root_#" .. heat_group.group_name .. "__->edit_content",
            sprite = "heat_group_add_blueprint_icon",
            tooltip = "Выбрать/Перезаписать сущности для группы (Comming soon! :D)" -- todo local text resource
        }
        -- todo - impl logic: connect GUI with service layer
        local delete_group_btn = group.add {
            type = "sprite-button",
            name = "ahm__heat_group_root_#" .. heat_group.group_name .. "__->delete_group",
            sprite = "heat_group_delete_icon",
            tooltip = "Удалить группу", -- todo local text resource
            tags = {
                group_name = heat_group.group_name
            }
        }
    end



    -----------------------
    --- Buttons actions ---
    -----------------------

    --- @type ItemStackIdentification
    local selector__create_group = {
        name = 'heat-monitor__selector__create_group'
    }

    function obj:set_selector_create_group(gui_event)
        print("create_group - RUN")
        local event_player = game.players[gui_event.player_index]
        if event_player.clear_cursor() then -- ?  сброс выделенного предмата, если он есть
            local stack = event_player.cursor_stack
            if stack and stack.can_set_stack(selector__create_group) then
                stack.set_stack(selector__create_group)
            end
        end
    end

    function obj:process_delete_group(gui_event)
        print("create_group - RUN")
        local player_index = gui_event.player_index
        local heat_group_name = gui_event.element.tags.group_name

        -- удалить gui -- уничтожить gui_element + все его дочерние элементы
        for _, gui_heat_group_root in ipairs(self.heat_group_container.children) do
            if (string.find(gui_heat_group_root.name, heat_group_name)) then gui_heat_group_root.destroy() end
        end
    end

    -- config self
    obj:init_interface(player)
    obj:init_toolbar()
    return obj
end

--- @class HeatGroupList
HeatGroupList = {}
function HeatGroupList:new()
    local obj = {
        classname = "HeatGroupList",
        content = {}, --- @type Table <heat_group_name : string, HeatGroup>
        _next_elem_index = 1
    }

    function obj:next_elem_index()
        local curr_group_index = self._next_elem_index
        self._next_elem_index = curr_group_index + 1
        return curr_group_index
    end

    function obj:create_heat_group(group_entites)
        local curr_group_index = self:next_elem_index()
        local heat_group_name = "Heat group " .. curr_group_index
        local rsl = HeatGroup:new(heat_group_name, group_entites)
        self.content[heat_group_name] = rsl
        return rsl
    end

    function obj:delete_heat_group(group_name)
        local heat_group = self.content[group_name]
        if (heat_group == nil) then
            log("WARM! delete_heat_group(\"" .. group_name .. "\") -> nil   - Do nothing!")
            return
        end
        for _, heat_marker in pairs(heat_group.content) do
            log("marker_guit_text" .. heat_marker.gui_text_id)
            heat_marker:destroy()
        end
    end

    return obj
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
--- @param name string Индификатор группы + имя группы для GUI
--- @param group_entites Entity[] набор игровых сущьностей для которых группы будет показывать температуру.
function HeatGroup:new(name, group_entites)
    local obj = {
        classname = "HeatGroupDispetcher",
        content = {}, -- :Table<unit_number: string, HeatMarker>
        -- __entities = {}, -- :Table<unit_number: string, Entity>
        group_name = name
    }

    --- @param entity Entity
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
            heat_marker:update_temperature_overlay()
        end
    end

    -- obj config
    obj:add_entities(group_entites)

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
    local obj = {
        classname = "HeatMarker",
        --- Сущьности для которой мы рендерим Температуру
        lua_entity = entity,
        --- Показывать/Скрывать GUI todo - реализовать
        is_active = true,
        gui_box_id = box_id, -- :id от LuaGuiElement
        gui_text_id = text_id -- :id от LuaGuiElement
    }

    function obj:update_temperature_overlay()
        local temperature = HeatMarker.calc_temperature_for_entity(self.lua_entity)

        rendering.set_color(self.gui_box_id, HeatMarker.approx_color_box(temperature))

        rendering.set_text(self.gui_text_id, temperature)
        rendering.set_color(self.gui_text_id, HeatMarker.approx_color_text(temperature))
    end

    function obj:update_is_active(bool)
        -- todo - impl 
    end

    function obj:destroy()
        rendering.destroy(self.gui_box_id)
        rendering.destroy(self.gui_text_id)
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
    draw_params_text.surface = heat_entity.surface
    draw_params_text.target = heat_entity
    draw_params_text.forces[1] = heat_entity.force
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
    draw_params_box.surface = heat_entity.surface
    draw_params_box.forces[1] = heat_entity.force
    return "" .. rendering.draw_rectangle(draw_params_box)
end

--------------------
--- GUI trigger ---
--------------------
-- https://lua-api.factorio.com/latest/events.html#on_gui_click
script.on_event(defines.events.on_gui_click, function(event) PlayerGuiDispatcher:process_on_gui_click(event) end)

script.on_event(defines.events.on_player_selected_area,
                function(event) PlayerGuiDispatcher:on_player_selected_area(event, false) end)
script.on_event(defines.events.on_player_alt_selected_area,
                function(event) PlayerGuiDispatcher:on_player_selected_area(event, true) end)

script.on_nth_tick(60, PlayerGuiDispatcher.on_nth_tick_update_temperature)
script.on_init(function()
    log("init gui2 \r\n")

    -- for _, player in pairs(game.players) do
    --     gui.create_interface(player)
    --     -- gui.create_buttons(player)
    -- end
    PlayerGuiDispatcher:on_init_event() -- todo import gui2

end)

script.on_event(defines.events.on_lua_shortcut, PlayerGuiDispatcher.on_lua_shortcut)
script.on_event(hotkey_event__create_group, PlayerGuiDispatcher.on_hotkey_pressed__create_group)
