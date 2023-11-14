--- Обёртка для factorio global table
--- https://lua-api.factorio.com/latest/auxiliary/global.html
--- todo - refac: вынести 2 массива в PlayerState(HeatGroupList, PlayerGui) 
GlobalTable = {
    classname = "GlobalTable",
    --- @type HeatGroupList[] Map<player_index: number, HeatGroupList>
    player_and_heat_group_list__array = {},
    --- @type PlayerGui[] Map<player_index: number, PlayerGui>
    player_and_gui__array = {},
    --- @type boolean
    is_loaded_from_save = false,
    --- @type integer[] https://lua-api.factorio.com/latest/events.html#on_entity_destroyed
    entity_on_destroy_registration_numbers = {}
}

function GlobalTable.do_on_player_created(event)
    table.insert(GlobalTable.player_and_gui__array, PlayerGui:new(game.players[event.player_index]))
end

function GlobalTable.do_on_init_event()
    if global.ahm == nil then
        global.ahm = GlobalTable

        -- кейса: создаётся сейв и нам тут делать нечего.
        if #game.players == 0 then return end

        -- кейс: мод подгружается к Существующему сейву(сейв ранее не имел мода)
        for _, player in pairs(game.players) do
            table.insert(GlobalTable.player_and_heat_group_list__array, HeatGroupList:new())
            table.insert(GlobalTable.player_and_gui__array, PlayerGui:new(player))
        end
    end
end

--- Важно синхронизировать только состояние, методы лучше не трогать и не надеятся что 
--- они переживут выгрузку на диск в виде сейва.
function GlobalTable.do_on_load_event()
    GlobalTable.player_and_heat_group_list__array = global.ahm.player_and_heat_group_list__array
    GlobalTable.player_and_gui__array = global.ahm.player_and_gui__array
    GlobalTable.is_loaded_from_save = true
end

function GlobalTable.do_on_configuration_changed_event(configuration_changed_Data)
    log("GlobalTable.do_on_load_event() - RUN\r\n")
    -- --- пока ничего
    local our_changes = configuration_changed_Data.mod_changes["atomicHeat-monitor"]
    if our_changes == nil then return end

    --- 1 - наш мод подключили к существующему сейву и on_init_event() уже отрабовал, так что просто выходим
    --- on_init_event() -> on_configuration_changed_event()
    --- 2 - есть странный момент что lua Global state обнуляется между
    --- on_init_event() -> on_configuration_changed_event()
    --- НО! factorio global остаётся
    if (our_changes.old_version == nil) then
        return

        --- это тех. версии в них не было global state
    elseif (our_changes.old_version == "0.0.1") then
        GlobalTable.do_on_init_event()
    elseif (our_changes.old_version == "0.0.2") then
        PlayerGuiLogic.destrpy_gui_v_0_0_2()
        GlobalTable.do_on_init_event()
        local k = ""
        log("GlobalTable.do_on_load_event() - END\r\n")
    elseif (our_changes.old_version == "0.0.3") then
        GlobalTable.do_on_init_event()

    elseif (our_changes.old_version == "0.0.4") then
        GlobalTable.migration_to_0_0_5()
    elseif (our_changes.old_version == "0.0.6") then
        GlobalTable.migration_to_0_0_7()
    end
    log("GlobalTable.do_on_load_event() - END\r\n")
end

---------------
--- Getters ---
---------------

function GlobalTable.get_or_create_heat_group_list(player_index)
    local self = global.ahm
    local heat_group_list = self.player_and_heat_group_list__array[player_index]
    if (heat_group_list == nil) then
        heat_group_list = HeatGroupList:new()
        self.player_and_heat_group_list__array[player_index] = heat_group_list
    end
    return heat_group_list
end
function GlobalTable.get_or_create_Gui(player_index)
    if (player_index == nil) then error("player_index is nil") end
    local self = global.ahm
    local player_gui = self.player_and_gui__array[player_index]
    if (player_gui == nil) then
        player_gui = PlayerGui:new(game.players[player_index])
        self.player_and_gui__array[player_index] = player_gui
    end
    return player_gui
end

---@param entity LuaEntity
function GlobalTable.register_entity_on_destory(entity)
    table.insert(global.ahm.entity_on_destroy_registration_numbers, script.register_on_entity_destroyed(entity))
end

function GlobalTable.do_on_entity_destroyed(event)
    local register = global.ahm.entity_on_destroy_registration_numbers
    if (register[event.registration_number] == false) then return end

    for player_index, player_heat_group_list in pairs(global.ahm.player_and_heat_group_list__array) do
        HeatGroupStoreLogic.remove_entity_from_all_groups(player_heat_group_list, event.unit_number)
        -- HeatGroupStoreLogic.clear_empty_heat_groups(player_heat_group_list) -- todo impl
    end

    register[event.registration_number] = nil
end
--- clear_old_render_objects_and_create_new
--- rendering.draw_text(...) -> int - этот id Валиден только во время сессис, 
--- то есть при save-load он становится НЕ Валиден, однако сам object продолжает существовать... -_-
--- Удаляем все rendering object нашего мода и создаём новые на время этой сессии.
function GlobalTable.replace_all_old_render_objects()
    local all_render_object_ids = rendering.get_all_ids(ModName) -- int[]

    --- @type table<string, HeatMarker[]> Map<entity_unit_id : int, HeatMarker[]>
    local entity_unit_id__array_of_heat_marker = {}
    for player_index, player_heat_group_list in pairs(global.ahm.player_and_heat_group_list__array) do
        for group_name, heat_group in pairs(player_heat_group_list.content) do
            for entity_unit_number, heat_marker in pairs(heat_group.content) do
                if (entity_unit_id__array_of_heat_marker[entity_unit_number] == nil) then
                    entity_unit_id__array_of_heat_marker[entity_unit_number] = {heat_marker}
                else
                    table.insert(entity_unit_id__array_of_heat_marker[entity_unit_number], heat_marker)
                end
            end
        end
    end

    for _, id in pairs(all_render_object_ids) do
        local render_target = rendering.get_target(id)
        if (render_target == nil) then
            --- тут есть варианты:
            --- 1 - искать entity по позиции, но это не точно
            --- 2 - убить heat_marker
            --- 3 - делать continue - heat_markerне будет обновляться, ну да и хер с ним сейчас
            goto continue

        end -- todo - проверка и удаление и чисто создание новой начиеки для HeatMarker 

        local unit_number = render_target.entity.unit_number
        local array_of_heat_marker = entity_unit_id__array_of_heat_marker["" .. unit_number]
        if (array_of_heat_marker == nil) then
            log("replace_all_old_render_objects# array_of_heat_marker = nil")
            return
        end -- todo - проверка и хз что ещё, пусть будет

        local heat_marker = table.remove(array_of_heat_marker, 1)
        if (heat_marker == nil) then end -- todo - проверка и хз что ещё, пусть будет

        local type = rendering.get_type(id)
        if (type == "rectangle") then
            heat_marker.gui_box_id = id
        elseif (type == "text") then
            heat_marker.gui_text_id = id
        end
        ::continue::
    end
end

-------------------
---- Migrations ---
-------------------

function GlobalTable.migration_to_0_0_5()
    for index, player_gui in ipairs(GlobalTable.player_and_gui__array) do
        player_gui.is_menu_show = true
        PlayerGuiLogic.add_top_menu_btn(player_gui)
    end
end
function GlobalTable.migration_to_0_0_7() global.ahm.entity_on_destroy_registration_numbers = {} end

return GlobalTable
