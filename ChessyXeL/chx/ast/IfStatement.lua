local FieldStatus = require 'ChessyXeL.FieldStatus'
local Stmt = require 'ChessyXeL.chx.ast.Stmt'

---@class chx.ast.IfStatement : chx.ast.Stmt
local IfStatement = Stmt.extend 'IfStatement'

IfStatement.body = FieldStatus.PUBLIC('default', 'default', nil)
IfStatement.condition = FieldStatus.PUBLIC('default', 'default', nil)
IfStatement.elseBody = FieldStatus.PUBLIC('default', 'default', nil)
IfStatement.new = function (condition, body, elseBody)
    local statement = IfStatement.create('IfStatement')
    statement.body = body
    statement.condition = condition
    statement.elseBody = elseBody
    return statement
end

return IfStatement