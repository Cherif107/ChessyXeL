local HScript = require 'ChessyXeL.hscript.HScript'

---@class hscript.TextUtil
local TextUtil = {
    loaded = false
}

function TextUtil.load()
    if not TextUtil.loaded then
        HScript.execute [[
            function applyMarkup(tag:String, input:String, rules:Array<Any> = []){
                game.modchartTexts.get(tag).applyMarkup(input, rules);
            }
        ]]
        TextUtil.loaded = true
    end
end

function TextUtil.applyMarkup(textTag, input, rules)
    TextUtil.load()
    HScript.call('applyMarkup', textTag, input, rules)
end

return TextUtil