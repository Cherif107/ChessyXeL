local FieldStatus = require 'ChessyXeL.FieldStatus'
local RuntimeVal = require 'ChessyXeL.chx.runtime.values.RuntimeVal'

---@class chx.runtime.values.NumberVal : chx.runtime.values.RuntimeVal
local NumberVal = RuntimeVal.extend 'NumberVal'

NumberVal.value = FieldStatus.PUBLIC('default', 'default', nil)
NumberVal.new = function (value)
    local numberVal = NumberVal.create()
    numberVal.type = 'Int'
    numberVal.value = value
    return numberVal
end

return NumberVal