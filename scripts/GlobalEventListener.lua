--- Первый уровень обработки любых Event
--- содержит все EventHandlers - методы начинающиеся с do_on_ ...
GlobalEventListener = {
    classname = "GlobalGuiEventListener",

    shortcut_hotkey_event_name = "ahm_pressed-create_group_hotkey",
    selector__shortcut_name = "heat-monitor__shortcut"
}
-- жуткий глобальный костыль.номер палитры
PaletteNumber = 1
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
    script.on_event(defines.events.on_gui_selection_state_changed, GlobalEventListener.on_gui_selection_state_changed)

    script.on_event(defines.events.on_player_selected_area,
                    function(event) GlobalEventListener:do_on_player_selected_area(event, false) end)
    script.on_event(defines.events.on_player_alt_selected_area,
                    function(event) GlobalEventListener:do_on_player_selected_area(event, true) end)

    script.on_nth_tick(1, GlobalEventListener.on_nth_tick_update_temperature)

    script.on_event(defines.events.on_lua_shortcut, GlobalEventListener.do_on_lua_shortcut)
    script.on_event(GlobalEventListener.shortcut_hotkey_event_name, GlobalEventListener.do_on_shortcut_hotkey_pressed)

    script.on_event(defines.events.on_entity_destroyed, GlobalEventListener.do_on_entity_destroyed)
end

function GlobalEventListener.do_on_entity_destroyed(event) GlobalTable.do_on_entity_destroyed(event) end

function GlobalEventListener.do_on_init_event() GlobalTable.do_on_init_event() end
function GlobalEventListener.do_on_load_event() GlobalTable.do_on_load_event() end
function GlobalEventListener.do_on_configuration_changed_event(configurationChangedData)
    GlobalTable.do_on_configuration_changed_event(configurationChangedData)
end
function GlobalEventListener.do_on_player_created(event) GlobalTable.do_on_player_created(event) end

-----------------------------------
-----------------------------------
-----------------------------------

--- https://lua-api.factorio.com/latest/events.html#on_gui_click
function GlobalEventListener.do_on_gui_click(gui_event)
    local btn_name = gui_event.element.name
    log ("btn_name "..btn_name)
    -- скипаем нажатия на Чужие кнопки, все наши кнопки начинаются на "ahm"
    if (string.sub(btn_name, 1, 3) ~= "ahm") then return end

    local player_gui = GlobalTable.get_or_create_Gui(gui_event.player_index)
    local player_groups = GlobalTable.get_or_create_heat_group_list(gui_event.player_index)
    local player_name = game.players[gui_event.player_index].name
    --вдруг нажато то, что не входит в группы
--    if (nil==gui_event.element.tags) or (nil==gui_event.element.tags.group_name)  then return end

    --- @type string | nil - если в GUI казан этот аргумент, то он будет тут, иначе nil    
    local heat_group_name = gui_event.element.tags.group_name

    if string.find(btn_name, "->show/hide menu") then
        PlayerGuiLogic.switch_show_or_hide_menu(player_gui)
    elseif string.find(btn_name, "->create_group") then
        PlayerGuiLogic.set_selector_create_group(gui_event.player_index)
    elseif string.find(btn_name, "->edit_content") then
    elseif string.find(btn_name, "->delete_group") then
        -- важен порядок действий - сначала логика, и в конце gui
        HeatGroupStoreLogic.delete_heat_group(player_groups, heat_group_name)
        PlayerGuiLogic.process_delete_group(player_gui, heat_group_name)
    elseif string.find(btn_name, "->start_record") then
        local recorder = player_groups.content[heat_group_name].recorder        
        recorder.decimator= player_gui.heat_group_container.ahm_heat__ReducerText_textfield.text
        
        EntityHeatCollectorLogic.start_record(recorder, player_name)
    elseif string.find(btn_name, "->stop_record") then
        local group_gui_element_name = "ahm__heat_group_root_#" .. heat_group_name
        local heat_group = player_groups.content[heat_group_name]
        local recorder = heat_group.recorder
        local lbl_name = string.gsub(btn_name, "->stop_record", "->label")
        -- считать имя файла.
        recorder.heat_group_name = player_gui.heat_group_container[group_gui_element_name][lbl_name].text

        EntityHeatCollectorLogic.stop_record(recorder, player_name)
        HeatGroupLogic.refresh_recorder(heat_group)
    end
end

function GlobalEventListener.on_gui_selection_state_changed(gui_event)
    local selection_name = gui_event.element.name
    for fname, field in pairs(gui_event.element) do log("on_gui_selection_state_changed->" .. fname) end
    -- баг на баге. Не берётся имя списка (
    --    log (" on_gui_selection_state_changed"..gui_event.element)
    -- скипаем нажатия на Чужие кнопки, все наши кнопки начинаются на "ahm"
    --    if (string.sub(selection_name, 1, 3) ~= "ahm") then return end

    local player_gui = GlobalTable.get_or_create_Gui(gui_event.player_index)
    local player_groups = GlobalTable.get_or_create_heat_group_list(gui_event.player_index)

    if string.find(selection_name, "palette_dropdown") then
        --        PlayerGuiLogic.switch_show_or_hide_menu(player_gui)--set palette
        log("state_changed" .. gui_event.element.selected_index)
        PaletteNumber = gui_event.element.selected_index

    end
end

--- https://lua-api.factorio.com/latest/events.html#on_player_selected_area
function GlobalEventListener:do_on_player_selected_area(event, is_alt_select)
    local player_index = event.player_index --- @type integer
    local group_entities = event.entities --- @type LuaEntity

    --- если нету выбраных entity, но делать нечего
    if (#group_entities == 0) then return end

    local player_gui = GlobalTable.get_or_create_Gui(player_index)
    local heat_group_list = GlobalTable.get_or_create_heat_group_list(player_index)

    if (event.item == "heat-monitor__selector__create_group") then
        if (is_alt_select == false) then
            GlobalConroller.add_group_for_player(player_index, group_entities)
        else
            for index, entity in ipairs(group_entities) do
                HeatGroupStoreLogic.remove_entity_from_all_groups(heat_group_list, entity.unit_number)
            end
        end
    elseif (event.item == "heat-monitor__selector__edit_group") then
        if (is_alt_select == false) then end
    end
end

function GlobalEventListener.on_nth_tick_update_temperature(event)
    if (GlobalTable.is_loaded_from_save) then
        GlobalTable.replace_all_old_render_objects()
        GlobalTable.is_loaded_from_save = false
    end
    for player_index, player_heat_groups in pairs(GlobalTable.player_and_heat_group_list__array) do
        for heat_group_name, heat_group in pairs(player_heat_groups.content) do
            HeatGroupLogic.update_temperature_values(heat_group)
            if heat_group.recorder.is_recording then
                EntityHeatCollectorLogic.do_every_tick(heat_group.recorder, event.tick)
            end
        end
    end
end
--- https://lua-api.factorio.com/latest/events.html#on_lua_shortcut
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

--- @param player_index number
--- @param group_entites LuaEntity[]
function GlobalConroller.add_group_for_player(player_index, group_entites)
    local player_gui = GlobalTable.get_or_create_Gui(player_index)
    local heat_group_list = GlobalTable.get_or_create_heat_group_list(player_index)

    local new_heat_group = HeatGroupStoreLogic.create_heat_group(heat_group_list, group_entites)

    if player_gui.root == nil then PlayerGuiLogic.get_or_create_scene_menu_root(player_gui) end
    PlayerGuiLogic.add_gui_for_heat_group(player_gui, new_heat_group)
end

--- @param player_index number
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
