---
--- Author: chriswang
--- DateTime: 2024-07-02 10:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")


local GatherNoteCfg = require("TableCfg/GatherNoteCfg")
local ColorUtil = require("Utils/ColorUtil")
local GatherNoteCfg = require("TableCfg/GatherNoteCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIViewID = require("Define/UIViewID")
local MajorUtil = require("Utils/MajorUtil")
local SkillMainCfg = require("TableCfg/SkillMainCfg")

local GatheringJobPanelVM = require("Game/GatheringJob/GatheringJobPanelVM")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local CloseIcon = "PaperSprite'/Game/UI/Atlas/GatheringJob/Frames/UI_GatheringJob_Btn_Interrupt_Normal_png.UI_GatheringJob_Btn_Interrupt_Normal_png'"
local CloseIconDisable = "PaperSprite'/Game/UI/Atlas/GatheringJob/Frames/UI_GatheringJob_Btn_Interrupt_Disabled_png.UI_GatheringJob_Btn_Interrupt_Disabled_png'"

local FLOG_INFO = _G.FLOG_INFO
local MsgTipsID = require("Define/MsgTipsID")

---@class NewGatheringJobMaterialItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnIcon UFWidgetSwitcher
---@field FBtn_Item UFButton
---@field IconHQUpRate UFImage
---@field IconHammerDisbled UFImage
---@field IconHammerNormal UFImage
---@field IconNQUpRate UFImage
---@field IconStoneInterruptDisbled UFImage
---@field IconStoneInterruptNormal UFImage
---@field IconStonePickaxeDisbled UFImage
---@field IconStonePickaxeNormal UFImage
---@field Slot74px GatheringjobSlot74pxItemView
---@field TextHQ UFTextBlock
---@field TextLevel UFTextBlock
---@field TextMaterial URichTextBox
---@field TextNQ UFTextBlock
---@field AnimCraft UWidgetAnimation
---@field AnimCraftStop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewGatheringJobMaterialItemView = LuaClass(UIView, true)

function NewGatheringJobMaterialItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnIcon = nil
	--self.FBtn_Item = nil
	--self.IconHQUpRate = nil
	--self.IconHammerDisbled = nil
	--self.IconHammerNormal = nil
	--self.IconNQUpRate = nil
	--self.IconStoneInterruptDisbled = nil
	--self.IconStoneInterruptNormal = nil
	--self.IconStonePickaxeDisbled = nil
	--self.IconStonePickaxeNormal = nil
	--self.Slot74px = nil
	--self.TextHQ = nil
	--self.TextLevel = nil
	--self.TextMaterial = nil
	--self.TextNQ = nil
	--self.AnimCraft = nil
	--self.AnimCraftStop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewGatheringJobMaterialItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Slot74px)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewGatheringJobMaterialItemView:OnInit()

end

function NewGatheringJobMaterialItemView:OnDestroy()

end

function NewGatheringJobMaterialItemView:OnShow()
	local CurEntrance = _G.InteractiveMgr.CurInteractEntrance
	if not CurEntrance then
		return
	end

	local GatherType = CurEntrance.GatherType
    local IconPath = _G.GatherMgr.GatherTypeIconConfig[GatherType].Icon
    local DisableIconPath = _G.GatherMgr.GatherTypeIconConfig[GatherType].DisableIcon
	UIUtil.ImageSetBrushFromAssetPath(self.IconNormal, IconPath, true)
	UIUtil.ImageSetBrushFromAssetPath(self.IconDisbled, DisableIconPath, true)
	-- UIUtil.SetIsVisible(self.IconNormal, true, true)
	UIUtil.SetIsVisible(self.IconDisbled, false)
end

function NewGatheringJobMaterialItemView:OnHide()
	self:CancelSkillTimer()
end

function NewGatheringJobMaterialItemView:CancelSkillTimer()
	if self.SkillTimer then
		_G.TimerMgr:CancelTimer(self.SkillTimer)
		self.SkillTimer = nil
	end
end

function NewGatheringJobMaterialItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FBtn_Item, self.OnClicked)
	UIUtil.AddOnClickedEvent(self, self.Slot74px.BackpackSlot.FBtn_Item, self.OnIconClicked)
end

function NewGatheringJobMaterialItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.Major_Attr_Change, self.OnMajorAttrChange)
	self:RegisterGameEvent(_G.EventID.SkillEnd, self.OnSkillEnd)
end

function NewGatheringJobMaterialItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	local Binders = {
		--{"IsCollection", UIBinderSetIsVisible.New(self, self.ImgCollectionIcon)},
		{"bShowImgCollection", UIBinderSetIsVisible.New(self, self.Slot74px.ImgCollection)},
		{"GatherItemIconPath",	UIBinderSetBrushFromAssetPath.New(self, self.Slot74px.BackpackSlot.FImg_Icon) },
		{ "SetItemColor", UIBinderValueChangedCallback.New(self, nil, self.OnSetItemColor) },

		{"bShowIconNQUpRate", UIBinderSetIsVisible.New(self, self.IconNQUpRate)},
		{"bShowIconHQUpRate", UIBinderSetIsVisible.New(self, self.IconHQUpRate)},

		{"TextNQ", UIBinderSetText.New(self, self.TextNQ)},
		{"TextHQ", UIBinderSetText.New(self, self.TextHQ)},

		{"TextItemName", UIBinderSetText.New(self, self.TextMaterial)},
		{"TextItemLevel", UIBinderSetText.New(self, self.TextLevel)},	
		{"TextNumber", UIBinderSetText.New(self, self.Slot74px.TextNum)},
		{"bShowTextNumber", UIBinderSetIsVisible.New(self, self.Slot74px.TextNum)},
		
		{ "BeginSimpleGather", UIBinderValueChangedCallback.New(self, nil, self.OnBeginSimpleGather) },
		{ "EndSimpleGather", UIBinderValueChangedCallback.New(self, nil, self.OnEndSimpleGather) },
		{ "BreakSimpleGather", UIBinderValueChangedCallback.New(self, nil, self.OnBreakSimpleGather) },
		{ "bSkillRsp", UIBinderValueChangedCallback.New(self, nil, self.OnSkillRsp) },

	}

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, Binders)
end

function NewGatheringJobMaterialItemView:OnSetItemColor(ItemColor)
	if ItemColor then
		local LinearColor = ColorUtil.GetLinearColor(ItemColor)
		ColorUtil.SetQualityByLinearColor(LinearColor, self.TextMaterial)
		ColorUtil.SetQualityByLinearColor(LinearColor, self.Slot74px.BackpackSlot.FImg_Quality)
	end
end

function NewGatheringJobMaterialItemView:OnMajorAttrChange(Params)
	if _G.UIViewMgr:IsViewVisible(UIViewID.EquipmentMainPanel)
		or _G.UIViewMgr:IsViewVisible(UIViewID.BagMain) then
		_G.InteractiveMgr:ShowEntrances()
		_G.InteractiveMgr:ExitInteractive()
		_G.GatherMgr:SendExitGatherState()
	end
end

function NewGatheringJobMaterialItemView:OnEndSimpleGather(bEnd)
	if bEnd and self.IsSimpleGathering then
		self:CancelSkillTimer()
		-- self:PlayAnimation(self.AnimCraftStop)
		-- FLOG_INFO("Gather AnimCraftStop OnEndSimpleGather---------- %s", self:GetName())
		self.IsGathering = false
		self.IsSimpleGathering = false
		-- FLOG_INFO("gather NewGatheringJobMaterialItemView:OnEndSimpleGather ")
	end
end

function NewGatheringJobMaterialItemView:OnBreakSimpleGather(IsBreak)
	if IsBreak and self.IsSimpleGathering then
		-- FLOG_INFO("gather NewGatheringJobMaterialItemView:OnBreakSimpleGather ")
		-- FLOG_INFO("Gather AnimCraftStop OnBreakSimpleGather---------- %s", self:GetName())
		self:PlayAnimation(self.AnimCraftStop)
		self:CancelSkillTimer()

		if self.bSkillEnd then
			-- FLOG_INFO("gather OnBreakSimpleGather immediatly")
			GatheringJobPanelVM:ExitSimpleGatherPanel()
			self.IsSimpleGathering = false
			self.ViewModel.BreakSimpleGather = false
		end
	else
	end
end

function NewGatheringJobMaterialItemView:OnBeginSimpleGather(bBegin)
	if bBegin then
		local FunctionItem = self.ViewModel.FunctionItem
		-- FLOG_INFO("Gather Begin SimpleGatherItem %s", self:GetName())
		
		if _G.GatherMgr:SimpleGatherItem(FunctionItem) == 1 then	--简易采集
			_G.CollectionMgr:SetGatherItem(FunctionItem) 
			_G.GatherMgr:SetGatherItemID(FunctionItem.ResID)
			self:PlayAnimation(self.AnimCraft)
			-- FLOG_INFO("Gather OnBeginSimpleGather ---------- %s", self:GetName())
			FLOG_INFO("Gather OnBeginSimpleGather")
			self.IsGathering = false
			self.IsSimpleGathering = true
			self.ViewModel.BreakSimpleGather = false

			self.BtnIcon:SetActiveWidgetIndex(1)
			
			self:CancelSkillTimer()

			if not self.SkillTimer then
				local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
				if LogicData then
					local SkillID = LogicData:GetBtnSkillID(0)
					if SkillID and SkillID > 0 then
						self.SkillCD = SkillMainCfg:FindValue(SkillID, "CD") / 1000 + 0.2
					end
				end
				
				--加计时器
				-- self.SkillTimer = _G.TimerMgr:AddTimer(self, self.TimerSimpleGather, self.SkillCD, self.SkillCD, 0)
			end
		end
	end
end

function NewGatheringJobMaterialItemView:OnSkillRsp(bOnSkillRsp)
	if bOnSkillRsp then
		self:CancelSkillTimer()
		if self.ViewModel.IsTreasure then
			FLOG_INFO("Gather IsTreasure BreakSimpleGather")
			GatheringJobPanelVM:BreakSimpleGather()
			return
		end

		local CurDuration = _G.GatherMgr:GetCurActiveGatherDuration()
		FLOG_INFO("Gather OnSkillRsp CurDuration:%d", CurDuration)
		if CurDuration >= 1 then
			self.SkillTimer = _G.TimerMgr:AddTimer(self, self.TimerSimpleGather, self.SkillCD, self.SkillCD, 0)
		end
	end
end

--只管简易采集的，采取计时器的做法
function NewGatheringJobMaterialItemView:TimerSimpleGather()
	self:CancelSkillTimer()

	if self.ViewModel.IsTreasure then
		GatheringJobPanelVM:BreakSimpleGather()
		return
	end
	
    local LeftBagNum = _G.BagMgr:GetBagLeftNum()
    if LeftBagNum <= 0 then
		_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.WildBoxBagFull) --"背包已满"
		GatheringJobPanelVM:BreakSimpleGather()
		return
	end

	local FunctionItem = self.ViewModel.FunctionItem
	-- FLOG_INFO("		Gather SimpleGatherItem ClickTime:%s", self:GetName())	
	if _G.GatherMgr:SimpleGatherItem(FunctionItem) == 1 then	--简易采集
		_G.CollectionMgr:SetGatherItem(FunctionItem)
		_G.GatherMgr:SetGatherItemID(FunctionItem.ResID)
		self.bSkillEnd = false
		self:PlayAnimation(self.AnimCraftStop)

		self:PlayAnimation(self.AnimCraft)
		-- FLOG_INFO("Gather TimerSimpleGather ---------- %s", self:GetName())
		self.IsGathering = false
		self.IsSimpleGathering = true
		
		-- local CurDuration = _G.GatherMgr:GetCurActiveGatherDuration()
		-- if CurDuration > 1 then
		-- 	self.SkillTimer = _G.TimerMgr:AddTimer(self, self.TimerSimpleGather, self.SkillCD, self.SkillCD, 0)
		-- end
	end
end

function NewGatheringJobMaterialItemView:OnIconClicked()
	local FunctionItem = self.ViewModel.FunctionItem
	local ItemResID = FunctionItem.ResID
	ItemTipsUtil.ShowTipsByResID(ItemResID, self.Slot74px)
end

function NewGatheringJobMaterialItemView:OnClicked()
    if _G.GatherMgr:GetIsSimpleGather() and not GatheringJobPanelVM.SimpleGatherItemVM.EndSimpleGather then
		FLOG_WARNING("Gather click EndSimpleGather")
        -- _G.MsgTipsUtil.ShowTips(LSTR("正在停止采集，请稍等片刻。"))
        GatheringJobPanelVM:BreakSimpleGather()
		
		return
	end

    local LeftBagNum = _G.BagMgr:GetBagLeftNum()
    if LeftBagNum <= 0 then
		_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.WildBoxBagFull) --"背包已满"
		return
	end

	--所有技能释放的过程中，都认为是cd
	if _G.GatherMgr.IsMajorSkilling then
		_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.LifeSkillCDing)
		return
	end

	local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
	if LogicData then
		local SkillID = LogicData:GetBtnSkillID(0)
		if not _G.SkillLogicMgr:CheckLifeSkillCD(SkillID) then
			_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.LifeSkillCDing)
			return
		end
	end
	
	if not self.ViewModel then
		return
	end
	
	local FunctionItem = self.ViewModel.FunctionItem
	-- FLOG_INFO("Gather GatherItem Click %s", self:GetName())
	_G.CollectionMgr:SetGatherItem(FunctionItem)

	local GatherType, CanSkillRlt = _G.GatherMgr:OnGatherItemClick(FunctionItem)
	if GatherType and GatherType == 1 then	--正常采集，非简易采集
		if CanSkillRlt and CanSkillRlt >= 0 then
			_G.GatherMgr:SetGatherItemID(FunctionItem.ResID)
			self:PlayAnimation(self.AnimCraft)
			self.IsGathering = true
			UIUtil.SetIsVisible(self.IconDisbled, true)
			-- FLOG_INFO("Gather AnimCraft---------- %s", self:GetName())
		end
	elseif GatherType and GatherType == 3 then --简易采集ing
		--等本次采集结束，再中断简易采集
		GatheringJobPanelVM:BreakSimpleGather()
	end

end

--只管普通采集的
function NewGatheringJobMaterialItemView:OnSkillEnd(Params)
	if not self.ViewModel then
		return 
	end

	local EntityID = Params.ULongParam1
	local FunctionItem = self.ViewModel.FunctionItem
    local MajorEntityID = MajorUtil.GetMajorEntityID()
	self.bSkillEnd = true

	-- FLOG_INFO("Gather ItemView:OnSkillEnd %s  IsSimpleGathering:%s BreakSimpleGather:%s", self:GetName()
	-- 	, tostring(self.IsSimpleGathering), tostring(self.ViewModel.BreakSimpleGather))
	if self.IsSimpleGathering and self.ViewModel.BreakSimpleGather then
		GatheringJobPanelVM:ExitSimpleGatherPanel()
		self.IsSimpleGathering = false
		self.ViewModel.BreakSimpleGather = false
		--todo
		UIUtil.SetIsVisible(self.IconDisbled, false)
		return 
	end
	
	UIUtil.SetIsVisible(self.IconDisbled, false)
	if not self.IsGathering then
		-- FLOG_INFO("gather NewGatheringJobMaterialItemView: not self.IsGathering ")
		return
	end

	if MajorEntityID == EntityID and FunctionItem 
		and FunctionItem.ResID == _G.GatherMgr:GetGatherItemID() then
		self.IsGathering = false
		-- FLOG_INFO("Gather AnimCraftStop OnSkillEnd---------- %s", self:GetName())
		self:PlayAnimation(self.AnimCraftStop)

		if _G.GatherMgr.IsSimpleGather then
		else
			GatheringJobPanelVM:SetCheckState(false)
			GatheringJobPanelVM:EndSimpleGather()
		end
	end
end

return NewGatheringJobMaterialItemView