---
--- Author: anypkvcai
--- DateTime: 2023-03-27 19:15
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommBtnParentView = require("Game/Common/Btn/CommBtnParentView")
local WidgetCallback = require("UI/WidgetCallback")

---@class CommBtnXLView : CommBtnParentView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Button UFButton
---@field Img UFImage
---@field TextContent UFTextBlock
---@field AnimPressed UWidgetAnimation
---@field AnimReleased UWidgetAnimation
---@field bAutoAddSpace bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommBtnXLView = LuaClass(CommBtnParentView, true)

function CommBtnXLView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Button = nil
	--self.Img = nil
	--self.TextContent = nil
	--self.AnimPressed = nil
	--self.AnimReleased = nil
	--self.bAutoAddSpace = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommBtnXLView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommBtnXLView:OnInit()
	self:SetImgAssetPath()
	self.Super:OnInit()
	self.OnCommonBtnClicked = WidgetCallback.New()
end

function CommBtnXLView:OnDestroy()
	self.Super:OnDestroy()
end

function CommBtnXLView:OnShow()
	self.Super:OnShow()

	if(self.bAutoAddSpace == true) then
		UIUtil.AutoAddSpaceForTwoWords(self.TextContent)
	end
	---初始化时播放Released动画的结尾，防止上一次动画异常中断导致的按钮表现异常
	self:SetReleaseAnimEnd()
end

function CommBtnXLView:OnHide()

end

function CommBtnXLView:OnRegisterUIEvent()
	self.Super:OnRegisterUIEvent()
	
	UIUtil.AddOnPressedEvent(self, self.Button, self.OnPressedButton)
	UIUtil.AddOnReleasedEvent(self, self.Button, self.OnReleasedButton)
end

function CommBtnXLView:OnRegisterGameEvent()

end

function CommBtnXLView:OnRegisterBinder()

end

function CommBtnXLView:OnPressedButton()
	self:PlayAnimation(self.AnimPressed)
end

function CommBtnXLView:OnReleasedButton()
	self:PlayAnimation(self.AnimReleased)
end

function CommBtnXLView:OnAnimationFinished(Animation)
	if Animation == self.AnimReleased then
		self.OnCommonBtnClicked:OnTriggered()
	end
end

return CommBtnXLView