local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Tween = require 'ChessyXeL.tweens.Tween'
local TableUtil = require 'ChessyXeL.util.TableUtil'
local Math = require 'ChessyXeL.math.Math'
require 'ChessyXeL.util.StringUtil'

---@class tweens.misc.VarTween : tweens.Tween 
local VarTween = Tween.extend 'VarTween'

VarTween._object = FieldStatus.NORMAL('default', 'default')
VarTween._properties = FieldStatus.NORMAL('default', 'default')
VarTween._propertyInfos = FieldStatus.NORMAL('default', 'default')

VarTween.initializeVars = Method.NORMAL(function (tween)
    if type(tween._properties) ~= 'table' then
        error('Error, Tween properties Must be a table')
    end
    for fieldPath, fieldValue in pairs(tween._properties) do
        local target = tween._object;
        local path = fieldPath:split(".");
        local field = TableUtil.pop(path)
        for i = 1, #path do
            target = target[path[i]]
            if (type(target) ~= 'table') then
                error('The object does not have the property "'..path[i]..'" in "'..fieldPath..'"')
            end
        end

        tween._propertyInfos[#tween._propertyInfos+1] = {
            object = target,
            field = field,
            startValue = 0/0,
            range = tween._properties[fieldPath]
        }
    end
end)

VarTween.setStartValues = Method.NORMAL(function (tween)
    for i = 1, #tween._propertyInfos do
        local info = tween._propertyInfos[i]
        local value = info.object[info.field]
        if Math.isNaN(value) then
            error('Property "'..info.field..'" is not numeric.')
        end
        info.startValue = value
        info.range = info.range - value
    end
end)

VarTween.tween = Method.PUBLIC(function (tween, object, properties, duration)
    tween._object = object
    tween._properties = properties
    tween._propertyInfos = {}
    tween.duration = duration
    tween.start()
    tween.initializeVars()
    return tween
end)

VarTween.override('update', function (super, tween, elapsed)
    local delay = (tween.executions > 0) and tween.loopDelay or tween.startDelay
    if tween._secondsSinceStart < delay then
        super(tween, elapsed)
    else
        if Math.isNaN(tween._propertyInfos[1].startValue) then
            tween.setStartValues()
        end
        super(tween, elapsed)

        if tween.active then
            for i = 1, #tween._propertyInfos do
                local info = tween._propertyInfos[i]
                info.object[info.field] = info.startValue + info.range * tween.scale
            end
        end
    end
end)
VarTween.override('destroy', function (super, tween)
    super(tween)
    tween._object = nil
    tween._properties = nil
    tween._propertyInfos = nil
end)
VarTween.override('isTweenOf', function (super, tween, object, field)
	if (object == tween._object and field == nil) then
		return true
    end
	for i = 1, #tween._propertyInfos do
        local property = tween._propertyInfos[i]
		if (object == property.object and (field == property.field or field == nil)) then
			return true
        end
    end
	return false
end)

return VarTween