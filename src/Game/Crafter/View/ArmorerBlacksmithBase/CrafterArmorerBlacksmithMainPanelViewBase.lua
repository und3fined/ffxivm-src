---
--- Author: henghaoli
--- DateTime: 2023-09-27 14:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetFormatTextValueWithCurve = require("Binder/UIBinderSetFormatTextValueWithCurve")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ProtoCS = require("Protocol/ProtoCS")
local CrafterArmorerBlacksmithVM = require("Game/Crafter/View/ArmorerBlacksmithBase/CrafterArmorerBlacksmithVM")
local CrafterArmorerBlacksmithTapVM = require("Game/Crafter/View/ArmorerBlacksmithBase/CrafterArmorerBlacksmithTapVM")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgTipsID = require("Define/MsgTipsID")
local RecipeCfg = require("TableCfg/RecipeCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local EventID = require("Define/EventID")
local CrafterConfig = require("Define/CrafterConfig")
local CrafterGlobalCfg = require("TableCfg/CrafterGlobalCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local EHeatType = CrafterConfig.ProfConfig[ProtoCommon.prof_type.PROF_TYPE_BLACKSMITH].EHeatType
local HotForgeSkillMap = CrafterConfig.HotForgeSkillMap
local SkillCheckErrorCode <const> = CrafterConfig.SkillCheckErrorCode

local ButtonIndex_Normal      <const> = 12   -- 普通捶打
local ButtonIndex_Skill       <const> = 9    -- 技巧捶打
local ButtonIndex_HotForge    <const> = 6    -- 热锻
local ButtonIndex_SkillSwitch <const> = 4    -- 技巧捶打开关

local PhaseCfgID = ProtoRes.crafter_global_cfg_id.CRAFTER_GLOBAL_CFG_SMITH_HOTBEAT_HEAT
local PhaseRequirementMap = CrafterGlobalCfg:FindCfgByKey(PhaseCfgID).Value  -- 热锻三个阶段的限制

local function IsHotForgeSkill(SkillID)
	return HotForgeSkillMap[SkillID] == true
end

local function GetHeatTypeByValue(Value)
	if Value == 0 then
		return EHeatType.Zero
	elseif Value < 35 then
		return EHeatType.Low
	elseif Value < 70 then
		return EHeatType.Medium
	elseif Value < 90 then
		return EHeatType.High
	else
		return EHeatType.Forge
	end
end



local CrafterArmorerBlacksmithMainPanelViewBase = LuaClass(UIView, true)

function CrafterArmorerBlacksmithMainPanelViewBase:Ctor()
end

function CrafterArmorerBlacksmithMainPanelViewBase:GetTapSubViewList()
	local EPanelType = self.EPanelType
	local PanelType = self.PanelType
	if PanelType == EPanelType.Panel4 then
		return self.TapPanel4SubViewList
	elseif PanelType == EPanelType.Panel6 then
		return self.TapPanel6SubViewList
	end
end

function CrafterArmorerBlacksmithMainPanelViewBase:OnInit()
	self.CrafterArmorerBlacksmithVM = CrafterArmorerBlacksmithVM.New()

	self.CrafterArmorerBlacksmithTapVM = {}
	for i = 1, self.MaxTapNum do
		self.CrafterArmorerBlacksmithTapVM[i] = CrafterArmorerBlacksmithTapVM.New()
	end

	self.TapPanel6SubViewList = {
		self.Tap1,
		self.Tap2,
		self.Tap3,
		self.Tap4,
		self.Tap5,
		self.Tap6
	}
	self.TapPanel4SubViewList = {
		self.Tap41,
		self.Tap42,
		self.Tap43,
		self.Tap44
	}

	-- 服务器发包时, 对应的x和y的值
	self.TapPanel6ExtraParams = {
		{ bIsHammerSkill = true, X = 0, Y = 0 },
		{ bIsHammerSkill = true, X = 0, Y = 1 },
		{ bIsHammerSkill = true, X = 0, Y = 2 },
		{ bIsHammerSkill = true, X = 1, Y = 0 },
		{ bIsHammerSkill = true, X = 1, Y = 1 },
		{ bIsHammerSkill = true, X = 1, Y = 2 },
	}

	self.TapPanel4ExtraParams = {
		{ bIsHammerSkill = true, X = 0, Y = 0 },
		{ bIsHammerSkill = true, X = 0, Y = 1 },
		{ bIsHammerSkill = true, X = 1, Y = 0 },
		{ bIsHammerSkill = true, X = 1, Y = 1 },
	}

	-- 收到服务器包时, TapPanel对应的英文下标
	self.TapPanel6IndexMap = {
		AA = 1,
		AB = 2,
		AC = 3,
		BA = 4,
		BB = 5,
		BC = 6,
	}

	self.TapPanel4IndexMap = {
		AA = 1,
		AB = 2,
		BA = 3,
		BB = 4,
	}

    local EItemType = self.EItemType
	self.ItemTypeWidgetMap = {
		[EItemType.Weapon]   = { self.ImgWeapon1, self.ImgWeapon4, self.ImgWeapon6 },
		[EItemType.Material] = { self.ImgMaterial1, self.ImgMaterial4, self.ImgMaterial6 },
		[EItemType.Prop]     = { self.ImgProp1, self.ImgProp4, self.ImgProp6 }
	}

	self.bHasSkillBuff = false

	self.TextTips:SetText(_G.LSTR(150002))
end

function CrafterArmorerBlacksmithMainPanelViewBase:OnDestroy()
end

function CrafterArmorerBlacksmithMainPanelViewBase:OnItemTypeChanged(ItemType)
	for IterItemType, WidgetList in pairs(self.ItemTypeWidgetMap) do
		local bIsVisible = IterItemType == ItemType
		for _, Widget in pairs(WidgetList) do
			UIUtil.SetIsVisible(Widget, bIsVisible, false, false)
		end
	end
end

function CrafterArmorerBlacksmithMainPanelViewBase:ChangeItemTypeByID(ItemID)
	if not ItemID then
		return
	end

	local Item = ItemCfg:FindCfgByKey(ItemID)
	if not Item then
		return
	end

	local ItemMainType = Item.ItemMainType
	local ItemType = self.ItemTypeMap[ItemMainType]
	self:OnItemTypeChanged(ItemType)
end

function CrafterArmorerBlacksmithMainPanelViewBase:OnShow()
	self.EntityID = MajorUtil.GetMajorEntityID()

	self.LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
	local LogicData = self.LogicData
	if LogicData == nil then
		return
	end

	local SkillID_Normal = LogicData:GetBtnSkillID(ButtonIndex_Normal)
	local SkillID_Skill = LogicData:GetBtnSkillID(ButtonIndex_Skill)
	-- local SkillID_HotForge = LogicData:GetBtnSkillID(ButtonIndex_HotForge)
	self.HammerBtnSkillID_Normal = SkillID_Normal
	self.HammerBtnSkillID_Skill = SkillID_Skill
	-- self.HammerBtnSkillID_HotForge = SkillID_HotForge
	self.HotForgePhase = 1

	if self.Params then
		local RecipeID = self.Params.RecipeID
		local Recipe = RecipeCfg:FindCfgByKey(RecipeID)
		if not Recipe then
			return
		end
		
		local ItemID = Recipe.ProductID

		self:ChangeItemTypeByID(ItemID)

		-- # TODO - 现在只需要4个格子, 表里面没有这个字段, 后面可能会用到
		local PanelType = Recipe.PanelType
		if not PanelType or PanelType == "" then
			PanelType = "4"
		end

        local EPanelType = self.EPanelType
		if PanelType == "4" then
			self:SetPanelType(EPanelType.Panel4)
		elseif PanelType == "6" then
			self:SetPanelType(EPanelType.Panel6)
		end
	end

	-- SubView OnShow在之后进行, 只能延迟一帧调用更新子View的遮罩
	self:RegisterTimer(self.UpdateMaskFlags, 0, nil, 1)
end

function CrafterArmorerBlacksmithMainPanelViewBase:OnHide()
	self.LogicData = nil
end

function CrafterArmorerBlacksmithMainPanelViewBase:OnRegisterUIEvent()
    local EPanelType = self.EPanelType

	local GenOnClickedFunction = function(Index, PanelType)
		local ExtraParams = PanelType == EPanelType.Panel4 and self.TapPanel4ExtraParams[Index] or self.TapPanel6ExtraParams[Index]
		return function(TapView)
			local VM = self.CrafterArmorerBlacksmithTapVM[Index]
			local SkillID
			local ButtonIndex
			if VM then
				if self.bHasSkillBuff then
					SkillID = self.HammerBtnSkillID_Skill
					ButtonIndex = ButtonIndex_Skill
				else
					SkillID = self.HammerBtnSkillID_Normal
					ButtonIndex = ButtonIndex_Normal
				end
			end
			TapView:PlayAnimation(TapView.AnimClick)
			_G.CrafterMgr:CastLifeSkill(ButtonIndex, SkillID, ExtraParams)
			_G.FLOG_INFO(
				"==== Crafter OnClickHammerBtnSkill, Idx: %d - %d. TapIndex: X = %d, Y = %d",
				ButtonIndex, SkillID, ExtraParams.X, ExtraParams.Y)
		end
	end

	for Index, Tap in ipairs(self.TapPanel6SubViewList) do
		UIUtil.AddOnClickedEvent(Tap, Tap.BtnTap, GenOnClickedFunction(Index, EPanelType.Panel6))
	end

	for Index, Tap in ipairs(self.TapPanel4SubViewList) do
		UIUtil.AddOnClickedEvent(Tap, Tap.BtnTap, GenOnClickedFunction(Index, EPanelType.Panel4))
	end
end

function CrafterArmorerBlacksmithMainPanelViewBase:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.CrafterSkillRsp, self.OnEventCrafterSkillRsp)
	self:RegisterGameEvent(EventID.CrafterSkillCostUpdate, self.OnCrafterSkillCostUpdate)
	self:RegisterGameEvent(EventID.CrafterSkillCDUpdate, self.OnCrafterSkillCDUpdate)
	self:RegisterGameEvent(EventID.MajorAddBuffLife, self.OnBuffAdd)
	self:RegisterGameEvent(EventID.MajorRemoveBuffLife, self.OnBuffRemove)
end

function CrafterArmorerBlacksmithMainPanelViewBase:OnRegisterBinder()
end

function CrafterArmorerBlacksmithMainPanelViewBase:SetPanelType(PanelType)
    local EPanelType = self.EPanelType

	local VM = self.CrafterArmorerBlacksmithVM

	self.PanelType = PanelType
	if PanelType == EPanelType.Panel4 then
		VM.bIsTapPanel4Visible = true
		VM.bIsTapPanel6Visible = false
	elseif PanelType == EPanelType.Panel6 then
		VM.bIsTapPanel4Visible = false
		VM.bIsTapPanel6Visible = true
	end

	for _, TapVM in pairs(self.CrafterArmorerBlacksmithTapVM) do
		TapVM:ResetParams()
	end
end

function CrafterArmorerBlacksmithMainPanelViewBase:SetTapParams(Index, Efficiency, HeatType)
	local TapVM = self.CrafterArmorerBlacksmithTapVM[Index]
	if TapVM then
		TapVM.Efficiency = Efficiency
		TapVM.HeatType = HeatType
	end
end

function CrafterArmorerBlacksmithMainPanelViewBase:GetTapPanelIndexMap()
	local EPanelType = self.EPanelType
	return self.PanelType == EPanelType.Panel6 and self.TapPanel6IndexMap or self.TapPanel4IndexMap
end

function CrafterArmorerBlacksmithMainPanelViewBase:OnEventCrafterSkillRsp(MsgBody)
	if MsgBody and MsgBody.CrafterSkill then
		local CrafterSkill = MsgBody.CrafterSkill
        local MajorEntityID = MajorUtil.GetMajorEntityID()
		if MajorEntityID == MsgBody.ObjID then

			local TapPanelIndexMap = self:GetTapPanelIndexMap()
			local VMList = self.CrafterArmorerBlacksmithTapVM
			local Features = CrafterSkill.Features
			local FeatureType = ProtoCS.FeatureType

			for IndexSuffix, Index in pairs(TapPanelIndexMap) do
				local VM = VMList[Index]
				local EfficiencyFeatureIndex = FeatureType["FEATURE_TYPE_HEAT_" .. IndexSuffix]

				if EfficiencyFeatureIndex then
					local Efficiency = Features[EfficiencyFeatureIndex] or VM.Efficiency
					VM.HeatType = GetHeatTypeByValue(Efficiency)
					VM.Efficiency = Efficiency
				end
			end
        end

		if CrafterSkill.Success == true and IsHotForgeSkill(MsgBody.LifeSkillID) then
			self.HotForgePhase = self.HotForgePhase + 1
		end

		-- 更新遮罩
		self:UpdateMaskFlags()
    end
end

function CrafterArmorerBlacksmithMainPanelViewBase:CanCastHotForge(bShowTips)
	if self.HotForgePhase >= 4 then
		if bShowTips then
			MsgTipsUtil.ShowTipsByID(MsgTipsID.BlacksmithHotForgeEnd)
		end
		return false, SkillCheckErrorCode.BlacksmithHotForgeEnd
	end

	local TapPanelIndexMap = self:GetTapPanelIndexMap()
	local VMList = self.CrafterArmorerBlacksmithTapVM
	local DesiredValue = PhaseRequirementMap[self.HotForgePhase]
	for _, Index in pairs(TapPanelIndexMap) do
		local VM = VMList[Index]
		if VM.Efficiency < DesiredValue then
			if bShowTips then
				MsgTipsUtil.ShowTipsByID(MsgTipsID.BlacksmithHotForgePhase, nil, DesiredValue, string.NumberToRoman(self.HotForgePhase))
			end
			return false, SkillCheckErrorCode.BlacksmithHotForgePhase
		end
	end

	return true, nil
end

function CrafterArmorerBlacksmithMainPanelViewBase:CustomCheckSkillValid(_, SkillID)
	if IsHotForgeSkill(SkillID) then
		return self:CanCastHotForge(true)
	end

	return true
end

local IndexMax <const> = 3

function CrafterArmorerBlacksmithMainPanelViewBase:OnCrafterSkillCostUpdate(Params)
	for Index = 1, IndexMax do
		self["LeatherworkerSkill" .. Index]:OnCrafterSkillCostUpdate(Params)
	end
end

function CrafterArmorerBlacksmithMainPanelViewBase:OnCrafterSkillCDUpdate(Params)
	for Index = 1, IndexMax do
		self["LeatherworkerSkill" .. Index]:OnCrafterSkillCDUpdate(Params)
	end
end

local CrafterMgr = _G.CrafterMgr
function CrafterArmorerBlacksmithMainPanelViewBase:SetHasSkillBuff(bHasSkillBuff)
	self.bHasSkillBuff = bHasSkillBuff

	if bHasSkillBuff then
		self:PlayAnimation(self.AnimSkillSwitchOn)
	else
		self:PlayAnimation(self.AnimSkillSwitchOff)
	end

	local TapSubViewList = self:GetTapSubViewList()
	for _, TapView in ipairs(TapSubViewList) do
		TapView:UpdateHammerType(TapView.VM.Efficiency, bHasSkillBuff)
	end

	local Views = CrafterMgr:GetSkillViewsByIndex(ButtonIndex_SkillSwitch)
	if Views and #Views > 0 then
		Views[1].BaseBtnVM.bIsSwitchOn = bHasSkillBuff
	end
end

function CrafterArmorerBlacksmithMainPanelViewBase:OnBuffAdd(BuffInfo)
	local BuffID = BuffInfo.BuffID
	if BuffID == self.SkillBuffID then
		self:SetHasSkillBuff(true)
	end
end

function CrafterArmorerBlacksmithMainPanelViewBase:OnBuffRemove(BuffInfo)
	local BuffID = BuffInfo.BuffID
	if BuffID == self.SkillBuffID then
		self:SetHasSkillBuff(false)
	end
end

function CrafterArmorerBlacksmithMainPanelViewBase:UpdateMaskFlags()
	-- 热锻的遮罩
	do
		local bCanCastHotForge = self:CanCastHotForge(false)
		local Views = CrafterMgr:GetSkillViewsByIndex(ButtonIndex_HotForge)
		if Views and #Views > 0 then
			Views[1]:UpdateBlacksmithMaskFlag(not bCanCastHotForge)
		end
	end

	-- 冷却的遮罩
	_G.CrafterSkillCheckMgr:RefreshConditionMask()
end

-- 处理断线重连
function CrafterArmorerBlacksmithMainPanelViewBase:OnCrafterReconnectionRsp(CrafterGet)
	local BlackSmith = CrafterGet.BlackSmith
	if not BlackSmith then
		return
	end

	self:SetHasSkillBuff(_G.LifeSkillBuffMgr:IsMajorContainBuff(self.SkillBuffID))

	self.HotForgePhase = BlackSmith.HotBeatCount + 1
	self:UpdateMaskFlags()
end

CrafterArmorerBlacksmithMainPanelViewBase.IsHotForgeSkill = IsHotForgeSkill

return CrafterArmorerBlacksmithMainPanelViewBase