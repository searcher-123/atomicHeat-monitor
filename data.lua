data:extend(
        {
            {
                type = "custom-input",
                name = "ahm_pressed-create_group_hotkey",
                key_sequence = "ALT + T",
                consuming = "none"
            },
            {
                type = "shortcut",
                name = "heat-monitor__shortcut",
                localised_name = "Atomic heat monitor",
		associated_control_input = "ahm_pressed-create_group_hotkey",
                action = "lua",
                icon = {
                    filename = "__base__/graphics/icons/nuclear-reactor.png",
                    size = 64,
                    scale = 1,
                    flags = { "icon" }
                }
            },
            {
                type = "selection-tool",
                name = "heat-monitor__selector__create_group",
--                icon = "__base__/graphics/icons/heat-boiler.png",
                icon = "__base__/graphics/icons/signal/signal_red.png",
                icon_size = 64,
                subgroup = "tool",
                stack_size = 1,
                stackable = false,
                draw_label_for_cursor_render = true,
                selection_color = { r = 0, g = 0, b = 1 },
                alt_selection_color = { r = 1, g = 0, b = 0 },
                flags = { "only-in-cursor" },
                selection_mode = { "buildable-type" },
                alt_selection_mode = { "buildable-type" },
                selection_cursor_box_type = "entity",
                alt_selection_cursor_box_type = "entity",
                entity_filter_mode = "whitelist",
                entity_type_filters = {
                    "reactor", "boiler", "heat-pipe"
                },
                alt_entity_filter_mode = "whitelist",
                alt_entity_type_filters = {
                    "reactor", "boiler", "heat-pipe"
                },
            },

            {
                type = "custom-input",
                name = "ahm_pressed-create_group_hotkey",
                key_sequence = "ALT + T",
                consuming = "none"
            },
            --sprite
            {
                type = "sprite",
                name = "heat_group_add_blueprint_icon",
                filename = "__atomicHeat-monitor__/graphics/blueprint_add.png",
                priority = "extra-high-no-scale",
                width = 64,
                height = 64,
                scale = 1,
            },
            {
                type = "sprite",
                name = "heat_group_delete_icon",
                filename = "__atomicHeat-monitor__/graphics/cross.png",
                priority = "extra-high-no-scale",
                width = 64,
                height = 64,
                scale = 1,
            },
            {
                type = "sprite",
                name = "show_or_hide_menu",
                filename = "__atomicHeat-monitor__/graphics/icon_ahm_main_menu_v2.png",
                priority = "extra-high-no-scale",
                width = 40,
                height = 40,
                scale = 1,
            },
            {
                type = "sprite",
                name = "start_record",
                filename = "__atomicHeat-monitor__/graphics/start_record.png",
                priority = "extra-high-no-scale",
                width = 100,
                height = 100,
                scale = 1,
            },
            {
                type = "sprite",
                name = "stop_record",
                filename = "__atomicHeat-monitor__/graphics/stop_record_2.png",
                priority = "extra-high-no-scale",
                width = 96,
                height = 96,
                scale = 1,
            },
        }
)
