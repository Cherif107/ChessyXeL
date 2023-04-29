local HScript = require 'ChessyXeL.hscript.HScript'
local Signal = require 'ChessyXeL.Signal'
---@class Signals
local Signals = {
    preUpdate = Signal(),
    postUpdate = Signal(),

    preDraw = Signal(),
    postDraw = Signal(),

    focusLost = Signal(),
    focusGained = Signal(),
}

local O = onCreate
function onCreate()
    luaDebugMode  = true
    if O then O() end
    for name, signal in pairs(Signals) do
        HScript.setFunction('CHESSYXEL_SIGNAL_'..name, signal.dispatch)
        HScript.execute('FlxG.signals.'..name..'.add(CHESSYXEL_SIGNAL_'..name..');\n')
    end
end

local OD = onDestroy
function onDestroy()
    if OD then OD() end
    for name, signal in pairs(Signals) do
        HScript.execute('\nFlxG.signals.'..name..'.remove(CHESSYXEL_SIGNAL_'..name..');\n')
    end
end

return Signals