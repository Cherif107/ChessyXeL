local Object = require 'ChessyXeL.display.object.Object'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local Basic = require 'ChessyXeL.Basic'
local HScript = require 'ChessyXeL.hscript.HScript'
local Stage = require 'ChessyXeL.Stage'

---@class media.Sound : Basic
local Sound = Basic.extend 'Sound'

Stage.set('onCreatePost', function ()
    HScript.execute [[
        function setOnSound(name:String, variable:String, value:Dynamic){
            Reflect.setProperty(game.modchartSounds[name], variable, parseLua(value));
        }
        function getOnSound(name:String, variable:String){
            return toLua(Reflect.getProperty(game.modchartSounds[name], variable));
        }
    ]]
end)

Sound.name = FieldStatus.PUBLIC('default', 'default', 'SOUND')
Sound.soundPath = FieldStatus.PUBLIC('default', 'default', 'SOUND')
Sound.onComplete = FieldStatus.PUBLIC('default', 'default', nil)
Sound.looped = FieldStatus.PUBLIC('default', 'default', false)
Sound.volume = FieldStatus.PUBLIC('default', function(V, I)
    Object.waitingList.add(function()
        setSoundVolume(I.name, V)
    end)
    I.volume = V
end, 1)
Sound.time = FieldStatus.PUBLIC(function(I) return getSoundTime(I.name) end, function(V, I)
    Object.waitingList.add(function()
        setSoundTime(I.name, V)
    end)
end, 1)
Sound.play = Method.PUBLIC(function(I, volume)
    Object.waitingList.add(function ()
        playSound(I.soundPath, volume or I.volume, I.name)
    end)
    return I
end)
Sound.stop = Method.PUBLIC(function(I)
    Object.waitingList.add(function ()
        stopSound(I.name)
    end)
    return I
end)
Sound.pause = Method.PUBLIC(function(I)
    Object.waitingList.add(function ()
        pauseSound(I.name)
    end)
    return I
end)
Sound.resume = Method.PUBLIC(function(I)
    Object.waitingList.add(function ()
        resumeSound(I.name)
    end)
    return I
end)
Sound.fadeIn = Method.PUBLIC(function(I, duration, from, to)
    Object.waitingList.add(function ()
        soundFadeIn(I.name, duration, from, to)
    end)
    return I
end)
Sound.fadeOut = Method.PUBLIC(function(I, duration, from, to)
    Object.waitingList.add(function ()
        soundFadeOut(I.name, duration, from, to)
    end)
    return I
end)
-- [[ /Hscript ]] --
Sound.pitch = FieldStatus.PUBLIC('default', function (V, I)
    Object.waitingList.add(function ()
        HScript.call('setOnSound', I.name, 'pitch', V)
    end)
    I.pitch = V
end, 1)
-- [[ Hscript\ ]] --

Sound.instances = FieldStatus.PUBLIC('default', 'default', {}, true)
Sound.new = function(soundPath)
    local sound = Sound.create()
    Object.waitingList.add(function()
        precacheSound(soundPath)
    end)

    sound.soundPath = soundPath
    sound.name = 'CHESSYXEL_SOUND_'..Object.GlobalObjectTag..'_'..sound.ID

    Sound.instances[sound.name] = sound
    return sound
end

local o = onSoundFinished
function onSoundFinished(t)
    if o then o(t) end
    for name, sound in pairs(Sound.instances) do
        if t == name then
            if sound.onComplete then
                sound.onComplete()
            end
            if sound.looped then
                sound.play(sound.volume)
            end
        end
    end
end

return Sound