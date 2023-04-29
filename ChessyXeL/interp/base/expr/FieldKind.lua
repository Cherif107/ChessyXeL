local Enum = require 'ChessyXeL.Enum'
---@class interp.base.expr.FieldKind : Enum
local FieldKind = Enum {
    KFunction = {'f'},
    KVar = {'v'}
}

return FieldKind