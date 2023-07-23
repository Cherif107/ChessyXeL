local ClassObject = require 'ChessyXeL.display.object.ClassObject'
local Object = require 'ChessyXeL.display.object.Object'
local Mouse = require 'ChessyXeL.input.Mouse'
local Sprite = require 'ChessyXeL.display.Sprite'
local Text = require 'ChessyXeL.display.text.Text'
local Group = require 'ChessyXeL.groups.Group'

local function Obj(name)
    local obj = Object()
    obj.name = name
    return obj
end

---@class Game a class that contains classes / objects from playstate etc
local Game = {
    FlxG = ClassObject('flixel.FlxG'),
    Conductor = ClassObject('Conductor'),
    ClientPrefs = ClassObject('ClientPrefs'),
    Main = ClassObject('Main'),
    Lib = ClassObject('openfl.Lib'),

    mouse = Mouse(),

    boyfriend = Sprite.fromTag('boyfriend'),
    gf = Sprite.fromTag('gf'),
    dad = Sprite.fromTag('dad'),

    timeBar = Sprite.fromTag('timeBar'),
    timeBarBG = Sprite.fromTag('timeBarBG'),
    timeTxt = Text.fromTag('timeTxt'),

    healthBar = Sprite.fromTag('healthBar'),
    healthBarBG = Sprite.fromTag('healthBarBG'),

    scoreTxt = Text.fromTag('scoreTxt'),
    iconP1 = Sprite.fromTag('iconP1'),
    iconP2 = Sprite.fromTag('iconP2'),

    members = Obj('members')
}

local function checkType(obj, tag)
    if type(obj.numFrames) == 'number' then
        if type(obj.borderColor) == 'number' then
            return Text.fromTag(tag)
        else
            return Sprite.fromTag(tag)
        end
    end

    if type(obj.ID) == 'number' and type(obj.maxSize) == 'number' and type(obj.length) == 'number' then
        local group = Group(obj.maxSize)
        group.name = tag
        for i = 0, obj.length - 1 do
            group.members[i + 1] = checkType(Obj(tag..'.members['..i..']'), tag..'.members['..i..']')
        end
        return group
    end

    return obj
end
setmetatable(Game, {
    __index = function (t, f)
        if getProperty and getProperty(f) ~= f then
            return getProperty(f)
        end

        local o = Object()
        o.name = f
        o = checkType(o, f)

        rawset(Game, f, o)
        return o
    end,
    __newindex = function (t, f, v)
        if getProperty and getProperty(f) ~= f then
            return setProperty(f, v)
        end
    end
})
return Game