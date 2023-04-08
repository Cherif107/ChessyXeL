---@class LuaUtil Some Utilities that can be useful
local LuaUtil = {
    ---@generic T
    ---@param value T The Value that will get a Metatable
    ---@param metatable table<any, any> Metatable to set to the Value
    ---@return T
    setmetatable = function (value, metatable)
        if not string.find(tostring(value), "^userdata") then
            debug.setmetatable(value, metatable)
        else
            error("Cannot set metatable on internal Lua value or constant string")
        end
        return value
    end,
    ---@param value any The Value that will get a Metatable
    ---@return table
    getmetatable = function (value)
        if not string.find(tostring(value), "^userdata") then
            return debug.getmetatable(value)
        else
            error("Cannot get metatable on internal Lua value or constant string")
        end
        return {}
    end
}

return LuaUtil