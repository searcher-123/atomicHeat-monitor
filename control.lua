ModName = "atomicHeat-monitor"

Listener = require "scripts.GlobalEventListener"
require "scripts.GlobalTable"
require "scripts.PlayerGui"
require "scripts.HeatGroupList"
require "scripts.HeatGroup"
require "scripts.HeatMarker"
require "scripts.EntityHeatCollector"

Listener.register_events_handlers()
