local FieldStatus = require 'ChessyXeL.FieldStatus'
local RuntimeVal = require 'ChessyXeL.chx.runtime.values.RuntimeVal'

---@class chx.runtime.values.FunctionValue : chx.runtime.values.RuntimeVal
local FunctionValue = RuntimeVal.extend 'FunctionValue'

FunctionValue.name = FieldStatus.PUBLIC('default', 'default', nil)
FunctionValue.parameters = FieldStatus.PUBLIC('default', 'default', nil)
FunctionValue.optionalParameters = FieldStatus.PUBLIC('default', 'default', nil)
FunctionValue.declarationEnv = FieldStatus.PUBLIC('default', 'default', nil)
FunctionValue.body = FieldStatus.PUBLIC('default', 'default', nil)
FunctionValue.new = function (name, parameters, body, optionalParameters, env)
    local functionValue = FunctionValue.create()
    functionValue.type = 'function'
    functionValue.name = name
    functionValue.parameters = parameters
    functionValue.body = body
    functionValue.declarationEnv = env
    functionValue.optionalParameters = optionalParameters or {}
    return functionValue
end

return FunctionValue