local FieldStatus = require 'ChessyXeL.FieldStatus'
local Stmt = require 'ChessyXeL.chx.ast.Stmt'

---@class chx.ast.SwitchCase : chx.ast.Stmt
local SwitchCase = Stmt.extend 'SwitchCase'

SwitchCase.body = FieldStatus.PUBLIC('default', 'default', nil)
SwitchCase.value = FieldStatus.PUBLIC('default', 'default', nil)
SwitchCase.new = function (value, body)
    local case = SwitchCase.create('SwitchCase')
    case.body = body
    case.value = value
    return case
end

return SwitchCase