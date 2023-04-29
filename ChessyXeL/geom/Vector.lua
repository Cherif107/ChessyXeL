local Class = require 'ChessyXeL.Class'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'

---@class geom.Vector : Class (use math.Point instead)
local Vector = Class 'Vector'

Vector.x = FieldStatus.PUBLIC('default', 'default', 0)
Vector.y = FieldStatus.PUBLIC('default', 'default', 0)
Vector.length = FieldStatus.PUBLIC(function (I) return math.sqrt(I.x * I.x + I.y * I.y) end, 'never')
Vector.lengthSquared = FieldStatus.PUBLIC(function (I) return I.x * I.x + I.y * I.y end, 'never')

Vector.setTo = Method.PUBLIC(function (vector, xa, ya)
    vector.x = xa or 0
    vector.y = ya or 0
    return vector
end)
Vector.offset = Method.PUBLIC(function (vector, dx, dy)
    vector.setTo(vector.x + dx, vector.y + dy)
end)
Vector.clone = Method.PUBLIC(function (vector)
    return Vector.new(vector.x, vector.y)
end)
Vector.equals = Method.PUBLIC(function (vector, v2)
    return (v2 ~= nil and (vector.x == v2.x) and (vector.y == v2.y))
end)
Vector.normalize = Method.PUBLIC(function (vector, thickness)
    if vector.x == 0 and vector.y == 0 then return end
    local norm = thickness / vector.length
    vector.x = vector.x * norm
    vector.y = vector.y * norm
end)
Vector.add = Method.PUBLIC(function (vector, v2, res)
    (res or Vector.new()).setTo(v2.x + vector.x, v2.y + vector.y)
    return res
end)
Vector.subtract = Method.PUBLIC(function (vector, v2, res)
    (res or Vector.new()).setTo(vector.x + v2.x, vector.y - v2.y)
    return res
end)

Vector.polar = Method.PUBLIC(function (Self, len, angle, res)
    (res or Self.new()).setTo(len * math.cos(angle), len * math.sin(angle))
    return res
end, true)
Vector.distance = Method.PUBLIC(function (Self, v1, v2)
    return math.sqrt((v1.x - v2.x)^2 + (v1.y - v2.y)^2)
end, true)
Vector.interpolate = Method.PUBLIC(function (Self, v1, v2, f, res)
    (res or Vector.new()).setTo(v2.x + f * (v1.x - v2.x), v2.y + f * (v1.y - v2.y))
    return res
end, true)
Vector.new = function (x, y)
    local vector = Vector.create()
    vector.setTo(x, y)
    return vector
end

return Vector