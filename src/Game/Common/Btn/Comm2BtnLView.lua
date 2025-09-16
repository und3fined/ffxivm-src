---
--- Author: anypkvcai
--- DateTime: 2022-05-17 17:52
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommBtnBaseView = require("Game/Common/Btn/CommBtnBaseView")

---@class Comm2BtnLView : CommBtnBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Button UFButton
---@field TextButton UTextBlock
---@field AnimPressed UWidgetAnimation
---@field AnimState01 UWidgetAnimation
---@field AnimState02 UWidgetAnimation
---@field AnimState03 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Comm2BtnLView = LuaClass(CommBtnBaseView, true)

function Comm2BtnLView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Button = nil
	--self.TextButton = nil
	--self.AnimPressed = nil
	--self.AnimState01 = nil
	--self.AnimState02 = nil
	--self.AnimState03 = nil
	--self.PlayColorAnimation = function(self) end
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Comm2BtnLView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Comm2BtnLView:OnInit()
	self.TextRawColorAndOpacity = self.TextButton.ColorAndOpacity
	self.Super:OnInit()
end

function Comm2BtnLView:OnDestroy()
	self.Super:OnDestroy()
end

function Comm2BtnLView:OnShow()

end

function Comm2BtnLView:OnHide()

end

function Comm2BtnLView:OnRegisterUIEvent()

end

function Comm2BtnLView:OnRegisterGameEvent()

end

function Comm2BtnLView:OnRegisterBinder()

end

function Comm2BtnLView:SetIsEnable(IsEnable)

	if IsEnable then
		UIUtil.SetIsVisible(self.Button, true, true)
		self.TextButton:SetColorAndOpacity(self.TextRawColorAndOpacity)
		UIUtil.SetIsVisible(self.Eff, true, false)
		self:PlayColorAnimation()
	else
		self.Button:SetVisibility(_G.UE.ESlateVisibility.HitTestInvisible)
		UIUtil.SetIsVisible(self.Eff, false, false)
		self:StopAllAnimations()
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextButton, "#a1a1a1")
		UIUtil.ImageSetColorAndOpacity(self.FImg_Btn, 1, 1, 1, 1)
	end
end

function Comm2BtnLView:SetButtonText(Text)
	if nil == Text then
		return
	end

	self.TextButton:SetText(Text)
end

return Comm2BtnLView