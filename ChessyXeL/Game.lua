local ClassObject = require 'ChessyXeL.display.object.ClassObject'
local Object = require 'ChessyXeL.display.object.Object'
local Mouse = require 'ChessyXeL.input.Mouse'
local Sprite = require 'ChessyXeL.display.Sprite'
local Text = require 'ChessyXeL.display.text.Text'

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

    playerStrums = Obj('playerStrums'),
    opponentStrums = Obj('opponentStrums'),
    strumLineNotes = Obj('strumLineNotes')
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
