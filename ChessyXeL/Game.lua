local ClassObject = require 'ChessyXeL.display.object.ClassObject'
local Object = require 'ChessyXeL.display.object.Object'
local Mouse = require 'ChessyXeL.input.Mouse'
local Sprite = require 'ChessyXeL.display.Sprite'

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
}
setmetatable(Game, {
    __index = function (t, f)
        local o = Object()
        o.name = f
        rawset(Game, f, o)
        return o
    end
})
return Game