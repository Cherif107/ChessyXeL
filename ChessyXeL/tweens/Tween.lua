local Class = require 'ChessyXeL.Class'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local TweenManager = require 'ChessyXeL.tweens.TweenManager'
local Ease = require 'ChessyXeL.tweens.Ease'
local Type = require 'ChessyXeL.tweens.Type'
local TableUtil = require 'ChessyXeL.util.TableUtil'

---@class tweens.Tween : Class A Class that starts tweens
local Tween = Class 'Tween'
Tween.globalManager = FieldStatus.PUBLIC('default', 'default', TweenManager(), true)
Tween.manager = FieldStatus.PUBLIC('default', 'default', Tween.globalManager)
Tween.duration = FieldStatus.PUBLIC('default', 'default', 0)
Tween.ease = FieldStatus.PUBLIC('default', 'default', Ease.linear)
Tween.onStart = FieldStatus.PUBLIC('default', 'default')
Tween.onUpdate = FieldStatus.PUBLIC('default', 'default')
Tween.onComplete = FieldStatus.PUBLIC('default', 'default')

Tween.active = FieldStatus.PUBLIC('default', function (V, I, F)
    I.active = V
    if (I._waitingForRestart) then
        I.restart()
    end
    return V
end, false)
Tween.type = FieldStatus.PUBLIC('default', function (V, I, F)
    I.backward = (V == Type.BACKWARD)
    I.type = V
    return V
end)
Tween.percent = FieldStatus.PUBLIC(function (I, F)
    return math.max((I._secondsSinceStart - I._delayToUse), 0) / I.duration
end, function (V, I, F)
    I._secondsSinceStart = I.duration * V + I._delayToUse
end)
Tween.finished = FieldStatus.PUBLIC('default', 'default', false)
Tween.scale = FieldStatus.PUBLIC('default', 'default', 0)
Tween.backward = FieldStatus.PUBLIC('default', 'default', false)
Tween.executions = FieldStatus.PUBLIC('default', 'default', 0)
Tween.startDelay = FieldStatus.PUBLIC('default', 'default', 0)
Tween.loopDelay = FieldStatus.PUBLIC('default', function (V, I, F)
    local dly = math.abs(V)
    if (I.executions > 0) then
        I._secondsSinceStart = I.duration * I.percent + math.max((dly - I.loopDelay), 0)
        I._delayToUse = dly
    end
    I.loopDelay = dly
    return dly
end, 0)
Tween.startDelay = FieldStatus.PUBLIC('default', function (V, I, F)
    local dly = math.abs(V)
    if (I.executions == 0) then
        I._delayToUse = dly
    end
    I.startDelay = dly
    return dly
end, 0)

Tween._secondsSinceStart = FieldStatus.NORMAL('default', 'default', 0)
Tween._delayToUse = FieldStatus.NORMAL('default', 'default', 0)
Tween._running = FieldStatus.NORMAL('default', 'default', false)
Tween._waitingForRestart = FieldStatus.NORMAL('default', 'default', false)
Tween._chainedTweens = FieldStatus.NORMAL('default', 'default', {})
Tween._nextTweenInChain = FieldStatus.NORMAL('default', 'default')

Tween.start = Method.PUBLIC(function (tween)
    tween._waitingForRestart = false;
    tween._secondsSinceStart = 0;
    tween._delayToUse = (tween.executions > 0) and tween.loopDelay or tween.startDelay;
    if (tween.duration == 0) then
        tween.active = false;
        return tween;
    end
    tween.active = true;
    tween._running = false;
    tween.finished = false;
    return tween;
end)
Tween.restart = Method.PUBLIC(function (tween)
    if tween.active then
        tween.start()
    else
        tween._waitingForRestart = true
    end
end)
Tween.resolveTweenOptions = Method.NORMAL(function (class, Options)
    if Options == nil then
        Options = {type = Type.ONESHOT}
    end
    if Options.type == nil then
        Options.type = Type.ONESHOT
    end
    return Options
end, true)
Tween.setDelays = Method.NORMAL(function(tween, startDelay, loopDelay)
    tween.startDelay = startDelay or 0
    tween.loopDelay = loopDelay or 0
    return tween
end)

Tween.new = function (options, manager)
    local tween = Tween.create()
    options = Tween.resolveTweenOptions(options)

    tween.onStart = options.onStart
    tween.onUpdate = options.onUpdate
    tween.onComplete = options.onComplete
    tween.ease = options.ease
    tween.type = options.type
    tween.setDelays(options.startDelay, options.loopDelay)
    tween.manager = manager or Tween.globalManager

    return tween
end

Tween.destroy = Method.NORMAL(function(tween)
    tween.onStart = nil
    tween.onUpdate = nil
    tween.onComplete = nil

    tween.ease = nil
    tween.manager = nil
    tween._chainedTweens = nil
    tween._nextTweenInChain = nil
end)

Tween.setVarsOnEnd = Method.NORMAL(function(tween)
    tween.active = false
    tween._running = false
    tween.finished = true
end)

Tween.addChainedTween = Method.NORMAL(function(tween, twn)
    twn.setVarsOnEnd()
    twn.manager.remove(twn, false)
    if tween._chainedTweens == nil then
        tween._chainedTweens = {}
    end
    tween._chainedTweens[#tween._chainedTweens + 1] = twn
    return tween
end)
Tween.setChain = Method.NORMAL(function(tween, prevChain)
    if prevChain == nil then return end
    if tween._chainedTweens == nil then
        tween._chainedTweens = prevChain
    else
        tween._chainedTweens = TableUtil.concat(tween._chainedTweens, prevChain)
    end
end)
Tween.doNextTween = Method.NORMAL(function(tween, twn)
    if not twn.active then
        twn.start()
        tween.manager.add(twn)
    end
    twn.setChain(tween._chainedTweens)
end)
Tween.processTweenChain = Method.NORMAL(function(tween)
    if tween._chainedTweens == nil or #tween._chainedTweens <= 0 then
        return
    end
    tween._nextTweenInChain = TableUtil.shift(tween._chainedTweens)
    tween.doNextTween(tween._nextTweenInChain)
    tween._chainedTweens = nil
end)
Tween.onEnd = Method.NORMAL(function(tween)
    tween.setVarsOnEnd()
    tween.processTweenChain()
end)

Tween.Then = Method.PUBLIC(function(tween, twn)
    return tween.addChainedTween(twn)
end)
Tween.update = Method.PUBLIC(function(tween, elapsed)
    tween._secondsSinceStart = tween._secondsSinceStart + elapsed;
	local delay = (tween.executions > 0) and tween.loopDelay or tween.startDelay;
	if (tween._secondsSinceStart < delay) then
		return;
    end
	tween.scale = math.max((tween._secondsSinceStart - delay), 0) / tween.duration
	if (tween.ease ~= nil) then
		tween.scale = tween.ease(tween.scale)
    end
	if (tween.backward) then
		tween.scale = 1 - tween.scale;
    end
	if (tween._secondsSinceStart > delay and not tween._running) then
		tween._running = true;
		if (tween.onStart ~= nil) then
			tween.onStart(tween);
        end
    end
	if (tween._secondsSinceStart >= tween.duration + delay) then
		tween.scale = (tween.backward) and 0 or 1;
		tween.finished = true
	else
		if (tween.onUpdate ~= nil) then
			tween.onUpdate(tween);
        end
    end
end)
Tween.cancel = Method.PUBLIC(function (tween)
    tween.onEnd()
    if tween.manager ~= nil then
        tween.manager.remove(tween)
    end
end)
Tween.cancelChain = Method.PUBLIC(function (tween)
    if tween._nextTweenInChain ~= nil then
        tween._nextTweenInChain.cancelChain()
    end
    if tween._chainedTweens ~= nil then
        tween._chainedTweens = nil
    end
    tween.cancel()
end)
Tween.finish = Method.NORMAL(function (tween)
    tween.executions = tween.executions + 1;
	if (tween.onComplete ~= nil) then
		tween.onComplete(tween);
    end
	local type = (tween.type == Type.BACKWARD and Type.ONESHOT or tween.type)
	if (type == Type.PERSIST or type == Type.ONESHOT) then
		tween.onEnd();
		tween._secondsSinceStart = tween.duration + tween.startDelay;
		if (type == Type.ONESHOT and tween.manager ~= nil) then
			tween.manager.remove(tween);
        end
	end
	if (type == Type.LOOPING or type == Type.PINGPONG) then
		tween._secondsSinceStart = (tween._secondsSinceStart - tween._delayToUse) % tween.duration + tween._delayToUse;
		tween.scale = math.max((tween._secondsSinceStart - tween._delayToUse), 0) / tween.duration;
		if (tween.ease ~= nil and tween.scale > 0 and tween.scale < 1) then
			tween.scale = tween.ease(tween.scale);
        end
		if (type == Type.PINGPONG) then
			tween.backward = not tween.backward;
			if (tween.backward) then
				tween.scale = 1 - tween.scale;
            end
		end
		tween.restart();
    end
end)
Tween.isTweenOf = Method.PUBLIC(function (tween, object, field)
    return false
end, false, true)

--- [[mlem]] ---

Tween.num = Method.PUBLIC(function (class, from, to, duration, options, tweenFunction)
    return class.globalManager.num(from, to, duration, options, tweenFunction)
end, true)
Tween.tween = Method.PUBLIC(function (class, Object, Values, duration, Options)
    return class.globalManager.tween(Object, Values, duration, Options)
end, true)
Tween.color = Method.PUBLIC(function (class, sprite, duration, fromColor, toColor, Options)
    return class.globalManager.color(sprite, duration, fromColor, toColor, Options)
end, true)
Tween.colors = Method.PUBLIC(function (class, sprite, duration, colors, Options)
    return class.globalManager.colors(sprite, duration, colors, Options)
end, true)

--- [[mlem]] ---

return Tween