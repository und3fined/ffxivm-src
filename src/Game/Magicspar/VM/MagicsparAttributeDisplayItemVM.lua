local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class MagicsparAttributeDisplayItemVM : UIViewModel
local MagicsparAttributeDisplayItemVM = LuaClass(UIViewModel)

function MagicsparAttributeDisplayItemVM:Ctor()
    self.bShowWarning = false
    self.AttrName = ""
    self.AttrValue = ""
    self.ExceedText = ""
end

function MagicsparAttributeDisplayItemVM:InitItem(Index, NameText, ValueText, LimitValue, bShowWarning)
    self.AttrName = NameText
    self.AttrValue = ValueText
    self.bShowWarning = bShowWarning
    if LimitValue > 0 and bShowWarning then
        local IndexText = 1060010 + Index
        self.ExceedText = string.format(_G.LSTR(IndexText), LimitValue)
    end
end

-- function MagicsparAttributeDisplayItemVM:UpdateExceedInform(AttrIndex)
--     if AttrIndex == 1 then
--         self.ExceedText = string.format(_G.LSTR(1060011), self.LimitNum) --"信念已超过%d，超出部分不生效"
--     elseif AttrIndex == 2 then
--         self.ExceedText = string.format(_G.LSTR(1060012), self.LimitNum) --"直击已超过%d，超出部分不生效"
--     elseif AttrIndex == 3 then
--         self.ExceedText = string.format(_G.LSTR(1060013), self.LimitNum) --"急速已超过%d，超出部分不生效"
--     elseif AttrIndex == 4 then
--         self.ExceedText = string.format(_G.LSTR(1060014), self.LimitNum) --"暴击已超过%d，超出部分不生效"
--     else
--         return
--     end
-- end
return MagicsparAttributeDisplayItemVM