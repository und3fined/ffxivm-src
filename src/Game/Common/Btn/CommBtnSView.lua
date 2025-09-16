---
--- Author: anypkvcai
--- DateTime: 2023-03-27 17:12
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommBtnParentView = require("Game/Common/Btn/CommBtnParentView")
local WidgetCallback = require("UI/WidgetCallback")

---@class CommBtnSView : CommBtnParentView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Button UFButton
---@field Img UFImage
---@field ProBarLongPress UProgressBar
---@field TextContent UFTextBlock
---@field AnimPressed UWidgetAnimation
---@field AnimReleased UWidgetAnimation
---@field ParamLongPress bool
---@field ParamPressTime float
---@field bAutoAddSpace bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommBtnSView = LuaClass(CommBtnParentView, true)

function CommBtnSView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Button = nil
	--self.Img = nil
	--self.ProBarLongPress = nil
	--self.TextContent = nil
	--self.AnimPressed = nil
	--self.AnimReleased = nil
	--self.ParamLongPress = nil
	--self.ParamPressTime = nil
	--self.bAutoAddSpace = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommBtnSView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommBtnSView:OnInit()
	self:SetImgAssetPath()
	self.Super:OnInit()

	if self.ParamLongPress then
		self.OnLongPressed = WidgetCallback.New()
		self.ProBarLongPress:SetPercent(0)
		UIUtil.ImageSetBrushFromAssetPath(self.Img, self.ImgDoneAssetPath)
		UIUtil.SetIsVisible(self.ProBarLongPress, true)
	else
		UIUtil.SetIsVisible(self.ProBarLongPress, false)
	end
end

function CommBtnSView:OnDestroy()
	if nil ~= self.OnLongPressed then
		self.OnLongPressed:Clear()
		self.OnLongPressed = nil
	end
	self.Super:OnDestroy()
end

function CommBtnSView:OnShow()
	self.Super:OnShow()

	self.ProBarLongPress:SetPercent(0)
	if(self.bAutoAddSpace == true) then
		UIUtil.AutoAddSpaceForTwoWords(self.TextContent)
	end
	---初始化时播放Released动画的结尾，防止上一次动画异常中断导致的按钮表现异常
	self:SetReleaseAnimEnd()
end

function CommBtnSView:OnHide()

end

function CommBtnSView:OnRegisterUIEvent()
	self.Super:OnRegisterUIEvent()
	UIUtil.AddOnPressedEvent(self, self.Button, self.OnPressedButton)
	UIUtil.AddOnReleasedEvent(self, self.Button, self.OnReleasedButton)
end

function CommBtnSView:OnRegisterGameEvent()

end

function CommBtnSView:OnRegisterBinder()

end

function CommBtnSView:OnPressedButton()
	self:PlayAnimation(self.AnimPressed)
	if not self.ParamLongPress then
		return
	end
	self.IsLongPressFinished = false

	self:UnRegisterAllTimer()

	self.TimerID = self:RegisterTimer(self.OnTimer, 0, 0.05, 0)

	self.ProBarLongPress:SetPercent(0)
end

function CommBtnSView:OnReleasedButton()
	if not self.IsLongPressFinished then
		self:PlayAnimation(self.AnimReleased)
	end
	if not self.ParamLongPress then
		return
	end
	if not self.IsLongPressFinished then
		self:UnRegisterAllTimer()
		self.ProBarLongPress:SetPercent(0)
	end
end

function CommBtnSView:OnTimer(_, ElapsedTime)
	local Time = self.ParamPressTime + 1

	if ElapsedTime < Time then
		self.ProBarLongPress:SetPercent(ElapsedTime / Time)
	else
		self.IsLongPressFinished = true

		self.ProBarLongPress:SetPercent(1)

		self:UnRegisterAllTimer()
		self:PlayAnimation(self.AnimReleased)
	end
end

function CommBtnSView:OnAnimationFinished(Animation)
	if Animation == self.AnimReleased and self.ParamLongPress and self.IsLongPressFinished then
		self.OnLongPressed:OnTriggered()
		self.IsLongPressFinished = false
		if (self.TimerID ~= nil) then
			self:UnRegisterTimer(self.TimerID)
			self.TimerID = nil
		end
	end
end

function  CommBtnSView:SetBtnName(Name)
	self.TextContent:SetText(Name or "")
end

---新人攻略特殊需要，不要描边和阴影 - 描边
function CommBtnSView:SetButtonTextOutlineEnable(bEnable)
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
function CommBtnSView:SetButtonTextShadowEnable(bEnable)
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

return CommBtnSView