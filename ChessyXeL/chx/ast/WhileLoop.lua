local FieldStatus = require 'ChessyXeL.FieldStatus'
local Stmt = require 'ChessyXeL.chx.ast.Stmt'

---@class chx.ast.WhileLoop : chx.ast.Stmt
local WhileLoop = Stmt.extend 'WhileLoop'

WhileLoop.body = FieldStatus.PUBLIC('default', 'default', nil)
WhileLoop.condition = FieldStatus.PUBLIC('default', 'default', nil)
WhileLoop.new = function (condition, body)
    local loop = WhileLoop.create('WhileLoop')
    loop.body = body
    loop.condition = condition
    return loop
end

return WhileLoop