local Class = require 'ChessyXeL.Class'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local TableUtil = require 'ChessyXeL.util.TableUtil'

---@class util.TimerManager : Class A Class for time management
local TimerManager = Class 'TimerManager'
TimerManager._managers = FieldStatus.PUBLIC('default', 'never', {}, true)
TimerManager._timers = FieldStatus.NORMAL('default', 'default', {}, false)
TimerManager.destroy = Method.PUBLIC(function (class)
    class.clear()
    class._timers = nil
    TimerManager._managers[TableUtil.indexOf(TimerManager, class)] = nil
end, false)
TimerManager.add = Method.PUBLIC(function (class, timer)
    class._timers[#class._timers + 1] = timer
end, false)
TimerManager.remove = Method.PUBLIC(function (class, timer)
    TableUtil.fastSplice(class._timers, timer)
end, false)
TimerManager.clear = Method.PUBLIC(function (class)
    TableUtil.clearArray(class._timers)
end, false)
TimerManager.forEach = Method.PUBLIC(function (class, func)
    for i = 1, #class._timers do
        func(class._timers[i])
    end
end, false)
TimerManager.completeAll = Method.PUBLIC(function (class)
    local timersToFinish = {}
    for timer in class._timers do
        if (timer.loops > 0 and timer.active) then
            timersToFinish.push(timer)
        end
    end
    for timer in timersToFinish do
        while not timer.finished do
            timer.update(timer.timeLeft)
            timer.onLoopFinished()
        end
    end
end, false)
TimerManager.update = Method.PUBLIC(function (class, elapsed)
    for i = 1, #TimerManager._managers do
        local class = TimerManager._managers[i]
        local O = class.privateAccess
        class.privateAccess = true
        local loopedTimers = nil
        for i = 1, #class._timers do
            local timer = class._timers[i]
            if (timer.active and not timer.finished and timer.time >= 0) then
                local timerLoops = timer.elapsedLoops
                timer.update(elapsed)
                if (timerLoops ~= timer.elapsedLoops) then
                    if (loopedTimers == nil) then
                        loopedTimers = {}
                    end
                    loopedTimers[#loopedTimers + 1] = timer
                end
            end
        end
        if (loopedTimers ~= nil) then
            while (#loopedTimers > 0) do
                TableUtil.shift(loopedTimers).onLoopFinished()
            end
        end
        class.privateAccess = O
    end
end, true)

TimerManager.new = function ()
    local m = TimerManager.create()
    TimerManager._managers[#TimerManager._managers + 1] = m
    return m
end

local o = onUpdate
function onUpdate(elapsed)
    if o then
        o(elapsed)
    end
    TimerManager.update(elapsed)
end

return TimerManager