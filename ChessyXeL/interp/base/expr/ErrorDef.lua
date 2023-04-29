local Enum = require 'ChessyXeL.Enum'
---@class interp.base.expr.ErrorDef : Enum
local ErrorDef = Enum {
    EDuplicate = {'v'},
    EInvalidChar = {'c'},
    EUnexpected = {'s'},
    EFunctionAssign = {'f'},
    EUnterminatedString = {},
    EUnterminatedComment = {},
    EInvalidPreprocessor = {'msg'},
    EUnknownVariable = {'v'},
    EInvalidIterator = {'v'},
    EInvalidOp = {'op'},
    EInvalidAccess = {'f'},
    EUnmatcingType = {'v', 't'},
    ECustom = {'msg'},
    EInvalidFinal = {'v'},
    EUnexistingField = {'f', 'f2'},
    EUnknownIdentifier = {'s'},
    EExpectedField = {'v'},
    EUpperCase = {}
}

return ErrorDef