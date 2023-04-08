local Enum = require 'ChessyXeL.Enum'
---@class tweens.Type : Enum Enumerator of Tween Types
--- [[ FIELDS : START ]] ---
---@field public PERSIST EnumData PERSISTING Tween Type
---@field public ONESHOT EnumData ONESHOT Tween Type
---@field public LOOPING EnumData LOOPING Tween Type
---@field public PINGPONG EnumData PINGPONG Tween Type
---@field public BACKWARD EnumData BACKWARD Tween Type
--- [[ FIELDS : END ]] ---
local Type = Enum {
    'PERSIST',
    'ONESHOT',
    'LOOPING',
    'PINGPONG',
    'BACKWARD'
}
return Type