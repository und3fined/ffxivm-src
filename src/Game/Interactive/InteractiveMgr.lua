local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local LuaClass = require("Core/LuaClass")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local UIUtil = require("Utils/UIUtil")
local AudioUtil = require("Utils/AudioUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local EntranceItemFactory = require("Game/Interactive/EntranceItemFactory")
local FunctionItemFactory = require("Game/Interactive/FunctionItemFactory")
local InteractiveMainPanelVM = require("Game/Interactive/MainPanel/InteractiveMainPanelVM")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
-- local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local InteractiveFunctypeCfg = require("TableCfg/InteractiveFunctypeCfg")
local ProcessorUseItem = require("Game/Interactive/EntranceItem/ProcessorUseItem")
local GatherPointCfg = require("TableCfg/GatherPointCfg")
local ManualSelectInteractionCfg = require("TableCfg/ManualSelectInteractionCfg")
local AnimationUtil = require("Utils/AnimationUtil")
local MutuallyExclusiveUIConfig = require("Game/Interactive/MainPanel/MutuallyExclusiveUIConfig")
local MsgTipsID = require("Define/MsgTipsID")
local MapUtil = require("Game/Map/MapUtil")
local CommonVfxCfg = require("TableCfg/CommonVfxCfg")
local EffectUtil = require("Utils/EffectUtil")
local LogMgr = require("Log/LogMgr")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local EobjExclusionInteractionCfg = require("TableCfg/EobjExclusionInteractionCfg")
local VfxSoundCfg = require("TableCfg/VfxSoundCfg")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ActiontimelinePathCfg = require("TableCfg/ActiontimelinePathCfg")

local FLOG_ERROR = LogMgr.Error

---@class InteractiveMgr : MgrBase
local InteractiveMgr = LuaClass(MgrBase)

InteractivePhrase = InteractivePhrase or
{
    None = 0,
    First = 1,  --一级交互
    Second = 2, --二级交互
}

--暂时没用，先放着
InteractiveMgr.CurPhrase = InteractivePhrase.None

function InteractiveMgr:OnInit()
    self.EnablePrintNormalLog = false
    self.EnablePrintCheckLog = false
    self.InteractorParamsList = {}
    self.CurrentFunctionViewID = 0
    self.CurInteractEntityID = 0
    self.FunctionItemsList = {}
    self.CurPhrase = InteractivePhrase.None

    --当前没有交互项，但是是在交互距离之内的，随时可能会有交互项
    self.InteractorParamsListToShow = {}

    --当前选择的一级入口Entrance
    self.CurInteractEntrance = nil
    --当前点击的二级交互的FunctionItem
    self.CurInteractFuncItem = nil

    --记录最后的CustomTalkID，回溯对话选项用
    self.LastCustomTalkID = nil
    --记录已经选过的对话选项，每次mainpanel关闭的时候置空
    self.TempNotAvailableOptions = {}
    self.IsResetCustomTalk = nil
    --是否正在播放动画，播放动画不显示交互UI
    self.CanShowInteractive = true
    self.ProcessorUseItem = ProcessorUseItem.New()
    self.EntranceUseItem = nil

    self.FuncTypeCfgMap = {}
    local FunctypeCfgList = InteractiveFunctypeCfg:FindAllCfg()
    for index = 1, #FunctypeCfgList do
        local Cfg = FunctypeCfgList[index]
        self.FuncTypeCfgMap[Cfg.FuncType] = Cfg
    end

    self.LastSelectedTargetEntityID = 0
    self.LastSelectedTargetParams = {}
    self.bHasSpecialSelectedTarget = false
    self.FixedFunctionItemsList = {}
    self.bFixedFuncPanelClosedByOtherUI = false
    self.bFoundFindWorldViewObj = false
    self.WorldViewObjEntranceItem = nil
    self.MutuallyExclusiveShowUIList = {}
    self.bMainPanelClosedByOtherUI = false
    self.LastInteractiveObjEntityID = 0
    self.SelectEffectCurve = "CurveLinearColor'/Game/Assets/Effect/BluePrint/Select/C_SelectSplashColor.C_SelectSplashColor'"
    self.SelectedSound = "/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_click_tape_1.Play_UI_click_tape_1"
    self.bEnableShowMainPanel = true
    self.LastInteractiveEntance = nil
    self.LastUseItemEntrance = nil
    self.bIsSelectPrioritized = false
    self.InteractiveTargetIndex = 1
    self.bIsDoingEmotion = false
    self.bNeedRecoveryMainPanel = false
    self.bHasPWorldBranch = false
    self.bNeedRecoveryEntrance = false

    self.QueryPWorldBranchTimer = nil
    self.QueryPWorldBranchInterval = 30
    self.CurrentCrystalEntityID = 0
    self.CurInteractionEntityID = 0
    self.CurSingInteractionID = 0
    self.bIsSinging = false

    self.bSendInteractionReqSuccess = false

    self.bLockTimer = false

    self.EntranceLastClickTime = 0
    self.IsEntranceDelayShowing = false
    self.IsMajorCancelMounting = false
    self.CurManualSelectInteractionCfg = nil

    self.NearByPlayers = {}
    self.NearByPlayersInfo = {}
    self.CurSelectedPlayerIndex = 0
    self.CurSelectedPlayerEntityID = 0
    self.ClickSelectedPlayerPos = { X = 0, Y = 0, Z = 0 }
    self.ClickSelectedPlayerEntityID = 0

    self.MajorRotationInterpSpeed = nil

    self.IsNeedShowMainPanelAfterSingOver = false
    self.HideOtherUITypeBySing = ""

    self.DuelInteractiveID = 501208
    self.EnableDuelMapID = 13026

    self.TimeToStopMajorMove = 0.5

    self.MountRideNpcIDList = { 2006110 }
end

function InteractiveMgr:OnBegin()
end

function InteractiveMgr:OnEnd()
    self:HideMainPanel()

    --角色在其他机器登录，被踢到登录界面
    self.ProcessorUseItem:OnEnd()
end

function InteractiveMgr:OnShutdown()
    self.InteractorParamsList = {}
    self.InteractorParamsListToShow = {}
    self.FunctionItemsList = {}
    self.CurPhrase = InteractivePhrase.None

    self.CurInteractEntrance = nil
    self.CurInteractFuncItem = nil

    self.LastSelectedTargetEntityID = 0
    self.LastSelectedTargetParams = {}
    self.bHasSpecialSelectedTarget = false
    self.FixedFunctionItemsList = {}
    self.MutuallyExclusiveShowUIList = {}

    self:SetEnablePrintNormalLog(false)
    self:SetEnablePrintCheckLog(false)
end

function InteractiveMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_INTERAVIVE, ProtoCS.CsInteractionCMD.CsInteractionCMDStart, self.OnInteractionStartRsp)
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_INTERAVIVE, ProtoCS.CsInteractionCMD.CsInteractionCMDBreak, self.OnInteractionBreakRsp)
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_INTERAVIVE, ProtoCS.CsInteractionCMD.CsInteractionCMDEnd, self.OnInteractionEndRsp)
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_INTERAVIVE, ProtoCS.CsInteractionCMD.CsInteractionCmdVfx, self.OnRecievePlayVfx)
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_SUMMON_BEAST, ProtoCS.Role.SummonBeast.SummonBeastCmd.SummonBeastCmdCallBack, self.OnSummonBeastCallBackRsp)
end

function InteractiveMgr:OnRegisterGameEvent()
    -- self:RegisterGameEvent(EventID.ClickNextDialog, self.OnGameEventClickNextDialog)
    self:RegisterGameEvent(EventID.EnterInteractionRange, self.OnGameEventEnterInteractionRange)
    self:RegisterGameEvent(EventID.EnterInteractionGuideRange, self.OnGameEventEnterInteractionGuideRange)
    self:RegisterGameEvent(EventID.LeaveInteractionRange, self.OnGameEventLeaveInteractionRange)
    -- self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldExit)
    self:RegisterGameEvent(EventID.HideUI, self.OnGameEventHideUI)
    self:RegisterGameEvent(EventID.WorldPreLoad, self.OnEventWorldPreLoad)
    self:RegisterGameEvent(EventID.WorldPostLoad, self.OnGameEventWorldPostLoad)
    self:RegisterGameEvent(EventID.FinishDialog, self.OnGameEventFinishDialog)
    self:RegisterGameEvent(EventID.VisionLeave, self.OnEventActorLeaveVision)
    self:RegisterGameEvent(EventID.ActorDestroyed, self.OnEventActorDestroy)
    self:RegisterGameEvent(EventID.PreClickFunctionItems, self.OnPreFunctionItemClick)
    -- self:RegisterGameEvent(EventID.PostClickFunctionItems, self.OnPostFunctionItemClick)
	self:RegisterGameEvent(EventID.ClickEntranceItems, self.OnClickEntranceItems)
    --任务状态变化的时候，要check下交互对象，是否有任务变化
    --（已经enterrange的情况下：原来没有交互的有交互了，原来有交互的现在没交互了）
    --tick更通用，但是不够及时，能看到闪一下
    self:RegisterGameEvent(EventID.UpdateQuest, self.OnUpdateQuest)
    self:RegisterGameEvent(EventID.MajorSingBarBegin, self.OnMajorSingBarBegin)
    self:RegisterGameEvent(EventID.MajorSingBarOver, self.OnMajorSingBarOver)
    self:RegisterGameEvent(EventID.ManualSelectTarget, self.OnManualSelectTarget)
	self:RegisterGameEvent(EventID.UnSelectTarget, self.OnUnSelectTarget)
    self:RegisterGameEvent(EventID.TeamMemberBeSelected, self.OnTeamMemberBeSelected)
    self:RegisterGameEvent(EventID.BagUseItem, self.OnEventUseItem)

    --self:RegisterGameEvent(EventID.NetworkReconnected, self.OnNetworkReconnected)
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.FightSkillPanelShowed, self.OnFightSkillPanelShowed)
    self:RegisterGameEvent(EventID.SkillMultiChoicePanelShowed, self.OnSkillMultiChoicePanelShowed)
    self:RegisterGameEvent(EventID.ShowUI, self.OnGameEventShowUI)
    self:RegisterGameEvent(EventID.UseWorldViewObj, self.OnUseWorldViewObj)
    self:RegisterGameEvent(EventID.ClickWorldViewObjEntranceItem, self.OnClickWorldViewObjEntranceItem)
    self:RegisterGameEvent(EventID.CombatStateChanged, self.OnCombatStateChanged)
    self:RegisterGameEvent(EventID.PostEmotionEnter, self.OnGameEventPostEmotionEnter)
	self:RegisterGameEvent(EventID.PostEmotionEnd, self.OnGameEventPostEmotionEnd)

    self:RegisterGameEvent(EventID.UpdateChocoboTransportNpcBookStatus, self.OnUpdateChocoboTransportNpcBookStatus)
    self:RegisterGameEvent(EventID.FateUpdate, self.OnGameEventFateUpdate)
    self:RegisterGameEvent(EventID.CrystalActivated, self.OnGameEventCrystalActivated)

    self:RegisterGameEvent(EventID.PWorldLineQueryResult, self.OnPWorldLineQueryResult)
    self:RegisterGameEvent(EventID.FishEnd, self.OnFishEnd)
    self:RegisterGameEvent(EventID.MajorDead, self.OnGameEventMajorDead)
    self:RegisterGameEvent(EventID.OtherCharacterDead, self.OnGameEventCharacterDead)
    self:RegisterGameEvent(EventID.EndPlaySequence, self.OnEndPlaySequence)
end

-- --先沿用之前的，以后再优化调整
-- function InteractiveMgr:OnGameEventMajorCreate(Params)
-- end

function InteractiveMgr:SetEnablePrintCheckLog(IsEnable)
    self.EnablePrintCheckLog = IsEnable
    if self.EnablePrintCheckLog then
        self:UpdateInteractiveList(IsEnable)
    end
end

function InteractiveMgr:SetEnablePrintNormalLog(IsEnable)
    self.EnablePrintNormalLog = IsEnable
end

function InteractiveMgr:PrintCurInteractionInfo()
    if self.EnablePrintCheckLog then
        for i = 1, #self.InteractorParamsList do
            local IUnit = self.InteractorParamsList[i]
            local EntityID = IUnit.EntityID or 0
            local ActorType = ActorUtil.GetActorType(EntityID)
            local ResID = ActorUtil.GetActorResID(EntityID)
            local ActorName = ActorUtil.GetActorName(EntityID)
            self:PrintInfo("InteractiveMgr:PrintCurInteractionInfo, ResID:%d EntityID:%d Type:%d ActorName:%s",
            ResID, EntityID, ActorType, ActorName)
        end
        if nil ~= self.EntranceUseItem then
            local EntityID = self.EntranceUseItem.EntityID or 0
            local ActorType = ActorUtil.GetActorType(EntityID)
            local ResID = ActorUtil.GetActorResID(EntityID)
            local ActorName = ActorUtil.GetActorName(EntityID)
            self:PrintInfo("InteractiveMgr:PrintCurInteractionInfo, EntranceUseItem, ResID:%d EntityID:%d Type:%d ActorName:%s",
            ResID, EntityID, ActorType, ActorName)
        end
    end
end

function InteractiveMgr:OnNetworkReconnected(Param)
    local bRelay = Param and Param.bRelay
    self:PrintInfo("InteractiveMgr:OnNetworkReconnected, bRelay:%s", tostring(bRelay))
    if (bRelay) then
        InteractiveMainPanelVM:SetFunctionVisible(false)
        self:ShowMainPanel()
    end
end

function InteractiveMgr:OnGameEventLoginRes(Param)
    local bReconnect = Param and Param.bReconnect
    self:PrintInfo("InteractiveMgr:OnGameEventLoginRes, bReconnect:%s", tostring(bReconnect))
    if (bReconnect) then
        InteractiveMainPanelVM:SetFunctionVisible(false)
        self:ShowMainPanel()
    end
    -- 登录和重连都主动打断交互,为了触发服务器退出交互状态
    self:SendInteractiveBreakReq()
end

function InteractiveMgr:OnEventWorldPreLoad(Params)
    self.InteractorParamsList = {}
    self.InteractorParamsListToShow = {}
    self.FunctionItemsList = {}
    self.CurPhrase = InteractivePhrase.None
    self.CurInteractFuncItem = nil

    self:StopFindWorldViewObjTickTimer()
end

function InteractiveMgr:OnGameEventWorldPostLoad()
    self:StartFindWorldViewObjTickTimer()
    self.bMainPanelClosedByOtherUI = false
    self.MutuallyExclusiveShowUIList = {}
end

function InteractiveMgr:StartFindWorldViewObjTickTimer()
    if not self.FindWorldViewObjTimerID then
        self.FindWorldViewObjTimerID = self:RegisterTimer(self.FindWorldViewObj, 0, 0.3, 0)
    end
end

function InteractiveMgr:StopFindWorldViewObjTickTimer()
    if self.FindWorldViewObjTimerID then
        self:UnRegisterTimer(self.FindWorldViewObjTimerID)
        self.FindWorldViewObjTimerID = nil
    end
end

function InteractiveMgr:StartQueryPWorldBranchTimer()
    if not self.QueryPWorldBranchTimer then
        self.QueryPWorldBranchTimer = self:RegisterTimer(self.QueryPWorldBranch, 0, self.QueryPWorldBranchInterval, 0)
    end
end

function InteractiveMgr:StopQueryPWorldBranchTimer()
    if self.QueryPWorldBranchTimer then
        self:UnRegisterTimer(self.QueryPWorldBranchTimer)
        self.QueryPWorldBranchTimer = nil
    end
end

function InteractiveMgr:SetCurCrystalEntrance(Entrance)
    self.CurCrystalEntrance = Entrance
end

function InteractiveMgr:SendInteractiveStartReq(InteractiveID, EntityID)
    local ObjType, ObjID = ActorUtil.GetInteractionObjInfo(EntityID)
    if not ObjType then
        FLOG_ERROR("InteractiveMgr:SendInteractiveStartReq, ObjType is nil!")
        return
    end

	local MsgID = ProtoCS.CS_CMD.CS_CMD_INTERAVIVE
	local SubMsgID = ProtoCS.CsInteractionCMD.CsInteractionCMDStart

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Start = {InteractiveID = InteractiveID, Obj = {ObjID = ObjID, Type = ObjType}}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    self:ClientSendInteractionStartReq(InteractiveID)
end

function InteractiveMgr:SendInteractiveStartReqWithoutObj(InteractiveID)
	local MsgID = ProtoCS.CS_CMD.CS_CMD_INTERAVIVE
	local SubMsgID = ProtoCS.CsInteractionCMD.CsInteractionCMDStart

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Start = {InteractiveID = InteractiveID, Obj = {ObjID = 0, Type = ProtoCS.InteractionObjType.InteractionObjTypeEmpty}}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    self:ClientSendInteractionStartReq(InteractiveID)
end

function InteractiveMgr:ClientSendInteractionStartReq(InteractionID)
    --FLOG_INFO("InteractiveMgr:ClientSendInteractionStartReq, InteractionID:%d", InteractionID)
    self.CurSingInteractionID = InteractionID
    self.bSendInteractionReqSuccess = false
    local function CheckNextInteractive()
        if not self.bSendInteractionReqSuccess then
            self.CurSingInteractionID = 0
            self:StartTickTimer()
        end
    end
    self.SendInteractionStartReqTimer = self:RegisterTimer(CheckNextInteractive, 1, 1, 1)
end

function InteractiveMgr:OnInteractionStartRsp(MsgBody)
    if (MsgBody.ErrorCode and MsgBody.ErrorCode > 0) then
        if MsgBody.ErrorCode == 101010 then         --"等级不足，不能进入副本。"
            local Params = {TypeNum = ProtoRes.promote_type.PROMOTE_TYPE_COMBAT}
            _G.EventMgr:SendEvent(EventID.ShowPromoteMainPanel, Params)
        elseif MsgBody.ErrorCode == 101035 then     --"装备平均品级不足，打开商会或市场购买更高品级的装备"
            local Params = {TypeNum = ProtoRes.promote_type.PROMOTE_TYPE_EQUIP}
            _G.EventMgr:SendEvent(EventID.ShowPromoteMainPanel, Params) 
        end
        _G.NpcDialogMgr:EndInteraction()
        return
    end
    local InteractionStartRsp = MsgBody.Start
    if nil == InteractionStartRsp then
        return
    end
    if nil ~= InteractionStartRsp.Obj and InteractionStartRsp.Obj.ObjID then
        self.CurInteractionEntityID = InteractionStartRsp.Obj.ObjID
    end
    local InteractionID = InteractionStartRsp.InteractionID
    -- FLOG_INFO("InteractiveMgr:OnInteractionStartRsp, ObjID:%d, InteractionID:%d",
    --  self.CurInteractionEntityID, InteractionID)

     if self.CurSingInteractionID == InteractionID then
        self.bSendInteractionReqSuccess = true
        if nil ~= self.SendInteractionStartReqTimer then
            self:UnRegisterTimer(self.SendInteractionStartReqTimer)
        end
        self:StartTickTimer()
    end
    self.CurSingInteractionID = InteractionID
end

function InteractiveMgr:SetCurrentSingInteractionId(InteractionID)
    --FLOG_INFO("InteractiveMgr:SetCurrentSingInteractionId, InteractionID:%d", InteractionID)
    self.CurSingInteractionID = InteractionID
end

function InteractiveMgr:SendInteractiveBreakReq()
    local MsgID = ProtoCS.CS_CMD.CS_CMD_INTERAVIVE
    local SubMsgID = ProtoCS.CsInteractionCMD.CsInteractionCMDBreak

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function InteractiveMgr:OnInteractionBreakRsp(MsgBody)
    FLOG_INFO("InteractiveMgr:OnInteractionBreakRsp, MsgBody:%s", tostring(MsgBody))
    self.CurSingInteractionID = 0
end

function InteractiveMgr:SendInteractiveEndReq()
    --FLOG_INFO("InteractiveMgr:SendInteractiveEndReq, InteractionID:%d",self.CurSingInteractionID)
    if self.CurSingInteractionID ~= 0 then
        local MsgID = ProtoCS.CS_CMD.CS_CMD_INTERAVIVE
        local SubMsgID = ProtoCS.CsInteractionCMD.CsInteractionCMDEnd

        local MsgBody = {}
        MsgBody.Cmd = SubMsgID
        MsgBody.End = {InteractiveID = self.CurSingInteractionID}

        GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    end
end

function InteractiveMgr:OnInteractionEndRsp(MsgBody)
    local InteractionEndRsp = MsgBody.End
    if nil ~= InteractionEndRsp then
        local InteractionID = InteractionEndRsp.InteractiveID
        --FLOG_INFO("InteractiveMgr:OnInteractionEndRsp, InteractionID:%d", InteractionID)
        if self.CurSingInteractionID == InteractionID then
            self.CurSingInteractionID = 0
        end
    else
        if MsgBody.ErrorCode then
            _G.EventMgr:SendEvent(EventID.InteractiveReqEndError)
        end
    end
end

function InteractiveMgr:SendInteractiveSpellChgReq(SingStateID)
    --FLOG_INFO("InteractiveMgr:SendInteractiveSpellChgReq, SpellId:%d", SingStateID)
    if self.CurSingInteractionID ~= 0 then
        local MsgID = ProtoCS.CS_CMD.CS_CMD_INTERAVIVE
        local SubMsgID = ProtoCS.CsInteractionCMD.CsInteractionCMDSpellChg

        local MsgBody = {}
        MsgBody.Cmd = SubMsgID
        MsgBody.SpellChg = {SpellID = SingStateID}

        GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    end
end

function InteractiveMgr:SetMajorIsinging(IsSinging)
    self.bIsSinging = IsSinging
    -- if IsSinging then
    --     self:StopMajorMoveForFixedTime(0)
    -- end
    local IsMainPanelShowed = _G.UIViewMgr:IsViewVisible(_G.UIViewID.MainPanel)
    if self.HideOtherUITypeBySing ~= "" then
        if self.HideOtherUITypeBySing == "1" then
            if IsSinging then
                if IsMainPanelShowed then
                    self:PrintInfo("InteractiveMgr:SetMajorIsinging, HideMainPanel")
                    --_G.BusinessUIMgr:HideMainPanel(_G.UIViewID.MainPanel, true)

                    -- local MainPanleView = _G.UIViewMgr:FindView(_G.UIViewID.MainPanel)
                    -- if MainPanleView then
                    --     MainPanleView:SetVisible(false)
                    -- end
                    self.IsNeedShowMainPanelAfterSingOver = true
                end
            else
                if self.IsNeedShowMainPanelAfterSingOver and not IsMainPanelShowed then
                    self:PrintInfo("InteractiveMgr:SetMajorIsinging, ShowMainPanel")
                    --_G.BusinessUIMgr:ShowMainPanel(_G.UIViewID.MainPanel)
                    
                    -- local MainPanleView = _G.UIViewMgr:FindView(_G.UIViewID.MainPanel)
                    -- if MainPanleView then
                    --     MainPanleView:SetVisible(true)
                    -- end
                    self.IsNeedShowMainPanelAfterSingOver = false
                    self:SetHideOtherUITypeBySing("")
                end
            end
        end
    end
end

function InteractiveMgr:SetHideOtherUITypeBySing(HideType)
    self:PrintInfo("InteractiveMgr:SetHideOtherUITypeBySing, HideType:%s", HideType)
    self.HideOtherUITypeBySing = HideType
end

function InteractiveMgr:OnMajorSingBarBegin()
    self:PrintInfo("InteractiveMgr:OnMajorSingBarBegin, HideMainPanel")
    self:HideMainPanel()
    --self:SetMajorIsinging(true)
end

function InteractiveMgr:OnMajorSingBarOver(EntityID, IsBreak)
    self:PrintInfo("InteractiveMgr:OnMajorSingBarOver, EntityID:%d", EntityID)
    --self.bIsSinging = false
    self:SetMajorIsinging(false)
    if not IsBreak then
        self.ProcessorUseItem:ApplyExeptionEntityID()
        self:RemoveSingBarOverEntityID()
    end

    -- if (self.InteractorParamsList and #self.InteractorParamsList > 0)
    -- or (self.EntranceUseItem ~= nil) or self.bHasSpecialSelectedTarget then
    --     self:ShowMainPanel()
    -- end

    -- 召唤坐骑的情况在MountMgr:OnMountCall里显示
    if not MountMgr:IsRequestingMount() then
        self:RegisterTimer(self.ShowMainPanelAfterMajorSingOver, 1, 0.5, 1)
    end

    --[sammrli] 处理打断传送的情况，需要重新显示一级交互
    if IsBreak then
        self:RegisterTimer(self.OnTimerAfterMajorSingOver, 1, 1, 1)
    end

    self.CurInteractionEntityID = 0
end

function InteractiveMgr:RemoveSingBarOverEntityID()
    for Index, Value in ipairs(self.InteractorParamsList) do
        --FLOG_INFO("InteractiveMgr:RemoveSingBarOverEntityID, Value.EntityID:%d", Value.EntityID)
        if Value.EntityID == self.CurInteractionEntityID then
            table.remove(self.InteractorParamsList, Index)
            break
        end
    end
end

function InteractiveMgr:ShowMainPanelAfterMajorSingOver()
    if (self.InteractorParamsList and #self.InteractorParamsList > 0)
        or (self.EntranceUseItem ~= nil) or self.bHasSpecialSelectedTarget then
        self:ShowMainPanel()
    end
end

function InteractiveMgr:OnTimerAfterMajorSingOver()
    local Major = MajorUtil.GetMajor()
    if Major then
        local CrystalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
        local Crystals = CrystalMgr.CrystalList
        if Crystals then
            for _, Crystal in pairs(Crystals) do
                if Crystal and Crystal.TriggerActor and Crystal.TriggerActor:IsOverlappingActor(Major) then
                    local Params = _G.EventMgr:GetEventParams()
                    Params.IntParam1 = _G.LuaEntranceType.CRYSTAL
                    Params.ULongParam1 = Crystal.EntityID
                    _G.EventMgr:SendEvent(_G.EventID.EnterInteractionRange, Params)
                    break
                end
            end
        end
    end
end

function InteractiveMgr:OnEventUseItem(_)
    self.ProcessorUseItem:ApplyExeptionEntityID()
end

function InteractiveMgr:HideMainPanel()
    self:TriggerObjInteraction(0)
    _G.UIViewMgr:HideView(UIViewID.InteractiveMainPanel)
    self:StopTickTimer()
    --_G.GatherMgr:SendExitGatherState()
end

function InteractiveMgr:ShowMainPanel(bIsByManualSelect)
    --_G.FLOG_WARNING("InteractiveMgr:ShowMainPanel, %s", debug.traceback())
    local _ <close> = CommonUtil.MakeProfileTag("InteractiveMgr.ShowMainPanel")
    -- self:PrintInfo("InteractiveMgr:ShowMainPanel, bMainPanelClosedByOtherUI:%s, bEnableShowMainPanel:%s, bIsSinging:%s, IsCollectionState:%s, IsMajorCancelMounting:%s",
    --     tostring(self.bMainPanelClosedByOtherUI),
    --     tostring(self.bEnableShowMainPanel),
    --     tostring(self.bIsSinging),
    --     tostring(_G.GatherMgr:IsGatherState()),
    --     tostring(self.IsMajorCancelMounting))
    if self.bMainPanelClosedByOtherUI == true or
        not self.bEnableShowMainPanel or
        self.bIsSinging or
        _G.GatherMgr:IsGatherState() or
        self.IsMajorCancelMounting then
        return
    end

    --Sequenc播放的时候不展示交互列表了 or 目标标记界面打开的时候
    if self.CanShowInteractive == false or _G.SignsMgr.TargetSignsMainPanelIsShowing then
        self:PrintInfo("InteractiveMgr:ShowMainPanel, CanShowInteractive:%s, TargetSignsMainPanelIsShowing:%s",
            tostring(self.CanShowInteractive),
            tostring(_G.SignsMgr.TargetSignsMainPanelIsShowing))
        return
    end

    if self.EntranceUseItem then
        local _ <close> = CommonUtil.MakeProfileTag("InteractiveMgr.ShowMainPanel.ProcessorTick")
        self.ProcessorUseItem:ProcessorTick(true) -- ShowView之前先处理一遍，及时隐藏
    end

    local _ <close> = CommonUtil.MakeProfileTag("InteractiveMgr.ShowMainPanel.ShowView")
    _G.UIViewMgr:ShowView(UIViewID.InteractiveMainPanel)
    if nil ~= bIsByManualSelect and bIsByManualSelect == true then
        self:PrintInfo("InteractiveMgr:ShowMainPanel, IsByManualSelect")
        return
    end

    self.CurPhrase = InteractivePhrase.First

    self:ShowEntrances()
    self:StartTickTimer()
end

function InteractiveMgr:SetCanShowInteractive(CanShowInteractive)
    --FLOG_INFO("InteractiveMgr:SetCanShowInteractive, CanShowInteractive:%s", tostring(CanShowInteractive))
    self.CanShowInteractive = CanShowInteractive
    if self.CanShowInteractive then
        self:ShowInteractiveEntrance()
    end
end

function InteractiveMgr:SetNeedRecoveryInteractiveEntrance(bFlag)
    self.bNeedRecoveryEntrance = bFlag
end

function InteractiveMgr:OnClickEntranceItems()
	-- FLOG_INFO("Interactive Hide Entrance Items")
    if not self.bNeedRecoveryEntrance then
        self:HideEntrance()
    else
        self.bNeedRecoveryEntrance = false
    end
end

-- 展示对话中的功能选项，FunctionList为FunctionBase的列表，FunctionList为空列表时不展示功能选项
function InteractiveMgr:SetFunctionList(FunctionList, IsReset)
    local TempFuncList = {}
    for _, Func in ipairs(FunctionList) do
        table.insert(TempFuncList, Func)
    end
    self:ShowMainPanel()

    self.FunctionItemsList = TempFuncList
    self.IsResetCustomTalk = IsReset
    InteractiveMainPanelVM:SetFunctionItems(TempFuncList)
    self.CurPhrase = InteractivePhrase.Second
end

function InteractiveMgr:SaveLastTalk(CustomTalkID, OpoinID)
    if CustomTalkID  then
        self.LastCustomTalkID = CustomTalkID
    end
    if OpoinID and OpoinID ~= self.LastCustomTalkID then
        self.TempNotAvailableOptions[tostring(OpoinID)] = true
    end
end

function InteractiveMgr:GetLastCustomTalk()
    if self.LastCustomTalkID == nil then return false end
    return self.LastCustomTalkID, self.TempNotAvailableOptions
end

function InteractiveMgr:GetIsResetCustomTalk()
    return self.IsResetCustomTalk
end

function InteractiveMgr:ClearCustomData()
    self.LastCustomTalkID = nil
    self.IsResetCustomTalk = false
    self.TempNotAvailableOptions = {}
end

--目前采集在用，界面闪烁问题
function InteractiveMgr:UpdateGatherFunctionList(FunctionList)
    local IndxListToRemove = {}
    local FunctionItemsList = self.FunctionItemsList
    local CurCount = #FunctionItemsList
    for index = 1, CurCount do
        local FuncItem = FunctionItemsList[index]
        local ResID = FuncItem.ResID
        if ResID then
            local bFind = false
            for j = 1, #FunctionList do
                local FuncItem2 = FunctionList[j]
                if FuncItem2.ResID and FuncItem2.ResID == ResID then
                    bFind = true
                    FunctionItemsList[index] = FuncItem2
                    break
                end
            end

            if not bFind then
                table.insert(IndxListToRemove, 1, index)
            end
        end
    end

    for i = 1, #IndxListToRemove do
        table.remove(FunctionItemsList, IndxListToRemove[i])
    end

    InteractiveMainPanelVM:SetFunctionItems(FunctionList)
end

function InteractiveMgr:OnEntranceVisible(bShow)
    if bShow then
        self:StartTickTimer()
    else
        self:StopTickTimer()
        -- _G.GatherMgr:SendExitGatherState()
    end
end

function InteractiveMgr:QueryPWorldBranch()
    --_G.FLOG_INFO("InteractiveMgr:QueryPWorldBranch")
    local CrystalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
    if CrystalMgr:IsExistActiveCrystal(self.CurrentCrystalEntityID) and
        MapUtil.IsAcrossMapCrystal(self.CurrentCrystalEntityID) then
        -- 水晶交互需要查询地图分线情况
        --_G.FLOG_INFO("InteractiveMgr:QueryPWorldBranch, EntityID:%d", self.CurrentCrystalEntityID)
        _G.PWorldMgr:SendLineQuery()
    end
end

function InteractiveMgr:CheckExclusionInteractiveEObj()
    for _, IUnit in ipairs(self.InteractorParamsList) do
        local Cfg = EobjExclusionInteractionCfg:FindCfgByKey(IUnit.ResID)
        if nil ~= Cfg and nil ~= Cfg.IsExclusive and Cfg.IsExclusive == 1 then
            return true
        end
    end

    return false
end

function InteractiveMgr:OnGameEventEnterInteractionGuideRange(Params)
    local ActorType = Params.IntParam1
    local EntityID = Params.ULongParam1
    local ResID = Params.ULongParam2 or 0
    local ActorName = ActorUtil.GetActorName(EntityID)

    if not string.isnilorempty(ActorName) then
        self:PrintInfo("InteractiveMgr:OnGameEventEnterInteractionRange, EntityID:%d ResID:%d Type:%d ActorName:%s", EntityID, ResID, ActorType, ActorName)
    end

    if ActorType == _G.UE.EActorType.Npc then
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.NearTargetField --新手引导触发类型

        if _G.NpcMgr:IsChocoboNpcByNpcID(ResID) then
            EventParams.Param1 = TutorialDefine.NearTargetFieldType.Chocobo
        else
            EventParams.Param1 = TutorialDefine.NearTargetFieldType.NPC
            EventParams.Param2 = ResID
        end

        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end
end

--private
function InteractiveMgr:OnGameEventEnterInteractionRange(Params)
    if self.bLockTimer then 
        return  
    end
    local ActorType = Params.IntParam1
    local EntityID = Params.ULongParam1
    local ResID = Params.ULongParam2 or 0
    local ActorName = ActorUtil.GetActorName(EntityID)
    if not string.isnilorempty(ActorName) then
        self:PrintInfo("InteractiveMgr:OnGameEventEnterInteractionRange, EntityID:%d ResID:%d Type:%d ActorName:%s", EntityID, ResID, ActorType, ActorName)
    end

    if self.EnablePrintNormalLog then
        for index, value in ipairs(self.InteractorParamsList) do
           FLOG_INFO("InteractiveMgr:OnGameEventEnterInteractionRange, Exist ActorName:%s", ActorUtil.GetActorName(value.EntityID))
        end
    end

    -- if ActorType == _G.LuaEntranceType.EOBJ and self:CheckExclusionInteractiveEObj() then
    --     _G.FLOG_INFO("InteractiveMgr:OnGameEventEnterInteractionRange, is exclusion interactive eobj!")
    --     return
    -- end

    -- if ActorType == _G.UE.EActorType.Npc and self:IsActorDead(EntityID, ResID, ActorName) then
    --     return
    -- end

    if ActorType == _G.UE.EActorType.Monster and self:IsActorDead(EntityID, ResID, ActorName) then
        return
    end

    self.ProcessorUseItem:OnEnterRange(Params)

    --按键选怪是有专门的交互形式
    if ActorType == _G.UE.EActorType.Monster and nil ~= Params.IntParam2 and Params.IntParam2 > 0 then
        local Cfg = InteractivedescCfg:FindCfgByKey(Params.IntParam2)
        if Cfg and Cfg.FuncType == ProtoRes.interact_func_type.INTERACT_FUNC_CLICK_SELECT_MONSTER then
            _G.SelectMonsterMgr:OnGameEventEnterInteractionRange(Params)
            --_G.FLOG_ERROR("InteractiveMgr Enter Interactive Range EntityID:%d Type:%d", EntityID, ActorType)
            return
        end
    elseif ActorType == _G.LuaEntranceType.CRYSTAL then
        self.CurrentCrystalEntityID = EntityID
        --self:QueryPWorldBranch()
        --self:StartQueryPWorldBranchTimer()
    end

    do
        local _ <close> = CommonUtil.MakeProfileTag("InteractiveMgr.OnGameEventEnterInteractionRange.ShowMainPanel")
        self:ShowMainPanel()
    end
    for _, IUnit in ipairs(self.InteractorParamsList) do
        if IUnit.EntityID == EntityID and IUnit.TargetType == ActorType then
            if ActorType == _G.UE.EActorType.Gather then
                -- _G.FLOG_ERROR("InteractiveMgr Repeat Enter Interactive Range" .. EntityID)
            end

            return
        end
    end

    for _, IUnit in ipairs(self.InteractorParamsListToShow) do
        if IUnit.EntityID == EntityID and IUnit.TargetType == ActorType then
            if ActorType == _G.UE.EActorType.Gather then
                -- _G.FLOG_ERROR("InteractiveMgr Repeat Enter (ToShow) Interactive Range" .. EntityID)
            end

            return
        end
    end

    -- local IUnit = EntranceBase:New()
    -- IUnit.TargetType = ActorType
    -- IUnit.EntityID = Params.ULongParam1
    -- IUnit.ResID = ResID
    -- IUnit.Distance = ActorUtil.GetActorByEntityID(IUnit.EntityID):GetDistanceToMajor()
    local IUnit
    do
        local _ <close> = CommonUtil.MakeProfileTag("InteractiveMgr.OnGameEventEnterInteractionRange.CreateEntrance")
        IUnit = EntranceItemFactory:CreateEntrance(Params)
    end
    if (not IUnit) and (not self.EntranceUseItem) then
        _G.FLOG_ERROR("InteractiveMgr CreateEntrance Error (EntityID:%d, type:%d)", EntityID, ActorType)
        return
    end

    --FLOG_ERROR("OnGameEventEnterInteractionRange :"..debug.traceback())
    local bCanInteract = false

    do
        local _ <close> = CommonUtil.MakeProfileTag("InteractiveMgr.OnGameEventEnterInteractionRange.CanInterative")
        if IUnit and IUnit:CanInterative(true) then
            table.insert(self.InteractorParamsList, IUnit)
            self:ChangeSelectPriority()

            if ActorType == _G.UE.EActorType.Gather then
                self:PrintInfo("InteractiveMgr Enter Interactive Range EntityID:%d EntranceNum:%d", EntityID, #self.InteractorParamsList)
            end

            --table.sort(self.InteractorParamsList, function(a, b) return a.Distance < b.Distance end)
            bCanInteract = true
        end
    end

    if self.EntranceUseItem then
        bCanInteract = true
    end

    if bCanInteract then

        --新手引导第一次遇到或者进入可交互相关触发处理
        do
            if ActorType == _G.UE.EActorType.Npc then

            elseif ActorType == _G.UE.EActorType.Gather then
                local Cfg = GatherPointCfg:FindCfgByKey(ResID)

                if Cfg ~= nil then
                    local EventParams = _G.EventMgr:GetEventParams()
                    EventParams.Type = TutorialDefine.TutorialConditionType.NearTargetField --新手引导触发类型
                    --这是限时采集
                    if Cfg.RarePopTime ~= nil and Cfg.RarePopTime > 0 then
                        EventParams.Param1 = TutorialDefine.NearTargetFieldType.LimitTimeGather
                        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
                    else
                        EventParams.Param1 = TutorialDefine.NearTargetFieldType.Gather
                        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
                    end
                end
            end
        end

        if InteractiveMainPanelVM.FunctionVisible then
            self:PrintInfo("InteractiveMgr FunctionVisible, pass entrance")
            --显示二级交互的时候，如果有entrance的变化，只更新InteractorParamsList
            return
        end

        if not InteractiveMainPanelVM:GetFunctionVisible() then
            local _ <close> = CommonUtil.MakeProfileTag("InteractiveMgr.OnGameEventEnterInteractionRange.ShowEntrances")
            self:ShowEntrances()
        else
            local _ <close> = CommonUtil.MakeProfileTag("InteractiveMgr.OnGameEventEnterInteractionRange.SetEntranceItems")
            self:SetEntranceItems()
        end
    elseif (IUnit ~= nil) then
        self:PrintWarning("InteractiveMgr Enter Interactive Range but can not Interact: %d, %s", EntityID, ActorName)
        table.insert(self.InteractorParamsListToShow, IUnit)
    end
end

--只是控制显示
function InteractiveMgr:ShowEntrances()
    if self:IsMajorPlayingDialogue() or not self.bEnableShowMainPanel then
        return
    end

    self.CurPhrase = InteractivePhrase.First
    --FLOG_INFO("InteractiveMgr:ShowEntrances, TargetNum:%d", #self.InteractorParamsList)

    if (#self.InteractorParamsList > 0) or (self.EntranceUseItem) then
        self:PrintInfo("InteractiveMgr:ShowEntrances true")
        local _ <close> = CommonUtil.MakeProfileTag("InteractiveMgr.ShowEntrances.SetEntrancesVisible")
        InteractiveMainPanelVM:SetEntrancesVisible(true)
        local _ <close> = CommonUtil.MakeProfileTag("InteractiveMgr.ShowEntrances.ShowOrHideMainPanel")
        self:ShowOrHideMainPanel(true)
        local _ <close> = CommonUtil.MakeProfileTag("InteractiveMgr.ShowEntrances.SetEntranceItems")
        self:SetEntranceItems()
    end

    self.CurInteractFuncItem = nil

    -- _G.GatherMgr:SendExitGatherState()
end

--把数据重新刷一遍
function InteractiveMgr:RefreshEntances()
    self:SetEntranceItems()
end

function InteractiveMgr:OnUpdateQuest()
    self.ProcessorUseItem:ClearAllException()
    if self:UpdateInteractiveList(true) then
        if not InteractiveMainPanelVM.FunctionVisible and
         not InteractiveMainPanelVM.EntranceVisible and
         not self:IsMajorPlayingDialogue() then
            InteractiveMainPanelVM:SetEntrancesVisible(true)
        end
        if self:IsNeedHideEntrances() then
            self:HideEntrance()
        else
            if not self.IsEntranceDelayShowing then
                self:ShowInteractiveEntrance()
            end
        end
        self:SetEntranceItems()
        self:PrintInfo("InteractiveMgr:OnUpdateQuest listNum:%d", #self.InteractorParamsList)
    end
end

--private
function InteractiveMgr:UpdateInteractorList()
    if self.bLockTimer then 
        return  
    end

    local _ <close> = CommonUtil.MakeProfileTag("InteractiveMgr.UpdateInteractorList")
    self:UpdateInteractiveList(self.EnablePrintCheckLog)

    for _, IUnit in ipairs(self.InteractorParamsList) do
        IUnit:UpdateDistance()
        -- IUnit.Distance = ActorUtil.GetActorByEntityID(IUnit.EntityID):GetDistanceToMajor()
    end

    local InteractorNum = #self.InteractorParamsList
    --FLOG_INFO("InteractiveMgr:UpdateInteractorList, InteractorNum:%d", InteractorNum)
    if InteractorNum > 0 then
        if not InteractiveMainPanelVM:GetFunctionVisible() then
            InteractiveMainPanelVM:SetEntrancesVisible(true)
        end
    end

    if InteractorNum == 0 or self.InteractiveTargetIndex > InteractorNum or self.bIsSelectPrioritized then
        self.InteractiveTargetIndex = 1
        InteractiveMainPanelVM:SetInteractiveTargetIndex(self.InteractiveTargetIndex)
    end

    --table.sort(self.InteractorParamsList, function(a, b) return a.Distance < b.Distance end)
    self:SortInteractorParamsList()

    local bNeedRefresh = false

    if InteractorNum > 0 then
        if self.LastInteractiveObjEntityID ~= self.InteractorParamsList[self.InteractiveTargetIndex].EntityID or
            self.LastInteractiveEntance ~= self.InteractorParamsList[self.InteractiveTargetIndex] then
            bNeedRefresh = true
            --self.LastInteractiveEntance = self.InteractorParamsList[1]
            --self.LastInteractiveObjEntityID = self.InteractorParamsList[1].EntityID
        end
    else
        if nil ~= self.LastInteractiveEntance then
            bNeedRefresh = true
            self.LastInteractiveEntance = nil
        end
    end

    if self.LastUseItemEntrance ~= self.EntranceUseItem then
        bNeedRefresh = true
        self.LastUseItemEntrance = self.EntranceUseItem
    end

    if bNeedRefresh then
        self:SetEntranceItems()
    end

    if self:IsNeedHideEntrances() then
        --FLOG_INFO("InteractiveMgr:ShowEntrances false")
        self:HideEntrance()
        InteractiveMainPanelVM:SetFunctionVisible(false)
        self:TriggerObjInteraction(0)
    end

    InteractiveMainPanelVM:SetTargetSwitchVisible(InteractorNum > 1)
end

function InteractiveMgr:HideTargetSwitchPanel()
    InteractiveMainPanelVM:SetTargetSwitchVisible(false)
end

function InteractiveMgr:IsMajorPlayingDialogue()
    --_G.FLOG_WARNING("InteractiveMgr:IsMajorPlayingDialogue, %s", debug.traceback())
    --local IsNpcDialogueMainPanelShowed = _G.NpcDialogMgr:IsDialogPanelVisible()
    local _ <close> = CommonUtil.MakeProfileTag("InteractiveMgr.IsMajorPlayingDialogue.IsNpcDialogueMainPanelShowed")
    local IsNpcDialogueMainPanelShowed = _G.UIViewMgr:IsViewVisible(_G.UIViewID.NpcDialogueMainPanel)
    local _ <close> = CommonUtil.MakeProfileTag("InteractiveMgr.IsMajorPlayingDialogue.IsDialogueMainPanelShowed")
    local IsDialogueMainPanelShowed = _G.UIViewMgr:IsViewVisible(_G.UIViewID.DialogueMainPanel)
    -- self:PrintInfo("InteractiveMgr:IsMajorPlayingDialogue, IsNpcDialogueMainPanelShowed:%s, IsDialogueMainPanelShowed:%s",
    --     tostring(IsNpcDialogueMainPanelShowed), tostring(IsDialogueMainPanelShowed))
    return IsNpcDialogueMainPanelShowed or IsDialogueMainPanelShowed
end

function InteractiveMgr:IsTakingPhoto()
    --_G.FLOG_WARNING("InteractiveMgr:IsTakingPhoto, %s", debug.traceback())
    local IsPhotoMainMainPanelShowed = _G.UIViewMgr:IsViewVisible(_G.UIViewID.PhotoMain)
    self:PrintInfo("InteractiveMgr:IsMajorPlayingDialogue, IsPhotoMainMainPanelShowed:%s", tostring(IsPhotoMainMainPanelShowed))
    return IsPhotoMainMainPanelShowed
end

function InteractiveMgr:IsNeedHideEntrances()
    local CurEntityID = nil ~= self.LastInteractiveEntance and self.LastInteractiveEntance.EntityID or 0
    -- _G.FLOG_INFO("InteractiveMgr:IsNeedHideEntrances, IsGathering:%s, bMainPanelClosedByOtherUI:%s, IsDoingEmotion:%s, IsMajorCancelMounting:%s, IsInFishState:%s, IsInMiniGame:%s, IsPlayingSequence:%s, IsTreasureHuntBoxOpened:%s, IsPendingDisableMerchant:%s, MountHide:%s",
    --     tostring(_G.GatherMgr:IsGatherState()),
    --     tostring(self.bMainPanelClosedByOtherUI),
    --     tostring(self.bIsDoingEmotion),
    --     tostring(self.IsMajorCancelMounting),
    --     tostring(_G.FishMgr:IsInFishState()),
    --     tostring(_G.GoldSaucerMiniGameMgr:CheckIsInMiniGame()),
    --     tostring(_G.StoryMgr:SequenceIsPlaying()),
    --     tostring(_G.TreasureHuntMgr:IsTreasureHuntBoxOpened(CurEntityID)),
    --     tostring(_G.MysterMerchantMgr:IsPendingDisableMerchant(CurEntityID)),
    --     tostring(_G.MountMgr:IsNeedHideInteractiveEntrances()))
    
    return (MajorUtil.IsGatherProf() and _G.GatherMgr:IsGatherState()) or
        --_G.GoldSaucerMiniGameMgr:CheckIsInMiniGame() or
        self.bMainPanelClosedByOtherUI or
        self.bIsDoingEmotion or
        self.IsMajorCancelMounting or
        _G.FishMgr:IsInFishState() or
        _G.StoryMgr:SequenceIsPlaying() or 
        --_G.TreasureHuntMgr:IsTreasureHuntBoxOpened(CurEntityID) or
        _G.MysterMerchantMgr:IsPendingDisableMerchant(CurEntityID) or
        _G.MountMgr:IsNeedHideInteractiveEntrances()
end

function InteractiveMgr:OnEventActorLeaveVision(Params)
    if nil == Params then
        return
    end

    local EntityID = 0
    if nil ~= Params.ULongParam1 then
        EntityID = Params.ULongParam1
    end

    local IsNeedRefreshEntrance = false
    local InteractorNum = #self.InteractorParamsList
    if InteractorNum > 0 and self.InteractiveTargetIndex <= InteractorNum and
        self.InteractorParamsList[self.InteractiveTargetIndex].EntityID == EntityID then 
        IsNeedRefreshEntrance = true
    end

    -- local ActorName = ActorUtil.GetActorName(EntityID) or ""
    -- local selectTargetName = ActorUtil.GetActorName(self.LastSelectedTargetEntityID)
    -- _G.FLOG_INFO("InteractiveMgr:OnEventActorLeaveVision, EntityID:%d ActorName:%s, SelectedTarget:%d, Name:%s",
    --     EntityID, ActorName, self.LastSelectedTargetEntityID, selectTargetName)
    if self.bHasSpecialSelectedTarget and EntityID ~= 0 and EntityID == self.LastSelectedTargetEntityID then
        self:CancelTargetInteractive()
    end

    if nil ~= Params.IntParam1 and Params.IntParam1 ~= _G.UE.EActorType.Gather then
        for index, value in ipairs(self.InteractorParamsList) do
            if value.EntityID == 0 or value.EntityID == EntityID then
                table.remove(self.InteractorParamsList, index)
                break
            end
        end
    end

    if IsNeedRefreshEntrance then 
        self:SetEntranceItems()
    end
end

function InteractiveMgr:OnEventActorDestroy(Params)
    -- local EntityID = Params.ULongParam1 or 0
    -- local ActorName = ActorUtil.GetActorName(EntityID) or ""
    -- _G.FLOG_INFO("InteractiveMgr:OnEventActorDestroy: EntityID:%d ActorName:%s", EntityID, ActorName)
    local IsNeedRefreshEntrance = false
    local InteractorNum = #self.InteractorParamsList
    if InteractorNum > 0 and self.InteractiveTargetIndex <= InteractorNum and
        self.InteractorParamsList[self.InteractiveTargetIndex].EntityID == Params.ULongParam1 then 
        IsNeedRefreshEntrance = true
    end
    if (Params.IntParam1 ~= _G.UE.EActorType.Gather) then
        for index, value in ipairs(self.InteractorParamsList) do
            if value.EntityID == 0 or value.EntityID == Params.ULongParam1 then
                table.remove(self.InteractorParamsList, index)
                break
            end
        end
    end

    if IsNeedRefreshEntrance then 
        self:SetEntranceItems()
    end
end

function InteractiveMgr:ClearEntranceByType(TargetType, RefreshEntrances)
    for index = #self.InteractorParamsList, 1, -1 do
        if self.InteractorParamsList[index].TargetType == TargetType then
            table.remove(self.InteractorParamsList, index)
        end
    end

    if RefreshEntrances then
        self:SetEntranceItems()
    end
end

--private
function InteractiveMgr:OnGameEventLeaveInteractionRange(Params)
    if self.bLockTimer then 
        return  
    end
    local EntityID = Params.ULongParam1 or 0
    local ActorName = ActorUtil.GetActorName(EntityID) or ""
    if not string.isnilorempty(ActorName) then
        self:PrintInfo("InteractiveMgr Leave Interactive Range: EntityID:%d, ActorName:%s", EntityID, ActorName)
    end

    if self.EnablePrintNormalLog then
        for index, value in ipairs(self.InteractorParamsList) do
            FLOG_INFO("InteractiveMgr:OnGameEventLeaveInteractionRange, Exist ActorName:%s", ActorUtil.GetActorName(value.EntityID))
        end
    end

    self.ProcessorUseItem:OnLeaveRange(Params)

    --按键选怪是有专门的交互形式
    if Params.IntParam1 == _G.UE.EActorType.Monster and nil ~= Params.IntParam2 and Params.IntParam2 > 0 then
        local Cfg = InteractivedescCfg:FindCfgByKey(Params.IntParam2)
        if Cfg and Cfg.FuncType == ProtoRes.interact_func_type.INTERACT_FUNC_CLICK_SELECT_MONSTER then
            _G.SelectMonsterMgr:OnGameEventLeaveInteractionRange(Params)
            return
        end
    end

    local bRemove = false

    for index, value in ipairs(self.InteractorParamsList) do
        if value.EntityID == EntityID then
            bRemove = true
            table.remove(self.InteractorParamsList, index)
            break
        end
    end

    if #self.InteractorParamsList == 0 and self.bHasSpecialSelectedTarget == false and nil == self.EntranceUseItem then
        self:PrintInfo("InteractiveMgr:OnGameEventLeaveInteractionRange, HideMainPanel")
        self:HideMainPanel()
    end
    --self:SwitchSelectedTarget(Params, false)
    if not bRemove then
        for index, value in ipairs(self.InteractorParamsListToShow) do
            if value.EntityID == EntityID then
                table.remove(self.InteractorParamsListToShow, index)
                return
            end
        end
    end

    if not bRemove then
        --矿山逻辑比较特殊，多个有一个Entrance，所以可能leave的entityid和矿山第一个enter的entityid不是同一个
        --走到这个函数，肯定是当前没有采集物了，所以矿山这种入口也就没了
        local ActorType = ActorUtil.GetActorType(EntityID)
        if ActorType == _G.UE.EActorType.Gather then
            local Cfg = GatherPointCfg:FindCfgByKey(Params.ULongParam2)
            if Cfg then
                local GatherTypeOfLeaveEntity = Cfg.GatherType
                for index, value in ipairs(self.InteractorParamsList) do
                    if value.TargetType == _G.UE.EActorType.Gather then
                        local CfgOfCur = GatherPointCfg:FindCfgByKey(value.ResID)
                        local GatherTypeOfCur = CfgOfCur.GatherType
                        if GatherTypeOfLeaveEntity == GatherTypeOfCur then
                            table.remove(self.InteractorParamsList, index)
                            break
                        end
                    end
                end
            end
        end
    end

    if self.CurInteractEntityID == EntityID or #self.InteractorParamsList == 0 then
        self:ExitInteractive()
    end

    self:SetEntranceItems()

    if (#self.InteractorParamsList == 0) and (self.EntranceUseItem == nil) then
        self:HideEntrance()
        -- --交互类型是采集物的才执行以下逻辑
        -- if Params.IntParam1 == _G.LuaEntranceType.GATHER then
        --     local CurGatherID = _G.GatherMgr.CurActiveEntityID or 0
        --     if CurGatherID > 0 and CurGatherID == EntityID then
        --         _G.GatherMgr:DelayHidePanel(1.9)
        --     end
        --     FLOG_INFO("InteractiveMgr:OnGameEventLeaveInteractionRange GatherMgr:DelayHidePanel Cur:%d EntityID:%d", CurGatherID, EntityID)
        -- end
    end

    --如果没有其他交互，关闭二级交互；假设还有其他一级交互，旧二级也关闭，所以这里直接关闭
    InteractiveMainPanelVM:SetFunctionVisible(false)

    _G.EventMgr:SendEvent(_G.EventID.TriggerObjInteractive, { IsActive = false, EntityID = EntityID })
    --self.LastInteractiveObjEntityID = 0

    if Params.IntParam1 == _G.LuaEntranceType.CRYSTAL then
        --InteractiveMainPanelVM:SetEnableShowBranchLineEntrance(nil)
        self.CurrentCrystalEntityID = 0
        self.bHasPWorldBranch = false
        self:StopQueryPWorldBranchTimer()
    end
end

function InteractiveMgr:OnGameEventPWorldExit(Params)
    self.ProcessorUseItem:OnPWorldExit(Params)
end

function InteractiveMgr:SetFunctionViewID(ViewID)
    self.CurrentFunctionViewID = ViewID
end

function InteractiveMgr:ClearFunctionViewID()
    self.CurrentFunctionViewID = 0
end

--交互中显示ui的，使用该接口
function InteractiveMgr:ShowView(ViewID, bShowImmediatdly, Params)
    if bShowImmediatdly then
        _G.UIViewMgr:ShowView(ViewID, Params)
    end

    self.CurrentFunctionViewID = ViewID
end

-- 一级交互项的click：被按类型封装到各个EntranceBase的子类了，比如EntranceNpc
function InteractiveMgr:OnEntranceClick(EntranceItem)
    local EntityID = EntranceItem.EntityID
    self.CurInteractEntityID = EntityID
    self.CurInteractEntrance = EntranceItem

    CommonUtil.XPCall(self, self.EnterInteractive)

    self.CurInteractFuncItem = nil
    self:StopMajorMoveForFixedTime(self.TimeToStopMajorMove)
    self:PrintInfo("=========== InteractiveMgr Begin Interactive: "..EntityID)
    --如果这里返回true，就不会再调用EntranceBase子类的OnClick
    --也就是说这里给了改写的机会
    return false
end

function InteractiveMgr:EnterInteractive()
    self.IsEnterInteractiveState = true
    _G.EventMgr:SendEvent(EventID.EnterInteractive, self.CurInteractEntrance)
end

function InteractiveMgr:ExitInteractive()
    if self.IsEnterInteractiveState then
        local ExitInteractiveFunc =  function()
            self:PrintInfo("=========== InteractiveMgr:ExitInteractive ")
            _G.EventMgr:SendEvent(EventID.ExitInteractive)
        end

        self.IsEnterInteractiveState = false

        _G.NpcDialogMgr:ResumeCamera()  --兜底保障下

        CommonUtil.XPCall(nil, ExitInteractiveFunc)
    end
end

function InteractiveMgr:CurEntranceReClick()
    if self.CurInteractEntrance and InteractiveMainPanelVM:GetFunctionVisible() then
        self.CurInteractEntrance:Click()
    end
end

function InteractiveMgr:HideFunctionItem(EntityID)
    for index = 1, #self.FunctionItemsList do
        if self.FunctionItemsList[index].EntityID == EntityID then
            table.remove(self.FunctionItemsList, index)

            if #self.FunctionItemsList == 0
                or #self.FunctionItemsList == 1 and (self.FunctionItemsList[1].FuncType == LuaFuncType.QUIT_FUNC or self.FunctionItemsList[1].FuncType == LuaFuncType.NPCQUIT_FUNC) then
                self:ShowEntrances()
                self:ExitInteractive()
                self:SetEntranceItems()
            else
                self:SetFunctionList(self.FunctionItemsList)
            end
            break
        end
    end
end

function InteractiveMgr:HideFunctionItemByFuncType(EntityID, FuncType)
    for index = 1, #self.InteractorParamsList do
        if self.InteractorParamsList[index].EntityID == EntityID then
            local FunctionItemsList = self.InteractorParamsList[index].FunctionItemsList
            if nil ~= FunctionItemsList then
                for func_index = 1, #FunctionItemsList do
                    if FunctionItemsList[func_index].InteractivedescCfg ~= nil and FunctionItemsList[func_index].InteractivedescCfg.FuncType == FuncType then
                        table.remove(FunctionItemsList, func_index)

                        if #FunctionItemsList == 0
                        or #FunctionItemsList == 1 and (FunctionItemsList[1].FuncType == LuaFuncType.QUIT_FUNC or FunctionItemsList[1].FuncType == LuaFuncType.NPCQUIT_FUNC) then
                            self:ShowEntrances()
                            self:ExitInteractive()
                            self:SetEntranceItems()
                        else
                            self:SetFunctionList(FunctionItemsList)
                        end
                        return
                    end
                end
            end
        end
    end
end

function InteractiveMgr:OnPreFunctionItemClick(FunctionItem)
    self.CurInteractFuncItem = FunctionItem

    -- 1：隐藏二级列表 2：返回一级列表  0：不做任何变化，保持在二级列表
	self:PrintInfo("Interactive PreClickFunctionItems: Hide Function Items and show entrance")
	if FunctionItem.UIOPWhenClick == 1 then
		InteractiveMainPanelVM:SetFunctionVisible(false)
	elseif FunctionItem.UIOPWhenClick == 2 then
		InteractiveMainPanelVM:SetEntrancesVisible(true)
        self:SetEntranceItems()
	end
end

-- function InteractiveMgr:OnPostFunctionItemClick(FunctionItem, ClickRlt)
--     if ClickRlt then
--         --click已经处理了，但至于该item是否该从二级交互消失，得看具体逻辑吧
--         --比如npc接任务，任务接取完成后就没了；采集物得采集成功后才能消失
--     else
--     end
-- end

function InteractiveMgr:AddEntranceUseItem(ItemID, QuestTargetID)
    self:PrintInfo("InteractiveMgr:AddEntranceUseItem ItemID=%d QuestTargetID=%d", (ItemID or 0), (QuestTargetID or 0))
    self.ProcessorUseItem:AddProcessorUnit(ItemID, QuestTargetID)
end

function InteractiveMgr:RemoveEntranceUseItem(ItemID, QuestTargetID)
    self:PrintInfo("InteractiveMgr:RemoveEntranceUseItem ItemID=%d QuestTargetID=%d", (ItemID or 0), (QuestTargetID or 0))
    self.ProcessorUseItem:RemoveProcessorUnit(ItemID, QuestTargetID)
end

function InteractiveMgr:ShowEntranceUseItem(EntranceParams, bIntendedCall)
    if self.EntranceUseItem == nil then
        self.EntranceUseItem = EntranceItemFactory:CreateSharedEntrance(EntranceParams)
    end
    self.EntranceUseItem:UpdateEntrance(EntranceParams)

    if not bIntendedCall then -- 从定时器调用过来才会触发以下逻辑
        if not InteractiveMainPanelVM.FunctionVisible and not InteractiveMainPanelVM.EntranceVisible then
            InteractiveMainPanelVM:SetEntrancesVisible(true)
        end
    end
end

function InteractiveMgr:HideEntranceUseItem()
    local OldEntrance = self.EntranceUseItem
    self.EntranceUseItem = nil
    if (OldEntrance ~= nil) and (self.EntranceUseItem == nil) then
        self:SetEntranceItems()
    end
end

function InteractiveMgr:HideEntrance()
    InteractiveMainPanelVM:SetEntrancesVisible(false)
end

function InteractiveMgr:SetExeptionUseItem(ItemID, EntityID)
    self.ProcessorUseItem:SetPreExeptionEntityID(ItemID, EntityID)
end

---------------------------------------- private ----------------------------------------
---
function InteractiveMgr:UpdateInteractiveList(EnableCheckLog)

    local IndxListToRemove = {}
    local bNeedRefresh = false

    -- _G.FLOG_INFO("InteractiveMgr listnum:%d", #self.InteractorParamsList)
    --Show=>Hide
    for i = 1, #self.InteractorParamsList do
        local IUnit = self.InteractorParamsList[i]
        if not IUnit:CanInterative(EnableCheckLog) then
            self:PrintInfo("InteractiveMgr UpdateInteractorList Show=>Hide Entrance:" .. IUnit.EntityID)
            table.insert(self.InteractorParamsListToShow, IUnit)
            table.insert(IndxListToRemove, 1, i)

            bNeedRefresh = true
        else
            bNeedRefresh = true
        end
    end

    -- {3, 2, 1}
    for i = 1, #IndxListToRemove do
        table.remove(self.InteractorParamsList, IndxListToRemove[i])
    end

    --Hide=>Show
    -- IndxListToRemove = {}
    for i = #self.InteractorParamsListToShow, 1, -1 do
        local IUnit = self.InteractorParamsListToShow[i]
        if IUnit:CanInterative(EnableCheckLog) then
            self:PrintInfo("InteractiveMgr UpdateInteractorList Hide=>Show Entrance:" .. IUnit.EntityID)
            table.insert(self.InteractorParamsList, IUnit)
            self:ChangeSelectPriority()
            -- table.insert(IndxListToRemove, 1, i)
            table.remove(self.InteractorParamsListToShow, i)

            bNeedRefresh = true
        end
    end

    -- for i = #IndxListToRemove, 1, -1 do
    --     table.remove(self.InteractorParamsListToShow, IndxListToRemove[i])
    -- end

    self:PrintCurInteractionInfo()

    return bNeedRefresh
end

function InteractiveMgr:StartTickTimer()
    if not self.UpdateListTimerID then
        --FLOG_INFO("InteractiveMgr:StartTickTimer")
        self.UpdateListTimerID = self:RegisterTimer(self.UpdateInteractorList, 0, 0.2, 0)
    end
end

function InteractiveMgr:StopTickTimer()
    if self.UpdateListTimerID then
        --FLOG_WARNING("InteractiveMgr:StopTickTimer, %s", debug.traceback())
        self:UnRegisterTimer(self.UpdateListTimerID)
        self.UpdateListTimerID = nil
    end
end

--对话结束，进行上报    --Npc:1004346
function InteractiveMgr:OnGameEventFinishDialog(Params)
    local CurFuncItem = self.CurInteractFuncItem
    if CurFuncItem and CurFuncItem.InteractivedescCfg then
        local FuncTypeCfg = self.FuncTypeCfgMap[CurFuncItem.InteractivedescCfg.FuncType]
        if FuncTypeCfg and FuncTypeCfg.Report ~= 0 then
            self:SendReport(CurFuncItem)
        end
    end
end

---------------------------------------- private ----------------------------------------
function InteractiveMgr:SendReport(CurFuncItem)
    self:PrintInfo("InteractiveMgr:SendReport")
    local InteractiveDescID = CurFuncItem.InteractivedescCfg.ID
    local MsgID = ProtoCS.CS_CMD.CS_CMD_INTERAVIVE
    local SubMsgID = ProtoCS.CsInteractionCMD.CsInteractionCMDReport

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID

    local FuncTypeCfg = self.FuncTypeCfgMap[CurFuncItem.InteractivedescCfg.FuncType]
    if not FuncTypeCfg or FuncTypeCfg.Report == 0 then
        FLOG_ERROR("InteractiveMgr SendReport Error")
        return
    end

    local ObjType, ObjID = ActorUtil.GetInteractionObjInfo(CurFuncItem.EntityID)
    if not ObjType then
        FLOG_ERROR("Interactive SendReport ObjType is nil")
        return
    end

    if FuncTypeCfg.Report >= ProtoRes.interaction_report.interaction_report_npc_distance then
        MsgBody.Report =
        {
            InteractionID = InteractiveDescID,
            Obj = {ObjID = ObjID, Type = ObjType}
        }
    else
        FLOG_ERROR("InteractiveMgr SendReport Report is none")
        return
    end

    self:PrintInfo("InteractiveMgr SendReport InteractiveID: %d", InteractiveDescID)
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--EntityID：选中的target
function InteractiveMgr:UpdateGatherEntranceVisible(IUnit, EntityID)
    local NeedRefresh = false

    if IUnit.TargetType == _G.UE.EActorType.Gather then
        if IUnit.EntityID == EntityID then
            IUnit.IsSelectOtherGatherPoint = false
            NeedRefresh = true
        else
            IUnit.IsSelectOtherGatherPoint = true
            NeedRefresh = true
        end
    end

    return NeedRefresh
end

function InteractiveMgr:ResetAllGatherEntranceVisible()
    local IUnit = nil
    local NeedRefresh = false

    for index = #self.InteractorParamsList, 1, -1 do
        IUnit = self.InteractorParamsList[index]
        if IUnit.TargetType == _G.UE.EActorType.Gather then
            IUnit.IsSelectOtherGatherPoint = false
            NeedRefresh = true
        end
    end

    for index = #self.InteractorParamsListToShow, 1, -1 do
        IUnit = self.InteractorParamsListToShow[index]
        if IUnit.TargetType == _G.UE.EActorType.Gather then
            IUnit.IsSelectOtherGatherPoint = false
            NeedRefresh = true
        end
    end

    return NeedRefresh
end

function InteractiveMgr:SetEntranceItems()
    local _ <close> = CommonUtil.MakeProfileTag("InteractiveMgr.SetEntranceItems.SortInteractorParamsList")
    self:SortInteractorParamsList()

    -- if #self.InteractorParamsList > 0 and self.LastInteractiveObjEntityID == self.InteractorParamsList[1].EntityID then
    --     return
    -- end
    local _ <close> = CommonUtil.MakeProfileTag("InteractiveMgr.SetEntranceItems.SetEntranceItems")
    InteractiveMainPanelVM:SetEntranceItems(self.InteractorParamsList, self.EntranceUseItem)
end

function InteractiveMgr:OnGameEventShowUI(ViewID)
    --_G.FLOG_INFO("InteractiveMgr:OnGameEventShowUI, ViewID=%s", _G.UIViewID:IDToName(ViewID))
    if nil ~= ViewID and self:IsMutuallyExclusiveShowUI(ViewID) then
        self:AddToMutuallyExclusiveShowUIList(ViewID)
        if InteractiveMainPanelVM:GetFixedFunctionVisible() == true then
            self:PrintInfo("InteractiveMgr:OnGameEventShowUI, close FixedFunctionPanel!")
            if ViewID ~= UIViewID.PhotoMain then
                self.bFixedFuncPanelClosedByOtherUI = true
            end

            local IsNeedUnselectTarget = true
            if nil ~= self.LastSelectedTargetEntityID and self.LastSelectedTargetEntityID ~= 0 and
                self:IsSpecialSelectInteractiveTarget(self.LastSelectedTargetEntityID) then
                IsNeedUnselectTarget = false
            end

            if IsNeedUnselectTarget then
                self:OnUnSelectTarget()
            end
        end

        self.bMainPanelClosedByOtherUI = true
        self:StopTickTimer()
        self:HideEntranceUseItem()
        self:HideEntrance()
        InteractiveMainPanelVM:SetFunctionVisible(false)
    end
end

function InteractiveMgr:OnGameEventHideUI(Params)
    local ViewID = Params
    --_G.FLOG_INFO("Interactive Hide CurInteractEntityID="..self.CurInteractEntityID..", cur Function ViewID="..self.CurrentFunctionViewID)
    if ViewID == self.CurrentFunctionViewID and ActorUtil.GetActorType(self.CurInteractEntityID) == _G.UE.EActorType.Npc then
        --这个hideui的通道没法知道点击的取消，所以回到了一级交互，这个地方体验有点不好。。。加CurPhrase这个逻辑也没办法
        -- 所以CurPhrase 暂时无效，不管其正确性了
        _G.EventMgr:SendEvent(EventID.ClickNextDialog)
    end

    --_G.FLOG_INFO("InteractiveMgr:OnGameEventHideUI, ViewID=%s", _G.UIViewID:IDToName(ViewID))
    if nil ~= ViewID and self:IsMutuallyExclusiveShowUI(ViewID) then
        self:RemoveFromMutuallyExclusiveShowUIList(ViewID)

        if #self.MutuallyExclusiveShowUIList == 0 then
            if self.bFixedFuncPanelClosedByOtherUI == true then
                self:PrintInfo("InteractiveMgr:OnGameEventHideUI, open FixedFunctionPanel.")
                self.bFixedFuncPanelClosedByOtherUI = false
                if self.LastSelectedTargetEntityID ~= 0 then
                    local CurSelectedPlayerEntityID = self.CurSelectedPlayerEntityID
                    local CurSelectedPlayerIndex = self.CurSelectedPlayerIndex
                    self:OnManualSelectTarget(self.LastSelectedTargetParams)
                    self.CurSelectedPlayerEntityID = CurSelectedPlayerEntityID
                    self.CurSelectedPlayerIndex = CurSelectedPlayerIndex
                elseif self.LastSelectedTargetParams.ULongParam1 ~= 0 then
                    -- if self:IsSpecialSelectInteractiveTarget(self.LastSelectedTargetParams.ULongParam1) and self:IsValidManualSelectTarget() then
                    --     InteractiveMainPanelVM:SetFixedFunctionVisible(true)
                    --     _G.EventMgr:SendEvent(EventID.FixedFunctionPanelShowed, { IsShow = true })
                    -- end
                end
            end
            if self.bMainPanelClosedByOtherUI == true then
                self:PrintInfo("InteractiveMgr:OnGameEventHideUI, open MainPanel.")
                self.bMainPanelClosedByOtherUI = false
                self:StartTickTimer()
            end

            if self.EntranceUseItem == nil then
                self.ProcessorUseItem:ProcessorTick(true)
            end

            --恢复的时候，触发下显示交互界面
            if (self.InteractorParamsList and #self.InteractorParamsList > 0)
                or (self.EntranceUseItem ~= nil) or self.bHasSpecialSelectedTarget then
                    self:ShowMainPanel()
                end
        end
    end
end

function InteractiveMgr:OnManualSelectTarget(Params)
    if self:IsMajorPlayingDialogue() or self.bLockTimer then
        return
    end

    self:ResetNearByPlayerCheck()

    local EntityID = Params.ULongParam1
    local ResID = ActorUtil.GetActorResID(EntityID)
    Params.ULongParam2 = ResID
    local SelectActor = ActorUtil.GetActorByEntityID(EntityID)
    local Distance = 0.0
    if nil ~= SelectActor then
        local MajorActor = MajorUtil.GetMajor()
        local MajorPos = MajorActor:FGetActorLocation()
        local SelectActorPos = SelectActor:FGetActorLocation()
        local SelectActorToMajor = ((SelectActorPos.X - MajorPos.X) ^ 2) + ((SelectActorPos.Y - MajorPos.Y) ^ 2) + ((SelectActorPos.Z - MajorPos.Z) ^ 2)
        --Distance = SelectActor:GetDistanceToMajor()
        Distance = math.sqrt(SelectActorToMajor)
    end
    local ActorType = ActorUtil.GetActorType(EntityID)
    Params.IntParam1 = ActorType

    local IUnit = nil
    local NeedRefresh = false
    if ActorType == _G.UE.EActorType.Gather then
        for index = #self.InteractorParamsList, 1, -1 do
            IUnit = self.InteractorParamsList[index]
            if self:UpdateGatherEntranceVisible(IUnit, EntityID) then
                NeedRefresh = true
            end
        end

        for index = #self.InteractorParamsListToShow, 1, -1 do
            IUnit = self.InteractorParamsListToShow[index]
            if self:UpdateGatherEntranceVisible(IUnit, EntityID) then
                NeedRefresh = true
            end
        end
    else
        --重置所有采集点的
        if self:ResetAllGatherEntranceVisible() then
            NeedRefresh = true
        end
    end

    if NeedRefresh then
        if self:UpdateInteractiveList(true) then
            self:SetEntranceItems()
        end
    end

    local ActorName = ActorUtil.GetActorName(EntityID) or ""
    self:PrintInfo("InteractiveMgr:OnManualSelectTarget, ActorName=%s, ActorType=%d, ActorSubType=%d, Distance=%f",
        ActorName, ActorType, ActorUtil.GetActorSubType(EntityID), Distance)

    if self:IsCanDoBehavior() == false then
        return
    end

    if self:IsSpecialSelectInteractiveTarget(EntityID) then
        -- 某些情况不处理点选其他玩家/宠物/搭档的交互功能：
        -- 玩家处在战斗状态
        -- 能工巧匠各个职业制作状态、钓鱼状态、采集状态、决斗状态
        -- 某些副本中
        
        if ActorType == _G.UE.EActorType.Companion then
            local MajorEntityID = MajorUtil.GetMajorEntityID()
            local IsCombatState = ActorUtil.IsCombatState(MajorEntityID)
            if IsCombatState then
                self:ShowTips(MsgTipsID.CombatStateCantInteraction)
                return
            end
        end

        if _G.FishMgr:IsInFishState() or _G.GatherMgr:IsGatherState() or _G.CrafterMgr:GetIsMaking() or _G.WolvesDenPierMgr:IsInDuel() then
            return
        end
        
		if ActorType == _G.UE.EActorType.Player then
            -- 水晶冲突副本里
            if _G.PWorldMgr:CurrIsInPVPColosseum() then
                return
            end
            -- 其他副本里
            -- if _G.PWorldMgr:CurrIsInDungeon() then
            --     return
            -- end
        end
    end

    self:SwitchSelectedTarget(Params, true)
    self:GetSelectedTargetType(EntityID, ActorType)
    --点选功能仅对其他玩家，宠物和搭档生效(特殊情况：目前Major骑上搭档后，搭档无法被单独点选)
    if self:IsSpecialSelectInteractiveTarget(EntityID) and self:IsValidManualSelectTarget() then
        local bIsCanDoManualSelectBehavior = self:IsCanDoManualSelectBehavior()
        if bIsCanDoManualSelectBehavior == false then
            _G.FLOG_WARNING("InteractiveMgr:OnManualSelectTarget, Major is not in manual select state, do not show panel!")
        end
        if #self.MutuallyExclusiveShowUIList > 0 then
            self:PrintInfo("InteractiveMgr:OnManualSelectTarget, mutually exclusive by other UI.")
            return
        end
        self.bHasSpecialSelectedTarget = true
        local CanBeSelectedInteractiveRange = _G.UE.UHUDMgr:Get():GetVisibleRange()
        if bIsCanDoManualSelectBehavior and nil ~= CanBeSelectedInteractiveRange and Distance <= CanBeSelectedInteractiveRange then
            self:ShowSelectedTargetFunctionPanel(EntityID)
        else
            self:HideSelectedTargetFunctionPanel()
        end
    else
        --其他的可点选交互物（如NPC）在通用交互范围内点击时，需要显示通用交互入口
        self.bHasSpecialSelectedTarget = false
        local CommonInteractiveDistance = 0
        if nil ~= SelectActor then
            CommonInteractiveDistance = SelectActor:GetCommonInteractiveDistance()
        end
        self.bIsSelectPrioritized = true
        local bIsCanSelectInteractive = CommonInteractiveDistance ~= 0 and Distance <= CommonInteractiveDistance
        if nil ~= bIsCanSelectInteractive and bIsCanSelectInteractive == true then
            self:ChangeSelectPriority()
            self.InteractiveTargetIndex = 1
            InteractiveMainPanelVM:SetInteractiveTargetIndex(self.InteractiveTargetIndex)
            self:OnGameEventEnterInteractionRange(self.LastSelectedTargetParams)
        end
    end
end

function InteractiveMgr:OnUnSelectTarget(Params)
    if self.bLockTimer then 
        return  
    end
    local EntityID = 0
    if nil ~= Params then
        EntityID = Params.ULongParam1 or 0
        _G.EmotionMgr:SetNewTargetEntityID(0)
    elseif self.LastSelectedTargetEntityID ~= 0 then
        EntityID = self.LastSelectedTargetEntityID or 0
    end
    local ActorName = ActorUtil.GetActorName(EntityID) or ""
    self:PrintInfo("InteractiveMgr:OnUnSelectTarget, ActorName=%s, EntityID=%d", ActorName, EntityID)
    local ActorType = ActorUtil.GetActorType(EntityID)
    if ActorType == _G.UE.EActorType.Gather then
        --重置所有采集点的
        if self:ResetAllGatherEntranceVisible() then
            if self:UpdateInteractiveList(true) then
                self:SetEntranceItems()
            end
        end
    end

    if InteractiveMainPanelVM:GetFixedFunctionVisible() == true then
        self:HideSelectedTargetFunctionPanel()
    end

    if self.LastSelectedTargetEntityID ~= 0 and not self:NeedRecoveryEnterInteraction(self.LastSelectedTargetParams) then
        self:OnGameEventLeaveInteractionRange(self.LastSelectedTargetParams)
    end

    if #self.InteractorParamsList > 0 and ActorType ~= _G.UE.EActorType.Gather then
        if not _G.DiscoverNoteMgr:IsNeedDoNotShowInteractivePanelWhenUnSelectMajor(EntityID) then
            self:PrintInfo("InteractiveMgr:OnUnSelectTarget, there are still interactable targets within range.")
            self:ShowMainPanel()
        end
    end

    self.bIsSelectPrioritized = false

    self:ChangeSelectPriority()

    self.LastSelectedTargetEntityID = 0
    self.bHasSpecialSelectedTarget = false
    self:ResetNearByPlayerCheck()
end

function InteractiveMgr:OnTeamMemberBeSelected(Params)
    local TargetEntityID = Params.ULongParam1
    local MajorEntityID = MajorUtil:GetMajorEntityID()
    if TargetEntityID ~= 0 then
        if Params.ULongParam1 == MajorEntityID then
            self:HideSelectedTargetFunctionPanel()
        else
            if InteractiveMainPanelVM:GetFixedFunctionVisible() and #self.FixedFunctionItemsList > 0 then
                for i = 1, #self.FixedFunctionItemsList do
                    local IUnit = self.FixedFunctionItemsList[i]
                    IUnit:SetEntityID(TargetEntityID)
                end
            end
        end
    end
end

function InteractiveMgr:ChangeSelectPriority()
    for _, IUnit in ipairs(self.InteractorParamsList) do
        if IUnit.EntityID == self.LastSelectedTargetEntityID and self.bIsSelectPrioritized then
            IUnit:SetSelectPriority(1)
        else
            IUnit:SetSelectPriority(0)
        end
    end
    --self:SortInteractorParamsList()
end

function InteractiveMgr:SortInteractorParamsList()
    if #self.InteractorParamsList > 1 then
        -- 交互目标的优先级：点选>切换选中>主线任务>类型>距离
        table.sort(self.InteractorParamsList, function(A, B)
            if self.bIsSelectPrioritized then
                return A.SelectPriority > B.SelectPriority
            else
                if nil ~= A.CheckWithMainQuest then
                    A:CheckWithMainQuest()
                end
                if nil ~= B.CheckWithMainQuest then
                    B:CheckWithMainQuest()
                end

                if A.IsWithMainQuest > B.IsWithMainQuest then
                    return true
                elseif A.IsWithMainQuest < B.IsWithMainQuest then
                    return false
                end

                if A.InteractivePriority > B.InteractivePriority then
                    return true
                elseif A.InteractivePriority < B.InteractivePriority then
                    return false
                end

                return A.Distance < B.Distance
            end
        end)
    end

    -- if self.bIsSelectPrioritized then
    --     table.sort(self.InteractorParamsList, function(a, b) return a.SelectPriority > b.SelectPriority end)
    -- else
    --     table.sort(self.InteractorParamsList, function(a, b) return a.Distance < b.Distance end)
    -- end
end

function InteractiveMgr:NeedRecoveryEnterInteraction(Params)
    local EntityID = Params.ULongParam1
    local SelectActor = ActorUtil.GetActorByEntityID(EntityID)

    if SelectActor == nil then
        return false
    end

    local Distance = SelectActor:GetDistanceToMajor()
    if not self:IsSpecialSelectInteractiveTarget(EntityID) then
        local CommonInteractiveDistance = SelectActor:GetCommonInteractiveDistance()
        if CommonInteractiveDistance ~= 0 and Distance <= CommonInteractiveDistance then
            return true
        end
    end

    return false
end


function InteractiveMgr:SwitchSelectedTarget(Params, IsEnter)
    if nil ~= Params then
        local EntityID = Params.ULongParam1
        if IsEnter == true then
            if self.LastSelectedTargetEntityID ~= 0 and self.LastSelectedTargetEntityID ~= EntityID then
                self:OnUnSelectTarget()
            end
            self.LastSelectedTargetEntityID = EntityID
            self.LastSelectedTargetParams.ULongParam1 = Params.ULongParam1
            self.LastSelectedTargetParams.ULongParam2 = Params.ULongParam2
            self.LastSelectedTargetParams.IntParam1 = Params.IntParam1
            self.LastSelectedTargetParams.IntParam2 = Params.IntParam2
        else
            _G.UE.USelectEffectMgr:Get():UnSelectActor(EntityID)
        end
    end
end

function InteractiveMgr:IsSpecialSelectInteractiveTarget(EntityID)
    local ActorType = ActorUtil.GetActorType(EntityID)
    local ActorSubType = ActorUtil.GetActorSubType(EntityID)
    if ActorType == _G.UE.EActorType.Player or
        ActorType == _G.UE.EActorType.Companion or
        ActorType == _G.UE.EActorType.Summon or
        ActorType == _G.UE.EActorType.Monster and ActorSubType == _G.UE.EActorSubType.Buddy then
        return true
    end

    return false
end

function InteractiveMgr:OnFightSkillPanelShowed(Param)
    if nil ~= Param then
        if Param == self.bPanelShowed then
            return
        end
        self.bPanelShowed = Param
        if Param == true then
            --self:CancelTargetInteractive()
            if InteractiveMainPanelVM:GetFixedFunctionVisible() == true then
                self:HideSelectedTargetFunctionPanel()
            end
        else
            if nil ~= self.LastSelectedTargetEntityID and self.LastSelectedTargetEntityID ~= 0 then
                if self:IsSpecialSelectInteractiveTarget(self.LastSelectedTargetEntityID) then
                    self:ShowSelectedTargetFunctionPanel(self.LastSelectedTargetEntityID)
                end
            end
        end
    end
end

function InteractiveMgr:CancelTargetInteractive()
    _G.TargetMgr:EndHardLockEffect()
    _G.UE.USelectEffectMgr:Get():UnSelectActor(self.LastSelectedTargetEntityID)

    if _G.AetherCurrentsMgr.SingVfxID ~= nil then
        return -- 针对监修临时处理主界面控制按钮的展开事件判断，屏蔽风脉泉吟唱的情况
    end
    self:OnUnSelectTarget()
end

SpecialSelectTargetType = SpecialSelectTargetType or
{
    None = 0,
    Player = 1,             --其他玩家
    MajorBuddy = 2,         --主角的搭档
    MajorCompanion = 3,     --主角的宠物
    OtherBuddy = 4,         --其他玩家的搭档
    OtherCompanion = 5,     --其他玩家的宠物
    Summon = 6,             --召唤兽
}

InteractiveMgr.SelectedTargetType = SpecialSelectTargetType.None

function InteractiveMgr:IsValidManualSelectTarget()
    self.CurManualSelectInteractionCfg = ManualSelectInteractionCfg:FindCfgByKey(self.SelectedTargetType)
    if nil ~= self.CurManualSelectInteractionCfg and
        nil ~= self.CurManualSelectInteractionCfg.InteractionIDList and
        #self.CurManualSelectInteractionCfg.InteractionIDList > 0 then
        return true
    end
    return false
end

function InteractiveMgr:ShowSelectedTargetFunctionPanel(EntityID)
    --_G.FLOG_INFO("InteractiveMgr:ShowSelectedTargetFunctionPanel")

    local ResID = ActorUtil.GetActorResID(EntityID)
    local ActorType = ActorUtil.GetActorType(EntityID)
    self:GetSelectedTargetType(EntityID, ActorType)

    if self.SelectedTargetType ~= SpecialSelectTargetType.None then
        self:ShowMainPanel(true)
        self:HideEntrance()
        InteractiveMainPanelVM:SetFunctionVisible(false)
        self:ResetWorldViewObjEntranceItem()
        self.bFoundFindWorldViewObj = false

        local SelectActor = ActorUtil.GetActorByEntityID(EntityID)
        if ActorType == _G.UE.EActorType.Player then
            self:GetNearByPlayers(SelectActor, EntityID)
            if #self.NearByPlayers > 1 then
                if not self.DistanceBetweenPlayersTimer then
                    self.DistanceBetweenPlayersTimer = self:RegisterTimer(self.UpdateNearByPlayersByDistance, 0, 0.1, 0)
                end
            else
                self:ResetNearByPlayerCheck()
            end
        else
            self:ResetNearByPlayerCheck()
        end

        local Cfg = self.CurManualSelectInteractionCfg
        local FuncList = {}
        if nil ~= Cfg then
            local IdList = Cfg.InteractionIDList
            for i = 1, #IdList do
                local IsNeedInteractFunctionUnit = true
                if IdList[i] == self.DuelInteractiveID then
                    local CurMapResID = _G.PWorldMgr:GetCurrMapResID()
                    if CurMapResID ~= self.EnableDuelMapID then
                        IsNeedInteractFunctionUnit = false
                    end
                end
                if IsNeedInteractFunctionUnit then
                    local InteractFunctionUnit = FunctionItemFactory:CreateInteractiveDescFunc({FuncValue = IdList[i], EntityID = EntityID, ResID = ResID})
                    if InteractFunctionUnit then
                        table.insert(FuncList, InteractFunctionUnit)
                    end
                end
            end
        else
            _G.FLOG_ERROR("It has no special select interaction config, please check again!")
        end

        self:SetFixedFunctionItems(FuncList)

        _G.EventMgr:SendEvent(EventID.FixedFunctionPanelShowed, { IsShow = true })
    end
end

function InteractiveMgr:IsTargetOwnedByMajor(EntityID)
    local AttributeComponent = ActorUtil.GetActorAttributeComponent(EntityID)
	local OwnerEntityID = AttributeComponent.Owner
    local MajorEntityID = MajorUtil.GetMajorEntityID()
	if OwnerEntityID and OwnerEntityID == MajorEntityID then
		return true
	end

    return false
end

function InteractiveMgr:GetSelectedTargetType(EntityID, ActorType)
    local ActorSubType = ActorUtil.GetActorSubType(EntityID)
    if ActorType == _G.UE.EActorType.Player then
        self.SelectedTargetType = SpecialSelectTargetType.Player
    elseif ActorType == _G.UE.EActorType.Companion then
        if self:IsTargetOwnedByMajor(EntityID) then
            self.SelectedTargetType = SpecialSelectTargetType.MajorCompanion
        else
            self.SelectedTargetType = SpecialSelectTargetType.OtherCompanion
        end
    elseif ActorType == _G.UE.EActorType.Monster and ActorSubType == _G.UE.EActorSubType.Buddy then
        if self:IsTargetOwnedByMajor(EntityID) then
            self.SelectedTargetType = SpecialSelectTargetType.MajorBuddy
        else
            self.SelectedTargetType = SpecialSelectTargetType.OtherBuddy
        end
    elseif ActorType == _G.UE.EActorType.Summon then
        self.SelectedTargetType = SpecialSelectTargetType.Summon
    --[[ elseif ActorType == _G.UE.EActorType.Major and _G.MountMgr:IsInRide() then
        self.SelectedTargetType = SpecialSelectTargetType.MajorBuddy ]]
    end
end

function InteractiveMgr:HideSelectedTargetFunctionPanel()
    --_G.FLOG_INFO("InteractiveMgr:HideSelectedTargetFunctionPanel")
    InteractiveMainPanelVM:SetFixedFunctionVisible(false)
    --self:ResetNearByPlayerCheck()
    _G.EventMgr:SendEvent(EventID.FixedFunctionPanelShowed, { IsShow = false })
end

function InteractiveMgr:OnSkillMultiChoicePanelShowed(Params)
    if nil ~= Params and Params.IsDisplayed == true then
        InteractiveMainPanelVM:MakeMainPanelVisible(false)
    else
        InteractiveMainPanelVM:MakeMainPanelVisible(true)
    end
end

function InteractiveMgr:AddToMutuallyExclusiveShowUIList(ViewID)
    local bFound = false
    for i = 1, #self.MutuallyExclusiveShowUIList do
        if ViewID == self.MutuallyExclusiveShowUIList[i] then
            bFound = true
            break
        end
    end
    if not bFound then
        table.insert(self.MutuallyExclusiveShowUIList, ViewID)
    end
end

function InteractiveMgr:RemoveFromMutuallyExclusiveShowUIList(ViewID)
    for k, v in pairs(self.MutuallyExclusiveShowUIList) do
        if ViewID == v then
            table.remove(self.MutuallyExclusiveShowUIList, k)
            break
        end
    end
end

function InteractiveMgr:IsMutuallyExclusiveShowUI(ViewID)
    for _, Value in ipairs(MutuallyExclusiveUIConfig) do
        if Value == ViewID then
            return true
        end
    end
    return false
end

function InteractiveMgr:FindWorldViewObj()
    if not self:EnableFindWorldViewObj() then
        return
    end

    local MajorEntityID = MajorUtil.GetMajorEntityID()
    local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(MajorEntityID)
    --PlayerAnimInst:EndChair(MajorEntityID)

    if PlayerAnimInst then
        local IsWorldViewObj = PlayerAnimInst:FindChair(MajorEntityID)

        if self.bFoundFindWorldViewObj ~= IsWorldViewObj then
            if IsWorldViewObj == true then
                self:PrintInfo("InteractiveMgr:FindWorldViewObj, found world view object!")
                local IsBed = PlayerAnimInst:FindBed(MajorEntityID)
                --IsBed = false
                if IsBed ~= true then
                    self:CreateWorldViewInteractionEntrance()
                else
                    self:PrintInfo("InteractiveMgr:FindWorldViewObj, it is a bed!")
                end
            else
                --self.WorldViewObjEntranceItem = nil
                self:ResetWorldViewObjEntranceItem()
            end
            if nil ~= self.WorldViewObjEntranceItem and not self:IsMajorPlayingDialogue() then
                self:ShowMainPanel()
            end
            --InteractiveMainPanelVM:SetWorldViewObjEntranceItem(self.WorldViewObjEntranceItem)
        end
        self.bFoundFindWorldViewObj = IsWorldViewObj
    end
end

function InteractiveMgr:EnableFindWorldViewObj()
    if self.bHasSpecialSelectedTarget or self.EntranceUseItem ~= nil or
        InteractiveMainPanelVM:GetFunctionVisible() or not self.bEnableShowMainPanel then
        return false
    end

    local Major = MajorUtil.GetMajor()
    if Major and Major:GetRideComponent():IsInRide() then
        self:ResetWorldViewObjEntranceItem()
        return false
    end

    return true
end

function InteractiveMgr:CreateWorldViewInteractionEntrance()
    local Params = {}
    Params.IntParam1 =  _G.LuaEntranceType.WorldViewObj
    Params.ULongParam1 = _G.LuaEntranceType.WorldViewObj
    Params.ULongParam2 = 0
    self.WorldViewObjEntranceItem = EntranceItemFactory:CreateEntrance(Params)
    if not self.WorldViewObjEntranceItem then
        _G.FLOG_ERROR("InteractiveMgr:CreateWorldViewInteractionEntrance, CreateEntrance Error!")
        return
    end

    table.insert(self.InteractorParamsList, self.WorldViewObjEntranceItem)
    self:ChangeSelectPriority()
end

function InteractiveMgr:OnUseWorldViewObj(Param)
    --_G.FLOG_INFO("InteractiveMgr:OnUseWorldViewObj")
    if nil ~= Param and nil ~= Param.IsSitState then
        if Param.IsSitState then
            self:ResetWorldViewObjEntranceItem()
            self.bFoundFindWorldViewObj = true
        else
            self.bFoundFindWorldViewObj = false
        end
    end
    self:ResetWorldViewObjEntranceItem()
end

function InteractiveMgr:OnClickWorldViewObjEntranceItem()
    --_G.FLOG_INFO("InteractiveMgr:OnClickWorldViewObjEntranceItem")
    self:ResetWorldViewObjEntranceItem()
end

function InteractiveMgr:OnGameEventPostEmotionEnter(Params)
	local FromID = Params.ULongParam1
	local MajorID = MajorUtil.GetMajorEntityID()
	local EmotionID = Params.IntParam1
    --_G.FLOG_INFO("InteractiveMgr:OnGameEventPostEmotionEnter, FromID:%d, MajorID:%d, EmotionID:%d", FromID, MajorID, EmotionID)
    if FromID == MajorID then
        --self.bIsDoingEmotion = true
        if _G.EmotionMgr.IsSitEmotionID(EmotionID) or _G.EmotionMgr:IsBedEmotion(EmotionID) then
            self.bEnableShowMainPanel = false
            self:PrintInfo("InteractiveMgr:OnGameEventPostEmotionEnter, HideMainPanel, bEnableShowMainPanel = false")
            self:HideMainPanel()
        end
    end
end

function InteractiveMgr:OnGameEventPostEmotionEnd(Params)
	local FromID = Params.ULongParam1
	local MajorID = MajorUtil.GetMajorEntityID()
	local EmotionID = Params.IntParam1
    --_G.FLOG_INFO("InteractiveMgr:OnGameEventPostEmotionEnd, FromID:%d, MajorID:%d, EmotionID:%d", FromID, MajorID, EmotionID)
    if FromID == MajorID then
        --self.bIsDoingEmotion = false
        if _G.EmotionMgr.IsSitEmotionID(EmotionID) or _G.EmotionMgr:IsBedEmotion(EmotionID) then
            self:PrintInfo("InteractiveMgr:OnGameEventPostEmotionEnd, bEnableShowMainPanel = true")
            self.bEnableShowMainPanel = true
        end
    end

    self:ShowInteractiveEntrance()
end

-- 是否在其他模组功能的进行过程中屏蔽交互显示
function InteractiveMgr:BlockInteractEntranceByOtherModule()
    -- self:PrintInfo("InteractiveMgr:BlockInteractEntranceByOtherModule, IsInMiniGame:%s, DiscoverIsInInteract:%s, bIsSinging:%s, IsMajorPlayingDialogue:%s, IsOnPhoto:%s",
    --     tostring(_G.GoldSaucerMiniGameMgr:CheckIsInMiniGame()),
    --     tostring(_G.DiscoverNoteMgr:CheckIsInInteract()),
    --     tostring(self.bIsSinging),
    --     tostring(self:IsMajorPlayingDialogue()),
    --     tostring(_G.PhotoMgr.IsOnPhoto))
    return _G.GoldSaucerMiniGameMgr:CheckIsInMiniGame() or
        _G.DiscoverNoteMgr:CheckIsInInteract() or
        self.bIsSinging == true or
        self:IsMajorPlayingDialogue() or
        _G.PhotoMgr.IsOnPhoto
end

function InteractiveMgr:ShowInteractiveEntrance()
    if #self.InteractorParamsList > 0 then
        if self.bEnableShowMainPanel and not _G.UIViewMgr:IsViewVisible(UIViewID.InteractiveMainPanel) then
            self:ShowMainPanel()
        end

        if not self:BlockInteractEntranceByOtherModule() then
            if not InteractiveMainPanelVM:GetEntrancesVisible() and
                not InteractiveMainPanelVM:GetFunctionVisible() then
                    InteractiveMainPanelVM:SetEntrancesVisible(true)
            end
        else
            InteractiveMainPanelVM:SetEntrancesVisible(false)
        end
    end
end

function InteractiveMgr:SetMainPanelIsVisible(View, IsVisible)
    --_G.FLOG_WARNING("InteractiveMgr:SetMainPanelIsVisible, %s", debug.traceback())
    self:PrintInfo("InteractiveMgr:SetMainPanelIsVisible, IsVisible=%s", tostring(IsVisible))
    UIUtil.SetIsVisible(View, IsVisible)
end

function InteractiveMgr:UpdateInteractorItems(TargetType)
    for _, IUnit in ipairs(self.InteractorParamsList) do
        if IUnit.TargetType == TargetType and IUnit.Update then
            IUnit:Update()
        end
    end
    for _, IUnit in ipairs(self.InteractorParamsListToShow) do
        if IUnit.TargetType == TargetType and IUnit.Update then
            IUnit:Update()
        end
    end
    self:SortInteractorParamsList()
end

function InteractiveMgr:OnUpdateChocoboTransportNpcBookStatus()
    self:UpdateInteractorItems(_G.UE.EActorType.Npc)
end

function InteractiveMgr:OnGameEventCrystalActivated()
    --FLOG_INFO("InteractiveMgr:OnGameEventCrystalActivated")
    self:UpdateInteractorItems(_G.LuaEntranceType.CRYSTAL)
end

function InteractiveMgr:ResetWorldViewObjEntranceItem()
    if nil ~= self.WorldViewObjEntranceItem then
        self:PrintInfo("InteractiveMgr:ResetWorldViewObjEntranceItem")
        for Index = 1, #self.InteractorParamsList do
            if self.InteractorParamsList[Index].TargetType == _G.LuaEntranceType.WorldViewObj then
                table.remove(self.InteractorParamsList, Index)
                break
            end
        end
        self.WorldViewObjEntranceItem = nil
        --InteractiveMainPanelVM:SetWorldViewObjEntranceItem(self.WorldViewObjEntranceItem)
        self.bFoundFindWorldViewObj = false
        if #self.InteractorParamsList == 0 and self.bHasSpecialSelectedTarget == false then
            self:PrintInfo("InteractiveMgr:ResetWorldViewObjEntranceItem, HideMainPanel")
            self:HideMainPanel()
        end
    end
end

function InteractiveMgr:TriggerObjInteraction(EntityID)
    if self.LastInteractiveObjEntityID ~= EntityID then
        if self.LastInteractiveObjEntityID ~= 0 then
            -- _G.FLOG_INFO("InteractiveMgr:TriggerObjInteraction, DisactiveEntityID=%d, ActorName=%s",
            --     self.LastInteractiveObjEntityID, ActorUtil.GetActorName(self.LastInteractiveObjEntityID))
            _G.EventMgr:SendEvent(_G.EventID.TriggerObjInteractive, { IsActive = false, EntityID = self.LastInteractiveObjEntityID })
        end
        if EntityID ~= 0 then
            -- _G.FLOG_INFO("InteractiveMgr:TriggerObjInteraction, ActiveEntityID=%d, ActorName=%s",
            --     EntityID, ActorUtil.GetActorName(EntityID))
            _G.EventMgr:SendEvent(_G.EventID.TriggerObjInteractive, { IsActive = true, EntityID = EntityID })
            self:ShowTriggerEffect(EntityID)
        end
        self.LastInteractiveObjEntityID = EntityID
    end
    for Index = 1, #self.InteractorParamsList do
        if self.LastInteractiveObjEntityID == self.InteractorParamsList[Index].EntityID then
            self.LastInteractiveEntance = self.InteractorParamsList[Index]
            break
        end
    end
end

function InteractiveMgr:ShowTriggerEffect(EntityID)
    if (_G.StoryMgr:SequenceIsPlaying()) or _G.FishMgr:IsInFishState() or EntityID == self.LastInteractiveObjEntityID then
        return
    end

    self.ActorAvatarComponent = ActorUtil.GetActorAvatarComponent(EntityID)
    if nil ~= self.ActorAvatarComponent then
        local function Callback()
            local Curve = _G.ObjectMgr:GetObject(self.SelectEffectCurve)
            if Curve and nil ~= self.ActorAvatarComponent then
                self:PlaySelectedSound(EntityID)
                self.ActorAvatarComponent:StartSelect(Curve)
            end
        end

        local SelectColorIntensityCurve = _G.ObjectMgr:GetObject(self.SelectEffectCurve)
        if SelectColorIntensityCurve then
            --_G.FLOG_INFO("InteractiveMgr:ShowTriggerEffect, use cache!")
            self:PlaySelectedSound(EntityID)
            self.ActorAvatarComponent:StartSelect(SelectColorIntensityCurve)
        else
            _G.ObjectMgr:LoadObjectAsync(self.SelectEffectCurve, Callback)
        end
    end
end

function InteractiveMgr:PlaySelectedSound(EntityID)
    local ActorType = ActorUtil.GetActorType(EntityID)
    if ActorType == _G.UE.EActorType.Npc then
        AudioUtil.LoadAndPlayUISound(self.SelectedSound)
    end
end

function InteractiveMgr:ShowPersonalSimpleInfoView(EntityID)
    if EntityID then
        local EntityVM = _G.ActorMgr:FindActorVM(EntityID)
        if nil ~= EntityVM and EntityVM.RoleID then
            _G.PersonInfoMgr:ShowPersonalSimpleInfoView(EntityVM.RoleID)
        end
    end
end

function InteractiveMgr:OnGameEventFateUpdate(Params)
    local Fate = Params
    if (Fate == nil or Fate.NPCEntityID == nil) then
        return
    end

    if Fate.State > ProtoCS.FateState.FateState_WaitNPCTrigger then
        local IUnit = self.CurInteractEntrance
        if IUnit ~= nil and IUnit.EntityID == Fate.NPCEntityID and IUnit.TargetType == _G.UE.EActorType.Npc then
            IUnit:UpdateListByFateStart()
        end

        for _, IUnit in ipairs(self.InteractorParamsList) do
            if (IUnit.EntityID == Fate.NPCEntityID  and IUnit.TargetType == _G.UE.EActorType.Npc) then
                IUnit:UpdateListByFateStart()
            end
        end
    end
end

function InteractiveMgr:OnPWorldLineQueryResult(Params)
    self.bHasPWorldBranch = false
    if nil ~= Params and nil ~= Params.bHasPWorldBranch then
        self.bHasPWorldBranch = Params.bHasPWorldBranch
    end

    if nil ~= self.CurCrystalEntrance then
        self.CurCrystalEntrance:AfterClickEntrance()
    end
end

function InteractiveMgr:OnFishEnd(Flag)
    if Flag then
        self:StartTickTimer()
    end
end

function InteractiveMgr:OnCombatStateChanged(Param)
    if nil ~= Param and Param.IsFight == false then
        if #self.InteractorParamsList > 0 and self.InteractorParamsList[1].TargetType ~= _G.LuaEntranceType.GATHER then
            self:PrintInfo("InteractiveMgr:OnCombatStateChanged, there are still interactable targets within range.")
            self:ShowMainPanel()
        end
    end
end

function InteractiveMgr:SwitchInteractiveTarget()
    local Interactors = #self.InteractorParamsList
    if Interactors <= 1 then
        self:PrintInfo("InteractiveMgr:SwitchInteractiveTarget, not need to switch target, interactors:%d", Interactors)
        return
    end

    local bNeedRefreshIndex = true

    if self.bIsSelectPrioritized then
        self.InteractiveTargetIndex = 1
        local LastSelectedTargetEntityID = self.LastSelectedTargetEntityID
        self:CancelTargetInteractive()
        if LastSelectedTargetEntityID ~= self.InteractorParamsList[self.InteractiveTargetIndex].EntityID then
            bNeedRefreshIndex = false
        end
    end

    if bNeedRefreshIndex then
        self.InteractiveTargetIndex = self.InteractiveTargetIndex + 1
        if self.InteractiveTargetIndex > Interactors then
            self.InteractiveTargetIndex = 1
        end
    end

    self:PrintInfo("InteractiveMgr:SwitchInteractiveTarget, InteractiveTargetIndex=%d", self.InteractiveTargetIndex)
    InteractiveMainPanelVM:SetInteractiveTargetIndex(self.InteractiveTargetIndex)
    self:SetEntranceItems()
end

function InteractiveMgr:ShowOrHideMainPanel(bShow)
    if bShow then
        if self.bNeedRecoveryMainPanel then
            self:PrintInfo("InteractiveMgr:ShowOrHideMainPanel, show")
            if _G.QuestMgr.isUnlockProf or (MajorUtil.IsGatherProf() and _G.GatherMgr:IsGatherState()) or self.IsEnterInteractiveState then
                return
            end
            self.bNeedRecoveryMainPanel = false
            _G.BusinessUIMgr:ShowMainPanel(_G.UIViewID.MainPanel,true)
        end
    else
        self:PrintInfo("InteractiveMgr:ShowOrHideMainPanel, hide")
        _G.BusinessUIMgr:HideMainPanel(_G.UIViewID.MainPanel, true)
        self:DisableJoyStickAndInput()
        self.bNeedRecoveryMainPanel = true
    end
end

function InteractiveMgr:InteractionProhibitedState()
    -- -- 攀爬状态下不支持交互操作
    -- if ActorUtil.IsClimbingState(MajorUtil.GetMajorEntityID()) then
    --     self:ShowTips(MsgTipsID.ClimbingStateCantInteraction)
    --     return true
    -- end

    -- -- 游泳状态下不支持交互操作
    -- local Major = MajorUtil.GetMajor()
    -- if nil ~= Major and Major:IsSwimming() then
    --     self:ShowTips(MsgTipsID.SwimmingStateCantInteraction)
    --     return true
    -- end

    -- 死亡状态下不支持交互操作
    if MajorUtil.IsMajorDead() == true then
        self:ShowTips(MsgTipsID.DeadStateCantInteraction)
        return true
    end

    return false
end

function InteractiveMgr:IsActorDead(EntityID, ResID, ActorName)
    local ActorStateComponent = ActorUtil.GetActorStateComponent(EntityID)
    if nil ~= ActorStateComponent and ActorStateComponent:IsDeadState() then
        self:PrintInfo("InteractiveMgr:IsActorDead, ResID:%d, ActorName:%s", ResID, ActorName)
        return true
    end

    return false
end

function InteractiveMgr:IsCanDoBehavior(IgnoreStateArray)
    local Result = CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_INTERACTION, true, IgnoreStateArray)
    if not Result then
        self:RegisterTimer(function()
            self:StartTickTimer()
        end, 2, 1, 1)
    end

    return Result
end

function InteractiveMgr:IsCanDoManualSelectBehavior(IgnoreStateArray)
    local Result = CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_INTERACTOR_MANUAL_SELECT, false, IgnoreStateArray)
    if not Result then
        self:RegisterTimer(function()
            self:StartTickTimer()
        end, 2, 1, 1)
    end

    return Result
end

function InteractiveMgr:ShowTips(TipsID)
    _G.MsgTipsUtil.ShowTipsByID(TipsID)

    local function Callback()
        self:StartTickTimer()
    end

    self:RegisterTimer(Callback, 2, 1, 1)
end

function InteractiveMgr:OnRecievePlayVfx(MsgBody)
    local Msg = MsgBody.Vfx
    if nil == Msg then
        return
    end
    ---获取动效id
    local VfxID = Msg.VfxID
    if nil == VfxID then
        return
    end
    local RoleID = Msg.RoleID
    if nil == RoleID then
        return
    end
    -- ATL 类别
    if Msg.Type and Msg.Type == 1 then
        self:PlayItemUsedPlayATL(VfxID, RoleID)
        return
    end
    local bTargetSelf = Msg.TargetSelf
    if nil == bTargetSelf then
        return
    end
    self:PlayItemUsedVfx(VfxID, RoleID, bTargetSelf)
end

function InteractiveMgr:PlayItemUsedPlayATL(VfxID, RoleID)
    local EntityID = ActorUtil.GetEntityIDByRoleID(RoleID)
    if EntityID then
        local IsMajor = MajorUtil.IsMajor(EntityID)
        if not IsMajor then
            -- 视野不显示的玩家无需播放特效
            local Actor = ActorUtil.GetActorByRoleID(RoleID)
            if Actor~= nil then
                local VisionLoadMeshState = Actor:GetVisionLoadMeshState()
                if VisionLoadMeshState ~= _G.UE.EVisionLoadMeshState.E_LOADED_SHOW then
                    return
                end
            end
        end
        local ActionCfg = ActiontimelinePathCfg:FindCfgByKey(VfxID)
        if ActionCfg and ActionCfg.Filename then
            local AnimPathStr = _G.AnimMgr:GetActionTimeLinePath(ActionCfg.Filename)
            if AnimPathStr == nil or #AnimPathStr == 0 then
                FLOG_INFO("InteractiveMgr:PlayItemUsedPlayATL, AnimPathStr is nil ATL:%s", ActionCfg.Filename)
                return
            end
            local StateComponent = MajorUtil.GetMajorStateComponent()
            if IsMajor then
                self:EnableMajorMove(false)
            end
            local ActionTimelines = {
                [1] = {AnimPath = AnimPathStr, Callback = CommonUtil.GetDelegatePair(function()
                    _G.EventMgr:SendEvent(_G.EventID.PlayItemUsedPlayATLEnd,EntityID,VfxID)
                    if IsMajor then
                        self:EnableMajorMove(true)
                    end
                    end,true)},
            }
           _G.AnimMgr:PlayAnimationMulti(EntityID, ActionTimelines)
        end
    end

end

--- 播放物品使用后的Vfx
--- 属于通用特效
function InteractiveMgr:PlayItemUsedVfx(VfxID, RoleID, bTargetSelf)
    local FindResult = CommonVfxCfg:FindCfgByKey(VfxID)
    if nil ~= FindResult then
        local EffectPath = FindResult.Path
        local Actor = ActorUtil.GetActorByRoleID(RoleID)
        if nil ~= EffectPath and nil ~= Actor then
            local AttrComp = Actor:GetAttributeComponent()
            local EntityID
            if AttrComp then
                EntityID = AttrComp.EntityID
            end
            if EntityID and not MajorUtil.IsMajor(EntityID) then
                -- 视野不显示的玩家无需播放特效
                local VisionLoadMeshState = Actor:GetVisionLoadMeshState()
                if VisionLoadMeshState ~= _G.UE.EVisionLoadMeshState.E_LOADED_SHOW then
                    return false
                end
            end
           
            local VfxParameter = _G.UE.FVfxParameter()
            local InsertPosition = #EffectPath - 1
            local PreEffectPath = string.sub(EffectPath, 1, InsertPosition)
            VfxParameter.VfxRequireData.EffectPath = PreEffectPath .. "_C'"
            self:PrintInfo("PlayItemUsedVfx:number:path %s", VfxParameter.VfxRequireData.EffectPath)
            --- 默认附着点
            local AttachPointType_Max = _G.UE.EVFXAttachPointType.AttachPointType_Max
            VfxParameter:SetCaster(Actor, 0, AttachPointType_Max, 0)
            --- 特效目标是角色自身
            if bTargetSelf == true then
                VfxParameter.VfxRequireData.VfxTransform = Actor:FGetActorTransform()
                VfxParameter:AddTarget(Actor, 0, AttachPointType_Max, 0)
            else
                --- 特效目标是角色点选的目标
                local EntityID = ActorUtil.GetEntityIDByRoleID(RoleID)
                local TargetEntityID = _G.TargetMgr:GetTarget(EntityID)
                local Target = ActorUtil.GetActorByEntityID(TargetEntityID)
                if nil ~= Target then
                    VfxParameter.VfxRequireData.VfxTransform = Target:FGetActorTransform()
                    VfxParameter:AddTarget(Target, 0, AttachPointType_Max, 0)
                    --- 点选目标不存在，在角色身上播放
                else
                    VfxParameter.VfxRequireData.VfxTransform = Actor:FGetActorTransform()
                    VfxParameter:AddTarget(Actor, 0, AttachPointType_Max, 0)
                end
            end

            local SoundCfg = VfxSoundCfg:FindCfgByKey(VfxID)
            local function PlaySoundAndVfx()
                self:PlaySound(SoundCfg, Actor)
                EffectUtil.PlayVfx(VfxParameter)
            end
            if SoundCfg ~= nil and SoundCfg.DelayTime ~= nil and SoundCfg.DelayTime > 0 then
                -- 需要延迟播放
                local DelayTime = SoundCfg.DelayTime / 1000
                self:RegisterTimer(PlaySoundAndVfx, DelayTime)
            else
                PlaySoundAndVfx()
            end
            return 
        else
            self:PrintWarning("PlayItemUsedVfx:Vfx path is not exist")
            return
        end
    else
        self:PrintWarning("PlayItemUsedVfx:Vfx ID is not exist")
        return
    end
end

function InteractiveMgr:PlaySound(SoundCfg, Actor)
    if SoundCfg ~= nil and SoundCfg.FirworkSound ~= nil then
        local Location = Actor:FGetActorLocation()
        local Rotation = Actor:FGetActorRotation()
        AudioUtil.LoadAndPlaySoundAtLocation(SoundCfg.FirworkSound, Location, Rotation, _G.UE.EObjectGC.NoCache)
    end
end

function InteractiveMgr:OnEnterDialogue()
    -- local TraceBack = debug.traceback()
    -- FLOG_ERROR("InteractiveMgr:OnEnterDialogue"..TraceBack)
    self.bLockTimer = true
    self:StopTickTimer()
end

function InteractiveMgr:OnExitDialogue()
    -- local TraceBack = debug.traceback()
    -- FLOG_ERROR("InteractiveMgr:OnExitDialogue"..TraceBack)
    self.bLockTimer = false
    self:StartTickTimer()
end

function InteractiveMgr:EnableMajorMove(bFlag)
    self:PrintInfo("InteractiveMgr:EnableMajorMove, flag=%s", tostring(bFlag))
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    local StateComponent = ActorUtil.GetActorStateComponent(MajorEntityID)
    if StateComponent ~= nil then
        StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanMove, bFlag, "InteractiveMgr")
    end
end

function InteractiveMgr:StopMajorMoveForFixedTime(Time)
    --FLOG_INFO("InteractiveMgr:StopMajorMoveForFixedTime, Time:%f", Time)
    local MajorController = MajorUtil.GetMajorController()
    if nil ~= MajorController then
        MajorController:SetStopMoveTime(Time)
    end
end

function InteractiveMgr:OnGameEventMajorDead()
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    _G.UE.USelectEffectMgr:Get():UnSelectActor(MajorEntityID)
end

function InteractiveMgr:OnGameEventCharacterDead(Params)
    -- local EntityID = Params.ULongParam1
    -- local ActorType = ActorUtil.GetActorType(EntityID)
    -- local ResID = ActorUtil.GetActorResID(EntityID) or 0
    -- local ActorName = ActorUtil.GetActorName(EntityID) or ""
    -- if not string.isnilorempty(ActorName) then
    --     _G.FLOG_INFO("InteractiveMgr:OnGameEventCharacterDead, EntityID:%d ResID:%d Type:%d ActorName:%s", EntityID, ResID, ActorType, ActorName)
    -- end
end

function InteractiveMgr:OnEndPlaySequence()
    self:PrintInfo("InteractiveMgr:OnEndPlaySequence")
    self:StartTickTimer()
end

function InteractiveMgr:GetEntranceLastClickTime()
    return self.EntranceLastClickTime
end

function InteractiveMgr:SetEntranceLastClickTime(ClickTime)
    self.EntranceLastClickTime = ClickTime
end

function InteractiveMgr:SetFunctionListShowState(bFlag)
    if bFlag then
        if nil == self.DisableJoyStickAndInputTimer then
            self.DisableJoyStickAndInputTimer = self:RegisterTimer(self.DisableJoyStickAndInput, 0, 0.1, 0)
        end
    else
        if nil ~= self.DisableJoyStickAndInputTimer then
            self:UnRegisterTimer(self.DisableJoyStickAndInputTimer)
            self.DisableJoyStickAndInputTimer = nil
        end
    end
end

function InteractiveMgr:DisableJoyStickAndInput()
    --FLOG_INFO("InteractiveMgr:DisableJoyStickAndInput")
    UIUtil.SetInputMode_UIOnly()
    CommonUtil.HideJoyStick()
end

function InteractiveMgr:DelayShowEntrance(DelayTime)
    local function DelayShow()
        self.IsEntranceDelayShowing = false
        self:ShowMainPanel()
        if self.DelayUpdateEntranceTimerID then
            self:UnRegisterTimer(self.DelayUpdateEntranceTimerID)
            self.DelayUpdateEntranceTimerID = nil
        end
    end

    if not self.DelayUpdateEntranceTimerID then
        self:HideMainPanel()
        self.IsEntranceDelayShowing = true
        self.DelayUpdateEntranceTimerID = self:RegisterTimer(DelayShow, DelayTime, 1, 1)
    end
end

function InteractiveMgr:SetCancelMountingState(IsMounting)
    self.IsMajorCancelMounting = IsMounting
    -- if not IsMounting then
    --     if self.MountingTimerID then
    --         TimerMgr:CancelTimer(self.MountingTimerID)
    --         self.MountingTimerID = nil
    --     end

    -- else
    --     if not self.MountingTimerID then
    --         self.MountingTimerID = self:RegisterTimer(self.HideMainPanel, 0, 0.2, 0)
    --     end
    -- end
end

function InteractiveMgr:CheckOutOfCheckDistanceRange(SelectedActorPos, TargetActor, PrintCheckLog)
    local Major = MajorUtil.GetMajor()
    if nil ~= Major and nil ~= TargetActor then
        local MajorPos = Major:FGetActorLocation()
        --local SelectedActorPos = SelectedActor:FGetActorLocation()
        local TargetActorPos = TargetActor:FGetActorLocation()
        if nil ~= TargetActorPos then
            local DistanceToMajor = ((TargetActorPos.X - MajorPos.X) ^ 2) + ((TargetActorPos.Y - MajorPos.Y) ^ 2) + ((TargetActorPos.Z - MajorPos.Z) ^ 2)
            local DistanceToSelectedActor = ((TargetActorPos.X - SelectedActorPos.X) ^ 2) + ((TargetActorPos.Y - SelectedActorPos.Y) ^ 2) + ((TargetActorPos.Z - SelectedActorPos.Z) ^ 2)
            -- if PrintCheckLog then
            --     local MajorEntityID = MajorUtil.GetMajorEntityID()
            --     --local SelectedActorEntityID  = SelectedActor:GetActorEntityID()
            --     local TargetActorEntityID  = TargetActor:GetActorEntityID()
            --     self:PrintInfo("InteractiveMgr:CheckOutOfCheckDistanceRange, DistanceToMajor: %f (%s <--> %s), DistanceToSelectedActor: %f (%s <--> %s)",
            --         DistanceToMajor, ActorUtil.GetActorName(TargetActorEntityID), ActorUtil.GetActorName(MajorEntityID),
            --         DistanceToSelectedActor, ActorUtil.GetActorName(TargetActorEntityID), ActorUtil.GetActorName(self.ClickSelectedPlayerEntityID))
            -- end
            local CheckDistance = _G.UE.UHUDMgr:Get():GetCheckDistanceBetweenPlayers()
            local CanBeSelectedInteractiveRange = _G.UE.UHUDMgr:Get():GetVisibleRange()
            if DistanceToSelectedActor <= CheckDistance ^ 2 and DistanceToMajor <= CanBeSelectedInteractiveRange ^ 2 then
                return false
            end
        end
    end

    return true
end

function InteractiveMgr:GetNearByPlayers(SelectedPlayer, EntityID)
    if nil == SelectedPlayer then
        return
    end
    self:SetFixedFunctionItems({})
    self:ResetNearByPlayerCheck()
    local SelectedPlayerPos = SelectedPlayer:FGetActorLocation()
    self.ClickSelectedPlayerPos.X = SelectedPlayerPos.X
    self.ClickSelectedPlayerPos.Y = SelectedPlayerPos.Y
    self.ClickSelectedPlayerPos.Z = SelectedPlayerPos.Z
    self.ClickSelectedPlayerEntityID = EntityID
    self.CurSelectedPlayerIndex = 1
    self.CurSelectedPlayerEntityID = EntityID
    table.insert(self.NearByPlayers, SelectedPlayer)
    local AllPlayers = _G.UE.UActorManager:Get():GetAllPlayers()
    if nil ~= AllPlayers and AllPlayers:Length() > 0 then
		for i = 1, AllPlayers:Length() do
            local Player = AllPlayers:Get(i)
            local PlayerEntityID  = Player:GetActorEntityID()
            if EntityID ~= PlayerEntityID and not self:CheckOutOfCheckDistanceRange(self.ClickSelectedPlayerPos, Player, true) then
                table.insert(self.NearByPlayers, Player)
            end
        end
	end
end

function InteractiveMgr:UpdateNearByPlayersByDistance()
    local NearByPlayersNum = #self.NearByPlayers
    self.NearByPlayersInfo = {}
    local TempNearByPlayers = {}
    if NearByPlayersNum > 1 then
        for Index = 1, NearByPlayersNum do
            local Player = self.NearByPlayers[Index]
            if not self:CheckOutOfCheckDistanceRange(self.ClickSelectedPlayerPos, Player, false) then
                local PlayerEntityID = Player:GetActorEntityID()
                table.insert(self.NearByPlayersInfo, PlayerEntityID)
                table.insert(TempNearByPlayers, Player)
            end
        end
    end

    self.NearByPlayers = {}
    for i = 1, #TempNearByPlayers do
        table.insert(self.NearByPlayers, TempNearByPlayers[i])
    end

    local NearByPlayersInfoNum = #self.NearByPlayersInfo
    if NearByPlayersInfoNum <= 1 then
        self:ResetNearByPlayerCheck()
    else
        local Found = false
        for i = 1, NearByPlayersInfoNum do
            if self.ClickSelectedPlayerEntityID == self.NearByPlayersInfo[i] then
                Found = true
                break
            end
        end
        if not Found then
            self:ResetNearByPlayerCheck()
        end
    end

    self:RefreshSelectPlayerInfo()
end

function InteractiveMgr:SetFixedFunctionItems(FuncItemList)
    self.FixedFunctionItemsList = FuncItemList
    InteractiveMainPanelVM:SetFixedFunctionVisible(true)
    InteractiveMainPanelVM:SetFixedFunctionItems(self.FixedFunctionItemsList)
end

function InteractiveMgr:ResetNearByPlayerCheck()
    if nil ~= self.DistanceBetweenPlayersTimer then
        self:UnRegisterTimer(self.DistanceBetweenPlayersTimer)
        self.DistanceBetweenPlayersTimer = nil
    end

    self.NearByPlayers = {}
    self.NearByPlayersInfo = {}
    self.CurSelectedPlayerIndex = 0
    self.CurSelectedPlayerEntityID = 0
    InteractiveMainPanelVM:SetPlayerSwitchVisible(false)
end

function InteractiveMgr:SwitchPlayer()
    local PlayerNum = #self.NearByPlayersInfo
    if PlayerNum > 1 then
        self.CurSelectedPlayerIndex = self.CurSelectedPlayerIndex + 1
        if self.CurSelectedPlayerIndex > PlayerNum then
            self.CurSelectedPlayerIndex = 1
        end
        self.CurSelectedPlayerEntityID = self.NearByPlayersInfo[self.CurSelectedPlayerIndex]
        self:RefreshSelectPlayerInfo()
    else
        self:ResetNearByPlayerCheck()
    end
end

function InteractiveMgr:RefreshSelectPlayerInfo()
    local PlayerNum = #self.NearByPlayersInfo
    if PlayerNum > 1 then
        local IsExist = false
        for i = 1, PlayerNum do
            if self.CurSelectedPlayerEntityID == self.NearByPlayersInfo[i] then
                IsExist = true
                break
            end
        end

        if not IsExist then
            self.CurSelectedPlayerIndex = 1
            self.CurSelectedPlayerEntityID = self.NearByPlayersInfo[1]
        end

        self:ChangeToSelectPlayer(self.CurSelectedPlayerEntityID)
        local PlayerName = ActorUtil.GetActorName(self.CurSelectedPlayerEntityID)
        InteractiveMainPanelVM:SetPlayerName(PlayerName)
    else
        -- if self.LastSelectedTargetEntityID ~= 0 then
        --     self:ChangeToSelectPlayer(self.LastSelectedTargetEntityID)
        -- end

        self:ResetNearByPlayerCheck()
    end

    InteractiveMainPanelVM:SetPlayerSwitchVisible(PlayerNum > 1)
end

function InteractiveMgr:ChangeToSelectPlayer(EntityID)
    for i = 1, #self.FixedFunctionItemsList do
        local IUnit = self.FixedFunctionItemsList[i]
        IUnit:SetEntityID(EntityID)
    end
    local EventParams = _G.EventMgr:GetEventParams()
    EventParams.ULongParam1 = EntityID
    EventParams.IntParam2 = _G.UE.ETargetLockType.Hard
    _G.EventMgr:SendCppEvent(EventID.ManualSelectTarget, EventParams)
end

function InteractiveMgr:GetCurrSelectedPlayerEntityID()
    return self.CurSelectedPlayerEntityID
end

function InteractiveMgr:PrintInfo(Msg, ...)
    if self.EnablePrintNormalLog then
        _G.FLOG_INFO("%s", string.format(Msg, ...))
    end
end

function InteractiveMgr:PrintWarning(Msg, ...)
    if self.EnablePrintNormalLog then
        _G.FLOG_WARNING("%s", string.format(Msg, ...))
    end
end

--- 可决定最上层交互界面是否显示
function InteractiveMgr:SetShowMainPanelEnabled(bEnable)
    self:PrintInfo("InteractiveMgr:SetShowMainPanelEnabled, bEnable:%s", tostring(bEnable))
    self.bEnableShowMainPanel = bEnable
end


function InteractiveMgr:GetTargetActorIsExistInInteractiveList(EntityID, ResID)
    for i = 1, #self.InteractorParamsList do
        local IUnit = self.InteractorParamsList[i]
        if EntityID == IUnit.EntityID then
            return true
        end
    end

    for i = 1, #self.InteractorParamsListToShow do
        local IUnit = self.InteractorParamsListToShow[i]
        if EntityID == IUnit.EntityID then
            return true
        end
    end

    if nil ~= self.EntranceUseItem then
        return true
    end

    return false
end

function InteractiveMgr:LookAtTarget(EntityID)
    if nil == self.MajorRotationInterpSpeed then
        local Cfg = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_ROTATION_INTERP_SPEED)
		if Cfg then
			self.MajorRotationInterpSpeed = Cfg.Value[1]
		end
    end

    MajorUtil.LookAtActorByInterp(EntityID, self.MajorRotationInterpSpeed)
    --MajorUtil.LookAtActor(EntityID)
end

function InteractiveMgr:RecallSummonedBeast(ResID)
    self:PrintInfo("InteractiveMgr:RecallSummonedBeast, ResID:%d", ResID)
    local MsgID = ProtoCS.CS_CMD.CS_CMD_SUMMON_BEAST
	local SubMsgID = ProtoCS.Role.SummonBeast.SummonBeastCmd.SummonBeastCmdCallBack

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.CallBack = { ID = ResID }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function InteractiveMgr:OnSummonBeastCallBackRsp(Msg)
    self:PrintInfo("InteractiveMgr:OnSummonBeastCallBackRsp, Msg:%s", _G.table_to_string(Msg))
end

function InteractiveMgr:IsMountRideNpc(ResID)
    for _, Value in pairs(self.MountRideNpcIDList) do
        if Value == ResID then
            return true
        end
    end

    return false
end

function InteractiveMgr:GetEntranceItemByEntityID(EntityID)
    if EntityID == 0 then
        return nil
    end

    for _, IUnit in ipairs(self.InteractorParamsList) do
        if IUnit.EntityID == EntityID then
            return IUnit
        end
    end

    if nil ~= self.EntranceUseItem and EntityID == self.EntranceUseItem.EntityID then
        return self.EntranceItem
    end

    return nil
end

return InteractiveMgr