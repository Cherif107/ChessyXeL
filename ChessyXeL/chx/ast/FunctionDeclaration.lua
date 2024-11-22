local FieldStatus = require 'ChessyXeL.FieldStatus'
local Stmt = require 'ChessyXeL.chx.ast.Stmt'

---@class chx.ast.FunctionDeclaration : chx.ast.Stmt
local FunctionDeclaration = Stmt.extend 'FunctionDeclaration'

FunctionDeclaration.unnamed = FieldStatus.PUBLIC('default', 'default', false)
FunctionDeclaration.parameters = FieldStatus.PUBLIC('default', 'default', nil)
FunctionDeclaration.optionalParameters = FieldStatus.PUBLIC('default', 'default', nil)
FunctionDeclaration.name = FieldStatus.PUBLIC('default', 'default', nil)
FunctionDeclaration.body = FieldStatus.PUBLIC('default', 'default', nil)
FunctionDeclaration.inline = FieldStatus.PUBLIC('default', 'default', false)
FunctionDeclaration.static = FieldStatus.PUBLIC('default', 'default', false)
FunctionDeclaration.new = function (parameters, name, body, inline, static, unnamed, optionalParameters)
    local func = FunctionDeclaration.create('FunctionDeclaration')
    func.parameters = parameters
    func.name = name
    func.body = body
    func.inline = inline or false
    func.static = static or false
    func.unnamed = unnamed or false
    func.optionalParameters = optionalParameters
    return func
end

return FunctionDeclaration