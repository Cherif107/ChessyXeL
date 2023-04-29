local Enum = require 'ChessyXeL.Enum'

---@class interp.base.Token : Class
local Token = Enum {
    "TEof",
    TConst = {'const'},
    TId = {'s'},
    TOp = {'s'},
    "TPOpen",
    "TPClose",
    "TBrOpen",
    "TBrClose",
    "TDot",
    "TComma",
    "TStatement",
    "TEol",
    "TBkOpen",
    "TBkClose",
    "TQuestion",
    "TDoubleDot",
    TMeta = {'s'},
    TPrepro = {'s'}
}

return Token