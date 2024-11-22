local FieldStatus = require 'ChessyXeL.FieldStatus'
local Class = require 'ChessyXeL.Class'

---@class chx.PosInfo : Class
local PosInfo = Class 'PosInfo'

PosInfo.index = FieldStatus.PUBLIC('default', 'default', 0)
PosInfo.line = FieldStatus.PUBLIC('default', 'default', 1)

return PosInfo