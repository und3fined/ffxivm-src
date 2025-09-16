---
--- Author: anypkvcai
--- DateTime: 2022-01-23 14:35
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommBtnBaseView = require("Game/Common/Btn/CommBtnBaseView")

---@class Comm1BtnMView : CommBtnBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Button UFButton
---@field TextButton UTextBlock
---@field AnimPressed UWidgetAnimation
---@field AnimState01 UWidgetAnimation
---@field AnimState02 UWidgetAnimation
---@field AnimState03 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Comm1BtnMView = LuaClass(CommBtnBaseView, true)

function Comm1BtnMView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Button = nil
	--self.TextButton = nil
	--self.AnimPressed = nil
	--self.AnimState01 = nil
	--self.AnimState02 = nil
	--self.AnimState03 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Comm1BtnMView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Comm1BtnMView:OnInit()
	self.TextRawColorAndOpacity = self.TextButton.ColorAndOpacity
	self.Super:OnInit()
end

function Comm1BtnMView:OnDestroy()
	self.Super:OnDestroy()
end

function Comm1BtnMView:OnShow()

end

function Comm1BtnMView:OnHide()

end

function Comm1BtnMView:OnRegisterUIEvent()

end

function Comm1BtnMView:OnRegisterGameEvent()

end

function Comm1BtnMView:OnRegisterBinder()

end

function Comm1BtnMView:SetIsEnable(IsEnable)

	if IsEnable then
		UIUtil.SetIsVisible(self.Button,true,true)
		self.TextButton:SetColorAndOpacity(self.TextRawColorAndOpacity)
		UIUtil.SetIsVisible(self.Eff,true,false)
		self:PlayColorAnimation()
	else
		self.Button:SetVisibility(_G.UE.ESlateVisibility.HitTestInvisible)
		UIUtil.SetIsVisible(self.Eff,false,false)
		self:StopAllAnimations()
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextButton,"#a1a1a1")
		UIUtil.ImageSetColorAndOpacity(self.FImg_Btn,1,1,1,1)
	end
end

return Comm1BtnMView