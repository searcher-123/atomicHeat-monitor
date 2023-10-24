data:extend(
{
	{
		type = "shortcut",
		name = "heat-monitor__shortcut",
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
		name = "heat-monitor__selector",
		icon = "__base__/graphics/icons/nuclear-reactor.png",
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
		}
	}
})
