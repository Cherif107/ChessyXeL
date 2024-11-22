local FieldStatus = require 'ChessyXeL.FieldStatus'
local Expr = require 'ChessyXeL.chx.ast.Expr'

---@class chx.ast.NumericLiteral : chx.ast.Expr
local NumericLiteral = Expr.extend 'NumericLiteral'

NumericLiteral.value = FieldStatus.PUBLIC('default', 'default', nil)
NumericLiteral.new = function (value)
    local numericLiteral = NumericLiteral.create('NumericLiteral')
    numericLiteral.value = value
    return numericLiteral
end

return NumericLiteral