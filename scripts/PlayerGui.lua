require "scripts.HeatPalettes"
--- Класс отвечает за Создание, Настройку, Изменение, Действия кнопок GUI для Одного Определённого юзера.
--- @class PlayerGui
--- @field player LuaPlayer
--- @field root LuaGuiElement
--- @field toolbar LuaGuiElement
--- @field heat_group_container LuaGuiElement
--- @field is_menu_show boolean
PlayerGui = {}
--- @param player LuaPlayer 
--- @return PlayerGui
function PlayerGui:new(player)
    local obj = {
        classname = "PlayerGui",
        player = player, --- @type LuaPlayer
        root = nil, --- @type LuaGuiElement @lateint
        toolbar = nil, --- @type LuaGuiElement @lateint
        heat_group_container = nil, --- @type LuaGuiElement @lateinit
        is_menu_show = false
    }

    -- config self
    PlayerGuiLogic.add_top_menu_btn(obj)
    return obj
end

--- методы для PlayerGui
PlayerGuiLogic = {}

function PlayerGuiLogic.destrpy_gui_v_0_0_2()
    log("PlayerGuiLogic.destrpy_gui_v_0_0_2() - RUN\r\n")
    for _, player in pairs(game.players) do player.gui.screen["ahm__root__frame"].destroy() end
end

----------------------
--- GUI init stage ---
----------------------

--- @param player_gui PlayerGui
function PlayerGuiLogic.add_top_menu_btn(player_gui)
    player_gui.player.gui.top.add {
        type = "sprite-button",
        name = "ahm__menu__->show/hide menu",
        sprite = "show_or_hide_menu",
        tooltip = {"btn.tooltip.show_or_hide_menu"}
    }
end
--- @param player_gui PlayerGui
function PlayerGuiLogic.add_main_menu_to_scene(player_gui)

    player_gui.root = player_gui.player.gui.screen.add {
        type = "frame",
        name = "ahm__root__frame",
        direction = "vertical",
        caption = "atomic heat monitor",
        children = {}
    }                                       
    player_gui.heat_group_container = player_gui.root.add {
        type = "scroll-pane",
        name = "ahm__heat_group_container__scroll-pane",
        direction = "vertical",
	caption="Heat gropus"
    }

    player_gui.is_menu_show = true


    player_gui.PaletteScrollerTitle= player_gui.heat_group_container.add {
    type="label",
    caption="Цветовая палитра"
    }

    player_gui.PaletteScroller= player_gui.heat_group_container.add {
        type = "drop-down",
        name = "ahm_heat__palette_dropdown",
        tooltip = {"btn.tooltip.show_or_hide_menu"}--need to correct
    }
    for name,palette in  pairs(heat_palettes) do player_gui.PaletteScroller.add_item (name.."/"..palette.name) end
    player_gui.PaletteScroller.selected_index=1
    player_gui.PaletteScrollerTitle= player_gui.heat_group_container.add {
    type="label",
    caption="Управление группами"
    }

end

--- @param player_gui PlayerGui
function PlayerGuiLogic.add_toolbar_to_main_menu(player_gui)
    player_gui.toolbar = player_gui.heat_group_container.add {
        type = "scroll-pane",
        name = "ahm__toolbar",
        direction = "horizontal"
    }
    player_gui.toolbar.add {
        type = "sprite-button",
        name = "ahm__toolbar__->create_group",
        sprite = "heat_group_add_blueprint_icon",
        tooltip = {"btn.tooltip.create_heat_group"}
    }
end

-----------------------
--- Buttons actions ---
-----------------------

--- @param player_gui PlayerGui
function PlayerGuiLogic.switch_show_or_hide_menu(player_gui)
    if player_gui.root == nil then
        PlayerGuiLogic.get_or_create_scene_menu_root(player_gui)
    elseif player_gui.is_menu_show == true then
        player_gui.root.visible = false
        player_gui.is_menu_show = false
    elseif player_gui.is_menu_show == false then
        player_gui.root.visible = true
        player_gui.is_menu_show = true
    elseif player_gui.is_menu_show == nil then
        log("player_gui.is_menu_show == nil # player_gui.player.index=" .. player_gui.player.index)
    end
end

--- @param player_gui PlayerGui
--- @return LuaGuiElement
function PlayerGuiLogic.get_or_create_scene_menu_root(player_gui)
    if player_gui.root == nil then
        PlayerGuiLogic.add_main_menu_to_scene(player_gui)
        PlayerGuiLogic.add_toolbar_to_main_menu(player_gui)
    end
    return player_gui.root
end

--- @param player_gui PlayerGui
--- @param heat_group HeatGroup
function PlayerGuiLogic.add_gui_for_heat_group(player_gui, heat_group)
    local group = player_gui.heat_group_container.add {
        type = "frame",
        name = "ahm__heat_group_root_#" .. heat_group.group_name,
        direction = "horizontal",
        caption = heat_group.group_name
    }
    -- group.add {
    --     type = "sprite-button",
    --     name = "ahm__heat_group_root_#" .. heat_group.group_name .. "__->edit_content",
    --     sprite = "heat_group_add_blueprint_icon",
    --     tooltip = "Выбрать/Перезаписать сущности для группы (Comming soon! :D)" -- TODO local text resource
    -- }
    group.add {
        type = "sprite-button",
        name = "ahm__heat_group_root_#" .. heat_group.group_name .. "__->delete_group",
        sprite = "heat_group_delete_icon",
        tooltip = {"btn.tooltip.delete_heat_group"},
        tags = {
            group_name = heat_group.group_name
        }
    }
end

--- @type ItemStackIdentification
local selector__create_group = {
    name = 'heat-monitor__selector__create_group'
}

--- @param player_index number
function PlayerGuiLogic.set_selector_create_group(player_index)
    print("create_group - RUN")
    local event_player = game.players[player_index]
    if event_player.clear_cursor() then -- ?  сброс выделенного предмата, если он есть
        local stack = event_player.cursor_stack
        if stack and stack.can_set_stack(selector__create_group) then stack.set_stack(selector__create_group) end
    end
end

--- @param player_gui PlayerGui
--- @param heat_group_name string
function PlayerGuiLogic.process_delete_group(player_gui, heat_group_name)
    for _, gui_heat_group_root in ipairs(player_gui.heat_group_container.children) do
        if (string.find(gui_heat_group_root.name, heat_group_name)) then gui_heat_group_root.destroy() end
    end
end
