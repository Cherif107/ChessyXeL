local FieldStatus = require 'ChessyXeL.FieldStatus'
local RuntimeVal = require 'ChessyXeL.chx.runtime.values.RuntimeVal'

---@class chx.runtime.values.NullVal : chx.runtime.values.RuntimeVal
local NullVal = RuntimeVal.extend 'NullVal'

NullVal.value = FieldStatus.PUBLIC('default', 'default', nil)
NullVal.new = function ()
    local nullVal = NullVal.create()
    nullVal.type = 'null'
    nullVal.value = 'null'
    return nullVal
end

return NullVal