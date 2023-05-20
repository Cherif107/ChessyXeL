local Object = require 'ChessyXeL.display.object.Object'
local FieldStatus = require 'ChessyXeL.FieldStatus'

---@class display.object.ClassObject : display.object.Object for objects that use set/getPropertyFromClass
local ClassObject = Object.extend 'ClassObject'

ClassObject.new = function (class, firstField)
    local obj = ClassObject.create()
    obj.name = class
    obj.__isClassObject = true
    obj.__additionalClassField = firstField
    return obj
end

return ClassObject