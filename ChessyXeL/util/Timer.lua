local Class = require 'ChessyXeL.Class'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local TimerManager = require 'ChessyXeL.util.TimerManager'
---@class util.Timer : Class a class for creating timers
local Timer = Class 'Timer'

Timer.globalManager = FieldStatus.PUBLIC('default', 'default', TimerManager(), true)
Timer.manager = FieldStatus.PUBLIC('default', 'default', Timer.globalManager)
Timer.time = FieldStatus.PUBLIC('default', 'default', 0)
Timer.loops = FieldStatus.PUBLIC('default', 'default', 0)
Timer.active = FieldStatus.PUBLIC('default', 'default', false)
Timer.finished = FieldStatus.PUBLIC('default', 'default', true)
Timer.onComplete = FieldStatus.PUBLIC('default', 'default')
Timer.timeLeft = FieldStatus.PUBLIC(function (I, F)
    return I.time - I._timeCounter
end, 'never')
Timer.elapsedTime = FieldStatus.PUBLIC(function (I, F)
    return I._timeCounter
end, 'never')
Timer.loopsLeft = FieldStatus.PUBLIC(function (I, F)
    return I.loops - I._loopsCounter
end, 'never')
Timer.elapsedLoops = FieldStatus.PUBLIC(function (I, F)
    return I._loopsCounter
end, 'never')
Timer.progress = FieldStatus.PUBLIC(function (I, F)
    return (I.time > 0) and (I._timeCounter / I.time) or 0
end, 'never')
Timer._timeCounter = FieldStatus.NORMAL('default', 'default', 0)
Timer._loopsCounter = FieldStatus.NORMAL('default', 'default', 0)
Timer._inManager = FieldStatus.NORMAL('default', 'default', false)

Timer.new = function (manager)
    local timer = Timer.create()
    timer.manager = manager or Timer.globalManager
    return timer
end

Timer.start = Method.PUBLIC(function (timer, time, onComplete, loops)
    loops = loops or 1
    if timer.manager ~= nil and not timer._inManager then
        timer.manager.add(timer)
        timer._inManager = true
    end
    timer.active = true
    timer.finished = false
    timer.time = math.abs(time)
    if loops < 0 then
        loops = loops * - 1
    end
    timer.loops = loops
    timer.onComplete = onComplete
    timer._timeCount = 0
    timer._loopsCounter = 0

    return timer
end)
Timer.reset = Method.PUBLIC(function (timer, newTime)
    newTime = newTime or -1
    if newTime < 0 then
        newTime = timer.time
    end
    return timer.start(newTime, timer.onComplete, timer.loops)
end)
Timer.cancel = Method.PUBLIC(function (timer)
    timer.finished = true
    timer.active = false
    if timer.manager ~= nil and timer._inManager then
        timer.manager.remove(timer)
        timer._inManager = false
    end
end)
Timer.update = Method.PUBLIC(function (timer, elapsed)
    timer._timeCounter = timer._timeCounter + elapsed
    while ((timer._timeCounter >= timer.time) and timer.active and not timer.finished) do
        timer._timeCounter = timer._timeCounter - timer.time
        timer._loopsCounter = timer._loopsCounter + 1;

        if (timer.loops > 0 and (timer._loopsCounter >= timer.loops)) then
            timer.finished = true;
        end
    end
end)
Timer.onLoopFinished = Method.NORMAL(function (timer)
    if timer.finished then
        timer.cancel()
    end
    if timer.onComplete ~= nil then
        timer.onComplete(timer)
    end
end)

return Timer