local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local TimeUtil = require("Utils/TimeUtil")
local EventID = require("Define/EventID")
local SingBarMgr = require("Game/Interactive/SingBar/SingBarMgr")
local SkillUtil = require("Utils/SkillUtil")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local SidebarType = SidebarDefine.SidebarType.MountInvite
local CommonUtil = require("Utils/CommonUtil")
local GlobalCfg = require("TableCfg/GlobalCfg")
local BuddyEquipCfg = require("TableCfg/BuddyEquipCfg")
local RideCfg = require("TableCfg/RideCfg")
local RideTextCfg = require("TableCfg/RideTextCfg")
local MapCfgTable = require("TableCfg/MapCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local FuncCfg = require("TableCfg/FuncCfg")
local SceneEnterGlobalCfg = require("TableCfg/SceneEnterGlobalCfg")
local MountVM = require("Game/Mount/VM/MountVM")
local MountPanelVM = require("Game/Mount/VM/MountPanelVM")
local MountCustomMadeVM = require("Game/Mount/VM/MountCustomMadeVM")
local SaveKey = require("Define/SaveKey")
local DataReportUtil = require("Utils/DataReportUtil")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local MountCustomCfg = require("TableCfg/MountCustomCfg")
local MountEffectCfg = require("TableCfg/MountEffectCfg")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local CrystalPortalCfg = require("TableCfg/TeleportCrystalCfg")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")
local SideBarDefine = require("Game/Common/Frame/Define/CommonSelectSideBarDefine")
local CommSideBarUtil = require("Utils/CommSideBarUtil")
local MountDefine = require("Game/Mount/MountDefine")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local SaveKey = require("Define/SaveKey")
local MsgTipsID = require("Define/MsgTipsID")
local RideSpeedCfg = require("TableCfg/RideSpeedCfg")
local MapUtil = require("Game/Map/MapUtil")
local WorldMapVM = require("Game/Map/VM/WorldMapVM")
local AudioUtil = require("Utils/AudioUtil")
local ActivityCfg = require("TableCfg/ActivityCfg")
local EnumRidePurposeType = ProtoRes.EnumRidePurposeType
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID

local CS_CMD = ProtoCS.CS_CMD
local MOUNT_SUB_ID = ProtoCS.MountCmd
local LSTR = _G.LSTR

local ApplyDistance = 500

---@class MountMgr : MgrBase
local MountMgr = LuaClass(MgrBase)

MountMgr.AllowFlyReason = {
    MapConfig = 0,  --通过地图配置的是否可以飞行
    AreaConfig = 1, --通过区域配置的是否可以飞行
    WindPulse = 2,  --风脉泉解锁是否可以飞行
    ChocoboTransport = 3, --开启陆行鸟运输后不可以飞行
}

MountMgr.AllowRideReason = {
    MapConfig = 0,
}

function MountMgr:OnInit()
    self.MountSpeedCfg = {}
    self.ForbidFlyAreaID = 0
	self:LoadMountSpeedCfg()
end

function MountMgr:OnBegin()
	self.VisionBindCache = {}
    self.PrecallMap = {}
    self.EntitySingStateRecordMap = {}
    self.MountCancelCallback = nil
    self.ChocoboArmor = {}
    self.ChocoboColor = {}

    self.InviterList = {}
    self.LikeList = nil
    self.CurrentSidebarInviter = nil
    self.bIsRequestingMount = false
    self.bIsAutoPathMoving = false
    self.bIsChocobo = false
    self.AllowRideFlags = 0 --所有位都为0时表示允许骑乘，否则不允许
    self.AllowFlyFlags = 0 --所有位都为0时表示允许飞行，否则不允许
    self.AssembleID = 0
    self.bIsRequestingCancelMount = false
    self.SendMountCallTimeStamp = 0

    self.InviteTransWorldEnterCallback = nil
    self.FuncSendMountCallTimer = nil
    self.bIsDisableOtherSkill = false

    --self.LocalRedTable = {}
    -- 快捷使用系统接入
    _G.BagMgr:RegisterItemUsedFun(ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_MOUNT, self.IsItemUsed)

    MountCustomMadeVM:OnMountMgrBegin()
end

function MountMgr.IsItemUsed(ItemResID)
    local FindItemCfg = ItemCfg:FindCfgByKey(ItemResID)
    if FindItemCfg == nil then return false end
    local FindFuncCfg = FuncCfg:FindCfgByKey(FindItemCfg.UseFunc)
    if FindFuncCfg == nil then return false end

    local MountResID = FindFuncCfg.Func[1].Value[1]
    --local isModuelOpen = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMount)
    return not MountVM:IsNotOwnedMount(MountResID) 
end

function MountMgr:OnEnd()
    self.MountBGMID = nil
    self.CurrentPlayingBgmID = nil
end

function MountMgr:OnShutdown()
	self.MountSpeedCfg = nil
end

function MountMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MOUNT, MOUNT_SUB_ID.MountCmdQuery, self.OnMountCmdQuery)						--坐骑列表查询
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MOUNT, MOUNT_SUB_ID.MountCmdLike, self.OnMountLikeRsp)						--设置坐骑偏好
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MOUNT, MOUNT_SUB_ID.MountCmdApplyNotify, self.OnMountApplyNotify)			    --通知申请或邀请
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MOUNT, MOUNT_SUB_ID.MountCmdReplyNotify, self.OnMountReplyNotify)			    --通知回复结果
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MOUNT, MOUNT_SUB_ID.MountCmdUnlock, self.OnMountUnlock)                       --坐骑解锁
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MOUNT, MOUNT_SUB_ID.MountCmdPreCallOut, self.OnMountPrecall)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MOUNT, MOUNT_SUB_ID.MountCmdSpeedPromote, self.OnMountSpeedPromote)           --坐骑速度解锁
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MOUNT, MOUNT_SUB_ID.MountCmdInviteTrans, self.OnMountInviteTrans)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MOUNT, MOUNT_SUB_ID.MountCmdFacade, self.OnReceiveCustomMadeChange)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MOUNT, MOUNT_SUB_ID.MountCmdFacadeUnlock, self.OnReceiveFacadeUnlock)

    self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_BIND_CHG, self.OnMountCallRsp)	--召唤坐骑返回
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_ENTER, self.OnVisionEnter)	    --进入视野同步
    --self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_LEAVE, self.OnVisionLeave)     --离开视野同步
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_QUERY, self.OnVisionQuery)	    --进入视野同步
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_CHOCOBO_CHG, self.OnChocoboChg)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BUDDY, ProtoCS.BuddyCmd.BuddyCmdQuery, self.OnNetMsgBuddyQuery)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_ENTER, self.OnPWorldRespEnter)    --进入副本
end

function MountMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ActorVMCreate, self.OnGameEventActorVMCreate)
    self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)
    self:RegisterGameEvent(EventID.PlayerCreate, self.OnGameEventPlayerCreate)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventPWorldExit)
    self:RegisterGameEvent(EventID.WorldPreLoad, self.OnGameEventWorldPreLoad)
    self:RegisterGameEvent(EventID.MajorSingBarBegin, self.OnGameEventMajorSingBarBegin)
    -- self:RegisterGameEvent(EventID.MajorSingBarBreak, self.OnGameEventMajorSingBarBreak)
    self:RegisterGameEvent(EventID.MajorSingBarOver, self.OnGameEventMajorSingBarOver)
    -- self:RegisterGameEvent(EventID.OthersSingBarBegin, self.OnGameEventOthersSingBarBegin)
    self:RegisterGameEvent(EventID.MajorFirstMove, self.OnGameEventMajorFirstMove)
    self:RegisterGameEvent(EventID.MajorDead, self.OnGameEventMajorDead)
    self:RegisterGameEvent(EventID.OtherCharacterDead, self.OnGameEventOtherCharacterDead)
    self:RegisterGameEvent(EventID.SidebarItemTimeOut, self.OnGameEventSidebarItemTimeOut) --侧边栏Item超时
    self:RegisterGameEvent(EventID.MountFlyStateChange, self.OnMountFlyStateChange)
    self:RegisterGameEvent(EventID.MountFallStateChange, self.OnMountFallStateChange)
    self:RegisterGameEvent(EventID.MountTouchCeiling, self.OnGameEventMountTouchCeiling)
    self:RegisterGameEvent(EventID.MountExitEnd, self.OnMountExitEnd)
    self:RegisterGameEvent(EventID.NetStateUpdate, self.OnNetStateUpdate)
    self:RegisterGameEvent(EventID.ActorVelocityUpdate, self.OnGameEventActorVelocityUpdate)
    self:RegisterGameEvent(EventID.CharacterLanded, self.OnGameEventCharacterLanded)
    self:RegisterGameEvent(EventID.BeginTrueJump, self.OnGameEventBeginTrueJump)
    self:RegisterGameEvent(EventID.MountAssembleAllEnd, self.OnGameEventMountAssembleAllEnd)
    self:RegisterGameEvent(EventID.UseMount, self.OnGameEventUseMount)
    self:RegisterGameEvent(EventID.StopAutoMoving, self.OnGameEventStopAutoMoving)
    self:RegisterGameEvent(EventID.StopAutoPathMove, self.OnGameEventStopAutoPathMove)
    self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnGameEventModuleOpenNotify)
    self:RegisterGameEvent(EventID.MountFlyHighStateChange, self.OnFlyHighStateChange)
    self:RegisterGameEvent(EventID.AetherCurrentMapFlyOpen, self.OnGameEventAetherCurrentMapFlyOpen)
    self:RegisterGameEvent(EventID.WorldPostLoad, self.OnWorldPostLoad)
    self:RegisterGameEvent(EventID.AreaTriggerBeginOverlap, self.OnEnterAreaTrigger)
    self:RegisterGameEvent(EventID.AreaTriggerEndOverlap, self.OnExitAreaTrigger)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventRoleLoginRes)		-- 角色登录成功
    self:RegisterGameEvent(EventID.EnterWater, self.OnEnterWater)
    self:RegisterGameEvent(EventID.MajorPassengerIdle, self.OnMajorPassengerIdle)
    self:RegisterGameEvent(EventID.VisionReleaseMesh, self.OnGameEventVisionReleaseMesh)
    self:RegisterGameEvent(EventID.ChocoboTransportBegin, self.OnGameEventChocoboTransportBegin)
    self:RegisterGameEvent(EventID.ChocoboTransportFinish, self.OnGameEventChocoboTransportFinish)
    self:RegisterGameEvent(EventID.MajorDead, self.OnMajorDead)
    self:RegisterGameEvent(EventID.RemoveActivity, self.OnRemoveActivity)
end

function MountMgr:OnMajorDead(Params)
    if MountVM.IsInRide then
        self:ForceSendMountCancelCall()
    end
end

function MountMgr:OnMountCall(Params)
    --FLOG_INFO("[mount] call, %s", table.tostring(Params))

    local Actor = ActorUtil.GetActorByEntityID(Params.EntityID)
    if Actor == nil then return end
    local Cfg = RideCfg:FindCfgByKey(Params.MountResID)
    if Cfg == nil then return end

    --self:RegisterGameEvent(EventID.SkillCast, self.OnGameEventSkillCast)
    -- self:RegisterGameEvent(EventID.SkillStart, self.OnGameEventSkillStart)
    -- self:RegisterGameEvent(EventID.SkillEnd, self.OnGameEventSkillEnd)

    -- if Params.MountResID == MountDefine.MountIDSkateboard then
    --     local SuccessSound = Cfg.MountCallse
    --     _G.UE.UAudioMgr:Get():LoadAndPostEvent(SuccessSound, Actor, true)
    -- end

    if Params.EntityID == MajorUtil.GetMajorEntityID() and Cfg.MountBgm ~= nil then
        local BgmID = tonumber(Cfg.MountBgm)
        self.MountBGMID = BgmID
        if Params.MountResID > 0 then
            self:PlayMountBGM()
        end
    end

    if Params.EntityID == MajorUtil.GetMajorEntityID() then
        self.bIsRequestingMount = false
        _G.InteractiveMgr:RegisterTimer(_G.InteractiveMgr.ShowMainPanelAfterMajorSingOver, 1, 0.3, 1)
        self.bShouldHideItneractiveEntrances = true
        self:RegisterTimer(function() self.bShouldHideItneractiveEntrances = false end, 1)
    end

    self:UpdateHostRideFull()
end

function MountMgr:IsNeedHideInteractiveEntrances()
    return self:IsRequestingMount() or self.bShouldHideItneractiveEntrances
end

function MountMgr:UpdateHostRideFull()
    local HostRideCom = self:GetHostRideComponent()
    if HostRideCom == nil then return end
    local IsHostRideFull = true
    for i = 1, HostRideCom:GetSeatCount() do
        if HostRideCom:GetPassengerEntityID(i) == 0 then
            IsHostRideFull = false
            break
        end
    end
    MountVM.IsHostRideFull = IsHostRideFull
end

function MountMgr:GetCurrentMountResID()
    return 0
end

function MountMgr:OnEnterAreaTrigger(EventParam)
    --FLOG_INFO("[mount] OnEnterAreaTrigger, %s, self.ForbidFlyAreaID = %s", table.tostring(EventParam), tostring(self.ForbidFlyAreaID))
    if self.ForbidFlyAreaID == 0 and EventParam.bforbidfly then
        self.ForbidFlyAreaID = EventParam.AreaID
        self:SetAllowFly(false, self.AllowFlyReason.AreaConfig)
    end
end

function MountMgr:OnExitAreaTrigger(EventParam)
    --FLOG_INFO("[mount] OnExitAreaTrigger, %s, self.ForbidFlyAreaID = %s", table.tostring(EventParam), tostring(self.ForbidFlyAreaID))
    if self.ForbidFlyAreaID == EventParam.AreaID then
	    self.ForbidFlyAreaID = 0
        self:SetAllowFly(true, self.AllowFlyReason.AreaConfig)
    end
end

function MountMgr:OnMajorPassengerIdle()
    MsgTipsUtil.ShowTips(LSTR(1090002))
end

function MountMgr:OnMountPrecall(Params)
    if not Params.PreCall then return end
    local EntityID = Params.PreCall.EntityID
    if EntityID ~= MajorUtil.GetMajorEntityID() then
        self.PrecallMap[EntityID] = { ResID = Params.PreCall.ResID }
        self:PlayMountSingAnimation(EntityID)
    end
end

function MountMgr:OnMountBack(Params)
    --FLOG_INFO("[mount] back, %s", table.tostring(Params))
    local Actor = ActorUtil.GetActorByEntityID(Params.EntityID)
    if Actor == nil then return end

    --self:UnRegisterGameEvent(EventID.SkillCast, self.OnGameEventSkillCast)
    -- self:UnRegisterGameEvent(EventID.SkillStart, self.OnGameEventSkillStart)
    -- self:UnRegisterGameEvent(EventID.SkillEnd, self.OnGameEventSkillEnd)
    
    --self:MountLockMove(false)
    if Params.EntityID == MajorUtil.GetMajorEntityID() then
        self:StopMountBGM()
        self.MountBGMID = nil
    end

    local Cfg = RideCfg:FindCfgByKey(Params.MountResID)
    if Cfg == nil then return end
    local Sound = Cfg.MountExitse
    _G.UE.UAudioMgr:Get():LoadAndPostEvent(Sound, Actor, true)

    self:UpdateHostRideFull()
end

function MountMgr:OnWorldPostLoad(Params)
    MountVM:SetRideState()
    self:PlayMountBGM()
end

function MountMgr:PlayMountBGM()
    local bMountBgm = _G.SettingsMgr:GetValueBySaveKey("MountBGM") == 1
    if bMountBgm and self.MountBGMID and self:IsInRide() then
        self.CurrentPlayingBgmID = _G.UE.UAudioMgr:Get():PlayBGM(self.MountBGMID, _G.UE.EBGMChannel.Mount)
        self:UpdateMountBGMValume()
    end
end

function MountMgr:QuickPlayOrStopMountBGM(IsPlay)
    --先改设置项
    _G.SettingsMgr:SetValueBySaveKey("MountBGM", IsPlay and 1 or 2)
    _G.SettingsMgr:SetValueByClientSetupKey("CSMountBGM", IsPlay and 1 or 2)
    if IsPlay then
        self:PlayMountBGM()
    else
        self:StopMountBGM()
    end
end

function MountMgr:StopMountBGM()
    if self.CurrentPlayingBgmID ~= nil then
        _G.UE.UAudioMgr:Get():StopBGMAtChannel(_G.UE.EBGMChannel.Mount)
        self:UpdateMountBGMValume()
        self.CurrentPlayingBgmID = nil
    end
end

function MountMgr:CheckBgmIsPlay()
    --和设置保持同步
    local bMountBgm = _G.SettingsMgr:GetValueBySaveKey("MountBGM") == 1
    return bMountBgm
end

function MountMgr:OnMountUnlock(Params)
    if Params.Unlock == nil or Params.Unlock.Unlock == nil then return end
    local ResID = Params.Unlock.Unlock.ResID
    local Cfg = RideCfg:FindCfgByKey(ResID)
    if Cfg == nil then return end

    local Name = Cfg.Name
    MsgTipsUtil.ShowTips(string.format(LSTR(1090003), Name))
    self:SendMountListQuery()

    local EventParams = _G.EventMgr:GetEventParams()
    EventParams.Type = TutorialDefine.TutorialConditionType.UnlockRiderItem --新手引导触发类型
    _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)

    if self:IsCustomMadeEnabled(ResID) then
        local UseSpecialItemParams = _G.EventMgr:GetEventParams()
        UseSpecialItemParams.Type = TutorialDefine.TutorialConditionType.UseSpecialItem
        UseSpecialItemParams.Param1 = Cfg.ItemID
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(UseSpecialItemParams)
    end
end

function MountMgr:OnMountFlyStateChange(Params)
    local Major = _G.UE.UActorManager:Get():GetMajor()
	if Major == nil then
		return
	end
    MountVM.IsMajorInFly = Major:IsInFly()
    MountVM.IsOnGround = Major:IsOnGround()
end

function MountMgr:OnMountFallStateChange(Params)
    if MajorUtil.IsMajor(Params.ULongParam1) then
        MountVM:SetIsMountFall(Params.BoolParam1)
    end
end

function MountMgr:OnMountExitEnd(Params)
    if MajorUtil.IsMajor(Params.ULongParam1) then
        MountVM:SetRideState()
        self.bIsDisableOtherSkill = false
        --PWorldExit时在C++侧调用Major的Uninit，并调用UnUseRide，lua侧没有发送MountBack事件，在这里补发一下
        local Major = MajorUtil.GetMajor()
        if Major and not Major:IsActive() then
            local MountBackParams = {EntityID = MajorUtil.GetMajorEntityID(), MountResID = 0, bIsEnteringWorld = false}
            _G.EventMgr:SendEvent(_G.EventID.MountBack, MountBackParams)
        end
    end
end

function MountMgr:RegisterCombatAttrMsg()
	--self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_ATTR_UPDATE, self.OnCombatAttrUpdate) 					--动态属性
end

function MountMgr:UnRegisterCombatAttrMsg()
	--self:UnRegisterGameNetMsg(CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_ATTR_UPDATE, self.OnCombatAttrUpdate) 					--动态属性
end

function MountMgr:OnMountSpeedPromote(Params)
    if Params.SpeedPromote == nil or Params.SpeedPromote.MapSpeedList == nil then
        return
    end
    local MapSpeedList = Params.SpeedPromote.MapSpeedList
    if #MapSpeedList == 0 then
        FLOG_ERROR("SpeedPromote.MapSpeedList num = 0")
        return
    end

    local IsCurMapPromote = false
    local CurMapId = _G.PWorldMgr:GetCurrMapResID()
    local SpeedLevel = 0
    local MapNameList = {}
    if MountVM.MountSpeedLevelMap == nil then
        MountVM.MountSpeedLevelMap = {}
    end
    for _, v in ipairs(MapSpeedList) do
        local MapId = v.MapID
        SpeedLevel = v.SpeedLevel
        MountVM.MountSpeedLevelMap[MapId] = SpeedLevel
        if MapId == CurMapId then
            IsCurMapPromote = true
        end
        local UIMapID = MapUtil.GetUIMapID(MapId) or 0
        local MapName = MapUtil.GetMapName(UIMapID) or LSTR(200012)
        table.insert(MapNameList, MapName)
    end

    if IsCurMapPromote then
        local RideComp = MajorUtil.GetMajorRideComponent()
        --在自己的坐骑上
        if RideComp ~= nil and RideComp:IsInRide() and not RideComp:IsInOtherRide() then
            local Speed = SceneEnterGlobalCfg:FindCfgByKey(ProtoRes.SceneGlobalCfgID.SGCMountSpeedPromote).Value[SpeedLevel]
            RideComp:SetSpeedPromote(Speed)
        end
    end

    local function ShowTip()
        UIViewMgr:ShowView(UIViewID.MountSpeedWinPanel,
        {
            SpeedLevel = SpeedLevel,
            TextCityList = MapNameList
        })
        local SoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_INGAME/Play_Zingle_Unlock.Play_Zingle_Unlock'"
        AudioUtil.LoadAndPlayUISound(SoundPath)
    end

    --速度提升弹窗
    local ShowDelayTime = 0
    if SpeedLevel == 1 then
        ShowDelayTime = 3
    end
    if not _G.UpgradeMgr.IsOnDirectUpState then
        self:RegisterTimer(ShowTip, ShowDelayTime)
    end
end

-----------------------------------------------Rsp start-----------------------------------------------

function MountMgr:OnMountInviteTrans(Params)
    FLOG_INFO("[mount] OnMountInviteTrans %s", table.tostring(Params))
    local CrystalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
    local CrystalID = Params.InviteTrans.CrystalID
    local CrystalCfg = CrystalPortalCfg:FindCfgByKey(CrystalID)
    local MapID = CrystalCfg and CrystalCfg.MapID or 0
    local UIMapID = MapUtil.GetUIMapID(MapID) or 0
    local MapName = MapUtil.GetMapName(UIMapID) or ""

    if CrystalMgr:IsExistActiveCrystal(CrystalID) then
        local function AgreeCallback()
            CrystalMgr:TransferByMap(CrystalID)
            self.InviteTransWorldEnterCallback = function()
                MsgTipsUtil.ShowTips(LSTR(1090039))
            end
        end
        local function CancelCallback()
            MsgTipsUtil.ShowTips(LSTR(1090039))
        end
        MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), string.format(LSTR(1090038), MapName), AgreeCallback, CancelCallback, LSTR(10003), LSTR(10002))
    else
        MsgTipsUtil.ShowTips(LSTR(1090039))
    end
end

-- lua MountMgr:TestApplyNotify()
function MountMgr:TestApplyNotify()
    local MsgBody = {ApplyNotify = {RoleID = 883171010995464262}}
    self:OnMountApplyNotify(MsgBody)
end

function MountMgr:AddInviter(RoleID)
    if self.InviterList[RoleID] ~= nil then return end
    local Time = TimeUtil.GetServerTime()
    local function DistanceCheck()
        local Inviter = ActorUtil.GetActorByRoleID(RoleID)
        local Major = MajorUtil.GetMajor()
        if Inviter == nil or Major == nil then
            self:InviteRefuseCallBack({RoleID = RoleID}, true)
            return
        end
        -- 前台不做距离限制，用后台的
        -- local InviterLocation = Inviter:FGetLocation(_G.UE.EXLocationType.ServerLoc)
        -- local MajorLocation = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
        -- local Distance = _G.UE.FVector.Dist2D(InviterLocation, MajorLocation)
        -- if Distance > MountInviteDistance then
        --     self:InviteRefuseCallBack({RoleID = RoleID}, true)
        --     return
        -- end
    end
    local CheckTimer = _G.TimerMgr:AddTimer(self, DistanceCheck, 1, 1, 0)
    self.InviterList[RoleID] = {RoleID = RoleID, Time = Time, CheckTimer = CheckTimer}
    local ListSize = table.size(self.InviterList)
    if ListSize == 1 then
        _G.SidebarMgr:AddSidebarItem(SidebarType, Time, 60, {RoleID = RoleID})
        self.CurrentSidebarInviter = RoleID
    end
end

function MountMgr:RemoveInviter(RoleID)
    local ListSize = table.size(self.InviterList)
    if ListSize == 0 then return end

    local InviterItem = self.InviterList[RoleID]
    if InviterItem == nil then return end
    _G.TimerMgr:CancelTimer(InviterItem.CheckTimer)
    self.InviterList[RoleID] = nil

    if ListSize == 1 then
        _G.SidebarMgr:RemoveSidebarItem(SidebarType)
        self.CurrentSidebarInviter = nil
    else
        if self.CurrentSidebarInviter == RoleID then
            _G.SidebarMgr:RemoveSidebarItem(SidebarType)
            local NewRoleID = 0
            for index, _ in pairs(self.InviterList) do
                NewRoleID = index
                break
            end
            local Inviter = self.InviterList[NewRoleID]
            if Inviter ~= nil then
                _G.SidebarMgr:AddSidebarItem(SidebarType, Inviter.Time, 60, {RoleID = NewRoleID})
                self.CurrentSidebarInviter = NewRoleID
            end
        else
        end
        self.CurrentSidebarInviter = nil
    end
    return
end

function MountMgr:OnMountApplyNotify(MsgBody)
    local MountApplyNotify = MsgBody.ApplyNotify
    MountMgr:AddInviter(MountApplyNotify.RoleID)
end

function MountMgr:OpenApplyNotifySidebar(StartTime, CountDown, RoleID, Type)
    local EntityID = ActorUtil.GetEntityIDByRoleID(RoleID)
    local PlayerName = ActorUtil.GetActorName(EntityID)
    local Params = {}
    Params.Title = LSTR(1090004)
    Params.Desc1 = string.format(LSTR(1090005), PlayerName)
    Params.Desc2 = LSTR(1090006)
    Params.StartTime = StartTime
    Params.CountDown = CountDown
    Params.CBFuncRight = self.InviteAgreeCallBack
    Params.CBFuncLeft = self.InviteRefuseCallBack
    Params.CBFuncObj = self
    Params.Type = Type
    Params.TransData = { RoleID = RoleID }
    UIViewMgr:ShowView(_G.UIViewID.SidebarCommon, Params)
end

function MountMgr:OnGameEventSidebarItemTimeOut( Type, TransData )
    if Type ~= SidebarType then
        return
    end
    self:InviteRefuseCallBack(TransData, false)
end

function MountMgr:InviteAgreeCallBack(Params)
    local RoleID = Params.RoleID
    self:SendMountReplyOn(RoleID, 0)
    MountMgr:RemoveInviter(RoleID)
end

function MountMgr:InviteRefuseCallBack(Params, Timeout)
    local RoleID = Params.RoleID
    if Timeout == true then
        self:SendMountReplyOn(RoleID, 2)
        _G.MsgTipsUtil.ShowTips(LSTR(1090062))
    else
        self:SendMountReplyOn(RoleID, 1)
        _G.MsgTipsUtil.ShowTips(LSTR(1090054))
    end
    MountMgr:RemoveInviter(RoleID)
end

function MountMgr:OnMountReplyNotify(MsgBody)
    local MountReplyNotify = MsgBody.ReplyNotify
    local Reply = MountReplyNotify.Reply   --对方是否同意

    if Reply == 1 then
        _G.MsgTipsUtil.ShowTips(LSTR(1090055))
    elseif Reply == 2 then
        _G.MsgTipsUtil.ShowTips(LSTR(1090062))
    end
    MountMgr:RemoveInviter(MsgBody.RoleID)
end

function MountMgr:OnMountCmdQuery(MsgBody)
	local MountQueryRsp = MsgBody.Query
    for _,v in ipairs(MountQueryRsp.Mounts) do
        if MountVM.MountMap ~= nil and MountVM.MountMap[v.ResID] == nil then
            MountVM:AddNew(v.ResID)
        end
    end
    local CustomUnlockList = {}
    for _,v in ipairs(MountQueryRsp.Facades) do
        CustomUnlockList[v.Facade] = { Flag = v.Flag, Unlocked = true }
    end

    MountVM.MountMap = {}
    local NewMountList = {}
    local Index = 1
    local Actor = MajorUtil.GetMajor()
    for _,v in ipairs(MountQueryRsp.Mounts) do
        if MountPanelVM:IsShowMount(v) then
            NewMountList[Index] = v
            Index = Index + 1
            MountVM.MountMap[v.ResID] = v

            -- 默认外观视为必定解锁
            local DefaultCustomMadeID = MountCustomMadeVM:GetDefaultCustomMadeID(v.ResID)
            if DefaultCustomMadeID ~= nil then
                CustomUnlockList[DefaultCustomMadeID] = { Flag = 0, Unlocked = true}
            end

            if Actor ~= nil then
                self:SetCustomMadeID(Actor, v.ResID, v.Facade)
            end
        end
    end
    MountVM.MountList = NewMountList

    FLOG_INFO("[mount] UpdateFacadeUnlockList %s", table.tostring(MountQueryRsp.Facades))

    MountCustomMadeVM.UnlockList = CustomUnlockList
    MountCustomMadeVM:CheckAllCustomMadeIsNew()

    --MountVM.IsMainMountCallButtonVisible = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMount) and #MountVM.MountList > 0
    --MountVM.MountCallBtnVisibleState = MountVM.IsMainMountCallButtonVisible

    MountVM.MountSpeedLevelMap = {}
    for _,v in ipairs(MountQueryRsp.MapSpeeds) do
        MountVM.MountSpeedLevelMap[v.MapID] = v.SpeedLevel
    end
    local RideComp = MajorUtil.GetMajorRideComponent()
    if RideComp ~= nil and RideComp:IsInRide() and not RideComp:IsInOtherRide() then
        local SpeedPromote = self:GetSpeedPromoteByMapId(RideComp:GetRideResID())
        RideComp:SetSpeedPromote(SpeedPromote)
    end
end

function MountMgr:OnMountLikeRsp(MsgBody)
    local MountLikeRsp = MsgBody.Like
    for _,v in ipairs(MountVM.MountList) do
        if v.ResID == MountLikeRsp.ResID then
            v.Flag = MountLikeRsp.Flag
            v.LikeTime = MountLikeRsp.LikeTime
            self:UpdateMountLikeList()
            _G.EventMgr:SendEvent(EventID.MountRefreshLike, v)
            return
        end
    end
end

-- // 建立和解除绑定时下发(或坐骑切换位置)，EntityID表示乘客的EntityID
-- message VBindChg
-- {
--   uint64 EntityID = 1;                // 实体ID
--   int32 ResID = 2;                    // 绑定怪则无意义
--   uint64 Host = 3;                    // 宿主ID，或司机entityID
--   int32 Pos = 4;                      // 位置
-- }
function MountMgr:OnMountCallRsp(MsgBody)
    local Bind = MsgBody.BindChg
    Bind.bIsEnteringWorld = false
    self:HandleBind(Bind)
end

function MountMgr:OnPWorldRespEnter(MsgBody)
    if MsgBody.Enter == nil or MsgBody.Enter.Externals == nil or MsgBody.Enter.Externals[1] == nil then return end
    local MsgMount = MsgBody.Enter.Externals[1].Mount
    if MsgMount == nil then return end

    -- -- 多人坐骑传送，WorldEnter不处理，等后续的BindChg
    -- if MsgMount.Seat > 0 then return end

    local Bind = {
        EntityID = MsgBody.Enter.EntityID,
        ResID = MsgMount.ResID,
        Host = MsgMount.Host or 0,
        Pos = MsgMount.Seat or 0,
        Facade = MsgMount.Facade,
    }
    if MsgMount.Flying then
        Bind.ActorLocation = MsgBody.Enter.Pos
    end
    Bind.bIsEnteringWorld = true
    FLOG_INFO("[mount] PWorldEnter Bind = %s", table.tostring(Bind))
    self:HandleBind(Bind)
end

function MountMgr:OnVisionEnter(MsgBody)
    self:HandleVisionMount(MsgBody.Enter)
end

function MountMgr:OnVisionLeave(MsgBody)

end

function MountMgr:OnVisionQuery(MsgBody)
    self:HandleVisionMount(MsgBody.Query)
end

-- // 实体的绑定信息
-- message VBind
-- {
--   int32 ResID = 1;                    // 坐骑ID，绑定怪则无意义
--   uint64 Host = 2;                    // 宿主ID，或司机entityID
--   int32 Pos = 3;                      // 位置，宿主位置=0
-- }
function MountMgr:HandleVisionMount(VisionEnterRsp)
    for _,VEntity in ipairs(VisionEnterRsp.Entities) do
        local Bind = VEntity.Bind
        if Bind ~= nil and VEntity.Type == ProtoRes.entity_type.ENTITY_TYPE_PLAYER then
            Bind.EntityID = VEntity.ID
            if VEntity.Move ~= nil and VEntity.Move.Status == 4 then -- EMoveStatus.Flying = 4
                Bind.ActorLocation = VEntity.Pos
            end
            Bind.bIsEnteringWorld = false
            self:HandleBind(Bind)
        end
        if VEntity.Type == _G.UE.EActorType.Player then
            self.ChocoboArmor[VEntity.ID] = VEntity.Role.Chocobo.Armor
            self.ChocoboColor[VEntity.ID] = VEntity.Role.Chocobo.Color
            --FLOG_INFO("[mount] Chocobo Vision EntityID=%d, Data=%s", VEntity.ID, table.tostring(VEntity.Role.Chocobo.Armor))
        end
    end
end

function MountMgr:HandleBind(Bind)
    local Actor = ActorUtil.GetActorByEntityID(Bind.EntityID)
    if Actor == nil or not Actor:IsActive() then
        self:CacheBind(Bind, Bind.EntityID)
        return
    end

    --在骑乘之前，要先终结所有正在播放的情感动作
	_G.EmotionMgr:StopAllEmotionsByMount(Bind.EntityID)

    local NewLocation = nil
    if Bind.ActorLocation ~= nil then
        NewLocation = _G.UE.FVector(Bind.ActorLocation.X, Bind.ActorLocation.Y, Bind.ActorLocation.Z)
    end
    if Bind.Host == Bind.EntityID or (Bind.Host == 0 and Bind.Pos == 0) then
        FLOG_INFO("[mount] Handle Bind=%s", table.tostring(Bind))
        self:HandleRideByResID(Actor, Bind.ResID, NewLocation, Bind.bIsEnteringWorld, Bind.Facade)
        if Bind.ResID == 0 then
            self:ClearCachedBind(Bind.EntityID)
            local ActorRideComp = Actor:GetRideComponent()
            if ActorRideComp ~= nil then
                FLOG_INFO("[mount] clear cache and cancel wait host %s", Bind.EntityID)
                ActorRideComp:CancelWaitHost()
            end
        end
    else
        --有2个id，多人坐骑

        local HostActor = ActorUtil.GetActorByEntityID(Bind.Host)
        if HostActor == nil or not HostActor:IsMeshLoadedAndShow() or (Bind.bIsEnteringWorld and Bind.Cached ~= true) then
            --司机还没创建出来，先缓存乘客信息
            self:CacheBind(Bind, Bind.Host)
            local ActorRideComp = Actor:GetRideComponent()
            if ActorRideComp ~= nil then
                FLOG_INFO("[mount] wait host %s", Bind.EntityID)
                ActorRideComp:WaitHost()
            end
        else
            --司机已经创建 可以直接把乘客绑定到司机坐骑上
            local RideComp = HostActor:GetRideComponent()
            if RideComp ~= nil and RideComp:IsInRide() and not RideComp:IsAssembling() then
                FLOG_INFO("[mount] Handle Other Bind=%s", table.tostring(Bind))
                self:OtherToHost(Bind.Host, Actor, Bind.Pos, NewLocation)
            else
                self:CacheBind(Bind, Bind.Host)
                local ActorRideComp = Actor:GetRideComponent()
                if ActorRideComp ~= nil then
                    FLOG_INFO("[mount] wait host %s", Bind.EntityID)
                    ActorRideComp:WaitHost()
                end
            end
        end
    end
end

function MountMgr:CacheBind(Bind, KeyEntityID)
    --FLOG_INFO("[mount] Cache Bind")
    if self.VisionBindCache[KeyEntityID] == nil then
        self.VisionBindCache[KeyEntityID] = {}
    end
    local Binds = self.VisionBindCache[KeyEntityID]
    Binds[Bind.EntityID] = Bind
    Bind.Cached = true
end

function MountMgr:ClearCachedBind(EntityID)
    for KeyEntityID, Binds in pairs(self.VisionBindCache) do
        if Binds ~= nil then
            Binds[EntityID] = nil
        end
    end
end

function MountMgr:HandleCachedBinds(EntityID)
    local Binds = self.VisionBindCache[EntityID]
    if Binds == nil then return end

    for _, Bind in pairs(Binds) do
        --FLOG_INFO("[mount] Clear cache %s", table.tostring(Bind))
        self.VisionBindCache[EntityID][Bind.EntityID] = nil
        self:HandleBind(Bind)
    end
end

function MountMgr:HandleRideByResID(Actor, InResID, ActorLocation, bIsEnteringWorld, CustomMadeID)
    --FLOG_INFO("[Mount] Actor = %s ride on ResID = %s", tostring(Actor), tostring(InResID))
    local RideComp = Actor:GetRideComponent()
    if RideComp == nil then
        --FLOG_INFO("[mount] RideComp == nil")
        return
    end

    local AttrComp = Actor:GetAttributeComponent()
    if AttrComp == nil then
        FLOG_WARNING("[mount] HandleRideByResID AttrComp == nil")
        return
    end

    local OldResID = RideComp:GetRideResID()
    local bOldIsInRide = RideComp:IsInRide()
    if InResID == 0 then
        if self:bInEdgeCaseNeedRide() then -- 处理特殊情况
            return
        end
        if RideComp:IsInOtherRide() then
            RideComp:UnuseOtherRide()
            if MajorUtil.IsMajor(AttrComp.EntityID) and not self.bIsRequestingCancelMount then
                MsgTipsUtil.ShowTips(LSTR(1090069))
            end
        elseif MajorUtil.IsMajor(AttrComp.EntityID) then
            RideComp:UnUseRide(true, not self.bToGround)
            self.bToGround = false
            MountVM.IsOnGround = true
            MountVM.bRideProbationState = false
        else
            RideComp:UnUseRide(true)
        end
        if MajorUtil.IsMajor(AttrComp.EntityID) then
            self.bIsRequestingCancelMount = false
            MountVM:SetRideState()
        end
    else
        --确保打断交互吟唱效果在骑乘之前，否则交互结束动作和坐的动作会冲突
        SingBarMgr:BreakCurSingDisplay(AttrComp.EntityID)

        -- 获取当前地图坐骑提升速度
        local SpeedPromote = self:GetSpeedPromoteByMapId(InResID)
        if InResID == 1 then
            local ChocoboArmor = self.ChocoboArmor[AttrComp.EntityID == MajorUtil.GetMajorEntityID() and 1 or AttrComp.EntityID]
            local StainID = self.ChocoboColor[AttrComp.EntityID == MajorUtil.GetMajorEntityID() and 1 or AttrComp.EntityID]
            self.bIsChocobo = true
            if StainID == nil then
                StainID = 0
            end
            if ChocoboArmor then
                local HeadChocoboEquipCfg = BuddyEquipCfg:FindCfgByKey(ChocoboArmor.Head)
                local HeadString = HeadChocoboEquipCfg and HeadChocoboEquipCfg.ModelString or ""
                local FeetChocoboEquipCfg = BuddyEquipCfg:FindCfgByKey(ChocoboArmor.Feet)
                local FeetString = FeetChocoboEquipCfg and FeetChocoboEquipCfg.ModelString or ""
                local BodyChocoboEquipCfg = BuddyEquipCfg:FindCfgByKey(ChocoboArmor.Body)
                local BodyString = BodyChocoboEquipCfg and BodyChocoboEquipCfg.ModelString or ""
                RideComp:UseRide(InResID, SpeedPromote,StainID, HeadString, BodyString, "", FeetString)
                --FLOG_INFO("[mount] UseRide ChocoboArmor")
            else
                RideComp:UseRide(InResID, SpeedPromote,StainID)
                --FLOG_INFO("[mount] UseRide not ChocoboArmor")
            end
        else
            self.bIsChocobo = false
            RideComp:UseRide(InResID, SpeedPromote)
            --FLOG_INFO("[mount] UseRide InResID != 1")
        end
        if CustomMadeID == 0 then
            CustomMadeID = MountCustomMadeVM:GetDefaultCustomMadeID(InResID)
        end
        self:SetCustomMadeID(Actor, InResID, CustomMadeID)

        if MajorUtil.IsMajor(AttrComp.EntityID) then
            RideComp:SetAllowFlying(MountVM.AllowFlyRide)
        else
            -- P3玩家是靠协议驱动的飞行，不受AllowFlying权限控制
            RideComp:SetAllowFlying(true)
        end
        if ActorLocation ~= nil then
            RideComp:SetBindLocation(ActorLocation)
        end
    end

    local ActorEntityID = Actor:GetAttributeComponent() and Actor:GetAttributeComponent().EntityID or nil
    local Cfg = RideCfg:FindCfgByKey(InResID)

    if self.PrecallMap[ActorEntityID] ~= nil and self.PrecallMap[ActorEntityID].TimerHandle ~= nil then
        _G.TimerMgr:CancelTimer(self.PrecallMap[ActorEntityID].TimerHandle)
    end
    self.PrecallMap[ActorEntityID] = nil

    if ActorEntityID == MajorUtil.GetMajorEntityID() then
        MountVM:SetRideState()
    end

    if InResID > 0 then
        local Params = {EntityID = ActorEntityID, MountResID = InResID, HostID = ActorEntityID, bIsTransfer = bOldIsInRide, Pos = 0, bIsEnteringWorld = bIsEnteringWorld}
        _G.EventMgr:SendEvent(_G.EventID.MountCall, Params)
        self:OnMountCall(Params)
    else
        local Params = {EntityID = ActorEntityID, MountResID = OldResID, bIsEnteringWorld = bIsEnteringWorld}
        _G.EventMgr:SendEvent(_G.EventID.MountBack, Params)
        self:OnMountBack(Params)
    end

end

function MountMgr:OnGameEventVisionReleaseMesh(Param)
    local EntityID = Param.ULongParam1
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if Actor == nil then
        return
    end
    local RideComp = Actor:GetRideComponent()
    if RideComp == nil then
        return
    end
    RideComp:ResetAvatar()
end

-----------------------------------------------Rsp end-----------------------------------------------

-----------------------------------------------Req start-----------------------------------------------
function MountMgr:SendMountRead(Param)
    self:SendEquipCommon(MOUNT_SUB_ID.MountCmdRead, "Read", Param)
end

function MountMgr:SendMountListQuery()
    if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMount) then return end
	self:SendEquipCommon(MOUNT_SUB_ID.MountCmdQuery, nil, nil)
end

function MountMgr:SendMountCall(InResID, bImmidiate)
    if self:IsRequestingMount() then
        return false
    end
    local MajorActor = MajorUtil.GetMajor()
    if not MajorActor then
        _G.FLOG_WARNING("[mount] SendMountCall MajorActor Is nil!")
        return false
    end

    -- 只支持行走、游泳、自动寻路的移动状态下召唤坐骑
    if MajorActor and MajorActor:GetMovementComponent() and not MajorActor:GetMovementComponent():IsWalking() and not MajorActor:GetMovementComponent():IsSwimming()
    and not MajorActor:IsPathWalking() then
        return false
    end

    -- 区域禁止飞行
    if not MountVM.AllowRide then
        MsgTipsUtil.ShowTips(LSTR(1090007))
        return false
    end
    -- if MajorUtil.GetMajorStateComponent() and MajorUtil.GetMajorStateComponent():IsInNetState(ProtoCommon.CommStatID.COMM_STAT_COMBAT) then
    --     MsgTipsUtil.ShowTips(LSTR(1090008))
    --     return
    -- end
    -- if _G.FishMgr:IsInFishState() then
    --     MsgTipsUtil.ShowTips(LSTR(1090009))
    --     return
    -- end

    -- 在高空飞行时
    if MountVM.IsMajorInFly and MountVM.FlyHigh then
        MsgTipsUtil.ShowTips(LSTR(1090010))
        return false
    end

    local EntityID = MajorUtil.GetMajorEntityID()
    if self.PrecallMap[EntityID] ~= nil then
        return false
    end

    -- 未拥有坐骑
    if MountVM.MountList ~= nil and #MountVM.MountList == 0 or InResID ~= nil and MountVM:IsNotOwnedMount(InResID) then
        MsgTipsUtil.ShowTips(LSTR(1090011))
        return false
    end

    -- 通用状态判断
    if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_CALL_MOUNT, true) then
        return false
    end

    -- 没有受管理的状态判断
    if _G.EmotionMgr:IsSitState(EntityID) then
        MsgTipsUtil.ShowTips(LSTR(1090012))
        return false
    end

    -- 寻宝挖掘中不让召唤
    if _G.TreasureHuntMgr:GetEntityIsDigging(EntityID) then
        MsgTipsUtil.ShowTipsByID(40157)
        return false
    end

    if not MountVM.AllowFlyRide and MajorActor:IsSwimming() then
        MsgTipsUtil.ShowTips(LSTR(1090017))
        return false
    end
    if self.IsSingBarPlay then
        return
    end
    local AttrComponent = ActorUtil.GetActorAttributeComponent(EntityID)
	if nil ~= AttrComponent then
		local ChangeRoleID = AttrComponent:GetChangeRoleID()
        if ChangeRoleID ~= 0 then
            MsgTipsUtil.ShowTips(LSTR(1090012))
            return false
        end
    end
    if MajorUtil.IsUsingSkill() then
        FLOG_INFO("[mount] SendMountCall while using skill")
        return false
    end

    -- if _G.SingBarMgr:GetMajorIsSinging() then
    --     return
    -- end

    if InResID == nil then
        InResID = self:SelectMountResID()
    end
    if InResID <= 0 then
        FLOG_INFO("[mount] SendMountCall Invalid InResID %s", tostring(InResID))
        return
    end

    local MajorRideComp = MajorActor:GetRideComponent()
    if MajorRideComp ~= nil and MajorRideComp:IsWaitingHost() then
        MsgTipsUtil.ShowTips(LSTR(1090012))
        return
    end

    self.bIsRequestingMount = true
    local function Callback(bIsInterrupted)
        if bIsInterrupted then
            self:InterruptMountCall()
        else
            local function FuncSendMountCall()
                self:DoSendMountCall()
            end
            self.FuncSendMountCallTimer = _G.TimerMgr:AddTimer(self, FuncSendMountCall, 1)
        end
    end
    if not bImmidiate then
        SingBarMgr:MajorSingBySingStateIDWithoutInteractiveID(33, Callback)
    end

    local SubMsgID = ProtoCS.MountCmd.MountCmdPreCallOut
    local MsgBody = {ResID = InResID}
    self.PrecallMap[EntityID] = {}
    self.PrecallMap[EntityID].ResID = InResID
    self:PlayMountSingAnimation(EntityID)
    self:SendEquipCommon(SubMsgID, "PreCall", MsgBody)
    MountVM:SetRecentCall(InResID)
    if bImmidiate then
        self:DoSendMountCall()
    end

    self.SendMountCallTimeStamp = TimeUtil.GetServerTimeMS()
end

function MountMgr:DoSendMountCall()
    if self.bIsRequestingMount then
        self:SendEquipCommon(MOUNT_SUB_ID.MountCmdCallOut, nil, nil)
    end
end

function MountMgr:InterruptMountCall()
    local EntityID = MajorUtil.GetMajorEntityID()
    self:PlayMountSingEndAnimation(EntityID, true)
    self.bIsRequestingMount = false
    FLOG_INFO("interrupt mount call")
end

function MountMgr:SendMountCancelCall(MountCancelCallback, bToGround)
    if MountVM.IsMajorInFly and MountVM.FlyHigh then
        MsgTipsUtil.ShowTipsByID(153019)
        return
    end

    local MajorRideComp = MajorUtil.GetMajorRideComponent()
    if not MajorRideComp or MajorRideComp:IsAssembling() then
        return
    end

    if MountVM.IsInRide then
        self:SendEquipCommon(MOUNT_SUB_ID.MountCmdCallBack, nil, nil)
        self.bIsRequestingCancelMount = true
    end
    if MountCancelCallback ~= nil then
        self.MountCancelCallback = MountCancelCallback
    end
    if bToGround == nil then
        self.bToGround = false
    else
        self.bToGround = bToGround
    end
end

function MountMgr:ForceSendMountCancelCall(MountCancelCallback)
    self:SendEquipCommon(MOUNT_SUB_ID.MountCmdCallBack, nil, nil)
    if MountCancelCallback ~= nil then
        self.MountCancelCallback = MountCancelCallback
    end
end

function MountMgr:SendMountRecall(ResID)
    if MountVM.IsMajorInFly and MountVM.FlyHigh then
        MsgTipsUtil.ShowTips(LSTR(1090010))
        return
    end
    local function Callback()
        self:SendMountCall(ResID)
    end
    self:GetDownMount(false, Callback)
end

function MountMgr:SendMountNextSeat()
    if MountVM.IsHostRideFull then
        MsgTipsUtil.ShowTips(LSTR(1090013))
    else
        self:SendEquipCommon(MOUNT_SUB_ID.MountCmdNextSeat, nil, nil)
    end
end

function MountMgr:SendMountLike(InResID, InLike)
    if InLike then
        local LikeLimit = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GLOBAL_CFG_MOUNT_LIKE_LIMIT, "Value")
        local LikeList = self:GetLikeList()
        if #LikeList >= LikeLimit[1] then
            MsgTipsUtil.ShowTips(LSTR(1090014))
            return
        end
    end

    local MountLikeReq = {ResID = InResID, Like = InLike}
	self:SendEquipCommon(MOUNT_SUB_ID.MountCmdLike, "Like", MountLikeReq)
end

function MountMgr:SendMountApplyOn(InRoleID)
    local OtherActor = ActorUtil.GetActorByRoleID(InRoleID)
    if OtherActor == nil then
        _G.FLOG_WARNING("[mount] SendMountApplyOn OtherActor Is nil!")
        return
    end
    local OtherStateComp = OtherActor:GetStateComponent()
    if OtherStateComp == nil then
        _G.FLOG_WARNING("[mount] SendMountApplyOn OtherStateComp Is nil!")
        return
    end

    local MajorActor = MajorUtil.GetMajor()
    if MajorActor then
        local MajorLocation = MajorActor:FGetActorLocation()
        local OtherLocation = OtherActor:FGetActorLocation()
        if (MajorLocation - OtherLocation):Size() >= ApplyDistance then
            MsgTipsUtil.ShowTipsByID(153005)
            return
        end
    end

    if OtherStateComp:IsDeadState() or OtherStateComp:IsCrafting() or OtherStateComp:IsGathering() or OtherStateComp:IsInCombatNetState()
    or OtherStateComp:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_FISH) or OtherStateComp:IsInNetState(ProtoCommon.CommStatID.CommStatPerform)
    or OtherStateComp:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_SPELL) then
        MsgTipsUtil.ShowTips(LSTR(1090071))
        return false
    end

    local OtherOnlineStatus = _G.OnlineStatusMgr:GetStatusByRoleID(InRoleID);
    if OtherOnlineStatus ~= nil and OnlineStatusUtil.CheckBit(OtherOnlineStatus, ProtoRes.OnlineStatus.OnlineStatusView) then
        MsgTipsUtil.ShowTips(LSTR(1090071))
        return false
    end

    -- 通用状态判断
    if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_MOUNT_RIDE_APPLY, true) then
        return false
    end


    -- local MajorStateComp = MajorUtil.GetMajorStateComponent()
    -- if MajorStateComp == nil then
    --     _G.FLOG_WARNING("[mount] SendMountApplyOn MajorStateComp Is nil!")
    -- end
    -- if MajorStateComp:IsDeadState() or MajorStateComp:IsCrafting() or MajorStateComp:IsGathering() or MajorStateComp:IsInCombatNetState()
    -- or MajorStateComp:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_FISH) or MajorStateComp:IsInNetState(ProtoCommon.CommStatID.CommStatPerform)
    -- or MajorStateComp:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_SPELL) or _G.PhotoMgr.IsOnPhoto then
    --     MsgTipsUtil.ShowTips(LSTR(1090070))
    --     return false
    -- end

    local AnimComp = MajorUtil.GetMajorAnimationComponent()
    if AnimComp == nil then
        _G.FLOG_WARNING("[mount] SendMountApplyOn AnimComp Is nil!")
    end
    local AnimInst = AnimComp:GetPlayerAnimInstance()
    -- 在播放复活动画
	if AnimInst:GetNotPlayReviveAnim() == false then
		return false
	end

    local MountApplyOnReq = {RoleID = InRoleID}
    self:SendEquipCommon(MOUNT_SUB_ID.MountCmdApplyOn, "ApplyOn", MountApplyOnReq)
    return true
end

function MountMgr:SendMountReplyOn(InRoleID, InReply)
    if self:IsRequestingMount() then
        MsgTipsUtil.ShowTips(LSTR(1090070))
        return false
    end

    local OtherActor = ActorUtil.GetActorByRoleID(InRoleID)
    if OtherActor == nil then
        _G.FLOG_WARNING("[mount] SendMountApplyOn OtherActor Is nil!")
        return
    end
    local OtherStateComp = OtherActor:GetStateComponent()
    if OtherStateComp == nil then
        _G.FLOG_WARNING("[mount] SendMountApplyOn OtherStateComp Is nil!")
        return
    end

    -- if OtherStateComp:IsDeadState() or OtherStateComp:IsCrafting() or OtherStateComp:IsGathering() or OtherStateComp:IsInCombatNetState()
    -- or OtherStateComp:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_FISH) or OtherStateComp:IsInNetState(ProtoCommon.CommStatID.CommStatPerform)
    -- or OtherStateComp:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_SPELL) then
    --     MsgTipsUtil.ShowTips(LSTR(1090071))
    --     return false
    -- end

    -- local OtherOnlineStatus = _G.OnlineStatusMgr:GetStatusByRoleID(InRoleID);
    -- if OtherOnlineStatus ~= nil and OnlineStatusUtil.CheckBit(OtherOnlineStatus, ProtoRes.OnlineStatus.OnlineStatusView) then
    --     MsgTipsUtil.ShowTips(LSTR(1090071))
    --     return false
    -- end

    --回想状态先退出回想
    if _G.MusicPlayerMgr:CheckCurRecallState() then
        _G.MusicPlayerMgr:ExitRevertState()
    end

    -- 通用状态判断
    if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_MOUNT_RIDE_INVITE_AGREE, true) then
        return false
    end
    
    -- local MajorStateComp = MajorUtil.GetMajorStateComponent()
    -- if MajorStateComp == nil then
    --     _G.FLOG_WARNING("[mount] SendMountApplyOn MajorStateComp Is nil!")
    -- end
    -- if MajorStateComp:IsDeadState() or MajorStateComp:IsCrafting() or MajorStateComp:IsGathering() or MajorStateComp:IsInCombatNetState()
    -- or MajorStateComp:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_FISH) or MajorStateComp:IsInNetState(ProtoCommon.CommStatID.CommStatPerform)
    -- or MajorStateComp:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_SPELL) or _G.PhotoMgr.IsOnPhoto then
    --     MsgTipsUtil.ShowTips(LSTR(1090070))
    --     return false
    -- end

    local AnimComp = MajorUtil.GetMajorAnimationComponent()
    if AnimComp == nil then
        _G.FLOG_WARNING("[mount] SendMountApplyOn AnimComp Is nil!")
    end
    local AnimInst = AnimComp:GetPlayerAnimInstance()
    -- 在播放复活动画
	if AnimInst:GetNotPlayReviveAnim() == false then
		return false
	end

    local MountReplyOnReq = {RoleID = InRoleID, Reply = InReply}
    self:SendEquipCommon(MOUNT_SUB_ID.MountCmdReplyOn, "ReplyOn", MountReplyOnReq)
    return true
end

function MountMgr:SendEquipCommon(SubMsgID, DataKey, DataReq)
	local CsReq = {Cmd = SubMsgID}
    if DataKey ~= nil then
        CsReq[DataKey] = DataReq
    end
	GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_MOUNT, SubMsgID, CsReq)
end
-----------------------------------------------Req end-----------------------------------------------

function MountMgr:OnGameEventPWorldMapEnter(Params)
    local MapCfg = MapCfgTable:FindCfgByKey(Params.CurrMapResID)
    if MapCfg == nil then return end

    self:SetAllowRide(MapCfg.AllowRide > 0, self.AllowRideReason.MapConfig)
    self:SetAllowFly(_G.AetherCurrentsMgr:IsCurMapCanFlyLimitByAetherCurrent(), self.AllowFlyReason.WindPulse)
    self:SetAllowFly(MapCfg.AllowFlyRide > 0, self.AllowFlyReason.MapConfig)
    self:SetAllowFly(self.ForbidFlyAreaID == 0, self.AllowFlyReason.AreaConfig)
    MountVM.bFlyLimitedByMap = MapCfg.AllowFlyRide == 0

    if self:IsMajorAssembling() then
        self:ReleaseRideComponentAssembleState()
    end

    if self.InviteTransWorldEnterCallback ~= nil then
        self.InviteTransWorldEnterCallback()
        self.InviteTransWorldEnterCallback = nil
    end
    self.bIsRequestingMount = false
    self.bIsRequestingCancelMount = false
end

function MountMgr:OnGameEventPWorldExit(Params)
    self.ForbidFlyAreaID = 0
    _G.TimerMgr:CancelTimer(self.FuncSendMountCallTimer)
end

function MountMgr:OnGameEventWorldPreLoad(Params)
    -- local Major = MajorUtil.GetMajor()
    -- if Major ~= nil then
    --     self:HandleRideByResID(Major, 0)
    -- end
end

--@return MountAbility
function MountMgr:GetMountType(InResID)
    if InResID == nil then
        return ProtoCS.MountAbility.MountAbilityNone
    end
    local c_ride_cfg = RideCfg:FindCfgByKey(InResID)
    if c_ride_cfg == nil then
        return ProtoCS.MountAbility.MountAbilityNone
    end

    if c_ride_cfg.MountType == ProtoCommon.MountType.MountTypeNone then
        return ProtoCS.MountAbility.MountAbilityNone
    end

    if c_ride_cfg.MountType == ProtoCommon.MountType.MountFlying then
        return ProtoCS.MountAbility.MountAbilityFly
    end

    if c_ride_cfg.MountType == ProtoCommon.MountType.MountWalking then
        return ProtoCS.MountAbility.MountAbilityWalk
    end
    return ProtoCS.MountAbility.MountAbilityNone
end

---获取坐骑用途类型
---@param RideResID
---@return ProtoRes.EnumRidePurposeType
function MountMgr:GetPurposeType(RideResID)
    if RideResID then
        local RideCfgItem = RideCfg:FindCfgByKey(RideResID)
        if RideCfgItem then
            return RideCfgItem.PurposeType or ProtoRes.EnumRidePurposeType.Call
        end
    end
    return ProtoRes.EnumRidePurposeType.Call
end

function MountMgr:OnGameEventActorVMCreate(Params)
    if Params.EntityID == MajorUtil.GetMajorEntityID() then
        MountVM:LoadSavedSettings()
        MountVM:LoadNewInfo()
        MountCustomMadeVM:LoadNewInfo()
        self:SendMountListQuery()
    end
end

function MountMgr:GetMountDesc(InResID)
    local Cfg = RideTextCfg:FindCfgByKey(InResID)
    if Cfg == nil then
        return ""
    end
    return Cfg.Expository
end

function MountMgr:IsInRide()
    return MountVM.IsInRide == true
end

function MountMgr:IsRidingOnResID(InResID)
    if not MountVM.IsInRide then
        return false
    end
    return (MountVM.CurRideResID == InResID)
end

--其他人上host的坐骑
function MountMgr:OtherToHost(HostID, OtherActor, Pos, ResID, ActorLocation)
    if OtherActor == nil or OtherActor:GetAttributeComponent() == nil then
        FLOG_ERROR("其他人上host的坐骑, OtherActor = nil")
        return
    end
    local RideComp = OtherActor:GetRideComponent()
    if RideComp == nil then return end
    local bAlreadyInRide = RideComp:IsInRide()
    RideComp:UseOtherRide(HostID, Pos)
    MountVM:SetRideState()
    if not bAlreadyInRide and (HostID == MajorUtil.GetMajorEntityID() or OtherActor:GetAttributeComponent() and OtherActor:GetAttributeComponent().EntityID == MajorUtil.GetMajorEntityID()) then
        _G.MsgTipsUtil.ShowTips(LSTR(1090056))
    end
    local OtherActorEntityID = OtherActor:GetAttributeComponent().EntityID

    if ActorLocation ~= nil then
        RideComp:SetBindLocation(ActorLocation)
    end

    local Params = {EntityID = OtherActorEntityID, MountResID = RideComp:GetRideResID(), HostID = HostID, bIsTransfer = bAlreadyInRide, Pos = Pos}
    _G.EventMgr:SendEvent(_G.EventID.MountCall, Params)
    self:OnMountCall(Params)
end

function MountMgr:OnGameEventMajorCreate(Params)
    self:HandleCachedBinds(Params.ULongParam1)
    MountVM:SetRideState()
end

function MountMgr:OnGameEventPlayerCreate(Params)
    self:HandleCachedBinds(Params.ULongParam1)
end

function MountMgr:OnGameEventMountAssembleAllEnd(Params)
    local EntityID = Params.ULongParam1
    --FLOG_INFO("[mount] Mount assemble all end: EntityID=%s", tostring(EntityID))
    local Major = MajorUtil.GetMajor()
    if Major == nil then return false end
    local AvatarComponent = Major:GetAvatarComponent()
    if AvatarComponent then
        AvatarComponent:WaitForTextureMips()
     end
    self:HandleCachedBinds(EntityID)
    -- 屏蔽技能
    if MajorUtil.IsMajor(EntityID) then
        local RideComp = Major:GetRideComponent()
        -- 在自己的坐骑上
        if RideComp and RideComp:IsInRide() and not RideComp:IsInOtherRide() then 
            local ResID = RideComp:GetRideResID()
            local Cfg = RideCfg:FindCfgByKey(ResID)
            if Cfg and Cfg.DisableSkill == 1 then
                self.bIsDisableOtherSkill = true
                EventMgr:SendEvent(EventID.SwitchPeacePanel, 0)
            end
        end
    end
end

function MountMgr:OnGameEventMajorSingBarBegin(EntityID, SingStateID)
    local Major = MajorUtil.GetMajor()
    if Major ~= nil and MountVM.IsInRide then
        --add by sammrli 坐骑上允许传送吟唱
        if SingBarMgr:GetIsTransferSing(SingStateID) then
            return
        end
        self:SendMountCancelCall()
    end
end

function MountMgr:OnGameEventMajorSingBarOver(EntityID, IsBreak, SingStateID)
    -- if IsBreak and SingStateID == 33 then
    --     self.bIsRequestingMount = false
    -- end
end

function MountMgr:GetHostRideComponent()
    local MajorRideCom = MajorUtil.GetMajorRideComponent()
    if MajorRideCom == nil then return end
    local HostEntityID = MajorRideCom:GetHostEntityID()
    local HostActor = ActorUtil.GetActorByEntityID(HostEntityID)
    if HostActor == nil then return end
    return HostActor:GetRideComponent()
end

function MountMgr:IsMountSkill(SkillID)
    if MountVM == nil or MountVM.PlayActionList == nil then
        return false
    end
    for _, Value in ipairs(MountVM.PlayActionList) do
        if SkillID == tonumber(Value) then
            return true
        end
    end
    return false
end

function MountMgr:OnGameEventSkillCast(Params)
    -- local SkillID = Params.SkillID
    -- if not self:IsMountSkill(SkillID) then
    --     self:SendMountCancelCall(nil, true)
    -- end
end

-- function MountMgr:OnGameEventSkillStart(Params)
--     local EntityID = Params.ULongParam1
-- 	if not MajorUtil.IsMajor(EntityID) then return end

--     if self:GetPurposeType(MountVM.CurRideResID) == ProtoRes.EnumRidePurposeType.Transport then
--         return
--     end

--     local MainSkillID = Params.IntParam2
--     if self:IsMountSkill(MainSkillID) then
--         self:MountLockMove(true)
--     end
-- end

-- function MountMgr:OnGameEventSkillEnd(Params)
--     local EntityID = Params.ULongParam1
-- 	if not MajorUtil.IsMajor(EntityID) then return end

--     local MainSkillID = Params.IntParam2
--     if self:IsMountSkill(MainSkillID) then
--         self:MountLockMove(false)
--     end
-- end

-- function MountMgr:MountLockMove(Lock)
--     local MajorEntityID = MajorUtil.GetMajorEntityID()
--     local StateComponent = ActorUtil.GetActorStateComponent(MajorEntityID)
--     if StateComponent ~= nil then
--         StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanMove, not Lock, "MountSkill")
--         --FLOG_INFO(Lock and "[mount] skill lock move" or "[mount] skill unlock move")
--     end
-- end

function MountMgr:PlayMountSingAnimation(EntityID)
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if Actor == nil or Actor:IsInRide() then return end

    local PrecallInfo = self.PrecallMap[EntityID]
    if PrecallInfo ~= nil and PrecallInfo.QueueID ~= nil then
        --FLOG_INFO("[mount] sing animation is already playing")
        return
    end

    local QueueID = 0
    if Actor:IsHoldWeapon() then
        if MajorUtil.IsMajor(EntityID) then
            _G.EmotionMgr:SendStopEmotionAll()
        end
        local Animations = {
            [1] = {AnimPath = "/Game/Assets/Character/Action/battle/battle_end.battle_end"},
            [2] = {AnimPath = "/Game/Assets/Character/Action/org/cbnp_u_itm_1.cbnp_u_itm_1"},
            [3] = {AnimPath = "/Game/Assets/Character/Action/org/cbnp_u_itm_2lp.cbnp_u_itm_2lp"},
        }
        QueueID = _G.AnimMgr:PlayAnimationMulti(EntityID, Animations)
    else
        local Animations = {
            [1] = {AnimPath = "/Game/Assets/Character/Action/org/cbnp_u_itm_1.cbnp_u_itm_1"},
            [2] = {AnimPath = "/Game/Assets/Character/Action/org/cbnp_u_itm_2lp.cbnp_u_itm_2lp"},
        }
        QueueID = _G.AnimMgr:PlayAnimationMulti(EntityID, Animations)
    end
    self.PrecallMap[EntityID].QueueID = QueueID
    --FLOG_INFO("[mount] play sing animation %s", tostring(QueueID))

    local function PrecallTimeout()
        self:PlayMountSingEndAnimation(EntityID, false)
        self.EntitySingStateRecordMap[EntityID] = false
    end
    local TimerHandle = _G.TimerMgr:AddTimer(self, PrecallTimeout, 1.5)
    self.PrecallMap[EntityID].TimerHandle = TimerHandle

    _G.EventMgr:SendEvent(EventID.MountPreCallStart, EntityID)
    if self.EntitySingStateRecordMap == nil then
        self.EntitySingStateRecordMap = {}
    end
    self.EntitySingStateRecordMap[EntityID] = true
end

function MountMgr:IsEntitySing(EntityID)
    if EntityID ~= nil and self.EntitySingStateRecordMap[EntityID] ~= nil and self.EntitySingStateRecordMap[EntityID] == true then
        return true
    end
    return false
end

function MountMgr:PlayMountSingEndAnimation(EntityID, bInterrupt)
    local PrecallInfo = self.PrecallMap[EntityID]
    if PrecallInfo == nil then return end
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if Actor == nil or Actor:GetAnimationComponent() == nil then return end
    _G.AnimMgr:StopAnimationMulti(EntityID, self.PrecallMap[EntityID].QueueID)
    Actor:GetAnimationComponent():PlayAnimationAsync("/Game/Assets/Character/Action/org/cbnp_u_mt_start.cbnp_u_mt_start", nil, 1, 0.25, 0.25)

    _G.TimerMgr:CancelTimer(PrecallInfo.TimerHandle)

    local Cfg = RideCfg:FindCfgByKey(self.PrecallMap[EntityID].ResID)
    if Cfg ~= nil then
        if bInterrupt then
            -- local FailSound = Cfg.MountCallFailse
            -- _G.UE.UAudioMgr:Get():LoadAndPostEvent(FailSound, Actor, true)
        else
            local SuccessSound = Cfg.MountCallse
            _G.UE.UAudioMgr:Get():LoadAndPostEvent(SuccessSound, Actor, true)
        end
    end

    self.PrecallMap[EntityID] = nil
end

function MountMgr:OnGameEventBeginTrueJump(Params)
    local EntityID = Params.ULongParam1
    self:PlayMountSingEndAnimation(EntityID, true)
end

function MountMgr:OnGameEventMajorDead(Params)
    -- local Major = MajorUtil.GetMajor()
    -- self:HandleRideByResID(Major, 0)
end

function MountMgr:OnGameEventOtherCharacterDead(Params)
    -- local ActorID = Params.ULongParam1
    -- local Actor = ActorUtil.GetActorByEntityID(ActorID)
    -- self:HandleRideByResID(Actor, 0)
end

function MountMgr:OnGameEventMajorFirstMove()
    local MajorRideComp = MajorUtil.GetMajorRideComponent()

    if MajorRideComp ~= nil and MajorRideComp:IsMountFall() and not MountVM.IsOnGround then
        local MajorController = MajorUtil.GetMajorController()
        if MajorController == nil then return end
        MajorController:JumpEnd()
    end
end

function MountMgr:OnGameEventMountTouchCeiling()
    MsgTipsUtil.ShowTips(LSTR(1090015))
end

function MountMgr:OnNetStateUpdate(Params)
	local EntityID = Params.ULongParam1
	if not MajorUtil.IsMajor(EntityID) then
		return
	end
	local StateType = Params.IntParam1
	if StateType ~= ProtoCommon.CommStatID.COMM_STAT_COMBAT then
		return
	end
	MountVM.IsCombatState = Params.BoolParam1
end

function MountMgr:OnGameEventActorVelocityUpdate(Params)
    local EntityID = Params.ULongParam1
	if not MajorUtil.IsMajor(EntityID) then return end
    self:UpdateMountBGMValume()
end

function MountMgr:OnGameEventCharacterLanded(Params)
    local EntityID = Params.ULongParam1
    if not MajorUtil.IsMajor(EntityID) then return end

    if self.MountCancelCallback ~= nil then
        local ShowDelayTime = 0.2
        local function MountCallback()
            if self.MountCancelCallback ~= nil then
                CommonUtil.XPCall(nil, self.MountCancelCallback)
                self.MountCancelCallback = nil
            end
        end
        self:RegisterTimer(MountCallback, ShowDelayTime)
    end
end

function MountMgr:ReleaseRideComponentAssembleState()
    local Actor = MajorUtil:GetMajor()
    if Actor ~= nil and Actor:GetAvatarComponent() ~= nil and Actor:GetRideComponent() ~= nil then
        local RideComp = Actor:GetRideComponent()
        local AvatarComp = Actor:GetAvatarComponent()
        if RideComp:IsAssembling() then
            AvatarComp:UpdateCurRoleAvatar()
            local Camera = Actor:GetCameraControllComponent()
            if Camera ~= nil then
                Camera:ResetSpringArmToDefault()
            end
        end
    end
end

function MountMgr:UpdateMountBGMValume()
    if not MountVM.IsInRide then return end
    if MajorUtil.GetMajor() == nil then
        _G.UE.UBGMMgr:Get():SetAudioVolumeScaleAtChannel(_G.UE.EBGMChannel.Mount, 0.5)
        return
    end
    local MoveComp = MajorUtil.GetMajor():GetMovementComponent()
    if MoveComp == nil then return end
    if MoveComp.Velocity:SizeSquared2D() > 100 then
        _G.UE.UBGMMgr:Get():SetAudioVolumeScaleAtChannel(_G.UE.EBGMChannel.Mount, 1)
    else
        _G.UE.UBGMMgr:Get():SetAudioVolumeScaleAtChannel(_G.UE.EBGMChannel.Mount, 0.5)
    end
end

function MountMgr:MajorFall()
    if MajorUtil.GetMajor() == nil then return end
    local MoveComp = MajorUtil.GetMajor():GetMovementComponent()
    if MoveComp == nil then return end

	if not MountVM.IsOnGround and MoveComp.Velocity:Size() == 0 then
        local MajorController = MajorUtil.GetMajorController()
        if MajorController == nil then return end
        if _G.UE.USaveMgr.GetInt(SaveKey.bMountFirstMajorFall, 0, true) == 0 then
            _G.UE.USaveMgr.SetInt(SaveKey.bMountFirstMajorFall, 1, true)
            MsgTipsUtil.ShowTips(LSTR(1090016))
        end
		MajorController:MountFall()
	end
end

function MountMgr:GetDownMount(AllowMajorFall, Callback)
	if self:GetPurposeType(MountVM.CurRideResID) == EnumRidePurposeType.Call then
		if not MountVM.IsMajorInFly then
			self:SendMountCancelCall(Callback)
		else
			if MountVM.FlyHigh then
                if AllowMajorFall then
				    self:MajorFall()
                end
			else
				self:SendMountCancelCall(Callback)
			end
		end
	else
		_G.ChocoboTransportMgr:CancelTrasport()
	end
end

function MountMgr:SelectMountResID()
    if MountVM.CallSetting == 1 then --最近召唤
        if MountVM.RecentCall > 0 and not MountVM:IsNotOwnedMount(MountVM.RecentCall) then return MountVM.RecentCall end
        local List = MountVM.MountList
        if List == nil or #List <= 0 then return 0 end
        local ServerLastMount = 0
        for _, MountInfo in pairs(List) do
            if MountVM:IsFlagSet(MountInfo.Flag, ProtoCS.MountFlagBitmap.MountFlagLast) then
                ServerLastMount = MountInfo.ResID
                break
            end
        end
        if ServerLastMount > 0 and not MountVM:IsNotOwnedMount(ServerLastMount) then return ServerLastMount end
        return List[1] and List[1].ResID or 0
    elseif MountVM.CallSetting == 2 then --全部随机
        local List = MountVM.MountList
        if List ~= nil then
            local CantCallMount = true
            while CantCallMount do
                local RandomIndex = math.random(1, #List)
                local Mount = List[RandomIndex]
                if MountPanelVM:IsShowMount(Mount) then
                    CantCallMount = false
                    return Mount.ResID
                end
            end
        end
    elseif MountVM.CallSetting == 3 then --收藏随机
        local List = self:GetLikeList()
        if #List <= 0 then
            return 1
        else
            local RandomIndex = math.random(1, #List)
            local Mount = List[RandomIndex]
            return Mount.ResID
        end
    end
    return
end

function MountMgr:GetLikeList()
    if self.LikeList == nil then
        self:UpdateMountLikeList()
    end
    return self.LikeList
end

function MountMgr:UpdateMountLikeList()
    self.LikeList = {}
    for _,v in ipairs(MountVM.MountList) do
        local IsLike = MountVM:IsFlagSet(v.Flag, ProtoCS.MountFlagBitmap.MountFlagLike)
        if IsLike then
            table.insert(self.LikeList, v)
        end
    end
end


function MountMgr:MajorFly(FromGround)
    local MajorController = MajorUtil.GetMajorController()
    if MajorController == nil then return end
    if FromGround == nil or FromGround then
        MajorController:MountFly()
    else
        MajorController:SwitchFlyInAir()
    end
end

function MountMgr:IsMountOwned(ResID)
    return MountVM.MountMap ~= nil and MountVM.MountMap[ResID] ~= nil
end

function MountMgr:PlayAction(SkillID, Index)
    local MountSkillVM = MountVM.MountSkillVMList[Index]
    if MountSkillVM ~= nil and not MountSkillVM:IsInCD() then
        if MountSkillVM.ActionType == 1 then
            --FLOG_INFO("[mount] Mount play action: "..SkillID)
            local MajorEntityID = MajorUtil.GetMajorEntityID()
            SkillUtil.CastSkill(MajorEntityID, 0, SkillID)
            MountSkillVM:UpdateCD()
        elseif MountSkillVM.ActionType == 2 then
            local Major = MajorUtil.GetMajor()
            if Major and Major:GetAnimationComponent() then
                local AnimComp = Major:GetAnimationComponent()
                local AtlPath = AnimComp:GetActionTimeline(MountSkillVM.Timeline)
                local function Callback()
                    --self:MountLockMove(false)
                end
                AnimComp:PlayAnimationCallBack(AtlPath, Callback)
                --self:MountLockMove(true)
            end
        end
    end
end

function MountMgr:IsMajorAssembling()
    local RideComp = MajorUtil.GetMajorRideComponent()
    if RideComp == nil then return false end

    return RideComp:IsAssembling()
end

function MountMgr:IsRequestingMount()
    if TimeUtil.GetServerTimeMS() - self.SendMountCallTimeStamp > 3000 then
        self.bIsRequestingMount = false
    end
    return self.bIsRequestingMount
end

function MountMgr:IsDisableOtherSkill()
    local RideComp = MajorUtil.GetMajorRideComponent()
    if RideComp == nil then 
        return false 
    end
    return self.bIsDisableOtherSkill
end

function MountMgr:OpenMountArchive()
    self:SendMountListQuery()
    DataReportUtil.ReportMountInterSystemFlowData(2, 2)
    UIViewMgr:ShowView(UIViewID.MountArchivePanel)
end

function MountMgr:OnChocoboChg(MsgBody)
    local EntityID = MsgBody.Chocobo.Master
    local ID = EntityID == MajorUtil.GetMajorEntityID() and 1 or EntityID
    local OldArmor = self.ChocoboArmor[ID]
    local Armor = MsgBody.Chocobo.Chocobo.Armor
    local StainID =  MsgBody.Chocobo.Chocobo.Color
    if StainID == nil then
        StainID = 0
    end
    self.ChocoboArmor[ID] = Armor
    self.ChocoboColor[ID] = StainID
    --FLOG_INFO("[mount] ChocoboChg EntityID=%d, Data=%s", MsgBody.Chocobo.Master, table.tostring(MsgBody.Chocobo.Chocobo.Armor))

    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if Actor == nil then return end

    local RideComp = Actor:GetRideComponent()
    if RideComp == nil then return end

    local HeadChocoboEquipCfg = BuddyEquipCfg:FindCfgByKey(Armor.Head)
    local HeadString = HeadChocoboEquipCfg and HeadChocoboEquipCfg.ModelString or ""
    local FeetChocoboEquipCfg = BuddyEquipCfg:FindCfgByKey(Armor.Feet)
    local FeetString = FeetChocoboEquipCfg and FeetChocoboEquipCfg.ModelString or ""
    local BodyChocoboEquipCfg = BuddyEquipCfg:FindCfgByKey(Armor.Body)
    local BodyString = BodyChocoboEquipCfg and BodyChocoboEquipCfg.ModelString or ""
    if self.bIsChocobo then
        RideComp:ChangeStainID(StainID)
    end
    RideComp:ChangeMountPartByString(HeadString, BodyString, "", FeetString)

end

function MountMgr:OnNetMsgBuddyQuery(MsgBody)
    self.ChocoboArmor[1] = MsgBody.Info.Armor
    self.ChocoboColor[1] = MsgBody.Info.Color.RGB
    --FLOG_INFO("[mount] Major Chocobo Query Data=%s", table.tostring(MsgBody.Info.Armor))
end

function MountMgr:OnGameEventUseMount(Params)
    if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMount) 
        and MountVM.MountList ~= nil 
        and #MountVM.MountList > 0 
        and MountVM.AllowRide 
        and not MountVM.IsInRide then
        self:SendMountCall()
        self.bIsAutoPathMoving = true
    end
end

function MountMgr:OnGameEventStopAutoMoving(Params)
    self.bIsAutoPathMoving = false
end

function MountMgr:OnGameEventStopAutoPathMove(Params)
    self.bIsAutoPathMoving = false
end

function MountMgr:OnGameEventModuleOpenNotify(Params)
    if Params == ProtoCommon.ModuleID.ModuleIDMount then
      --  self:PopUpAllMountItem()
        WorldMapVM.BtnMountSpeedVisible = true
    end
end

function MountMgr:OnEnterWater(Params)
    if not self:IsRequestingMount() then return end
    local EntityID = Params.ULongParam1
    if EntityID ~= MajorUtil.GetMajorEntityID() then return end
    if MountVM.AllowFlyRide then return end

    SingBarMgr:OnBreakSingOver()
    self:InterruptMountCall()
    MsgTipsUtil.ShowTips(LSTR(1090017))
end

function MountMgr:SetAllowRide(bEnable, Reason)
    if Reason == nil then return end
    if bEnable then
        self.AllowRideFlags = self.AllowRideFlags & ~(1 << Reason)
    else
        self.AllowRideFlags = self.AllowRideFlags | (1 << Reason)
    end
    MountVM.AllowRide = self.AllowRideFlags == 0
end

function MountMgr:SetAllowFly(bEnable, Reason)
    if Reason == nil then return end
    if bEnable then
        self.AllowFlyFlags = self.AllowFlyFlags & ~(1 << Reason)
    else
        self.AllowFlyFlags = self.AllowFlyFlags | (1 << Reason)
    end
    MountVM.AllowFlyRide = (self.AllowFlyFlags == 0)
    local RideComp = MajorUtil.GetMajorRideComponent()
    if RideComp ~= nil then
        RideComp:SetAllowFlying(MountVM.AllowFlyRide)
    end

    --FLOG_INFO("[mount] SetAllowFly: AllowFlyFlags=%s, Enable=%s, Reason=%s", tostring(self.AllowFlyFlags), tostring(bEnable), tostring(Reason))
end

-- 设置可以强行能飞，陆行鸟飞行用,最高优先级
function MountMgr:SetbForceCanFly()
    if MountVM.AllowFlyRide then
        return
    end
    MountVM.AllowFlyRide = true
    local RideComp = MajorUtil.GetMajorRideComponent()
    if RideComp ~= nil then
        RideComp:SetAllowFlying(MountVM.AllowFlyRide)
    end
end

-- 取消可以强行能飞模式, 恢复之前的根据FlyFlag判断的模式
function MountMgr:CancelForceCanFly()
    local AllowFlyFlags = self.AllowFlyFlags
    if AllowFlyFlags == 0 then -- 本来就能飞
        return
    end

    MountVM.AllowFlyRide = false
    local RideComp = MajorUtil.GetMajorRideComponent()
    if RideComp ~= nil then
        RideComp:SetAllowFlying(MountVM.AllowFlyRide)
    end
end

function MountMgr:OnGameEventAetherCurrentMapFlyOpen(EventParams)
    self:SetAllowFly(_G.AetherCurrentsMgr:IsCurMapCanFlyLimitByAetherCurrent(), self.AllowFlyReason.WindPulse)
end

function MountMgr:OnGameEventChocoboTransportBegin(EventParams)
    if not EventParams.bFlyTrans then
        self:SetAllowFly(false, self.AllowFlyReason.ChocoboTransport)
    end
end

function MountMgr:OnGameEventChocoboTransportFinish(EventParams)
    self:SetAllowFly(true, self.AllowFlyReason.ChocoboTransport)
end

function MountMgr:OnFlyHighStateChange(Params)
    local EntityID = Params.ULongParam1
    if MajorUtil.IsMajor(EntityID) then
        MountVM.FlyHigh = Params.BoolParam1
    end
    local RideComp = MajorUtil.GetMajorRideComponent()
    if RideComp ~= nil and RideComp:GetHostEntityID() == EntityID then
        MountVM.FlyHigh = Params.BoolParam1
    end
    --FLOG_INFO("Major FlyHigh = %s", tostring(MountVM.FlyHigh))
end

function MountMgr:PopUpAllMountItem()
    local function FindMountItem(Item)
        local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
        return Cfg and Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_MOUNT and not _G.MountMgr:IsItemUsed(Item.ResID)
    end
    local AllMountItem = _G.BagMgr:FilterItemByCondition(FindMountItem)

    for i = 1, #AllMountItem do
        BagMgr:PopUpEasyUse(AllMountItem[i])
    end
end

function MountMgr:GetSpeedPromoteByMapId(RideResID)
    local Speed = 0
    if self:GetPurposeType(RideResID) == ProtoRes.EnumRidePurposeType.Transport then
        return Speed
    end
    local CurMapId = _G.PWorldMgr:GetCurrMapResID()
    if not CurMapId or MountVM.MountSpeedLevelMap == nil then
        return Speed
    end
    local SpeedLevel = MountVM.MountSpeedLevelMap[CurMapId]
    if SpeedLevel ~= nil and SpeedLevel > 0 then
        Speed = SceneEnterGlobalCfg:FindCfgByKey(ProtoRes.SceneGlobalCfgID.SGCMountSpeedPromote).Value[SpeedLevel]
    end
    return Speed
end

--临时红点储存
--红点依赖后台数据，不能每点一次拉一次全量坐骑，这里临时储存一下
-- function MountMgr:InsertLocalRedPointID(ResId)
--     self.LocalRedTable[ResId] = true
-- end

-- function MountMgr:CheckMountLocalRedPoint(ResId)
--     return self.LocalRedTable[ResId]
-- end

--- 打开坐骑速度主界面
function MountMgr:OpenMountSpeedMainPanel()
    UIViewMgr:ShowView(UIViewID.MountSpeedPanel)
end

--- 获取坐骑速度数据
function MountMgr:LoadMountSpeedCfg()
    local RideSpeedCfgs = RideSpeedCfg:FindAllCfg()
    if RideSpeedCfg == nil then
        FLOG_ERROR("RideSpeedCfg is nil")
        return
    end

    for _, Value in ipairs(RideSpeedCfgs) do
        if Value and Value.ID > 0 then
            local RegionID = MapUtil.GetMapRegionID(Value.ID)
            local UIMapID = MapUtil.GetUIMapID(Value.ID) or 0
            if RegionID then
                local RegionInfo = self.MountSpeedCfg[RegionID] or {}
                local RideSpeedData = {}
                RideSpeedData.MapID = Value.ID
                RideSpeedData.MapName = MapUtil.GetMapName(UIMapID) or LSTR(200012)
                RideSpeedData.QuestID = Value.Quest
                RideSpeedData.ItemID = Value.ItemID
                RideSpeedData.Content = Value.Content
                table.insert(RegionInfo, RideSpeedData)
                self.MountSpeedCfg[RegionID] = RegionInfo
            end
        end
    end
end

function MountMgr:JumpToMountPanel(SelectedResID)
    CommSideBarUtil.ShowSideBarByType(SideBarDefine.PanelType.EasyToUse, SideBarDefine.EasyToUseTabType.Mount, {SelectedResID = SelectedResID})
end

function MountMgr:JumpToCustomMadePanel(MountResID)
    UIViewMgr:ShowView(UIViewID.MountCustomMadePanel, { MountResID = MountResID } )
end

function MountMgr:IsCustomMadeEnabled(MountResID)
    return MountCustomMadeVM:IsCustomMadeEnabled(MountResID)
end

function MountMgr:SendEquipCustomMade(ResID, CustomMadeID)
    local FacadeID = CustomMadeID
    if FacadeID == MountCustomMadeVM:GetDefaultCustomMadeID(ResID) then
        FacadeID = 0
    end
    self:SendEquipCommon(MOUNT_SUB_ID.MountCmdFacade, "Facade", { MountID = ResID, FacadeID = FacadeID } )
    self.bRequestingEquipCustomMade = true
end

function MountMgr:OnReceiveCustomMadeChange(Msg)
    --local EntityID = Msg.EntityID
    local MountResID = Msg.Facade.MountID
    local CustomMadeID = Msg.Facade.FacadeID
    if CustomMadeID == 0 then
        CustomMadeID = MountCustomMadeVM:GetDefaultCustomMadeID(MountResID)
    end

    local Actor = MajorUtil.GetMajor()
    if Actor == nil then return end
    
    self:SetCustomMadeID(Actor, MountResID, CustomMadeID)
    MountVM:SetCustomMadeID(MountResID, CustomMadeID)
    --MountCustomMadeVM:SetCustomMadeID(MountResID, CustomMadeID)

    if self.bRequestingEquipCustomMade then
        MsgTipsUtil.ShowTips(LSTR(1090073))
        self.bRequestingEquipCustomMade = false
    end
end

function MountMgr:SetCustomMadeID(Actor, MountResID, CustomMadeID)
    local RideComp = Actor:GetRideComponent()
    if RideComp == nil then return end

    local CustomCfg = MountCustomCfg:FindCfgByKey(CustomMadeID)
    if CustomCfg == nil then return end

    RideComp:SetImeChanID(MountResID, CustomCfg.ImeChanID)

end

function MountMgr:OnReceiveFacadeUnlock(Msg)
    FLOG_INFO("OnReceiveFacadeUnlock, %s", table.tostring(Msg))
    if Msg.FacadeUnlock == nil or Msg.FacadeUnlock.Facade == nil then return end
    local FacadeMsg = Msg.FacadeUnlock.Facade
    MountCustomMadeVM.UnlockList[FacadeMsg.Facade] = { Flag = FacadeMsg.Flag, Unlocked = true }
	MountCustomMadeVM:UpdateCustomList()
end

--GM打开坐骑预览界面
function MountMgr:GMOpenPreviewMonutView(MountId)
    UIViewMgr:ShowView(UIViewID.PreviewMountView,{ MountId = MountId })
end

function MountMgr:SetAssembleID(ID)
    self.AssembleID = ID
end

--- @type 边缘情况需要有坐骑
function MountMgr:bInEdgeCaseNeedRide()
    if _G.ChocoboTransportMgr:CheckNeedRide() then -- 陆行鸟运输运输跨地图时，不能下坐骑
        return true
    end
    return false
end

function MountMgr:IsCustomMadeOwned(MountCustomID)
	if nil == MountCustomMadeVM.UnlockList then
		return false
	end

	return nil ~= MountCustomMadeVM.UnlockList[MountCustomID]
end

function MountMgr:OnRemoveActivity(Params)
    if nil == Params then
        return
    end
    if nil == Params.Acts then
        print("[MountMgr] Params.Acts == nil ")
        return
    end
    local MountID = 2006         --试骑坐骑id
    local ActivityID = 25012101  --坐骑试骑活动id
    if Params.Acts.ActID == ActivityID then
        if Params.Acts.Status == 3 or Params.Acts.Status == 4 then
            local RideComp = MajorUtil.GetMajorRideComponent()
            if RideComp and RideComp:IsInRide() then
                if MountVM.CurRideResID == MountID then
                    self:GetDownMount(true)
                    MsgTipsUtil.ShowTipsByID(MsgTipsID.RideMountTemporaryActivityEnd)   --"活动已结束，已为您自动下坐骑"
                end
            end
        end
    end
end

--- 在坐骑图鉴中添加ID（GM命令）
function MountMgr:AllMountArchive(...)
    local MountArchivePanelVM = require("Game/Mount/VM/MountArchivePanelVM")
	if nil == MountArchivePanelVM then
		return
	end

    local Count = select('#', ...)
    if Count <= 0 then
        MountArchivePanelVM.ShowAllMount = nil
        return
    end
    local Clear = select(1, ...)
    if Clear == -1 then
        MountArchivePanelVM.ShowAllMount = true
        return
    end
    local Params = {...}
    if Params then
        if type(MountArchivePanelVM.ShowAllMount) == 'table' then
            for k, v in pairs(Params) do
                table.insert(MountArchivePanelVM.ShowAllMount,v)
            end
        else
            MountArchivePanelVM.ShowAllMount = Params
        end
    end
end

--- 断线重连
function MountMgr:OnGameEventRoleLoginRes(Params)
    if not Params or Params.bReconnect ~= true then
        return
    end
    local MountID = 2006         --试骑坐骑id
    local ActivityID = 25012101  --坐骑试骑活动id
	local RideComp = MajorUtil.GetMajorRideComponent()
    if RideComp and RideComp:IsInRide() then
        if MountVM.CurRideResID == MountID then
            local Cfg = ActivityCfg:FindCfgByKey(ActivityID)
            if Cfg ~= nil and Cfg.ChinaActivityTime.RemoveTime then
                local ServerTime = TimeUtil.GetServerTime()
                local OnTimeCfg = TimeUtil.GetTimeFromString(Cfg.ChinaActivityTime.RemoveTime)
                if OnTimeCfg > ServerTime then
                    self:GetDownMount(true)
                    print("[MountMgr]RoleLoginRes ActivityID:%d,DownMountID:%d",ActivityID,MountID)
                end
            end
        end
    end
end

return MountMgr