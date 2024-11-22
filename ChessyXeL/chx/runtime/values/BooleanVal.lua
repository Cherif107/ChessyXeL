local FieldStatus = require 'ChessyXeL.FieldStatus'
local RuntimeVal = require 'ChessyXeL.chx.runtime.values.RuntimeVal'

---@class chx.runtime.values.BooleanVal : chx.runtime.values.RuntimeVal
local BooleanVal = RuntimeVal.extend 'BooleanVal'

BooleanVal.value = FieldStatus.PUBLIC('default', 'default', nil)
BooleanVal.new = function (value)
    local booleanVal = BooleanVal.create()
    booleanVal.type = 'Bool'
    booleanVal.value = value or false
    return booleanVal
end

return BooleanVal