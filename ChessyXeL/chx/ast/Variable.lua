local FieldStatus = require 'ChessyXeL.FieldStatus'
local Class = require 'ChessyXeL.Class'

---@class chx.ast.Variable : Class
local Variable = Class 'Variable'

Variable.type = FieldStatus.PUBLIC('default', 'default', nil)
Variable.value = FieldStatus.PUBLIC('default', 'default', nil)
Variable.new = function (value, type)
    local var = Variable.create()
    var.type = type
    var.value = value
    return var
end

return Variable