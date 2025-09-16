--
-- Author: Carl
-- Date: 2025-3.17
-- Description: 幻卡编辑界面的规则列表ItemVM
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class CardsPrepareRuleItemVM : UIViewModel
local CardsPrepareRuleItemVM = LuaClass(UIViewModel)

function CardsPrepareRuleItemVM:Ctor(EmoTableID, EmoClassifyID, IsGetted, EmoClassifyTable)
    self.RuleName = ""
    self.DetailedIcon = "" -- 演示图片
    self.PictureTitles = "" --演示图片标题
    self.DetailedDesc = "" --演示图片详细说明
end


function CardsPrepareRuleItemVM:IsEqualVM(Value)
    return Value.Name == self.RuleName
end

function CardsPrepareRuleItemVM:UpdateVM(Value)
    self.RuleName = Value.Name
    self.DetailedIcon = Value.DetailedIcon
    self.PictureTitles = Value.PictureTitles
    self.DetailedDesc = Value.DetailedDesc
end

return CardsPrepareRuleItemVM
