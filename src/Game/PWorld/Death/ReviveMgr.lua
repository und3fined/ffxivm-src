--
-- Author: haialexzhou
-- Date: 2021-05-10
-- Description:角色复活管理器

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local ReviveCfg = require("TableCfg/ReviveCfg")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MapCfg = require("TableCfg/MapCfg")
local TeleportCrystalCfg = require("TableCfg/TeleportCrystalCfg")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local AudioUtil = require("Utils/AudioUtil")
local EffectUtil = require("Utils/EffectUtil")
local ActorUtil = require("Utils/ActorUtil")
local CommonBoxDefine = require("Game/CommMsg/CommonBoxDefine")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

local CS_CMD = ProtoCS.CS_CMD
local CS_REVIVE_CMD = ProtoCS.CS_REVIVE_CMD
local DelayReviveTimer = 0
local LSTR = _G.LSTR
local CS_COLOSSEUM_COMBAT_CMD = ProtoCS.CS_COLOSSEUM_COMBAT_CMD

local PVPMainCityResID = 1003009 -- PVP主城，复活显示其他的风格

local REVIVE_SOUND_PATH =
    "AkAudioEvent'/Game/WwiseAudio/Events/sound/vfx/magic/SE_VFX_Magic_Raise_Lv1_t/Play_SE_VFX_Magic_Raise_Lv1_t.Play_SE_VFX_Magic_Raise_Lv1_t'"
local REVIVE_ARROW_EFFECT_PATH =
    "VfxBlueprint'/Game/BluePrint/Skill/SkillEffect/BP_Common_HatredArrow_4.BP_Common_HatredArrow_4_C'"

---@class ReviveMgr : MgrBase
local ReviveMgr = LuaClass(MgrBase)

function ReviveMgr:CancelTimer()
    if DelayReviveTimer ~= 0 then
        self:UnRegisterTimer(DelayReviveTimer)
        DelayReviveTimer = 0
    end
end

function ReviveMgr:OnInit()
    self.ReviveInfo = nil --复活效果
    self.ReceivedReviveInfoTime = 0 --收到复活消息的时间点
    self:ResetReviveInfo()
end

function ReviveMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_REVIVE, CS_REVIVE_CMD.CS_REVIVE_CMD_INFO, self.OnReviveRespInfo)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_REVIVE, CS_REVIVE_CMD.CS_REVIVE_CMD_CONFIRM, self.OnReviveRespConfirm)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_REVIVE, CS_REVIVE_CMD.CS_REVIVE_CMD_TRANS, self.OnReviveRespTrans)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_REVIVE, CS_REVIVE_CMD.CS_REVIVE_CMD_READY, self.OnReviveRespReady)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_REVIVE, CS_REVIVE_CMD.CS_REVIVE_CMD_NOTIFY, self.OnReviveRespNotify)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_REVIVE, CS_REVIVE_CMD.CS_REVIVE_CMD_RESCUE, self.OnReviveRespRescue)
    self:RegisterGameNetMsg(
        CS_CMD.CS_CMD_COLOSSEUM_COMBAT,
        CS_COLOSSEUM_COMBAT_CMD.CS_COLOSSEUM_COMBAT_CMD_BUNDLE,
        self.OnNetMsgColosseumBundle
    )
    self:RegisterGameNetMsg(
        CS_CMD.CS_CMD_COLOSSEUM_COMBAT,
        CS_COLOSSEUM_COMBAT_CMD.CS_COLOSSEUM_COMBAT_CMD_TEAM,
        self.OnNetMsgColosseumTeam
    )
end

function ReviveMgr:OnGameEventMajorDead()
    self:SendGetReviveInfo()
end

function ReviveMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.WorldPreLoad, self.CancelTimer)
    self:RegisterGameEvent(EventID.SidebarItemTimeOut, self.OnGameEventSidebarItemTimeOut) --侧边栏Item超时
    self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldExit)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
    self:RegisterGameEvent(EventID.NetworkReconnectLoginFinished, self.OnNetworkReconnectLoginFinished)
    self:RegisterGameEvent(EventID.OnRescureInfo, self.OnEventRescureInfo)
    self:RegisterGameEvent(EventID.ActorReviveNotify, self.OnGameEventActorRevive)
    self:RegisterGameEvent(EventID.MajorDead, self.OnGameEventMajorDead)
end

function ReviveMgr:OnBegin()
end

function ReviveMgr:OnEnd()
    self.RescureInfo = nil
end

function ReviveMgr:OnShutdown()
end

---合包处理
function ReviveMgr:OnNetMsgColosseumBundle(MsgBody)
    local ColosseumCombatBundleRsp = MsgBody.bundle_rsp
    if ColosseumCombatBundleRsp == nil then
        return
    end

    for _, ColosseumCombatRsp in ipairs(ColosseumCombatBundleRsp.colosseum_combat_rsp) do
        if ColosseumCombatRsp.Cmd == CS_COLOSSEUM_COMBAT_CMD.CS_COLOSSEUM_COMBAT_CMD_TEAM then
            self:OnNetMsgColosseumTeam(ColosseumCombatRsp)
            break
        end
    end
end

function ReviveMgr:OnNetMsgColosseumTeam(InMsgData)
    if (InMsgData == nil) then
        return
    end

    local ColosseumCombatTeamRsp = InMsgData.team_rsp
    if ColosseumCombatTeamRsp == nil then
        return
    end

    if (not _G.PWorldMgr:CurrIsInPVPColosseum()) then
        return
    end

    local MajorRoleID = MajorUtil.GetMajorRoleID()
    for _, PlayerInfo in ipairs(ColosseumCombatTeamRsp.player_info) do
        if (PlayerInfo.role_id == MajorRoleID) then
            local ReviveTimeStamp = PlayerInfo.respawn_time
            local CurTime = TimeUtil.GetServerLogicTimeMS()
            if (ReviveTimeStamp ~= nil and ReviveTimeStamp > 0 and CurTime < ReviveTimeStamp) then
                UIViewMgr:ShowView(UIViewID.InfoPVPReviveTimeTips, ReviveTimeStamp)
            end
            
            break
        end
    end
end

function ReviveMgr:SendGetReviveInfo()
    local SubMsgID = ProtoCS.CS_REVIVE_CMD.CS_REVIVE_CMD_INFO

    local MsgBody = {
        Cmd = SubMsgID
    }

    _G.GameNetworkMgr:SendMsg(ProtoCS.CS_CMD.CS_CMD_REVIVE, SubMsgID, MsgBody)
end

function ReviveMgr:SendRevive(bIsAccepted)
    local SubMsgID = ProtoCS.CS_REVIVE_CMD.CS_REVIVE_CMD_CONFIRM
    local ReviveConfirm = {Type = ProtoCommon.ReviveChannelType.REVIVE_CHANNEL_BE_REVIVE, IsAccepted = bIsAccepted}
    local MsgBody = {
        Cmd = SubMsgID,
        Confirm = ReviveConfirm
    }

    _G.GameNetworkMgr:SendMsg(ProtoCS.CS_CMD.CS_CMD_REVIVE, SubMsgID, MsgBody)

    --死亡复活重置相机到死亡时刻的参数
    MajorUtil.GetMajorCameraControlComponent():ResetSpringArmForRevive()
end

function ReviveMgr:ShowReviveView()
    self:CancelTimer()
    if self.ReviveInfo == nil then
        return
    end

    if not MajorUtil.IsMajorDead() then
        return
    end

    -- 正在复活不弹窗
    if (self.IsReviving) then
        return
    end

    if (_G.PWorldMgr:CurrIsInPVPColosseum()) then
        -- 水晶冲突里面不显示复活窗口
    else
        --被复活弹窗界面
        if self.ReviveInfo.RescueRoleID > 0 then
            if _G.UIViewMgr:IsViewVisible(_G.UIViewID.BeReviveView) then
                _G.EventMgr:SendEvent(_G.EventID.ReviveInfoUpdate)
            else
                _G.UIViewMgr:ShowView(_G.UIViewID.BeReviveView)
            end

            --有新的复活信息时，关闭其他复活界面
            -- 死亡后弹窗界面, 2023-10-20 美术和策划确定，使用同一的弹窗CommMsgBox UIBP
            --_G.UIViewMgr:HideView(_G.UIViewID.BeDeathView)

            self:HideReviveMsgBox()
            self:RemoveReviveSidebarInfo()

            self.ReceivedReviveInfoTime = _G.TimeUtil.GetServerTime()
        else
            -- 死亡后弹窗界面, 2023-10-20 美术和策划确定，使用同一的弹窗CommMsgBox UIBP
            -- _G.UIViewMgr:ShowView(_G.UIViewID.BeDeathView)
            self.ReviveMapID = self.ReviveInfo.MapID
            self.ReviveCristalID = self.ReviveInfo.CrystalID
            self:ShowReviveMsgBox()
        end
    end
end

function ReviveMgr:OnReviveInfoHandle()
    if nil == self.ReviveInfo then
        return
    end

    if not MajorUtil.IsMajorDead() then
        return
    end

    local Cfg = ReviveCfg:FindCfg("ID = " .. self.ReviveInfo.RuleID)
    if Cfg == nil then
        return
    end

    if Cfg.ReviveType == ProtoCommon.ReviveType.REVIVE_TYPE_NONE then
        if _G.SidebarMgr:GetSidebarItemVM(SidebarDefine.SidebarType.Death) ~= nil then
            _G.SidebarMgr:RemoveSidebarItem(SidebarDefine.SidebarType.Death)
        end

        self:HideReviveMsgBox()
    end

    if Cfg.ReviveType == ProtoCommon.ReviveType.REVIVE_TYPE_REVIVE_POINT then
        _G.PWorldWarningMgr:ClearWarningGroupData()
    end

    local bShowReviveMsgBox = Cfg.IsShowReviveMsgBox == 1
    if self.ReviveInfo.RescueRoleID > 0 then
        bShowReviveMsgBox = true
        local EntityID = ActorUtil.GetEntityIDByRoleID(self.ReviveInfo.RescueRoleID)
        local ActorName = ActorUtil.GetActorName(EntityID)
        self.ReviveRescueRoleName = ActorName
        if (self.ReviveRescueRoleName == nil or self.ReviveRescueRoleName == "") then
            _G.FLOG_ERROR(
                "无法获取角色名字， EntityID : %s, RoleID: %s",
                tostring(EntityID),
                tostring(self.ReviveInfo.RescueRoleID)
            )
        end
    end

    if bShowReviveMsgBox then
        local DelayTime = self.ReviveInfo.RevivableTime - _G.TimeUtil.GetServerTime()
        if (DelayTime > 0) then
            self:CancelTimer()
            DelayReviveTimer = self:RegisterTimer(self.ShowReviveView, DelayTime)
        else
            self:ShowReviveView()
        end
    end
end

function ReviveMgr:OnReviveRespInfo(MsgBody)
    if (not MajorUtil.IsMajorDead) then
        _G.UIViewMgr:HideView(_G.UIViewID.BeReviveView)
        self:ResetReviveInfo()
        self:RemoveReviveSidebarInfo()
        _G.FLOG_WARNING("收到复活信息，但当前玩家已经复活")
        return
    end

    local PReviveInfo = MsgBody.Info
    self.ReviveInfo = PReviveInfo

    -- 解除自动移动
    _G.UE.UActorManager.Get():SetVirtualJoystickIsSprintLocked(false)

    if PReviveInfo then
        _G.EventMgr:SendEvent(
            EventID.OnRescureInfo,
            table.makeconst(
                {
                    RescueRoleID = PReviveInfo.RescueRoleID,
                    RoleID = MajorUtil.GetMajorRoleID(),
                    RescueDeadline = PReviveInfo.RescueDeadline,
                }
            )
        )
    end

    self:OnReviveInfoHandle()
end

function ReviveMgr:ShowReviveMsgBox()
    local Params = {}
    local _revivePosName = self:GetRevivePointString(self.ReviveMapID, self.ReviveCristalID)
    if (_revivePosName ~= nil) then
        Params.TipsText = _revivePosName
    end
    
    Params.CloseBtnCallback = function()
        self:OnClickKeepBtn()
    end

    if (_G.PWorldMgr.BaseInfo ~= nil and _G.PWorldMgr.BaseInfo.CurrPWorldResID == PVPMainCityResID) then
        -- PVP主城的，只显示一个按钮
        local BoxParams = MsgBoxUtil.MakeMsgBoxParams(
            self,
            LSTR(10004), -- 提 示
            LSTR(460017), -- 在决斗中败北，将原地复活
            nil,
            nil,
            function()
                self:OnClickReviveBtn()
            end,
            CommonBoxDefine.BtnUniformType.OneOpRight,
            nil,
            nil,
            LSTR(10002), --确 认,
            Params
        )
        _G.UIViewMgr:ShowView(UIViewID.CommonMsgBox, BoxParams)
    else
        self.CurReviveView = MsgBoxUtil.ShowMsgBoxTwoOp(
            self,
            LSTR(460001), --无法战斗提示
            LSTR(460002), --陷入无法战斗状态，要传送到返回点吗？
            function()
                self:OnClickReviveBtn()
            end,
            function()
                self:OnClickKeepBtn()
            end,
            LSTR(460003), --保留
            LSTR(460004), --确认
            Params
        )
    end
end

-- 获取返回点的名字
function ReviveMgr:GetRevivePointString(MapID, CrystalID)
    local _result = nil
    if (CrystalID ~= nil and CrystalID > 0) then
        -- 这里去找一下水晶
        local _cfg = TeleportCrystalCfg:FindCfgByKey(CrystalID)
        if (_cfg ~= nil) then
            _result = string.format(LSTR(460005), _cfg.CrystalName) --当前返回点：%s
        else
            _G.FLOG_ERROR("无法找到水晶，ID 是：" .. CrystalID)
        end
    else
        if (MapID ~= nil and MapID > 0) then
            local MapTableCfg = MapCfg:FindCfgByKey(MapID)
            if (MapTableCfg ~= nil) then
                local _name = MapTableCfg.DisplayName
                if (_name ~= nil) then
                    _result = string.format(LSTR(460005), _name)
                else
                    local _errorInfo = string.format("地图ID：%d，没有 DisplayName，请检查！", MapID)
                    _G.FLOG_ERROR(_errorInfo)
                end
            end
        end
    end

    return _result
end

function ReviveMgr:OnClickKeepBtn()
    if not MajorUtil.IsMajorDead() then
        return
    end

    if _G.SidebarMgr:GetSidebarItemVM(SidebarDefine.SidebarType.Death) ~= nil then
        _G.SidebarMgr:TryOpenSidebarMainWin()
    else
        _G.SidebarMgr:AddSidebarItem(SidebarDefine.SidebarType.Death)
    end

    _G.UIViewMgr:HideView(_G.UIViewID.CommonMsgBox) -- 这里有风险，因为是通用的消息UIBP，万一有其他的会不会给顶掉了？
end

function ReviveMgr:OnClickReviveBtn()
    self:RemoveReviveSidebarInfo()
    _G.SidebarMgr:TryOpenSidebarMainWin()
    
    local MsgID = ProtoCS.CS_CMD.CS_CMD_REVIVE
    local SubMsgID = ProtoCS.CS_REVIVE_CMD.CS_REVIVE_CMD_CONFIRM
    local ReviveConfirm = {Type = ProtoCommon.ReviveChannelType.REVIVE_CHANNEL_DEFAULT, IsAccepted = nil}
    local MsgBody = {
        Cmd = SubMsgID,
        Confirm = ReviveConfirm
    }

    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 清理数据
function ReviveMgr:ResetReviveInfo()
    self:RemoveReviveSidebarInfo()
    self.ReviveInfo = nil
    self.ReviveMapID = 0
    self.ReviveCristalID = 0
    self:HideReviveMsgBox()
    self.IsReviving = false
    self.ReviveRescueRoleName = nil
end

function ReviveMgr:OnReviveRespCommon(EntityID)
    --复活后关闭相关界面
    if (EntityID == nil or _G.PWorldMgr.MajorEntityID == EntityID) then
        _G.UIViewMgr:HideView(_G.UIViewID.BeReviveView)
        self:ResetReviveInfo()
        self:RemoveReviveSidebarInfo()
    end

    self:MarkReviveByEntityID(EntityID)
end

function ReviveMgr:HideReviveMsgBox()
    if (self.CurReviveView == nil) then
        return
    end

    if (self.CurReviveView.Object == nil or not self.CurReviveView.Object:IsValid()) then
        self.CurReviveView = nil
        return
    end
    self.CurReviveView:Hide()
    self.CurReviveView = nil
end

function ReviveMgr:OnGameEventPWorldExit()
    self:RemoveReviveSidebarInfo()
end

function ReviveMgr:OnGameEventPWorldMapEnter(Params)
    local bReconnect = false
    if Params ~= nil then
        bReconnect = Params.bReconnect
    end

    self.IsReviving = false

    if bReconnect then
        if (MajorUtil.IsMajorDead()) then
            self:SendGetReviveInfo()
        else
            self:RemoveReviveSidebarInfo()
        end
    end
end

function ReviveMgr:RemoveReviveSidebarInfo()
    if _G.SidebarMgr:GetSidebarItemVM(SidebarDefine.SidebarType.Death) ~= nil then
        _G.SidebarMgr:RemoveSidebarItem(SidebarDefine.SidebarType.Death)
    end
    if _G.SidebarMgr:GetSidebarItemVM(SidebarDefine.SidebarType.Revive) ~= nil then
        _G.SidebarMgr:RemoveSidebarItem(SidebarDefine.SidebarType.Revive)
    end
end

function ReviveMgr:OnNetworkReconnectLoginFinished()
end

function ReviveMgr:OnEventRescureInfo(Info)
    local Deadline = Info.RescueDeadline
	if Deadline == nil or Deadline <= 0 then
        if Info.RoleID and self.RescureInfo then
            self.RescureInfo[Info.RoleID] = nil
        end
		return
	end

	local function CancelUpdate()
		if self.TimerIDUpdateRescure then
			self:UnRegisterTimer(self.TimerIDUpdateRescure)
			self.TimerIDUpdateRescure = nil
		end
	end

	if Deadline > (self.RescureDeadline or 0) then
		self.RescureDeadline = Deadline
		if self.TimerIDCancelUpdateRescure then
			self:UnRegisterTimer(self.TimerIDCancelUpdateRescure)
			self.TimerIDCancelUpdateRescure = nil
		end
		local RemainTime = Deadline - _G.TimeUtil.GetServerTime()
		if RemainTime > 0 then
			self.TimerIDCancelUpdateRescure = self:RegisterTimer(function()
				CancelUpdate()
                local NewRecs = {}
                local ServerTime = _G.TimeUtil.GetServerTime()
                for k, v in pairs(self.RescureInfo or {}) do
                    if ServerTime - v.RescueDeadline < 0 then
                       NewRecs[k] = v
                    end
                end
                self.RescureInfo = NewRecs
			end, RemainTime + 1)
		else
			CancelUpdate()
		end
	end

	if Info.RoleID then
		if self.RescureInfo == nil then
			self.RescureInfo = {}
		end
		self.RescureInfo[Info.RoleID] = Info
	end
end

function ReviveMgr:OnGameEventActorRevive(Params)
    if Params then
       self:MarkReviveByEntityID(Params.ULongParam1) 
    end
end

function ReviveMgr:GetRescureInfo(RoleID)
    if RoleID and self.RescureInfo then
        return self.RescureInfo[RoleID]
    end
end

function ReviveMgr:OnReviveRespConfirm(MsgBody)
    local ConfirmData = MsgBody.Confirm
    local Type = ConfirmData.Type
    if (Type == ProtoCommon.ReviveChannelType.REVIVE_CHANNEL_DEFAULT) then
        self:OnReviveRespCommon()
    else
        if (ConfirmData.IsAccepted == false) then
            return
        end

        self:OnReviveRespCommon()
    end
end

function ReviveMgr:OnReviveRespTrans(MsgBody)
    -- 复活传送前播放特效
    local Trans = MsgBody.Trans
    local EntityID = Trans.EntityID
    local RuleID = Trans.RuleID
    local Cfg = ReviveCfg:FindCfg("ID = " .. RuleID)
    if Cfg == nil then
        FLOG_WARNING("OnReviveRespTrans Cfg is nil " .. tostring(RuleID))
        return
    end
    -- 为1时表示被技能复活 播放的特效会不同
    --print("Trans RuleID" .. RuleID .. "TransToRescuer = " .. Cfg.TransToRescuer)
    if Cfg.TransToRescuer == 1 then
        _G.SkillSingEffectMgr:PlaySingEffect(EntityID, 19997)
    else
        _G.SkillSingEffectMgr:PlaySingEffect(EntityID, 19999)
    end

    --被复活的是自己才黑屏
    if (EntityID == MajorUtil.GetMajorEntityID()) then
        local function ShowFadeView()
            self:RemoveReviveSidebarInfo()

            --解决：先发送的死亡传送复活，在这0.5s的delay内播放了ncut，导致显示异常
            if (not _G.StoryMgr:SequenceIsPlaying()) then
                local Params = {}
                Params.FadeColorType = 2
                Params.Duration = 1.5
                Params.HideMajor = true
                _G.UIViewMgr:ShowView(_G.UIViewID.CommonFadePanel, Params)
                _G.UIViewMgr:HideAllUIExceptRevive()
            end
        end

        self.IsReviving = true
        --ncut播放过程中 收到了复活协议，不做fade表现处理
        if (not _G.StoryMgr:SequenceIsPlaying()) then
            self:RegisterTimer(ShowFadeView, 0.5)
        else
            self:RemoveReviveSidebarInfo()
        end
    end
end

function ReviveMgr:OnReviveRespReady(MsgBody)
    local Ready = MsgBody.Ready
    local EntityID = Ready.EntityID
    local RuleID = Ready.RuleID
    local Cfg = ReviveCfg:FindCfg("ID = " .. RuleID)

    if Cfg == nil then
        FLOG_WARNING("OnReviveRespReady Cfg is nil " .. tostring(RuleID))
        return
    end

    -- 为1时表示被技能复活 被技能复活时不播特效
    --print("Ready RuleID" .. RuleID .. " TransToRescuer = " .. Cfg.TransToRescuer)
    if Cfg.TransToRescuer ~= 1 then
        _G.SkillSingEffectMgr:PlaySingEffect(EntityID, 19998)
    end
    AudioUtil.LoadAndPlaySoundEvent(EntityID, REVIVE_SOUND_PATH, true)
end

function ReviveMgr:OnReviveRespNotify(MsgBody)
    if MsgBody == nil then
        return
    end

    local Notify = MsgBody.Notify
    if Notify == nil then
        return
    end

    self:OnReviveRespCommon(Notify.EntityID)
end

function ReviveMgr:OnReviveRespRescue(MsgBody)
    if MsgBody == nil then
        return
    end

    local Rescue = MsgBody.Rescue
    if Rescue == nil then
        return
    end

    local RuleID = Rescue.RuleID or 0
    local EntityID = Rescue.EntityID or 0
    local RescueEntityID = Rescue.RescueEntityID or 0
    if RescueEntityID <= 0 then
        return
    end

    _G.EventMgr:SendEvent(_G.EventID.OnRescrueNotify, table.makeconst(table.clone(Rescue, true)))

    local Cfg = ReviveCfg:FindCfg("ID = " .. RuleID)
    if Cfg.IsShowReviveArrowEffect ~= 1 then
        return
    end

    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if Actor == nil then
        return
    end

    local RescueActor = ActorUtil.GetActorByEntityID(RescueEntityID)
    if RescueActor == nil then
        return
    end
    self:PlayArrowEffect(RescueEntityID, EntityID)
end

function ReviveMgr:OnGameEventSidebarItemTimeOut(Type, TransData)
    if Type ~= SidebarDefine.SidebarType.Revive then
        return
    end

    if _G.SidebarMgr:GetSidebarItemVM(SidebarDefine.SidebarType.Revive) ~= nil then
        _G.SidebarMgr:RemoveSidebarItem(SidebarDefine.SidebarType.Revive)
    end
    self:SendRevive(false)
end

function ReviveMgr:PlayArrowEffect(CasterEntityID, TargetEntityID)
    local Caster = ActorUtil.GetActorByEntityID(CasterEntityID)
    if Caster == nil then
        return
    end

    local Target = ActorUtil.GetActorByEntityID(TargetEntityID)
    if Target == nil then
        return
    end

    local VfxParameter = _G.UE.FVfxParameter()
    VfxParameter.VfxRequireData.EffectPath = REVIVE_ARROW_EFFECT_PATH
    VfxParameter.PlaySourceType = _G.UE.EVFXPlaySourceType.PlaySourceType_UBuffComponent
    VfxParameter:SetCaster(Caster, 0, _G.UE.EVFXAttachPointType.AttachPointType_Body, 0)
    VfxParameter:AddTarget(Target, 0, _G.UE.EVFXAttachPointType.AttachPointType_Body, 0)

    return EffectUtil.PlayVfx(VfxParameter)
end

function ReviveMgr:MarkReviveByEntityID(EntityID)
    self:MarkReviveByRoleID(ActorUtil.GetRoleIDByEntityID(EntityID))
end

function ReviveMgr:MarkReviveByRoleID(RoleID)
    if RoleID and self.RescureInfo then
       self.RescureInfo[RoleID] = nil 
    end
end

return ReviveMgr
