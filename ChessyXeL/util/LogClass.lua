local Class = require 'ChessyXeL.Class'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'

---@class util.LogClass : Class
local LogClass = Class 'LogClass'

LogClass.onGetLog = Method.PUBLIC(function (instance, field) end, true, true)
LogClass.onSetLog = Method.PUBLIC(function (instance, field, value) end, true, true)
rawset(LogClass, 'logSignals', {
    get = function (instance, field)
        if instance.__instanceClass.onGetLog then
            instance.__instanceClass.onGetLog(instance, field)
        end
    end,
    set = function (instance, field, value)
        if instance.__instanceClass.onSetLog then
            instance.__instanceClass.onSetLog(instance, field, value)
        end
    end
})

return LogClass