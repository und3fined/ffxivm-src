---
--- Author: v_vvxinchen
--- DateTime: 2025-04-07 09:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local SkillUtil = require("Utils/SkillUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgTipsID = require("Define/MsgTipsID")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local SkillButtonStateMgr = require("Game/Skill/SkillButtonStateMgr")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local ProtoRes = require("Protocol/ProtoRes")
local attr_type = require("Protocol/ProtoCommon").attr_type
local ButtonStateTips = SkillButtonStateMgr.ButtonStateTips
local State = SkillButtonStateMgr.SkillBtnState

local OneVector2D          <const> = _G.UE.FVector2D(1, 1)

---@class GatheringSkillItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field CanvasPanel UFCanvasPanel
---@field EFF_Loop_Color_Inst_1 UFImage
---@field FImg_CDNormal UFImage
---@field IconSkill UFImage
---@field ImgLight UFImage
---@field ImgSlot UFImage
---@field ImgSlotFrame UFImage
---@field MiddleNumber URichTextBox
---@field PanelBtnTips UFCanvasPanel
---@field PanelConsume3 UFCanvasPanel
---@field TextNum3 UFTextBlock
---@field Text_SkillCD UFTextBlock
---@field AnimClick UWidgetAnimation
---@field AnimClickIn UWidgetAnimation
---@field AnimClickOut UWidgetAnimation
---@field AnimDisable UWidgetAnimation
---@field ButtonIndex int
---@field IsScour bool
---@field IsHighYield bool
---@field IsCheckSkill bool
---@field Color_Enough LinearColor
---@field Color_NotEnough LinearColor
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatheringSkillItemView = LuaClass(UIView, true)

function GatheringSkillItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.CanvasPanel = nil
	--self.EFF_Loop_Color_Inst_1 = nil
	--self.FImg_CDNormal = nil
	--self.IconSkill = nil
	--self.ImgLight = nil
	--self.ImgSlot = nil
	--self.ImgSlotFrame = nil
	--self.MiddleNumber = nil
	--self.PanelBtnTips = nil
	--self.PanelConsume3 = nil
	--self.TextNum3 = nil
	--self.Text_SkillCD = nil
	--self.AnimClick = nil
	--self.AnimClickIn = nil
	--self.AnimClickOut = nil
	--self.AnimDisable = nil
	--self.ButtonIndex = nil
	--self.IsScour = nil
	--self.IsHighYield = nil
	--self.IsCheckSkill = nil
	--self.Color_Enough = nil
	--self.Color_NotEnough = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatheringSkillItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatheringSkillItemView:OnInit()
	
end

function GatheringSkillItemView:OnDestroy()

end

function GatheringSkillItemView:OnShow()
	local ProfID = MajorUtil.GetMajorProfID()
	local SkillGroup = _G.GatheringJobSkillPanelVM.SkillGroup[ProfID]
	self.SkillID = SkillGroup[self.ButtonIndex]
	SkillUtil.ChangeSkillIcon(self.SkillID, self.IconSkill)

	--BtnTips
	local IsScour = self.IsScour
	UIUtil.SetIsVisible(self.PanelConsume3, not IsScour)
	UIUtil.SetIsVisible(self.PanelBtnTips, IsScour)
	if not IsScour then --除了提纯技能
		self.TextNum3:SetText(self:GetSkillCostGP(self.SkillID))
		self:RefreshCostTextColor()
	end

	--ImgCD
    UIUtil.SetIsVisible(self.Text_SkillCD, false)

	--Onshow时已进入状态，执行过OnRreshSkillGroup，VM已有数据
	self:OnSetIsCanScour()
	--3慎重提纯4大胆提纯在进入状态时VM控制
	if self.ButtonIndex ~= 4 and self.ButtonIndex ~= 3 then
		UIUtil.SetIsVisible(self.ImgLight, false)
	end
end

--获取采集力消耗值
function GatheringSkillItemView:GetSkillCostGP(SkillID)
    local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
    if Cfg and Cfg.CostList then
		for index = 1, #Cfg.CostList do
			local CostUnit = Cfg.CostList[index]
			if CostUnit.AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_ATTR and CostUnit.AssetId == attr_type.attr_gp then
				local CostValue = CostUnit.AssetCost
				if CostValue and CostValue ~= 0 then
					return CostValue
				end
			end
		end
    end
	return 0
end

function GatheringSkillItemView:OnHide()
	self:StopAllAnimations()
	local AnimDisableEndTime = self.AnimDisable:GetEndTime()
	self:PlayAnimationTimeRange(self.AnimDisable, AnimDisableEndTime-0.01, AnimDisableEndTime, 1, nil, 1.0, false)
	local AnimClickEndTime = self.AnimClick:GetEndTime()
	self:PlayAnimationTimeRange(self.AnimClick, AnimClickEndTime-0.01, AnimClickEndTime, 1, nil, 1.0, false)
end

--region-----------------------------Binders---------------------------------
function GatheringSkillItemView:OnRegisterBinder()
	self.Binders = {
        {"bCanScour", UIBinderValueChangedCallback.New(self, nil, self.OnSetIsCanScour)},
    }
	if self.IsCheckSkill then
		table.insert(self.Binders, {"Scrutiny", UIBinderValueChangedCallback.New(self, nil, self.OnScrutiny)})
	elseif self.IsHighYield then
		table.insert(self.Binders, {"bHighYield", UIBinderValueChangedCallback.New(self, nil, self.OnSetIsHighYield)})
	end
	self:RegisterBinders(_G.GatheringJobSkillPanelVM, self.Binders)
end

function GatheringSkillItemView:OnSetIsCanScour()
	if self.IsScour then
		if  _G.GatheringJobSkillPanelVM.bCanScour then
			UIUtil.SetIsVisible(self.FImg_CDNormal, false)
		else
			UIUtil.SetIsVisible(self.FImg_CDNormal, true)
		end
	end
end

function GatheringSkillItemView:OnSetIsHighYield()
    if _G.GatheringJobSkillPanelVM.bHighYield then
        UIUtil.SetIsVisible(self.FImg_CDNormal, false)
    else
        UIUtil.SetIsVisible(self.FImg_CDNormal, true)
    end
end

function GatheringSkillItemView:OnScrutiny()
    _G.FLOG_INFO("GatheringJobSkillPanelView:OnScrutiny")
    if  _G.GatheringJobSkillPanelVM.Scrutiny then
        UIUtil.SetIsVisible(self.EFF_Loop_Color_Inst_1, true)
    else
        UIUtil.SetIsVisible(self.EFF_Loop_Color_Inst_1, false)
    end
end
--endregion

--region-----------------------------UIEvent---------------------------------
function GatheringSkillItemView:OnRegisterUIEvent()
	UIUtil.AddOnPressedEvent(self, self.Btn, self.OnPressed)
	UIUtil.AddOnReleasedEvent(self, self.Btn, self.OnReleased)
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickSkillBtn)
	UIUtil.AddOnLongClickedEvent(self, self.Btn, self.OnLongClickedSkillBtn)
    UIUtil.AddOnLongClickReleasedEvent(self, self.Btn, self.OnLongClickReleasedSkillBtn)
end

function GatheringSkillItemView:OnClickSkillBtn()
	
	local bSuccess = false
	local index = self.ButtonIndex
	local SkillID = self.SkillID
	if self.IsScour then
		if _G.GatheringJobSkillPanelVM.bCanScour then
			FLOG_INFO("Gather Collection Cast Scour Skill")
			_G.CollectionMgr.SkillIndex = index
			bSuccess = true
		else
			MsgTipsUtil.ShowTipsByID(MsgTipsID.ScourSkillUnUse)
		end
	elseif self.IsCheckSkill then
		if not self:PreCastSkill() then
			MsgTipsUtil.ShowTips(ButtonStateTips[State.SkillGP])
		else
			_G.CollectionMgr.SkillIndex = index
			bSuccess = true
		end
	elseif self.IsHighYield then
		if not self:PreCastSkill() then
			MsgTipsUtil.ShowTips(ButtonStateTips[State.SkillGP])
		elseif _G.GatheringJobSkillPanelVM.bHighYield == false then
			MsgTipsUtil.ShowTipsByID(MsgTipsID.GatherDurationMax)
		elseif _G.GatherMgr:CheckHighProductionCastCount(SkillID) == false then
			MsgTipsUtil.ShowTipsByID(MsgTipsID.GatherHighProduceCnt)
		else
			bSuccess = true
		end
	end
	if bSuccess then
		bSuccess = _G.CollectionMgr:CastSkill(index,SkillID,self.IsScour)
	end
	if bSuccess then
		self:PlayAnimation(self.AnimClick)
	else
		self:PlayAnimation(self.AnimDisable)
	end
end

---@type 长按提纯or集中检查技能
function GatheringSkillItemView:OnLongClickedSkillBtn()
    _G.FLOG_INFO("OnLongClickedScour")
	local index = self.ButtonIndex
	local View = _G.UIViewMgr:FindView(_G.UIViewID.GatheringJobSkillPanel)
	local CollectionPopup = View.CollectionPopup
    --显隐
    if self.IsScour then --3个提纯
        UIUtil.SetIsVisible(CollectionPopup.ProBarYellow, true) --提纯的预测值：黄圈
        if index == 4 then --大胆提纯
            UIUtil.SetIsVisible(CollectionPopup.ProBarRed, true) --提纯的预测最大值：红圈
        end
        --数据
        _G.GatheringJobSkillPanelVM:LongClickedScour(index)
    else
        UIUtil.SetIsVisible(CollectionPopup.ProBarRed, false)
        UIUtil.SetIsVisible(CollectionPopup.ProBarYellow, false)
    end

    --tip
    local ProfID = MajorUtil.GetMajorProfID()
    View.JobSkillTips:UPdateSkillInfo(self.SkillID, ProfID)
    UIUtil.SetIsVisible(View.PanelSkillTips, true)

	local btnsize = UIUtil.CanvasSlotGetSize(self)
	local InPosition = UIUtil.CanvasSlotGetPosition(self)
		-_G.UE.FVector2D(-btnsize.X * 0.4, -btnsize.Y)
	UIUtil.CanvasSlotSetPosition(View.PanelSkillTips, InPosition)
end

---@type 松开提纯or集中检查技能
function GatheringSkillItemView:OnLongClickReleasedSkillBtn()
    _G.FLOG_INFO("OnLongClickReleasedScour")
    --当松开的时候，隐藏tip
	local View = _G.UIViewMgr:FindView(_G.UIViewID.GatheringJobSkillPanel)
	local CollectionPopup = View.CollectionPopup
    UIUtil.SetIsVisible(View.PanelSkillTips, false)
    UIUtil.SetIsVisible(CollectionPopup.ProBarYellow, false)
    UIUtil.SetIsVisible(CollectionPopup.ProBarRed, false)
    --如果是提纯，数值回归，只显示绿环
    _G.GatheringJobSkillPanelVM:OnRefreshCollectionPanel()
end

function GatheringSkillItemView:OnPressed()
	self:SetRenderScale(OneVector2D * SkillCommonDefine.SkillBtnClickFeedback)
end

function GatheringSkillItemView:OnReleased()
	self:SetRenderScale(OneVector2D)
end
--endregion

--region-----------------------------GameEvent---------------------------------
function GatheringSkillItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OnCastSkillUpdateMask, self.OnCastSkillUpdateMask)
	self:RegisterGameEvent(_G.EventID.Attr_Change_GP, self.OnGameEventActorGPChange)
end

-----@type 当技能释放时所有技能都置灰
function GatheringSkillItemView:OnCastSkillUpdateMask(OnCast)
    if OnCast == nil then
        OnCast = self.OnCast --药品使用后更新
    else
        self.OnCast = OnCast --技能使用后更新
    end
    if OnCast then
		UIUtil.SetIsVisible(self.FImg_CDNormal, true)
    else
		if
			(not _G.GatheringJobSkillPanelVM.bCanScour and self.IsScour)
				or (self.ButtonIndex == 1 and (not _G.GatheringJobSkillPanelVM.bHighYield or _G.GatherMgr:CheckHighProductionCastCount(self.SkillID) == false)) 
				or not self:PreCastSkill()
			then
			UIUtil.SetIsVisible(self.FImg_CDNormal, true)
		else
			UIUtil.SetIsVisible(self.FImg_CDNormal, false)
		end
    end
end

function GatheringSkillItemView:PreCastSkill()
    if self.LogicData == nil then
		local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
		if LogicData == nil then
			_G.FLOG_ERROR("GatheringSkillItemView PreCastSkill, but Major LogicData is nil")
			return false
		end
		self.LogicData = LogicData
    end
    return self.LogicData:PlayerGPCheck(nil, self.SkillID)
end

function GatheringSkillItemView:OnGameEventActorGPChange(Params)
	if Params ~= nil then
		local EntityID = Params.ULongParam1
        if MajorUtil.IsMajor(EntityID) then
            self:RefreshCostTextColor()
			self:OnCastSkillUpdateMask()
        end
    end
end

function GatheringSkillItemView:RefreshCostTextColor()
	local bIsEnough = self:PreCastSkill()
	if bIsEnough then
		self.TextNum3:SetColorAndOpacity(self.Color_Enough)
	else
		self.TextNum3:SetColorAndOpacity(self.Color_NotEnough)
	end
end
--endregion

return GatheringSkillItemView