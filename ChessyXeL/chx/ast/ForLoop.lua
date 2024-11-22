local FieldStatus = require 'ChessyXeL.FieldStatus'
local Stmt = require 'ChessyXeL.chx.ast.Stmt'

---@class chx.ast.ForLoop : chx.ast.Stmt
local ForLoop = Stmt.extend 'ForLoop'

ForLoop.body = FieldStatus.PUBLIC('default', 'default', nil)
ForLoop.identifier = FieldStatus.PUBLIC('default', 'default', nil)
ForLoop.expression = FieldStatus.PUBLIC('default', 'default', nil)
ForLoop.new = function (identifier, expression, body)
    local loop = ForLoop.create('ForLoop')
    loop.body = body
    loop.identifier = identifier
    loop.expression = expression
    return loop
end

return ForLoop