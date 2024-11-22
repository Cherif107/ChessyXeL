local FieldStatus = require 'ChessyXeL.FieldStatus'
local Expr = require 'ChessyXeL.chx.ast.Expr'

---@class chx.ast.MemberExpr : chx.ast.Expr
local MemberExpr = Expr.extend 'MemberExpr'

MemberExpr.object = FieldStatus.PUBLIC('default', 'default', nil)
MemberExpr.property = FieldStatus.PUBLIC('default', 'default', nil)
MemberExpr.computed = FieldStatus.PUBLIC('default', 'default', false)
MemberExpr.new = function (object, property, computed)
    local memberExpr = MemberExpr.create('MemberExpr')
    memberExpr.object = object
    memberExpr.property = property
    memberExpr.computed = computed
    return memberExpr
end

return MemberExpr