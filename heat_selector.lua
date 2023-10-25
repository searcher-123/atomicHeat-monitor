-- задел под будущие со списком групп из heat-enity для записи и отдельного отслеживания


--- todo - entity что обрабатываются heat-selector, их Маркеры должны жить вечно, ДО:
---         1 - entity destroed
---         2 - группа была удалена из списка
---         3 - entity была выделена с Shift (альтернативное выделение) -> убрать entity из группы + уничтожить маркер
--- todo - что будет есть entity уничтожена? есть ли event.on_object_destroy + callback ИЛИ нам нужно проверять самим?
--- todo - GUI список heat group 
--- todo - GUI список heat group CRUID
--- todo - (searcher) про зум, надо будет подумать, шрифт когда не масштабируется выглядит не очень.
--- todo - (searcher) выбор категории объектов для отображения полезно, но где то возле выборах палитры.
--- todo - (searcher) json пойдёт. Конвертеры есть. Что выводим - проговорим.
----        Должен быть номер тика, координаты объекта, температура.
----        остальное будет видно после первых пусков(если доберемся)
--- todo - (searcher) кнопки старта/стопа отображения, записи нужны.
--- todo - (searcher) 
--- todo - настройки мода
---             радиус отрисовки
---             границы цветов + выбор цвета (когда-то)
---             интервал кол-во тиков  перед обновлением  (default = 60)
--- todo - 
--- todo - 
--- хранит связку из
--- Игрок + Его личные heat_group, последних может быть много
heat_selector_singlton = {
    --- key - player_index : int 
    --- val - heat_group : heat_group[] 
    players_heat_groups = {
        [1] = {}
        -- ["heat group #0"] = {}
    }
}

heat_palette= {
 b_need_numbers=true,
 b_need_rects=false,
 ranges_numbers={
	{range=250,low={r=255,g=0,b=0,a=0},high={r=255,g=0,b=0,a=1}},
	{range=500,low={r=255,g=255,b=0,a=0.5},high={r=255,g=255,b=0,a=0.5}},
	{range=1000,low={r=0,g=250,b=0,a=1},high={r=0,g=250,b=0,a=1}}
},
ranges_rects={
	{range=500,low={r=0,g=0,b=255,a=0.2},high={r=200,g=200,b=200,a=0.1}},
	{range=1000,low={r=230,g=230,b=230,a=0.1},high={r=255,g=0,b=0,a=0.2}}
}
}

function heat_palette_export () 
	simple_export ('exported-palette.json',heat_palette)
	--game.write_file('exported-palette.json',table_to_json(table_name))
end
function simple_export (file_name,table_name)
	
	game.write_file(file_name,game.table_to_json(table_name))
end
function heat_palette_export () 
	simple_export ('exported-palette.json',heat_palette)
	--game.write_file('exported-palette.json',table_to_json(table_name))
end
function simple_import (file_name,table_name)
	
	game.write_file(file_name,game.table_to_json(table_name))
end



function heat_selector_singlton.get_group_by_player_index(player_index) end

--- heat_group : table
--- Пример структуры + конструктор
--- name : string
--- entities : table[]
function new_heat_group(name, entities)
    return {
        ["name"] = name,
        ["entities"] = entities
    }
end

function process(event, debug, print)
    if event.item and event.item ~= 'heat-monitor__selector' then return end
    heat_groups = heat_selector_singlton.players_heat_groups[event.player_index]
    -- table.insert(heat_groups, new_heat_group("heat group #1", event.entities))
    heat_groups[0] = new_heat_group("heat group #1", event.entities)
end

function do_nothing(value) end

function on_player_selected_area(event) process(event, false, do_nothing) end

function on_player_alt_selected_area(event)
    local player = game.players[event.player_index]
    process(event, true, player.print)
end

function on_lua_shortcut(event)
    if event.prototype_name == 'heat-monitor__shortcut' then
        local player = game.players[event.player_index]
        if player.clear_cursor() then -- ?  сброс выделенного предмата, если он есть
            local stack = player.cursor_stack
            if player.cursor_stack and stack.can_set_stack({
                name = 'heat-monitor__selector'
            }) then
                stack.set_stack({
                    name = 'heat-monitor__selector'
                })
            end
        end
    end
end

script.on_event(defines.events.on_player_selected_area, on_player_selected_area)
script.on_event(defines.events.on_player_alt_selected_area, on_player_alt_selected_area)
script.on_event(defines.events.on_lua_shortcut, on_lua_shortcut)


return {
    heat_selector = heat_selector_singlton
}
