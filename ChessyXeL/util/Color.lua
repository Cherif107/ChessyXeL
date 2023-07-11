local Class = require "ChessyXeL.Class"
local FieldStatus = require "ChessyXeL.FieldStatus"
local Method = require "ChessyXeL.Method"
local Math = require "ChessyXeL.math.Math"
local Ease = require "ChessyXeL.tweens.Ease"
local Bit = require 'ChessyXeL.util.Bit'
local LogClass = require 'ChessyXeL.util.LogClass'
local function switchCase(var, cases)
    for _, __ in pairs(cases) do
        if var == _ then
            return __
        end
    end
    return cases.default
end

local ColorField = function(color)
    return FieldStatus.PUBLIC("default", "never", bit.tobit(color), true)
end
local ColorMethod = function(func)
    return Method.PUBLIC(function(class, ...)
        return func(...)
    end, true)
end
 --
--[[
          |\      _,,,---,,_
    ZZZzz /,`.-'`'    -.  ;-;;,_
         |,4-  ) )-,_. ,\ (  `'-'
        '---''(_/--'  `-'\_)  
]] ---@class util.Color : Class A Class used to make Colors and such with a bunch of methods and variables
--- [[ FIELDS : START ]] ---
---@field public TRANSPARENT integer Transparent Color
---@field public WHITE integer White Color
---@field public GRAY integer Gray Color
---@field public BLACK integer Black Color
---@field public CYAN integer Cyan Color
---@field public BLUE integer Blue Color
---@field public GREEN integer Green Color
---@field public LIME integer Lime Color
---@field public YELLOW integer Yellow Color
---@field public ORANGE integer Orange Color
---@field public RED integer Red Color
---@field public PINK integer Pink Color
---@field public MAGENTA integer Magenta Color
---@field public PURPLE integer Purple Color
--- [[ FIELDS : END ]] ---
local Color = LogClass.extend "Color"

Color.BLACK = ColorField(0xFF000000)
Color.GRAY = ColorField(0xFF808080)
Color.WHITE = ColorField(0xFFffffff)

Color.BLUE = ColorField(0xFF0000FF)
Color.CYAN = ColorField(0xFF00FFFF)
Color.GREEN = ColorField(0xFF008000)
Color.LIME = ColorField(0xFF00FF00)
Color.YELLOW = ColorField(0xFFFFFF00)
Color.ORANGE = ColorField(0xFFFFA500)
Color.RED = ColorField(0xFFFF0000)
Color.PINK = ColorField(0xFFFFC0CB)
Color.MAGENTA = ColorField(0xFFFF00FF)
Color.PURPLE = ColorField(0xFF800080)
Color.TRANSPARENT = ColorField(0x00000000)

Color.override('onSetLog', function (super, Self, color, field, value)
    if field == 'value' and color.parent then
        color.parent[color.parentField] = color
    end
end) 

Color.fromString =
    ColorMethod(
    function(Hex)
        if not string.find(Hex, "0x") then
            Hex = "0xFF" .. Hex
        end
        return bit.tobit(tonumber(Hex))
    end
)
Color.fromRGB =
    ColorMethod(
    function(red, green, blue, alpha)
        return Color().setRGB(red, green, blue, alpha)
    end
)
Color.fromRGBFloat =
    ColorMethod(
    function(red, green, blue, alpha)
        return Color().setRGBFloat(red, green, blue, alpha)
    end
)
Color.fromCMYK =
    ColorMethod(
    function(Cyan, Magenta, Yellow, Black, Alpha)
        return Color().setCMYK(Cyan, Magenta, Yellow, Black, Alpha or 1)
    end
)
Color.fromHSB =
    Method.PUBLIC(
    function(me, Hue, Saturation, Brightness, Alpha)
        return Color().setHSB(Hue, Saturation, Brightness, Alpha or 1)
    end, true
)
Color.fromHSL =
    ColorMethod(
    function(Hue, Saturation, Lightness, Alpha)
        return Color().setHSL(Hue, Saturation, Lightness, Alpha or 1)
    end
)

Color.parseColor = function(color)
    if type(color) == "table" then
        if color.__type == "Color" then
            return color.value
        end
        return Color.fromRGB(color[1], color[2], color[3]).value
    elseif type(color) == "string" then
        return Color.fromString(color)
    elseif type(color) == 'number' then
        return bit.tobit(color)
    end
end

Color.normalize = function(color)
    if type(color) == 'table' then
        if color.__type == 'Color' then
            return color 
        end
        return Color.fromRGB(color[1], color[2], color[3])
    end
    return Color(color)
end

function Color.interpolate(Color1, Color2, Factor)
    Factor = Factor or 0.5

    local PColor1 = Color.normalize(Color1)
    local PColor2 = Color.normalize(Color2)

    local r = bit.rshift((PColor2.red - PColor1.red) * Factor + PColor1.red, 0)
    local g = bit.rshift((PColor2.green - PColor1.green) * Factor + PColor1.green, 0)
    local b = bit.rshift((PColor2.blue - PColor1.blue) * Factor + PColor1.blue, 0)
    local a = bit.rshift((PColor2.alpha - PColor1.alpha) * Factor + PColor1.alpha, 0)

    return Color.fromRGB(
        bit.band(r, 0xff),
        bit.band(g, 0xff),
        bit.band(b, 0xff),
        bit.band(a, 0xff)
    )
end

function Color.multiInterpolate(colors, Factor)
    Factor = Factor or 0.5

    local numColors = #colors
    local normalizedColors = {}
    for i = 1, numColors do
        normalizedColors[i] = Color.normalize(colors[i])
    end

    local intervalSize = 1 / (numColors - 1)
    local intervalIndex = math.floor(Factor / intervalSize) + 1
    if intervalIndex >= numColors then return colors[numColors] end

    local intervalFactor = (Factor - intervalSize * (intervalIndex - 1)) / intervalSize
    local color1 = normalizedColors[intervalIndex]
    local color2 = normalizedColors[intervalIndex + 1]

    local r = bit.rshift((color2.red - color1.red) * intervalFactor + color1.red, 0)
    local g = bit.rshift((color2.green - color1.green) * intervalFactor + color1.green, 0)
    local b = bit.rshift((color2.blue - color1.blue) * intervalFactor + color1.blue, 0)
    local a = bit.rshift((color2.alpha - color1.alpha) * intervalFactor + color1.alpha, 0)

    return Color.fromRGB(
        bit.band(r, 0xff),
        bit.band(g, 0xff),
        bit.band(b, 0xff),
        bit.band(a, 0xff)
    )
end

function Color.blend(Color1, Color2)
    return Color.interpolate(Color1, Color2, 0.5)
end

function Color.gradient(Color1, Color2, Steps, ease)
    ease = ease or Ease.linear
    local gradientArray = {}
    for s = 1, Steps do
        gradientArray[s] = Color.interpolate(Color1, Color2, ease(s / (Steps - 1)))
    end
    return gradientArray
end
function Color.multiGradient(colors, Steps, ease)
    ease = ease or Ease.linear
    local gradientArray = {}
    for s = 1, Steps do
        gradientArray[s] = Color.multiInterpolate(colors, ease(s / (Steps - 1)))
    end
    return gradientArray
end

function Color.getHSBColorWheel(Alpha)
    local c = {}
    for a = 0, 360 do
        c[a] = Color.fromHSB(a, 1, 1, Alpha)
    end
    return c
end

function Color.getLightColorWheel(Alpha)
    local c = {}
    for a = 0, 360 do
        c[a] = Color.fromHSB(a, a / 360, a / 360, Alpha)
    end
    return c
end

Color.parent = FieldStatus.PUBLIC("default", "default", nil)
Color.parentField = FieldStatus.PUBLIC('default', 'default', 'color')
Color.value = FieldStatus.PUBLIC("default", "default", Color.BLACK)
Color.red =
    FieldStatus.PUBLIC(
    function(t, f)
        return bit.band(bit.rshift(t.value, 16), 0xff)
    end,
    function(v, t, f)
        t.value = bit.bor(bit.band(t.value, 0xff00ffff), bit.lshift(t.boundChannel(v), 16))
        return v
    end,
    0
)
Color.green =
    FieldStatus.PUBLIC(
    function(t)
        return bit.band(bit.rshift(t.value, 8), 0xff)
    end,
    function(v, t)
        t.value = bit.bor(bit.band(t.value, 0xffff00ff), bit.lshift(t.boundChannel(v), 8))
        return v
    end, 0
)
Color.blue =
    FieldStatus.PUBLIC(
    function(t)
        return bit.band(t.value, 0xff)
    end,
    function(v, t)
        t.value = bit.bor(bit.band(t.value, 0xffffff00), t.boundChannel(v))
        return v
    end, 0
)
Color.alpha =
    FieldStatus.PUBLIC(
    function(t)
        return bit.band(bit.rshift(t.value, 24), 0xff)
    end,
    function(v, t)
        t.value = bit.bor(bit.band(t.value, 0x00ffffff), bit.lshift(t.boundChannel(v), 24))
        return v
    end, 0
)

Color.cyan =
    FieldStatus.PUBLIC(
    function(t)
        return (1 - t.redFloat - t.black) / t.brightness
    end,
    function(v, t)
        t.cyan = t.setCMYK(v, t.magenta, t.yellow, t.black)
        return v
    end
)
Color.magenta =
    FieldStatus.PUBLIC(
    function(t)
        return (1 - t.greenFloat - t.black) / t.brightness
    end,
    function(v, t)
        t.magenta = t.setCMYK(t.cyan, v, t.yellow, t.black)
        return v
    end
)
Color.yellow =
    FieldStatus.PUBLIC(
    function(t)
        return (1 - t.blueFloat - t.black) / t.brightness
    end,
    function(v, t)
        t.yellow = t.setCMYK(t.cyan, t.magenta, v, t.black)
        return v
    end
)
Color.black =
    FieldStatus.PUBLIC(
    function(t)
        return 1 - t.brightness
    end,
    function(v, t)
        t.cyan = t.setCMYK(t.cyan, t.magenta, t.yellow, v)
        return v
    end
)

Color.redFloat =
    FieldStatus.PUBLIC(
    function(t)
        return t.red / 255
    end,
    function(v, t)
        t.red = Math.round(v * 255)
        return v
    end
)
Color.greenFloat =
    FieldStatus.PUBLIC(
    function(t)
        return t.green / 255
    end,
    function(v, t)
        t.green = Math.round(v * 255)
        return v
    end
)
Color.blueFloat =
    FieldStatus.PUBLIC(
    function(t)
        return t.blue / 255
    end,
    function(v, t)
        t.blue = Math.round(v * 255)
        return v
    end
)
Color.alphaFloat =
    FieldStatus.PUBLIC(
    function(t)
        return t.alpha / 255
    end,
    function(v, t)
        t.alpha = Math.round(v * 255)
        return v
    end
)

Color.saturation =
    FieldStatus.PUBLIC(
    function(t)
        return (t.maxColor() - t.minColor()) / t.brightness
    end,
    function(v, t)
        t.setHSB(t.hue, v, t.brightness, t.alphaFloat)
        return v
    end
)

Color.hex =
    FieldStatus.PUBLIC(
    function(I)
        return "0x" .. bit.tohex(I.value)
    end,
    "never",
    "?"
)

Color.info =
    FieldStatus.PUBLIC(
    function(I)
        return I.getInfo()
    end,
    "never",
    "?"
)
Color.instanceMeta.__tostring = function(t)
    return t.info
end
Color.instanceMeta.__add = function(t, v)
    v = Color.normalize(v)
    t = Color.normalize(t)
    return Color.fromRGB(t.red + v.red, t.green + v.green, t.blue + v.blue)
end
Color.instanceMeta.__sub = function(t, v)
    v = Color.normalize(v)
    t = Color.normalize(t)
    return Color.fromRGB(t.red - v.red, t.green - v.green, t.blue - v.blue)
end
Color.instanceMeta.__mul = function(t, v)
    v = Color.normalize(v)
    t = Color.normalize(t)
    return Color.fromRGB(t.redFloat * v.redFloat, t.greenFloat * v.greenFloat, t.blueFloat * v.blueFloat)
end
Color.instanceMeta.__eq = function(t, v)
    debugPrint('lol')
    return Color.parseColor(t) == Color.parseColor(v)
end

Color.boundChannel =
    Method.PUBLIC(
    function(color, value)
        return (value > 0xff and 0xff or value < 0 and 0 or value)
    end
)
Color.maxColor =
    Method.PUBLIC(
    function(color)
        return math.max(color.redFloat, color.blueFloat, color.greenFloat)
    end
)
Color.minColor =
    Method.PUBLIC(
    function(color)
        return math.min(color.redFloat, color.blueFloat, color.greenFloat)
    end
)

Color.brightness =
    FieldStatus.PUBLIC(
    function(t)
        return t.maxColor()
    end,
    function(v, t)
        t.setHSB(t.hue, t.saturation, v, t.alphaFloat)
        return v
    end
)

Color.lightness =
    FieldStatus.PUBLIC(
    function(I)
        return (I.maxColor() + I.minColor()) / 2
    end,
    function(V, I)
        I.setHSL(I.hue, I.saturation, V, I.alphaFloat)
        return V
    end,
    0
)

Color.hue =
    FieldStatus.PUBLIC(
    function(I)
        local hueRad = math.atan2(math.sqrt(3) * (I.greenFloat - I.blueFloat), 2 * I.redFloat - I.greenFloat - I.blueFloat)
        local hue = 0
        if hueRad ~= 0 then
            hue = 180 / math.pi * hueRad
        end
        return hue < 0 and hue + 360 or hue
    end,
    function(V, I)
        I.setHSB(V, I.saturation, I.brightness, I.alphaFloat)
        return V
    end,
    0
)

Color.setRGB =
    Method.PUBLIC(
    function(color, red, green, blue, alpha) -- set Color RGB
        color.red, color.green = red or 0, green or 0
        color.blue, color.alpha = blue or 0, alpha or 255
        return color
    end
)
Color.setRGBFloat =
    Method.PUBLIC(
    function(color, red, green, blue, alpha) -- set Color RGB
        color.redFloat, color.greenFloat = red or 0, green or 0
        color.blueFloat, color.alphaFloat = blue or 0, alpha or 1
        return color
    end
)
Color.setHSChromaMatch =
    Method.PUBLIC(
    function(color, Hue, Chroma, Match, Alpha)
        Hue = Hue % 360
        local hueD = Hue / 60
        local mid = Chroma * (1 - math.abs(hueD % 2 - 1)) + Match
        Chroma = Chroma + Match

        switchCase(
            math.floor(hueD),
            {
                [0] = function()
                    return color.setRGBFloat(Chroma, mid, Match, Alpha)
                end,
                function()
                    return color.setRGBFloat(mid, Chroma, Match, Alpha)
                end,
                function()
                    return color.setRGBFloat(Match, Chroma, mid, Alpha)
                end,
                function()
                    return color.setRGBFloat(Match, mid, Chroma, Alpha)
                end,
                function()
                    return color.setRGBFloat(mid, Match, Chroma, Alpha)
                end,
                function()
                    return color.setRGBFloat(Chroma, Match, mid, Alpha)
                end,
                default = function()
                    return color
                end
            }
        )()
        return color
    end
)

Color.setHSB =
    Method.PUBLIC(
    function(color, Hue, Saturation, Brightness, Alpha)
        local chroma = Brightness * Saturation
        local match = Brightness - chroma
        return color.setHSChromaMatch(Hue, chroma, match, Alpha)
    end
)
Color.setHSL =
    Method.PUBLIC(
    function(color, Hue, Saturation, Lightness, Alpha)
        local chroma = (1 - math.abs(2 * Lightness - 1)) * Saturation
        local match = Lightness - chroma / 2
        return color.setHSChromaMatch(Hue, chroma, match, Alpha)
    end
)
Color.setCMYK =
    Method.PUBLIC(
    function(color, Cyan, Magenta, Yellow, Black, Alpha)
        Black = Black or 0
        color.redFloat = (1 - (Cyan or 0)) * (1 - Black)
        color.greenFloat = (1 - (Magenta or 0)) * (1 - Black)
        color.blueFloat = (1 - (Yellow or 0)) * (1 - Black)
        color.alphaFloat = (Alpha or 1)
        return color
    end
)
Color.getInfo =
    Method.PUBLIC(
    function(color)
        return "Alpha: " ..
            color.alpha ..
                " | Red: " ..
                    color.red ..
                        " | Green: " ..
                            color.green ..
                                " | Blue: " ..
                                    color.blue ..
                                        "\n" ..
                                            "Hue: " ..
                                                Math.roundDecimal(color.hue, 2) ..
                                                    " | Saturation: " ..
                                                        Math.roundDecimal(color.saturation, 2) ..
                                                            "\n" ..
                                                                "Brightness: " ..
                                                                    Math.roundDecimal(color.brightness, 2) ..
                                                                        " | Lightness:" ..
                                                                            Math.roundDecimal(color.lightness, 2)
    end
)

Color.getInverted =
    Method.PUBLIC(
    function(color)
        local a = color.alpha
        local o = Color.WHITE - color
        o.alpha = a
        return o
    end
)
Color.getLightened =
    Method.PUBLIC(
    function(color, Factor)
        Factor = Math.bound((Factor or 0.2), 0, 1)
        local o = Color.new(color.value)
        o.lightness = o.lightness + (1 - color.lightness) * Factor
        return o
    end
)

Color.getDarkened =
    Method.PUBLIC(
    function(color, Factor)
        Factor = Math.bound((Factor or 0.2), 0, 1)
        local o = Color.new(color.value)
        o.lightness = o.lightness * (1 - Factor)
        return o
    end
)
Color.to24Bit =
    Method.PUBLIC(
    function(color)
        return bit.band(color.value, 0xffffff)
    end
)
Color.getTridacHarmony =
    Method.PUBLIC(
    function(color)
        local t1 =
            Color.fromHSB(
            Math.wrap(math.floor(color.hue) + 120, 0, 359),
            color.saturation,
            color.brightness,
            color.alphaFloat
        )
        local t2 =
            Color.fromHSB(
            Math.wrap(math.floor(t1.hue) + 120, 0, 359),
            color.saturation,
            color.brightness,
            color.alphaFloat
        )
        return {color1 = color, color2 = t1, color3 = t2}
    end
)
Color.getSplitComplementHarmony =
    Method.PUBLIC(
    function(color, Threshold)
        Threshold = Threshold or 30
        local opp = Math.wrap(math.floor(color.hue) + 180, 0, 350)
        local war =
            Color.fromHSB(Math.wrap(opp - Threshold, 0, 350), color.saturation, color.brightness, color.alphaFloat)
        local col =
            Color.fromHSB(Math.wrap(opp + Threshold, 0, 350), color.saturation, color.brightness, color.alphaFloat)
        return {original = color, warmer = war, colder = col}
    end
)
Color.getAnalogousHarmony =
    Method.PUBLIC(
    function(color, Threshold)
        Threshold = Threshold or 30
        local war =
            Color.fromHSB(
            Math.wrap(math.floor(color.hue) - Threshold, 0, 350),
            color.saturation,
            color.brightness,
            color.alphaFloat
        )
        local col =
            Color.fromHSB(
            Math.wrap(math.floor(color.hue) + Threshold, 0, 350),
            color.saturation,
            color.brightness,
            color.alphaFloat
        )
        return {original = color, warmer = war, colder = col}
    end
)
Color.getComplementHarmony =
    Method.PUBLIC(
    function(color)
        return Color.fromHSB(
            Math.wrap(math.floor(color.hue) + 180, 0, 350),
            color.saturation,
            color.brightness,
            color.alphaFloat
        )
    end
)

Color.getTetradicHarmony =
    Method.PUBLIC(
    function(color)
        local t1 =
            Color.fromHSB(
            Math.wrap(math.floor(color.hue) - 60, 0, 359),
            color.saturation,
            color.brightness,
            color.alphaFloat
        )
        local t2 =
            Color.fromHSB(
            Math.wrap(math.floor(color.hue) + 120, 0, 359),
            color.saturation,
            color.brightness,
            color.alphaFloat
        )
        local t3 = Color.fromHSB(
            Math.wrap((math.floor(color.hue) - 180), 0, 359),
            color.saturation,
            color.brightness,
            color.alphaFloat
        )
        return {color1 = t1, color2 = color, color3 = t2, color4 = t3}
    end
)

Color.new = function(value)
    local this = Color.create()
    this.value = Color.parseColor(value or Color.BLACK)
    return this
end

return Color