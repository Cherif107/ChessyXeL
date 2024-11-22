local FieldStatus = require 'ChessyXeL.FieldStatus'
local Stmt = require 'ChessyXeL.chx.ast.Stmt'

---@class chx.ast.Expr : chx.ast.Stmt
local Expr = Stmt.extend 'Expr'

return Expr