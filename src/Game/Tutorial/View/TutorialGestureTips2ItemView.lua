---
--- Author: Administrator
--- DateTime: 2023-05-19 10:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")

---@class TutorialGestureTips2ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgArrowDown UFImage
---@field ImgArrowLeft UFImage
---@field ImgArrowRight UFImage
---@field ImgArrowUp UFImage
---@field PanelProBar UFCanvasPanel
---@field ProBarFull URadialImage
---@field RichTextTips URichTextBox
---@field AnimInDown UWidgetAnimation
---@field AnimInLeft UWidgetAnimation
---@field AnimInRight UWidgetAnimation
---@field AnimInUp UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimProgress UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TutorialGestureTips2ItemView = LuaClass(UIView, true)

function TutorialGestureTips2ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgArrowDown = nil
	--self.ImgArrowLeft = nil
	--self.ImgArrowRight = nil
	--self.ImgArrowUp = nil
	--self.PanelProBar = nil
	--self.ProBarFull = nil
	--self.RichTextTips = nil
	--self.AnimInDown = nil
	--self.AnimInLeft = nil
	--self.AnimInRight = nil
	--self.AnimInUp = nil
	--self.AnimOut = nil
	--self.AnimProgress = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TutorialGestureTips2ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TutorialGestureTips2ItemView:OnInit()
	self.Anim = nil
end

function TutorialGestureTips2ItemView:OnDestroy()

end

function TutorialGestureTips2ItemView:OnShow()
end

function TutorialGestureTips2ItemView:OnHide()
	self:StopAnimation(self.Anim)
	self:RemoveTimer()
end

function TutorialGestureTips2ItemView:OnRegisterUIEvent()

end

function TutorialGestureTips2ItemView:OnRegisterGameEvent()

end

function TutorialGestureTips2ItemView:OnRegisterBinder()

end

function TutorialGestureTips2ItemView:SetText(Content)
	self.RichTextTips:SetText(Content)
end

function TutorialGestureTips2ItemView:NearBySkill(Dir)
	UIUtil.SetIsVisible(self.ImgArrowDown, TutorialDefine.TutorialArrowDir.Bottom == Dir)
	UIUtil.SetIsVisible(self.ImgArrowLeft, TutorialDefine.TutorialArrowDir.Left == Dir)
	UIUtil.SetIsVisible(self.ImgArrowRight, TutorialDefine.TutorialArrowDir.Right == Dir)
	UIUtil.SetIsVisible(self.ImgArrowUp, TutorialDefine.TutorialArrowDir.Top == Dir)

	if TutorialDefine.TutorialArrowDir.Bottom == Dir then
		self.Anim = self.AnimInUp
	elseif TutorialDefine.TutorialArrowDir.Left == Dir then
		self.Anim = self.AnimInRight

	elseif TutorialDefine.TutorialArrowDir.Right == Dir then
		self.Anim = self.AnimInLeft

	elseif TutorialDefine.TutorialArrowDir.Top == Dir then
		self.Anim = self.AnimInDown
	end

	if self.Anim then
		self:PlayAnimation(self.Anim)
	end
end

function TutorialGestureTips2ItemView:NearBy(Dir,Cfg)
	UIUtil.SetIsVisible(self.ImgArrowDown, TutorialDefine.TutorialArrowDir.Bottom == Dir)
	UIUtil.SetIsVisible(self.ImgArrowLeft, TutorialDefine.TutorialArrowDir.Left == Dir)
	UIUtil.SetIsVisible(self.ImgArrowRight, TutorialDefine.TutorialArrowDir.Right == Dir)
	UIUtil.SetIsVisible(self.ImgArrowUp, TutorialDefine.TutorialArrowDir.Top == Dir)

	if TutorialDefine.TutorialArrowDir.Bottom == Dir then
		self.Anim = self.AnimInUp
		if Cfg ~= nil and Cfg.Type == TutorialDefine.TutorialType.NoFuncForce then
			self.Anim = self.AnimInUpNoArray
		end
	elseif TutorialDefine.TutorialArrowDir.Left == Dir then
		self.Anim = self.AnimInRight
		if Cfg ~= nil and Cfg.Type == TutorialDefine.TutorialType.NoFuncForce then
			self.Anim = self.AnimInRightNoArray
		end
	elseif TutorialDefine.TutorialArrowDir.Right == Dir then
		self.Anim = self.AnimInLeft
		if Cfg ~= nil and Cfg.Type == TutorialDefine.TutorialType.NoFuncForce then
			self.Anim = self.AnimInLeftNoArray
		end
	elseif TutorialDefine.TutorialArrowDir.Top == Dir then
		self.Anim = self.AnimInDown
		if Cfg ~= nil and Cfg.Type == TutorialDefine.TutorialType.NoFuncForce then
			self.Anim = self.AnimInDownNoArray
		end
	end

	if self.Anim then
		self:PlayAnimation(self.Anim)
	end

	if Cfg ~= nil and Cfg.Type == TutorialDefine.TutorialType.NoFuncForce then
		UIUtil.SetIsVisible(self.PanelProBar, false)
	end
end

function TutorialGestureTips2ItemView:StartCountDown(Time, View, Callback)
	self:RemoveTimer()

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

function TutorialGestureTips2ItemView:RemoveTimer()
	if self.TimerHdl then
		self:UnRegisterTimer(self.TimerHdl)
		self.TimerHdl = nil
	end
end

return TutorialGestureTips2ItemView