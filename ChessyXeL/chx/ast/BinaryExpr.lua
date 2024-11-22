local FieldStatus = require 'ChessyXeL.FieldStatus'
local Expr = require 'ChessyXeL.chx.ast.Expr'

---@class chx.ast.BinaryExpr : chx.ast.Expr
local BinaryExpr = Expr.extend 'BinaryExpr'

BinaryExpr.left = FieldStatus.PUBLIC('default', 'default', nil)
BinaryExpr.right = FieldStatus.PUBLIC('default', 'default', nil)
BinaryExpr.operator = FieldStatus.PUBLIC('default', 'default', nil)
BinaryExpr.new = function (left, right, operator)
    local binaryExpr = BinaryExpr.create('BinaryExpr')
    binaryExpr.left = left
    binaryExpr.right = right
    binaryExpr.operator = operator
    return binaryExpr
end

return BinaryExpr