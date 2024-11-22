local FieldStatus = require 'ChessyXeL.FieldStatus'
local Expr = require 'ChessyXeL.chx.ast.Expr'

---@class chx.ast.Identifier : chx.ast.Expr
local Identifier = Expr.extend 'Identifier'

Identifier.symbol = FieldStatus.PUBLIC('default', 'default', nil)
Identifier.new = function (symbol)
    local identifier = Identifier.create('Identifier')
    identifier.symbol = symbol
    return identifier
end

return Identifier