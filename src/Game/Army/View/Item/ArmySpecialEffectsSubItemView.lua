---
--- Author: Administrator
--- DateTime: 2024-10-15 18:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ArmySpecialEffectsSubItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInfo UFButton
---@field ImgIcon UFImage
---@field TextContent UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmySpecialEffectsSubItemView = LuaClass(UIView, true)

function ArmySpecialEffectsSubItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnInfo = nil
	--self.ImgIcon = nil
	--self.TextContent = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmySpecialEffectsSubItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmySpecialEffectsSubItemView:OnInit()

end

function ArmySpecialEffectsSubItemView:OnDestroy()

end

function ArmySpecialEffectsSubItemView:OnShow()

end

function ArmySpecialEffectsSubItemView:SetCallback(Owner, CallBack)
	self.Owner = Owner
	self.CallBack = CallBack
end

function ArmySpecialEffectsSubItemView:OnHide()

end

function ArmySpecialEffectsSubItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnInfo, self.OnClickedInfo)
end

function ArmySpecialEffectsSubItemView:OnClickedInfo()
	if self.Owner and self.CallBack then
		self.CallBack(self.Owner)
	end
end

function ArmySpecialEffectsSubItemView:OnRegisterGameEvent()

end

function ArmySpecialEffectsSubItemView:OnRegisterBinder()

end

return ArmySpecialEffectsSubItemView