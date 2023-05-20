local Sprite = require 'ChessyXeL.display.Sprite'
local Math = require 'ChessyXeL.math.Math'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'

---@class display.addons.Line : display.Sprite
local Line = Sprite.extend 'Line'

Line.reset = Method.PUBLIC(function (line, x1, y1, x2, y2)
    local width = Math.distanceBetween(x1, y1, x2, y2)
    line.setGraphicSize(width, line.height)
    line.updateHitbox()
    line.angle = math.deg(Math.angleBetween(x1, y1, x2, y2))
    line.x, line.y = ((x1 + x2) / 2 - width / 2), ((y1 + y2) / 2 - line.height / 2)
    return line
end)
Line.resetByAngle = Method.PUBLIC(function(line, startX, startY, width, angle)
    local endX = startX + width * math.cos(angle)
    local endY = startY + width * math.sin(angle)
    line.reset(startX, startY, endX, endY)
end)
Line.new = function (x, y, endX, endY, size, color)
    local line = Line.create()
    line.makeGraphic(size, size, color)
    line.reset(x or 0, y or 0, endX or 0, endY or 0)
    return line
end

return Line