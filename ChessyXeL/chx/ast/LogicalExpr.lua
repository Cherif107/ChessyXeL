local FieldStatus = require 'ChessyXeL.FieldStatus'
local Expr = require 'ChessyXeL.chx.ast.Expr'

---@class chx.ast.LogicalExpr : chx.ast.Expr
local LogicalExpr = Expr.extend 'LogicalExpr'

LogicalExpr.left = FieldStatus.PUBLIC('default', 'default', nil)
LogicalExpr.right = FieldStatus.PUBLIC('default', 'default', nil)
LogicalExpr.operator = FieldStatus.PUBLIC('default', 'default', nil)
LogicalExpr.new = function (left, right, operator)
    local logicalExpr = LogicalExpr.create('LogicalExpr')
    logicalExpr.left = left
    logicalExpr.right = right
    logicalExpr.operator = operator
    return logicalExpr
end

return LogicalExpr