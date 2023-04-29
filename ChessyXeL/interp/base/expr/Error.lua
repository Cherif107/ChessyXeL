local Class = require 'ChessyXeL.Class'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
---@class interp.base.expr.Error : Class
local Error = Class 'Error'

Error.e = FieldStatus.PUBLIC()
Error.pmin = FieldStatus.PUBLIC()
Error.pmax = FieldStatus.PUBLIC()
Error.origin = FieldStatus.PUBLIC()
Error.line = FieldStatus.PUBLIC()
Error.toString = Method.PUBLIC(function (Self)
    
end)

Error.new = function (e, pmin, pmax, origin, line)
    local error = Error.create()
    error.e = e
    error.pmin = pmin
    error.pmax = pmax
    error.origin = origin
    error.line = line

    return error
end

return Error