---
--- Author: chaooren
--- DateTime: 2022-03-02 16:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local MajorUtil = require("Utils/MajorUtil")
local UIViewMgr = require("UI/UIViewMgr")

local MedicineSkill = 2061
local AbleBtnPosition = {
	[2] = {_G.UE.FVector2D(185, 0), _G.UE.FVector2D(-190, 0)},
	[3] = {_G.UE.FVector2D(156.0, -94), _G.UE.FVector2D(0, 188), _G.UE.FVector2D(-160, -94)},
	[4] = {_G.UE.FVector2D(0, -186), _G.UE.FVector2D(185, 0), _G.UE.FVector2D(0, 188), _G.UE.FVector2D(-190, 0)},
}

local EffectAngle = {
	[2] = {0, 180},
	[3] = {-30, 90, 210},
	[4] = {-90, 0, 90, 180},
}

---@class SkillMultiChoiceDisplayView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Able_1 SkillAbleBtnView
---@field Able_2 SkillAbleBtnView
---@field Able_3 SkillAbleBtnView
---@field Able_4 SkillAbleBtnView
---@field ChoiceModeSwitcher UWidgetSwitcher
---@field Display UFCanvasPanel
---@field EFF_Sequence_Inst_1 UFImage
---@field EFF_Sequence_Inst_2 UFImage
---@field EFF_Sequence_Inst_3 UFImage
---@field FImg_2Select1 UFImage
---@field FImg_2Select2 UFImage
---@field FImg_3Select1 UFImage
---@field FImg_3Select2 UFImage
---@field FImg_3Select3 UFImage
---@field FImg_4Select1 UFImage
---@field FImg_4Select2 UFImage
---@field FImg_4Select3 UFImage
---@field FImg_4Select4 UFImage
---@field SkillDrugBtn SkillDrugBtnView
---@field SkillDrug_1 UScaleBox
---@field Skill_1 UScaleBox
---@field Skill_2 UScaleBox
---@field Skill_3 UScaleBox
---@field Skill_4 UScaleBox
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimSelectIn UWidgetAnimation
---@field AnimSelectOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillMultiChoiceDisplayView = LuaClass(UIView, true)

function SkillMultiChoiceDisplayView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Able_1 = nil
	--self.Able_2 = nil
	--self.Able_3 = nil
	--self.Able_4 = nil
	--self.ChoiceModeSwitcher = nil
	--self.Display = nil
	--self.EFF_Sequence_Inst_1 = nil
	--self.EFF_Sequence_Inst_2 = nil
	--self.EFF_Sequence_Inst_3 = nil
	--self.FImg_2Select1 = nil
	--self.FImg_2Select2 = nil
	--self.FImg_3Select1 = nil
	--self.FImg_3Select2 = nil
	--self.FImg_3Select3 = nil
	--self.FImg_4Select1 = nil
	--self.FImg_4Select2 = nil
	--self.FImg_4Select3 = nil
	--self.FImg_4Select4 = nil
	--self.SkillDrugBtn = nil
	--self.SkillDrug_1 = nil
	--self.Skill_1 = nil
	--self.Skill_2 = nil
	--self.Skill_3 = nil
	--self.Skill_4 = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimSelectIn = nil
	--self.AnimSelectOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillMultiChoiceDisplayView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Able_1)
	self:AddSubView(self.Able_2)
	self:AddSubView(self.Able_3)
	self:AddSubView(self.Able_4)
	self:AddSubView(self.SkillDrugBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillMultiChoiceDisplayView:OnInit()
	self.Active = false
	self.SelectIndex = 0
	self.CacheSkillID = {}
	self.MultiChoiceCount = 0
	self.IsSkillDrugBtn = false
	self.bCancel = false

	--self.SkillMultiChoiceDisplayVM = SkillMultiChoiceDisplayVM.New()
	self.AbleMap = {
		self.Able_1, self.Able_2, self.Able_3, self.Able_4
	}

	self.ScaleSkillMap = {
		self.Skill_1, self.Skill_2, self.Skill_3, self.Skill_4
	}

	self.ImgSelectMap = {
		[2] = {self.FImg_2Select1, self.FImg_2Select2},
		[3] = {self.FImg_3Select1, self.FImg_3Select2, self.FImg_3Select3},
		[4] = {self.FImg_4Select1, self.FImg_4Select2, self.FImg_4Select3, self.FImg_4Select4},
	}
	self.IsStopUnlockAnimation = {}

	rawset(self, "bMultiSkillPanel", true)
end

function SkillMultiChoiceDisplayView:OnDestroy()

end

function SkillMultiChoiceDisplayView:OnEntityIDUpdate(EntityID, bMajor)
	self.EntityID = EntityID
	self.bMajor = bMajor

	for _, value in ipairs(self.SubViews) do
		value.EntityID = self.EntityID
		value.bMajor = self.bMajor
	end
end

function SkillMultiChoiceDisplayView:OnShow()
end

function SkillMultiChoiceDisplayView:ViewShow(Params)

	self.SelectIndex = 0

	self.SelectIdList = Params.SelectIdList
	if self.SelectIdList == nil or #self.SelectIdList == 0 then
		return
	end
	self.BaseSkillIndex = Params.BaseSkillIndex
	self.MultiChoiceCount = Params.MultiChoiceCount
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if not LogicData then
		return
	end
	local _ <close> = CommonUtil.MakeProfileTag("SkillMultiChoiceDisplayView:ViewShow")


	_G.EventMgr:SendEvent(EventID.SkillMultiChoicePanelShowed, { IsDisplayed = true })
	self.bActive = true

	-- do
	-- 	local _ <close> = CommonUtil.MakeProfileTag("SkillMultiChoiceDisplayView:UpdateSubView")
	-- 	--这么写大约可以节省0.2ms耗时
	-- 	for _, value in ipairs(self.SubViews) do
	-- 		value.EntityID = self.EntityID
	-- 		value.bMajor = self.bMajor
	-- 	end
	-- end

	do
		local _ <close> = CommonUtil.MakeProfileTag("SkillMultiChoiceDisplayView:UpdateMultiChoice")
		for index = 1, self.MultiChoiceCount do
			local AbleBtn = self.AbleMap[index]
			local SelectIDInfo = self.SelectIdList[index]
			local SelectSkillID = SelectIDInfo and SelectIDInfo.ID or 0
			if SelectSkillID == MedicineSkill then -- 吃药技能
				LogicData:InitSkillMap(self.SkillDrugBtn.ButtonIndex, SelectSkillID)
			else
				LogicData:InitSkillMap(AbleBtn.ButtonIndex, SelectSkillID)
				AbleBtn:OnShow()
			end
		end
	end

	_G.UIAsyncTaskMgr:UnRegisterTask(self.ViewShowTaskID)

	local co = coroutine.create(self.ViewShowAsync)
	self.ViewShowTaskID = _G.UIAsyncTaskMgr:RegisterTask(co, self)

	self.bAsync = true
end

function SkillMultiChoiceDisplayView:ViewShowAsync()
	local _ <close> = CommonUtil.MakeProfileTag("SkillMultiChoiceDisplayView:OnShow_Display")
	self.bAsync = false
	UIUtil.SetIsVisible(self.Display, true)
	self.ChoiceModeSwitcher:SetActiveWidgetIndex(self.MultiChoiceCount - 2)
	local SelectEffect = self[string.format("EFF_Sequence_Inst_%d", self.MultiChoiceCount - 1)]
	if SelectEffect then
		SelectEffect:SetRenderOpacity(0)
	end
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	local bDrugBtnVisible = false
	local PosTable = AbleBtnPosition[self.MultiChoiceCount]
	for index = 1, 4 do
		local AbleBtn = self.AbleMap[index]
		if index <= self.MultiChoiceCount then
			UIUtil.SetIsVisible(self.ImgSelectMap[self.MultiChoiceCount][index], false)
			local SelectIDInfo = self.SelectIdList[index]
			local SelectSkillID = SelectIDInfo and SelectIDInfo.ID or 0
			if SelectSkillID == MedicineSkill then -- 吃药技能
				UIUtil.CanvasSlotSetPosition(self.SkillDrug_1, PosTable[index])
				bDrugBtnVisible = true
				AbleBtn:SetVisible(false)
			else -- 一般技能
				local ScaleBox = self.ScaleSkillMap[index]
				UIUtil.CanvasSlotSetPosition(ScaleBox, PosTable[index])
				AbleBtn:OnMultiChoiceSelectChanged(false)
				AbleBtn:SetVisible(true)
				--判断是否播放技能解锁特效
				self.IsStopUnlockAnimation[index] = false
				if SelectIDInfo.NewUnLockSkill then
					local ProfID = MajorUtil.GetMajorProfID()
					local MajorLevel = MajorUtil.GetMajorLevelByProf(ProfID)
					local PWorldLevel = MajorUtil.GetMajorLevel()
					if MajorLevel and PWorldLevel then
						if MajorLevel <= PWorldLevel and LogicData then
							local InValidCount = LogicData:GetButtonIndexState(AbleBtn.ButtonIndex)
							AbleBtn:PlaySkillUnlockAnimation({SetCommonMaskTime = 1.2, InValidCount = InValidCount, SkillMultiChoice = 1} )
							self.IsStopUnlockAnimation[index] = true
						end
					end
					SelectIDInfo.NewUnLockSkill = false
				end
			end
		else
			AbleBtn:SetVisible(false)
		end
	end
	self.SkillDrugBtn:SetVisible(bDrugBtnVisible)
	if bDrugBtnVisible then
		self.SkillDrugBtn:OnShow()
	end

	if self.SelectIndex > 0 then
		self:OnHoverSkillSelect(self.SelectIndex, true)
	end
	self.ViewShowTaskID = nil
end

function SkillMultiChoiceDisplayView:OnHide()
	if self.bActive then
		self:ViewHide()
	end
end

--为了减少lua class调用这么写
local DrugButtonIndex = 25

local function StopSkillUnlockAnimation(AbleBtn)
	AbleBtn:StopSkillUnlockAnimation(true)
end

function SkillMultiChoiceDisplayView:ViewHide()
	_G.EventMgr:SendEvent(EventID.SkillMultiChoicePanelShowed, { IsDisplayed = false })
	self:OnSelectedCancelChange(false)
	local EntityID = self.EntityID
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(EntityID)
	for index = 1, 4 do
		local AbleBtn = self.AbleMap[index]

		-- 恢复一下按钮可见性, 否则View Recycle之后, 下次判定IsShowView有问题导致Binder注册不上
		AbleBtn:SetVisible(true)
		--关闭后解锁动画不能继续播放
		if self.IsStopUnlockAnimation[index] then
			StopSkillUnlockAnimation(AbleBtn)
		end
		local AbleButtonIndex = AbleBtn.ButtonIndex
		if LogicData then
			LogicData:InitSkillMap(AbleButtonIndex, 0)
		end

		AbleBtn:ClearAllTask()
	end
	self.SelectIdList = nil
	self.bActive = false
	UIUtil.SetIsVisible(self.Display, false)
	_G.UIAsyncTaskMgr:UnRegisterTask(self.ViewShowTaskID)
	self.ViewShowTaskID = nil
	self.bAsync = false
	self:StopLongClickDisplay()
end

function SkillMultiChoiceDisplayView:OnRegisterUIEvent()

end

function SkillMultiChoiceDisplayView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.SkillReplace, self.OnSkillReplace)
end

function SkillMultiChoiceDisplayView:OnRegisterBinder()

end

function SkillMultiChoiceDisplayView:GetCastSkillValidIndex()
	if self.bActive == true and self.bCancel == false then
		return self.SelectIndex or 0
	end
	return 0
end

--player castskill true
--other nil
function SkillMultiChoiceDisplayView:DoMultiChoiceCastSkill()
	if self.SkillTipsHandle then return nil end
	if self.IsSkillDrugBtn then
		self.SkillDrugBtn:OnMainSkillButtonUp(true)
		self.IsSkillDrugBtn = false
		return nil
	end

	local SelectIndex = self:GetCastSkillValidIndex()
	if SelectIndex > 0 then
		local ButtonName = string.format("Able_%d", SelectIndex)
		local MainDerivedSkill = self[ButtonName]
		if MainDerivedSkill:OnPrepareCastSkill() then
			local bSuccess = MainDerivedSkill:OnCastSkill()
			if bSuccess == true then
				return SelectIndex
			end
		end
	end
end

function SkillMultiChoiceDisplayView:OnSkillReplace(Params)
	if not self.bActive then
		return
	end

	if self.BaseSkillIndex == Params.SkillIndex then
		self:ViewHide()
		return
	end

	for _, AbleView in ipairs(self.AbleMap) do
		if AbleView.ButtonIndex == Params.SkillIndex then
			AbleView:OnSkillReplace(Params)
			return
		end
	end
end

function SkillMultiChoiceDisplayView:OnHoverSkillSelect(SelectIndex, ForceNotify)
	if nil == SelectIndex then return end

	local SelectIDInfo = self.SelectIdList and self.SelectIdList[SelectIndex]
	if self.bAsync then
		if SelectIndex > 0 then
			local SkillName = SkillMainCfg:FindValue(SelectIDInfo and SelectIDInfo.ID or 0, "SkillName")
			if SkillName == _G.LSTR("使用药品") then --战斗药品按钮被选择
				self.IsSkillDrugBtn = true
			else
				self.IsSkillDrugBtn = false
			end
		end
		self.SelectIndex = SelectIndex
		return
	end

	if self.bActive and (self.SelectIndex ~= SelectIndex or ForceNotify) then
		for index = 1, self.MultiChoiceCount do
			local BgName = string.format("FImg_%dSelect%d", self.MultiChoiceCount, index)
			local IconWidget = self[BgName]
			local bSelect = SelectIndex == index
			UIUtil.SetIsVisible(IconWidget, bSelect)
			local AbleBtn = self[string.format("Able_%d", index)]
			AbleBtn:OnMultiChoiceSelectChanged(bSelect)
		end
		local SelectEffect = self[string.format("EFF_Sequence_Inst_%d", self.MultiChoiceCount - 1)]
		if SelectIndex > 0 then
			SelectEffect:SetRenderTransformAngle(EffectAngle[self.MultiChoiceCount][SelectIndex])
			SelectEffect:SetRenderOpacity(1)
		else
			SelectEffect:SetRenderOpacity(0)
		end

		if SelectIndex > 0 then
			local SkillName = SkillMainCfg:FindValue(SelectIDInfo and SelectIDInfo.ID or 0, "SkillName")
			if SkillName == _G.LSTR("使用药品") then --战斗药品按钮被选择
				self.IsSkillDrugBtn = true
			else
				self.IsSkillDrugBtn = false
			end
		end

		if self.bMajor then
			if SelectIndex > 0 then
				self:StartLongClickTimer(SelectIndex)
			else
				self:StopLongClickDisplay()
			end
		end

		self.SelectIndex = SelectIndex
	end
end

function SkillMultiChoiceDisplayView:OnSelectedCancelChange(bCancel)
	self.bCancel = bCancel
	if self.SelectIndex == 0 then
		return
	end
	local BgName = string.format("FImg_%dSelect%d", self.MultiChoiceCount, self.SelectIndex)
	local IconWidget = self[BgName]
	local ChangeColor = bCancel and SkillCommonDefine.JoyStickInvalidateColor or SkillCommonDefine.JoyStickDefaultColor
	UIUtil.ImageSetColorAndOpacityHex(IconWidget, ChangeColor)
	local AbleBtn = self[string.format("Able_%d", self.SelectIndex)]
	AbleBtn:OnMultiChoiceCancelChanged(bCancel, ChangeColor)
end

function SkillMultiChoiceDisplayView:StartLongClickTimer(Index)
	self:StopLongClickDisplay()

	self.StartLongClickTime = _G.UE.UTimerMgr:Get().GetLocalTimeMS()
	self.LongClickTimerID = self:RegisterTimer(self.OnLongClick, SkillCommonDefine.SkillTipsClickTime, 1, 1, Index)
end

function SkillMultiChoiceDisplayView:StopLongClickDisplay()
	if self.LongClickTimerID then
		self:UnRegisterTimer(self.LongClickTimerID)
	end
	if self.SkillTipsHandle then
		_G.SkillTipsMgr:HideTipsByHandleID(self.SkillTipsHandle)
		self.SkillTipsHandle = nil
	end
end

function SkillMultiChoiceDisplayView:OnLongClick(Index)
	local SkillID = self.SelectIdList[Index].ID or 0
	local Widget = self.AbleMap[Index]
	if SkillID > 0 then
		self.SkillTipsHandle = _G.SkillTipsMgr:ShowMajorCombatSkillTips(SkillID, Widget)
	end
end

return SkillMultiChoiceDisplayView