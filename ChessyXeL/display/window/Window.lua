local HScript = require 'ChessyXeL.hscript.HScript'
local Object = require 'ChessyXeL.display.object.Object'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local Stage = require 'ChessyXeL.display.window.Stage'

---@class display.window.Window : display.object.Object
local Window = Object.extend 'Window'

Object.waitingList.add(function ()
    HScript.execute [[
        import openfl.Lib;

        function __chessyxel__makeWindow(name, ?title = '', x = 0, y = 0, width, height, ?borderless = false, ?alwaysOnTop = false){
            setVar(name, Lib.application.createWindow({
                x: x,
                y: y,
                width: width,
                height: height,
                borderless: borderless,
                alwaysOnTop: alwaysOnTop,
                title: title
            }));
            return null;
        }
    ]]
end)

Window.stage = FieldStatus.PUBLIC('default', 'default', nil)
Window.initialize = FieldStatus.PUBLIC('default', 'default', nil)
Window.new = function (title, x, y, width, height)
    local window = Window.create()
    window.initialize = function() HScript.call('__chessyxel__makeWindow', window.name, title, x, y, width, height) end
    return window
end

return Window