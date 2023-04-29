local Enum = require 'ChessyXeL.Enum'
---@class interp.base.expr.Const 
local Const = Enum {
    CInt = {'v'},
    CFloat = {'f'},
    CString = {'s'}
}

return Const