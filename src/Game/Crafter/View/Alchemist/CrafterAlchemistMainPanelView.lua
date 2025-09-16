---
--- Author: chriswang
--- DateTime: 2023-08-31 16:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local RecipeCfg = require("TableCfg/RecipeCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local CatalystCfg = require("TableCfg/CatalystCfg")
local MajorUtil = require("Utils/MajorUtil")
local LifeskillEffectCfg = require("TableCfg/LifeskillEffectCfg")

local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local SkillMainCfg = require("TableCfg/SkillMainCfg")

local AlchemistMainVM = require("Game/Crafter/Alchemist/AlchemistMainVM")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")

---@class CrafterAlchemistMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bottle11 CrafterAlchemistBottleItemView
---@field Bottle12 CrafterAlchemistBottleItemView
---@field Bottle13 CrafterAlchemistBottleItemView
---@field Bottle14 CrafterAlchemistBottleItemView
---@field Bottle15 CrafterAlchemistBottleItemView
---@field BottleDropEnterPanel BottleDropEnterPanelView
---@field BottlePanel UFCanvasPanel
---@field BtnAdjust CrafterAdjustItemView
---@field StrengthPanel CrafterStrengthItemView
---@field TextUse UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterAlchemistMainPanelView = LuaClass(UIView, true)

local BoomEventType = 101

function CrafterAlchemistMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bottle11 = nil
	--self.Bottle12 = nil
	--self.Bottle13 = nil
	--self.Bottle14 = nil
	--self.Bottle15 = nil
	--self.BottleDropEnterPanel = nil
	--self.BottlePanel = nil
	--self.BtnAdjust = nil
	--self.StrengthPanel = nil
	--self.TextUse = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterAlchemistMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bottle11)
	self:AddSubView(self.Bottle12)
	self:AddSubView(self.Bottle13)
	self:AddSubView(self.Bottle14)
	self:AddSubView(self.Bottle15)
	self:AddSubView(self.BottleDropEnterPanel)
	self:AddSubView(self.BtnAdjust)
	-- self:AddSubView(self.StrengthPanel)
	self:AddSubView(self.CrafterAlchemist)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterAlchemistMainPanelView:OnInit()
	self.BeginIndex = 11
	self.EndIndex = 15

	self.TextUse:SetText(_G.LSTR(150001))
end

function CrafterAlchemistMainPanelView:OnDestroy()

end

function CrafterAlchemistMainPanelView:OnShow()
	self.EntityID = MajorUtil.GetMajorEntityID()
	self.LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
	-- UIUtil.SetIsVisible(self.BtnAdjust, false)
	
	--催化剂
	self:UpdateCatalystInfo()
end

function CrafterAlchemistMainPanelView:OnHide()
end

function CrafterAlchemistMainPanelView:OnExitRecipeState()
	if self.ViewModel then
		self.ViewModel.bBtnAdjust = false
	end
end

function CrafterAlchemistMainPanelView:OnRegisterUIEvent()

end

function CrafterAlchemistMainPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.CrafterRandomEventSkill, self.OnRandomEventSkill)
	-- self:RegisterGameEvent(_G.EventID.MajorLifeSkillActionRsp, self.OnMajorLifeSkillActionRsp)
	self:RegisterGameEvent(_G.EventID.CrafterSkillCDUpdate, self.OnCrafterSkillCDUpdate)

    self:RegisterGameEvent(_G.EventID.CrafterSkillRsp, self.OnEventCrafterSkillRsp)
	self:RegisterGameEvent(_G.EventID.MajorLevelUpdate, self.OnMajorLevelUpdate)
    self:RegisterGameEvent(_G.EventID.BagUpdate, self.OnBagUpdate)
end

function CrafterAlchemistMainPanelView:OnRegisterBinder()
	self.ViewModel = AlchemistMainVM

	local Binders = {
		{"bBottleDropEnterPanel", UIBinderSetIsVisible.New(self, self.BottleDropEnterPanel, false, true)},
		{"bBtnAdjust", UIBinderSetIsVisible.New(self, self.BtnAdjust)},
		
	}

	self:RegisterBinders(self.ViewModel, Binders)

end

function CrafterAlchemistMainPanelView:OnCrafterSkillCDUpdate(Params)
	for Idx = self.BeginIndex, self.EndIndex do
		self["Bottle" .. Idx]:OnCrafterSkillCDUpdate(Params)
	end
end

function CrafterAlchemistMainPanelView:OnMajorLevelUpdate(Params)
	local bNoCatalyst = true
	for Idx = self.BeginIndex, self.EndIndex do
		local BottleView = self["Bottle" .. Idx]
		BottleView:OnMajorLevelUpdate(Params)

		if BottleView:GetLearned() == true then
			bNoCatalyst = false
		end
	end
	
	if bNoCatalyst then
		UIUtil.SetIsVisible(self.BottlePanel, false)
	else
		UIUtil.SetIsVisible(self.BottlePanel, true)
	end
end

function CrafterAlchemistMainPanelView:OnBagUpdate()
	for Idx = self.BeginIndex, self.EndIndex do
		local BottleView = self["Bottle" .. Idx]
		BottleView:OnBagUpdate()
	end
end

function CrafterAlchemistMainPanelView:OnUpdateSkillCostMaskFlag()
	for Idx = self.BeginIndex, self.EndIndex do
		local BottleView = self["Bottle" .. Idx]
		if BottleView then
			BottleView:OnUpdateSkillCostMaskFlag()
		end
	end
end

function CrafterAlchemistMainPanelView:UpdateCatalystInfo()
	local CatalystInfo = _G.CrafterMgr.CatalystInfo
	if not CatalystInfo then
		if self.LogicData == nil then
			return
		end
	
		CatalystInfo = {}
		for index = self.BeginIndex, self.EndIndex do
			local SkillID = self.LogicData:GetBtnSkillID(index)
			local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
			if Cfg then
				local CostUnit = nil
				for CostIdx = 1, #Cfg.CostList do
					CostUnit = Cfg.CostList[CostIdx]
					if CostUnit.AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_CATALYST then		--催化剂
						CatalystInfo[index] = {SkillID = SkillID, CatalystID = CostUnit.AssetId, CostNum = CostUnit.AssetCost}
						break
					end
				end
			end
		end

		_G.CrafterMgr.CatalystInfo = CatalystInfo
	end

	local bNoCatalyst = true
	for Idx = self.BeginIndex, self.EndIndex do
		local Info = CatalystInfo[Idx]
		local BottleView = self["Bottle" .. Idx]
		BottleView:UpdateCatalystInfo(Idx, Info, self.LogicData)

		if BottleView:GetLearned() == true then
			bNoCatalyst = false
		end
		-- local CatalystConfig = CatalystCfg:FindCfgByKey(Info.CatalystID)
		-- if CatalystConfig then
		-- 	local ItemNum =  _G.BagMgr:GetItemNum(CatalystConfig.ItemID)
		-- 	local BottleWidget = 
		-- 	BottleWidget.TextNumber:SetText(ItemNum)
		-- end
	end

	if bNoCatalyst then
		UIUtil.SetIsVisible(self.BottlePanel, false)
	else
		UIUtil.SetIsVisible(self.BottlePanel, true)
	end
end

function CrafterAlchemistMainPanelView:OnRandomEventSkill(RandomEventID, SkillID)
	if self.LogicData then
		self.RandomEventSkillID = SkillID

		if _G.CrafterSkillCheckMgr:CheckCondition(SkillID) == false then
			FLOG_WARNING("Crafter RandomEventSkill %d CheckCondition Failed", SkillID)
			return 
		end
		
		-- UIUtil.SetIsVisible(self.BtnAdjust, true, true)
		self.ViewModel.bBtnAdjust = true
		FLOG_INFO("Crafter OnRandomEventSkill bBtnAdjust = true  SkillID:%d", SkillID)
		
		--0-5是右下角的技能
		for index = 6, 21 do
			local ID = self.LogicData:GetBtnSkillID(index)
			if ID == SkillID then
				-- FLOG_INFO("Crafter OnRandomEventSkill, index:%d, SkillID:%d", index, SkillID)
				self.BtnAdjust:OnSkillReplace(index, SkillID)
				break
			end
		end
	end
end

-- function CrafterAlchemistMainPanelView:OnMajorLifeSkillActionRsp(Params)
-- 	local SkillID = Params.IntParam1
-- 	if self.RandomEventSkillID == SkillID then
-- 		_G.UIViewMgr:HideView(UIViewID.CrafterStateTips)
-- 	end
	
-- 	self.ViewModel.bBtnAdjust = false
-- 	-- UIUtil.SetIsVisible(self.BtnAdjust, false)
-- end

function CrafterAlchemistMainPanelView:OnEventCrafterSkillRsp(MsgBody)
    if MsgBody then
		local SkillID = MsgBody.LifeSkillID
		if self.RandomEventSkillID == SkillID then
			_G.UIViewMgr:HideView(_G.UIViewID.CrafterStateTips)
		end
		
		if not MsgBody.bReconnectRsp then
			self.ViewModel.bBtnAdjust = false
		end
		-- FLOG_INFO("Crafter OnEventCrafterSkillRsp bBtnAdjust = false")
		-- UIUtil.SetIsVisible(self.BtnAdjust, false)

		if MsgBody.CrafterSkill and MsgBody.CrafterSkill.EventIDs then
			local MajorEntityID = MajorUtil.GetMajorEntityID()

			local EventIDs = MsgBody.CrafterSkill.EventIDs
			local EventID = nil
			for index = 1, #EventIDs do
				EventID = EventIDs[index]
				if EventID == ProtoRes.EVENT_TYPE.EVENT_TYPE_BOOM then  --爆炸，只有炼金才有
					--爆炸失败的表现，这里可能是major，也可能是第三方
					if MajorEntityID == MsgBody.ObjID then
						-- MsgTipsUtil.ShowTips(LSTR("发生了炼金事故···"))
						_G.CrafterMgr:ShowStateTips({ EventType = BoomEventType })
					end

					--爆炸特效资源到位后，再播放，所有人都看的到
				end
			end
			
			-- self.StrengthPanel:UpdateSkillRsp(MsgBody.CrafterSkill)
			self.CrafterAlchemist:UpdateSkillRsp(MsgBody.CrafterSkill)
		end
		self:OnUpdateSkillCostMaskFlag()
    end
end

return CrafterAlchemistMainPanelView