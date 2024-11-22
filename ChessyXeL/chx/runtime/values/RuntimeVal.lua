local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local Class = require 'ChessyXeL.Class'

---@class chx.runtime.values.RuntimeVal : Class
local RuntimeVal = Class 'RuntimeVal'

RuntimeVal.type = FieldStatus.PUBLIC('default', 'default', nil)
RuntimeVal.fields = FieldStatus.PUBLIC('default', 'default', nil)

RuntimeVal.setField = Method.PUBLIC(function (val, field, ret)
    val.fields[field] = ret
end)
RuntimeVal.setMethod = Method.PUBLIC(function (val, name, func)
    val.fields[name] = function() return func end
end)
RuntimeVal.new = function (type)
    local runtimeVal = RuntimeVal.create()
    runtimeVal.type = type
    runtimeVal.fields = {}
    return runtimeVal
end

return RuntimeVal