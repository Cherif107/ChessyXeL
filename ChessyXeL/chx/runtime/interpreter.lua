local RuntimeVal = require 'ChessyXeL.chx.runtime.values.RuntimeVal'
local NullVal = require 'ChessyXeL.chx.runtime.values.NullVal'
local NumberVal = require 'ChessyXeL.chx.runtime.values.NumberVal'
local Identifier = require 'ChessyXeL.chx.ast.Identifier'
local VarDeclaration = require 'ChessyXeL.chx.ast.VarDeclaration'
local AssignmentExpr = require 'ChessyXeL.chx.ast.AssignmentExpr'
local ObjectLiteral  = require 'ChessyXeL.chx.ast.ObjectLiteral'
local ObjectVal      = require 'ChessyXeL.chx.runtime.values.ObjectVal'
local FunctionValue  = require 'ChessyXeL.chx.runtime.values.FunctionValue'
local environment    = require 'ChessyXeL.chx.runtime.environment'
local BooleanVal     = require 'ChessyXeL.chx.runtime.values.BooleanVal'
local StringVal      = require 'ChessyXeL.chx.runtime.values.StringVal'
local NativeFnValue      = require 'ChessyXeL.chx.runtime.values.NativeFnValue'
local IntIterator        = require 'ChessyXeL.chx.runtime.values.IntIterator'

local Stmt = require 'ChessyXeL.chx.ast.Stmt'
local NodeType = require 'ChessyXeL.chx.ast.NodeType'

local Enum = require 'ChessyXeL.Enum'
local Class = require 'ChessyXeL.Class'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'

local switch = function (def, cases)
    if cases[def] then return cases[def]() end
    if cases.default then return cases.default() end
end

---@class chx.runtime.interpreter : Class
local interpreter = Class 'interpreter'

local boolOPS = {'>', '<', '==', '<=', '>=', '!=', '!'}
for i = 1, #boolOPS do
    boolOPS[boolOPS[i]] = true
end
interpreter.eval_numeric_expr = Method.PUBLIC(function (interp, lhs, rhs, operator)
    local result
    if operator == '+' then
        result = lhs + rhs
    elseif operator == '-' then
        result = lhs - rhs
    elseif operator == '*' then
        result = lhs * rhs
    elseif operator == '/' then
        result = lhs / rhs
    elseif operator == '%' then
        result = lhs % rhs
    else
        result = lhs % rhs -- default
    end

    return result
end, true)
interpreter.eval_numeric_binary_expr = Method.PUBLIC(function (interp, lhs, rhs, operator)
    return NumberVal(interp.eval_numeric_expr(lhs.value, rhs.value, operator))
end, true)
interpreter.eval_string_binary_expr = Method.PUBLIC(function (interp, lhs, rhs, operator)
    local result
    if operator == '+' then
        result = tostring(lhs.value).. tostring(rhs.value)
    end

    return StringVal(result)
end, true)

interpreter.eval_bool_binary_expr = Method.PUBLIC(function (interp, lhs, rhs, operator)
    local result = false
    if operator == '>' then
        result = lhs.value > rhs.value
    elseif operator == '<' then
        result = lhs.value < rhs.value
    elseif operator == '==' then
        result = lhs.value == rhs.value
    elseif operator == '!=' then
        result = lhs.value ~= rhs.value
    elseif operator == '<=' then
        result = lhs.value <= rhs.value
    elseif operator == '>=' then
        result = lhs.value >= rhs.value
    elseif operator == '!' then
        if type(rhs.value) == 'boolean' then
            result = not rhs.value
        else
            error(type(rhs.value)..' Should be Boolean when using `!`')
        end
    end

    return BooleanVal(result)
end, true)
interpreter.eval_program = Method.PUBLIC(function (interp, program, env)
    for _, statement in pairs(program.body) do
        local val = interp.evaluate(statement, env)
        if statement.kind == 'ReturnValue' or val.kind == 'ReturnValue' then
            return val
        end
    end

    return NullVal()
end, true)
interpreter.eval_regularExpression = Method.PUBLIC(function (interp, expr, env)
    local val = NullVal
    for _, statement in pairs(expr.body) do
        val = interp.evaluate(statement, env)
    end

    return val
end, true)
interpreter.evaluate_logical_expr = Method.PUBLIC(function (interp, logic, env)
    local valueRight = interp.evaluate(logic.right, env)
    local valueLeft = interp.evaluate(logic.left, env)

    if type(valueRight.value) ~= 'boolean' or type(valueLeft.value) ~= 'boolean' then
        error('Value must be boolean in logical statements')
    end

    if logic.operator == '||' or logic.operator == 'or' then
        return BooleanVal(valueLeft.value or valueRight.value)
    elseif logic.operator == '&&' or logic.operator == 'and' then
        return BooleanVal(valueLeft.value and valueRight.value)
    end
end, true)
interpreter.evaluate_unary_expr = Method.PUBLIC(function (interp, unary, env)
    local valueRight = interp.evaluate(unary.identifier, env)
    local valueLeft = interp.evaluate(unary.assignment, env)

    if unary.direction == 'right' then
        return valueRight
    elseif unary.direction == 'left' then
        return valueLeft
    end
end, true)
interpreter.evaluate_binary_expr = Method.PUBLIC(function (interp, binop, env)
    local lhs = {}
    if binop.left then
        lhs = interp.evaluate(binop.left, env)
    end
    local rhs = interp.evaluate(binop.right, env)
    
    if boolOPS[binop.operator] then
        return interp.eval_bool_binary_expr(lhs, rhs, binop.operator)
    else
        if (lhs.type == 'Int' and rhs.type == 'Int') then
            return interp.eval_numeric_binary_expr(lhs, rhs, binop.operator)
        elseif (lhs.type == 'String' or rhs.type == 'String') then
            return interp.eval_string_binary_expr(lhs, rhs, binop.operator)
        end
    end

    return NullVal()
end, true)
interpreter.eval_identifier = Method.PUBLIC(function (interp, ident, env)
    local val = env.lookUpVar(ident.symbol)
    return val
end, true)
interpreter.eval_var_declaration = Method.PUBLIC(function (interp, declaration, env)
    return env.declareVar(declaration.identifier, declaration.value and interp.evaluate(declaration.value, env) or NullVal(), declaration.final, declaration.variableType)
end, true)
interpreter.eval_function_declaration = Method.PUBLIC(function (interp, declaration, env)
    local f = FunctionValue(declaration.name, declaration.parameters, declaration.body, declaration.optionalParameters, env)
    if declaration.unnamed then
        return f
    end
    return env.declareVar(declaration.name, f, true)
end, true)
interpreter.eval_return = Method.PUBLIC(function (interp, ret, env)
    if ret.value == nil then
        return NullVal()
    end
    return interp.evaluate(ret.value, env)
end, true)
interpreter.eval_assignment = Method.PUBLIC(function (interp, node, env)
    if node.assign.kind == 'Identifier' then
        local value = interp.evaluate(node.value, env)
        return env.assignVar(node.assign.symbol, node.assignmentOp and interp.eval_numeric_binary_expr(env.lookUpVar(node.assign.symbol), value, node.op) or value)
    elseif node.assign.kind == 'MemberExpr' then
        local object = interp.evaluate(node.assign.object, env)
        local value = interp.evaluate(node.value, env)
        object.properties[node.assign.property.symbol] = node.assignmentOp and interp.eval_numeric_binary_expr(object.properties[node.assign.property.symbol], value, node.op) or value
        return value
    -- elseif node.assign.kind == 'BinaryExpr' then
    --     return interp.evaluate_binary_expr(node.assign, env) -- test stuff
    end
    
    error ('Invalid LHS inside assignment expr '..tostring(node.assign))
end, true)
interpreter.eval_member_expr = Method.PUBLIC(function (interp, expr, env)
    if expr.object.kind == 'ObjectLiteral' then
        return interp.evaluate(expr.object, env).properties[expr.property.symbol]
    elseif expr.object.kind == 'Identifier' then
        local ident = interp.evaluate(expr.object, env)
        if ident.type == 'String' then
            return interpreter.fromLua((ident.fields[expr.property.symbol] or NullVal)())
        end
    end
end, true)
interpreter.eval_object_expr = Method.PUBLIC(function (interp, obj, env)
    local object = ObjectVal({})
    for _, keyValue in pairs(obj.properties) do
        object.properties[keyValue.key] = interp.evaluate(keyValue.value, env)
    end
    return object
end, true)
interpreter.eval_call_expr = Method.PUBLIC(function (interp, expr, env)
    local args = {}
    for _, arg in pairs(expr.args) do
        args[_] = interp.evaluate(arg, env)
    end
    local fn = interp.evaluate(expr.caller, env)

    if fn.type == 'native-fn' then
        local parsedArgs = {}
        for i = 1, #args do
            parsedArgs[i] = interpreter.toLua(args[i])

        end
        return interpreter.fromLua(fn.call(unpack(parsedArgs)))
    elseif fn.type == 'function' then
        local scope = environment(fn.declarationEnv)

        local expectedVars = {}

        for _, variable in pairs(fn.parameters) do
            if args[_] == nil and not fn.optionalParameters[variable] then
                table.insert(expectedVars, variable)
            elseif args[_] == nil and fn.optionalParameters[variable] then
                args[_] = interp.evaluate(fn.optionalParameters[variable], env)
            end
            scope.declareVar(variable, args[_], false)
        end

        if #expectedVars > 0 then
            local str = 'Not enough arguments, expected '
            for i = 1, #expectedVars do
                str = str..expectedVars[i]..', '
            end

            error(str)
        end

        for _, stmt in pairs(fn.body) do
            local val = interp.evaluate(stmt, scope)
            if stmt.kind == 'ReturnValue' or val.kind == 'ReturnValue' then
                return val
            end
        end

        return NullVal()
    end

    error('Cannot call a '..fn.type..' value.')
end, true)
interpreter.eval_if_statement = Method.PUBLIC(function (interp, statement, env)
    local condition = interp.evaluate(statement.condition, env)
    if condition.value then
        for _, stmt in pairs(statement.body) do
            local val = interp.evaluate(stmt, env)
            if stmt.kind == 'ReturnValue' then
                return stmt
            end
        end
    else
        if statement.elseBody then
            for _, stmt in pairs(statement.elseBody) do
                local val = interp.evaluate(stmt, env)
                if stmt.kind == 'ReturnValue' then
                    return stmt
                end
            end
        end
    end

    return NullVal()
end, true)
interpreter.eval_switch_case = Method.PUBLIC(function (interp, case, env)
    local value = interp.evaluate(case.value, env)
    local final
    for req, bodies in pairs(case.body) do
        if type(req) ~= 'string' then
            local eReq = interp.evaluate(req)
            if eReq.type ~= value.type then
                error(eReq.type..' Should be '..value.type)
            end
            if eReq.value == value.value then
                final = bodies
            end
        end
    end

    if not final and case.body['default'] then
        final = case.body['default']
    end

    if final then
        for _, stmt in pairs(final) do
            local val = interp.evaluate(stmt, env)
            if stmt.kind == 'ReturnValue' then
                return stmt
            end
        end
    end

    return NullVal()
end, true)
interpreter.eval_for_loop = Method.PUBLIC(function (interp, loop, env)
    local expression = interp.evaluate(loop.expression)
    local scope = environment(env)
    scope.declareVar(loop.identifier.symbol, NullVal())
    while expression.hasNext() do
        scope.assignVar(loop.identifier.symbol, NumberVal(expression.next()))
        for _, stmt in pairs(loop.body) do
            local val = interp.evaluate(stmt, scope)
            if stmt.kind == 'ReturnValue' then
                return stmt
            end
        end
    end

    return NullVal()
end, true)
interpreter.eval_while_loop = Method.PUBLIC(function (interp, loop, env)
    local condition = interp.evaluate(loop.condition, env)
    while condition.value do
        for _, stmt in pairs(loop.body) do
            local val = interp.evaluate(stmt, env)
            if stmt.kind == 'ReturnValue' then
                return stmt
            end
        end
        condition = interp.evaluate(loop.condition, env)
    end

    return NullVal()
end, true)
interpreter.evaluate = Method.PUBLIC(function (interp, astNode, env)
    return switch(astNode.kind, {
        NumericLiteral = function ()
            return NumberVal(astNode.value)
        end,
        StringCollection = function ()
            local actualString = ''
            for i = 1, #astNode.value do
                local comb = astNode.value[i]
                if comb[2] == 'string' then
                    actualString = actualString..tostring(comb[1].value)
                elseif comb[2] == 'identifier' then
                    actualString = actualString.. tostring(interp.evaluate(comb[1], env).value)
                elseif comb[2] == 'expression'  then
                    actualString = actualString.. tostring(interp.evaluate(comb[1], env).value)
                end
            end
            return StringVal(actualString)
        end,
        IntIterator = function ()
            return IntIterator(interp.evaluate(astNode.min).value, interp.evaluate(astNode.max).value)
        end,
        BinaryExpr = function ()
            return interp.evaluate_binary_expr(astNode, env)
        end,
        Program = function ()
            return interp.eval_program(astNode, env)
        end,
        Identifier = function ()
            return interp.eval_identifier(astNode, env)
        end,
        UnaryExpr = function ()
            return interp.evaluate_unary_expr(astNode, env)
        end,
        LogicalExpr = function ()
            return interp.evaluate_logical_expr(astNode, env)
        end,
        ObjectLiteral = function ()
            return interp.eval_object_expr(astNode, env)
        end,
        MemberExpr = function ()
            return interp.eval_member_expr(astNode, env)
        end,
        CallExpr = function ()
            return interp.eval_call_expr(astNode, env)
        end,
        VarDeclaration = function ()
            return interp.eval_var_declaration(astNode, env)
        end,
        FunctionDeclaration = function ()
            return interp.eval_function_declaration(astNode, env)
        end,
        IfStatement = function ()
            return interp.eval_if_statement(astNode, env)
        end,
        SwitchCase = function ()
            return interp.eval_switch_case(astNode, env)
        end,
        ForLoop = function ()
            return interp.eval_for_loop(astNode, env)
        end,
        WhileLoop = function ()
            return interp.eval_while_loop(astNode, env)
        end,
        AssignmentExpr = function ()
            return interp.eval_assignment(astNode, env)
        end,
        ReturnValue = function ()
            return interp.eval_return(astNode, env)
        end,
        RegularExpression = function ()
            return interp.eval_regularExpression(astNode, env)
        end,
        default = function ()
            error('Undefined AST node: '..tostring(astNode))
        end
    })
end, true)
interpreter.fromLua = Method.PUBLIC(function (This, value)
    local vType = type(value)
    if vType == 'number' then
        return NumberVal(value)
    elseif vType == 'string' then
        return StringVal(value)
    elseif vType == 'boolean' then
        return BooleanVal(value)
    elseif vType == 'function' then
        return NativeFnValue(value)
    end
    return NullVal()
end, true)
interpreter.toLua = Method.PUBLIC(function (This, value)
    local vType = value.type
    if vType == 'Int' or vType == 'String' or vType == 'Bool' then
        return value.value
    elseif vType == 'object' then
        return value.properties
    elseif vType == 'function' then
        return function(...)
            return interpreter.call(value.declarationEnv, value.name, ...)
        end
    end
    return nil
end, true)
interpreter.call = Method.PUBLIC(function (interp, env, func, ...)
    local args = {...}
    for _, arg in pairs(args) do
        args[_] = interpreter.fromLua(arg)
    end
    local fn = env.lookUpVar(func)

    if fn.type == 'native-fn' then
        return fn.call(args, env)
    elseif fn.type == 'function' then
        local scope = environment(fn.declarationEnv)

        local expectedVars = {}

        for _, variable in pairs(fn.parameters) do
            if args[_] == nil and not fn.optionalParameters[variable] then
                table.insert(expectedVars, variable)
            elseif args[_] == nil and fn.optionalParameters[variable] then
                args[_] = interp.evaluate(fn.optionalParameters[variable], env)
            end
            scope.declareVar(variable, args[_], false)
        end

        if #expectedVars > 0 then
            local str = 'Not enough arguments, expected '
            for i = 1, #expectedVars do
                str = str..expectedVars[i]..', '
            end

            error(str)
        end

        local result = NullVal()
        for _, stmt in pairs(fn.body) do
            local val = interp.evaluate(stmt, scope)
            if stmt.kind == 'ReturnValue' or val.kind == 'ReturnValue' then
                return val
            end
        end

        return result
    end

    error('Cannot call a '..fn.type..' value.')
end, true)

return interpreter