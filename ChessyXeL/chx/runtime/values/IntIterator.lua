local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local RuntimeVal = require 'ChessyXeL.chx.runtime.values.RuntimeVal'

---@class chx.runtime.values.IntIterator : chx.runtime.values.RuntimeVal
local IntIterator = RuntimeVal.extend 'IntIterator'

IntIterator.min = FieldStatus.PUBLIC('default', 'default', nil)
IntIterator.max = FieldStatus.PUBLIC('default', 'default', nil)

IntIterator.hasNext = Method.PUBLIC(function (iterator)
    return iterator.min < iterator.max
end)
IntIterator.next = Method.PUBLIC(function (iterator)
    iterator.min = iterator.min + 1
    return iterator.min - 1
end)
IntIterator.new = function (min, max)
    local iterator = IntIterator.create()
    iterator.type = 'IntIterator'
    iterator.min = min
    iterator.max = max
    return iterator
end

return IntIterator