local FieldStatus = require 'ChessyXeL.FieldStatus'
local Stmt = require 'ChessyXeL.chx.ast.Stmt'

---@class chx.ast.RegularExpression : chx.ast.Stmt
local RegularExpression = Stmt.extend 'RegularExpression'

RegularExpression.body = FieldStatus.PUBLIC('default', 'default', nil)
RegularExpression.new = function (body)
    local expr = RegularExpression.create('RegularExpression')
    expr.body = body
    return expr
end

return RegularExpression