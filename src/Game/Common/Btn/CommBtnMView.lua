---
--- Author: anypkvcai
--- DateTime: 2023-03-27 17:13
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommBtnParentView = require("Game/Common/Btn/CommBtnParentView")
local WidgetCallback = require("UI/WidgetCallback")

---@class CommBtnMView : CommBtnParentView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Button UFButton
---@field Img UFImage
---@field TextContent UFTextBlock
---@field AnimPressed UWidgetAnimation
---@field AnimReleased UWidgetAnimation
---@field bAutoAddSpace bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommBtnMView = LuaClass(CommBtnParentView, true)

function CommBtnMView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Button = nil
	--self.Img = nil
	--self.TextContent = nil
	--self.AnimPressed = nil
	--self.AnimReleased = nil
	--self.bAutoAddSpace = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommBtnMView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommBtnMView:OnInit()
	self:SetImgAssetPath()
	self.Super:OnInit()
	self.OnCommonBtnClicked = WidgetCallback.New()
end

function CommBtnMView:OnDestroy()
	self.Super:OnDestroy()
end

function CommBtnMView:OnShow()
	self.Super:OnShow()

	if(self.bAutoAddSpace == true) then
		UIUtil.AutoAddSpaceForTwoWords(self.TextContent)
	end
	---初始化时播放Released动画的结尾，防止上一次动画异常中断导致的按钮表现异常
	self:SetReleaseAnimEnd()
end

function CommBtnMView:OnHide()

end

function CommBtnMView:OnRegisterUIEvent()
	self.Super:OnRegisterUIEvent()
	
	UIUtil.AddOnPressedEvent(self, self.Button, self.OnPressedButton)
	UIUtil.AddOnReleasedEvent(self, self.Button, self.OnReleasedButton)
end

function CommBtnMView:OnRegisterGameEvent()

end

function CommBtnMView:OnRegisterBinder()

end

function CommBtnMView:OnPressedButton()
	self:PlayAnimation(self.AnimPressed)
end

function CommBtnMView:OnReleasedButton()
	self:PlayAnimation(self.AnimReleased)
end

function CommBtnMView:OnAnimationFinished(Animation)
	if Animation == self.AnimReleased then
		self.OnCommonBtnClicked:OnTriggered()
	end
end

function CommBtnMView:SetButtonText(Text)
	if nil == Text then
		return
	end

	self.TextContent:SetText(Text)
end

---新人攻略特殊需要，不要描边和阴影 - 描边
function CommBtnMView:SetButtonTextOutlineEnable(bEnable)
	local OutlineSize
	if bEnable then
		OutlineSize = 2
	else
		OutlineSize = 0
	end
	self.TextContent.Font.OutlineSettings.OutlineSize = OutlineSize
	self.TextContent:SetFont(self.TextContent.Font)
end

---新人攻略特殊需要，不要描边和阴影 - 阴影
function CommBtnMView:SetButtonTextShadowEnable(bEnable)
	local Color 
	if bEnable then
		Color = {
			R = 0,
			G = 0,
			B = 0,
			A = 1,
		}
	else
		Color = {
			R = 0,
			G = 0,
			B = 0,
			A = 0,
		}
	end
	UIUtil.TextBlockSetShadowColorAndOpacity(self.TextContent, Color.R, Color.G, Color.B, Color.A)
end

return CommBtnMView