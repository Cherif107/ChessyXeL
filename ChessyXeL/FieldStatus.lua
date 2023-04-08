local Enum = require 'ChessyXel.Enum'

---@class FieldStatus : Enum Represents the Type of the Field (Private, Public, Regular), Also includes Static fields, value is the first value its assigned to
---[[ FIELDS:START ]]---
---@field public PUBLIC EnumData Public Field
---@field public PRIVATE EnumData Private Field
---@field public NORMAL EnumData Regular Field
---[[ FIELDS:END ]]---
local FieldStatus = Enum {
    PUBLIC = {'get', 'set', 'value', 'static'},
    PRIVATE = {'get', 'set', 'value', 'static'},
    NORMAL = {'get', 'set', 'value', 'static'}
}

return FieldStatus