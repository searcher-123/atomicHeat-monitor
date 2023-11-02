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
		localised_name = "Atomic heat monitor - создать Тепловую группу", -- todo - local text resource
		localised_description = "создать Тепловую группу", -- todo - local text resource
		action = "lua",
		icon = {
		filename = "__base__/graphics/icons/nuclear-reactor.png",
		size = 64,
			scale = 1,
			flags = { "icon" }
		}
	},
	-- {
	-- 	type = "selection-tool",
	-- 	name = "heat-monitor__selector",
	-- 	icon = "__base__/graphics/icons/nuclear-reactor.png",
	-- 	icon_size = 64,
	-- 	subgroup = "tool",
	-- 	stack_size = 1,
	-- 	stackable = false,
	-- 	draw_label_for_cursor_render = true,
	-- 	selection_color = { r = 0, g = 0, b = 1 },
	-- 	alt_selection_color = { r = 1, g = 0, b = 0 },
	-- 	flags = { "only-in-cursor" },
	-- 	selection_mode = { "buildable-type" },
	-- 	alt_selection_mode = { "buildable-type" },
	-- 	selection_cursor_box_type = "entity",
	-- 	alt_selection_cursor_box_type = "entity",
	-- 	entity_filter_mode = "whitelist",
	-- 	entity_type_filters = {
    --         "reactor", "boiler", "heat-pipe"
	-- 	},
	-- 	alt_entity_filter_mode = "whitelist",
	-- 	alt_entity_type_filters = { 
    --          "reactor", "boiler", "heat-pipe"
	-- 	}
	-- },
	{
		type = "selection-tool",
		name = "heat-monitor__selector__create_group",
		-- icon = "__base__/graphics/icons/nuclear-reactor.png",
		-- icon = "__base__/graphics/icons/heat-pipe.png",
		icon = "__base__/graphics/icons/heat-boiler.png",
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
})
