local FieldStatus = require 'ChessyXeL.FieldStatus'
local Stmt = require 'ChessyXeL.chx.ast.Stmt'

---@class chx.ast.VarDeclaration : chx.ast.Stmt
local VarDeclaration = Stmt.extend 'VarDeclaration'

VarDeclaration.final = FieldStatus.PUBLIC('default', 'default', false)
VarDeclaration.identifier = FieldStatus.PUBLIC('default', 'default', nil)
VarDeclaration.value = FieldStatus.PUBLIC('default', 'default', nil)
VarDeclaration.variableType = FieldStatus.PUBLIC('default', 'default', nil)
VarDeclaration.new = function (identifier, final, value, type)
    local var = VarDeclaration.create('VarDeclaration')
    var.identifier = identifier
    var.final = final
    var.value = value
    var.variableType = type
    return var
end

return VarDeclaration