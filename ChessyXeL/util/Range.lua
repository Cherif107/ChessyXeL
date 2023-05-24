local Class = require 'ChessyXeL.Class'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'

---@class util.Range : Class
local Range = Class 'Range'

Range.start = FieldStatus.PUBLIC('default', 'default')
Range.stop = FieldStatus.PUBLIC('default', 'default')
Range.active = FieldStatus.PUBLIC('default', 'default', true)

Range.new = function (start, stop)
    local range = Range.create()
    range.start = start
    range.stop = stop or start
    return range
end

return Range