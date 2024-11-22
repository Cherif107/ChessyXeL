local Class = require 'ChessyXeL.Class'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local Token = require 'ChessyXeL.chx.Token'
local TokenType = require 'ChessyXeL.chx.TokenType'

---@class chx.Lexer : Class
local Lexer = Class 'Lexer'

local function isAlphabetic(string)
    return string:upper() ~= string:lower()
end
local function isSkippable(string)
    return string == ' ' or string == '\n' or string == '\t' or string == '\r'
end

Lexer.tokenizeIdentifier = Method.PUBLIC(function (token, tokens, line, index, src)
    local identifier = ''
    while #src > 0 and isAlphabetic(src[1]) do
        identifier = identifier..table.remove(src, 1)
    end

    local reserved = Token.reservedKeywords[identifier]
    if reserved == nil then
        return Token(TokenType.Identifier, identifier, line, index)
    else
        return Token(reserved, identifier, line, index)
    end
end, true)
Lexer.tokenize = Method.PUBLIC(function (lexer, source, stopEof)
    local tokens = {}
    local src = {}
    for i = 1, #source do
        src[i] = source:sub(i, i)
    end

    local line = 1
    local index = 0
    while (#src > 0) do
        index = index + 1
        if src[1] == '(' then
            table.insert(tokens, Token(TokenType.OpenParen, table.remove(src, 1), line, index))
        elseif src[1] == ')' then
            table.insert(tokens, Token(TokenType.CloseParen, table.remove(src, 1), line, index))
        elseif src[1] == '{' then
            table.insert(tokens, Token(TokenType.OpenBrace, table.remove(src, 1), line, index))
        elseif src[1] == '}' then
            table.insert(tokens, Token(TokenType.CloseBrace, table.remove(src, 1), line, index))
        elseif (src[1] == '+' and src[2] == '+') or (src[1] == '-' and src[2] == '-') then
            table.insert(tokens, Token(TokenType.UnaryOperator, table.remove(src, 1)..table.remove(src, 1), line, index))
        elseif src[1] == '+' or src[1] == '-' or src[1] == '*' or src[1] == '/' or src[1] == '%' then
            local kind = TokenType.BinaryOperator
            local operator = table.remove(src, 1)
            if src[1] == '=' then
                kind = TokenType.AssignmentOperator
                operator = operator..table.remove(src, 1)
            end
            table.insert(tokens, Token(kind, operator, operator, index))
        elseif src[1] == '!' then
            table.remove(src, 1)
            if src[1] == '=' then
                table.remove(src, 1)
                table.insert(tokens, Token(TokenType.NotEqual, '!=', line, index))
            else
                table.insert(tokens, Token(TokenType.BinaryOperator, '!', line, index))
            end
        elseif src[1] == '=' then
            table.remove(src, 1)
            if src[1] == '>' then
                table.remove(src, 1)
                table.insert(tokens, Token(TokenType.MapEquals, '=>', line, index))
            elseif src[1] == '=' then
                table.remove(src, 1)
                table.insert(tokens, Token(TokenType.DoubleEquals, '==', line, index))
            else
                table.insert(tokens, Token(TokenType.Equals, '=', line, index))
            end
        elseif src[1] == '&' and src[2] == '&' then
            table.insert(tokens, Token(TokenType.And, table.remove(src, 1)..table.remove(src, 1), line, index))
        elseif src[1] == '|' and src[2] == '|' then
            table.insert(tokens, Token(TokenType.Or, table.remove(src, 1)..table.remove(src, 1), line, index))
        elseif src[1] == ';' then
            table.insert(tokens, Token(TokenType.Semicolon, table.remove(src, 1), line, index))
        elseif src[1] == ':' then
            table.insert(tokens, Token(TokenType.Colon, table.remove(src, 1), line, index))
        elseif src[1] == ',' then
            table.insert(tokens, Token(TokenType.Comma, table.remove(src, 1), line, index))
        elseif src[1] == '.' then
            if src[2] == '.' and src[3] == '.' then
                table.insert(tokens, Token(TokenType.ThreeDots, table.remove(src, 1).. table.remove(src, 1).. table.remove(src, 1), line, index))
            else
                table.insert(tokens, Token(TokenType.Dot, table.remove(src, 1), line, index))
            end
        elseif src[1] == '?' then
            table.insert(tokens, Token(TokenType.QuestionMark, table.remove(src, 1), line, index))
        elseif src[1] == "'" or src[1] == '"' then
            table.insert(tokens, Token(src[1] == "'" and TokenType.StringApostrophe or TokenType.StringQuote, table.remove(src, 1), line, index))
            local stringValue = ''
            
            local ifCheck 
            if src[1] == "'" then ifCheck = src[1] ~= '\n' and src[1] ~= "'" else ifCheck = src[1] ~= '"' end
            local prefix = src[1]

            local stringVal = {}
            local expression

            while (ifCheck) do
                local newStr = table.remove(src, 1)
                if newStr == '$' then
                    if not isAlphabetic(src[1]) and src[1] ~= '{'  then
                        if src[1] == '$' then
                            newStr = '$'
                        else
                            newStr = '$'..src[1]
                        end
                        stringValue = stringValue..tostring(newStr)
                    else
                        table.insert(stringVal, {stringValue, 'string'})
                        if src[1] == '{' then
                            table.remove(src, 1)
                            local expr = ''
                            while src[1] ~= '}' do
                                if src[1] == prefix then
                                    error('Unterminated String.')
                                end
                                expr = expr..table.remove(src, 1)
                            end
                            
                            table.remove(src, 1) -- remove the }
                            expression = lexer.tokenize(expr, true)
                            table.insert(stringVal, {'', 'expression'})
                        else
                            table.insert(stringVal, {lexer.tokenizeIdentifier(tokens, line, index, src), 'identifier'})
                        end
                        
                        stringValue = ''
                    end
                else
                    stringValue = stringValue..tostring(newStr)
                end
                if src[1] == "'" then ifCheck = src[1] ~= '\n' and src[1] ~= "'" else ifCheck = src[1] ~= '"' end
            end
            table.insert(stringVal, {stringValue, 'string'})
            table.insert(tokens, Token(TokenType.String, stringVal, line, index))
            if expression then
                for i = 1, #expression do
                    table.insert(tokens, expression[i])
                end
                table.insert(tokens, Token(TokenType.CloseBrace, '}', line, index)) -- add back the } we removed earlier
            end
            table.insert(tokens, Token(src[1] == "'" and TokenType.StringApostrophe or TokenType.StringQuote, table.remove(src, 1), line, index))

            -- this made me confused because of the $ support
        elseif src[1] == '>' then
            table.remove(src, 1)
            if src[1] == '=' then
                table.remove(src, 1)
                table.insert(tokens, Token(TokenType.BiggerEquals, '>=', line, index))
            else
                table.insert(tokens, Token(TokenType.Bigger, '>', line, index))
            end
        elseif src[1] == '<' then
            table.remove(src, 1)
            if src[1] == '=' then
                table.remove(src, 1)
                table.insert(tokens, Token(TokenType.SmallerEquals, '<=', line, index))
            else
                table.insert(tokens, Token(TokenType.Smaller, '<', line, index))
            end
        else
            if tonumber(src[1]) ~= nil then
                local number = ''
                while #src > 0 and tonumber(src[1]) ~= nil do
                    number = number..table.remove(src, 1)
                end

                table.insert(tokens, Token(TokenType.Number, number, line, index))
            elseif isAlphabetic(src[1]) then
                table.insert(tokens, lexer.tokenizeIdentifier(tokens, line, index, src))
            elseif isSkippable(src[1]) then
                if src[1] == '\n' then
                    line = line + 1
                    index = 0
                end
                table.remove(src, 1)
            else
                error('Unexpected Token: '..src[1])
                table.remove(src, 1)
            end
        end
    end

    if not stopEof then -- added this for ${} support in strings
        table.insert(tokens, Token(TokenType.EOF, 'EndOfFile', line, index))
    end
    return tokens
end, true)

return Lexer