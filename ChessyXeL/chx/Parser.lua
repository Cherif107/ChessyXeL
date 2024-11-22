local Class = require 'ChessyXeL.Class'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local VarDeclaration = require 'ChessyXeL.chx.ast.VarDeclaration'
local AssignmentExpr = require 'ChessyXeL.chx.ast.AssignmentExpr'
local ObjectLiteral  = require 'ChessyXeL.chx.ast.ObjectLiteral'
local Property       = require 'ChessyXeL.chx.ast.Property'
local CallExpr       = require 'ChessyXeL.chx.ast.CallExpr'
local MemberExpr     = require 'ChessyXeL.chx.ast.MemberExpr'
local FunctionDeclaration = require 'ChessyXeL.chx.ast.FunctionDeclaration'
local ReturnValue         = require 'ChessyXeL.chx.ast.ReturnValue'
local UnaryExpr            = require 'ChessyXeL.chx.ast.UnaryExpr'
local StringCollection        = require 'ChessyXeL.chx.ast.StringCollection'
local StringLiteral        = require 'ChessyXeL.chx.ast.StringLiteral'
local RegularExpression    = require 'ChessyXeL.chx.ast.RegularExpression'
local LogicalExpr          = require 'ChessyXeL.chx.ast.LogicalExpr'
local IfStatement          = require 'ChessyXeL.chx.ast.IfStatement'
local IntIterator          = require 'ChessyXeL.chx.ast.IntIterator'
local ForLoop              = require 'ChessyXeL.chx.ast.ForLoop'
local WhileLoop            = require 'ChessyXeL.chx.ast.WhileLoop'
local SwitchCase           = require 'ChessyXeL.chx.ast.SwitchCase'

local Token = require 'ChessyXeL.chx.Token'
local TokenType = require 'ChessyXeL.chx.TokenType'
local Lexer = require 'ChessyXeL.chx.Lexer'

local Stmt = require 'ChessyXeL.chx.ast.Stmt'
local Program = require 'ChessyXeL.chx.ast.Program'
local Expr = require 'ChessyXeL.chx.ast.Expr'
local BinaryExpr = require 'ChessyXeL.chx.ast.BinaryExpr'
local NumericLiteral = require 'ChessyXeL.chx.ast.NumericLiteral'
local Identifier = require 'ChessyXeL.chx.ast.Identifier'
local Enum = require 'ChessyXeL.Enum'

local switch = function (def, cases)
    if cases[def] then return cases[def]() end
    if cases.default then return cases.default() end
end

---@class chx.Parser : Class
local Parser = Class 'Parser'

Parser.tokens = FieldStatus.PUBLIC('default', 'default', nil)
Parser.not_eof = Method.PUBLIC(function (parser)
    return parser.tokens[1].type ~= TokenType.EOF
end)
Parser.at = Method.PUBLIC(function (parser)
    local tok = parser.tokens[1]
    if tok.type == TokenType.AssignmentOperator then
        -- error('euh', 3)
    end
    return tok
end)
Parser.eat = Method.PUBLIC(function (parser)
    return table.remove(parser.tokens, 1)
end)
Parser.expect = Method.PUBLIC(function (parser, type, err)
    local prev = table.remove(parser.tokens, 1)
    if not prev or prev.type ~= type then
        debugPrint('Interp:'..prev.line..': '..prev.index..' - '..err.. ' - Expected: '..tostring(type))
        error('End of compilation.', 0)
    end
    return prev
end)

Parser.parse_binary_expr = Method.PUBLIC(function (parser, insideArgs)
    local op = parser.eat().value
    
    if op == '-' then
        return BinaryExpr(NumericLiteral(-1), parser.parse_primary_expr(insideArgs), '*')
    elseif op == '!' then
        return BinaryExpr(nil, parser.parse_expr(insideArgs), '!')
    end

    error('Interp:'..parser.at().line..': '..parser.at().index..' - Unexpected Token `'..tostring(op)..'`', 3)
    error('End of compilation.', 0)
end)
Parser.parse_unary_expr = Method.PUBLIC(function (parser, identifier, operator, direction, insideArgs)
    return UnaryExpr(operator, identifier, direction, AssignmentExpr(identifier, BinaryExpr(identifier, NumericLiteral(1), operator == '++' and '+' or '-')))
end)
Parser.parse_string_literal = Method.PUBLIC(function (parser, insideArgs)
    local prefix = parser.eat()
    local stringValue = parser.eat()
    local string = Identifier('null')
    if stringValue.type == TokenType.String then
        for i = 1, #stringValue.value do
            if stringValue.value[i][2] == 'identifier' then
                stringValue.value[i][1] = Identifier(stringValue.value[i][1].value)
            elseif stringValue.value[i][2] == 'expression' then
                local expr = RegularExpression({})
                while parser.at().type ~= TokenType.CloseBrace and parser.at().type ~= TokenType.StringApostrophe do
                    table.insert(expr.body, parser.parse_expr(true))
                end
                parser.eat()
                    
                stringValue.value[i][1] = expr
            else
                stringValue.value[i][1] = StringLiteral(stringValue.value[i][1])
            end
        end
        string = StringCollection(stringValue.value)
    end

    parser.expect(prefix.type, 'error in string closing.')

    return string
end)
Parser.parse_primary_expr = Method.PUBLIC(function (parser, insideArgs)
    local tk = parser.at().type

    return Enum.switch(tk, {
        [TokenType.UnaryOperator] = function ()
            local op = parser.eat().value
            return parser.parse_unary_expr(parser.parse_call_member_expr(insideArgs), op, 'left', insideArgs) -- i was questioning why it didn't work properly at the first place, until i found out that i put parse_object_expr instad of primary, im stupid fr ong
        end,
        [TokenType.Identifier] = function ()
            local identifier = Identifier(parser.eat().value)
            return identifier
        end,
        [TokenType.Number] = function ()
            return NumericLiteral(tonumber(parser.eat().value))
        end,
        [TokenType.StringApostrophe] = function ()
            return parser.parse_string_literal(insideArgs)
        end,
        [TokenType.StringQuote] = function ()
            return parser.parse_string_literal(insideArgs)
        end,
        [TokenType.BinaryOperator] = function ()
            return parser.parse_binary_expr(insideArgs)
        end,
        [TokenType.OpenParen] = function ()
            parser.eat()
            local value = parser.parse_expr(true)
            parser.expect(TokenType.CloseParen, 'Unexpected token inside parenthesis.')
            return value
        end,
        default = function ()
            -- debugPrint(tostring(parser.eat().type))
            -- debugPrint(tostring(parser.eat().type))
            debugPrint('Interp:'..parser.at().line..': '..parser.at().index..' - Unexpected Token `'..tostring(parser.at().value)..'`')
            error('End of compilation.', 0)
        end
    })
end)

Parser.parse_member_expr_custom = Method.PUBLIC(function (parser, insideArgs, object)
    while (parser.at().type == TokenType.Dot) do
        local op = parser.eat()
        local property = parser.parse_primary_expr(insideArgs)

        if property.kind ~= 'Identifier' then
            debugPrint('Interp:'..parser.at().line..': '..parser.at().index..' - Invalid index identifier.')
            error('End of compilation.', 0)
        end

        object = MemberExpr(object, property, false)
    end

    if parser.at().type == TokenType.UnaryOperator then
        return parser.parse_unary_expr(object, parser.eat().value, 'right', insideArgs)
    end

    return object
end)
Parser.parse_member_expr = Method.PUBLIC(function (parser, insideArgs)
    local object = parser.parse_primary_expr(insideArgs)
    local property

    while (parser.at().type == TokenType.Dot) do
        local op = parser.eat()
        property = parser.parse_primary_expr(insideArgs)

        if property.kind ~= 'Identifier' then
            debugPrint('Interp:'..parser.at().line..': '..parser.at().index..' - Invalid index identifier.')
            error('End of compilation.', 0)
        end

        object = MemberExpr(object, property, false)
    end

    if parser.at().type == TokenType.UnaryOperator then
        return parser.parse_unary_expr(object, parser.eat().value, 'right', insideArgs)
    end

    return object
end)

Parser.parse_param = Method.PUBLIC(function (parser)
    local optional = parser.at().type == TokenType.QuestionMark
    if optional then
        parser.eat()
    end
    local identifier = parser.parse_primary_expr()
    if identifier.kind ~= 'Identifier' then
        debugPrint('Interp:'..parser.at().line..': '..parser.at().index..' - Expected argument Identifier.')
        error('End of compilation.', 0)
    end
    local defaultValue

    if parser.at().type == TokenType.Equals then
        parser.eat()
        optional = true
        if parser.at().type == TokenType.Comma or parser.at().type == TokenType.CloseParen then
            debugPrint('Interp:'..parser.at().line..': '..parser.at().index..' - Expected value after `=`.')
            error('End of compilation.', 0)
        end
        defaultValue = parser.parse_expr(true)
    end

    return {identifier, optional, defaultValue}
end)
Parser.parse_parameter_list = Method.PUBLIC(function (parser)
    local arg, optional, defaultValue = unpack(parser.parse_param())
    local args = {arg}
    local optionals = {}
    if optional then
        optionals[arg] = defaultValue or Identifier('null')
    end
    
    while parser.at().type == TokenType.Comma and parser.eat() do
        local arg, optional, defaultValue = unpack(parser.parse_param())
        table.insert(args, arg)
        if optional then
            optionals[arg] = defaultValue or Identifier('null')
        end
    end

    return {args, optionals}
end)
Parser.parse_params = Method.PUBLIC(function (parser)
    parser.expect(TokenType.OpenParen, "Expected `(`")

    local ret = {{}, {}}
    if parser.at().type ~= TokenType.CloseParen then -- idfk why i have to add this
        local args = (parser.at().type == TokenType.CloseParen and {} or nil)
        local optArgs = parser.parse_parameter_list()
        if not args then
            args = optArgs[1]
        end
        
        ret = {args, optArgs[2]}
    end
    parser.expect(TokenType.CloseParen, "Expected `)`")

    return ret
end)
Parser.parse_arguments_list = Method.PUBLIC(function (parser)
    local args = {(parser.at().type == TokenType.Function and parser.parse_fn_declaration(true) or parser.parse_expr(true))}

    while parser.at().type == TokenType.Comma and parser.eat() do
        if parser.at().type == TokenType.Function then
            table.insert(args, parser.parse_fn_declaration(true))
        else
            table.insert(args, parser.parse_expr(true))
        end
    end

    return args
end)
Parser.parse_args = Method.PUBLIC(function (parser)
    parser.expect(TokenType.OpenParen, "Expected `(`")
    local args = (parser.at().type == TokenType.CloseParen and {} or parser.parse_arguments_list())
    parser.expect(TokenType.CloseParen, "Expected `)`")

    return args
end)
Parser.parse_call_expr = Method.PUBLIC(function (parser, caller)
    local call_expr = CallExpr(parser.parse_args(), caller)

    if parser.at().type == TokenType.OpenParen then
        call_expr = parser.parse_call_expr(call_expr)
    end

    if parser.at().type == TokenType.Dot then
        return parser.parse_member_expr_custom(false, call_expr)
    end

    return call_expr
end)
Parser.parse_call_member_expr = Method.PUBLIC(function (parser, insideArgs)
    local member = parser.parse_member_expr(insideArgs)

    if parser.at().type == TokenType.OpenParen then
        return parser.parse_call_expr(member, insideArgs)
    end

    return member
end)
Parser.parse_multiplicative_expr = Method.PUBLIC(function (parser, insideArgs)
    local left = parser.parse_call_member_expr(insideArgs)

    while (parser.at().value == "/" or parser.at().value == "*" or parser.at().value == '%') do
        local operator = parser.eat().value
        local right = parser.parse_call_member_expr(insideArgs)
        left = BinaryExpr(left, right, operator)
    end

    return left
end)
Parser.parse_additive_expr = Method.PUBLIC(function (parser, insideArgs)
    local left = parser.parse_multiplicative_expr(insideArgs)

    while (parser.at().value == "+" or parser.at().value == "-") do
        local operator = parser.eat().value
        local right = parser.parse_multiplicative_expr()
        left = BinaryExpr(left, right, operator)
    end

    return left
end)

Parser.parse_compare_expr = Method.PUBLIC(function (parser, insideArgs)
    local left = parser.parse_additive_expr(insideArgs)

    local op = parser.at().value
    if (op == ">" or op == "<" or op == '==' or op == '>=' or op == '<=' or op == '!=') then
        local operator = parser.eat().value
        local right = parser.parse_additive_expr(insideArgs)
        left = BinaryExpr(left, right, operator)
    end

    return left
end)

Parser.parse_logical_expr = Method.PUBLIC(function (parser, insideArgs)
    local left = parser.parse_compare_expr(insideArgs)

    local op = parser.at().value
    if (op == '||' or op == '&&' or op == 'and' or op == 'or') then
        local operator = parser.eat().value
        local right = parser.parse_logical_expr(insideArgs)
        left = LogicalExpr(left, right, operator)
    end

    return left
end)

Parser.parse_expr = Method.PUBLIC(function (parser, insideFuncArgs, insideObject)
    return parser.parse_assignment_expr(insideFuncArgs, false, insideObject)
end)
Parser.parse_object_expr = Method.PUBLIC(function (parser, insideArgs)
    if parser.at().type ~= TokenType.OpenBrace then
        return parser.parse_logical_expr(insideArgs)
    end

    parser.eat()
    local properties = {}

    while (parser.not_eof() and parser.at().type ~= TokenType.CloseBrace) do
        local key = parser.expect(TokenType.Identifier, 'Expected field in Anonymous Object.').value
        if parser.at().type == TokenType.Comma or parser.at().type == TokenType.CloseBrace then
            parser.expect(TokenType.Colon, 'field `'..key..'` Must have a value - Missing `:` while declaring field in Anonymous Object')
        end

        parser.expect(TokenType.Colon, 'Missing colon while declaring field `'..key..'` in Anonymous Object.')
        local value = parser.parse_expr(false, true)

        table.insert(properties, Property(key, value))
        if parser.at().type ~= TokenType.CloseBrace then
            parser.expect(TokenType.Comma, 'Expected `,` or `}`')
        end
    end

    parser.expect(TokenType.CloseBrace, 'Expected }')
    return ObjectLiteral(properties)
end)
Parser.parse_iterator_expr = Method.PUBLIC(function(parser, insideFuncArgs)
    local left = parser.parse_object_expr(insideFuncArgs)

    if parser.at().type == TokenType.ThreeDots then
        parser.eat()
        local right = parser.parse_primary_expr(insideFuncArgs)
        return IntIterator(left, right)
    end

    return left
end)
Parser.parse_assignment_expr = Method.PUBLIC(function (parser, insideFuncArgs, insideAssignmentExpr, insideObject)
    local left = parser.parse_iterator_expr(insideFuncArgs)

    local isAssOp = parser.at().type == TokenType.AssignmentOperator
    if parser.at().type == TokenType.Equals or isAssOp then
        local op = parser.eat()
        local value
        if parser.at().type == TokenType.Function then
            value = parser.parse_fn_declaration(true)
        else
            value = parser.parse_assignment_expr(insideFuncArgs, true)
        end
        
        left = AssignmentExpr(left, value, isAssOp, op.value:sub(1, 1))
    end

    if not insideFuncArgs and not insideAssignmentExpr and not insideObject then
        -- error ('WOOOOOOO A EUUUUU', 6)
        parser.expect(TokenType.Semicolon, 'Expected ;')
    end

    return left
end)
Parser.parse_var_declaration = Method.PUBLIC(function (parser)
    local isFinal = parser.eat().type == TokenType.Final
    local identifier = parser.expect(TokenType.Identifier, 'Expected variable name').value

    local type
    if parser.at().type == TokenType.Colon then
        parser.eat()
        type = parser.expect(TokenType.Identifier, 'Expected type').value
    end
    if parser.at().type == TokenType.Semicolon then
        parser.eat()
        if isFinal then
            debugPrint('Interp:'..parser.at().line..': '..parser.at().index..' - Final variables must have a value.')
            error('End of compilation.', 0)
        end

        return VarDeclaration(identifier, false, nil)
    end
    parser.expect(TokenType.Equals, 'Expected `=` when assigning variable to a value.')

    if parser.at().type == TokenType.Function then
        return VarDeclaration(identifier, isFinal, parser.parse_fn_declaration(true), type)
    end
    return VarDeclaration(identifier, isFinal, parser.parse_expr(), type)
end)
Parser.parse_fn_declaration = Method.PUBLIC(function (parser, Unnamed)
    Unnamed = Unnamed or false
    parser.eat()

    local name
    if not Unnamed then
        name = parser.expect(TokenType.Identifier, 'Unnamed functions are not supported.').value
    end
    local params = {}
    local optionals = {}

    local optargs = parser.parse_params()
    local args, opts = optargs[1], optargs[2]

    for _, argument in pairs(args) do
        if argument.kind ~= 'Identifier' then
            error('Interp:'..parser.at().line..': '..parser.at().index..' - Unexpected type of parameter in function argument list.', 3)
            error('End of compilation.', 0)
        end
        params[_] = argument.symbol

        if opts[argument] then
            optionals[argument.symbol] = opts[argument]
        end
    end

    local hasBrace = parser.at().type == TokenType.OpenBrace
    if hasBrace then parser.eat() end

    local body = {}
    while (parser.at().type ~= TokenType.EOF and parser.at().type ~= TokenType.CloseBrace) do
        table.insert(body, parser.parse_stmt())
        
        if not hasBrace then
            break
        end
    end
    if hasBrace then
        parser.expect(TokenType.CloseBrace, 'Expected `}`')
    end
    -- hot mess alert
    return FunctionDeclaration(params, name, body, false, false, Unnamed, optionals)
end)
Parser.parse_return = Method.PUBLIC(function (parser)
    parser.eat() -- eat the return token
    if parser.at().type == TokenType.Semicolon then
        parser.eat()
        return ReturnValue(nil)
    end
    return ReturnValue(parser.parse_stmt(false, true))
end)

Parser.parse_switch_case = Method.PUBLIC(function (parser)
    parser.eat()

    parser.expect(TokenType.OpenParen, 'Expected (')
    if parser.at().type == TokenType.CloseParen then
        debugPrint('Interp:'..parser.at().line..': '..parser.at().index..' - Expected Value inside switch case.')
        error('End of compilation.', 0)
    end
    local value = parser.parse_expr(true)
    parser.expect(TokenType.CloseParen, 'Expected )')
    parser.expect(TokenType.OpenBrace, 'Expected {')

    local body = {}
    while (parser.at().type ~= TokenType.EOF and parser.at().type ~= TokenType.CloseBrace) do
        local case
        if parser.at().type ~= TokenType.Default then
            parser.expect(TokenType.Case, 'Expected `case`.')
        else
            case = 'default'
            parser.eat()
        end
        if not case then
            case = parser.parse_primary_expr(true)
        end
        parser.expect(TokenType.Colon, 'Expected :.')

        body[case] = {}
        while parser.at().type ~= TokenType.Case and parser.at().type ~= TokenType.Default and parser.at().type ~= TokenType.CloseBrace do
            table.insert(body[case], parser.parse_stmt())
        end
    end
    parser.expect(TokenType.CloseBrace, 'Expected `}`')

    return SwitchCase(value, body)
end)

Parser.parse_if_statement = Method.PUBLIC(function (parser)
    parser.eat()

    parser.expect(TokenType.OpenParen, 'Expected (')
    if parser.at().type == TokenType.CloseParen then
        debugPrint('Interp:'..parser.at().line..': '..parser.at().index..' - Expected Condition inside if statment')
        error('End of compilation.', 0)
    end
    local condition = parser.parse_expr(true)
    parser.expect(TokenType.CloseParen, 'Expected )')
    

    local hasBrace = parser.at().type == TokenType.OpenBrace
    if hasBrace then parser.eat() end

    local body = {}
    while (parser.at().type ~= TokenType.EOF and parser.at().type ~= TokenType.CloseBrace) do
        table.insert(body, parser.parse_stmt())
        
        if not hasBrace then
            break
        end
    end
    if hasBrace then
        parser.expect(TokenType.CloseBrace, 'Expected `}`')
    end

    local elseBody = {}
    if parser.at().type == TokenType.Else then
        parser.eat()
        local hasBrace = parser.at().type == TokenType.OpenBrace
        if hasBrace then parser.eat() end
    
        while (parser.at().type ~= TokenType.EOF and parser.at().type ~= TokenType.CloseBrace) do
            table.insert(elseBody, parser.parse_stmt())
            
            if not hasBrace then
                break
            end
        end
        if hasBrace then
            parser.expect(TokenType.CloseBrace, 'Expected `}`')
        end
    end

    return IfStatement(condition, body, elseBody)
end)

Parser.parse_while_loop = Method.PUBLIC(function (parser)
    parser.eat()

    parser.expect(TokenType.OpenParen, 'Expected (')
    if parser.at().type == TokenType.CloseParen then
        debugPrint('Interp:'..parser.at().line..': '..parser.at().index..' - Expected Condition inside while loop')
        error('End of compilation.', 0)
    end
    local condition = parser.parse_expr(true)
    parser.expect(TokenType.CloseParen, 'Expected )')
    

    local hasBrace = parser.at().type == TokenType.OpenBrace
    if hasBrace then parser.eat() end

    local body = {}
    while (parser.at().type ~= TokenType.EOF and parser.at().type ~= TokenType.CloseBrace) do
        table.insert(body, parser.parse_stmt())
        
        if not hasBrace then
            break
        end
    end
    if hasBrace then
        parser.expect(TokenType.CloseBrace, 'Expected `}`')
    end

    return WhileLoop(condition, body)
end)

Parser.parse_for_loop = Method.PUBLIC(function (parser)
    parser.eat()

    parser.expect(TokenType.OpenParen, 'Expected (')
    if parser.at().type == TokenType.CloseParen then
        debugPrint('Interp:'..parser.at().line..': '..parser.at().index..' - Expected Header inside for loop')
        error('End of compilation.', 0)
    end
    local identifier = parser.parse_primary_expr(true)
    parser.expect(TokenType.In, 'Expected `in` `expr`')
    local expr = parser.parse_expr(true)
    parser.expect(TokenType.CloseParen, 'Expected )')
    

    local hasBrace = parser.at().type == TokenType.OpenBrace
    if hasBrace then parser.eat() end

    local body = {}
    while (parser.at().type ~= TokenType.EOF and parser.at().type ~= TokenType.CloseBrace) do
        table.insert(body, parser.parse_stmt())
        
        if not hasBrace then
            break
        end
    end
    if hasBrace then
        parser.expect(TokenType.CloseBrace, 'Expected `}`')
    end

    return ForLoop(identifier, expr, body)
end)


Parser.parse_stmt = Method.PUBLIC(function (parser, insideFuncArgs, inReturn)
    local at = parser.at().type
    local em = Enum.switch(at, {
        [TokenType.Var] = function ()
            return parser.parse_var_declaration()
        end,
        [TokenType.Final] = function ()
            return parser.parse_var_declaration()
        end,
        [TokenType.Function] = function ()
            return parser.parse_fn_declaration(inReturn)
        end,
        [TokenType.If] = function ()
            return parser.parse_if_statement(inReturn)
        end,
        [TokenType.Switch] = function ()
            return parser.parse_switch_case(inReturn)
        end,
        [TokenType.For] = function ()
            return parser.parse_for_loop(inReturn)
        end,
        [TokenType.While] = function ()
            return parser.parse_while_loop(inReturn)
        end,
        [TokenType.Return] = function ()
            return parser.parse_return()
        end,
        default = function()
            return parser.parse_expr(insideFuncArgs)
        end
    })
    return em
    -- return parser.parse_expr()
end)
Parser.produceAST = Method.PUBLIC(function (parser, source)
    parser.tokens = Lexer.tokenize(source)
    local program = Program({})

    while (parser.not_eof()) do
        table.insert(program.body, parser.parse_stmt())
    --     break
    end

    return program
end)

return Parser