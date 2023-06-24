local Sprite = require 'ChessyXeL.display.Sprite'
local Text = require 'ChessyXeL.display.text.Text'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local Object = require 'ChessyXeL.display.object.Object'

---@class display.addons.Button : display.Sprite
local Button = Sprite.extend 'Button'

local function mouseOverlaps(object, camera)
    return getMouseX(camera or 'other') >= object.x and
        getMouseX(camera or 'other') <= object.x + object.width and
        getMouseY(camera or 'other') >= object.y and
        getMouseY(camera or 'other') <= object.y + object.height
end

Button.onClick = FieldStatus.PUBLIC('default', 'default', nil)
Button.label = FieldStatus.PUBLIC('default', 'default', nil)
Button.text = FieldStatus.PUBLIC(function (I) return I.label.text end, function (V, I) I.label.text = V end)
Button.new = function (x, y, text, onClick)
    local button = Button.create(x, y)
    button.label = Text(x, y, 0, text, 14, 0xFFffffff)
    button.onClick = onClick
    button.update = function ()
        if button.label ~= nil then
            button.label.x = button.x + (button.width - button.label.width) / 2
            button.label.y = button.y + (button.height - button.label.height) / 2
            if button.label.camera ~= button.camera then
                button.label.camera = button.camera
            end
        end
        if mouseOverlaps(button, button.camera) then
            button.label.alpha = button.alpha / 1.5
            if mouseClicked() then
                if button.onClick then
                    button.onClick()
                end
            end
        else
            button.label.alpha = button.alpha 
        end
    end
    return button
end

Button.override('add', function (super, button, onTop)
    super(button, onTop)
    button.label.add(onTop)
    button.label.order = button.order
    button.order = button.order
end)
Button.override('kill', function (super, button)
    super(button)
    button.label.kill()
end)
Button.override('destroy', function (super, button)
    super(button)
    button.label.destroy()
end)

return Button