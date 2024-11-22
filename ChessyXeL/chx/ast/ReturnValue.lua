local FieldStatus = require 'ChessyXeL.FieldStatus'
local Expr = require 'ChessyXeL.chx.ast.Expr'

---@class chx.ast.ReturnValue : chx.ast.Expr
local ReturnValue = Expr.extend 'ReturnValue'

ReturnValue.value = FieldStatus.PUBLIC('default', 'default', nil)
ReturnValue.new = function (value)
    local returnValue = ReturnValue.create('ReturnValue')
    returnValue.value = value
    return returnValue
end

return ReturnValue