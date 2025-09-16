---
--- Author: Administrator
--- DateTime: 2023-11-10 15:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetSliderWithCurve = require("Binder/UIBinderSetSliderWithCurve")
local CrafterGoldsmithVM = require("Game/Crafter/View/Goldsmith/CrafterGoldsmithVM")
local MajorUtil = require("Utils/MajorUtil")

-- 指针动画时长
local SliderMoveTime = 0.53

---@class CrafterGoldsmithMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CarpenterSkill1 CrafterSkillItemView
---@field CarpenterSkill2 CrafterSkillItemView
---@field CarpenterSkill3 CrafterSkillItemView
---@field Carpenternervous UFCanvasPanel
---@field CrafterGoldsmith CrafterGoldsmithItemView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterGoldsmithMainPanelView = LuaClass(UIView, true)

function CrafterGoldsmithMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CarpenterSkill1 = nil
	--self.CarpenterSkill2 = nil
	--self.CarpenterSkill3 = nil
	--self.Carpenternervous = nil
	--self.CrafterGoldsmith = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterGoldsmithMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CarpenterSkill1)
	self:AddSubView(self.CarpenterSkill2)
	self:AddSubView(self.CarpenterSkill3)
	self:AddSubView(self.CrafterGoldsmith)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterGoldsmithMainPanelView:OnInit()
	self.CrafterGoldsmithVM = CrafterGoldsmithVM.New()
	self.BtnBeginIndex = 1
	self.BtnEndIndex = 3
end

function CrafterGoldsmithMainPanelView:OnDestroy()

end

function CrafterGoldsmithMainPanelView:OnShow()
	self.CrafterGoldsmithVM:ResetParams()
	local Params = self.Params
	if not Params then
		return
	end

	self.CrafterGoldsmithVM:UpdateFeatures(Params.Features)
	self.CrafterGoldsmith:UpdateFeatures(Params.Features)
	self.CrafterGoldsmithVM:UpdateBuffEffects()
	self.CrafterGoldsmith:UpdateBuffEffects(self.CrafterGoldsmithVM.TensionState,self.CrafterGoldsmithVM.bIsPurpleZoneVisible)

	if not Params.bIsReconnect then
		return
	end
	local BuffMap = _G.LifeSkillBuffMgr.Map[MajorUtil.GetMajorEntityID()]
	if not BuffMap then
		return
	end
	BuffMap = BuffMap.Map
	if not BuffMap then
		return
	end
	for _, BuffInfo in pairs(BuffMap) do
		self:OnBuffAdd(BuffInfo)
	end
end

function CrafterGoldsmithMainPanelView:OnHide()

end

function CrafterGoldsmithMainPanelView:OnRegisterUIEvent()

end

function CrafterGoldsmithMainPanelView:OnRegisterGameEvent()
	local EventID = _G.EventID
	self:RegisterGameEvent(EventID.MajorAddBuffLife, self.OnBuffAdd)
	self:RegisterGameEvent(EventID.MajorRemoveBuffLife, self.OnBuffRemove)
	self:RegisterGameEvent(EventID.CrafterSkillCDUpdate, self.OnCrafterSkillCDUpdate)
	self:RegisterGameEvent(EventID.CrafterSkillRsp, self.OnEventCrafterSkillRsp)
	self:RegisterGameEvent(EventID.CrafterSkillCostUpdate, self.OnCrafterSkillCostUpdate)
end

function CrafterGoldsmithMainPanelView:OnRegisterBinder()
	-- local GoldsmithThrill = self.CarpenterThrill
	-- local Binders = {
	-- 	{"TensionSliderPercent",        UIBinderSetSliderWithCurve.New(
	-- 		self, GoldsmithThrill.Slider, GoldsmithThrill.ThrillCurve, GoldsmithThrill.SliderMoveTime)},
	-- 	{"bIsTensionInRedZone",         UIBinderSetIsVisible.New(self, GoldsmithThrill.EFF_Orange)},
	-- 	{"bIsTensionInBlueZone",        UIBinderSetIsVisible.New(self, GoldsmithThrill.EFF_Blue)},
	-- 	{"bIsTensionInRightPurpleZone", UIBinderSetIsVisible.New(self, GoldsmithThrill.EFF_Purple2)},
	-- 	{"bIsTensionInLeftPurpleZone",  UIBinderSetIsVisible.New(self, GoldsmithThrill.EFF_Purple1)},
	-- 	{"bIsPurpleZoneVisible",        UIBinderSetIsVisible.New(self, GoldsmithThrill.ImgPurple1)},
	-- 	{"bIsPurpleZoneVisible",        UIBinderSetIsVisible.New(self, GoldsmithThrill.ImgPurple2)},
	-- 	{"bIsPurpleZoneVisible",        UIBinderSetIsVisible.New(self, GoldsmithThrill.ImgOrange, true)},
	-- 	{"bIsPurpleZoneVisible",        UIBinderSetIsVisible.New(self, GoldsmithThrill.ImgBlue, true)},
	-- }
	-- self:RegisterBinders(self.CrafterGoldsmithVM ,Binders)
end

function CrafterGoldsmithMainPanelView:OnCrafterSkillCDUpdate(Params)
	local BIndex = self.BtnBeginIndex
	local EIndex = self.BtnEndIndex
	for Index = BIndex, EIndex do
		self["CarpenterSkill" .. tostring(Index)]:OnCrafterSkillCDUpdate(Params)
	end
end

function CrafterGoldsmithMainPanelView:OnEventCrafterSkillRsp(MsgBody)
	if MsgBody and MsgBody.CrafterSkill then
		local MajorEntityID = MajorUtil.GetMajorEntityID()
		if MajorEntityID == MsgBody.ObjID then
			local CrafterGoldsmithVM = self.CrafterGoldsmithVM
			CrafterGoldsmithVM:UpdateFeatures(MsgBody.CrafterSkill.Features)
			self.CrafterGoldsmith:UpdateFeatures(MsgBody.CrafterSkill.Features)
			local BuffEffectTimer = self.BuffEffectTimer
			if BuffEffectTimer then
				self:UnRegisterTimer(BuffEffectTimer)
			end
			self.BuffEffectTimer = self:RegisterTimer(
				function()
					CrafterGoldsmithVM:UpdateBuffEffects()
					self.CrafterGoldsmith:UpdateBuffEffects(self.CrafterGoldsmithVM.TensionState, self.CrafterGoldsmithVM.bIsPurpleZoneVisible)
				end,
				SliderMoveTime, 0, 1)
		end
	end
end

function CrafterGoldsmithMainPanelView:OnBuffAdd(BuffInfo)
	self.CrafterGoldsmithVM:OnBuffChanged(BuffInfo.BuffID,true)
end

function CrafterGoldsmithMainPanelView:OnBuffRemove(BuffInfo)
	self.CrafterGoldsmithVM:OnBuffChanged(BuffInfo.BuffID,false)
end

function CrafterGoldsmithMainPanelView:OnCrafterSkillCostUpdate(Params)
	local BIndex = self.BtnBeginIndex
	local EIndex = self.BtnEndIndex
	for Index = BIndex, EIndex do
		self["CarpenterSkill" .. tostring(Index)]:OnCrafterSkillCostUpdate(Params)
	end
end

return CrafterGoldsmithMainPanelView