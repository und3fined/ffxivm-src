---
--- Author: kanohchen
--- DateTime: 2025-08-27 16:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SettingsHandleDefine = require("Game/Settings/SettingsHandleDefine")
local EventID = require("Define/EventID")
local SkillUtil = require("Utils/SkillUtil")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local SkillHandleRunBtnVM = require("Game/MainSkillHandle/View/Item/SkillHandleRunBtnVM")
local UIBinderSetBrushFromAssetPath =  require("Binder/UIBinderSetBrushFromAssetPath")

local OneVector2D = _G.UE.FVector2D(1, 1)
local BtnLockTime = 3

---@class SkillHandleRunBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnEntrance UFButton
---@field HandleState SkillHandleStateLView
---@field ImgIcon UFImage
---@field ImgSlot UFImage
---@field Img_CD URadialImage
---@field Panel UFCanvasPanel
---@field PanelCD UFCanvasPanel
---@field Text_SkillCD UFTextBlock
---@field AnimCDFinish UWidgetAnimation
---@field ButtonIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillHandleRunBtnView = LuaClass(UIView, true)

function SkillHandleRunBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnEntrance = nil
	--self.HandleState = nil
	--self.ImgIcon = nil
	--self.ImgSlot = nil
	--self.Img_CD = nil
	--self.Panel = nil
	--self.PanelCD = nil
	--self.Text_SkillCD = nil
	--self.AnimCDFinish = nil
	--self.ButtonIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillHandleRunBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.HandleState)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillHandleRunBtnView:OnInit()
	self.SkillIndex = 10	--技能组表加速技能
	self.SkillID = 0
end

function SkillHandleRunBtnView:OnDestroy()

end

function SkillHandleRunBtnView:OnShow()
	local ParentView = rawget(self, "ParentView")
	local EntityID = ParentView.EntityID
	if EntityID == nil or EntityID == 0 then
		EntityID = MajorUtil.GetMajorEntityID()
	end
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(EntityID)
	if LogicData then
		self.SkillID = LogicData:GetBtnSkillID(self.SkillIndex)
	else
		self.SkillID = 0
	end
	self:OnGamePadUpdateCombatType()
end

function SkillHandleRunBtnView:OnHide()

end

function SkillHandleRunBtnView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnEntrance, self.OnBtnClick)
	UIUtil.AddOnPressedEvent(self, self.BtnEntrance, self.OnBtnPressed)
	UIUtil.AddOnReleasedEvent(self, self.BtnEntrance, self.OnBtnRelease)
end

function SkillHandleRunBtnView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.SkillCDUpdateLua, self.OnSkillCDUpdate)
	self:RegisterGameEvent(EventID.SkillReplace, self.OnSkillReplace)
	self:RegisterGameEvent(EventID.GamePadUpdateCombatType, self.OnGamePadUpdateCombatType)
	self:RegisterGameEvent(EventID.InputActionSkillPressed, self.OnInputActionSkillPressed)
	self:RegisterGameEvent(EventID.InputActionSkillReleased, self.OnInputActionSkillReleased)
	self:RegisterGameEvent(EventID.ChangeHandleSpeedSkillFunc, self.OnChangeHandleSpeedSkillFunc)
	self:RegisterGameEvent(EventID.GamePadFishingSit, self.OnGamePadFishingSit)
end

function SkillHandleRunBtnView:OnRegisterBinder()
	local Binders = {
		{"SkillCD", UIBinderSetText.New(self, self.Text_SkillCD)},
		{"bSkillValid", UIBinderSetIsVisible.New(self, self.Img_CD, true)},
		{"NormalCDPercent", UIBinderSetPercent.New(self, self.Img_CD) },
		{"SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{"SkillCDUpadting" ,UIBinderValueChangedCallback.New(self, nil, self.PlayCDFinishAnim) },
	}
	self.SkillHandleRunBtnVM = SkillHandleRunBtnVM.New()
	self:RegisterBinders(self.SkillHandleRunBtnVM , Binders)
end

function SkillHandleRunBtnView:OnBtnClick()
	if self.SkillHandleRunBtnVM:GetIsSpeedSkill() and self.SkillHandleRunBtnVM:IsSkillValid() then
		if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_USE_SKILL, true) then
			return
		end
		local BtnIndex = self.SkillIndex
		local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
		if LogicData and LogicData:CanCastSkill(BtnIndex, true) then
			if self.SkillID == 0 then
				self.SkillID = LogicData:GetBtnSkillID(self.SkillIndex)
			end
			SkillUtil.CastNormalSkillDirect(self.SkillID, BtnIndex)
		end
	elseif self.SkillHandleRunBtnVM:IsSkillValid() then
		self:OnClickBtnSit()
	end
end

function SkillHandleRunBtnView:OnGamePadUpdateCombatType()
    local HandleButtonText = _G.SettingsHandleMgr:GetHandleInputActionTextByCusAction(SettingsHandleDefine.HandleCustomActionType.SpeedSkill)
	if HandleButtonText then
		self.HandleState:SetHandleButtonText(HandleButtonText)
	end
end

function SkillHandleRunBtnView:OnBtnPressed()
	self:SetRenderScale(OneVector2D* SkillCommonDefine.SkillBtnClickFeedback)
end

function SkillHandleRunBtnView:OnBtnRelease()
	self:SetRenderScale(OneVector2D)
end

function SkillHandleRunBtnView:OnSkillCDUpdate(Params)
	if Params.SkillID == self.SkillID then
		self.SkillHandleRunBtnVM:SetSkillCD(Params.SkillCD, Params.BaseCD)
	end
end

function SkillHandleRunBtnView:OnSkillReplace(Params)
	if Params.SkillIndex == self.SkillIndex then
		self.SkillID = Params.SkillID
		local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
		if LogicData then
			LogicData:UpdateAllStateList(Params.SkillIndex, Params.SkillID)
			LogicData:RefreshAllAffectedFlag(Params.SkillIndex, Params.SkillID)
		end
		self.SkillHandleRunBtnVM:SetSkillCD(_G.SkillCDMgr:GetSkillRealCDValue(Params.SkillID))
	end
end

function SkillHandleRunBtnView:OnInputActionSkillPressed(Params)
	if Params ~= self.SkillIndex then return end
	self:SetRenderScale(OneVector2D * SkillCommonDefine.SkillBtnClickFeedback)
	self:StartLongClickTimer()
end

function SkillHandleRunBtnView:OnInputActionSkillReleased(Params)
	if Params ~= self.SkillIndex then return end
	self:SetRenderScale(OneVector2D)
end

function SkillHandleRunBtnView:StopLongClickTimer()
	self:SetRenderScale(OneVector2D)
	local LongClickTimerID = rawget(self, "LongClickTimerID")
	if LongClickTimerID then
		self:UnRegisterTimer(LongClickTimerID)
		rawset(self, "LongClickTimerID", nil)
	end
end

function SkillHandleRunBtnView:StartLongClickTimer()
	local LongClickTimerID = rawget(self, "LongClickTimerID")
	if LongClickTimerID then
		self:UnRegisterTimer(LongClickTimerID)
	end

	self.StartLongClickTime = _G.UE.UTimerMgr:Get().GetLocalTimeMS()
	LongClickTimerID = self:RegisterTimer(self.StopLongClickTimer, SkillCommonDefine.SkillTipsClickTime, 1, 1)
	rawset(self, "LongClickTimerID", LongClickTimerID)
end


local IE_Pressed = _G.UE.EInputEvent.IE_Pressed
local IE_Released = _G.UE.EInputEvent.IE_Released
function SkillHandleRunBtnView:OnGamePadFishingSit(EventType)
	if EventType ==  IE_Pressed then
		self:StartLongClickTimer()
		self:SetRenderScale(OneVector2D * SkillCommonDefine.SkillBtnClickFeedback)
	elseif EventType == IE_Released then
		self:SetRenderScale(OneVector2D)
		local LongClickTimerID = rawget(self, "LongClickTimerID")
		if LongClickTimerID then
			self:UnRegisterTimer(LongClickTimerID)
			rawset(self, "LongClickTimerID", nil)
			self:OnClickBtnSit()
		end
	end
end

function SkillHandleRunBtnView:OnChangeHandleSpeedSkillFunc(IsInFishingState)
	self.SkillHandleRunBtnVM:SetSpeedSkillIcon(not IsInFishingState)
end

function SkillHandleRunBtnView:OnClickBtnSit()
	if not self.bSitBtnLock then
		_G.FishMgr:SendMajorSitChange()
		-- 这里设置一个按钮的内置CD防止玩家连点
		self.bSitBtnLock = true
		self:RegisterTimer(self.UnLockBtnSit,BtnLockTime,1,1)
	end
end

function SkillHandleRunBtnView:UnLockBtnSit()
	self.bSitBtnLock = false
end

function SkillHandleRunBtnView:PlayCDFinishAnim(Value)
	if not Value then
		self:PlayAnimationToEndTime(self.AnimCDFinish, 0, 1, nil, 1, true)
	end
end

return SkillHandleRunBtnView