---
--- Author: Administrator
--- DateTime: 2024-07-31 17:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")

---@class TutorialGestureTipsSystemItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgArrowDown UFImage
---@field ImgArrowLeft UFImage
---@field ImgArrowRight UFImage
---@field ImgArrowUp UFImage
---@field PanelContinue UFCanvasPanel
---@field PanelProBar UFCanvasPanel
---@field ProBarFull URadialImage
---@field RichTextTips URichTextBox
---@field AnimInDown UWidgetAnimation
---@field AnimInLeft UWidgetAnimation
---@field AnimInRight UWidgetAnimation
---@field AnimInUp UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TutorialGestureTipsSystemItemView = LuaClass(UIView, true)

function TutorialGestureTipsSystemItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgArrowDown = nil
	--self.ImgArrowLeft = nil
	--self.ImgArrowRight = nil
	--self.ImgArrowUp = nil
	--self.PanelContinue = nil
	--self.PanelProBar = nil
	--self.ProBarFull = nil
	--self.RichTextTips = nil
	--self.AnimInDown = nil
	--self.AnimInLeft = nil
	--self.AnimInRight = nil
	--self.AnimInUp = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TutorialGestureTipsSystemItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TutorialGestureTipsSystemItemView:OnInit()

end

function TutorialGestureTipsSystemItemView:OnDestroy()

end

function TutorialGestureTipsSystemItemView:OnShow()
end

function TutorialGestureTipsSystemItemView:OnHide()
	self:RemoveTimer()
end

function TutorialGestureTipsSystemItemView:OnRegisterUIEvent()

end

function TutorialGestureTipsSystemItemView:OnRegisterGameEvent()

end

function TutorialGestureTipsSystemItemView:OnRegisterBinder()
end

function TutorialGestureTipsSystemItemView:SetText(Content)
	self.RichTextTips:SetText(Content)
end

function TutorialGestureTipsSystemItemView:StartCountDown(Time, View, Callback)
	self:RemoveTimer()
	UIUtil.SetIsVisible(self.PanelProBar, false)

	local Inv = 0.05

	if Time and Time > 0 then
		self.CountDown = Time
		UIUtil.SetIsVisible(self.PanelProBar, true)

		local Duration = Time
		local PlaySpeed = self.AnimProgress:GetEndTime() / Duration
		self:PlayAnimation(self.AnimProgress, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, PlaySpeed)

		local Start = TimeUtil.GetLocalTimeMS()
		self.TimerHdl = self:RegisterTimer(function()
			local Cur = TimeUtil.GetLocalTimeMS()
			local Delta = (Cur - Start) / 1000
			if Delta > self.CountDown then
				if Callback ~= nil then
					self:RemoveTimer()
					Callback(View)
				end
				return
			end
		end, 0, Inv, 0)
	else
		UIUtil.SetIsVisible(self.PanelProBar, false)
	end

end

function TutorialGestureTipsSystemItemView:RemoveTimer()
	if self.TimerHdl then
		self:UnRegisterTimer(self.TimerHdl)
		self.TimerHdl = nil
	end
end

function TutorialGestureTipsSystemItemView:NearBy(Dir,Cfg)
	UIUtil.SetIsVisible(self.ImgArrowDown, TutorialDefine.TutorialArrowDir.Bottom == Dir)
	UIUtil.SetIsVisible(self.ImgArrowLeft, TutorialDefine.TutorialArrowDir.Left == Dir)
	UIUtil.SetIsVisible(self.ImgArrowRight, TutorialDefine.TutorialArrowDir.Right == Dir)
	UIUtil.SetIsVisible(self.ImgArrowUp, TutorialDefine.TutorialArrowDir.Top == Dir)

	local Anim = nil

	if TutorialDefine.TutorialArrowDir.Bottom == Dir then
		Anim = self.AnimInUp
		if Cfg ~= nil and Cfg.Type == TutorialDefine.TutorialType.NoFuncForce then
			Anim = self.AnimInUpNoArray
		end
	elseif TutorialDefine.TutorialArrowDir.Left == Dir then
		Anim = self.AnimInRight
		if Cfg ~= nil and Cfg.Type == TutorialDefine.TutorialType.NoFuncForce then
			Anim = self.AnimInRightNoArray
		end
	elseif TutorialDefine.TutorialArrowDir.Right == Dir then
		Anim = self.AnimInLeft
		if Cfg ~= nil and Cfg.Type == TutorialDefine.TutorialType.NoFuncForce then
			Anim = self.AnimInLeftNoArray
		end
	elseif TutorialDefine.TutorialArrowDir.Top == Dir then
		Anim = self.AnimInDown
		if Cfg ~= nil and Cfg.Type == TutorialDefine.TutorialType.NoFuncForce then
			Anim = self.AnimInDownNoArray
		end
	end

	if Anim then
		self:PlayAnimation(Anim)
	end

	if Cfg ~= nil and Cfg.Type == TutorialDefine.TutorialType.NoFuncForce then
		UIUtil.SetIsVisible(self.PanelProBar, false)
	end

end


return TutorialGestureTipsSystemItemView