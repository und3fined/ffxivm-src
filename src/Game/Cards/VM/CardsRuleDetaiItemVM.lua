--
-- Author: MichaelYang_LightPaw
-- Date: 2023-10-23 14:50
-- Description: CardsRuleDetaiItemVM
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProfType = ProtoCommon.prof_type
local RoleGender = ProtoCommon.role_gender

---@class CardsRuleDetaiItemVM : UIViewModel
local CardsRuleDetaiItemVM = LuaClass(UIViewModel)

---Ctor
function CardsRuleDetaiItemVM:Ctor()
    self.Title = nil
    self.Content = nil
end

function CardsRuleDetaiItemVM:SetTitleAndContent(TitleValue, ContentValue, NoRuleTitleColor, NormalRuleTitleColor)
    self.Title = TitleValue
    self.Content = ContentValue
    self.NoRuleTitleColor = NoRuleTitleColor
    self.NormalRuleTitleColor = NormalRuleTitleColor
end

-- 要返回当前类
return CardsRuleDetaiItemVM
