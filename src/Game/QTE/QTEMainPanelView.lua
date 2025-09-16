---
--- Author: frankjfwang
--- DateTime: 2021-02-02 21:27
--- Description:
---

local UIViewMgr = _G.UIViewMgr
local ActorMgr = _G.ActorMgr
local UIView = require("UI/UIView")
local ProtoCommon = require("Protocol/ProtoCommon")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local FMath = _G.UE.UKismetMathLibrary
local UIViewID = _G.UIViewID
local FLOG_INFO = _G.FLOG_INFO
local EventID = _G.EventID

---@class QTEMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bar_BlueRed UProgressBar
---@field ProgressCursorPanel UCanvasPanel
---@field ProgressCursorPanel2 UCanvasPanel
---@field RightBtn UButton
---@field Text_Time UTextBlock
---@field Anim_Aoto_In UWidgetAnimation
---@field Anim_Click UWidgetAnimation
---@field Anim_Contest UWidgetAnimation
---@field Anim_Tips_Loop UWidgetAnimation
---@field GuideShowTime float
---@field ProgressSpeed float
---@field AddPerClick float
---@field QTETotalTime float
---@field MapSequenceActorId int
---@field QTEStartSequence_SegId int
---@field QTEEndSequence_SegId int
---@field BeginLerpThreshold float
---@field LerpCoef float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local QTEMainPanelView = LuaClass(UIView, true)

function QTEMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bar_BlueRed = nil
	--self.ProgressCursorPanel = nil
	--self.ProgressCursorPanel2 = nil
	--self.RightBtn = nil
	--self.Text_Time = nil
	--self.Anim_Aoto_In = nil
	--self.Anim_Click = nil
	--self.Anim_Contest = nil
	--self.Anim_Tips_Loop = nil
	--self.GuideShowTime = nil
	--self.ProgressSpeed = nil
	--self.AddPerClick = nil
	--self.QTETotalTime = nil
	--self.MapSequenceActorId = nil
	--self.QTEStartSequence_SegId = nil
	--self.QTEEndSequence_SegId = nil
	--self.BeginLerpThreshold = nil
	--self.LerpCoef = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.BloodPercent = 0.5
	self.CurrentProgressAnim = nil
	self.ContestAnimPlayed = false
end

function QTEMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function QTEMainPanelView:OnInit()
end

function QTEMainPanelView:OnDestroy()

end

function QTEMainPanelView:OnShow()
	self.GuideLeftTime = self.GuideShowTime
	self.QTELeftTime = self.QTETotalTime
	--local UILayer = require("UI/UILayer")
	--UIViewMgr:ShowLayer(UILayer.Exclusive)
	self:SetBloodProgress()
	self.Text_Time:SetText(string.format("%.2f", self.QTELeftTime))
	-- self:PlayAnimation(self.DX_UI_TIPS_LOOP, 0, 0)
	-- self:PlayAnimation(self.EFF_UI_QTE_BTN_GUIDE_LOOP, 0, 0)

	self:PlayAnimation(self.Anim_Aoto_In)
	UIUtil.SetIsVisible(self.RightBtn, true)

	self.QTELeftTime = self.QTELeftTime + self.Anim_Aoto_In:GetEndTime()

	self:UpdateMapSequenceState(self.QTEStartSequence_SegId)
end

function QTEMainPanelView:OnHide()
	--UIViewMgr:RestoreLayer()
end

function QTEMainPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.RightBtn, self.OnRightClicked)
	-- UIUtil.AddOnClickedEvent(self, self.LeftBtn, self.OnLeftClicked)
end

function QTEMainPanelView:OnRegisterGameEvent()
end

function QTEMainPanelView:OnRegisterTimer()

end

function QTEMainPanelView:OnRegisterBinder()

end

function QTEMainPanelView:OnLeftClicked()
	self:PlayAnimation(self.EFF_UI_QTE_BTN_R_CLICK_ANIM)
	self:OnLeftOrRightClicked()
end

function QTEMainPanelView:OnRightClicked()
	-- self:PlayAnimation(self.EFF_UI_QTE_BTN_L_CLICK_ANIM)
	self:PlayAnimation(self.Anim_Click)
	-- if not self.ContestAnimPlayed then
	-- 	self:PlayAnimation(self.Anim_Contest)
	-- 	self.ContestAnimPlayed = true
	-- end
	self:OnLeftOrRightClicked()
end

function QTEMainPanelView:OnLeftOrRightClicked()
	if self.BloodPercent > self.BeginLerpThreshold then
		self.BloodPercent = FMath.Lerp(self.BloodPercent, 1.0, self.AddPerClick * self.LerpCoef)
	else
		self.BloodPercent = self.BloodPercent + self.AddPerClick
	end
	-- self.BloodPercent = FMath.Lerp(self.BloodPercent, 1.0, self.AddPerClick)
	self.BloodPercent = FMath.FMin(self.BloodPercent, 1.0)
end

function QTEMainPanelView:Tick(_, InDeltaTime)
	if self:IsFailed() then return end

	if self.GuideLeftTime > 0 then
		self.GuideLeftTime = self.GuideLeftTime - InDeltaTime
		if self.GuideLeftTime <= 0 then
			-- self:StopAnimation(self.EFF_UI_QTE_BTN_GUIDE_LOOP)
			-- self.GuideNode:SetVisibility(_G.UE.ESlateVisibility.Hidden)
			-- self.NormalNode:SetVisibility(_G.UE.ESlateVisibility.SelfHitTestInvisible)
			-- self:PlayAnimation(self.EFF_UI_QTE_BTN_R_CLICK_ANIM)
			-- self:PlayAnimation(self.EFF_UI_QTE_BTN_L_CLICK_ANIM)
			--self:PlayProgressAnim()
			--self:PlayAnimation(self.CurrentProgressAnim, 0, 0)

			self:PlayAnimation(self.Anim_Tips_Loop, 0, 0)
			UIUtil.SetIsVisible(self.RightBtn, true, true)
			self:PlayAnimation(self.Anim_Contest)
		end
		return
	end

	-- self:PlayProgressAnim()
	-- self.BloodPercent = self.BloodPercent - self.ProgressSpeed * InDeltaTime
	if self.BloodPercent < self.BeginLerpThreshold then
		self.BloodPercent = FMath.Lerp(self.BloodPercent, 0.0, self.ProgressSpeed * InDeltaTime * self.LerpCoef)
	else
		self.BloodPercent = self.BloodPercent - self.ProgressSpeed * InDeltaTime
	end
	self.BloodPercent = FMath.FMax(self.BloodPercent, 0.0)
	self.QTELeftTime = self.QTELeftTime - InDeltaTime

	self:SetBloodProgress()
	self.Text_Time:SetText(string.format("%.2f", self.QTELeftTime))
	if self:IsFailed() then
		-- send req to leave qte
		-- local majorStatComp = MajorUtil.GetMajor():GetStateComponent()
		-- majorStatComp:SetNetState(ProtoCommon.CommStatID.COMM_STAT_QTE, false, true)
	end
end

function QTEMainPanelView:PlayProgressAnim()
	local NextProgressAnim = nil
	if self.BloodPercent >= 0.99 then
		NextProgressAnim = self.EFF_UI_QTE_NLT_MAX_LOOP
	elseif self.BloodPercent >= 0.5 then
		NextProgressAnim = self.EFF_UI_QTE_NLT_MANY_LOOP
	else
		NextProgressAnim = self.EFF_UI_QTE_NLT_LESS_LOOP
	end

	if NextProgressAnim ~= self.CurrentProgressAnim then
		self:StopAnimation(self.CurrentProgressAnim)
		self.CurrentProgressAnim = NextProgressAnim
		self:PlayAnimation(self.CurrentProgressAnim, 0, 0)
	end
end

function QTEMainPanelView:SetBloodProgress()
	self.Bar_BlueRed:SetPercent(1.0-self.BloodPercent)

	-- ProgressCursorPanel in range (0, -1)
	local OldPos = UIUtil.CanvasSlotGetAlignment(self.ProgressCursorPanel)
	UIUtil.CanvasSlotSetAlignment(self.ProgressCursorPanel,
		_G.UE.FVector2D(-1.0+self.BloodPercent, OldPos.Y))

	OldPos = UIUtil.CanvasSlotGetAlignment(self.ProgressCursorPanel2)
		UIUtil.CanvasSlotSetAlignment(self.ProgressCursorPanel2,
			_G.UE.FVector2D(-1.0+self.BloodPercent, OldPos.Y))
end

function QTEMainPanelView:IsFailed()
	return self.QTELeftTime <= 0.0 or self.BloodPercent <= 0.02
end

---@param Params FEventParams
function QTEMainPanelView:OnActorStateChanged(Params)
	-- if not MajorUtil.IsMajor(Params.ULongParam1) then return end
    -- local majorStatComp = MajorUtil.GetMajor():GetStateComponent()
	-- if not Params.IntParam1 == ProtoCommon.CommStatID.COMM_STAT_QTE then return end
    -- if not majorStatComp:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_QTE) then
	--     if not self:IsFailed() then
	-- 		-- success!
	-- 		FLOG_INFO("QTE Success!")
	-- 	else
	-- 		-- failed
	-- 		FLOG_INFO("QTE faile!")
	-- 	end
	-- 	self:UpdateMapSequenceState(self.QTEEndSequence_SegId)
	-- 	UIViewMgr:HideView(UIViewID.QTEMain)
    -- end
end

function QTEMainPanelView:UpdateMapSequenceState(State)
	_G.PWorldMgr:LocalUpdateDynData(
		ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_MAP_SEQUENCE,
		self.MapSequenceActorId, State)
end

return QTEMainPanelView