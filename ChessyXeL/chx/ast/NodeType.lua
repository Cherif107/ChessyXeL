local Enum = require 'ChessyXeL.Enum'

---@class chx.NodeType : Enum
local NodeType = Enum {
    'Program',
    'VarDeclaration',
    'AssignmentExpr',

    'NumericLiteral',
    'Identifier',
    'BinaryExpr',
    'ObjectLiteral',
    'Property',

    'MemberExpr',
    'CallExpr',
    -- 'UnaryExpr',
    'FunctionDeclaration'
}

return NodeType