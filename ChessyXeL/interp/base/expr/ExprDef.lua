local Enum = require 'ChessyXeL.Enum'
---@class interp.base.expr.ExprDef : Enum
local ExprDef = Enum {
    EConst = {'c'},
    EIdent = {'v', 'isFinal'},
    EVar = {'n', 't', 'e', 'p', 'g'},
    EFinal = {'f', 't', 'e', 'p'},
    EParent = {'e'},
    EBlock = {'e'},
    EField = {'e', 'f'},
    EBinop = {'op', 'e1', 'e2'},
    EUnop = {'op', 'prefix', 'e'},
    ECall = {'e', 'params'},
    EIf = {'cond', 'e1', 'e2'},
    EWhile = {'cond', 'e'},
    EFor = {'v', 'it', 'e'},
    ECoalesce = {'e1', 'e2', 'assign'},
    EBreak = {},
    EContinue = {},
    EFunction = {'args', 'e', 'name', 'ret', 'p', 'd'},
    EReturn = {'e'},
    EArray = {'e', 'index'},
    EArrayDecl = {'e'},
    ENew = {'cl', 'params'},
    EThrow = {'e'},
    ETry = {'e', 'v', 't', 'ecatch'},
    EObject = {'fl'},
    ETernary = {'cond', 'e1', 'e2'},
    ESwitch = {'e', 'cases', 'defaultExpr'},
    EDoWhile = {'cond', 'e'},
    EUsing = {'op', 'n'},
    EImport = {'i', 'c', 'ps'},
    EPackage = {'p'},
    EMeta = {'name', 'args', 'e'},
    ECheckType = {'e', 't'}
} 

return ExprDef