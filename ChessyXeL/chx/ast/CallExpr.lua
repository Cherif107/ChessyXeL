local FieldStatus = require 'ChessyXeL.FieldStatus'
local Expr = require 'ChessyXeL.chx.ast.Expr'

---@class chx.ast.CallExpr : chx.ast.Expr
local CallExpr = Expr.extend 'CallExpr'

CallExpr.args = FieldStatus.PUBLIC('default', 'default', nil)
CallExpr.caller = FieldStatus.PUBLIC('default', 'default', nil)
CallExpr.new = function (arguments, caller)
    local callExpr = CallExpr.create('CallExpr')
    callExpr.args = arguments
    callExpr.caller = caller
    return callExpr
end

return CallExpr