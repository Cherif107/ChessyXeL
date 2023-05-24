local Class = require 'ChessyXeL.Class'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Group = require 'ChessyXeL.groups.Group'
local Text = require 'ChessyXeL.display.text.Text'
local Sprite = require 'ChessyXeL.display.Sprite'
local Log = require 'ChessyXeL.debug.Log'
local TableUtil = require 'ChessyXeL.util.TableUtil'
local TextFormatTextFormatMarkerPair = require 'ChessyXeL.display.text.TextFormatMarkerPair'
local TextFormat = require 'ChessyXeL.display.text.TextFormat'

---@class debug.Debugger : Class
local Debugger = Class 'Debugger'

Debugger.borderSprite = FieldStatus.PUBLIC('default', 'default', nil)
Debugger.centerSprite = FieldStatus.PUBLIC('default', 'default', nil)
Debugger.topSprite = FieldStatus.PUBLIC('default', 'default', nil)
Debugger.debugGroup = FieldStatus.PUBLIC('default', 'default', nil)
Debugger.debugText = FieldStatus.PUBLIC('default', 'default', nil)

local format = TextFormatTextFormatMarkerPair(TextFormat(0xFFff0000), '<error>')
local format2 = TextFormatTextFormatMarkerPair(TextFormat(0xFFffA200), '<function>')
Debugger.onLog = Method.PUBLIC(function (debugger, log)
    table.insert(debugger.debugGroup, 1, log)
    if #debugger.debugGroup > 16 then
        table.remove(debugger.debugGroup, 17)
    end

    local str = ''
    for i = #debugger.debugGroup, 1, -1 do
        str = str..debugger.debugGroup[i]..'\n'
    end
    debugger.debugText.text = str
    if str:find '<error>' then
        if str:find '<function>' then
            return debugger.debugText.applyMarkup(str, {format, format2})
        end
        debugger.debugText.applyMarkup(str, {format})
    end
end)
Debugger.new = function ()
    local debug = Debugger.create()

    debug.borderSprite = Sprite().makeGraphic(1270, 300, 0xFF1b091f)
    debug.borderSprite.camera = 'other'
    debug.borderSprite.screenCenter('X')
    debug.borderSprite.y = 720 - 290

    debug.centerSprite = Sprite().makeGraphic(1250, 250, 0xFF200551)
    debug.centerSprite.camera = 'other'
    debug.centerSprite.screenCenter('X')
    debug.centerSprite.y = 720 - 260

    debug.topSprite = Sprite().makeGraphic(1270, 10, 0xFF520052)
    debug.topSprite.camera = 'other'
    debug.topSprite.screenCenter('X')
    debug.topSprite.y = 720 - 280 
    
    debug.borderSprite.add(true)
    debug.centerSprite.add(true)
    debug.topSprite.add(true)

    debug.debugGroup = {}
    debug.debugText = Text(15, 720 - 255, 0, '', 15, 0xFFffffff)
    debug.debugText.alignment = 'LEFT'
    debug.debugText.camera = 'other'
    debug.debugText.add(true)

    -- debug.borderSprite.order = 5000
    -- debug.centerSprite.order = 5001
    -- debug.topSprite.order = 5002
    -- debug.debugText.order = 5003
    return debug
end
Debugger.debugger = FieldStatus.PUBLIC('default', 'default', Debugger(), true)

local Stage = require 'ChessyXeL.Stage'
Stage.set('onCreate', function ()
    Log.logger.onLog = Debugger.debugger.onLog
end)

return Debugger