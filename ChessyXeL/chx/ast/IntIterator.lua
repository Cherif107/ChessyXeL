local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local Stmt = require 'ChessyXeL.chx.ast.Stmt'

---@class chx.ast.IntIterator : chx.ast.Stmt
local IntIterator = Stmt.extend 'IntIterator'

IntIterator.min = FieldStatus.PUBLIC('default', 'default', nil)
IntIterator.max = FieldStatus.PUBLIC('default', 'default', nil)

IntIterator.new = function (min, max)
    local iterator = IntIterator.create('IntIterator')
    iterator.min = min
    iterator.max = max
    return iterator
end

return IntIterator