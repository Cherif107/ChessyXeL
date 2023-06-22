local Sprite = require 'ChessyXeL.display.Sprite'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Object = require 'ChessyXeL.display.object.Object'

---@class display.addons.InversedSprite : display.Sprite
local InversedSprite = Sprite.extend 'InversedSprite'

InversedSprite.y = FieldStatus.PUBLIC(function (I, F)
    return screenHeight - getProperty(I.name .. '.y') - I.height
end, function (V, I, F)
    return Object.waitingList.add(function ()
        return I.set('y', screenHeight - V - I.height)
    end)
end, 0)

return InversedSprite