
--------------------
--- other things ---
--------------------

Array = {
    classname = "FNArray"
}

function Array:new(array_name)
    -- return Array {}
    -- local obj = {
    --     name = array_name
    -- }

    -- function obj:get_array()
    --     local gl = Player.get_global()
    --     if not gl["a" .. self.name] then gl["a" .. self.name] = {} end
    --     return gl["a" .. self.name]
    -- end
end

function Array:get(array_name)
    local obj = {
        name = array_name
    }

    function obj:get_array()
        local gl = Player.get_global()
        if not gl["a" .. self.name] then gl["a" .. self.name] = {} end
        return gl["a" .. self.name]
    end
end

return Gui
