local Enum = require 'ChessyXeL.Enum'
---@class util.Axes : Enum
---@field public X EnumData X axis
---@field public Y EnumData Y axis
---@field public XY EnumData Both X and Y axes
---@field public NONE EnumData Neither
local Axes = Enum {
    'X',
    'Y',
    'XY',
    'NONE'
}

return Axes