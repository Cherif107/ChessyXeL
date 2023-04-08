local Enum = require 'ChessyXel.Enum'

---@class Method : Enum Represents Methods aka Functions, with features like Public / Private / Normal & Static / Dynamic methods
---[[ FIELDS:START ]]---
---@field public PUBLIC EnumData Public Method
---@field public PRIVATE EnumData Private Method
---@field public NORMAL EnumData Regular Method
---[[ FIELDS:END ]]---
local Method = Enum {
    PUBLIC = {'method', 'static', 'dynamic'},
    PRIVATE = {'method', 'static', 'dynamic'},
    NORMAL = {'method', 'static', 'dynamic'}
}

return Method

--- ABANDONED