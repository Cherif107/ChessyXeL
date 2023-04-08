local Class = require 'ChessyXeL.Class'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local TableUtil = require 'ChessyXeL.util.TableUtil'
local Type = require 'ChessyXeL.tweens.Type'
local Math = require 'ChessyXeL.math.Math'
local NumTween, VarTween, ColorTween, MultiColorTween
require 'ChessyXeL.util.StringUtil'

---@class tweens.TweenManager : Class Handles all the tweens, also contains methods for them such as cancelling them all
local TweenManager = Class 'TweenManager'
TweenManager.managers = FieldStatus.NORMAL('default', 'default', {}, true)
TweenManager.new = function ()
    local manager = TweenManager.create()
    TweenManager.privateAccess = true
    TweenManager.managers[#TweenManager.managers+1] = manager
    TweenManager.privateAccess = true
    return manager
end
TweenManager._tweens = FieldStatus.NORMAL('default', 'default', {})
TweenManager.add = Method.PUBLIC(function (manager, tween, start)
    if start == nil then start = false end
    if tween == nil then return nil end
    manager._tweens[#manager._tweens + 1] = tween
    
    if start then
        tween.start()
    end
    return tween
end)
TweenManager.remove = Method.PUBLIC(function (manager, tween, destroy)
    if destroy == nil then destroy = true end
    if tween == nil then return nil end
    tween.active = false
    
    if destroy then
        tween.destroy()
    end
    TableUtil.fastSplice(manager._tweens, tween)
    return tween
end)
TweenManager.clear = Method.PUBLIC(function (manager)
    for i = 1, #manager._tweens do
        local tween = manager._tweens[i]
        if tween ~= nil then
            tween.active = false
            tween.destroy()
        end
        TableUtil.splice(manager._tweens, 1, #manager._tweens)
    end
end)
TweenManager.forEach = Method.PUBLIC(function (manager, func)
    for i = 1, #manager._tweens do
        if (manager._tweens[i] ~= nil) then
            func(manager._tweens[i])
        end
    end
end)
TweenManager.completeAll = Method.PUBLIC(function (manager)
    manager.forEach(function (tween)
        if (tween.type ~= Type.LOOPING and tween.type ~= Type.PINGPONG and tween.active) then
            tween.update(Math.MAX_VALUE_FLOAT)
        end
    end)
end)
TweenManager.forEachTweensOf = Method.NORMAL(function (manager, Object, fieldPaths, Function)
    if Object == nil then
        error('Cannot iterate over an empty Object\'s tweens.')
    end
    if fieldPaths == nil or #fieldPaths == 0 then
        local i = #manager._tweens
        while i - 1 > 1 do
            i = i - 1
            local tween = manager._tweens[i]
            if tween.isTweenOf(Object) then
                Function(tween)
            end
        end
    else
        local propertyInfos = {}
        for i = 1, #fieldPaths do
            local fieldPath = fieldPaths[i]
            local target = Object
            local path = fieldPath:split('.')
            local field = TableUtil.pop(path)
            for q = 1, #path do
                target = target[path[q]]
                if type(target) == 'table' then
                    break
                end
            end
            if type(target) == 'table' then
                propertyInfos[#propertyInfos + 1] = {object = target, field = field}
            end
        end

        local i = #manager._tweens
        while i - 1 > 1 do
            i = i - 1
            local tween = manager._tweens[i]
            for q = 1, #propertyInfos do
                if tween.isTweenOf(propertyInfos[q].object, propertyInfos[q].field) then
                    Function(tween)
                    break
                end
            end
        end
    end
end) -- warning: very expensive

TweenManager.completeTweensOf = Method.PUBLIC(function (manager, Object, fieldPaths)
    manager.forEachTweensOf(Object, fieldPaths, function (tween)
        if (tween.type ~= Type.LOOPING and tween.type ~= Type.PINGPONG and tween.active) then
            tween.update(Math.MAX_VALUE_FLOAT)
        end
    end)
end)
TweenManager.cancelTweensOf = Method.PUBLIC(function (manager, Object, fieldPaths)
    manager.forEachTweensOf(Object, fieldPaths, function (tween) tween.cancel() end)
end)

TweenManager.update = Method.PUBLIC(function (class, elapsed)
    for i = 1, #class.managers do
        local manager = class.managers[i]
        local finishedTweens = {}
        manager.forEach(function (tween)
		    if (tween.active) then
		        tween.update(elapsed);
		        if (tween.finished) then
		        	if (finishedTweens == nil) then
		        		finishedTweens = {};
                    end
		        	finishedTweens[#finishedTweens+1] = tween;
		        end
            end
        end)
        if (finishedTweens ~= nil) then
            while #finishedTweens > 0 do
                local p = TableUtil.shift(finishedTweens)
                if p == nil then
                    return
                end
                p.finish()
            end
        end
    end
end, true)

local o = onUpdate
function onUpdate(elapsed)
    if o then
        o(elapsed)
    end
    TweenManager.update(elapsed)
end

--- [[mlem]] ---

TweenManager.num = Method.PUBLIC(function (manager, from, to, duration, Options, tweenFunction)
    NumTween = require 'ChessyXeL.tweens.misc.NumTween'
    local twn = NumTween(Options, manager)
    twn.tween(from, to, duration or 1, tweenFunction)
    manager.add(twn)
    return twn
end)
TweenManager.tween = Method.PUBLIC(function (manager, Object, Values, duration, Options)
    VarTween = require 'ChessyXeL.tweens.misc.VarTween'
    local twn = VarTween(Options, manager)
    twn.tween(Object, Values, duration or 1)
    manager.add(twn)
    return twn
end)
TweenManager.color = Method.PUBLIC(function (manager, sprite, duration, fromColor, toColor, Options)
    ColorTween = require 'ChessyXeL.tweens.misc.ColorTween'
    local twn = ColorTween(Options, manager)
    twn.tween(duration or 1, fromColor, toColor, sprite)
    manager.add(twn)
    return twn
end)
TweenManager.colors = Method.PUBLIC(function (manager, sprite, duration, colors, Options) -- warning: still working on it
    MultiColorTween = require 'ChessyXeL.tweens.misc.MultiColorTween'
    local twn = MultiColorTween(Options, manager)
    twn.tween(duration or 1, colors, sprite)
    manager.add(twn)
    return twn
end)

--- [[mlem]] ---
return TweenManager