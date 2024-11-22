local FieldStatus = require 'ChessyXeL.FieldStatus'
local Expr = require 'ChessyXeL.chx.ast.Expr'

---@class chx.ast.AssignmentExpr : chx.ast.Expr
local AssignmentExpr = Expr.extend 'AssignmentExpr'

AssignmentExpr.assign = FieldStatus.PUBLIC('default', 'default', nil)
AssignmentExpr.value = FieldStatus.PUBLIC('default', 'default', nil)
AssignmentExpr.assignmentOp = FieldStatus.PUBLIC('default', 'default', nil)
AssignmentExpr.op = FieldStatus.PUBLIC('default', 'default', nil)
AssignmentExpr.new = function (assign, value, assignmentOp, op)
    local assignmentExpr = AssignmentExpr.create('AssignmentExpr')
    assignmentExpr.assign = assign
    assignmentExpr.value = value
    assignmentExpr.assignmentOp = assignmentOp
    assignmentExpr.op = op
    return assignmentExpr
end

return AssignmentExpr