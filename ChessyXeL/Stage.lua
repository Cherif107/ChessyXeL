---@class Stage
local Stage = {}
Stage = {
    functions = {
        onCreate = {},
        onUpdate = {},
        onDestroy = {},
        
        onCountdownStarted = {},
        onCountdownTick = {},
        
        onStartCountdown = {},
        onSongStart = {},
        onEndSong = {},
        
        onCreatePost = {},
        onUpdatePost = {},
        
        onStepHit = {},
        onSectionHit = {},
        onBeatHit = {},
        
        onSpawnNote = {},
        onGhostTap = {},
        onKeyRelease = {},
        onKeyPress = {},
        
        goodNoteHit = {},
        opponentNoteHit = {},
        
        noteMiss = {},
        noteMissPress = {},
        
        onMoveCamera = {},
        
        onEvent = {},
        eventEarlyTrigger = {},
        
        onPause = {},
        onResume = {},
        
        onNextDialogue = {},
        onSkipDialogue = {},
        
        onRecalculateRating = {},
        
        onGameOver = {},
        onGameOverStart = {},
        onGameOverConfirm = {},
        
        onTweenCompleted = {},
        onSoundFinished = {},
        onTimerCompleted = {},
    },
    set = function(Function, NewCallBack, Tag)
        if Stage.functions[Function] == nil then
            error('Stage Error: Callback ('..Function..') Does Not Exist')
        else
            Tag = Tag or #Stage.functions[Function] + 1
            Stage.functions[Function][Tag] = NewCallBack 
        end
    end,
    remove = function(Function, Tag)
        if Stage.functions[Function] == nil then
            error('Stage Error: Callback ('..Function..') Does Not Exist')
        else
            Stage.functions[Function][Tag] = nil
        end
    end,
    call = function(Function, ...)
        if Stage.functions[Function] == nil then
            error('Stage Error: Callback ('..Function..') Does Not Exist')
        else
            if #Stage.functions[Function] > 0 then
                for index, func in pairs(Stage.functions[Function]) do
                    func(...)
                end
            end
        end
    end
}

local f = onCreate
function onCreate()
    if f then f() end
    Stage.call('onCreate')
end

local f = onUpdate
function onUpdate(elapsed)
    if f then f(elapsed) end
    Stage.call('onUpdate', elapsed)
end

local f = onDestroy
function onDestroy()
    if f then f() end
    Stage.call('onDestroy')
end

local f = onCountdownStarted
function onCountdownStarted()
    if f then f() end
    Stage.call('onCountdownStarted')
end

local f = onCountdownTick
function onCountdownTick(counter)
    if f then f(counter) end
    Stage.call('onCountdownTick', counter)
end

local f = onStartCountdown
function onStartCountdown()
    if f then f() end
    Stage.call('onStartCountdown')
end

local f = onSongStart
function onSongStart()
    if f then f() end
    Stage.call('onSongStart')
end

local f = onEndSong
function onEndSong()
    if f then f() end
    Stage.call('onEndSong')
end

local f = onCreatePost
function onCreatePost()
    if f then f() end
    Stage.call('onCreatePost')
end

local f = onUpdatePost
function onUpdatePost(elapsed)
    if f then f(elapsed) end
    Stage.call('onUpdatePost', elapsed)
end

local f = onStepHit
function onStepHit()
    if f then f() end
    Stage.call('onStepHit')
end

local f = onSectionHit
function onSectionHit()
    if f then f() end
    Stage.call('onSectionHit')
end

local f = onBeatHit
function onBeatHit()
    if f then f() end
    Stage.call('onBeatHit')
end

local f = onSpawnNote
function onSpawnNote(id, noteData, noteType, isSustainNote)
    if f then f(id, noteData, noteType, isSustainNote) end
    Stage.call('onSpawnNote', id, noteData, noteType, isSustainNote)
end

local f = onGhostTap
function onGhostTap(noteData)
    if f then f(noteData) end
    Stage.call('onGhostTap', noteData)
end

local f = onKeyRelease
function onKeyRelease(key)
    if f then f(key) end
    Stage.call('onKeyRelease', key)
end

local f = onKeyPress
function onKeyPress(key)
    if f then f(key) end
    Stage.call('onKeyPress', key)
end

local f = goodNoteHit
function goodNoteHit(id, noteData, noteType, isSustainNote)
    if f then f(id, noteData, noteType, isSustainNote) end
    Stage.call('goodNoteHit', id, noteData, noteType, isSustainNote)
end

local f = opponentNoteHit
function opponentNoteHit(id, noteData, noteType, isSustainNote)
    if f then f(id, noteData, noteType, isSustainNote) end
    Stage.call('opponentNoteHit', id, noteData, noteType, isSustainNote)
end

local f = noteMiss
function noteMiss(id, noteData, noteType, isSustainNote)
    if f then f(id, noteData, noteType, isSustainNote) end
    Stage.call('noteMiss', id, noteData, noteType, isSustainNote)
end

local f = noteMissPress
function noteMissPress(noteData)
    if f then f(noteData) end
    Stage.call('noteMissPress', noteData)
end

local f = onMoveCamera
function onMoveCamera(focus)
    if f then f(focus) end
    Stage.call('onMoveCamera', focus)
end

local f = onEvent
function onEvent(name, value1, value2)
    if f then f(name, value1, value2) end
    Stage.call('onEvent', name, value1, value2)
end

local f = eventEarlyTrigger
function eventEarlyTrigger(name)
    if f then f(name) end
    Stage.call('eventEarlyTrigger', name)
end

local f = onPause
function onPause()
    if f then f() end
    Stage.call('onPause')
end

local f = onResume
function onResume()
    if f then f() end
    Stage.call('onResume')
end

local f = onNextDialogue
function onNextDialogue(dialogueCount)
    if f then f(dialogueCount) end
    Stage.call('onNextDialogue', dialogueCount)
end

local f = onSkipDialogue
function onSkipDialogue(dialogueCount)
    if f then f(dialogueCount) end
    Stage.call('onSkipDialogue', dialogueCount)
end

local f = onRecalculateRating
function onRecalculateRating()
    if f then f() end
    Stage.call('onRecalculateRating')
end

local f = onGameOver
function onGameOver()
    if f then f() end
    Stage.call('onGameOver')
end

local f = onGameOverStart
function onGameOverStart()
    if f then f() end
    Stage.call('onGameOverStart')
end

local f = onGameOverConfirm
function onGameOverConfirm()
    if f then f() end
    Stage.call('onGameOverConfirm')
end

local f = onTweenCompleted
function onTweenCompleted(tag)
    if f then f(tag) end
    Stage.call('onTweenCompleted', tag)
end

local f = onTimerCompleted
function onTimerCompleted(tag, loops, loopsLeft)
    if f then f(tag, loops, loopsLeft) end
    Stage.call('onTimerCompleted', tag, loops, loopsLeft)
end

local f = onSoundFinished
function onSoundFinished(tag)
    if f then f(tag) end
    Stage.call('onSoundFinished', tag)
end

return setmetatable(Stage, {
    __newindex = function (this, index, value)
        return this.set(index, value)
    end
})