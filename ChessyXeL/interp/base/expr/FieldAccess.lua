local Enum = require 'ChessyXeL.Enum'
---@class interp.base.expr.FieldAccess : Enum
local FieldAccess = Enum {
    'APublic',
    'APrivate',
    'AInline',
    'AOverride',
    'AStatic',
    'AMacro'
}

return FieldAccess