local Class = require 'ChessyXeL.Class'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local TokenType = require 'ChessyXeL.chx.TokenType'
require 'ChessyXeL.util.StringUtil'

---@class chx.Token : Class
local Token = Class 'Token'

Token.value = FieldStatus.PUBLIC('default', 'default', nil)
Token.type = FieldStatus.PUBLIC('default', 'default', nil)
Token.line = FieldStatus.PUBLIC('default', 'default', 1)
Token.index = FieldStatus.PUBLIC('default', 'default', 0)

Token.reservedKeywords = FieldStatus.PUBLIC('default', 'never', {
    var = TokenType.Var,
    final = TokenType.Final,
    ['function'] = TokenType.Function,
    ['return'] = TokenType.Return,
    ['and'] = TokenType.And,
    ['or'] = TokenType.Or,
    ['if'] = TokenType.If,
    ['else'] = TokenType.Else,
    ['for'] = TokenType.For,
    ['in'] = TokenType.In,
    ['while'] = TokenType.While,
    switch = TokenType.Switch,
    default = TokenType.Default,
    case = TokenType.Case
}, true)
Token.new = function (type, value, line, index)
    local token = Token.create()
    token.type = type
    token.value = value
    token.line = line or 1
    token.index = index or 0
    return token
end

return Token