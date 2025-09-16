---
--- Author: chriswang
--- DateTime: 2023-10-20 14:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LoginCreateDateItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDate UFButton
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field TextDateNum UFTextBlock
---@field AnimChecked UWidgetAnimation
---@field AnimUnchecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateDateItemView = LuaClass(UIView, true)

function LoginCreateDateItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDate = nil
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--self.TextDateNum = nil
	--self.AnimChecked = nil
	--self.AnimUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateDateItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateDateItemView:OnInit()

end

function LoginCreateDateItemView:OnDestroy()

end

function LoginCreateDateItemView:OnShow()
	if self.Params and self.Params.Data then
		if nil ~= self.TextDateNum then
			self.TextDateNum:SetText(self.Params.Data)
		end
	end
end

function LoginCreateDateItemView:OnHide()

end

function LoginCreateDateItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnDate, self.OnBtnDateClick)
end

function LoginCreateDateItemView:OnRegisterGameEvent()

end

function LoginCreateDateItemView:OnRegisterBinder()

end

function LoginCreateDateItemView:OnSelectChanged(IsSelected)
	self:StopAllAnimations()
	if IsSelected then
		UIUtil.SetIsVisible(self.ImgSelect, true)
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextDateNum, "183f7bFF")
		self:PlayAnimation(self.AnimChecked)
	else
		UIUtil.SetIsVisible(self.ImgSelect, false)
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextDateNum, "b4d5f1FF")
		self:PlayAnimation(self.AnimUnchecked)
	end
end

function LoginCreateDateItemView:OnBtnDateClick()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemClicked(self, Params.Index)
end

return LoginCreateDateItemView