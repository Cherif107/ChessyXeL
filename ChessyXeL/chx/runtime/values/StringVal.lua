local FieldStatus = require 'ChessyXeL.FieldStatus'
local RuntimeVal = require 'ChessyXeL.chx.runtime.values.RuntimeVal'

---@class chx.runtime.values.StringVal : chx.runtime.values.RuntimeVal
local StringVal = RuntimeVal.extend 'StringVal'

StringVal.value = FieldStatus.PUBLIC('default', 'default', nil)
StringVal.new = function (value)
    local stringVal = StringVal.create()
    stringVal.type = 'String'
    stringVal.value = value

    stringVal.setField('length', function ()
        return #stringVal.value
    end)
    stringVal.setMethod('charAt', function (index)
        return stringVal.value:sub(index, index) or ''
    end)
    stringVal.setMethod('charCodeAt', function (index)
        return string.byte(stringVal.value:sub(index, index) or '')
    end)
    stringVal.setMethod('indexOf', function (otherStr, index)
        return string.find(stringVal.value, otherStr, index, true)
    end)
    return stringVal
end

return StringVal