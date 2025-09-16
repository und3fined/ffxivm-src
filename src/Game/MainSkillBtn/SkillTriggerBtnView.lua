---
--- Author: chaooren
--- DateTime: 2022-03-04 16:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MainSkillBaseView = require("Game/MainSkillBtn/MainSkillBaseView")
local ProtoRes = require ("Protocol/ProtoRes")
local SkillUtil = require("Utils/SkillUtil")
local TimeUtil = require("Utils/TimeUtil")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local BuffCfg = require("TableCfg/BuffCfg")
local SkillSystemReplaceCfg = require("TableCfg/SkillSystemReplaceCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local SkillBtnState = require("Game/Skill/SkillButtonStateMgr").SkillBtnState

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local QteSkilldisplayCfg = require("TableCfg/QteSkilldisplayCfg")

local TriggerCDTickTime = 100 --ms

---@class SkillTriggerBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot CommonRedDotView
---@field EFF_Circle_012 UFImage
---@field EFF_Circle_015 UFImage
---@field EnergyCD UFCanvasPanel
---@field EnergyCDMask URadialImage
---@field FHorizontalTime UFHorizontalBox
---@field FImg_CDNormal UFImage
---@field FImg_Slot UFImage
---@field Icon_Trigger UFImage
---@field ImgTime UFImage
---@field Img_Add UFImage
---@field Img_CD URadialImage
---@field PanelConsume UFCanvasPanel
---@field PanelTime UFCanvasPanel
---@field SizeBox USizeBox
---@field TagTimes UFCanvasPanel
---@field TextNum UFTextBlock
---@field TextTime UFTextBlock
---@field Text_SkillCD UFTextBlock
---@field Text_TriggerTimes UFTextBlock
---@field TriggerCD UFCanvasPanel
---@field Trigger_CDMask URadialImage
---@field AnimCDFinish UWidgetAnimation
---@field AnimClick UWidgetAnimation
---@field AnimSelectedIn UWidgetAnimation
---@field AnimSelectedOut UWidgetAnimation
---@field AnimSkillTriggerLoop UWidgetAnimation
---@field ButtonIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillTriggerBtnView = LuaClass(MainSkillBaseView, true)

function SkillTriggerBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot = nil
	--self.EFF_Circle_012 = nil
	--self.EFF_Circle_015 = nil
	--self.EnergyCD = nil
	--self.EnergyCDMask = nil
	--self.FHorizontalTime = nil
	--self.FImg_CDNormal = nil
	--self.FImg_Slot = nil
	--self.Icon_Trigger = nil
	--self.ImgTime = nil
	--self.Img_Add = nil
	--self.Img_CD = nil
	--self.PanelConsume = nil
	--self.PanelTime = nil
	--self.SizeBox = nil
	--self.TagTimes = nil
	--self.TextNum = nil
	--self.TextTime = nil
	--self.Text_SkillCD = nil
	--self.Text_TriggerTimes = nil
	--self.TriggerCD = nil
	--self.Trigger_CDMask = nil
	--self.AnimCDFinish = nil
	--self.AnimClick = nil
	--self.AnimSelectedIn = nil
	--self.AnimSelectedOut = nil
	--self.AnimSkillTriggerLoop = nil
	--self.ButtonIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillTriggerBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillTriggerBtnView:OnInit()
	self.Super:OnInit()
	self.bTriggerBtn = true

	self.bSelected = false
	self.ExpireTimerID = 0
	self.QTECDTimerID = 0
	self.SmimulateSkillTimerID = 0
	self.QTECDCnt = 0

	self.Binders = {
		{"SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.Icon_Trigger)},
		--{"bSkillIcon", UIBinderSetIsVisible.New(self, self.Icon_Trigger)},
		{"bCommonMask", UIBinderSetIsVisible.New(self, self.FImg_CDNormal)},
		{"NormalCDPercent", UIBinderSetPercent.New(self, self.Img_CD) },
		{"bNormalCD", UIBinderSetIsVisible.New(self, self.Img_CD)},
		{"SkillCDText", UIBinderSetText.New(self, self.Text_SkillCD)},
		{"SkillCostColor", UIBinderSetColorAndOpacityHex.New(self, self.TextNum) },
		{"bSkillCost", UIBinderSetIsVisible.New(self, self.PanelConsume)},
		{"SkillCostText", UIBinderSetText.New(self, self.TextNum) },
		{"bCanUseQTE", UIBinderSetIsVisible.New(self, self.PanelTime,true) },
		{"bCanUseQTE", UIBinderSetIsVisible.New(self, self.EnergyCD,true) },
		{"QTECDTime", UIBinderSetText.New(self, self.TextTime) },
	}
	rawset(self, "BLMQTESkillID", 0)
	self.BLMQTEBuffID = 0
	local Cfg = QteSkilldisplayCfg:FindCfgByProfID(ProtoCommon.prof_type.PROF_TYPE_BLACKMAGE)
	if Cfg then
		rawset(self, "BLMQTESkillID", Cfg.SkillID)
		self.BLMQTEBuffID = Cfg.BuffID
	end
	self.BLMQTECD = 10

	local BuffInfo = BuffCfg:FindCfgByKey(self.BLMQTEBuffID)
	if BuffInfo then
		self.BLMQTECD = BuffInfo.LiveTime / 1000
	end
end


function SkillTriggerBtnView:OnShow()
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if LogicData == nil then
		FLOG_WARNING("[SkillTriggerBtnView] LogicData is nil, EntityID: " .. tostring(self.EntityID or 0))
		return
	end	
	if not self.bMajor then
		local SkillID = LogicData:GetBtnSkillID(self.ButtonIndex)
		if SkillID > 0 then
			self.BtnSkillID = 0
			-- 技能系统专用替换
			local Cfg = SkillSystemReplaceCfg:FindCfgByKey(SkillID)
			if Cfg then
				SkillID = Cfg.ReplaceSkillID
			end
			self.Super:OnSkillReplace({SkillIndex = self.ButtonIndex, SkillID = SkillID})
			_G.SkillSystemMgr:RegisterSkillButtonRedDotWidget(self.ButtonIndex, self.BtnSkillID, self.CommonRedDot)
		else
			UIUtil.SetIsVisible(self, false)
		end

		return
	end

	local TriggerData = _G.MajorTriggerSkillMgr:GetTriggerDataByIndex(self.ButtonIndex)
	self.BtnSkillID = 0
	self:UpdateTriggerData(TriggerData)
end

function SkillTriggerBtnView:OnHide()
	self.Super:OnHide()
	self:StopAnimation(self.AnimSkillTriggerLoop)
end

function SkillTriggerBtnView:OnDestroy()
	rawset(self, "bBinderRegistered", false)
	self.Super:UnRegisterAllBinder()
end

function SkillTriggerBtnView:OnRegisterUIEvent()

end

function SkillTriggerBtnView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()

	if not self.bMajor then
		self:RegisterGameEvent(EventID.PlayerPrepareCastSkill, self.OnPlayerPrepareCastSkill)
		-- self:RegisterGameEvent(EventID.SkillSystemReplaceChange, self.OnSkillSystemReplaceChange)
		self:RegisterGameEvent(EventID.SkillSystemClickBlank, self.OnSkillSystemClickBlank)
	else
		self:RegisterGameEvent(EventID.SkillAssetAttrUpdate, self.OnSkillAssetAttrUpdate)
		self:RegisterGameEvent(EventID.MajorUpdateBuffTime, self.OnUpdateBuffTime)
	end
end

function SkillTriggerBtnView:OnRegisterBinder()
	if rawget(self, "bBinderRegistered") then
		return
	end
	rawset(self, "bBinderRegistered", true)
	self.BaseBtnVM.bCanUseQTE = true
	self.BaseBtnVM.QTECDTime = 0
	self:RegisterBinders(self.BaseBtnVM, self.Binders)
end

--chaooren 重写取消注册binder函数，这是一种危险的写法，请勿模仿
function SkillTriggerBtnView:UnRegisterAllBinder()

end

function SkillTriggerBtnView:UpdateTriggerData(TriggerData)
	local _ <close> = CommonUtil.MakeProfileTag("SkillTriggerBtnView:UpdateTriggerData")
	if self.ExpireTimerID > 0 then
		self:UnRegisterTimer(self.ExpireTimerID)
		self.ExpireTimerID = 0
	end
	if self.QTECDTimerID > 0 then
		self:UnRegisterTimer(self.QTECDTimerID)
		self.QTECDTimerID = 0
	end
	local SkillID = TriggerData.SkillID

	if SkillID == nil then
		return
	end

	local Index = self.ButtonIndex
	local MajorSkillLogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
	if MajorSkillLogicData then
		local MgrSkillID = MajorSkillLogicData:GetBtnSkillID(Index)
		if MgrSkillID ~= SkillID then
			print("[SkillTriggerBtnView] trigger id %d not equal mgr id %d", SkillID, MgrSkillID or 0)
		end
	else
		return
	end

	self.BaseBtnVM:SetSkillID(SkillID)

	local ExpireTime = TriggerData.ExpireTime
	local FullTime = TriggerData.FullTime
	local BtnSkillID = self.BtnSkillID
	if SkillID ~= BtnSkillID then
		BtnSkillID = SkillID
		self.BtnSkillID = SkillID
		self.__Current = self.__BaseType
		self.Super:OnSkillReplace({SkillIndex = Index, SkillID = SkillID})
		self:ChangeSkillIcon(SkillID)
		self:UpdateSkillCost(SkillID)
	end

	local bTriggerCDVisible = false
	if ExpireTime > 0 then
		local LastTime = ExpireTime - TimeUtil.GetServerTimeMS()
		if LastTime > 0 then
			if FullTime > 0 then
				UIUtil.SetIsVisible(self.TriggerCD, true)
				self.Trigger_CDMask:SetPercent(1)
				self.CurExpireTime = ExpireTime
				self.ExpireTimerID = self:RegisterTimer(self.TriggerSkillCDTick, 0, TriggerCDTickTime / 1000, 0, {ExpireTime = ExpireTime, FullTime = FullTime})
				bTriggerCDVisible = true
			end
		end
	end
	if not bTriggerCDVisible then
		UIUtil.SetIsVisible(self.TriggerCD, false)
	end

    if BtnSkillID == rawget(self, "BLMQTESkillID") then
		local ShouldVisible = (TriggerData.IsTrigger and TriggerData.IsShow) or false
		self:UpdateQTECanUse(ShouldVisible)
	else
		self:PlayAnimation(self.AnimSkillTriggerLoop, 0, 0)
	end
end

function SkillTriggerBtnView:TriggerSkillCDTick(Params)

	local ExpireTime = Params.ExpireTime
	local FullTime = Params.FullTime

	local LastTime = ExpireTime - TimeUtil.GetServerTimeMS()

	local Percent = LastTime / FullTime
	if Percent > 1 then Percent = 1 end
	self.Trigger_CDMask:SetPercent(Percent)
end

function SkillTriggerBtnView:TriggerQTECDTick(Params)
	if not self.BaseBtnVM.bCanUseQTE then
		local MaxValue = self.BLMQTECD
		self.QTECDCnt = self.QTECDCnt + 1
		local DeltaTime = self.QTECDCnt * Params.deltaTime
		if DeltaTime > 1 then
			DeltaTime = 1
		end
		local CurValue = MaxValue - self.BaseBtnVM.QTECDTime + DeltaTime
		if CurValue > MaxValue then
			CurValue = MaxValue
		end
		if MaxValue and MaxValue > 0 then
			self.EnergyCDMask:SetPercent(CurValue / MaxValue)
		end
	end
end


-- function SkillTriggerBtnView:OnSkillSystemReplaceChange(Params)
-- 	local ButtonIndex = Params.ButtonIndex
-- 	local bShow = Params.bShow
-- 	if ButtonIndex == 2 then
-- 		self.BaseBtnVM.bCommonMask = bShow
-- 	end
-- end

function SkillTriggerBtnView:OnSkillSystemClickBlank()
	self:PlayerClearButtonState()
end

function SkillTriggerBtnView:OnGameEventMajorUseSkill(Params)
	self:PlayAnimation(self.AnimClick, 0, 1, nil, 1, true)
end

function SkillTriggerBtnView:PlayerUnselectButton()
	if self.bSelected then
		if self:IsAnimationPlaying(self.AnimSelectedIn) == true then
			self:StopAnimation(self.AnimSelectedIn)
		end
		self:PlayAnimation(self.AnimSelectedOut)
		self.bSelected = false
	end
end

function SkillTriggerBtnView:PlayerClearButtonState()
	if self.bDisplaySimulateReplace then
		self.bDisplaySimulateReplace = false
		_G.EventMgr:SendEvent(EventID.SkillSystemReplaceChange, { ButtonIndex = self.ButtonIndex, bShow = false, bTableView = true })
	end

	self:PlayerUnselectButton()
end

function SkillTriggerBtnView:OnPlayerPrepareCastSkill(Params)
	if Params.Index ~= self.ButtonIndex and self.EntityID == Params.EntityID then
		self:PlayerClearButtonState()
	end
	-- if Params.Index ~= 2 then
	-- 	self.BaseBtnVM.bCommonMask = false
	-- end
end

function SkillTriggerBtnView:OnPlayerUseSkill(Params)
	--self:PlayAnimation(self.AnimClick)
	if not self.bDisplaySimulateReplace then
		self.Super:OnPlayerUseSkill(Params)
	end
	self:PlayAnimation(self.AnimSelectedIn)
	self.bSelected = true
end

function SkillTriggerBtnView:bSupportSimulateReplace()
	if not self.bMajor and _G.SkillLogicMgr:CanPlayerSimulateReplaceShowTableView(self.EntityID, self.ButtonIndex) then
		return true
	end
	return false
end

function SkillTriggerBtnView:DoSimulateReplace()
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if LogicData then
		local NextSkillID = LogicData:GetPlayerSeriesNext(self.BtnSkillID, self.ButtonIndex)
		SkillUtil.ChangeSkillIcon(NextSkillID, self.IconSkillReplace)
	end
	_G.EventMgr:SendEvent(EventID.SkillSystemReplaceChange, { ButtonIndex = self.ButtonIndex, bShow = true, bTableView = true })
end

function SkillTriggerBtnView:OnSkillReplace(Params)
	--非主角将触发按钮视为普通按钮
	if  Params.SkillIndex == self.ButtonIndex then
		self.Super:OnSkillReplace(Params)
		self:UpdateCanUse()
	end
end

function SkillTriggerBtnView:OnSkillAssetAttrUpdate(Params)
	local SkillVM = self.BaseBtnVM
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if LogicData and SkillVM:CanUpdateSkillCost() then
		local State, Cost = LogicData:GetButtonState(self.ButtonIndex, Params.Key)
		SkillVM:SetSkillCost(State, Cost)
	end
end

function SkillTriggerBtnView:OnUpdateBuffTime(BuffInfoParam)
	if BuffInfoParam.BuffID == self.BLMQTEBuffID then
		self.BaseBtnVM.QTECDTime = BuffInfoParam.BuffLeftTime
		self.QTECDCnt = 0
	end
end

function SkillTriggerBtnView:UpdateQTECanUse(CanUse)
	if CanUse == nil then
		local TriggerData = _G.MajorTriggerSkillMgr:GetTriggerDataByIndex(self.ButtonIndex)
		CanUse = (TriggerData.IsTrigger and TriggerData.IsShow) or false
	end
	self.BaseBtnVM.bCanUseQTE = CanUse
	UIUtil.SetIsVisible(self, true, true)
	if CanUse then
		self:PlayAnimation(self.AnimSkillTriggerLoop, 0, 0)
	else
		self:StopAnimation(self.AnimSkillTriggerLoop)
		self.EFF_Circle_015:SetRenderOpacity(0)
		local diffTime = TriggerCDTickTime / 1000
		if self.QTECDTimerID == 0 then
			self.QTECDTimerID = self:RegisterTimer(self.TriggerQTECDTick, 0, diffTime, 0, {deltaTime = diffTime})
		end
	end
end

function SkillTriggerBtnView:UpdateCanUse(CanUse)
	local _ <close> = CommonUtil.MakeProfileTag("SkillTriggerBtnView:UpdateCanUse")
	if not self.bMajor then
		UIUtil.SetIsVisible(self, true, true)
		return
	end
	if CanUse == nil then
		local TriggerData = _G.MajorTriggerSkillMgr:GetTriggerDataByIndex(self.ButtonIndex)
		CanUse = (TriggerData.IsTrigger and TriggerData.IsShow) or false
	end
	self.BaseBtnVM.bCanUseQTE = CanUse
	
	local BtnSkillID = self.BtnSkillID
    if BtnSkillID ~= rawget(self, "BLMQTESkillID") then
        UIUtil.SetIsVisible(self, CanUse, true)
		if BtnSkillID ~= 0 then
			self:PlayAnimation(self.AnimSkillTriggerLoop, 0, 0)
		end
    else
		UIUtil.SetIsVisible(self, true, true)
		local LogicData = SkillLogicMgr:GetSkillLogicData(self.EntityID)
		if LogicData ~= nil then
			LogicData:SetSkillButtonState(self.ButtonIndex, SkillBtnState.PVPQTE, CanUse)
			self:OnSkillStatusUpdate()
		end

        if CanUse then
            self:PlayAnimation(self.AnimSkillTriggerLoop, 0, 0)
        else
            self:StopAnimation(self.AnimSkillTriggerLoop)
			self.EFF_Circle_015:SetRenderOpacity(0)
			local diffTime = TriggerCDTickTime / 1000
			if self.QTECDTimerID == 0 then
				self.QTECDTimerID = self:RegisterTimer(self.TriggerQTECDTick, 0, diffTime, 0, {deltaTime = diffTime})
			end
        end
    end
end

function SkillTriggerBtnView:GetCanUse()
    if self.BtnSkillID ~= rawget(self, "BLMQTESkillID") then
		return self:GetIsShowView()
    else
		return self.BaseBtnVM.bCanUseQTE
    end
end

local AttrType2ButtonStatus = 
{
    [ProtoCommon.attr_type.attr_mp] = SkillBtnState.SkillMP,
    [ProtoCommon.attr_type.attr_gp] = SkillBtnState.SkillGP
}

function SkillTriggerBtnView:UpdateSkillCost(SkillID)
	local SkillVM = self.BaseBtnVM
	local bValid = SkillVM:CanUpdateSkillCost()
	SkillVM:SetSkillCostFlag(bValid)
	if bValid then
		local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
		local State, Cost = LogicData:GetButtonState(self.ButtonIndex, AttrType2ButtonStatus[SkillVM:GetCostAttr()])
		SkillVM:SetSkillCost(State or not self.bMajor, Cost)
	end
end

function SkillTriggerBtnView:SimulateTriggerSkill(SkillID,DisplayDuration)
	local SkillCDMgr = _G.SkillCDMgr
	local RemainTime = DisplayDuration / 1000
	self.EFF_Circle_015:SetRenderOpacity(0)
	self.BtnSkillID = SkillID
	local MajorSkillLogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
	if MajorSkillLogicData then
		MajorSkillLogicData:InitSkillMap(self.ButtonIndex,SkillID)
	end
	local BaseCD, QuickAttrInvalid = SkillCDMgr:LoadSkillCDInfo(SkillID) * 1000
	local CDData = {ID = SkillID,Expd = TimeUtil.GetServerTimeMS() + BaseCD}
	SkillCDMgr:DoSingleCD(CDData)
    UIUtil.SetIsVisible(self, true, true)
	self:PlayAnimation(self.AnimClick, 0, 1, nil, 1, true)
	self:PlayAnimation(self.AnimCDFinish, 0, 1, nil, 1, true)
	-- local Params = {SkillID=SkillID,Index= self.ButtonIndex}
	-- self:OnPlayerUseSkill(Params)
	if self.SmimulateSkillTimerID > 0 then
		self:UnRegisterTimer(self.SmimulateSkillTimerID)
	end
	self.SmimulateSkillTimerID = self:RegisterTimer(function()
		self:UnRegisterTimer(self.SmimulateSkillTimerID)
		UIUtil.SetIsVisible(self, false, false)
	end, RemainTime, RemainTime, 1)
end

-- 生产职业触发技也支持长按看Tips, 复用一下able按钮逻辑
local SkillAbleBtnView = require("Game/MainSkillBtn/SkillAbleBtnView")
SkillTriggerBtnView.OnLongClick = SkillAbleBtnView.OnLongClick
SkillTriggerBtnView.OnLongClickReleased = SkillAbleBtnView.OnLongClickReleased

return SkillTriggerBtnView