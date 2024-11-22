local Class = require 'ChessyXeL.Class'
local FieldStatus = require 'ChessyXeL.FieldStatus'

---@class chx.ast.Stmt : Class
local Stmt = Class 'Stmt'

Stmt.kind = FieldStatus.PUBLIC('default', 'default', nil)
Stmt.new = function (kind)
    local stmt = Stmt.create()
    stmt.kind = kind
    return stmt
end

return Stmt