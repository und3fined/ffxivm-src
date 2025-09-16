--
-- Author: MichaelYang_LightPaw
-- Date: 2023-10-23 14:50
-- Description: CardsRuleDetailVM
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local CardsRuleDetaiItemVM = require("Game/Cards/VM/CardsRuleDetaiItemVM")
local ProfType = ProtoCommon.prof_type
local RoleGender = ProtoCommon.role_gender

---@class CardsRuleDetailVM : UIViewModel
local CardsRuleDetailVM = LuaClass(UIViewModel)

---Ctor
function CardsRuleDetailVM:Ctor()
    -- self.LocalString = nil
    -- self.TextColor = nil
    -- self.ProfID = nil
    -- self.GenderID = nil
    -- self.IsVisible = nil

    --- 包含的是 Title Content
    -- Content 是 string
    -- Title 是 string
    self.CardsRuleItemVMList = {}

    --- 标题
    self.TextTitle = nil
end

function CardsRuleDetailVM:AddTitleAndContent(TitleValue, ContentValue, NoRuleColor, NormalRuleColor)
    local _index = #self.CardsRuleItemVMList
    _index = _index + 1
    self.CardsRuleItemVMList[_index] = CardsRuleDetaiItemVM.New()
    self.CardsRuleItemVMList[_index]:SetTitleAndContent(TitleValue, ContentValue, NoRuleColor, NormalRuleColor)
end

-- 要返回当前类
return CardsRuleDetailVM
