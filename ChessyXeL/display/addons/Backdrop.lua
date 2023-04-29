local Sprite = require 'ChessyXeL.display.Sprite'
local HScript = require 'ChessyXeL.hscript.HScript'
local Point = require 'ChessyXeL.math.Point'
local Axes = require 'ChessyXeL.util.Axes'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local SpriteUtil = require 'ChessyXeL.hscript.SpriteUtil'
---@class Backdrop : display.Sprite
local Backdrop = Sprite.extend 'Backdrop'

Backdrop.repeatAxes = FieldStatus.PUBLIC('default', 'default', Axes.XY)
Backdrop.spacing = FieldStatus.PUBLIC('default', 'default', Point())

Backdrop._blitOffset = FieldStatus.NORMAL('default', 'default', Point())
Backdrop._prevDrawParams = FieldStatus.NORMAL('default', 'default', {
    graphicKey = nil,
    tilesX = -1,
    tilesY = -1,
    scaleX = 0.0,
    scaleY = 0.0,
    spacingX = 0.0,
    spacingY = 0.0,
    repeatAxes = Axes.XY,
    angle = 0.0
})


Backdrop.new = function (graphic, repeatAxes, spacingX, spacingY)
    local backdrop = Backdrop.create()
    backdrop.repeatAxes = repeatAxes or Axes.XY
    backdrop.spacing.set(spacingX, spacingY)

    HScript.execute()
    return backdrop
end