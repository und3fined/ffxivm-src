---
--- Author: Administrator
--- DateTime: 2024-09-05 17:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local TreasureHuntMgr = _G.TreasureHuntMgr

---@class TreasureHuntBtnItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnMark UFButton
---@field BtnSkill UFButton
---@field PanelBtn UFCanvasPanel
---@field SkillPanel UFCanvasPanel
---@field TreasureMark UFCanvasPanel
---@field AnimClick UWidgetAnimation
---@field AnimTreasureHuntIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TreasureHuntBtnItemView = LuaClass(UIView, true)

function TreasureHuntBtnItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnMark = nil
	--self.BtnSkill = nil
	--self.PanelBtn = nil
	--self.SkillPanel = nil
	--self.TreasureMark = nil
	--self.AnimClick = nil
	--self.AnimTreasureHuntIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TreasureHuntBtnItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TreasureHuntBtnItemView:OnInit()
	self.Binders = {
		{ "SkillPanelVisible", UIBinderSetIsVisible.New(self, self.SkillPanel, false, true)},
		{ "TreasureMarkVisible", UIBinderSetIsVisible.New(self, self.TreasureMark, false, true)},
	}
end

function TreasureHuntBtnItemView:OnDestroy()

end

function TreasureHuntBtnItemView:OnShow()

end

function TreasureHuntBtnItemView:OnHide()

end

function TreasureHuntBtnItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSkill, self.OnClickButtonSkill)
	UIUtil.AddOnClickedEvent(self, self.BtnMark, self.OnClickButtonMark)
end

function TreasureHuntBtnItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.TreasureHuntShowSkillBtn,self.OnGameEventShowSkillBtn)
end

function TreasureHuntBtnItemView:OnRegisterBinder()
	local ViewModel = _G.TreasureHuntSkillPanelVM.BtnItemVM
	self:RegisterBinders(ViewModel, self.Binders)
end

function TreasureHuntBtnItemView:OnClickButtonSkill()
	if TreasureHuntMgr:CheckCanDigTreasure(true) then
		local Major = MajorUtil.GetMajor()
		if Major == nil then return end

		self:PlayAnimation(self.AnimClick)

		local RideCom = Major:GetRideComponent()
		if RideCom and RideCom:IsInRide() then
			_G.MountMgr:SendMountCancelCall(function() TreasureHuntMgr:PreDigTreasureReq() end)
		else
			TreasureHuntMgr:PreDigTreasureReq()
		end
	end
end

function TreasureHuntBtnItemView:OnClickButtonMark()
	UIUtil.SetIsVisible(self.TreasureMark,false)
	_G.TreasureHuntSkillPanelVM:MarkTreasureMapReq()
end

function TreasureHuntBtnItemView:OnGameEventShowSkillBtn()
	self:StopAnimation(self.AnimClick)
	self:PlayAnimation(self.AnimTreasureHuntIn)
end

return TreasureHuntBtnItemView