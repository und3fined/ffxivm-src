---
--- Author: chunfengluo
--- DateTime: 2023-08-10 14:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIVewID = require("Define/UIViewID")
local MountVM = require("Game/Mount/VM/MountVM")
local MainPanelVM = require("Game/Main/MainPanelVM")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsID = require("Define/MsgTipsID")
local DataReportUtil = require("Utils/DataReportUtil")
local UIBinderSetButtonBrush = require("Binder/UIBinderSetButtonBrush")
local SideBarDefine = require("Game/Common/Frame/Define/CommonSelectSideBarDefine")
local LSTR = _G.LSTR
local MountMgr = _G.MountMgr
local prof_type = ProtoCommon.prof_type
local EnumRidePurposeType = ProtoRes.EnumRidePurposeType

local UpDownMaintainTime = 0.5

---@class MainMountPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDown UFButton
---@field BtnTransfer UFButton
---@field BtnUp UFButton
---@field ImgAbleLine UFImage
---@field PanelAble UFCanvasPanel
---@field PanelCall UFCanvasPanel
---@field PanelCalled UFCanvasPanel
---@field PanelDrive UFCanvasPanel
---@field PanelFlight UFCanvasPanel
---@field PanelMount UFCanvasPanel
---@field PanelRide UFCanvasPanel
---@field SkillAbleBtn01 SkillAbleBtnView
---@field SkillAbleBtn02 SkillAbleBtnView
---@field SkillAbleBtn03 SkillAbleBtnView
---@field SkillMountBtn SkillMountBtnView
---@field SkillMountSwitchBtn SkillMountSwitchBtnView
---@field SkillMusicBtn SkillMusicBtnView
---@field SkillProspectBtn01 SkillAbleBtnView
---@field SkillSprintMountDownBtn SkillSprintMountDownBtnView
---@field SkillSprintMountUpBtn SkillSprintMountUpBtnView
---@field AnimMountIn UWidgetAnimation
---@field AnimMountOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainMountPanelView = LuaClass(UIView, true)

function MainMountPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDown = nil
	--self.BtnTransfer = nil
	--self.BtnUp = nil
	--self.ImgAbleLine = nil
	--self.PanelAble = nil
	--self.PanelCall = nil
	--self.PanelCalled = nil
	--self.PanelDrive = nil
	--self.PanelFlight = nil
	--self.PanelMount = nil
	--self.PanelRide = nil
	--self.SkillAbleBtn01 = nil
	--self.SkillAbleBtn02 = nil
	--self.SkillAbleBtn03 = nil
	--self.SkillMountBtn = nil
	--self.SkillMountSwitchBtn = nil
	--self.SkillMusicBtn = nil
	--self.SkillProspectBtn01 = nil
	--self.SkillSprintMountDownBtn = nil
	--self.SkillSprintMountUpBtn = nil
	--self.AnimMountIn = nil
	--self.AnimMountOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainMountPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SkillAbleBtn01)
	self:AddSubView(self.SkillAbleBtn02)
	self:AddSubView(self.SkillAbleBtn03)
	self:AddSubView(self.SkillMountBtn)
	self:AddSubView(self.SkillMountSwitchBtn)
	self:AddSubView(self.SkillMusicBtn)
	self:AddSubView(self.SkillProspectBtn01)
	self:AddSubView(self.SkillSprintMountDownBtn)
	self:AddSubView(self.SkillSprintMountUpBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainMountPanelView:OnInit()
	--self.BtnRideMask_Control.IsAllowLongClick = true
	self.UpPressTime = 0
	self.DownPressTime = 0
	--self.bIsBtnGetOffEnabled = true

	--local TriggerTimeCfg = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GLOBAL_CFG_RIDE_PROBAR_TRIGGER_TIME , "Value")
	self.TriggerTime = 0.5
	--local OpenTimeCfg = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GLOBAL_CFG_RIDE_PROBAR_OPEN_TIME , "Value")
	self.OpenTime = 1.5
	local MountJumpLongClickTimeCfg = ClientGlobalCfg:FindValue(ProtoRes.client_global_cfg_id.GLOBAL_CFG_MOUNT_FLY_LONG_CLICK_TIME, "Value")
	self.MountJumpLongClickTime = MountJumpLongClickTimeCfg and MountJumpLongClickTimeCfg[1] / 1000 or 1

	self.AbleSkillMap = {
		[self.SkillAbleBtn01.ButtonIndex] = self.SkillAbleBtn01,
		[self.SkillAbleBtn02.ButtonIndex] = self.SkillAbleBtn02,
		[self.SkillAbleBtn03.ButtonIndex] = self.SkillAbleBtn03,
		[self.SkillProspectBtn01.ButtonIndex] = self.SkillProspectBtn01,
	}

	self.MountJumpLongClickTimer = nil

	rawset(self, "bMainMountPanel", true)	--技能按钮用于判断是否为坐骑技能
end

function MainMountPanelView:OnDestroy()

end

function MainMountPanelView:OnShow()
	self:UpdateMountViews()
	self:SetControlMountVtnVisibility()
end

function MainMountPanelView:OnHide()

end

function MainMountPanelView:OnRegisterUIEvent()
	UIUtil.AddOnPressedEvent(self, self.BtnDown, self.OnClickMountDownPressed)
	UIUtil.AddOnReleasedEvent(self, self.BtnDown, self.OnClickMountDownReleased)
	UIUtil.AddOnPressedEvent(self, self.BtnUp, self.OnClickMountUpPressed)
	UIUtil.AddOnReleasedEvent(self, self.BtnUp, self.OnClickMountUpReleased)
	UIUtil.AddOnClickedEvent(self, self.BtnTransfer, self.OnClickBtnTransfer)
	UIUtil.AddOnPressedEvent(self, self.SkillSprintMountUpBtn.BtnRun, self.OnMountUpPressed)
	UIUtil.AddOnReleasedEvent(self, self.SkillSprintMountUpBtn.BtnRun, self.OnMountUpReleased)
	UIUtil.AddOnPressedEvent(self, self.SkillSprintMountDownBtn.BtnRun, self.OnMountDownClick)
end

function MainMountPanelView:OnRegisterGameEvent()
	local EventID = require("Define/EventID")
	self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnModuleOpen)
	self:RegisterGameEvent(EventID.OnShowMountPanel, self.OnShowMountPanel)
    -- 坐骑列表打开的时候播放坐骑按钮的动画会暂停播放并累积，重新更新一下坐骑按钮的状态
	-- self:RegisterGameEvent(EventID.MainPanelActive, self.OnGameEventMainPanelActive)
	self:RegisterGameEvent(EventID.CharacterLanded, self.UpdateMountViewsByLanded)
	self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnEventMajorProfSwitch)
	self:RegisterGameEvent(EventID.MajorLevelUpdate, self.OnGameEventMajorLevelUpdate)
	self:RegisterGameEvent(EventID.MountAssembleAllEnd, self.UpdateMountViews)
	self:RegisterGameEvent(EventID.MajorCreate, self.UpdateMountViews)
	self:RegisterGameEvent(EventID.FightSkillPanelShowed, self.OnFightSkillPanelShowed)

	--技能事件转发
	self:RegisterGameEvent(EventID.SkillReplace, self.OnSkillReplace)
	self:RegisterGameEvent(EventID.MajorUseSkill, self.OnMajorUseSkill)
	--TODO[chaooren] 没听说坐骑技能要用到蓄力，后就用到了就把注释去掉
	-- self:RegisterGameEvent(EventID.StorageStart, self.StartStorageAnim)
	-- self:RegisterGameEvent(EventID.StorageEnd, self.StopStorageAnim)

	--设置项
	self:RegisterGameEvent(EventID.MountBgmSettingChange, self.OnBgmStateChange)
end

function MainMountPanelView:OnRegisterBinder()
	local Binders = {
		{ "CurRideResID", UIBinderValueChangedCallback.New(self, nil, self.UpdateMountViews) },
		{ "PlayActionList", UIBinderValueChangedCallback.New(self, nil, self.UpdateMountViews) },
		--{ "IsInRide", UIBinderSetIsVisible.New(self, self.PanelMount) }, --注释，统一MainPanelView:ShowMountPanel处理
		{ "IsInRide", UIBinderSetIsVisible.New(self, self.SkillMusicBtn) },
		{ "IsMajorInFly", UIBinderValueChangedCallback.New(self, nil, self.OnIsMajorInFlyChange)},
		{ "IsInOtherRide", UIBinderValueChangedCallback.New(self, nil, self.OnIsInOtherRideChange)},
		{ "IsInRide", UIBinderSetIsVisible.New(self, self.PanelCall) },
		--{ "IsMainMountCallButtonVisible", UIBinderSetIsVisible.New(self, self.PanelCall)},
        { "IsBtnTransferVisible", UIBinderSetIsVisible.New(self, self.BtnTransfer)},
		{ "IsJumpBtnVisible", UIBinderSetIsVisible.New(self, self.SkillSprintMountUpBtn)},
		{ "IsFlyBtnVisible", UIBinderSetIsVisible.New(self, self.SkillSprintMountDownBtn)},
		{ "IsPanelFlyingVisible", UIBinderSetIsVisible.New(self, self.PanelFlight)},
		{ "IsPanelOtherRideVisible", UIBinderSetIsVisible.New(self, self.PanelRide)},
		{ "CombatPanelState", UIBinderSetIsVisible.New(self, self.SkillMountBtn, true)},

		--{ "NotesVisible", UIBinderSetIsVisible.New(self, self.BtnGather,false,true)},
		--{ "BtnGatherIconPath", UIBinderSetButtonBrush.New(self, self.BtnGather, nil) },
		--{ "FlyHigh", UIBinderValueChangedCallback.New(self, nil, self.OnFlyHighStateChange) },
		{ "AllowFlyRide", UIBinderValueChangedCallback.New(self, nil, self.OnUpdateAllowFlyRide) },
		--{ "IsMountFall", UIBinderSetIsChecked.New(self, self.ToggleBtnRemove2, false)}
	}
	self:RegisterBinders(MountVM, Binders)
end

function MainMountPanelView:OnIsMajorInFlyChange()
	local IsMajorInFly = MountVM.IsMajorInFly
	local IsInOtherRide = MountVM.IsInOtherRide
    --MountVM.IsBtnTransferVisible = not IsMajorInFly and not IsInOtherRide
	MountVM.IsFlyBtnVisible = not IsMajorInFly and not IsInOtherRide
	MountVM.IsPanelOtherRideVisible = not IsMajorInFly and IsInOtherRide
	MountVM.IsPanelFlyingVisible = IsMajorInFly
end

function MainMountPanelView:OnIsInOtherRideChange()
	local IsMajorInFly = MountVM.IsMajorInFly
	local IsInOtherRide = MountVM.IsInOtherRide
    --MountVM.IsBtnTransferVisible = not IsMajorInFly and not IsInOtherRide
	MountVM.IsFlyBtnVisible = not IsMajorInFly and not IsInOtherRide
	MountVM.IsJumpBtnVisible = not IsInOtherRide
	MountVM.IsPanelOtherRideVisible = not IsMajorInFly and IsInOtherRide
end

function MainMountPanelView:UpdateMountViews()
	if MountVM.CurRideResID ~= 0 then 
		self:SetMountSkill()
	end
	self:ShowProfView()
end

function MainMountPanelView:UpdateMountViewsByLanded()
	self:ShowProfView()
end

function MainMountPanelView:OnMountNextSeat()
	MountMgr:SendMountNextSeat()
end

function MainMountPanelView:OnPressButtonRide()
	self.ButtonRideEnableCall = true
	if MountMgr:GetPurposeType(MountVM.CurRideResID) ~= EnumRidePurposeType.Call then
		return
	end
	self.RideProbarTimer = TimerMgr:AddTimer(self, self.BeginRideProbar, self.TriggerTime)
	self.OpenMountPanelTimer = TimerMgr:AddTimer(self, self.OnLongClickButtonRide, self.OpenTime)
	--self:BeginRideProbar()
end

function MainMountPanelView:OnReleaseButtonRide()
	TimerMgr:CancelTimer(self.RideProbarTimer)
	self:EndRideProbar()
end

function MainMountPanelView:OnLongClickButtonRide()
	self:EndRideProbar()
	local CommSideBarUtil = require("Utils/CommSideBarUtil")
	DataReportUtil.ReportMountInterSystemFlowData(1, 3)
	CommSideBarUtil.ShowSideBarByType(SideBarDefine.PanelType.EasyToUse, SideBarDefine.EasyToUseTabType.Mount)
end

function MainMountPanelView:OnClickMountJump()
	local MajorController = MajorUtil.GetMajorController()
	if MajorController == nil then return end
	MajorController:NewJumpStart()
	MajorController:NewJumpEnd()

	local MountJumpLongClickFunction = function()
		TimerMgr:CancelTimer(self.MountJumpLongClickTimer)
		self:TryFly()
	end

	self.MountJumpLongClickTimer = TimerMgr:AddTimer(self, MountJumpLongClickFunction, self.MountJumpLongClickTime)
end

function MainMountPanelView:OnReleaseMountJump()
	TimerMgr:CancelTimer(self.MountJumpLongClickTimer)
end

-- 根据相关功能是否解锁显示飞行按钮状态
function MainMountPanelView:UpdateFlyLimitState()

	-- 风脉泉
	local bFlyLimitedByAetherCurrent = not MountVM.AllowFlyRide
	-- 陆行鸟运输中
	local bIsChocoboTransporting = _G.ChocoboTransportMgr:GetIsTransporting()
	if bFlyLimitedByAetherCurrent or bIsChocoboTransporting then
		--self.BtnFlighting:SetRenderOpacity(0.4)
		--UIUtil.SetRenderOpacity(self.BtnFlighting, 0.4)
		UIUtil.SetBackgroundColor(self.BtnFlighting, 1, 1, 1, 0.4)
	else
		--self.BtnFlighting:SetRenderOpacity(1)
		--UIUtil.SetRenderOpacity(self.BtnFlighting, 1)
		UIUtil.SetBackgroundColor(self.BtnFlighting, 1, 1, 1, 1)
	end
end

function MainMountPanelView:OnClickMountFly()
	if not _G.AetherCurrentsMgr:IsCurMapCanFlyLimitByAetherCurrent() then
		local TipsContent = LSTR(1090072)
        MsgTipsUtil.ShowTips(TipsContent)
		return
	end
	if MountVM.bFlyLimitedByMap then
		MsgTipsUtil.ShowTips(LSTR(1090051))
		return
	end
	self:TryFly()
end

function MainMountPanelView:TryFly()
	if not MountVM.AllowFlyRide then
		return
	end
	local MajorController = MajorUtil.GetMajorController()
	if MajorController == nil then return end
	MajorController:MountFly()
end

function MainMountPanelView:OnClickMountDownPressed()
	local MajorController = MajorUtil.GetMajorController()
	TimerMgr:CancelTimer(self.MountUpTimer)
	TimerMgr:CancelTimer(self.MountDownTimer)
	self.DownPressTime = TimeUtil.GetServerTimeMS()
	MajorController:DoJumpStart(true)
end

function MainMountPanelView:OnClickMountDownReleased()
	local Time = UpDownMaintainTime - (TimeUtil.GetServerTimeMS() - self.DownPressTime) / 1000
	local function JumpEnd()
		local MajorController = MajorUtil.GetMajorController()
		if MajorController ~= nil then
			MajorController:JumpEnd()
		end
	end
	if Time > 0 then
		self.MountDownTimer = TimerMgr:AddTimer(nil, JumpEnd, Time)
	else
		JumpEnd()
	end
end

function MainMountPanelView:OnClickMountUpPressed()
	local MajorController = MajorUtil.GetMajorController()
	TimerMgr:CancelTimer(self.MountUpTimer)
	TimerMgr:CancelTimer(self.MountDownTimer)
	self.UpPressTime = TimeUtil.GetServerTimeMS()
	MajorController:JumpStart()
end

function MainMountPanelView:OnClickMountUpReleased()
	local Time = UpDownMaintainTime - (TimeUtil.GetServerTimeMS() - self.UpPressTime) / 1000
	local function JumpEnd()
		local MajorController = MajorUtil.GetMajorController()
		if MajorController ~= nil then
			MajorController:JumpEnd()
		end
	end
	if Time > 0 then
		self.MountUpTimer = TimerMgr:AddTimer(nil, JumpEnd, Time)
	else
		JumpEnd()
	end
end

function MainMountPanelView:OnClickBtnTransfer()
	local MainPanel =_G.UIViewMgr:FindView(_G.UIViewID.MainPanel)
	if MainPanel == nil then return end

	MainPanel:ShowMountPanel(false)
end

function MainMountPanelView:OnMountUpPressed()
	local MoveComp = MajorUtil.GetMajor():GetMovementComponent()
	if MoveComp and MoveComp:IsFalling() then
		local MajorController = MajorUtil.GetMajorController()
		if MajorController == nil then return end
		MajorController:MountFly()
		return
	end

	if MountVM.IsMajorInFly then
		self:OnClickMountUpPressed()
		return
	end

	local MajorController = MajorUtil.GetMajorController()
	if MajorController == nil then return end
	MajorController:NewJumpStart()
	MajorController:NewJumpEnd()

	local MountJumpLongClickFunction = function()
		_G.TimerMgr:CancelTimer(self.MountJumpLongClickTimer)
		MajorController:MountFly()
	end

	self.MountJumpLongClickTimer = _G.TimerMgr:AddTimer(self, MountJumpLongClickFunction, self.MountJumpLongClickTime)
end

function MainMountPanelView:OnMountUpReleased()
	if MountVM.IsMajorInFly then
		self:OnClickMountUpReleased()
		return
	end

	_G.TimerMgr:CancelTimer(self.MountJumpLongClickTimer)
end

function MainMountPanelView:OnMountDownClick()
	if not _G.AetherCurrentsMgr:IsCurMapCanFlyLimitByAetherCurrent() then
        MsgTipsUtil.ShowTips(LSTR(1090050))
		return
	end
	if MountVM.bFlyLimitedByMap then
		MsgTipsUtil.ShowTips(LSTR(1090051))
		return
	end

	local MajorController = MajorUtil.GetMajorController()
	if MajorController == nil then return end
	MajorController:MountFly()
end

function MainMountPanelView:OnUpdateAllowFlyRide()
	self:UpdateMountViews()
	if MountVM.AllowFlyRide then
		UIUtil.SetOpacity(self.SkillSprintMountDownBtn.Icon_Skill, 1)
	else
		UIUtil.SetOpacity(self.SkillSprintMountDownBtn.Icon_Skill, 0.5)
	end
end

function MainMountPanelView:OnModuleOpen(ModuleID)
	if ModuleID == ProtoCommon.ModuleID.ModuleIDMount then
		self:SetControlMountVtnVisibility()
		self:UpdateMountViews()
	end
end

function MainMountPanelView:OnShowMountPanel()
	self:SetControlMountVtnVisibility()
end

function MainMountPanelView:SetControlMountVtnVisibility()
	MountVM.IsControlMountBtnVisible = not MainPanelVM.IsMountPanelVisible and _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMount)
end

function MainMountPanelView:ShowProfView()
	local ProfID = MajorUtil.GetMajorProfID()
	if ProfID == prof_type.PROF_TYPE_MINER or ProfID ==  prof_type.PROF_TYPE_BOTANIST then
		MountVM:SetNoteBookVisible(true)
		--self:SetProfSkillView()
		--屏蔽骑乘在状态下的勘探
		UIUtil.SetIsVisible(self.SkillProspectBtn01, false)
	elseif ProfID == ProtoCommon.prof_type.PROF_TYPE_FISHER then
		MountVM:SetNoteBookVisible(true)
		UIUtil.SetIsVisible(self.SkillProspectBtn01, false)
	else
		MountVM:SetNoteBookVisible(false)
		UIUtil.SetIsVisible(self.SkillProspectBtn01, false)
	end
end

function MainMountPanelView:OnEventMajorProfSwitch(Params)
	self:ShowProfView()
	self:SetMountSkill()
end

function MainMountPanelView:OnGameEventMajorLevelUpdate()
	self:SetMountSkill()
end

function MainMountPanelView:SetProfSkillView()
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
	if LogicData == nil then
		FLOG_ERROR("MainMountPanelView Major LogicData is nil")
		UIUtil.SetIsVisible(self.SkillProspectBtn01, false)
	else
		local SkillID = LogicData:GetBtnSkillID(4)
		if SkillID then
			self.SkillProspectBtn01.EntityID = MajorEntityID
			self.SkillProspectBtn01.bMajor = true
			--_G.SkillLogicMgr:SetBtnViewPtr(MajorEntityID, self.SkillProspectBtn01.ButtonIndex, self.SkillProspectBtn01)
			LogicData:InitSkillMap(self.SkillProspectBtn01.ButtonIndex, SkillID)
			UIUtil.SetIsVisible(self.SkillProspectBtn01, true,true)
			self.SkillProspectBtn01:OnShow()
		end
	end
end

function MainMountPanelView:OnClickBtnBook() 
	local ProfID = MajorUtil.GetMajorProfID()
	if ProfID then
		if ProfID == prof_type.PROF_TYPE_MINER or ProfID == prof_type.PROF_TYPE_BOTANIST then
			_G.UIViewMgr:ShowView(_G.UIViewID.GatheringLogMainPanelView)
		elseif ProfID == prof_type.PROF_TYPE_FISHER then
            DataReportUtil.ReportSystemFlowData("FishingNotesInfo", 1, 1)
			_G.UIViewMgr:ShowView(_G.UIViewID.FishInghole)
		end
	end
end

function MainMountPanelView:SetMountSkill()
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
	for i = 1, 3 do
		if LogicData ~= nil and self["SkillAbleBtn0"..i] ~= nil then
			local SkillBtn = self["SkillAbleBtn0"..i]
			if MountVM.PlayActionList and MountVM.PlayActionList[i] then
				local ActionStringSplit = string.split(MountVM.PlayActionList[i], ",")
				local Action = tonumber(ActionStringSplit[1])
				if Action ~= nil then
					SkillBtn.EntityID = MajorEntityID
					SkillBtn.bMajor = true
					--_G.SkillLogicMgr:SetBtnViewPtr(MajorEntityID, SkillBtn.ButtonIndex, SkillBtn)
					LogicData:InitSkillMap(SkillBtn.ButtonIndex, Action)
					UIUtil.SetIsVisible(SkillBtn, true,true)
					SkillBtn:OnShow()
				else
					UIUtil.SetIsVisible(SkillBtn, false)
				end

			else
				UIUtil.SetIsVisible(SkillBtn, false)
			end
		end
	end
end

function MainMountPanelView:OnBgmStateChange(Params)
	self.SkillMusicBtn:SetButtonState(Params)
end

--技能按钮事件转发
function MainMountPanelView:OnSkillReplace(Params)
	local AbleView = self.AbleSkillMap[Params.SkillIndex]
	if AbleView then
		local ValidSkill = Params.SkillID ~= nil and Params.SkillID ~= 0
		if AbleView:GetIsShowView() then
			if not ValidSkill then
				AbleView:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
			else
				AbleView:OnSkillReplace(Params)
			end
		elseif ValidSkill then
			AbleView:SetVisibility(_G.UE.ESlateVisibility.Visible)
		end
	end
end

function MainMountPanelView:OnMajorUseSkill(Params)
	local SkillBtn = self.AbleSkillMap[Params.ULongParam1]
	if SkillBtn and SkillBtn:GetIsShowView() then
		SkillBtn:OnGameEventMajorUseSkill(Params)
	end
end

function MainMountPanelView:OnSimulateMajorSkillCast(Index)
	if Index > 0 then
		local SkillBtn = self.AbleSkillMap[Index]
		if SkillBtn and SkillBtn:GetIsShowView() then
			SkillBtn:OnPrepareCastSkill()
			SkillBtn:OnCastSkill()
		end
	end
end

function MainMountPanelView:OnSkillCastFailed(Index)
	if Index > 0 then
		local SkillBtn = self.AbleSkillMap[Index]
		if SkillBtn then
			SkillBtn:SkillCastFailed()
		end
	end
end
--技能按钮事件转发END

function MainMountPanelView:OnFightSkillPanelShowed(InFight)
	if InFight then
		UIUtil.SetIsVisible(self.SkillMusicBtn, false)
	else
		if MountVM.IsInRide then
			UIUtil.SetIsVisible(self.SkillMusicBtn, true)
		end
	end

	UIUtil.SetIsVisible(self.PanelAble, not InFight)
end

function MainMountPanelView:StopInOutAnim()
	self:StopAnimation(self.AnimMountIn)
	self:StopAnimation(self.AnimMountOut)
end

return MainMountPanelView