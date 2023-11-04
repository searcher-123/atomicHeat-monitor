--- Обёртка для factorio global table
--- https://lua-api.factorio.com/latest/auxiliary/global.html
--- todo - refac: вынести 2 массива в PlayerState(HeatGroupList, PlayerGui) 
GlobalTable = {
    classname = "GlobalTable",
    player_and_heat_group_list__array = {}, -- :Table<player_index: number, HeatGroupList>
    player_and_gui__array = {}, -- :Table<player_index: number, PlayerGui>
    is_loaded_from_save = false
}

--- Наш мод подключили к существующему сейву 
--- ИЛИ создаётся чистый сейв уже с модом 
--- ИЛИ подключается новый новый игрок
function GlobalTable.do_on_init_event()
    log("GlobalTable.do_on_init_event() - RUN\r\n")
    if  global.ahm  == nil then
        for _, player in pairs(game.players) do
            table.insert(GlobalTable.player_and_heat_group_list__array, HeatGroupList:new())
            table.insert(GlobalTable.player_and_gui__array, PlayerGui:new(player))
        end
        global.ahm = GlobalTable
    end
end

--- Важно синхронизировать только состояние, методы лучше не трогать и не надеятся что 
--- они переживут выгрузку на диск в виде сейва.
function GlobalTable.do_on_load_event()
    GlobalTable.player_and_heat_group_list__array = global.ahm.player_and_heat_group_list__array
    GlobalTable.player_and_gui__array = global.ahm.player_and_gui__array
    GlobalTable.is_loaded_from_save = true
end

--- game version
--- ANY mod version
--- (ADD || REMOVE) ANY mod
--- (ADD || REMOVE) ANY prototype
--- ANY startup setting 
function GlobalTable.do_on_configuration_changed_event(configurationChangedData)
    log("GlobalTable.do_on_load_event() - RUN\r\n")
    -- --- пока ничего
    local our_changes = configurationChangedData.mod_changes["atomicHeat-monitor"]

    --- 1 - наш мод подключили к существующему сейву и on_init_event() уже отрабовал, так что просто выходим
    --- on_init_event() -> on_configuration_changed_event()
    --- 2 - есть странный момент что lua Global state обнуляется между
    --- on_init_event() -> on_configuration_changed_event()
    --- НО! factorio global остаётся
    if (our_changes.old_version == nil) then return

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

        --- для будущего
    -- elseif (our_changes.old_version == "0.0.4") then

        -- global.ahm.total_destroy() -- todo impl
        -- GlobalTable.do_on_init_event()

    -- else
        -- GlobalTable.do_on_init_event()
    end
    local k = ""
    log("GlobalTable.do_on_load_event() - END\r\n")
end

---------------
--- Getters ---
---------------

function GlobalTable.get_or_create_heat_group_list(player_index)
    -- local self = GlobalTable
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
    -- local self = GlobalTable
    local self = global.ahm
    local player_gui = self.player_and_gui__array[player_index]
    if (player_gui == nil) then
        player_gui = PlayerGui:new(game.players[player_index])
        self.player_and_gui__array[player_index] = player_gui
    end
    return player_gui
end

-- function GlobalTable.init_global_state()
--         if not global.ahm then
--         for _, player in pairs(game.players) do
--             table.insert(GlobalTable.player_and_heat_group_list__array, HeatGroupList:new())
--             table.insert(GlobalTable.player_and_gui__array, PlayerGui:new(player))
--         end
--         global.ahm = GlobalTable
--     end
-- end

--- clear_old_render_objects_and_create_new
--- rendering.draw_text(...) -> int - этот id Валиден только во время сессис, 
--- то есть при save-load он становится НЕ Валиден, однако сам object продолжает существовать... -_-
--- Удаляем все rendering object нашего мода и создаём новые на время этой сессии.
function GlobalTable.replace_all_old_render_objects()
    -- rendering.clear(ModName)

    local all_render_object_ids = rendering.get_all_ids(ModName) -- int[]

    local entity_unit_id__array_of_heat_marker = {} --- :Table<entity_unit_id : int, HeatMarker[]>
    for player_index, player_heat_group_list in pairs(global.ahm.player_and_heat_group_list__array) do
        for group_name, heat_group in pairs(player_heat_group_list.content) do
            for enity_unit_number, heat_marker in pairs(heat_group.content) do
                if (entity_unit_id__array_of_heat_marker[enity_unit_number] == nil) then
                    entity_unit_id__array_of_heat_marker[enity_unit_number] = {heat_marker}
                else
                    table.insert(entity_unit_id__array_of_heat_marker[enity_unit_number], heat_marker)
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
        local array_of_heat_marker = entity_unit_id__array_of_heat_marker[""..unit_number]
        if (array_of_heat_marker == nil) then 
            log ("replace_all_old_render_objects# array_of_heat_marker = nil")
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


return GlobalTable