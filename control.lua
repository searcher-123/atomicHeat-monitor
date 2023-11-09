ModName = "atomicHeat-monitor"

Listener = require "scripts/GlobalEventListener"
GlobalTable = require "scripts.GlobalTable"
require "scripts.PlayerGui"
require "scripts.HeatGroupList"
require "scripts.HeatGroup"
require "scripts.HeatMarker"

Listener.register_events_handlers()
