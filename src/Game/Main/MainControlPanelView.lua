--
-- Author: anypkvcai
-- Date: 2020-09-01 16:23:25
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIUtil = require("Utils/UIUtil")

local LoginMgr = require("Game/Login/LoginMgr")
local EventID = require("Define/EventID")

local prof_type = ProtoCommon.prof_type
local ProfUtil = require("Game/Profession/ProfUtil")
local EmotionMgr = require("Game/Emotion/EmotionMgr")
local ProtoRes = require("Protocol/ProtoRes")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")

local SkillMainCfg = require("TableCfg/SkillMainCfg")
local CombatPanelBuffCfg = require("TableCfg/CombatPanelBuffCfg")

local DataReportUtil = require("Utils/DataReportUtil")
local SkillUtil = require("Utils/SkillUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgTipsID = require("Define/MsgTipsID")

local MainPanelVM = require("Game/Main/MainPanelVM")
local MountVM = require("Game/Mount/VM/MountVM")
local MainControlPanelVM = require("Game/Main/VM/MainControlPanelVM")

local UIBinderSetBrushFromAssetPath =  require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsVisibleByBit = require("Binder/UIBinderSetIsVisibleByBit")

local SwitchPeaceSkillTime = 5 --5秒后切换回非战斗状态技能组
local FindGatherPointRealIndex = SkillCommonDefine.FindGatherPointRealIndex

---@class MainControlPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Anim_song_screen_particle UFCanvasPanel
---@field BtnSwitch_1 UFButton
---@field ButtonTarget UFButton
---@field ExtraSkillBtn ExtraSkillBtnView
---@field FightPanel UCanvasPanel
---@field FindGather SkillAbleBtnView
---@field IconTarget UFImage
---@field IconTargetBg UFImage
---@field ImgSwitch_1 UFImage
---@field MainProSkill_UIBP MainProSkillView
---@field NewMainSkill_UIBP NewMainSkillView
---@field PanelBookBtn UFCanvasPanel
---@field PanelSprint UFCanvasPanel
---@field PanelTarget UFCanvasPanel
---@field PeacelPanel UCanvasPanel
---@field Schedule FishNewTimeItemView
---@field SkillGenAttackBtn_UIBP SkillGenAttackBtnView
---@field SkillMountBtn SkillMountBtnView
---@field SkillSprintDownBtn SkillSprintDownBtnView
---@field SkillSprintUpBtn SkillSprintUpBtnView
---@field SkillSwithcer UWidgetSwitcher
---@field TestParentCanvas UFCanvasPanel
---@field require_remove UFCanvasPanel
---@field Anim_Fight UWidgetAnimation
---@field Anim_Peacel UWidgetAnimation
---@field Anim_song_Screen UWidgetAnimation
---@field AnimMountIn11 UWidgetAnimation
---@field AnimMountOut11 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainControlPanelView = LuaClass(UIView, true)

function MainControlPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Anim_song_screen_particle = nil
	--self.BtnSwitch_1 = nil
	--self.ButtonTarget = nil
	--self.ExtraSkillBtn = nil
	--self.FightPanel = nil
	--self.FindGather = nil
	--self.IconTarget = nil
	--self.IconTargetBg = nil
	--self.ImgSwitch_1 = nil
	--self.MainProSkill_UIBP = nil
	--self.NewMainSkill_UIBP = nil
	--self.PanelBookBtn = nil
	--self.PanelSprint = nil
	--self.PanelTarget = nil
	--self.PeacelPanel = nil
	--self.Schedule = nil
	--self.SkillGenAttackBtn_UIBP = nil
	--self.SkillMountBtn = nil
	--self.SkillSprintDownBtn = nil
	--self.SkillSprintUpBtn = nil
	--self.SkillSwithcer = nil
	--self.TestParentCanvas = nil
	--self.require_remove = nil
	--self.Anim_Fight = nil
	--self.Anim_Peacel = nil
	--self.Anim_song_Screen = nil
	--self.AnimMountIn11 = nil
	--self.AnimMountOut11 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainControlPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ExtraSkillBtn)
	self:AddSubView(self.FindGather)
	self:AddSubView(self.MainProSkill_UIBP)
	self:AddSubView(self.NewMainSkill_UIBP)
	self:AddSubView(self.Schedule)
	self:AddSubView(self.SkillGenAttackBtn_UIBP)
	self:AddSubView(self.SkillMountBtn)
	self:AddSubView(self.SkillSprintDownBtn)
	self:AddSubView(self.SkillSprintUpBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY

    --self.UseItemBtn.JoyStickCancelPanel = self.CancelJoyStick
    --self.Sprint:RegisterNormalCDObj(self, self.OnSkillCDUpdate)
    -- self.FindGather:RegisterNormalCDObj(self, self.OnSkillCDUpdate)
end


--ProfID = 前缀
local SpecialProf = {[prof_type.PROF_TYPE_FISHER] = "Fish"}

--后缀
local SkillBtnClick = "SkillBtnClick"
local ViewShow = "ViewShow"
local ForceFight = "ForceFight"
local ForcePeace = "ForcePeace"
local SwitchProf = "SwitchProf"
local FuncPair = {SkillBtnClick, ViewShow, ForceFight, ForcePeace, SwitchProf}
--FunctionName = string.format("%s_%s", 前缀, 后缀)

function MainControlPanelView:GetProfControlFuncs(ProfID)
    if self.ProfFuncs then
        return self.ProfFuncs
    end
    local ProfSkillPanelShowHideFunc = {}
    for Prof, Prefix in pairs(SpecialProf) do
        ProfSkillPanelShowHideFunc[Prof] = {}
        for _, FuncName in ipairs(FuncPair) do
            ProfSkillPanelShowHideFunc[Prof][FuncName] = self[string.format("%s_%s", Prefix, FuncName)]
        end
    end
    local ProfSkillPanelShowHideFuncMetaTable = {__index = function(_, InProfID)
        local FuncPrefix = nil
        if ProfUtil.IsGpProf(InProfID) then
            FuncPrefix = "GP"
        elseif ProfUtil.IsCrafterProf(InProfID) then
            FuncPrefix = "Crafter"
        elseif ProfUtil.IsCombatProf(InProfID) then
            FuncPrefix = "Combat"
        end

        if FuncPrefix then
            local Result = {}
            for _, FuncName in ipairs(FuncPair) do
                Result[FuncName] = self[string.format("%s_%s", FuncPrefix, FuncName)]
            end
            return Result
        end
    end}
    setmetatable(ProfSkillPanelShowHideFunc, ProfSkillPanelShowHideFuncMetaTable)

    self.ProfFuncs = ProfSkillPanelShowHideFunc[ProfID] or {}
    return self.ProfFuncs
end


function MainControlPanelView:GetProfControlFunc(ProfID, FuncName)
    local Funcs = self:GetProfControlFuncs(ProfID)
    if Funcs then
        return Funcs[FuncName]
    end
end


function MainControlPanelView:OnInit()
    --UIUtil.SetIsVisible(self.Btn_Joystick, false)
    --self.ButtonJump.OnPressed

    local ProtoRes = require("Protocol/ProtoRes")
    local ModuleType = ProtoRes.module_type

    --if not LoginMgr:IsModuleSwitchOn(ModuleType.MODULE_GM) then
    --	UIUtil.SetIsVisible(self.ButtonSwitch, false)
    --end

    if not LoginMgr:IsModuleSwitchOn(ModuleType.MODULE_JUMP) then
        UIUtil.SetIsVisible(self.SkillSprintUpBtn, false)
    end

    --if not LoginMgr:IsModuleSwitchOn(ModuleType.MODULE_BAG) then
    --	UIUtil.SetIsVisible(self.ButtonBackpack, false)
    --end
    self.SwitchPeaceTimer = 0
    --self.FightState = false

    self.KeepSwitchFight = false

    self.MajorEntityID = 0
end

function MainControlPanelView:OnDestroy()

end

function MainControlPanelView:OnShow()

    self.FightState = nil
    --空跑一次，缓存职业对应函数列表
    self.ProfFuncs = nil
    local ProfID = MajorUtil.GetMajorProfID()
    self:GetProfControlFuncs(ProfID)

    self:OnSkillLimitCancelBtnClick()
    _G.EventMgr:SendEvent(EventID.SkillLimitCancelBtnClick)

    local Func = self:GetProfControlFunc(ProfID, ViewShow)
    if Func then
        Func(self, true)
    end

    self:SetDefaultBtnSwitchTips(ProfID)

    self:CheckButtonTargetShow()

    self.BtnSwitch_1:SetIsDisabledState(true)
end

function MainControlPanelView:OnHide()
    self:StopAnimation(self.Anim_Fight)
    self:StopAnimation(self.Anim_Peacel)
    self.ProfFuncs = nil
end

function MainControlPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.ButtonTarget, self.OnClickButtonTarget)
    SkillUtil.RegisterPressScaleEvent(self, self.ButtonTarget, SkillCommonDefine.SkillBtnClickFeedback)
    UIUtil.AddOnClickedEvent(self, self.BtnSwitch_1, self.OnClickBtnSwitch)
    SkillUtil.RegisterPressScaleEvent(self, self.BtnSwitch_1, SkillCommonDefine.SkillBtnClickFeedback)
end

function MainControlPanelView:OnRegisterGameEvent()

    self:RegisterGameEventByProf(MajorUtil.GetMajorProfID())

    self:RegisterGameEvent(EventID.SkillBtnClick, self.OnSkillBtnClick)

    --TODO 临时代码执行副本切换OnShow
    self:RegisterGameEvent(EventID.MajorCreate, self.OnShow)

    --强制展开技能组的开关；别的系统可以直接重用OnForceFightSkillTrue/False这2个函数
    self:RegisterGameEvent(EventID.ForceFightPanel, self.OnForceSwitchFight)
    self:RegisterGameEvent(EventID.ForcePeacePanel, self.OnForceSwitchPeace)

    self:RegisterGameEvent(EventID.SwitchFightPanel, self.OnExpandSkillView)
    self:RegisterGameEvent(EventID.SwitchPeacePanel, self.OnReleaseSkillView)

    self:RegisterGameEvent(EventID.SkillLimitEntranceClick, self.OnSkillLimitEntranceClick)
    self:RegisterGameEvent(EventID.SkillLimitCancelBtnClick, self.OnSkillLimitCancelBtnClick)
    self:RegisterGameEvent(_G.EventID.SkillLimitDel, self.OnSkillLimitDel)

    self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnEventMajorProfSwitch)

    self:RegisterGameEvent(EventID.FixedFunctionPanelShowed, self.OnFixedFunctionPanelShowed)

    self:RegisterGameEvent(EventID.SkillSpectrum_BardAnim, self.OnCastBardAnim)

	self:RegisterGameEvent(EventID.PWorldSkillTip, self.OnPWorldSkillTip)
	self:RegisterGameEvent(EventID.ActorReviveNotify,self.OnGameEventActorReviveNotify)	--角色复活
    
    --技能解锁
    self:RegisterGameEvent(EventID.SkillUnLockView, self.SkillUnLockViewShow)

    self:RegisterGameEvent(EventID.CastLimitSkill, self.OnCastLimitSkill)
    self:RegisterGameEvent(EventID.RemoveLimitSkill, self.OnRemoveLimitSkill)

    self:RegisterGameEvent(EventID.MajorEntityIDUpdate, self.OnMajorEntityIDUpdate)
	self:RegisterGameEvent(EventID.SkillReplace, self.OnSkillReplace)

    self:RegisterGameEvent(EventID.EnterGatherState, self.OnEnterGatherState)
    self:RegisterGameEvent(EventID.ExitGatherState, self.OnExitGatherState)
    self:RegisterGameEvent(EventID.EnterFishStatus, self.OnEnterFishStatus)
    self:RegisterGameEvent(EventID.ExitFishStatus, self.OnExitFishStatus)

    self:RegisterGameEvent(EventID.MajorUpdateBuff, self.OnMajorUpdateBuff)
    self:RegisterGameEvent(EventID.MajorRemoveBuff, self.OnMajorRemoveBuff)
    
end

function MainControlPanelView:RegisterGameEventByProf(ProfID)
    if ProfUtil.IsCombatProf(ProfID) then
        self:RegisterGameEvent(EventID.NetStateUpdate, self.OnNetStateUpdate)
    else
        self:UnRegisterGameEvent(EventID.NetStateUpdate, self.OnNetStateUpdate)
    end
end

function MainControlPanelView:OnRegisterTimer()

end

function MainControlPanelView:OnRegisterBinder()

    self:PostSkillEntityChange(_G.PWorldMgr.MajorEntityID)
    local UIBinderSetIsVisibleByBitData = {MaxIndex = 0}
    local MainPanelBinders = {
		{ "NotesVisible", UIBinderSetIsVisible.New(self, self.BtnFishingNotes,false,true)},
		{ "IconBook", UIBinderSetBrushFromAssetPath.New(self, self.IconBook)},
        { "IsMountPanelVisible", UIBinderSetIsVisibleByBit.New(self, self.PanelSprint, UIBinderSetIsVisibleByBitData, true)},
	}
	self:RegisterBinders(MainPanelVM, MainPanelBinders)

    local UIBinderSetGenAttackIsVisibleByBitData = {MaxIndex = 0}
    local MountBinders = {
        { "IsPanelFlyingVisible", UIBinderSetIsVisibleByBit.New(self, self.SkillGenAttackBtn_UIBP, UIBinderSetGenAttackIsVisibleByBitData, true)},
        { "IsInOtherRide", UIBinderSetIsVisibleByBit.New(self, self.SkillGenAttackBtn_UIBP, UIBinderSetGenAttackIsVisibleByBitData, true)},
        { "IsControlMountBtnVisible", UIBinderSetIsVisible.New(self, self.SkillMountBtn)},
    }
    self:RegisterBinders(MountVM, MountBinders)

    local Binders = {
        { "bLimitCastState",  UIBinderSetIsVisible.New(self, self.BtnSwitch_1, false, true)},
        { "bLimitCastState",  UIBinderSetIsVisibleByBit.New(self, self.PanelSprint, UIBinderSetIsVisibleByBitData)},
        { "BtnSwitchIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgSwitch_1)},
        { "SkillSprintVisible",  UIBinderSetIsVisibleByBit.New(self, self.PanelSprint, UIBinderSetIsVisibleByBitData)},
        { "LimitGenAttackVisible",  UIBinderSetIsVisibleByBit.New(self, self.SkillGenAttackBtn_UIBP, UIBinderSetGenAttackIsVisibleByBitData)},
        { "BGIcon_1", UIBinderSetBrushFromAssetPath.New(self, self.SkillGenAttackBtn_UIBP.ImgBtnBase)},
        { "BGIcon_2", UIBinderSetBrushFromAssetPath.New(self, self.SkillSprintUpBtn.ImgUp)},
        { "BGIcon_3", UIBinderSetBrushFromAssetPath.New(self, self.SkillSprintDownBtn.ImgUp)},
    }

    if _G.FishMgr:IsInFishState() then
        MainControlPanelVM:SetBtnSwitchTips(MsgTipsID.CombatBtnSwitchDisable_Fish)
        MainControlPanelVM.SkillSprintVisible = false
    elseif _G.GatherMgr:IsGatherState() then
        MainControlPanelVM:SetBtnSwitchTips(MsgTipsID.CombatBtnSwitchDisable_Gather)
        MainControlPanelVM.SkillSprintVisible = false
    else
        MainControlPanelVM:SetBtnSwitchTips(0)
        MainControlPanelVM.SkillSprintVisible = true
    end

    self:RegisterBinders(MainControlPanelVM, Binders)
end

function MainControlPanelView:OnClickBtnSwitch()
    local TipsID = MainControlPanelVM:GetBtnSwitchTips()
    if TipsID > 0 then
        MsgTipsUtil.ShowTipsByID(TipsID)
        return
    end

    self:ResetSwitchPeaceTimer()
    if self.FightState then
        self:OnSwitchPeaceSkill()
    else
        self:OnSwitchFightSkill()
    end
end

function MainControlPanelView:OnEnterGatherState()
    MainControlPanelVM:SetBtnSwitchTips(MsgTipsID.CombatBtnSwitchDisable_Gather)
    MainControlPanelVM.SkillSprintVisible = false
end

function MainControlPanelView:OnExitGatherState()
    MainControlPanelVM:SetBtnSwitchTips(0)
    MainControlPanelVM.SkillSprintVisible = true
end

function MainControlPanelView:OnEnterFishStatus()
    MainControlPanelVM:SetBtnSwitchTips(MsgTipsID.CombatBtnSwitchDisable_Fish)
    MainControlPanelVM.SkillSprintVisible = false
end

function MainControlPanelView:OnExitFishStatus()
    MainControlPanelVM:SetBtnSwitchTips(0)
    MainControlPanelVM.SkillSprintVisible = true
end

function MainControlPanelView:OnGameEventActorReviveNotify(Params)
	local EntityID = Params.ULongParam1
    if EntityID == MajorUtil.GetMajorEntityID() then
        _G.EventMgr:SendEvent(EventID.SkillLimitCancelBtnClick)
        -- self.NewMainSkill_UIBP:OnSkillLimitCancelBtnClick()
        -- self:OnSkillLimitCancelBtnClick()
    end
end

function MainControlPanelView:OnMajorEntityIDUpdate(Params)
    if self.MajorEntityID ~= Params.ULongParam1 then
        self:PostSkillEntityChange(Params.ULongParam1)
    end
end

function MainControlPanelView:PostSkillEntityChange(EntityID)
    self.MajorEntityID = EntityID
    local MajorLogicData = SkillLogicMgr.MajorLogicData
    local MapType = MajorLogicData and MajorLogicData.MapType
    for _, value in ipairs(self.SubViews) do
        if value["OnEntityIDUpdate"] ~= nil then
            value:OnEntityIDUpdate(EntityID, true, MapType)
        end
    end
end

function MainControlPanelView:OnClickButtonTarget()
    local Major = _G.UE.UActorManager:Get():GetMajor()
    _G.SwitchTarget:SwitchTargets(Major)
end

function MainControlPanelView:OnCastBardAnim(bStatus)
    if bStatus then
        self:PlayAnimation(self.Anim_song_Screen)
    else
        self:StopAnimation(self.Anim_song_Screen)
        UIUtil.SetIsVisible(self.Anim_song_screen_particle, false)
    end
end

function MainControlPanelView:OnPWorldSkillTip(SkillID)
    local StateCmp = MajorUtil.GetMajorStateComponent()
    if StateCmp and StateCmp:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_COMBAT) == false then
        self:OnSwitchFightSkill()
    end
end

--function MainControlPanelView:OnClickButtonActor()
--	UIViewMgr:ShowView(UIViewID.EquipmentMainPanel)
--end
--[[
function MainControlPanelView:OnMiniMapPanelVisibleChange(Value)
	--print("MainControlPanelView:OnMiniMapPanelVisibleChange")

	--if Value then
	--	self:PlayAnimation(self.Anim_Task)
	--else
	--	self:PlayAnimation(self.Anim_Team)
	--end
end
--]]

--function MainControlPanelView:OnClickButtonSkill()
--	SkillUtil.CastSkill(self.ButtonIndex)
--end

--function MainControlPanelView:OnPressedButtonSkill()
--	print("MainControlPanelView:OnPressedButtonSkill")
--	SkillUtil.PrepareCastSkill(self.ButtonIndex)
--end
--
--function MainControlPanelView:OnReleasedButtonSkill()
--	print("MainControlPanelView:OnReleasedButtonSkill")
--	SkillUtil.CastSkill(self.ButtonIndex)
--end

--function MainControlPanelView:OnBagBtnClick()
--	UIViewMgr:ShowView(UIViewID.BagPanel)
--end

--function MainControlPanelView:OnPerspectiveBtnClick()
--	local Major = ActorMgr:GetMajor();
--	if Major then
--    	Major:GetCameraControllComponent():ResetSpringArm();
--    end
--end



--function MainControlPanelView:OnEmojiFightBtnClick()
--	if UIViewMgr:IsViewVisible(UIViewID.GMMain) then
--		UIViewMgr:HideView(UIViewID.GMMain)
--	else
--		UIViewMgr:ShowView(UIViewID.GMMain)
--	end
--end

function MainControlPanelView:OnNetStateUpdate(Params)
    local EntityID = Params.ULongParam1
    if not MajorUtil.IsMajor(EntityID) then
        return
    end

    local StateType = Params.IntParam1
    if StateType ~= ProtoCommon.CommStatID.COMM_STAT_COMBAT then
        return
    end

    --骑乘状态时无视战斗状态改变
    local StateComp = MajorUtil.GetMajorStateComponent()
    if StateComp and StateComp:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_MOUNT) then
        return
    end

    if self:DefaultCombatState() ~= 0 then
        return
    end
    local State = Params.BoolParam1
    self:ResetSwitchPeaceTimer()
    if State == true then
        self:OnSwitchFightSkill()
        self.KeepSwitchFight = true
    else
        local function SwitchFightTimeFinish()
            self:OnSwitchPeaceSkill()
            self.KeepSwitchFight = false
            if self.FightState == false then
                _G.EventMgr:SendEvent(EventID.CombatStateChanged, { IsFight = false } )
            end
        end
        self.SwitchPeaceTimer = self:RegisterTimer(SwitchFightTimeFinish, SwitchPeaceSkillTime)
    end
end

function MainControlPanelView:ResetSwitchPeaceTimer()
    if self.SwitchPeaceTimer > 0 then
        self:UnRegisterTimer(self.SwitchPeaceTimer)
        self.SwitchPeaceTimer = 0
    end
end

--进入战斗状态，切换战斗技能组
--在非战斗状态使用普攻也会短暂切换至战斗
function MainControlPanelView:OnSwitchFightSkill()
    
    if self.FightState == true then
        return
    end
    _G.EventMgr:SendEvent(EventID.FightSkillPanelShowed, true)
    self:UpdateControlPanelState(true)

    self:StopAnimation(self.Anim_Peacel)
    self:PlayAnimation(self.Anim_Fight)
    self:SubViewSwitchFight()
end

--切换非战斗技能组
function MainControlPanelView:OnSwitchPeaceSkill(bShowImmediately)
    -- if MainPanelVM.IsMountPanelVisible == true then
    --     return
    -- end
    
    if self.FightState == false then
        return
    end

    if _G.SkillLogicMgr.DisableSwitchToPeaceSkill then
        return
    end

    if _G.SkillLogicMgr:IsSkillPress() then
        self:ResetSwitchPeaceTimer()
        self.SwitchPeaceTimer = self:RegisterTimer(self.OnSwitchPeaceSkill, SwitchPeaceSkillTime, 1, 1)
        return
    end
    _G.EventMgr:SendEvent(EventID.FightSkillPanelShowed, false)
    self:UpdateControlPanelState(false)

    self:StopAnimation(self.Anim_Fight)
    if bShowImmediately then
        local AnimToPlay = self.Anim_Peacel
        local EndTime = AnimToPlay:GetEndTime()
        self:PlayAnimationTimeRange(AnimToPlay, EndTime, EndTime, 1, nil, 1.0, false)
    else
        self:PlayAnimation(self.Anim_Peacel)
    end
    self:SubViewSwitchPeace()
end
--
function MainControlPanelView:SkillUnLockViewShow()
    --当处于战斗状态时不触发
    if self.KeepSwitchFight == false then
        self:ResetSwitchPeaceTimer()
        self:RegisterTimer(self.OnSwitchFightSkill, 0.3, 1, 1)
        --self:OnSwitchFightSkill()
        self.SwitchPeaceTimer = self:RegisterTimer(self.OnSwitchPeaceSkill, SwitchPeaceSkillTime, 1, 1)
    end
end
function MainControlPanelView:SubViewSwitchFight()
    self.NewMainSkill_UIBP:ViewSwitchFight()

    if MajorUtil.IsGatherProf() then
        _G.UIViewMgr:ShowView(_G.UIViewID.GatherDrugSkillPanel)
        local ProfConfig = _G.GatherMgr.ProfConfig
        local ProfID = MajorUtil.GetMajorProfID()
        local NoteRtrPath = ProfConfig[ProfID].NoteRtrPath
        if NoteRtrPath then
            UIUtil.ImageSetBrushFromAssetPath(self.SkillGenAttackBtn_UIBP.Img_ProfSign, NoteRtrPath, true)
        end
    elseif  MajorUtil.IsFishingProf() then
        _G.UIViewMgr:ShowView(_G.UIViewID.GatherDrugSkillPanel)
    end

    self:CheckButtonTargetShow()
end

function MainControlPanelView:SubViewSwitchPeace()
    self.NewMainSkill_UIBP:ViewSwitchPeace()

    if MajorUtil.IsFishingProf() then
        _G.UIViewMgr:HideView(_G.UIViewID.GatherDrugSkillPanel)
    elseif MajorUtil.IsGatherProf() then
        _G.UIViewMgr:HideView(_G.UIViewID.GatherDrugSkillPanel)
        local ProfConfig = _G.GatherMgr.ProfConfig
        local ProfID = MajorUtil.GetMajorProfID()
        local NoteRtrPath = ProfConfig[ProfID].NormalSkillIcon
        if NoteRtrPath then
            UIUtil.ImageSetBrushFromAssetPath(self.SkillGenAttackBtn_UIBP.Img_ProfSign, NoteRtrPath, true)
        end
    end
end

function MainControlPanelView:Fish_ViewShow()
    UIUtil.SetIsVisible(self.FindGather, false)
    if _G.FishMgr:IsInFishState() then
        self:OnSwitchFightSkill()
    else
        self:OnSwitchPeaceSkill()
    end
end

function MainControlPanelView:Fish_ViewHide()
    self:OnSwitchPeaceSkill()
end


function MainControlPanelView:Fish_SwitchProf()
    self:Fish_ViewShow()
end

function MainControlPanelView:Fish_SkillBtnClick(Params)
    self:ResetSwitchPeaceTimer()
    Params.UIState = self.FightState or false
    if not _G.FishMgr:IsInFishState() then
        self:OnSwitchFightSkill()
        self.SwitchPeaceTimer = self:RegisterTimer(self.Fish_ViewHide, SwitchPeaceSkillTime, 1, 1)
    end
end

function MainControlPanelView:Combat_SwitchProf()
    self:Combat_ViewShow()
end

function MainControlPanelView:Combat_ViewShow(bShowImmediately)
    local CombatState = self:DefaultCombatState()
    if CombatState == ProtoRes.c_combat_state_type.COMBAT_STATE_FIGHTING then
        self:OnSwitchFightSkill(bShowImmediately)
        self.KeepSwitchFight = true
        return
    elseif CombatState == ProtoRes.c_combat_state_type.COMBAT_STATE_PEACE then
        self:OnSwitchPeaceSkill(bShowImmediately)
        self.KeepSwitchFight = false
        return
    end
    if MajorUtil and MajorUtil.GetMajorStateComponent() then
        local State = MajorUtil.GetMajorStateComponent():IsInNetState(ProtoCommon.CommStatID.COMM_STAT_COMBAT)
        if State == true then
            self:OnSwitchFightSkill(bShowImmediately)
            self.KeepSwitchFight = true
        else
            self:OnSwitchPeaceSkill(bShowImmediately)
            self.KeepSwitchFight = false
        end
    end
end

function MainControlPanelView:Combat_SkillBtnClick(Params)
    self:ResetSwitchPeaceTimer()
    local CombatState = self:DefaultCombatState()
    if CombatState == ProtoRes.c_combat_state_type.COMBAT_STATE_FIGHTING then
        Params.UIState = self.FightState or false
        --TODO[chaooren] 这里存在状态异常，暂无法确定异常原因
        --额外判断一下switcher index，只要index=0(peace panel)就展开
        if Params.UIState == false or self.SkillSwithcer:GetActiveWidgetIndex() == 0 then
            self:OnSwitchFightSkill()
        end
        return
    elseif CombatState == ProtoRes.c_combat_state_type.COMBAT_STATE_PEACE then
        Params.UIState = false
        return
    end

    Params.UIState = self.FightState or false
    self:OnSwitchFightSkill()
    local StateCmp = MajorUtil.GetMajorStateComponent()
    if StateCmp and StateCmp:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_COMBAT) == false then
        self.SwitchPeaceTimer = self:RegisterTimer(self.OnSwitchPeaceSkill, SwitchPeaceSkillTime, 1, 1)
    end
end

function MainControlPanelView:GP_ViewShow(Params)
    if _G.GatherMgr:IsGatherState() then--and _G.UIViewMgr:IsViewVisible(_G.UIViewID.GatheringJobPanel) then
        self:OnSwitchFightSkill()
        _G.UIViewMgr:ShowView(_G.UIViewID.GatherDrugSkillPanel)
    else
        self:OnSwitchPeaceSkill()
        _G.UIViewMgr:HideView(_G.UIViewID.GatherDrugSkillPanel)
    end
end

function MainControlPanelView:GP_SkillBtnClick(Params)
    if Params.BtnIndex == FindGatherPointRealIndex then
        return
    end

    self:ResetSwitchPeaceTimer()
    Params.UIState = self.FightState or false
    self:OnSwitchFightSkill()

    _G.UIViewMgr:ShowView(_G.UIViewID.GatherDrugSkillPanel)
    self.SwitchPeaceTimer = self:RegisterTimer(self.GP_OnSwitchPeaceSkill, SwitchPeaceSkillTime, 1, 1)
end

function MainControlPanelView:GP_OnSwitchPeaceSkill()
    if _G.GatherMgr:IsGatherState() then
        return 
    end
    
    self:OnSwitchPeaceSkill()
    _G.UIViewMgr:HideView(_G.UIViewID.GatherDrugSkillPanel)
end

function MainControlPanelView:GP_ForceFight(Params)
    _G.UIViewMgr:ShowView(_G.UIViewID.GatherDrugSkillPanel)
end

function MainControlPanelView:Crafter_ViewShow(Params)
    self:OnSwitchPeaceSkill()
end

function MainControlPanelView:Crafter_SwitchProf(Params)
    self:OnSwitchPeaceSkill()
end

--转职过来
function MainControlPanelView:GP_SwitchProf(Params)
    if MajorUtil.IsGatherProf() then
        UIUtil.SetIsVisible(self.FindGather, true, true)
    end

    self:OnSwitchPeaceSkill()
    _G.UIViewMgr:HideView(_G.UIViewID.GatherDrugSkillPanel)
end

function MainControlPanelView:OnSkillReplace(Params)
    if MajorUtil.IsGatherProf() and Params.SkillIndex == FindGatherPointRealIndex then
        local AbleView = self.FindGather
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
end

function MainControlPanelView:GP_ForcePeace(Params)
    _G.UIViewMgr:HideView(_G.UIViewID.GatherDrugSkillPanel)
end

function MainControlPanelView:OnSkillBtnClick(Params)
    local Func = self:GetProfControlFunc(MajorUtil.GetMajorProfID(), SkillBtnClick)
    if Func then
        Func(self, Params)
    end
end

function MainControlPanelView:DefaultCombatState()
    local PWorldInfo = _G.PWorldMgr:GetCurrPWorldTableCfg()
    if nil == PWorldInfo then
        return
    end

    local DefaultCombatState = PWorldInfo.DefaultCombatState or 0
    return DefaultCombatState
end

--懒人专用
function MainControlPanelView:OnForceSwitchFight()
    self:OnExpandSkillView()
    
    local ProfID = MajorUtil.GetMajorProfID()
    local Func = self:GetProfControlFunc(ProfID, ForceFight)
    if Func then
        Func(self)
    end
end

--懒人专用
function MainControlPanelView:OnForceSwitchPeace()
    self:OnReleaseSkillView()

    local ProfID = MajorUtil.GetMajorProfID()
    local Func = self:GetProfControlFunc(ProfID, ForcePeace)
    if Func then
        Func(self)
    end
end

--AutoReleaseTime：多少秒后自动收起
--<=0不自动收起
function MainControlPanelView:OnExpandSkillView(AutoReleaseTime)
    self:ResetSwitchPeaceTimer()
    self:OnSwitchFightSkill()
    if AutoReleaseTime and AutoReleaseTime > 0 then
        self.SwitchPeaceTimer = self:RegisterTimer(self.OnSwitchPeaceSkill, AutoReleaseTime, 1, 1)
    end
end

function MainControlPanelView:OnReleaseSkillView(AutoReleaseTime)
    self:ResetSwitchPeaceTimer()
    if AutoReleaseTime and AutoReleaseTime > 0 then
        self.SwitchPeaceTimer = self:RegisterTimer(self.OnSwitchPeaceSkill, AutoReleaseTime, 1, 1)
    else
        self:OnSwitchPeaceSkill()
    end
end

function MainControlPanelView:GetIsPeaceAniming()
    return self:IsAnimationPlaying(self.Anim_Peacel)
end

--点极限技入口，进入释放极限技的ui
function MainControlPanelView:OnSkillLimitEntranceClick()
    MainControlPanelVM:SetLimitGenAttackVisible(false)
    UIUtil.SetIsVisible(self.MainProSkill_UIBP, false)
    _G.SkillLogicMgr.DisableSwitchToPeaceSkill = true
end

--从释放极限技的ui，点击右上角退出按钮，回到正常的技能组ui
function MainControlPanelView:OnSkillLimitCancelBtnClick()
    MainControlPanelVM:SetLimitGenAttackVisible(true)
    UIUtil.SetIsVisible(self.MainProSkill_UIBP, true)
    _G.SkillLogicMgr.DisableSwitchToPeaceSkill = false

    --不知道干啥的，先注释
    -- if not MainPanelVM.IsFightState then
    --     self:OnCombatStateChange(false)
    -- end
end

function MainControlPanelView:OnSkillLimitDel()
    self:OnSkillLimitCancelBtnClick()
end


--通用技能交互CDUpdate
function MainControlPanelView:OnSkillCDUpdate(Params)
    local CurrentCD = Params.SkillCD
    local BaseCD = Params.BaseCD

    local ImgCD = self.ImgCD
    local TextCD = self.TextCD

    -- if MajorUtil.IsGatherProf() then
    --     local FindGatherPointRealIndex = SkillCommonDefine.FindGatherPointRealIndex
    --     local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
    --     if LogicData then
    --         local FindGatherSkillID = LogicData:GetBtnSkillID(FindGatherPointRealIndex)
    --         if Params.SkillID == FindGatherSkillID then --采集职业的勘探技能
    --             ImgCD = self.ImgCDFindGather
    --             TextCD = self.TextCDFindGather
    --         end
    --     end
    -- end

    if CurrentCD <= 0 then
        ImgCD:SetPercent(0)
        TextCD:SetText("")
    else
        local CDPercent = CurrentCD / BaseCD
        if CDPercent > 1 then
            CDPercent = 1
        end
        ImgCD:SetPercent(CDPercent)
        TextCD:SetText(string.format("%d", math.ceil(CurrentCD)))
    end
end

function MainControlPanelView:OnEventMajorProfSwitch(Params)

    self:ResetSwitchPeaceTimer()
    local ProfID = MajorUtil.GetMajorProfID()
    self:RegisterGameEventByProf(ProfID)

    self.ProfFuncs = nil

    --特殊，所以这里先hide
    _G.UIViewMgr:HideView(_G.UIViewID.GatherDrugSkillPanel)
    UIUtil.SetIsVisible(self.FindGather, false)

    local Func = self:GetProfControlFunc(ProfID, SwitchProf)
    if Func then
        Func(self)
    end

    self:SetDefaultBtnSwitchTips(ProfID)

    -- self:CheckButtonTargetShow()
    _G.MainPanelVM:SetVisibleIconBook()
end

local EBtnSwitchCondition_PeaceToFight <const> =  MainControlPanelVM.EBtnSwitchCondition.PeaceToFight

function MainControlPanelView:SetDefaultBtnSwitchTips(ProfID)
    local TipsID = 0
    -- 生产职业不允许切换到战斗页
    if ProfUtil.IsCrafterProf(ProfID) then
        TipsID = MsgTipsID.CombatBtnSwitchDisable_Crafter
    end
    MainControlPanelVM:SetBtnSwitchTips(TipsID, EBtnSwitchCondition_PeaceToFight)
end

function MainControlPanelView:OnFixedFunctionPanelShowed(Params)
    if nil ~= Params and Params.IsShow == true then
        self:ResetSwitchPeaceTimer()
        self:OnSwitchPeaceSkill()
    end
end

function MainControlPanelView:CheckButtonTargetShow()
    local IsShow = true
    if MajorUtil.IsGpProf() then
        IsShow = false
        
        if MajorUtil.IsGatherProf() and not _G.GoldSauserLeapOfFaithMgr:IsCurMapLeapOfFaith() then
            UIUtil.SetIsVisible(self.FindGather, true, true)
        else
            UIUtil.SetIsVisible(self.FindGather, false)
        end
    else
        UIUtil.SetIsVisible(self.FindGather, false)
    end

    UIUtil.SetIsVisible(self.ButtonTarget, IsShow, true)
end

function MainControlPanelView:OnCastLimitSkill(Index, PerdueSkill)
    local ServerSkillID = PerdueSkill.SkillID
    if Index == 0 then
        local SkillType = SkillMainCfg:GetSkillType(ServerSkillID)
        if SkillType == ProtoRes.skill_type.SKILL_TYPE_EXTRA then
            self.ExtraSkillBtn:OnCastUpdatePerdueSkill(ServerSkillID, PerdueSkill.ExpireTime, PerdueSkill.LastCount)
        end
    end
end

function MainControlPanelView:OnRemoveLimitSkill(Index, PerdueSkill)
    if Index == 0 then
        local SkillType = SkillMainCfg:GetSkillType(PerdueSkill.SkillID)
        if SkillType == ProtoRes.skill_type.SKILL_TYPE_EXTRA then
            self.ExtraSkillBtn:HideTriggerBtn(true, true)
        end
    end
end

function MainControlPanelView:UpdateControlPanelState(State)
    self.FightState = State
    MainControlPanelVM:SetFightStatus(State)
    MainPanelVM:SetIsFightState(State)
    MountVM:UpdateCombatPanelState(State)
end



function MainControlPanelView:OnMajorUpdateBuff(Params)
    local BuffID = Params.IntParam1
    local Cfg = CombatPanelBuffCfg:FindCfgByKey(BuffID)
    if not Cfg then
        return
    end

    for Index, Icon in ipairs(Cfg.Icon) do
        if Icon then
            MainControlPanelVM[string.format("BGIcon_%d", Index)] = Icon
        end
    end

    local DefaultCombatState = Cfg.DefaultCombatState
    if DefaultCombatState > 0 then
        local CombatState = DefaultCombatState - 1
        if CombatState == ProtoRes.c_combat_state_type.COMBAT_STATE_FIGHTING then
            self:ResetSwitchPeaceTimer()
            self:OnSwitchFightSkill()
            self.KeepSwitchFight = true
            return
        elseif CombatState == ProtoRes.c_combat_state_type.COMBAT_STATE_PEACE then
            self:OnSwitchPeaceSkill()
            self.KeepSwitchFight = false
            return
        end
    end
end

function MainControlPanelView:OnMajorRemoveBuff(Params)
    local BuffID = Params.IntParam1
    local Cfg = CombatPanelBuffCfg:FindCfgByKey(BuffID)
    if not Cfg then
        return
    end
    local bRestoreIcon = false
    for _, Icon in ipairs(Cfg.Icon) do
        if Icon then
            bRestoreIcon = true
            break
        end
    end

    if bRestoreIcon then
        MainControlPanelVM:ResetDefaultBG()
    end

    local DefaultCombatState = Cfg.DefaultCombatState
    if DefaultCombatState > 0 then
        self:Combat_ViewShow(true)
    end
end

return MainControlPanelView