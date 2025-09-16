---
--- Author: chunfengluo
--- DateTime: 2025-01-21 17:09
--- Description:
---

local LuaClass = require("Core/LuaClass")
local MainSkillBaseView = require("Game/MainSkillBtn/MainSkillBaseView")
local ProSkillSpectrumBase = require("Game/Main/ProSkill/ProSkillSpectrumBase")
local ProfProSkillViewBase = require("Game/Main/ProSkill/ProfProSkillViewBase")
local ProSkillDefine = require("Game/Main/ProSkill/ProSkillDefine")
local UIUtil = require("Utils/UIUtil")
local SkillUtil = require("Utils/SkillUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local ProtoRes = require("Protocol/ProtoRes")
local SkillBtnState = require("Game/Skill/SkillButtonStateMgr").SkillBtnState

local CostTypeSpectrum <const> = ProtoRes.skill_cost_type.SKILL_COST_TYPE_SPECTRUM
local SpectrumIDMap <const>    = ProSkillDefine.SpectrumIDMap
local EMapType <const>         = SkillUtil.MapType
local SkillLogicMgr <const>    = SkillLogicMgr
local MainProSkillMgr <const>  = MainProSkillMgr
local AdapterProSkill <const>  = ProfProSkillViewBase


---@class SkillSpectrum_PVP : ProSkillSpectrumBase
---@field Super ProSkillSpectrumBase
local SkillSpectrum_PVP = LuaClass(ProSkillSpectrumBase, true)



---@class SkillPVPBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot CommonRedDotView
---@field EFF_ADD_Inst_25 UFImage
---@field EFF_Circle_012 UFImage
---@field FCanvasPanel_59 UFCanvasPanel
---@field FImg_CDNormal UFImage
---@field IconSkillReplace UFImage
---@field IconSkillReplaceBtn UFButton
---@field Icon_Skill UFImage
---@field ImgLock UFImage
---@field ImgLockLevel UFTextBlock
---@field ImgPVPBase UFImage
---@field ImgPVPCD URadialImage
---@field ImgPVPFull UFImage
---@field ImgPVPLimit UFImage
---@field Img_CD URadialImage
---@field MultiChoiceSlot UFCanvasPanel
---@field PVPCD UFCanvasPanel
---@field QueueSkill UFCanvasPanel
---@field SecondJoyStick SecondJoyStickView
---@field TextQuantity UFTextBlock
---@field Text_SkillCD UFTextBlock
---@field AnimAlternate UWidgetAnimation
---@field AnimCDFinish UWidgetAnimation
---@field AnimChange UWidgetAnimation
---@field AnimChangeIn UWidgetAnimation
---@field AnimChangeOut UWidgetAnimation
---@field AnimClick UWidgetAnimation
---@field AnimSelectedIn UWidgetAnimation
---@field AnimSelectedOut UWidgetAnimation
---@field AnimSkillCharge UWidgetAnimation
---@field AnimSkillChargeLoop UWidgetAnimation
---@field AnimSkillChargeStop UWidgetAnimation
---@field AnimSkillChargeStopRelease UWidgetAnimation
---@field AnimSkillChoiceIn UWidgetAnimation
---@field AnimSkillChoiceOut UWidgetAnimation
---@field AnimSkillLimitLoop UWidgetAnimation
---@field AnimSkillLimitStop UWidgetAnimation
---@field AnimSkillUnlock UWidgetAnimation
---@field AnimSkillUnlockMulti UWidgetAnimation
---@field ButtonIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillPVPBtnView = LuaClass(MainSkillBaseView, true)

function SkillPVPBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot = nil
	--self.EFF_ADD_Inst_25 = nil
	--self.EFF_Circle_012 = nil
	--self.FCanvasPanel_59 = nil
	--self.FImg_CDNormal = nil
	--self.IconSkillReplace = nil
	--self.IconSkillReplaceBtn = nil
	--self.Icon_Skill = nil
	--self.ImgLock = nil
	--self.ImgLockLevel = nil
	--self.ImgPVPBase = nil
	--self.ImgPVPCD = nil
	--self.ImgPVPFull = nil
	--self.ImgPVPLimit = nil
	--self.Img_CD = nil
	--self.MultiChoiceSlot = nil
	--self.PVPCD = nil
	--self.QueueSkill = nil
	--self.SecondJoyStick = nil
	--self.TextQuantity = nil
	--self.Text_SkillCD = nil
	--self.AnimAlternate = nil
	--self.AnimCDFinish = nil
	--self.AnimChange = nil
	--self.AnimChangeIn = nil
	--self.AnimChangeOut = nil
	--self.AnimClick = nil
	--self.AnimSelectedIn = nil
	--self.AnimSelectedOut = nil
	--self.AnimSkillCharge = nil
	--self.AnimSkillChargeLoop = nil
	--self.AnimSkillChargeStop = nil
	--self.AnimSkillChargeStopRelease = nil
	--self.AnimSkillChoiceIn = nil
	--self.AnimSkillChoiceOut = nil
	--self.AnimSkillLimitLoop = nil
	--self.AnimSkillLimitStop = nil
	--self.AnimSkillUnlock = nil
	--self.AnimSkillUnlockMulti = nil
	--self.ButtonIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.bAbleBtn = true  -- PVP这按钮, 虽然是单独的蓝图, 但是逻辑上完全可以视为一个Able按钮, 方便管理
end

function SkillPVPBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot)
	self:AddSubView(self.SecondJoyStick)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillPVPBtnView:OnInit()
	self.Super:OnInit()
	AdapterProSkill.OnInit(self)
	self:BindSpectrumBehavior(SpectrumIDMap.PVP_2k, SkillSpectrum_PVP)
	self:BindSpectrumBehavior(SpectrumIDMap.PVP_3k, SkillSpectrum_PVP)
	self:BindSpectrumBehavior(SpectrumIDMap.PVP_4k, SkillSpectrum_PVP)
	self.Binders = {
		{ "SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.Icon_Skill) },
		{ "bCommonMask", UIBinderSetIsVisible.New(self, self.FImg_CDNormal) },
		{ "bLBReady", UIBinderValueChangedCallback.New(self, nil, self.OnLBReadyStateChanged) },
		{ "bIsSpectrumSkill", UIBinderValueChangedCallback.New(self, nil, self.OnIsSpectrumSkillChanged) },
	}
	self.bSelected = false
	self.OriginalButtonIndex = self.ButtonIndex
	self.SimulateReplaceTimer = 0
end

function SkillPVPBtnView:OnDestroy()
	AdapterProSkill.OnDestroy(self)
end

function SkillPVPBtnView:OnShow()
	self.Super:OnShow()

	if self:IsEnable() then
		self:RefreshAdapterProSkill()
	end
end

function SkillPVPBtnView:OnHide()
	self.Super:OnHide()
	AdapterProSkill.OnHide(self)
end

function SkillPVPBtnView:OnRegisterUIEvent()
	if not self.bMajor then
		UIUtil.AddOnClickedEvent(self, self.IconSkillReplaceBtn, self.IconSkillReplaceClicked)
	end
end

function SkillPVPBtnView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
	if self.bMajor then
		AdapterProSkill.OnRegisterGameEvent(self)
		-- self:RegisterGameEvent(EventID.SkillSpectrumUpdate, self.OnSpectrumUpdate)
		-- self:RegisterGameEvent(EventID.SkillSpectrumValueUpdate, self.OnSpectrumMaxValueUpdate)
	else
		local EventID = EventID
		self:RegisterGameEvent(EventID.PlayerPrepareCastSkill, self.OnPlayerPrepareCastSkill)
		self:RegisterGameEvent(EventID.SkillSystemClickBlank, self.OnSkillSystemClickBlank)
	end
end

function SkillPVPBtnView:OnRegisterBinder()
	local VM = self.BaseBtnVM
	VM.bLBReady = nil
	VM.bIsSpectrumSkill = nil
	self:RegisterBinders(self.BaseBtnVM, self.Binders)
end

function SkillPVPBtnView:OnLongClick()
	self.SkillTipsHandle = _G.SkillTipsMgr:ShowMajorCombatSkillTips(self.BtnSkillID, self)
end

function SkillPVPBtnView:OnLongClickReleased()
	if self.SkillTipsHandle then
		_G.SkillTipsMgr:HideTipsByHandleID(self.SkillTipsHandle)
		self.SkillTipsHandle = nil
	end
end

local function IsSpectrumSkill(SkillID)
	local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
	if not Cfg then
		return false
	end
	for _, CostInfo in pairs(Cfg.CostList) do
		if CostInfo.AssetType == CostTypeSpectrum then
            return true
        end
	end
	return false
end

function SkillPVPBtnView:RefreshAdapterProSkill()
	AdapterProSkill.OnHide(self)
	local CurrentSpectrumIDs = MainProSkillMgr.CurrentSpectrumIDs
	self.Params = CurrentSpectrumIDs
	AdapterProSkill.OnShow(self)
end

function SkillPVPBtnView:OnSkillReplace(Params)
	self.Super:OnSkillReplace(Params)
	if self.bMajor then
		self:RefreshAdapterProSkill()
		self:ResetLB()
	end
	self.BaseBtnVM.bIsSpectrumSkill = IsSpectrumSkill(Params.SkillID)
end

function SkillPVPBtnView:IsEnable()
	if not self.bMajor then
		-- 技能系统中直接就绪
		self:OnLBReadyStateChanged(true)
		return false
	end

	local LogicData = SkillLogicMgr:GetSkillLogicData(self.EntityID)
	local MapType = LogicData.MapType
	if MapType ~= EMapType.PVP then
		return false
	end

	return true
end

function SkillPVPBtnView:ResetLB()
	local VM = self.BaseBtnVM
	VM.bLBReady = nil
	VM.bIsSpectrumSkill = nil
	self:UpdateLB(0, 0)
	self.ImgPVPCD:SetPercent(0)
end

function SkillPVPBtnView:UpdateLB(CurValue, MaxValue)
	CurValue, MaxValue = CurValue or 0, MaxValue or 0
	local Percent = 0
	if MaxValue > 0 then
		Percent = CurValue / MaxValue
	end

	self.Text_SkillCD:SetText(string.format("%.0f%%", Percent * 100))

	local bLBReady = Percent >= 1
	self.BaseBtnVM.bLBReady = bLBReady
end

function SkillPVPBtnView:OnLBReadyStateChanged(bLBReady)
	self:UpdateLBButtonState()

	-- # TODO - 临时处理, 显隐后面由动效控制
	UIUtil.SetIsVisible(self.ImgPVPBase, not bLBReady)
	UIUtil.SetIsVisible(self.ImgPVPCD, not bLBReady)
	UIUtil.SetIsVisible(self.ImgPVPFull, bLBReady)
end

function SkillPVPBtnView:OnIsSpectrumSkillChanged(bIsSpectrumSkill)
	self:UpdateLBButtonState()
	UIUtil.SetIsVisible(self.PVPCD, bIsSpectrumSkill)
end

-- 更新LB按钮遮罩和CD百分比的可见性
function SkillPVPBtnView:UpdateLBButtonState()
	if not self.bMajor then
		UIUtil.SetIsVisible(self.Text_SkillCD, false)
		return
	end

	local VM = self.BaseBtnVM
	local bLBReady = VM.bLBReady
	local bIsSpectrumSkill = VM.bIsSpectrumSkill
	local LogicData = SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if LogicData ~= nil then
		LogicData:SetSkillButtonState(self.ButtonIndex, SkillBtnState.PVPLB, bLBReady or not bIsSpectrumSkill)
		self:OnSkillStatusUpdate()
	end
	UIUtil.SetIsVisible(self.Text_SkillCD, not bLBReady and bIsSpectrumSkill)
end

function SkillPVPBtnView:DoCustomIndexReplace()
end



--region 技能系统 复用触发技、普通技的函数

local SkillTriggerBtnView = require("Game/MainSkillBtn/SkillTriggerBtnView")
local SkillAbleBtnView = require("Game/MainSkillBtn/SkillAbleBtnView")

SkillPVPBtnView.OnSkillSystemClickBlank = SkillTriggerBtnView.OnSkillSystemClickBlank
SkillPVPBtnView.OnGameEventMajorUseSkill = SkillTriggerBtnView.OnGameEventMajorUseSkill
SkillPVPBtnView.PlayerUnselectButton = SkillTriggerBtnView.PlayerUnselectButton
SkillPVPBtnView.DoSimulateReplace = SkillAbleBtnView.DoSimulateReplace
SkillPVPBtnView.PlayerClearSimulateReplace = SkillAbleBtnView.PlayerClearSimulateReplace
SkillPVPBtnView.IconSkillReplaceClicked = SkillAbleBtnView.IconSkillReplaceClicked
SkillPVPBtnView.OnAnimChangeAnimationFinished = SkillAbleBtnView.OnAnimChangeAnimationFinished

function SkillPVPBtnView:PlayerClearButtonState()
	self:PlayerClearSimulateReplace()
	self:PlayerUnselectButton()
end

function SkillPVPBtnView:OnPlayerPrepareCastSkill(Params)
	if Params.Index ~= self.ButtonIndex and self.EntityID == Params.EntityID then
		self:PlayerClearButtonState()
	end
end

function SkillPVPBtnView:OnPlayerUseSkill(Params)
	if not self.bDisplaySimulateReplace then
		self.Super.OnPlayerUseSkill(self, Params)
	end
	self:PlayAnimation(self.AnimSelectedIn)
	self.bSelected = true
end

function SkillPVPBtnView:bSupportSimulateReplace()
	if not self.bMajor and #_G.SkillLogicMgr:GetPlayerSeriesList(self.EntityID, self.ButtonIndex) > 0 then
		return true
	end
	return false
end

--endregion



local AdapterVirtualTable = getmetatable(AdapterProSkill).__newindex
if AdapterVirtualTable then
	for FuncName, Func in pairs(AdapterVirtualTable) do
		if type(Func) == "function" and not SkillPVPBtnView[FuncName] then
			SkillPVPBtnView[FuncName] = Func
		end
	end 
end



--region 量谱相关函数

function SkillSpectrum_PVP:OnInit()
	self.Super:OnInit()
end

function SkillSpectrum_PVP:ValueUpdateFunc(CurValue, TargetValue)
	self.View:UpdateLB(TargetValue, self.SpectrumMaxValue)
end

function SkillSpectrum_PVP:ValueUpdateEachFunc(CurValue)
	local MaxValue = self.SpectrumMaxValue
	if MaxValue and MaxValue > 0 then
		self.View.ImgPVPCD:SetPercent(CurValue / self.SpectrumMaxValue)
	end
end

--endregion

return SkillPVPBtnView