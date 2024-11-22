local FieldStatus = require 'ChessyXeL.FieldStatus'
local RuntimeVal = require 'ChessyXeL.chx.runtime.values.RuntimeVal'

---@class chx.runtime.values.NativeFnValue : chx.runtime.values.RuntimeVal
local NativeFnValue = RuntimeVal.extend 'NativeFnValue'

NativeFnValue.call = FieldStatus.PUBLIC('default', 'default', nil)
NativeFnValue.new = function (FunctionCall)
    local nativeFnValue = NativeFnValue.create()
    nativeFnValue.type = 'native-fn'
    nativeFnValue.call = FunctionCall
    return nativeFnValue
end

return NativeFnValue