local Enum = require 'ChessyXeL.Enum'
---@class interp.base.expr.ModuleDecl : Enum
local ModuleDecl = Enum {
    DPackage = {'path'},
    DImport = {'path', 'everything', 'asIdent'},
    DClass = {'c'},
    DTypedef = {'c'}
}

return ModuleDecl