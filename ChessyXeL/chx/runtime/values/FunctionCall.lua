local FieldStatus = require 'ChessyXeL.FieldStatus'
local RuntimeVal = require 'ChessyXeL.chx.runtime.values.RuntimeVal'

---@class chx.runtime.values.FunctionCall : chx.runtime.values.RuntimeVal
local FunctionCall = RuntimeVal.extend 'FunctionCall'

FunctionCall.args = FieldStatus.PUBLIC('default', 'default', nil)
FunctionCall.new = function (args, env)
    local functionCall = FunctionCall.create()
    functionCall.type = 'functioncall'
    functionCall.args = args
    return functionCall
end

return FunctionCall