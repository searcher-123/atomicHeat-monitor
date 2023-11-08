--- Первый уровень обработки любых Event
--- содержит все EventHandlers - методы начинающиеся с do_on_ ...
GlobalEventListener = {
    classname = "GlobalGuiEventListener",

    shortcut_hotkey_event_name = "ahm_pressed-create_group_hotkey",
    selector__shortcut_name = "heat-monitor__shortcut"
}

--------------------
--- GUI trigger ---
--------------------
function GlobalEventListener.register_events_handlers()
    --- Наш мод подключили к существующему сейву 
    --- ИЛИ создаётся чистый сейв уже с модом 
    --- ИЛИ подключается новый новый игрок
    script.on_init(GlobalEventListener.do_on_init_event)
    script.on_load(GlobalEventListener.do_on_load_event)
    --- Вызывается в любом из случаев:
    --- GAME version
    --- ANY MOD version
    --- (ADD || REMOVE) ANY mod
    --- (ADD || REMOVE) ANY prototype
    --- ANY startup setting 
    script.on_configuration_changed(GlobalEventListener.do_on_configuration_changed_event)

    --- https://lua-api.factorio.com/latest/events.html#on_player_created
    script.on_event(defines.events.on_player_created, GlobalEventListener.do_on_player_created)

    script.on_event(defines.events.on_gui_click, GlobalEventListener.do_on_gui_click)
    script.on_event(defines.events.on_player_selected_area,
                    function(event) GlobalEventListener:do_on_player_selected_area(event, false) end)
    script.on_event(defines.events.on_player_alt_selected_area,
                    function(event) GlobalEventListener:do_on_player_selected_area(event, true) end)

    script.on_nth_tick(60, GlobalEventListener.on_nth_tick_update_temperature)

    script.on_event(defines.events.on_lua_shortcut, GlobalEventListener.do_on_lua_shortcut)
    script.on_event(GlobalEventListener.shortcut_hotkey_event_name, GlobalEventListener.do_on_shortcut_hotkey_pressed)
end

function GlobalEventListener.do_on_init_event() GlobalTable.do_on_init_event() end
function GlobalEventListener.do_on_load_event() GlobalTable.do_on_load_event() end
function GlobalEventListener.do_on_configuration_changed_event(configurationChangedData)
    GlobalTable.do_on_configuration_changed_event(configurationChangedData)
end
function GlobalEventListener.do_on_player_created(event) GlobalTable.do_on_player_created(event) end

-----------------------------------
-----------------------------------
-----------------------------------

function GlobalEventListener.do_on_gui_click(gui_event)
    local btn_name = gui_event.element.name
    -- скипаем нажатия на Чужие кнопки, все наши кнопки начинаются на "ahm"
    if (string.sub(btn_name, 1, 3) ~= "ahm") then return end

    local player_gui = GlobalTable.get_or_create_Gui(gui_event.player_index)
    local player_groups = GlobalTable.get_or_create_heat_group_list(gui_event.player_index)

    if string.find(btn_name, "->show/hide menu") then
        PlayerGuiLogic.switch_show_or_hide_menu(player_gui)
    elseif string.find(btn_name, "->create_group") then
        PlayerGuiLogic.set_selector_create_group(gui_event.player_index)
    elseif string.find(btn_name, "->edit_content") then
    elseif string.find(btn_name, "->delete_group") then
        -- важен порядок действий - сначала логика, и в конце gui
        local heat_group_name =  gui_event.element.tags.group_name
        HeatGroupStoreLogic.delete_heat_group(player_groups, heat_group_name)
        PlayerGuiLogic.process_delete_group(player_gui,heat_group_name)
    end
end

-- https://lua-api.factorio.com/latest/events.html#on_player_selected_area
function GlobalEventListener:do_on_player_selected_area(event, is_alt_select)
    local player_index = event.player_index
    local group_entities = event.entities
    local player_gui = GlobalTable.get_or_create_Gui(player_index)
    local heat_group_list = GlobalTable.get_or_create_heat_group_list(player_index)

    if (event.item == "heat-monitor__selector__create_group") then
        if (is_alt_select == false) then
            GlobalConroller.add_group_for_player(player_index, group_entities)
        else

        end
    elseif (event.item == "heat-monitor__selector__edit_group") then
        if (is_alt_select == false) then end
    end
end

function GlobalEventListener.on_nth_tick_update_temperature()
    if (GlobalTable.is_loaded_from_save) then
        GlobalTable.replace_all_old_render_objects()
        GlobalTable.is_loaded_from_save = false
    end
    for player_index, player_heat_groups in pairs(GlobalTable.player_and_heat_group_list__array) do
        for heat_group_name, heat_group in pairs(player_heat_groups.content) do
            HeatGroupLogic.update_temperature_values(heat_group)
        end
    end
end

function GlobalEventListener.do_on_lua_shortcut(event)
    if event.prototype_name ~= GlobalEventListener.selector__shortcut_name then return end
    GlobalConroller.set_selector_tool(event.player_index)
end

function GlobalEventListener.do_on_shortcut_hotkey_pressed(event) GlobalConroller.set_selector_tool(event.player_index) end

--------------------------------------------
--------------------------------------------
--------------------------------------------

--------------------
--- Bussines API ---
--------------------

--- Второй уровень обработки любых Event
--- вспомогательный класс для GlobalEventListener
GlobalConroller = {
    classname = "GlobalConroller"
}

function GlobalConroller.add_group_for_player(player_index, group_entites)
    local player_gui = GlobalTable.get_or_create_Gui(player_index)
    local heat_group_list = GlobalTable.get_or_create_heat_group_list(player_index)

    local new_heat_group = HeatGroupStoreLogic.create_heat_group(heat_group_list, group_entites)
    PlayerGuiLogic.add_gui_for_heat_group(player_gui, new_heat_group)
end

function GlobalConroller.set_selector_tool(player_index)
    -- делаем вид, что передаём gui_event. Мимикрируем под gui_event XD
    PlayerGuiLogic.set_selector_create_group(player_index)
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
--- debug
function GlobalConroller.show_render_ids()
    local ids = rendering.get_all_ids(ModName)
    for index, id in ipairs(ids) do
        ids[index] = {
            id = "id",
            is_valid = rendering.is_valid(id)
        }
    end
    return ids
end


return GlobalEventListener
