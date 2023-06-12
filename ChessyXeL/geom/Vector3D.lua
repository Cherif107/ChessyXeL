local Class = require 'ChessyXeL.Class'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'

---@class geom.Vector3D : Class
local Vector3D = Class 'Vector3D'

Vector3D.x = FieldStatus.PUBLIC('default', 'default', 0)
Vector3D.y = FieldStatus.PUBLIC('default', 'default', 0)