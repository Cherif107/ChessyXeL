local FieldStatus = require 'ChessyXeL.FieldStatus'
local Stmt = require 'ChessyXeL.chx.ast.Stmt'

---@class chx.ast.Program : chx.ast.Stmt
local Program = Stmt.extend 'Program'

Program.body = FieldStatus.PUBLIC('default', 'default', nil)
Program.new = function (body)
    local program = Program.create('Program')
    program.body = body
    return program
end

return Program