local Class = require 'ChessyXeL.Class'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local TypeUtil = require 'ChessyXeL.util.TypeUtil'
local CType = require 'ChessyXeL.interp.base.expr.CType'
local ExprDef = require 'ChessyXeL.interp.base.expr.ExprDef'
local ErrorDef = require 'ChessyXeL.interp.base.expr.ErrorDef'
local Enum = require 'ChessyXeL.Enum'
local Token = require 'ChessyXeL.interp.base.Token'
local Const = 'ChessyXeL.interp.base.Const'
require 'ChessyXeL.util.StringUtil'

local function exists(t, f)
    for k, v in pairs(t) do
        if f(v) then
            return true
        end
    end
    return false
end

---@class interp.base.Printer : Class
local Printer = Class 'Printer'

Printer.buf = FieldStatus.NORMAL()
Printer.tabs = FieldStatus.NORMAL()

Printer.add = Method.PUBLIC(function (instance, s)
    instance.buf = instance.buf..s
end)
Printer.type = Method.NORMAL(function (instance, t)
    Enum.switch(t, {
        [CType.CTOpt] = function (t)
            instance.add('?')
            instance.type(t)
        end,
        [CType.CTPath] = function (path, params)
            instance.add(table.concat(path, '.'))
            if params ~= nil then
                instance.add('<')
                local first = true
                for _, p in pairs(params) do
                    if first then first = false else instance.add(', ') end
                    instance.type(p)
                end
                instance.add(">")
            end
        end,
        [CType.CTNamed] = function (name, t)
            instance.add(name)
            instance.add(':')
            instance.add(t)
        end,
        [CType.CTFun] = function (args, ret)
            if exists(args, function(a) return a.match(CType.CTNamed('_', '_')) end) then
                instance.add('(')
                for _, a in pairs(args) do
                    Enum.switch(a, {
                        [CType.CTNamed] = function (_, _)
                            instance.type(a)
                        end,
                        default = function ()
                            instance.type(CType.CTNamed('_', a))
                        end
                    })
                end
                instance.add(')->')
            else
                if #args == 0 then
                    instance.add('Void -> ')
                else
                    for _, a in pairs(args) do
                        instance.type(a)
                        instance.add(' -> ')
                    end
                end
            end
            instance.type(ret)
        end,
        [CType.CTAnon] = function (fields)
            instance.add('{')
            local first = true
            for _, f in pairs(fields) do
                if first then
                    first = false
                    instance.add(" ")
                else
                    instance.add(', ')
                end
                instance.add(f.name..' : ')
                instance.type(f.t)
            end
            instance.add('}')
        end,
        [CType.CTParent] = function (t)
            instance.add('(')
            instance.type(t)
            instance.add(')')
        end
    })
end)

Printer.addType = Method.NORMAL(function (instance, t)
    if t ~= nil then
        instance.add(' : ')
        instance.type(t)
    end
end)
Printer.exprToString = Method.PUBLIC(function (instance, e)
    instance.buf = ''
    instance.tabs = ''
    instance.expr(e)
    return instance.buf
end)
Printer.typeToString = Method.PUBLIC(function (instance, t)
    instance.buf = ''
    instance.tabs = ''
    instance.type(t)
    return instance.buf
end)
Printer.toString = Method.PUBLIC(function (Self, e)
    return Self.new().exprToString(e)
end, true)
Printer.expr = Method.NORMAL(function (instance, e)
    if e == nil then
        instance.add('??NULL??')
        return
    end
    Enum.switch(e.e, {
        [ExprDef.EConst] = function (c)
            Enum.switch(c, {
                [Const.CInt] = function (i)
                    instance.add(i)
                end,
                [Const.CFloat] = function (f)
                    instance.add(f)
                end,
                [Const.CString] = function (s)
                    instance.add('"')
                    instance.add(s:gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "\\t"))
                    instance.add('"')
                end,
            })
        end,
        [ExprDef.EIdent] = function (v)
            instance.add(v)
        end,
        [ExprDef.EVar] = function (n, t, e)
            instance.add('var '..n)
            instance.addType(t)
            if e ~= nil then
                instance.add(' = ')
                instance.expr(e)
            end
        end,
        [ExprDef.EParent] = function (e)
            instance.add('(')
            instance.expr(e)
            instance.add(')')
        end,
        [ExprDef.EBlock] = function (el)
            if #el == 0 then
                instance.add('{}')
            else
                instance.tabs = instance.tabs..'\t'
                instance.add('{\n')
                for _, e in pairs(el) do
                    instance.add(instance.tabs)
                    instance.expr(e)
                    instance.add(';\n')
                end
                instance.tabs = instance.tabs:sub(2)
                instance.add('}')
            end
        end,
        [ExprDef.EField] = function (e, f)
            instance.expr(e)
            instance.add('.'..f)
        end,
        [ExprDef.EBinop] = function (op, e1, e2)
            instance.expr(e1)
            instance.add(tostring(op))
            instance.expr(e2)
        end,
        [ExprDef.EUnop] = function (op, pre, e)
            if pre then
                instance.add(op)
                instance.expr(e)
            else
                instance.expr(e)
                instance.add(op)
            end
        end,
        [ExprDef.ECall] = function (e, args)
            if e == nil then
                instance.expr(e)
            else
                Enum.switch(e.e, {
                    [ExprDef.EField] = function (_)
                        instance.expr(e)
                    end,
                    [ExprDef.EIdent] = function (_)
                        instance.expr(e)
                    end
                    ,
                    [ExprDef.EConst] = function (_)
                        instance.expr(e)
                    end,
                    default = function ()
                        instance.add('(')
                        instance.expr(e)
                        instance.add(')')
                    end
                })
                instance.add('(')
                local first = true
                for _, a in pairs(args) do
                    if first then
                        first = false
                    else
                        instance.add(', ')
                    end
                    instance.expr(a)
                end
                instance.add(')')
            end
        end,
        [ExprDef.EIf] = function (cond, e1, e2)
            instance.add('if( ')
            instance.expr(cond)
            instance.add(' ) ')
            instance.expr(e1)
            if e2 ~= nil then
                instance.add(" else ")
                    instance.expr(e2)
            end
        end,
        [ExprDef.EWhile] = function (cond, e)
            instance.add('while( ')
            instance.expr(cond)
            instance.add(' ) ')
            instance.expr(e)
        end,
        [ExprDef.EDoWhile] = function (cond, e)
            instance.add('do ')
            instance.expr(e)
            instance.add('while( ')
            instance.expr(cond)
            instance.add(' ) ')
        end,
        [ExprDef.EFor] = function (v, it, e)
            instance.add('for( '..v..' in ')
            instance.expr(it)
            instance.add(' ) ')
            instance.expr(e)
        end,
        [ExprDef.EBreak] = function ()
            instance.add('break')
        end,
        [ExprDef.EContinue] = function ()
            instance.add('continue')
        end,
        [ExprDef.EFunction] = function (params, e, name, ret)
            instance.add('function')
            if name ~= nil then
                instance.add(" "..name)
            end
            instance.add('(')
            local first = true
            for _, a in pairs(params) do
                if first then first = false else instance.add(', ') end
                if a.opt then instance.add('?') end
                instance.add(a.name)
                instance.addType(a.t)
            end
            instance.add(')')
            instance.addType(ret)
            instance.add(' ')
            instance.expr(e)
        end,
        [ExprDef.EReturn] = function (e)
            instance.add('return')
            if e ~= nil then
                instance.add(" ")
                instance.expr(e)
            end
        end,
        [ExprDef.EArray] = function (e, index)
            instance.expr(e)
            instance.add('[')
            instance.expr(index)
            instance.add(']')
        end,
        [ExprDef.EArrayDecl] = function (el)
            instance.add('[')
            local first = true
            for _, e in pairs(el) do
                if first then first = false else instance.add(', ') end
                instance.expr(e)
            end
            instance.add(']')
        end,
        [ExprDef.ENew] = function (cl, args)
            instance.add('new '..cl..'(')
            local first = true
            for _, e in pairs(args) do
                if first then first = false else instance.add(', ') end
                instance.expr(e)
            end
            instance.add(')')
        end,
        [ExprDef.EThrow] = function (e)
            instance.add('throw ')
            instance.expr(e)
        end,
        [ExprDef.ETry] = function (e, v, t, ecatch)
            instance.add('try ')
            instance.expr(e)
            instance.add(' catch( '..v)
            instance.addType(t)
            instance.add(') ')
            instance.expr(ecatch)
        end,
        [ExprDef.EObject] = function (fl)
            if #fl == 0 then
                instance.add('{}')
            else
                instance.tabs = instance.tabs..'\t'
                instance.add('{\n')
                for _, f in pairs(fl) do
                    instance.add(instance.tabs)
                    instance.add(f.name..' : ')
                    instance.expr(f.e)
                    instance.add(',\n')
                end
                instance.tabs = instance.tabs:sub(2)
                instance.add('}')
            end
        end,
        [ExprDef.ETenerary] = function (c, e1, e2)
            instance.expr(c)
            instance.add(' ? ')
            instance.expr(e1)
            instance.add(' : ')
            instance.expr(e2)
        end,
        [ExprDef.ESwitch] = function (e, cases, def)
            instance.add('switch( ')
            instance.expr(e)
            instance.add(') {')
            for _, c in pairs(cases) do
                instance.add('case ')
                local first = true
                for _, v in pairs(c.values) do
                    if first then first = false else instance.add(', ') end
                    instance.expr(v)
                end
                instance.add(': ')
                instance.expr(c.expr)
                instance.add(';\n')
            end
            instance.add('}')
        end,
        [ExprDef.EMeta] = function (name, args, e)
            instance.add('@')
            instance.add(name)
            if args ~= nil and #args > 0 then
                instance.add('(')
                local first = true
                for _, a in pairs(args) do
                    if first then first = false else instance.add(', ') end
                    instance.expr(e)
                end
                instance.add(')')
            end
            instance.add(' ')
            instance.expr(e)
        end,
        [ExprDef.ECheckType] = function (e, t)
            instance.add('(')
            instance.expr(e)
            instance.add(' : ')
            instance.addType(t)
            instance.add(')')
        end,
    })
end)

Printer.errorToString = Method.PUBLIC(function (Self, e)
    local message = Enum.switch(
        e.e,
        {
            [ErrorDef.EInvalidChar] = function(c)
                return "Invalid character: '" .. (c == -1 and "EOF" or string.char(c)) .. "' (" .. c .. ")"
            end,
            [ErrorDef.EUnexpected] = function(s)
                return "Unexpected \"" .. s .. "\""
            end,
            [ErrorDef.EUnterminatedString] = function()
                return "Unterminated string"
            end,
            [ErrorDef.EUnterminatedComment] = function()
                return "Unterminated comment"
            end,
            [ErrorDef.EInvalidPreprocessor] = function(str)
                return "Invalid preprocessor (" .. str .. ")"
            end,
            [ErrorDef.EUnknownVariable] = function(v)
                return "Unknown variable: " .. v
            end,
            [ErrorDef.EInvalidIterator] = function(v)
                return "Invalid iterator: " .. v
            end,
            [ErrorDef.EInvalidOp] = function(op)
                return "Invalid operator: " .. op
            end,
            [ErrorDef.EInvalidAccess] = function(f)
                return "Invalid access to field " .. f
            end,
            [ErrorDef.ECustom] = function(msg)
                return msg
            end,
            [ErrorDef.EInvalidFinal] = function(v)
                return "You cannot reassign a value to the final variable \"" .. v .. "\"."
            end,
            [ErrorDef.EUnmatcingType] = function(v, t)
                return t .. " should be " .. v .. "."
            end,
            [ErrorDef.EUnexistingField] = function(f, f2)
                return "Field " .. f2 .. " does not exist in " .. f .. "."
            end,
            [ErrorDef.EUnknownIdentifier] = function(v)
                return "Unknown identifier: " .. v .. "."
            end,
            [ErrorDef.EUpperCase] = function()
                return "Package name cannot have capital letters."
            end,
            [ErrorDef.EDuplicate] = function(v)
                return "Duplicate class field declaration (" .. v .. ")."
            end,
            [ErrorDef.EExpectedField] = function(v)
                return "Expected \"public\" or \"private\" for " .. v .. ", couldn't get any."
            end,
            [ErrorDef.EFunctionAssign] = function(f)
                return "Cannot rebind this method (" .. f .. ") : please use 'dynamic' before method declaration"
            end
        }
    )
    return e.origin..' : '..e.line.. ' : '..message
end, true)

return Printer