local Class = require 'ChessyXeL.Class'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Pool = require 'ChessyXeL.util.Pool'
local Math = require 'ChessyXeL.math.Math'
---@class math.Point : Class
local Point = Class 'Point'

Point.EPSILON = FieldStatus.PUBLIC('default', 'default', 0.0000001, true)
Point.EPSILON_SQUARED = FieldStatus.PUBLIC('default', 'default', Point.EPSILON * Point.EPSILON, true)

Point.pool = FieldStatus.PUBLIC('default', 'default', Pool(Point), true)
Point._point1 = FieldStatus.PUBLIC('default', 'default', Point(), true)
Point._point2 = FieldStatus.PUBLIC('default', 'default', Point(), true)
Point._point3 = FieldStatus.PUBLIC('default', 'default', Point(), true)

Point._weak = FieldStatus.NORMAL('default', 'default', false)
Point._inPool = FieldStatus.NORMAL('default', 'default', false)
Point.x = FieldStatus.PUBLIC('default', function (V, I, F)
    I.x = V
end, 0)
Point.y = FieldStatus.PUBLIC('default', function (V, I, F)
    I.y = V
end, 0)

Point.lengthSquared = FieldStatus.PUBLIC(function (I, F)
    return I.x * I.x + I.y * I.y
end)
Point.length = FieldStatus.PUBLIC(function (I, F)
    return math.sqrt(I.lengthSquared)
end)
Point.radians = FieldStatus.PUBLIC(function(I)
    return 0
end, function (V, I, F)
    local len = I.length
    I.x = len * math.cos(V)
    I.y = len * math.sin(V)
    -- I.radians = V
    return V
end, 0)
Point.dx = FieldStatus.PUBLIC(function ()
    
end, 'never')
Point.dy = FieldStatus.PUBLIC(function ()
    
end, 'never')

Point.destroy = Method.PUBLIC(function(p)
    p.x = 0
    p.y = 0
end)
Point.set = Method.PUBLIC(function (point, x, y)
    point.x = x or 0
    point.y = y or 0
    return point
end)
Point.put = Method.PUBLIC(function (point)
    if not point._inPool then
        point._inPool = true
        point._weak = false
        Point.pool.putUnsafe(point)
    end
end)
Point.putWeak = Method.PUBLIC(function (point)
    if point._weak then
        point.put()
    end
end)
Point.equals = Method.PUBLIC(function (I, point)
    local res = Math.equal(I.x, point.x) and Math.equal(I.y, point.y)
    point.putWeak()
    return res
end)
Point.copyFrom = Method.PUBLIC(function (I, point)
    I.set(point.x, point.y)
    point.putWeak()
    return I
end)
Point.subtract = Method.PUBLIC(function (I, x, y)
    I.x = I.x - x
    I.y = I.y - y
    return I
end)
Point.subtractPoint = Method.PUBLIC(function (I, point)
    I = I.subtract(point.x, point.y)
    point.putWeak()
    return I
end)
Point.pivotRadians = Method.PUBLIC(function (I, pivot, radians)
    Point._point1.copyFrom(I).subtractPoint(pivot)
    Point._point1.radians = Point._point1.radians + radians
    I.set(Point._point1.x + pivot.x, Point._point1.y + pivot.y)
    pivot.putWeak()
    return I
end)
Point.pivotDegrees = Method.PUBLIC(function (I, pivot, deg)
    return I.pivotRadians(pivot, math.rad(deg))
end)

Point.floor = Method.PUBLIC(function (p)
    p.x = math.floor(p.x)
    p.y = math.floor(p.y)
    return p
end)

Point.get = Method.PUBLIC(function (Self, x, y)
    local point = Self.pool.get().set(x or 0, y or 0)
    local og = point.privateAccess
    point.privateAccess = true
    point._inPool = false
    point.privateAccess = og
    return point
end, true)
Point.weak = Method.PUBLIC(function (Self, x, y)
    local point = Self.get(x, y)
    point._weak = true
    return point
end, true)
Point.instanceMeta.__sub = function (a, b)
    local res = Point.get(a.x - b.x, a.y - b.y)
    a.putWeak()
    b.putWeak()
    return res
end
Point.instanceMeta.__add = function (a, b)
    local res = Point.get(a.x + b.x, a.y + b.y)
    a.putWeak()
    b.putWeak()
    return res
end
Point.instanceMeta.__mul = function (a, b)
    local res = Point.get(a.x * b, a.y * b)
    a.putWeak()
    return res
end
Point.instanceMeta.__div = function (a, b)
    local res = Point.get(a.x / b, a.y / b)
    a.putWeak()
    return res
end

Point.new = function (x, y)
    return Point.create().set(x, y)
end

return Point