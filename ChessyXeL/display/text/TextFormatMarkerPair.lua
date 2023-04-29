local FieldStatus = require 'ChessyXeL.FieldStatus'
local Class = require 'ChessyXeL.Class'
---@class text.TextFormatMarkerPair : Class
local TextFormatMarkerPair = Class 'TextFormatMarkerPair'

TextFormatMarkerPair.format = FieldStatus.PUBLIC('default', 'default')
TextFormatMarkerPair.marker = FieldStatus.PUBLIC('default', 'default')
TextFormatMarkerPair.new = function (format, marker)
    local markerPair = TextFormatMarkerPair.create()
    markerPair.format = format
    markerPair.marker = marker
    return markerPair
end

return TextFormatMarkerPair