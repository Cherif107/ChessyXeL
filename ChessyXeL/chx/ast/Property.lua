local FieldStatus = require 'ChessyXeL.FieldStatus'
local Expr = require 'ChessyXeL.chx.ast.Expr'

---@class chx.ast.Property : chx.ast.Expr
local Property = Expr.extend 'Property'

Property.key = FieldStatus.PUBLIC('default', 'default', nil)
Property.value = FieldStatus.PUBLIC('default', 'default', nil)
Property.new = function (key, value)
    local property = Property.create('Property')
    property.key = key
    property.value = value
    return property
end

return Property