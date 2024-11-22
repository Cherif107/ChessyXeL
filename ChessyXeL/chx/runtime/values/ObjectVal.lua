local FieldStatus = require 'ChessyXeL.FieldStatus'
local RuntimeVal = require 'ChessyXeL.chx.runtime.values.RuntimeVal'

---@class chx.runtime.values.ObjectVal : chx.runtime.values.RuntimeVal
local ObjectVal = RuntimeVal.extend 'ObjectVal'

ObjectVal.properties = FieldStatus.PUBLIC('default', 'default', nil)
ObjectVal.new = function (properties)
    local objectVal = ObjectVal.create()
    objectVal.type = 'object'
    objectVal.properties = properties
    return objectVal
end

return ObjectVal