local Enum = require 'ChessyXeL.Enum'
---@class interp.base.expr.CType : Enum
local CType = Enum {
    CTPath = {'path', 'params'},
    CTFun = {'args', 'ret'},
    CTAnon = {'fields'},
    CTParent = {'t'},
    CTOpt = {'t'},
    CTNamed = {'n', 't'}
}

return CType