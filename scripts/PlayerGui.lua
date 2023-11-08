--- Класс отвечает за Создание, Настройку, Изменение, Действия кнопок GUI для Одного Определённого юзера.
PlayerGui = {}
--- @param player LuaPlayer 
function PlayerGui:new(player)
    local obj = {
        classname = "PlayerGui",
        player = player, --- @type LuaPlayer
        root = nil, --- @type LuaGuiElement @lateint
        toolbar = nil, --- @type LuaGuiElement @lateint
        heat_group_container = nil --- @type LuaGuiElement @lateinit
        --- таблица с Именеим Кнопки + ссылка на функцию, что должна отработать при её нажатии.
        -- button_action_register = {} --- :Table<button_name : string, do_on_ress : function(event) -> Unit>
    }

    function obj:add_main_menu_to_scene()
        self.root = self.player.gui.screen.add {
            type = "frame",
            name = "ahm__root__frame",
            direction = "vertical",
            caption = "atomic heat monitor",
            children = {}
        }
        self.heat_group_container = self.root.add {
            type = "scroll-pane",
            name = "ahm__heat_group_container__scroll-pane",
            direction = "vertical"
        }
    end

    function obj:add_toolbar_to_main_menu()
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

    -- config self
    obj:add_main_menu_to_scene()
    obj:add_toolbar_to_main_menu()
    return obj
end

--- методы для PlayerGui
PlayerGuiLogic = {}

function PlayerGuiLogic.destrpy_gui_v_0_0_2()
    log("PlayerGuiLogic.destrpy_gui_v_0_0_2() - RUN\r\n")
    for _, player in pairs(game.players) do player.gui.screen["ahm__root__frame"].destroy() end
end
-----------------------
--- Buttons actions ---
-----------------------

function PlayerGuiLogic.add_gui_for_heat_group(playerGui, heat_group)
    local group = playerGui.heat_group_container.add {
        type = "frame",
        name = "ahm__heat_group_root_#" .. heat_group.group_name,
        direction = "horizontal",
        caption = heat_group.group_name
    }
    group.add {
        type = "sprite-button",
        name = "ahm__heat_group_root_#" .. heat_group.group_name .. "__->edit_content",
        sprite = "heat_group_add_blueprint_icon",
        tooltip = "Выбрать/Перезаписать сущности для группы (Comming soon! :D)" -- TODO local text resource
    }
    group.add {
        type = "sprite-button",
        name = "ahm__heat_group_root_#" .. heat_group.group_name .. "__->delete_group",
        sprite = "heat_group_delete_icon",
        tooltip = "Удалить группу", -- todo local text resource
        tags = {
            group_name = heat_group.group_name
        }
    }
end

--- @type ItemStackIdentification
local selector__create_group = {
    name = 'heat-monitor__selector__create_group'
}

-- todo - refac : тут мы можем забить на player_index и вообще на gui_event
function PlayerGuiLogic.set_selector_create_group(player_index)
    print("create_group - RUN")
    local event_player = game.players[player_index]
    if event_player.clear_cursor() then -- ?  сброс выделенного предмата, если он есть
        local stack = event_player.cursor_stack
        if stack and stack.can_set_stack(selector__create_group) then stack.set_stack(selector__create_group) end
    end
end

-- todo - refac : тут мы можем забить на player_index и вообще на gui_event + @param heat_group_name
function PlayerGuiLogic.process_delete_group(playerGui, gui_event)
    print("create_group - RUN")
    local player_index = gui_event.player_index
    local heat_group_name = gui_event.element.tags.group_name

    --- todo - refac : попробовать заюзать get из map self.heat_group_container[heat_group_name].destroy()
    -- удалить gui -- уничтожить gui_element + все его дочерние элементы
    for _, gui_heat_group_root in ipairs(playerGui.heat_group_container.children) do
        if (string.find(gui_heat_group_root.name, heat_group_name)) then gui_heat_group_root.destroy() end
    end
end
