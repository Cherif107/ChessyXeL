local Class = require 'ChessyXeL.Class'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local TableUtil = require 'ChessyXeL.util.TableUtil'

---@class Signal : Class
local Signal = Class 'Signal'
Signal.listeners = FieldStatus.PUBLIC('default', 'never', {})
Signal.remove = Method.PUBLIC(function (signal, listener)
    return table.remove(signal.listeners, TableUtil.indexOf(signal.listeners, listener))
end)
Signal.add = Method.PUBLIC(function (signal, listener)
    return table.insert(signal.listeners, listener)
end)
Signal.has = Method.PUBLIC(function (signal, listener)
    return TableUtil.indexOf(signal.listeners, listener) ~= -1
end)
Signal.dispatch = Method.PUBLIC(function (signal, ...)
    for i = 1, #signal.listeners do
        signal.listeners[i](...)
    end
end)

return Signal