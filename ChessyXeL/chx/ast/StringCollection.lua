local FieldStatus = require 'ChessyXeL.FieldStatus'
local Expr = require 'ChessyXeL.chx.ast.Expr'

---@class chx.ast.StringCollection : chx.ast.Expr
local StringCollection = Expr.extend 'StringCollection'

StringCollection.value = FieldStatus.PUBLIC('default', 'default', nil)
StringCollection.prefix = FieldStatus.PUBLIC('default', 'default', nil) -- ' or "
StringCollection.new = function (value, prefix)
    local stringCollection = StringCollection.create('StringCollection')
    stringCollection.value = value
    stringCollection.prefix = prefix
    return stringCollection
end

return StringCollection