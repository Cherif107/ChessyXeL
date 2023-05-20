local FieldStatus = require 'ChessyXeL.FieldStatus'
local Enum = require 'ChessyXeL.Enum'

---@class Field Used for Class Fields to manage Private and Public variables and also Getters and Setters
---[[ FIELDS:START ]]---
---@field public status FieldStatus Type of Field
---@field public value any Current Field Value (Unlike status.value, this Field always changes when it's set)
---@field public get function A Function that gets called when Indexed.
---@field public set function A Function that gets called when Set.
---@field public static boolean If the Field is Static or not
---[[ FIELDS:END ]]---
local Field = {
    ---@param status FieldStatus
    ---@return Field
    new = function (status, n)
        local field = {
            bypassedSet = false,
            bypassedGet = false,
            status = status,
        }
        local function check(get, set, value, static, private)
            set = (set ~= 'default' and set or nil)
            get = (get ~= 'default' and get or nil)
            if static then field.static = true else field.static = false end
            field.get = get
            field.set = set
            field.value = value
            field.private = private
        end
        Enum.switch(status, {
            [FieldStatus.NORMAL] = function (get, set, value, static)
                check(get, set, value, static, true)
            end,
            [FieldStatus.PUBLIC] = function (get, set, value, static)
                check(get, set, value, static, false)
            end,
            [FieldStatus.PRIVATE] = function (get, set, value, static)
                check(get, set, value, static, true)
            end
        })
        return field
    end
}
return setmetatable(Field, {__call = function(t, status, n)
    return Field.new(status, n)
end})