-- local Object = require 'ChessyXeL.display.object.Object'
-- local ObjectField = require 'ChessyXeL.display.object.Field'
-- local HScript = require 'ChessyXeL.hscript.HScript'

-- ---@class hscript.Object : display.object.Object
-- local HScriptObject = Object.extend 'HScriptObject'
-- rawset(HScript, 'additionalInstanceMetatable', {
--     __index = function (instance, field)
--         local f = ObjectField.parseIndex(instance.name, field)
--         local v = getProperty(f)
--         if v == f then
--             local t = instance.regularFields[field]
--             if t == nil then
--                 instance.regularFields[field] = ObjectField(ObjectField.parseIndex(instance.name, field))
--                 t = instance.regularFields[field]
--             end
--             if t.get then
--                 return t.get(ObjectField.parseIndex(instance.name, field))
--             end
--             return t
--         else
--             return v
--         end
--     end,
--     __newindex = function (instance, field, value)
--         local f = ObjectField.parseIndex(instance.name, field)
--         local v
--         if getProperty == nil then
--             v = f
--         else
--             v = getProperty(f)
--         end
--         if v == f and instance.regularFields[field] and instance.regularFields[field].set then
--             return Object.waitingList.add(function()
--                 instance.regularFields[field].set(ObjectField.parseIndex(instance.name, field), value)
--             end)
--         else
--             return Object.waitingList.add(function()
--                 setProperty(f, value)
--             end)
--         end
--     end
-- })

-- return HScriptObject