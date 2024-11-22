local FieldStatus = require 'ChessyXeL.FieldStatus'
local Expr = require 'ChessyXeL.chx.ast.Expr'

---@class chx.ast.UnaryExpr : chx.ast.Expr
local UnaryExpr = Expr.extend 'UnaryExpr'

UnaryExpr.value = FieldStatus.PUBLIC('default', 'default', nil)
UnaryExpr.direction = FieldStatus.PUBLIC('default', 'default', nil)
UnaryExpr.identifier = FieldStatus.PUBLIC('default', 'default', nil)
UnaryExpr.assignment = FieldStatus.PUBLIC('default', 'default', nil)
UnaryExpr.new = function (value, identifier, direction, assignment)
    local unaryExpr = UnaryExpr.create('UnaryExpr')
    unaryExpr.value = value
    unaryExpr.identifier = identifier
    unaryExpr.direction = direction
    unaryExpr.assignment = assignment
    return unaryExpr
end

return UnaryExpr