local FieldStatus = require 'ChessyXeL.FieldStatus'
local Expr = require 'ChessyXeL.chx.ast.Expr'

---@class chx.ast.StringLiteral : chx.ast.Expr
local StringLiteral = Expr.extend 'StringLiteral'

StringLiteral.value = FieldStatus.PUBLIC('default', 'default', nil)
StringLiteral.prefix = FieldStatus.PUBLIC('default', 'default', nil) -- ' or "
StringLiteral.new = function (value, prefix)
    local stringLiteral = StringLiteral.create('StringLiteral')
    stringLiteral.value = value
    stringLiteral.prefix = prefix
    return stringLiteral
end

return StringLiteral