local Class = require 'ChessyXeL.Class'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Sprite = require 'ChessyXeL.display.Sprite'
local Object = require 'ChessyXeL.display.object.Object'

---@class modchart.Note : display.Sprite
local Note = Sprite.extend 'Note'

Note.noteData = FieldStatus.PUBLIC('default', function (V, I)
    I.name = 'strumLineNotes.members['..V..']'
    I.noteData = V
end, 0)
Note.flippedScroll = FieldStatus.PUBLIC('default', function (V, I)
    I.flippedScroll = V
    if V then
        I.flipY = not getPropertyFromClass('ClientPrefs', 'downScroll')
        I.y = getPropertyFromClass('ClientPrefs', 'downScroll') and 50 or screenHeight - 150
    else
        I.flipY = getPropertyFromClass('ClientPrefs', 'downScroll')
        I.y = getPropertyFromClass('ClientPrefs', 'downScroll') and screenHeight - 150 or 50
    end
end, false)
Note.loadTexture = Method.PUBLIC(function (note, texturepath)
    Object.waitingList.add(function()
        setPropertyFromGroup('strumLineNotes', note, 'texture', texturepath)
    end)
end)
Note.new = function (noteData)
    local note = Note.create(0, 0, 'DO NOT INITIALIZE')
    note.noteData = noteData
    return note
end

return Note