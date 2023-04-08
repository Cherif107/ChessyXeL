require 'ChessyXeL.util.StringUtil'
---@class math.Math A class that contains functions and variables that are useful for math stuff
local Math = {
    MIN_VALUE_FLOAT = -1.79769313486231570815e+308,
    MAX_VALUE_FLOAT = 1.79769313486231570815e+308,

    MIN_VALUE_INT = -0x7FFFFFFF,
    MAX_VALUE_INT = 0x7FFFFFFF,

    SQUARE_ROOT_OF_TWO = 1.41421356237,
    EPLISON = 0.0000001,
    isNaN = function (value)
        return (type(value) ~= 'number' or value ~= value)
    end
}

Math.roundDecimal = function (Value, Precision)
    local mult = 1
    for i = 1, Precision do
        mult = mult * 10
    end
    return Math.fround(Value * mult) / mult
end

Math.round = function (num)
    return math.floor(num + 0.5)
end

Math.bound = function (Value, Min, Max)
    local lowerBound = ((Min ~= nil and Value < Min) and Min or Value)
    return ((Max ~= nil and lowerBound > Max) and Max or lowerBound)
end

Math.lerp = function (a, b, ratio)
    return a + ratio * (b - a)
end

Math.inBounds = function (Value, Min, Max)
    return (Min == nil or Value >= Min) and (Max == nil or Value <= Max)
end

Math.isOdd = function (Value)
    return math.floor(Value) % 2 ~= 0
end

Math.isEven = function (Value)
    return math.floor(Value) % 2 == 0
end

Math.numericComparison = function (a, b)
    if (b > a) then
        return -1
    elseif (a > b) then
        return 1
    end
    return 0;
end

Math.pointInCoordinates = function (pointX, pointY, rectX, rectY, rectWidth, rectHeight)
    if (pointX >= rectX and pointX <= (rectX + rectWidth)) then
        if (pointY >= rectY and pointY <= (rectY + rectHeight)) then
            return true
        end
    end
    return false
end

-- Math.pointInRect
-- Math.mouseInRect

Math.maxAdd = function (Value, Amount, Max, Min)
    Value = Value + Amount
    if (Value > Max) then
        Value = Max;
    elseif (Value <= Min) then
        Value = Min
    end
    return Value;
end

Math.wrap = function (Value, Min, Max)
    local range = Max - Min + 1
    if (Value < Min) then
        Value = Value + range * math.floor((Min - Value) / range + 1)
    end
    return Min + (Value - Min) % range
end

Math.remapToRange = function (value, start1, stop1, start2, stop2)
    return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1))
end

Math.dotProduct = function (ax, ay, bx, by)
    return ax * bx + ay * by
end

Math.vectorLength = function (dx, dy)
    return math.sqrt(dx * dx + dy * dy)
end

Math.distanceBetween = function (SpriteA, SpriteB)
    local dx = (SpriteA.x + SpriteA.origin.x) - (SpriteB.x + SpriteB.origin.x)
    local dy = (SpriteA.y + SpriteA.origin.y) - (SpriteB.y + SpriteB.origin.y)
    return math.floor(Math.vectorLength(dx, dy));
end

Math.isDistanceWithin = function (SpriteA, SpriteB, Distance, IncludeEqual)
    local dx = (SpriteA.x + SpriteA.origin.x) - (SpriteB.x + SpriteB.origin.x)
    local dy = (SpriteA.y + SpriteA.origin.y) - (SpriteB.y + SpriteB.origin.y)
    if (IncludeEqual) then
        return dx * dx + dy * dy <= Distance * Distance
    else
        return dx * dx + dy * dy < Distance * Distance
    end
end

-- Math.distanceToPoint
-- Math.isDistanceToPointWithin

Math.getDecimals = function (Value)
    local S = tostring(Value):split('.')
    local decimals = 0
    if #S > 1 then
        decimals = #S[2]
    end
    return decimals
end

Math.equal = function (aValueA, aValueB, aDiff)
    aDiff = aDiff or Math.EPLISON
    return math.abs(aValueA - aValueB) <= aDiff
end

Math.signOf = function (Value)
    return ((Value < 0) and -1 or 1)
end

Math.sameSign = function (a, b)
    return Math.signOf(a) == Math.signOf(b)
end

return Math