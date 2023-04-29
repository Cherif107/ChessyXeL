local Class = require 'ChessyXeL.Class'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local TypeUtil = require 'ChessyXeL.util.TypeUtil'
local CType = require 'ChessyXeL.interp.base.expr.CType'
local ExprDef = require 'ChessyXeL.interp.base.expr.ExprDef'
local Enum = require 'ChessyXeL.Enum'

---@class interp.base.Tools : Class
local Tools = Class 'Tools'

Tools.keys = FieldStatus.PUBLIC('default', 'default', {
    "import", "package", "if", "var", "for", "while", "final", "do", "as", "using", "break", "continue",
	"public", "private", "static", "overload", "override", "class", "function", "else", "try", "catch",
	"abstract", "case", "switch", "untyped", "cast", "typedef", "dynamic", "default", "enum", "extern",
	"extends", "implements", "in", "macro", "new", "null", "return", "throw", "from", "to", "super"
}, true)

Tools.iter = Method.PUBLIC(function(e, f)
    Enum.switch(e.e, {
        [ExprDef.EConst] = function() end,
        [ExprDef.EIdent] = function() end,
        [ExprDef.EVar] = function(_, _, ex)
            if ex ~= nil then
                f(ex)
            end
        end,
        [ExprDef.EParent] = function(ex)
            f(ex)
        end,
        [ExprDef.EBlock] = function(el)
            for _, ex in ipairs(el) do
                f(ex)
            end
        end,
        [ExprDef.EField] = function(ex, _)
            f(ex)
        end,
        [ExprDef.EBinop] = function(_, e1, e2)
            f(e1)
            f(e2)
        end,
        [ExprDef.EUnop] = function(_, _, ex)
            f(ex)
        end,
        [ExprDef.ECall] = function(ex, args)
            f(ex)
            for _, arg in ipairs(args) do
                f(arg)
            end
        end,
        [ExprDef.EIf] = function(c, e1, e2)
            f(c)
            f(e1)
            if e2 ~= nil then
                f(e2)
            end
        end,
        [ExprDef.EWhile] = function(c, e)
            f(c)
            f(e)
        end,
        [ExprDef.EDoWhile] = function(c, e)
            f(c)
            f(e)
        end,
        [ExprDef.EFor] = function(_, it, e)
            f(it)
            f(e)
        end,
        [ExprDef.EBreak] = function() end,
        [ExprDef.EContinue] = function() end,
        [ExprDef.EFunction] = function(_, e, _, _)
            f(e)
        end,
        [ExprDef.EReturn] = function(e)
            if e ~= nil then
                f(e)
            end
        end,
        [ExprDef.EArray] = function(e, i)
            f(e)
            f(i)
        end,
        [ExprDef.EArrayDecl] = function(el)
            for _, ex in ipairs(el) do
                f(ex)
            end
        end,
        [ExprDef.ENew] = function(_, el)
            for _, ex in ipairs(el) do
                f(ex)
            end
        end,
        [ExprDef.EThrow] = function(e)
            f(e)
        end,
        [ExprDef.ETry] = function(e, _, _, c)
            f(e)
            f(c)
        end,
        [ExprDef.EObject] = function(fl)
            for _, fi in ipairs(fl) do
                f(fi.e)
            end
        end,
        [ExprDef.ETernary] = function(c, e1, e2)
            f(c)
            f(e1)
            f(e2)
        end,
        [ExprDef.ESwitch] = function(e, cases, def)
            f(e)
            for _, c in ipairs(cases) do
                for _, v in ipairs(c.values) do
                    f(v)
                end
                f(c.expr)
            end
            if def ~= nil then
                f(def)
            end
        end,
        [ExprDef.EMeta] = function(_, args, e)
            if args ~= nil then
                for _, arg in ipairs(args) do
                    f(arg)
                end
            end
            f(e)
        end,
        [ExprDef.ECheckType] = function (e, _)
            f(e)
        end
    })
end, true)
Tools.map = Method.PUBLIC(function(Self, e, f)
    local edef = Enum.switch(e.e, {
        [ExprDef.EConst] = function() return e end,
        [ExprDef.EIdent] = function(v) return v end,
        [ExprDef.EBreak] = function() return e end,
        [ExprDef.EContinue] = function() return e end,
        [ExprDef.EVar] = function(n, t, expr)
            if expr ~= nil then
                expr = f(expr)
            end
            return ExprDef.EVar(n, t, expr)
        end,
        [ExprDef.EParent] = function(expr)
            return ExprDef.EParent(f(expr))
        end,
        [ExprDef.EBlock] = function(el)
            local newEl = {}
            for _, e in ipairs(el) do
                table.insert(newEl, f(e))
            end
            return ExprDef.EBlock(newEl)
        end,
        [ExprDef.EField] = function(e, fi)
            return ExprDef.EField(f(e), fi)
        end,
        [ExprDef.EBinop] = function(op, e1, e2)
            return ExprDef.EBinop(op, f(e1), f(e2))
        end,
        [ExprDef.EUnop] = function(op, pre, e)
            return ExprDef.EUnop(op, pre, f(e))
        end,
        [ExprDef.ECall] = function(e, args)
            local newArgs = {}
            for _, a in ipairs(args) do
                table.insert(newArgs, f(a))
            end
            return ExprDef.ECall(f(e), newArgs)
        end,
        [ExprDef.EIf] = function(c, e1, e2)
            if e2 ~= nil then
                e2 = f(e2)
            end
            return ExprDef.EIf(f(c), f(e1), e2)
        end,
        [ExprDef.EWhile] = function(c, e)
            return ExprDef.EWhile(f(c), f(e))
        end,
        [ExprDef.EDoWhile] = function(c, e)
            return ExprDef.EDoWhile(f(c), f(e))
        end,
        [ExprDef.EFor] = function(v, it, e)
            return ExprDef.EFor(v, f(it), f(e))
        end,
        [ExprDef.EFunction] = function(args, e, name, t)
            return ExprDef.EFunction(args, f(e), name, t)
        end,
        [ExprDef.EReturn] = function(e)
            if e ~= nil then
                e = f(e)
            end
            return ExprDef.EReturn(e)
        end,
        [ExprDef.EArray] = function(e, i)
            return ExprDef.EArray(f(e), f(i))
        end,
        [ExprDef.EArrayDecl] = function(el)
            local newEl = {}
            for _, e in ipairs(el) do
                table.insert(newEl, f(e))
            end
            return ExprDef.EArrayDecl(newEl)
        end,
        [ExprDef.ENew] = function(cl, el)
            local newEl = {}
            for _, e in ipairs(el) do
                table.insert(newEl, f(e))
            end
            return ExprDef.ENew(cl, newEl)
        end,
        [ExprDef.EThrow] = function(e)
            return ExprDef.EThrow(f(e))
        end,
        [ExprDef.ETry] = function(expr)
            return ExprDef.ETry(f(expr), expr.v, expr.t, f(expr.c))
        end,
        [ExprDef.EObject] = function(expr)
            local fl = {}
            for _, fi in ipairs(expr.fl) do
                fl[#fl+1] = {name=fi.name, e=f(fi.e)}
            end
            return ExprDef.EObject(fl)
        end,
        [ExprDef.ETernary] = function(expr)
            return ExprDef.ETernary(f(expr.c), f(expr.e1), f(expr.e2))
        end,
        [ExprDef.ESwitch] = function(expr)
            local cases = {}
            for _, c in ipairs(expr.cases) do
                local values = {}
                for _, v in ipairs(c.values) do
                    values[#values+1] = f(v)
                end
                cases[#cases+1] = {values=values, expr=f(c.expr)}
            end
            local def = expr.def == nil and nil or f(expr.def)
            return ExprDef.ESwitch(f(expr.e), cases, def)
        end,
        [ExprDef.EMeta] = function(expr)
            local args = expr.args == nil and nil or {}
            for _, a in ipairs(expr.args) do
                args[#args+1] = f(a)
            end
            return ExprDef.EMeta(expr.name, args, f(expr.e))
        end,
        [ExprDef.ECheckType] = function(expr)
            return ExprDef.ECheckType(f(expr.e), expr.t)
        end
    }) or e.e
    return Tools.mk(edef, e)
end, true)

Tools.getIdent = Method.PUBLIC(function (Self, e)
    return Enum.switch(e.e, {
        [ExprDef.EIdent] = function (v)
            return v
        end,
        [ExprDef.EField] = function (e, f)
            return Self.getIdent(e)
        end,
        [ExprDef.EArray] = function (e, i)
            return Self.getIdent(e)
        end
    })
end, true)
Tools.ctToType = Method.PUBLIC(function (Self, ct)
    return Enum.switch(ct, {
        [CType.CTPath] = function (path, params)
            if path[1] == 'Null' then
                return Self.ctToType(params[0])
            end
            return path[1]
        end,
        [CType.CTFun] = function (_, _)
            return "Function"
        end,
        [CType.CTParent] = function (_, _)
            return "Function"
        end,
        [CType.CTAnon] = function (fields)
            return "Anon"
        end
    })
end, true)

Tools.compatibleWithEachother = Method.PUBLIC(function (Self, v, v2)
    return (v == 'Float' and v2 == 'Int') or (v == 'Dynamic' and v2 == 'null')
end, true)
Tools.getType = Method.PUBLIC(function (Self, v)
    local type = TypeUtil.typeOf(v)
    local result = type
    if type == 'nil' then
        result = 'null'
    elseif type == "integer" then
        result = 'Int'
    elseif type == 'float' then
        result = 'Float'
    elseif type == 'boolean' then
        result = 'Bool'
    elseif type == 'ClassInstance' then
        result = v.__type
    elseif type == 'function' then
        result = 'Function'
    end
    return result
end, true)
Tools.mk = Method.PUBLIC(function (Self, e, p)
    return {e = e, pmin = p.pmin, pmax = p.pmax, origin = p.origin, line = p.line}
end, true)

return Tools