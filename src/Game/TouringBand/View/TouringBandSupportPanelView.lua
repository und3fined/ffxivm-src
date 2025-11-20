---
--- Author: Administrator
--- DateTime: 2025-02-12 10:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")

---@class TouringBandSupportPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Action1 TouringBandActionItemView
---@field Action2 TouringBandActionItemView
---@field Action3 TouringBandActionItemView
---@field Action4 TouringBandActionItemView
---@field Action5 TouringBandActionItemView
---@field FCanvasPanel_22 UFCanvasPanel
---@field M_DX_TouringBand_4a UFImage
---@field M_DX_TouringBand_4b UFImage
---@field M_DX_TouringBand_4c UFImage
---@field M_DX_TouringBand_4d UFImage
---@field M_DX_TouringBand_4e UFImage
---@field PanelHint UFCanvasPanel
---@field PanelProBar UFCanvasPanel
---@field PanelText UFCanvasPanel
---@field ProBarFull UFProgressBar
---@field TextHint UFTextBlock
---@field TextSuccess UFTextBlock
---@field AnimClick UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimShow UWidgetAnimation
---@field AnimSuccessLoop UWidgetAnimation
---@field AnimTips UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TouringBandSupportPanelView = LuaClass(UIView, true)

function TouringBandSupportPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Action1 = nil
	--self.Action2 = nil
	--self.Action3 = nil
	--self.Action4 = nil
	--self.Action5 = nil
	--self.FCanvasPanel_22 = nil
	--self.M_DX_TouringBand_4a = nil
	--self.M_DX_TouringBand_4b = nil
	--self.M_DX_TouringBand_4c = nil
	--self.M_DX_TouringBand_4d = nil
	--self.M_DX_TouringBand_4e = nil
	--self.PanelHint = nil
	--self.PanelProBar = nil
	--self.PanelText = nil
	--self.ProBarFull = nil
	--self.TextHint = nil
	--self.TextSuccess = nil
	--self.AnimClick = nil
	--self.AnimLoop = nil
	--self.AnimShow = nil
	--self.AnimSuccessLoop = nil
	--self.AnimTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TouringBandSupportPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Action1)
	self:AddSubView(self.Action2)
	self:AddSubView(self.Action3)
	self:AddSubView(self.Action4)
	self:AddSubView(self.Action5)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TouringBandSupportPanelView:OnInit()
	self.ProgressMDX = 
	{
		self.M_DX_TouringBand_4a,
		self.M_DX_TouringBand_4b,
		self.M_DX_TouringBand_4c,
		self.M_DX_TouringBand_4d,
		self.M_DX_TouringBand_4e,
	}
end

function TouringBandSupportPanelView:OnDestroy()

end

function TouringBandSupportPanelView:OnShow()
	
end

function TouringBandSupportPanelView:OnHide()

end

function TouringBandSupportPanelView:OnRegisterUIEvent()
	
end

function TouringBandSupportPanelView:OnRegisterGameEvent()

end

function TouringBandSupportPanelView:OnRegisterBinder()
	self.SkillVM = _G.TouringBandMgr:GetTouringBandActionBtnVM()
	local Binders = {
		{ "IsVisible", UIBinderSetIsVisible.New(self, self.FCanvasPanel_22) },
		{ "IsProBarVisible", UIBinderSetIsVisible.New(self, self.PanelProBar) },
		{ "IsVisible", UIBinderValueChangedCallback.New(self, nil, self.OnRootVisible) },
		{ "IsPlayClickAnim", UIBinderValueChangedCallback.New(self, nil, self.OnPlayClickAnim) },
		{ "Progress", UIBinderSetPercent.New(self, self.ProBarFull) },
	}
	
	self:RegisterBinders(self.SkillVM, Binders)
end

function TouringBandSupportPanelView:OnPlayClickAnim(NewValue)
	if self.SkillVM == nil then
		return
	end
	
	if NewValue then
		if self:IsAnimationPlaying(self.AnimTips) then
			self:PlayAnimToEnd(self.AnimTips)
		end
		
		-- 三种情况：1.没有成功，2.常驻乐团成功，3.巡回乐团成功
		if self.SkillVM.CurActionNum >= _G.TouringBandMgr:GetCheeringMaxNum() then
			if self.TimerID then
				self:UnRegisterTimer(self.TimerID)
				self.TimerID = nil
			end
			local Time = _G.TouringBandMgr:GetCurTimelineLeftTime()
			if Time > 0 then
				UIUtil.SetIsVisible(self.PanelText, false)
				UIUtil.SetIsVisible(self.PanelHint, true)
				self.TimerID = self:RegisterTimer(self.OnTimer, 0, 1, 0)
			else
				UIUtil.SetIsVisible(self.PanelText, true)
				UIUtil.SetIsVisible(self.PanelHint, false)
				self.TextSuccess:SetText(_G.LSTR(450024)) -- 应援成功
			end
			if not self:IsAnimationPlaying(self.AnimSuccessLoop) then
				self:PlayAnimation(self.AnimSuccessLoop,0,0)
			end
		else
			if self.TimerID then
				self:UnRegisterTimer(self.TimerID)
				self.TimerID = nil
			end
			UIUtil.SetIsVisible(self.PanelText, true)
			UIUtil.SetIsVisible(self.PanelHint, false)
			self.TextSuccess:SetText(_G.LSTR(450027))
			for i, Effect in ipairs(self.ProgressMDX) do
				UIUtil.SetIsVisible(Effect, i == self.SkillVM.CurActionNum, false, true)
				UIUtil.SetRenderOpacity(Effect, 0)
			end
			self:PlayAnimation(self.AnimClick)
		end
	end
end

function TouringBandSupportPanelView:OnRootVisible(NewValue)
	if self:IsAnimationPlaying(self.AnimTips) then
		self:PlayAnimToEnd(self.AnimTips)
	end
	if self:IsAnimationPlaying(self.AnimClick) then
		self:PlayAnimToEnd(self.AnimClick)
	end
	
	if NewValue then
		UIUtil.SetIsVisible(self.PanelText, false)
		UIUtil.SetIsVisible(self.PanelHint, false)
		if self.SkillVM and self.SkillVM.CurActionNum >= _G.TouringBandMgr:GetCheeringMaxNum() then
			if self.TimerID then
				self:UnRegisterTimer(self.TimerID)
				self.TimerID = nil
			end

			local Time = _G.TouringBandMgr:GetCurTimelineLeftTime()
			if Time > 0 then
				UIUtil.SetIsVisible(self.PanelText, false)
				UIUtil.SetIsVisible(self.PanelHint, true)
				self.TimerID = self:RegisterTimer(self.OnTimer, 0, 1, 0)
			else
				UIUtil.SetIsVisible(self.PanelText, true)
				UIUtil.SetIsVisible(self.PanelHint, false)
				self.TextSuccess:SetText(_G.LSTR(450024)) -- 应援成功
			end
		else
			if self.TimerID then
				self:UnRegisterTimer(self.TimerID)
				self.TimerID = nil
			end
			self.TextHint:SetText(_G.LSTR(450030)) -- 点击动作完成应援
			self.TextSuccess:SetText(_G.LSTR(450027)) -- 气氛提升！
		end
		self:PlayAnimation(self.AnimShow)
	end
end

function TouringBandSupportPanelView:OnAnimationFinished(Anim)
	if Anim == self.AnimClick then
		UIUtil.SetIsVisible(self.PanelHint, false)
	elseif Anim == self.AnimShow then
		if self.SkillVM and self.SkillVM.CurActionNum >= _G.TouringBandMgr:GetCheeringMaxNum() then
			self:PlayAnimation(self.AnimSuccessLoop,0,0)
		else
			UIUtil.SetIsVisible(self.PanelHint, true)
			self:PlayAnimation(self.AnimTips)
		end
	end
end

function TouringBandSupportPanelView:OnTimer()
	local Time = _G.TouringBandMgr:GetCurTimelineLeftTime()
	if Time > 0 then
		local TimerStr = TimeUtil.GetTimeFormat("%M:%S", Time)
		self.TextHint:SetText(_G.LSTR(450034) .. ":" .. TimerStr)
	else
		self.TextSuccess:SetText(_G.LSTR(450024)) -- 应援成功
		self:UnRegisterTimer(self.TimerID)
		self.TimerID = nil
	end
end

return TouringBandSupportPanelView