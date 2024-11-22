local Enum = require 'ChessyXeL.Enum'

---@class chx.TokenType : Enum
local TokenType = Enum {
    'String',
    'Number',
    'Identifier',
    'Equals',
    'MapEquals',
    'OpenParen',
    'CloseParen',

    'BinaryOperator',
    'UnaryOperator',

    'Var',
    'Final',
    -- 'Static',
    'Inline',
    'Function',
    'Return',

    'Semicolon',
    'Comma',
    'Colon',
    'Dot',
    'QuestionMark',
    'ExclamationMark',
    'StringApostrophe',
    'StringQuote',
    'DollarSign',

    'AssignmentOperator',

    'Bigger',
    'Smaller',
    'DoubleEquals',
    'NotEqual',
    'BiggerEquals',
    'SmallerEquals',

    'And',
    'Or',

    'If',
    'Else',
    'For',
    'While',
    'Switch',
    'Case',
    'Default',
    'In',
    'ThreeDots',

    'OpenBrace',
    'CloseBrace',

    'EOF',
}

return TokenType