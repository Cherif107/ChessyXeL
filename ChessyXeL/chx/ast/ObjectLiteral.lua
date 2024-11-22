local FieldStatus = require 'ChessyXeL.FieldStatus'
local Expr = require 'ChessyXeL.chx.ast.Expr'

---@class chx.ast.ObjectLiteral : chx.ast.Expr
local ObjectLiteral = Expr.extend 'ObjectLiteral'

ObjectLiteral.properties = FieldStatus.PUBLIC('default', 'default', nil)
ObjectLiteral.new = function (properties)
    local objectLiteral = ObjectLiteral.create('ObjectLiteral')
    objectLiteral.properties = properties
    return objectLiteral
end

return ObjectLiteral