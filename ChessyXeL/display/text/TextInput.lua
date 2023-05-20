local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local Text = require 'ChessyXeL.display.text.Text'
local Sprite = require 'ChessyXeL.display.Sprite'
local Timer = require 'ChessyXeL.util.Timer'

local function mouseOverlaps(object, camera)
    return getMouseX(camera or 'other') >= object.x and
        getMouseX(camera or 'other') <= object.x + object.width and
        getMouseY(camera or 'other') >= object.y and
        getMouseY(camera or 'other') <= object.y + object.height
end

---@class display.text.TextInput : display.text.Text
local TextInput = Text.extend 'TextInput'

local keyList = {
    zero = 0, one = 1, two = 2, three = 3, four = 4, five = 5, six = 6, seven = 7, eight = 8, nine = 9, period = '.',
    numpadzero = 0, numpadone = 1, numpadtwo = 2, numpadthree = 3, numpadfour = 4, numpadfive = 5, numpadsix = 6, numpadseven = 7, numpadeight = 8, numpadnine = 9, numpadperiod = '.',
    backslash = '\\', semicolon = ',', slash = '/' 
}
for i = 97, 122 do
    keyList[string.char(i)] = string.char(i)
end

TextInput.background = FieldStatus.PUBLIC('default', 'default', nil)
TextInput.canType = FieldStatus.PUBLIC('default', 'default', false)
TextInput.inputText = FieldStatus.PUBLIC('default', 'default', '')
TextInput.staticText = FieldStatus.PUBLIC('default', 'default', '')
TextInput.caret = FieldStatus.PUBLIC('default', 'default', nil)
TextInput.caretPosition = FieldStatus.PUBLIC('default', 'default', 1)
TextInput.caretTimer = FieldStatus.PUBLIC('default', 'default', nil)
TextInput.caretVisible = FieldStatus.PUBLIC('default', 'default', false)

TextInput.lastScroll = FieldStatus.PUBLIC('default', 'default', 0)
TextInput.inputType = FieldStatus.PUBLIC('default', 'default', 'NONE')

TextInput.onStartType = FieldStatus.PUBLIC('default', 'default', nil)
TextInput.onStopType = FieldStatus.PUBLIC('default', 'default', nil)
TextInput.onType = FieldStatus.PUBLIC('default', 'default', nil)
TextInput.onBackspace = FieldStatus.PUBLIC('default', 'default', nil)
TextInput.override('add', function (super, txt, onTop)
    txt.background.add(onTop)
    txt.background.order = txt.order + 1
    super(txt, onTop)
    txt.caret.add(onTop)
    txt.caret.order = txt.background.order + 1
end)
TextInput.override('kill', function (super, txt)
    super(txt)
    txt.background.kill()
    txt.caret.kill()
end)
TextInput.override('destroy', function (super, txt)
    super(txt)
    txt.background.destroy()
    txt.caret.destroy()
end)
TextInput.new = function (X, Y, Width, text, size, color, font)
    local input = TextInput.create(X, Y, Width, text, size, color, font)
    input.background = Sprite()
    input.staticText = text
    input.caretTimer = Timer()
    input.caret = Sprite().makeGraphic(2, input.height, 0xFf000000)
    input.update = function ()
        if mouseOverlaps(input, input.camera) then
            if mouseClicked() then
                input.canType = true
                input.text = (#input.inputText > 0 and input.inputText or '')
                input.caretPosition = #input.text + 1
                input.caretTimer.start(0.8, function (t)
                    if input.canType then
                        input.caretVisible = not input.caretVisible
                        t.reset(0.8)
                    end
                end)
                if input.onStartType then
                    input.onStartType()
                end
            end
        else
            if mouseClicked() and input.canType then
                input.canType = false
                input.text = (#input.inputText > 0 and input.inputText or input.staticText)
                input.caretVisible = false
                input.caretTimer.cancel()

                if input.onStopType then
                    input.onStopType(#input.inputText > 0 and input.inputText or '')
                end
            end
        end

        if input.canType then
            if keyboardJustPressed('RIGHT') then
                input.caretPosition = math.min(input.caretPosition + 1, #input.inputText)
            elseif keyboardJustPressed('LEFT') then
                input.caretPosition = math.max(input.caretPosition - 1, 0)
            elseif keyboardJustPressed('BACKSPACE') and input.caretPosition > 0 then
                input.inputText = input.inputText:sub(1, input.caretPosition - 1)..input.inputText:sub(input.caretPosition + 1)
                input.caretPosition = math.max(input.caretPosition - 1, 0)
                input.text = input.inputText
                if input.onBackspace then
                    input.onBackspace(input.text, input.caretPosition)
                end
                if input.onType then
                    input.onType('', input.text, input.caretPosition)
                end
            elseif keyboardJustPressed('SPACE') and input.inputType:upper() ~= 'NUMERIC' then
                input.inputText = input.inputText..' '
                input.caretPosition = math.min(input.caretPosition + 1, #input.inputText)
                input.text = input.inputText
                if input.onType then
                    input.onType(' ', input.text, input.caretPosition)
                end
            else
                for key, char in pairs(keyList) do
                    char = tostring(char)
                    if keyboardJustPressed(key:upper()) then
                        local typecheck = true
                        if input.inputType:upper() == 'NUMERIC' then
                            typecheck = (tonumber(char) ~= nil or char == '.')
                        elseif input.inputType:upper() == 'ALPHABETIC' then
                            typecheck = tonumber(char) == nil
                        end
                        if typecheck then
                            input.inputText = input.inputText:sub(1, input.caretPosition)..(keyboardPressed('SHIFT') and char:upper() or char)..input.inputText:sub(input.caretPosition + 1)
                            input.caretPosition = math.min(input.caretPosition + 1, #input.inputText)
                            input.text = input.inputText

                            if input.onType then
                                input.onType(char, input.text, input.caretPosition)
                            end
                        end
                    end
                end
            end
        end
        if input.caret.camera ~= input.camera then
            input.caret.camera = input.camera
        end
        if input.background.camera ~= input.camera then
            input.background.camera = input.camera
        end
        -- input.caret.setGraphicSize(20, input.height)
        input.caret.updateHitbox()
        local eachWidth = ((input.textField.textWidth + input.width) / 2 / math.max(1, #input.inputText))
        local doWidth = (input.textField.textWidth / math.max(1, #input.inputText))

        input.caret.x = input.alignment == 'center' and (input.x + (input.caretPosition * doWidth) + 2 + (input.textField.width - 2 - input.textField.textWidth) / 2 + input.textField.scrollH / 2) or input.alignment == 'left' and (input.x + (input.caretPosition * eachWidth)) or 0
        input.caret.y = input.y
        input.lastScroll = input.textField.scrollH
        if input.caretPosition * eachWidth > input.lastScroll + input.textField.width - 2 then
            input.textField.scrollH = -math.floor((input.textField.width - 2) - input.caretPosition * eachWidth) -- didnt work out sadly
            -- input.text = input.text:sub(#input.text - (input.textField))
        end
        input.caret.x = input.caret.x - input.textField.scrollH + 2

        input.caret.alpha = input.alpha
        input.caret.visible = (input.visible and input.canType and input.caretVisible)
        input.background.x = input.x - (input.background.width - input.width) / 2
        input.background.y = input.y - (input.background.height - input.height) / 2
    end
    return input
end

return TextInput

