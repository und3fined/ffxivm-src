---
--- Author: guanjiewu
--- DateTime: 2024-01-16 19:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LegendaryWeaponAttriItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextAttri UFTextBlock
---@field TextAttriValue UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LegendaryWeaponAttriItemView = LuaClass(UIView, true)

function LegendaryWeaponAttriItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextAttri = nil
	--self.TextAttriValue = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponAttriItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponAttriItemView:OnInit()

end

function LegendaryWeaponAttriItemView:OnDestroy()

end

function LegendaryWeaponAttriItemView:OnShow()
	local Params = self.Params
	if nil == Params then return end
	local AttrInfo = Params.Data
	self.TextAttri:SetText(AttrInfo.Attr)
	self.TextAttriValue:SetText(AttrInfo.Value)
end

function LegendaryWeaponAttriItemView:OnHide()

end

function LegendaryWeaponAttriItemView:OnRegisterUIEvent()

end

function LegendaryWeaponAttriItemView:OnRegisterGameEvent()

end

function LegendaryWeaponAttriItemView:OnRegisterBinder()

end

return LegendaryWeaponAttriItemView