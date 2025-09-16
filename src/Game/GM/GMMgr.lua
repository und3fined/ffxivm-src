--
-- Author: jianweili
-- Date: 2020-12-23 12:00:00
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require ("Protocol/ProtoCS")
local SkillUtil = require("Utils/SkillUtil")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local CommonUtil = require("Utils/CommonUtil")
local EffectUtil = require("Utils/EffectUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local FaceAnimConfig = require("Define/FaceAnimConfig")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local LootMgr = require("Game/Loot/LootMgr")
local ProtoRes = require("Protocol/ProtoRes")
local LoginMgr = require("Game/Login/LoginMgr")
local SettingsUtils = require("Game/Settings/SettingsUtils")
local DialogueUtil = require("Utils/DialogueUtil")



local CS_CMD = ProtoCS.CS_CMD
local CS_PWORLD_CMD = ProtoCS.CS_PWORLD_CMD
local CS_DEBUG_CMD = ProtoCS.CS_DEBUG_CMD
-- local ActorMgr = _G.ActorMgr
local UIViewID = _G.UIViewID
local EventID = _G.EventID
local UIViewMgr = _G.UIViewMgr
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR
local LSTR = _G.LSTR
local SettingsTabBase = require("Game/Settings/SettingsTabBase")

---@class GMMgr : MgrBase
local GMMgr = LuaClass(MgrBase)
--是否显示调试信息
local bShowDebugTips = 0
--是否关闭选中描边
local bCloseSelectOutline = 1
local UINT64_MAX = 18446744073709551615

function GMMgr:OnInit()
    self.GMOpenState = LoginMgr:IsModuleSwitchOn(ProtoRes.module_type.MODULE_GM)
    print("CurGMState = ", self.GMOpenState)
    if self.GMOpenState then
        self:InitInfo()
    end
    self.PlayerEffWhiteListSwitch = true
    self.VisionEffWhiteListSwitch = true
end

function GMMgr:TimeGM()
    _G.CommonUtil.ConsoleCommand("timer.lt 1")
end

function GMMgr:InitInfo()
    self.CacheValue = {}
    self.CacheTime = {}
    self.TimeStamp = 0
    self.bStartTest = false
    self.GMHistoryRecord = nil
    self.GMStringList = nil
    self.GMIndex = 0
    self.ChoseFist = nil
    self.ChoseSecond = nil
    self.GMCmdList = {}

    --一些自定义枚举
    self.GMEnum = {
        [1] = LSTR("按钮"),
        [2] = LSTR("进度条"),
        [3] = LSTR("开关"),
        [4] = LSTR("客户端"),
        [5] = LSTR("通用"),
        [6] = LSTR("首页"),
        [7] = LSTR("全部"),
        [8] = LSTR("角色技能"),
        [9] = LSTR("创建"),
        [10] = LSTR("测试"),
        [11] = LSTR("天气"),
        [12] = LSTR("玩法"),
        --[[ [13] = "模型交互", ]]
        [14] = LSTR("自动化测试"),
        [15] = LSTR("控制台"),
        [16] = LSTR("面板"),
        [17] = LSTR("关卡"),
        [18] = LSTR("角色"),
        [19] = LSTR("系统"),
        [20] = LSTR("叙事"),
        [21] = LSTR("任务"),
        [22] = LSTR("特效"),
        [23] = LSTR("寻路"),
    }
end

function GMMgr:OnRegisterNetMsg()
    if not self.GMOpenState then
        return
    end
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_READY, self.OnNetMsgPWorldReady)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_GM, 0, self.OnNetMsgGM)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_DEBUG, CS_DEBUG_CMD.CS_DEBUG_CMD_AI_INFO_GET, self.OnGetTargetAIInfo)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_DEBUG, CS_DEBUG_CMD.CS_DEBUG_CMD_SKILL_INFO_GET, self.OnGetTargetCombatInfo)
end

function GMMgr:OnRegisterGameEvent()
    if not self.GMOpenState then
        return
    end
	self:RegisterGameEvent(EventID.GMShowUI, self.OnGameEventHandle)
end

function GMMgr:OnBegin()
    _G.UE.UFGameInstance.ExecCmd("U2PM|hello world")
end

function GMMgr:OnEnd()
end

function GMMgr:OnShutdown()

end

function GMMgr:OpenGMPanel()
    local IsOpen = LoginMgr:IsModuleSwitchOn(ProtoRes.module_type.MODULE_GM)
    print("OpenGMPanel IsOpen = ", IsOpen)
    if IsOpen then
        _G.UIViewMgr:ShowView(UIViewID.GMPanel)
    end
end

function GMMgr:OnGameEventHandle(Params)
    if UIViewMgr:IsViewVisible(UIViewID.MainPanel) then
        if UIViewMgr:IsViewVisible(UIViewID.GMMain) then
            UIViewMgr:HideView(UIViewID.GMMain)
        else
            UIViewMgr:ShowView(UIViewID.GMMain)
        end
    end
end

function GMMgr:OnNetMsgGM(MsgBody)
    -- _G.UE.UKismetSystemLibrary.PrintString(self, tostring(MsgBody.Result), true, false, _G.UE.FLinearColor(1,1,1,1),5)

    if nil ~= MsgBody then
        if "AutoFight_Cloth" == MsgBody.Result then
            self:ReqGM("role equip on 50000006")

        elseif "AutoFight_Fight" == MsgBody.Result then
            -- 加血量上限, 加血, 无敌, 免疫
            self:ReqGM0("cell attr set 7 1000000000 || cell attr set 51 1000000000 || cell combatstat set 7 || cell combatstat set 8")
            -- PC端屏蔽特效
            if CommonUtil.GetPlatformName() == "Windows" then
                
            end
            self:StartAutoFight()
        elseif "group" == MsgBody.Cmd then
            _G.ArmyMgr:SendGetArmyInfoMsg()
        end

        _G.AutoTest.OnReceiveGM(MsgBody)
    end

    _G.EventMgr:SendEvent(EventID.GMReceiveRes, MsgBody)
end

local function ParseMetaData(cmd)
    -- 服务器web端发送纯客户端指令时，在web端回显信息
    local SubCmd = string.gsub(cmd, "MetaData={.-} ", "")
    local MetaDataStr = string.match(cmd, "MetaData={.-}")
    local MetaData = {}
    if nil ~= MetaDataStr then
        MetaDataStr = string.sub(MetaDataStr, 11, -2)
        local MetaDataList = string.split(MetaDataStr, " ")
        for i = 1, #(MetaDataList) do
            local MetaDataPair = string.split(MetaDataList[i], "=")
            MetaData[MetaDataPair[1]] = string.sub(MetaDataPair[2], 2, -2)
        end
    end
    return SubCmd, MetaData
end

function GMMgr:ReqGM(cmd, ConfigParams)
    local SubCmd, MetaData = ParseMetaData(cmd)
    SubCmd = SubCmd:gsub("\u{00A0}", " ")
    local splitList = string.split(SubCmd, " ")
    local firstTag = splitList[1]
    local secondTag = splitList[2]
    local thirdTag = {}

    for i = 3, #(splitList) do
        table.insert(thirdTag, tostring(splitList[i]))
    end

    if firstTag == nil or secondTag == nil then
        FLOG_WARNING("GM format illegal, too short, two words at least")
        return
    end

    if firstTag == "client" then
        --客户端本地GM以client开头，其它的认为是服务器GM
        self:DoClientInput(cmd)
        return
    elseif firstTag == "lua" then
        --Lua脚本
        local LuaScript = secondTag
        if ConfigParams ~= nil then
            LuaScript = string.format(LuaScript, self:GetCacheValue(ConfigParams.ID))
        end
        local LuaFunc = _G.load(LuaScript)
        if LuaFunc then
            LuaFunc()
        else
            FLOG_ERROR("[GMMgr]Lua error, please check lua script")
        end
    else
        local MsgID = CS_CMD.CS_CMD_GM
        local SubMsgID = 0
        local MsgBody = {}
        MsgBody.Svr = tostring(firstTag)
        MsgBody.Cmd = tostring(secondTag)
        MsgBody.Request = thirdTag
        if nil ~= _G.next(MetaData) then MsgBody.MetaData = MetaData end
        _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
        FLOG_WARNING(string.format("------------GM Request: %s-------------", cmd))
    end
end

-- 处理需要延时发送的指令
function GMMgr:ReqGM0(CmdList)
    if string.find(CmdList, "||") ~= nil then
        CmdList = string.split(CmdList, "||")
        local delayTime = 0.0
        local step = 1.0
        for i = 1, #(CmdList) do
            local CmdContent = CmdList[i]
            local DelayCallBack = function()
                self:ReqGM1(CmdContent)
            end
            if(delayTime ~= 0) then
                _G.TimerMgr:AddTimer(self, DelayCallBack, delayTime, 1.0, 1, nil)
            else
                self:ReqGM1(CmdContent)
            end
            delayTime = delayTime + step
        end
    else
        self:ReqGM1(CmdList)
    end
end

-- 处理指令列表
function GMMgr:ReqGM1(CmdList)
    if string.find(CmdList, "|") ~= nil then
        CmdList = string.split(CmdList, "|")
        for i = 1, #(CmdList) do
            self:ReqGM(CmdList[i])
        end
    else
        self:ReqGM(CmdList)
    end
end

function GMMgr:ReqServerGM(cmd)

end

function GMMgr:SwitchShowDebugTips()
    if (bShowDebugTips == 1) then
        bShowDebugTips = 0
    else
        bShowDebugTips = 1
    end
end

function GMMgr:SwitchShowSelectOutline()
    if (bCloseSelectOutline == 1) then
        bCloseSelectOutline = 0
        SettingsTabBase:SetShowSelectOutline(2, true)
    else
        bCloseSelectOutline = 1
        SettingsTabBase:SetShowSelectOutline(1, false)
    end
end

function GMMgr:IsShowDebugTips()
    return bShowDebugTips == 1
end

function GMMgr:IsShowSelectOutline()
    return _G.SettingsMgr:GetValueBySaveKey("ShowSelectOutline") == 1
end

function GMMgr:DoClientInput(cmd)
    local splitList = string.split(cmd, " ")
    local Name = splitList[2]
    local Param1 = splitList[3]
    local Param2 = splitList[4]
    local Param3 = splitList[5]
    local Param4 = splitList[6]
    local Param5 = splitList[7]
    local Param6 = splitList[8]
    local Param7 = splitList[9]

    local RotateActorInRPMTimerId
    local RotateCameraInRPMTimerId

    -- client ue xxx 执行ue的gm命令xxx
    if ("ue" == splitList[2]) then
        local _, end_pos= string.find(cmd, "ue")
        CommonUtil.ConsoleCommand(string.sub(cmd, end_pos + 1))
    elseif "SetRTPCValue" == splitList[2] then
        local UAudioMgr = _G.UE.UAudioMgr.Get()
        local RTPCName = tostring(splitList[3])
        local RTPCValue = tonumber(splitList[4])
        if nil ~= RTPCName and nil ~= RTPCValue then
            UAudioMgr.SetRTPCValue(RTPCName, RTPCValue, 10)
        end
    elseif "navi" == splitList[2] then
        -- _G.NaviDecalMgr:NaviPathToNpc(29000015)
        _G.NaviDecalMgr:NaviPathToPos(_G.UE.FVector(33406, 40618, 3896), _G.NaviDecalMgr.EGuideType.Task
            , _G.NaviDecalMgr.EForceType.OnceForce)
    elseif "navimap" == splitList[2] then
        _G.NaviDecalMgr:SetNaviType(_G.NaviDecalMgr.EGuideType.BigMap)
        _G.NaviDecalMgr:NaviPathToPos(_G.UE.FVector(33406, 40618, 3896), _G.NaviDecalMgr.EGuideType.BigMap)
            -- , _G.NaviDecalMgr.EForceType.OnceForce)
    elseif "navimapover" == splitList[2] then
        _G.NaviDecalMgr:CancelNaviType(_G.NaviDecalMgr.EGuideType.BigMap)
    elseif "opennavi" == splitList[2] then
        local Tab = SettingsUtils.GetSettingTabs("SettingsTabUnCategory")
        if Tab then
            Tab:SetNavigationState(1)
        end
    elseif "closenavi" == splitList[2] then
        local Tab = SettingsUtils.GetSettingTabs("SettingsTabUnCategory")
        if Tab then
            Tab:SetNavigationState(2)
        end
    elseif "statetip" == splitList[2] then
        local Params = { EventType = 1 }
        _G.CrafterMgr:ShowStateTips(Params)
        local function DelayTip()
            Params = { EventType = 103, Title = "sdf" }
            _G.CrafterMgr:ShowStateTips(Params, true)
        end
        DelayTip()
        -- _G.TimerMgr:AddTimer(nil, DelayTip, 1, 1, 1)
    elseif "setting" == splitList[2] then
        local bOpen = tonumber(Param2) == 1 or false
        if tonumber(Param1) then
            _G.SettingsMgr:ShowByID(tonumber(Param1), true)
        else
            _G.SettingsMgr:ShowBySaveKey(Param1, true)
        end
    elseif "SetFXPoolSize" == Name then
        local PoolSize = tonumber(Param1) or -1
        if PoolSize < 0 then return end
        EffectUtil.SetWorldEffectMaxCount(_G.math.floor(PoolSize))
        return
    elseif "sysnotice" == Name then
        if nil == Param1 then return end
        _G.MsgTipsUtil.ShowTipsByID(tonumber(Param1))
    elseif "showview" == Name then
        if nil == Param1 then return end
        _G.UIViewMgr:ShowView(tonumber(Param1))
    elseif "SetFXGScale" == splitList[2] then
        local FXGScale = tonumber(splitList[3]) or -1
        if FXGScale < 0 then return end
        --此接口已废弃
        --_G.UE.UFXMgr:Get():SetFXGScale(FXGScale)
    elseif "createtest" == splitList[2] then
        local Count = tonumber(splitList[3]) or 1
        local SpecialMaterialTest = require("Game/Test/SpecialMaterialTest")
        SpecialMaterialTest.CreateTestCharacter(Count)
    elseif "switch" == splitList[2] and tonumber(splitList[4]) ~= nil then
        local Name = splitList[3] or " "
        local Charc = splitList[4] or "1"
        local SpecialMaterialTest = require("Game/Test/SpecialMaterialTest")
        SpecialMaterialTest.SwitchMaterial(Name, tonumber(Charc))
    elseif "PlayDialogueSequence" == Name then
        local SequenceID = Param1 and Param1 or nil
        if (SequenceID ~= nil) then
            local function SequenceFinishedCallback(_)
                print("GM: OnSequenceFinished")
            end

            local StoryMgr = _G.StoryMgr
            StoryMgr.CameraResetSpeed = tonumber(splitList[4] or "5")
            if tonumber(SequenceID) ~= nil then
                StoryMgr.bGMLoadSubLevel = true
                StoryMgr:PlayDialogueSequence(tonumber(SequenceID), SequenceFinishedCallback)
                _G.UIViewMgr:HideView(_G.UIViewID.GMMain)
            end
        end
    elseif "PlayChangeMapSequence" == Name then
        _G.PWorldMgr:PlayChangeMapSequence()
    elseif "PlayStaffRoll" == Name then
        local VersionID = Param1 and Param1 or nil
        if (VersionID ~= nil) then
            local SequencePath = string.format("LevelSequence'/Game/EditorRes/StaffRoll/StaffRoll_%s.StaffRoll_%s'",VersionID,VersionID)
            if SequencePath ~= nil then
                local function SequenceFinishedCallback(_)
                    print("GM: Play Sequence Path Finished")
                end
                _G.StoryMgr:PlayStaffRollSequence(SequencePath, SequenceFinishedCallback)
                _G.UIViewMgr:HideView(_G.UIViewID.GMMain)
            end
        end
    elseif "seqp" == Name then
        local SequencePath = Param1 and Param1 or nil
        local TimeInFrameStr = Param2 and Param2 or nil
        if SequencePath ~= nil then
            local function SequenceFinishedCallback(_)
                print("GM: Play Sequence Path Finished")
            end
            local Major = MajorUtil.GetMajor()
            Major:GetStateComponent():SetHoldWeaponState(false)
            Major:GetStateComponent():ClearTempHoldWeapon(_G.UE.ETempHoldMask.ALL, true)
            local OtherParams = {}
            OtherParams.bLoadSubLevel = true

            if (TimeInFrameStr) then
                OtherParams.StartFrameNumber = tonumber(TimeInFrameStr)
            end
            
            _G.StoryMgr:PlaySequenceByPath(SequencePath, SequenceFinishedCallback, nil, nil, nil, OtherParams)
            
            _G.UIViewMgr:HideView(_G.UIViewID.GMMain)
        end
        

    elseif "HideAvatarWeapon" == Name then
        local ActorResID = Param1 and Param1 or nil
        local Actor = ActorUtil.GetActorByResID(ActorResID)
        if (Actor) then
            local AvatarComponent = Actor:GetAvatarComponent()
            if (AvatarComponent) then
                AvatarComponent:SetAvatarHiddenInGame(_G.UE.EAvatarPartType.WEAPON_MASTER_HAND, true, false, false)
                AvatarComponent:SetAvatarHiddenInGame(_G.UE.EAvatarPartType.WEAPON_SLAVE_HAND, true, false, false)
                AvatarComponent:SetAvatarHiddenInGame(_G.UE.EAvatarPartType.WEAPON_SYSTEM, true, false, false)
            end
        end

    elseif "behaviorset" == Name then
        local SelectedTarget = _G.SelectTargetMgr:GetCurrSelectedTarget()
        if not SelectedTarget then
            return
        end
        local BehaviorID = tonumber(Param1)
        local ThinkComponent = SelectedTarget:GetThinkComponent()
        if ThinkComponent and BehaviorID > 0 then
            ThinkComponent:TestExecBehavior(BehaviorID)
        end

    elseif "behaviorlogopen" == Name then
        local SelectedTarget = _G.SelectTargetMgr:GetCurrSelectedTarget()
        if not SelectedTarget then
            local BehaviorID = tonumber(Param1)
            if BehaviorID ~= 0 then
                _G.UE.UPWorldMgr:Get():ExecOpenBehaviorLog(BehaviorID)
            end

            return
        end

        local ThinkComponent = SelectedTarget:GetThinkComponent()
        if ThinkComponent then
            ThinkComponent:TestExecPrintLog()
        end

    elseif "powersave" == Name then
        local EnterTime = tonumber(Param1 or 20)
        _G.PowerSavingMgr:SetEnable(EnterTime)

    elseif "sharedgroup" == Name then
        local InstanceID = Param1 and Param1 or nil
        local ModelState = Param2 and Param2 or nil
        _G.PWorldMgr:PlaySharedGroupTimeline(InstanceID, ModelState)

        local BossTransData = {}
        BossTransData.EndTime = _G.TimeUtil.GetServerTime() + 10
        BossTransData.RegionID = 0
        _G.PWorldMgr:OnBossAreaTrans(BossTransData)

    elseif "switchstyle" == Name then
        local StyleName = Param1 and Param1 or nil
        local NPCTalkMainPanel = UIViewMgr:FindView(UIViewID.NpcTalkMainPanel)
        if NPCTalkMainPanel then
            NPCTalkMainPanel:SwitchStyle(StyleName)
        end
    elseif "setModelState" == Name then
        local ResID = Param1 and Param1 or nil
        local ModelState = Param2 and Param2 or nil
        local Actor = ActorUtil.GetActorByResID(ResID)
        if Actor ~= nil then
            Actor:SetModelState(ModelState)
        end
    elseif Name == "changeweather" then
        local AreaID = Param1 and Param1 or nil
        if AreaID then
            local World = FWORLD()
            _G.UE.UTodUtils.ChangeWeather(World, tostring(AreaID))
        end
    elseif Name == "setweatherandlocktime" then
        local Time = Param1 and Param1 or 0
        local LockTime = Param2 and Param2 or true
        _G.UE.UEnvMgr:Get():SetDesireAsyoTime(Time * 3600,LockTime)
    elseif Name == "showroadgraph" then
        local ShowTime = Param1 and Param1 or 100
        local ShouldShowNodeName = Param1 and Param1 or false
        _G.UE.UPWorldMgr:Get():ShowCurLevelRoadGraph(ShowTime, ShouldShowNodeName)

    elseif Name == "showSphere" then        
        local FVectorPos = _G.UE.FVector(tonumber(Param1 or 0), tonumber(Param2 or 0), tonumber(Param3 or 0))
        local ShowTime = Param4 and Param4 or 120
        _G.UE.UPWorldMgr:Get():ShowSphere(FVectorPos, 40, ShowTime) 
    elseif Name == "roadtest" then
        local DstMapID = tonumber(Param1 or 0)
        local DstPos = _G.UE.FVector(tonumber(Param2 or 0), tonumber(Param3 or 0), tonumber(Param4 or 0))

        _G.NavigationPathMgr:GMTestRoadGraph(DstMapID, DstPos)

    elseif Name == "autopathmove" then
        local DstMapID = tonumber(Param1 or 0)
        local DstPos = _G.UE.FVector(tonumber(Param2 or 0), tonumber(Param3 or 0), tonumber(Param4 or 0))

        _G.AutoPathMoveMgr:GMTestAutoPathMove(DstMapID, DstPos)
        --elseif Name == "transedge" then
        --    _G.PWorldMgr:SendTrans(ProtoCS.PWORLD_TRANS_TYPE.PWORLD_TRANS_TYPE_EXIT_RANGE, 2377056)
    elseif "PlayEmotion" == Name then
        local ID = tonumber(Param1)
        EmotionMgr:SendEmotionReq(ID)
    elseif "PlayFace" == Name then
        local ID = tonumber(Param1)
        local Major = MajorUtil.GetMajor()
        local AnimComp = Major:GetAnimationComponent()
        if AnimComp then
            AnimComp:PlayFaceAnimSequence(FaceAnimConfig[ID])
        end
    elseif "PlayRoleAnim" == Name then
        if nil ~= Param1 then
            local Major = MajorUtil.GetMajor()
            local AnimComp = Major:GetAnimationComponent()
            if AnimComp then
                AnimComp:PlayAnimation(Param1);
            end
        end
    elseif "PlayRoleAnimLooping" == Name then
        if nil ~= Param1 then
            local Major = MajorUtil.GetMajor()
            local AnimComp = Major:GetAnimationComponent()
            if AnimComp then
                AnimationQueueID = AnimComp:PlayActionTimelineMultiLooping(Param1)
            end
        end
    elseif "StopPlayRoleAnimLooping" == Name then
        local Major = MajorUtil.GetMajor()
        local AnimComp = Major:GetAnimationComponent()
        if AnimComp then
            AnimComp:StopActionTimelineMulti(AnimationQueueID);
        end
    elseif "PlayRoleTPose" == Name then
        local Major = MajorUtil.GetMajor()
        local AnimComp = Major:GetAnimationComponent()
        if AnimComp then
            AnimationQueueID = AnimComp:PlayActionTimelineMultiLooping("TPose/CharacterTPose")
            local EmojiAnimInst = Major:GetEmojiAnimInst()
            if EmojiAnimInst and EmojiAnimInst.SetNeedToPauseEye ~= nil then
                EmojiAnimInst:SetNeedToPauseEye(true)
            end
        end
    elseif "StopPlayRoleTPose" == Name then
        local Major = MajorUtil.GetMajor()
        local AnimComp = Major:GetAnimationComponent()
        if AnimComp then
            AnimComp:StopActionTimelineMulti(AnimationQueueID);
            local EmojiAnimInst = Major:GetEmojiAnimInst()
            if EmojiAnimInst and EmojiAnimInst.SetNeedToPauseEye ~= nil then
                EmojiAnimInst:SetNeedToPauseEye(false)
            end
        end
    elseif "RotateActorInRPM" == Name then
        _G.FLOG_INFO("GMMGR:RotateActorInRPM")
        local DeltaTime = 0.03
        local IsAlreadyPrintCallBackLog = false
        _G.FLOG_INFO(cmd)
        _G.FLOG_INFO(debug.traceback())
        local DelayCallBack = function()
            if nil ~= Param1 then
                local Major = MajorUtil.GetMajor()
                if Major == nil then
                    FLOG_ERROR("GMMGR:RotateActorInRPM  Major == nil")
                    return
                end
                local AnimComp = Major:GetAnimationComponent()
                if AnimComp then
                    ActorRotation = Major:FGetActorRotation()
                    AnimComp:ForceSetRotation(_G.UE.FRotator(0, ActorRotation.Yaw + tonumber(Param1) * DeltaTime, 0), 0);
                    if IsAlreadyPrintCallBackLog == false then
                        _G.FLOG_INFO("GMMGR:RotateActorInRPMDelayCallBack")
                        IsAlreadyPrintCallBackLog = true
                    end
                end
            end
        end
        _G.TimerMgr:CancelTimer(self.RotateActorInRPMTimerId)
        self.RotateActorInRPMTimerId = _G.TimerMgr:AddTimer(self, DelayCallBack, 0, DeltaTime, 0)
    elseif "StopActorRotate" == Name then
        _G.TimerMgr:CancelTimer(self.RotateActorInRPMTimerId)
    elseif "ResetActorRotation" == Name then
        local Major = MajorUtil.GetMajor()
        local AnimComp = Major:GetAnimationComponent()
        if AnimComp then
            ActorRotation = Major:FGetActorRotation()
            AnimComp:ForceSetRotation(_G.UE.FRotator(0, 0, 0), 0);
        end
    elseif "RotateCameraInRPM" == Name then
        _G.FLOG_INFO("GMMGR:RotateCameraInRPM")
        local DeltaTime = 0.03
        local IsAlreadyPrintCallBackLog = false
        _G.FLOG_INFO(cmd)
        _G.FLOG_INFO(debug.traceback())
        local DelayCallBack = function()
            if nil ~= Param1 then
                local Major = MajorUtil.GetMajor()
                if Major == nil then
                    FLOG_ERROR("GMMGR:RotateCameraInRPM  Major == nil")
                    return
                end
                local CameraComp = Major:GetCameraControllComponent()
                if CameraComp then
                    local CameraRotation = CameraComp:GetCameraBoomRelativeRotation()
                    CameraComp:SetCameraBoomRelativeRotation(_G.UE.FRotator(CameraRotation.Pitch, CameraRotation.Yaw + tonumber(Param1) * DeltaTime, CameraRotation.Roll));
                    if IsAlreadyPrintCallBackLog == false then
                        _G.FLOG_INFO("GMMGR:RotateCameraInRPMDelayCallBack")
                        IsAlreadyPrintCallBackLog = true
                    end
                end
            end
        end
        _G.TimerMgr:CancelTimer(self.RotateCameraInRPMTimerId)
        self.RotateCameraInRPMTimerId = _G.TimerMgr:AddTimer(self, DelayCallBack, 0, DeltaTime, 0)
    elseif "StopCameraRotate" == Name then
        _G.TimerMgr:CancelTimer(self.RotateCameraInRPMTimerId)
    elseif "ResetCameraRotation" == Name then
        local Major = MajorUtil.GetMajor()
        local CameraComp = Major:GetCameraControllComponent()
        if CameraComp then
            local CameraRotation = CameraComp:GetCameraBoomRelativeRotation()
            CameraComp:SetCameraBoomRelativeRotation(_G.UE.FRotator(CameraRotation.Pitch, 0, CameraRotation.Roll));
        end
    elseif "SetTouchWaitTime" == Name then
        _G.NpcDialogMgr:SetTouchWaitTime(tonumber(Param1), tonumber(Param2))
        local SequencePlayerVM = require("Game/Story/SequencePlayerVM")
        SequencePlayerVM:GMSetTouchWaitTimeMS(tonumber(Param1))
    elseif "PlayTPoseDelayRotate" == Name then
        _G.FLOG_INFO("GMMGR:PlayTPoseDelayRotate")
        local Major = MajorUtil.GetMajor()
        local AnimComp = Major:GetAnimationComponent()
        if AnimComp then
            AnimationQueueID = AnimComp:PlayActionTimelineMultiLooping("TPose/CharacterTPose")
            local EmojiAnimInst = Major:GetEmojiAnimInst()
            if EmojiAnimInst and EmojiAnimInst.SetNeedToPauseEye ~= nil then
                EmojiAnimInst:SetNeedToPauseEye(true)
            end
        end
        local DeltaTime = 0.03
        local IsAlreadyPrintCallBackLog = false
        local DelayTime = tonumber(Param1) or 0
        local TimeTurnOneCycle = tonumber(Param2) or 1
        local RPM = 360 / TimeTurnOneCycle
        local DelayCallBack = function()
            local Major = MajorUtil.GetMajor()
            local AnimComp = Major:GetAnimationComponent()
            if AnimComp then
                ActorRotation = Major:FGetActorRotation()
                AnimComp:ForceSetRotation(_G.UE.FRotator(0, ActorRotation.Yaw + RPM * DeltaTime, 0), 0);
                if IsAlreadyPrintCallBackLog == false then
                    _G.FLOG_INFO("GMMGR:PlayTPoseDelayRotateDelayCallBack")
                    IsAlreadyPrintCallBackLog = true
                end
            end
        end
        _G.TimerMgr:CancelTimer(self.RotateActorInRPMTimerId)
        self.RotateActorInRPMTimerId = _G.TimerMgr:AddTimer(self, DelayCallBack, DelayTime, DeltaTime, _G.UE.UKismetMathLibrary.Abs(TimeTurnOneCycle/DeltaTime))
    elseif "PlayYell" == Name then
        _G.SpeechBubbleMgr:ShowBubbleTest(Param1)
    elseif "PlayBalloon" == Name then
        _G.SpeechBubbleMgr:ShowBalloonTest(Param1)
    elseif "SetClientConfig" == Name then
        local MajorRoleID = MajorUtil.GetMajorRoleID()
        local Key = tonumber(splitList[3])
        local Value = splitList[4]

        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.ULongParam1 = MajorRoleID
        EventParams.IntParam1 = Key
        EventParams.StringParam1 = Value
        EventMgr:SendEvent(EventID.ClientSetupSet, EventParams)
        EventMgr:SendCppEvent(EventID.ClientSetupSet, EventParams)
    elseif "ResetRotation" == Name then
        local Major = MajorUtil.GetMajor()
        local Time = tonumber(Param1)
        local AnimComp = Major:GetAnimationComponent()
        if AnimComp then
            AnimComp:ForceSetRotation(_G.UE.FRotator(0, 0, 0), Time)
        end
    elseif "switch" == splitList[2] and "character" == splitList[3] then
        local CharacterName = splitList[4] or " "
        require("Game/Test/SpecialMaterialTest").SwitchCharacter(CharacterName)
    elseif "fixedlod" == Name then
        local LODLevel = tonumber(Param1) or -1
        -- _G.UE.UFXPoolMgr:Get():SetFixedLOD(tonumber(LODLevel))

    elseif "weather" == Name then
        local Minutes = splitList[5] or "0"
        Minutes = tonumber(Minutes)
        Minutes = math.floor(Minutes)
        _G.EventMgr:SendEvent(_G.EventID.GMChangeWeatherTime)

    elseif "Camera" == Name then
        local Major = MajorUtil.GetMajor()
        local CamCtrComp = Major:GetCameraControllComponent()
        local CamOption = splitList[3]
        if "Offset" == CamOption then
            local Coord = splitList[4]
            local CoordOffset = splitList[5] or "0"
            CoordOffset = math.floor(tonumber(CoordOffset))
            local TargetOffset = CamCtrComp:GetRotatableOffset()
            if "X" == Coord then TargetOffset.X = CoordOffset
            elseif "Y" == Coord then TargetOffset.Y = CoordOffset
            elseif "Z" == Coord then TargetOffset.Z = CoordOffset
            end
            CamCtrComp:EnableOffsetYawRotate(TargetOffset, true)
        elseif "Reset" == CamOption then
            CamCtrComp:CancelCameraLookAtWithOffset()
        end
    elseif "fade" == Name then
        local Actor = MajorUtil.GetMajor()
        if Param2 ~= nil then
            local EntityID = tonumber(Param2)
            Actor = ActorUtil.GetActorByEntityID(EntityID) or Actor
        end
        if "in" == Param1 then
            Actor:SetActorHiddenInGame(false)
            Actor:StartFadeIn(1.0, true)
        elseif "out" == Param1 then
            Actor:StartFadeOut(1, 0)
        end
    elseif "stainsection" == Name then
        local PosKey = tonumber(Param1)
        local SectionID = tonumber(Param2)
        local ColorID = tonumber(Param3)

        local AvatarCom = MajorUtil.GetMajorAvatarComponent()
        if AvatarCom then
            local Assembler = AvatarCom:GetAssembler()
            if Assembler then
                Assembler:StainPartForSection(PosKey, SectionID, ColorID)
            end
        end
    elseif "stainsectionshow" == Name then
        local PosKey = tonumber(Param1)
        local ColorID = tonumber(Param2)
        
        local AvatarCom = MajorUtil.GetMajorAvatarComponent()
        if AvatarCom then
            local Assembler = AvatarCom:GetAssembler()
            if Assembler then
                local AttachType = Assembler:GetAttachType()
                local ModelPath = Assembler:GetModelPath(PosKey)
                local SubModelPath = Assembler:GetSubModelPath(PosKey)
                local ImagechangeID = Assembler:GetImagechangeID(PosKey)

                local Mask = _G.UE.FStainMaterialIndex.GetMask(PosKey, AttachType, ModelPath, SubModelPath, ImagechangeID)
                -- 这里只示范MaskA，部分模型还有B\C\D的材质
                local BitUtil = require("Utils/BitUtil")
                local BitCount = BitUtil.BitCount(Mask.MaskA)
                local CurIndex = 0
                _G.TimerMgr:AddTimer(nil, function()
                    while CurIndex < 16 and ((1 << CurIndex) & Mask.MaskA) == 0 do
                        CurIndex = CurIndex + 1
                    end
                    Assembler:StainPartForSection(PosKey, CurIndex, ColorID)
                    CurIndex = CurIndex + 1
                    print(string.format("stainsectionshow Cur:%d BitCount:%d", CurIndex, BitCount))
                end, 0, 1, BitCount)
            end
        end
    elseif "indexcheck" == Name then
        local PosKey = tonumber(Param1)
        local Index = tonumber(Param2)
        local AvatarCom = MajorUtil.GetMajorAvatarComponent()
        local Assembler = AvatarCom:GetAssembler()
        if Assembler then
            AvatarCom:SetIndexCheck(PosKey, true)
            Assembler:SetMaterialScalar(PosKey, "currentindexid1", Index)
        end
    elseif "sing" == Name then
        local SingFinshCallback = function (IsBreak)
            if not IsBreak then
                print("SingFinshCallback over")
            else
                print("SingFinshCallback Is Break")
            end
        end
        local SingID = tonumber(Param1) or 200
        _G.SingBarMgr:MajorSingBySingStateIDWithoutInteractiveID(SingID, SingFinshCallback)
        _G.UIViewMgr:HideView(_G.UIViewID.GMMain)

    elseif "ver" == splitList[2] then
        _G.ClientVisionMgr:CheckVersionByGlobalVersion(Param1)
    elseif "crafter" == Name then
        local RecipeID = tonumber(Param1) or 2
        local MakeType = tonumber(Param2) or 2
        local IsForce = tonumber(Param3) or false
        if MakeType == 2 then
            _G.CrafterMgr:StartMake(RecipeID, false, 1, IsForce)
        elseif MakeType == 3 then
            _G.CrafterMgr:StartMake(RecipeID, true, 1, IsForce)
        elseif MakeType == 4 then
            --_G.CrafterMgr:StartFastMake(RecipeID)
        end
        _G.UIViewMgr:HideView(_G.UIViewID.GMMain)
    elseif "settingrpt" == Name then
        local DataReportUtil = require("Utils/DataReportUtil")
        DataReportUtil.ReportSettingData("test")
    elseif "logout" == Name then
        _G.LoginMgr:RoleLogOut()
    elseif "getcrafter" == Name then
        local info = "\n反应强度：" .. _G.CrafterMgr:GetFeatureValue(5)   --反应强度
        self.GMHistoryRecord = self.GMHistoryRecord .. info
        local GMMainView = _G.UIViewMgr:ShowView(_G.UIViewID.GMMain)
        GMMainView.GMMain_UIBP:UpdateGMHistory()
    elseif "OpenSpeedConst" == Name then
        if tonumber(Param1) == 0 then
            _G.UE.AMajorController:CloseSpeedConst()
        else
            _G.UE.AMajorController:OpenSpeedConst()
        end
    elseif "ToggleWind" == Name then
        local EnvMgr = _G.UE.UEnvMgr:Get()
        if EnvMgr then
            EnvMgr:ToggleWindGM()
        end
    elseif "nearestgather" == Name then
        _G.GatherMgr:GMFindNearestGather()
    elseif "getallgather" == Name then
        _G.GatherMgr:GetAllGatherPoints()
    elseif "gather" == Name then
        self:ReqGM0("cell attr set 61 1000 || role lifeskill addgp 1000 || cell attr set 64 1000 || role attr rev 63 0 1000")
    elseif "SetZoomSpeed" == Name then
        local Major = MajorUtil.GetMajor()
        local CamCtrComp = Major:GetCameraControllComponent()
        CamCtrComp:SetZoomSpeed(tonumber(Param1))
    elseif "SetInterpSpeed" == Name then
        local Major = MajorUtil.GetMajor()
        local CamCtrComp = Major:GetCameraControllComponent()
        CamCtrComp:SetZoomInterpolation_InterpSpeed(tonumber(Param1))
    elseif "SetInterpSpeedToInterpolation" == Name then
        local Major = MajorUtil.GetMajor()
        local CamCtrComp = Major:GetCameraControllComponent()
        CamCtrComp:SetZoomInterpolation_InterpSpeedToInterpolation(tonumber(Param1))
    elseif "SetResetInterpSpeedTolerance" == Name then
        local Major = MajorUtil.GetMajor()
        local CamCtrComp = Major:GetCameraControllComponent()
        CamCtrComp:SetZoomInterpolation_ResetInterpSpeedTolerance(tonumber(Param1))
    elseif "PrintAnimsPath" == Name then
        local Table = ActorUtil.GetMonsterAnimations(tonumber(Param1))
        for _, Value in pairs(Table) do
            FLOG_ERROR(Value)
        end
    elseif "TestTimer" == Name then
        local InRate = tonumber(Param1)
        local bLoop = tonumber(splitList[4])
        local FirstDelay = tonumber(splitList[5])
        _G.UE.UActorManager:Get():TestClearTime(InRate, bLoop == 1, FirstDelay)
    elseif "SwitchCVM" == Name then
        local bSwitch = tonumber(Param1)
        local Major = MajorUtil.GetMajor()
        local CamCtrComp = Major:GetCameraControllComponent()
        CamCtrComp.bCVMOpen = bSwitch
    elseif "skillblock" == Name then
        local IsOpen = tonumber(Param1)
        if IsOpen == 1 then
            ActorUtil.SkillBlockEnable = true
        else
            ActorUtil.SkillBlockEnable = false
        end
    elseif "summon" == Name then
        local ListID = tonumber(Param1)
        local SummonID = tonumber(Param2)
        local Major = MajorUtil.GetMajor()
        local Location = Major:FGetActorLocation()
        local Rotation = Major:FGetActorRotation()
        _G.UE.UActorManager:Get():CreateClientActor(_G.UE.EActorType.Summon, ListID, SummonID, Location, Rotation)
    elseif "avatarchg" == Name then
        local Major = MajorUtil.GetMajor()
        local AvatarComp = Major:GetAvatarComponent()
        if AvatarComp then
            local ModelName = splitList[3]
            local PosID = tonumber(splitList[4])
            local ImagechangeID = tonumber(splitList[5]) or 0
            local ColorID = tonumber(splitList[6]) or 0

            AvatarComp:ClientGMChangeAvatar(ModelName, PosID, ImagechangeID, ColorID)
        end
    elseif "tsp" == Name then
        local Major = MajorUtil.GetMajor()
        local AvatarComp = Major:GetAvatarComponent()
        if AvatarComp then
            local PosKey = tonumber(splitList[3])
            local Priority = tonumber(splitList[4])

            AvatarComp:SetPartTranslucencySortPriority(PosKey, Priority)
        end
    elseif "SetRide" == Name then
        local Actor = nil
        local SelectedTarget = _G.SelectTargetMgr:GetCurrSelectedTarget()
        if SelectedTarget then
            Actor = SelectedTarget
        else
            Actor = MajorUtil.GetMajor()
        end
        local ResID = tonumber(Param1)
        local RideComp = Actor:GetRideComponent()
        if RideComp then
            if ResID == 0 then
                RideComp:UnUseRide()
            else
                RideComp:UseRide(ResID)
            end
        end
    elseif "SetOtherRide" == Name then
        local Major = MajorUtil.GetMajor()
        local RideComp = Major:GetRideComponent()
        local SelectedTarget = _G.SelectTargetMgr:GetCurrSelectedTarget()
        if RideComp and SelectedTarget then
            _G.MountMgr:SendMountApplyOn(SelectedTarget:GetAttributeComponent().RoleID)
            --RideComp:RideToOther(SelectedTarget:GetAttributeComponent().EntityID, tonumber(Param1))
        end
    elseif "SetRideSpeed" == Name then
        local Major = MajorUtil.GetMajor()
        if Major then
            local RideComp = Major:GetRideComponent()
            if RideComp then
                local InGroundRunSpeed = tonumber(splitList[3])
                local InGroundWalkSpeed = tonumber(splitList[4])
                local InFlyingRunSpeed = tonumber(splitList[5])
                local InFlyingWalkSpeed = tonumber(splitList[6])
                RideComp:SetRideSpeed(InGroundRunSpeed, InGroundWalkSpeed, InFlyingRunSpeed, InFlyingWalkSpeed)
            end
        end
    elseif "InviteOtherRide" == Name then
        local Major = MajorUtil.GetMajor()
        local RideComp = Major:GetRideComponent()
        local SelectedTarget = _G.SelectTargetMgr:GetCurrSelectedTarget()
        if RideComp and SelectedTarget then
            _G.MountMgr:SendMountApplyOn(SelectedTarget:GetAttributeComponent().RoleID)
            --RideComp:RideToOther(SelectedTarget:GetAttributeComponent().EntityID, tonumber(Param1))
        end
    elseif "TestInvite" == Name then
        _G.MountMgr:TestApplyNotify()
    elseif Name == "profile" then
        print('create AvatarProfile')
        local Major = MajorUtil.GetMajor();
        local ProfileName = splitList[3] or ""
        _G.UE.UActorManager:Get():CreateActorByAvatarEditorAssetDefault("", ProfileName, Major:FGetActorLocation())
    elseif Name == "profilegroup" then
        local List = {1025176, 1011081, 64, 348, 2140, 1000105, 1000177, 1520, 1003034, 1003192, 1003947, 1004379, 1005137, 364, 2413}
        local delayTime = 0.0
        local step = 0.2
        for i = 1, #(List) do
            local DelayCallBack = function()
                local Major = MajorUtil.GetMajor();
                _G.UE.UActorManager:Get():CreateActorByAvatarEditorAssetDefault("", tostring(List[i]), Major:FGetActorLocation())
            end
            if(delayTime ~= 0) then
                _G.TimerMgr:AddTimer(self, DelayCallBack, delayTime, 1.0, 1, nil)
            else
                local Major = MajorUtil.GetMajor();
                _G.UE.UActorManager:Get():CreateActorByAvatarEditorAssetDefault("", tostring(List[i]), Major:FGetActorLocation())
            end
            delayTime = delayTime + step
        end
    elseif Name == "musickey" then
        local Key = tonumber(Param1)
        _G.MusicPerformanceMgr:Request(Key)
    elseif Name == "music" then
        if not _G.UIViewMgr:IsViewVisible(_G.UIViewID.MusicPerformanceSelectPanelView) then
            _G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceSelectPanelView)
            UIViewMgr:HideView(UIViewID.GMMain)
        end
    elseif Name == "musicstart" then
        local InstrumentID = tonumber(Param1)
        _G.MusicPerformanceMgr:SetModeLocal(InstrumentID)
    elseif Name == "musicend" then
        _G.MusicPerformanceMgr:ReqAbortPerform()
    elseif "CancelRide" == Name then
        local Major = MajorUtil.GetMajor()
        local RideComp = Major:GetRideComponent()
        if RideComp then
            RideComp:UnUseRide(tonumber(Param1)==1)
        end
    elseif "listen" == Name and "target" == Param1 then
        local EntityID = Param2
        if _G.UIViewMgr:IsViewVisible(_G.UIViewID.MainPanel) then
            if _G.UIViewMgr:IsViewVisible(_G.UIViewID.GMTargetInfo) then
                _G.UIViewMgr:FindVisibleView(_G.UIViewID.GMTargetInfo):UpdateView({EntityID = EntityID})
            else
                _G.UIViewMgr:ShowView(_G.UIViewID.GMTargetInfo, {EntityID = EntityID})
            end
        end
    elseif "fate" == Name and "update" == Param1 then
        _G.FateMgr:TestUpdateFate()
    elseif "fate" == Name and "end" == Param1 then
        _G.FateMgr:TestEndFate()
    elseif "SetCustomStatus" == Name then
        _G.OnlineStatusMgr:SetCustomStatus(_G.tonumber(Param1))
    elseif "OnlineStatusShow" == Name then
        local function Callback(_, RoleVM)
            local Util = require("Game/OnlineStatus/OnlineStatusUtil")
            local Text = string.format("\nMajor's status: %s. CustomStatus: %d. Identity: %s",
                    Util.ToString(RoleVM.OnlineStatus), RoleVM.OnlineStatusCustomID,
                    _G.table.concat(Util.DecodeBitset(RoleVM.Identity), " "))
            GMMgr.GMHistoryRecord = GMMgr.GMHistoryRecord .. Text
            local GMMainView = _G.UIViewMgr:ShowView(_G.UIViewID.GMMain)
            GMMainView.GMMain_UIBP:UpdateGMHistory()
        end
        if Param1 ~= nil then
            _G.RoleInfoMgr:QueryRoleSimple(_G.tonumber(Param1), Callback, nil, false)
        else
            _G.RoleInfoMgr:QueryRoleSimple(MajorUtil.GetMajorRoleID(), Callback, nil, false)
        end
    elseif "OnlineStatusShowSettings" == Name then
        _G.UIViewMgr:ShowView(_G.UIViewID.OnlineStatusSettingsPanel)
    elseif "Recharge" == Name then
        _G.RechargingMgr:ShowMainPanel()
    elseif "SDKTest" == Name then
        _G.SDKMgr:ShowMainPanel()
    elseif "AvatarHide" == Name then
        local PosKey = tonumber(Param1)
        local bHide = tonumber(Param2) == 1
        local bFade = tonumber(splitList[5]) == 1
        local AvatarComp = MajorUtil.GetMajorAvatarComponent()
        if AvatarComp then
            AvatarComp:SetAvatarHiddenInGame(PosKey, bHide, bFade)
        end
    elseif "CustomFace" == Name then
        local PartKey = tonumber(Param1)
        local Value = tonumber(Param2)
        local AvatarCom = MajorUtil.GetMajorAvatarComponent()
        if AvatarCom then
            AvatarCom:SetAvatarPartCustomize(PartKey, Value, false)
        end
    elseif "SkinColor" == Name then
        local ID = tonumber(Param1)
        MajorUtil.GetMajorAvatarComponent():GMSetSkinColor(ID)
    elseif "PcssOpen" == Name then
        local DirLight = UE4.UGameplayStatics.GetActorOfClass(FWORLD(), _G.UE.ADirectionalLight.StaticClass())
        if DirLight then
            local DirLightComp = DirLight.DirectionalLightComponent
            DirLightComp.bMobileExtraCascadeShadow = tonumber(Param1) == 1
        end
    elseif "PcssCSMDistance" == Name then
        local DirLight = UE4.UGameplayStatics.GetActorOfClass(FWORLD(), _G.UE.ADirectionalLight.StaticClass())
        if DirLight then
            local DirLightComp = DirLight.DirectionalLightComponent
            DirLightComp.DynamicShadowDistanceMovableLight = tonumber(Param1)
        end
    elseif "PcssCSMDistributionExponente" == Name then
        local DirLight = UE4.UGameplayStatics.GetActorOfClass(FWORLD(), _G.UE.ADirectionalLight.StaticClass())
        if DirLight then
            local DirLightComp = DirLight.DirectionalLightComponent
            DirLightComp.CascadeDistributionExponent = tonumber(Param1)
        end
    elseif "PcssShadowBias" == Name then
        local DirLight = UE4.UGameplayStatics.GetActorOfClass(FWORLD(), _G.UE.ADirectionalLight.StaticClass())
        if DirLight then
            local DirLightComp = DirLight.DirectionalLightComponent
            DirLightComp.MobileExtraShadowBias = tonumber(Param1)
        end
    elseif "PcssShadowSlopeBias" == Name then
        local DirLight = UE4.UGameplayStatics.GetActorOfClass(FWORLD(), _G.UE.ADirectionalLight.StaticClass())
        if DirLight then
            local DirLightComp = DirLight.DirectionalLightComponent
            DirLightComp.MobileExtraShadowSlopeBias = tonumber(Param1)
        end
    elseif "CSMCascadeNum" == Name then
        local DirLight = UE4.UGameplayStatics.GetActorOfClass(FWORLD(), _G.UE.ADirectionalLight.StaticClass())
        if DirLight then
            local DirLightComp = DirLight.DirectionalLightComponent
            DirLightComp:SetDynamicShadowCascades(tonumber(Param1))
        end
    elseif "EngineEasyHDShadow" == Name then
        local Text = string.format("EngineTest.CSMEnable %d", tonumber(Param1))
        local PlayerController = GameplayStaticsUtil.GetPlayerController()
        PlayerController:ConsoleCommand(Text, true)
    elseif "EngineEasyHDShadowDebug" == Name then
        if Param1 == nil then
            FLOG_ERROR("GM Name = EngineEasyHDShadowDebug, Param1 Can Not Is Null")
            return
        end
        local Text = string.format("EngineTest.CSMDebugEnable %d", tonumber(Param1))
        local PlayerController = GameplayStaticsUtil.GetPlayerController()
        PlayerController:ConsoleCommand(Text, true)
    elseif "EngineFarCamDst" == Name then
        local Text = string.format("EngineTest.FarCamDst %d", tonumber(Param1))
        local PlayerController = GameplayStaticsUtil.GetPlayerController()
        PlayerController:ConsoleCommand(Text, true)
    elseif "EngineFarDistribution" == Name then
        local Text = string.format("EngineTest.FarDistribution %d", tonumber(Param1))
        local PlayerController = GameplayStaticsUtil.GetPlayerController()
        PlayerController:ConsoleCommand(Text, true)
    elseif "EngineNearCamDst" == Name then
        if Param1 ~= nil then
            local Text = string.format("EngineTest.NearCamDst %d", tonumber(Param1))
            local PlayerController = GameplayStaticsUtil.GetPlayerController()
            PlayerController:ConsoleCommand(Text, true)
        end
    elseif "EngineNearDistribution" == Name then
        local Text = string.format("EngineTest.NearDistributionExponent %d", tonumber(Param1))
        local PlayerController = GameplayStaticsUtil.GetPlayerController()
        PlayerController:ConsoleCommand(Text, true)
    elseif "ReqVision" == Name then
        print("client ReqVision")
        _G.UE.UVisionMgr.Get():ReqVision()
    elseif "playTutorial" == Name then
        local ID = tonumber(Param1)
        _G.NewTutorialMgr:PlayGMTutorial(ID)
    elseif "playTutorialGuide" == Name then
        -- 打开
        local ID = tonumber(Param1)
        _G.TutorialGuideMgr:PlayGMGuide(ID)
    elseif "EnableTutorial" == Name then
        local Enable = tonumber(Param1)
        _G.NewTutorialMgr:EnableGMTutorial(Enable)
        _G.TutorialGuideMgr:EnableGMTutorial(Enable)
    elseif "Drop" == Name then
        -- LOOT_TYPE.LOOT_TYPE_ITEM = 1
        local LootItem = { Type = 1, Item = { GID = 0, ResID = 50211082, Value = 22 } }
        local CommList = {LootItem}
        LootMgr:ShowCommonDropList(CommList, false)
    elseif "setrunstate" == Name then
        local SelectedTarget = _G.SelectTargetMgr:GetCurrSelectedTarget()
        local StateComp = SelectedTarget:GetStateComponent()
        local IsRunning = tonumber(Param1) > 0
        StateComp:SetRunningState(IsRunning)
    elseif "CameraSettings" == Name then
        UIViewMgr:ShowView(UIViewID.CameraSettingsPanel)
    elseif "CharacterInfo" == Name then
        UIViewMgr:ShowView(UIViewID.GMCharacterInfo)
    elseif "setAirPath" == Name then
        self:ReqGM(string.format("lua _G.RideShootingMgr:SelectPath(%s)", Param1))
    elseif "Blacksmith" == Name then
        local TapIndex = tonumber(Param1)
        local Efficiency = tonumber(Param2)
        local HeatType = tonumber(Param3)

        local BlacksmithView = _G.UIViewMgr:FindVisibleView(3514)
        if BlacksmithView then
            if TapIndex < 60 then
                BlacksmithView:SetPanelType(1)
                TapIndex = TapIndex - 40
            else
                BlacksmithView:SetPanelType(2)
                TapIndex = TapIndex - 60
            end
            BlacksmithView:SetTapParams(TapIndex, Efficiency, HeatType)
        end
    elseif "EnvSoundDebugDraw" == Name then
        local EnvSoundMgr = _G.UE.UEnvSoundMgr
        if EnvSoundMgr then
            EnvSoundMgr.Get():SetShouldDrawDebugShape(tonumber(Param1) ~= 0 and true or false)
        end
    elseif "SetBGMVolumeScaleAtChannel" == Name then
        _G.UE.UBGMMgr.Get():SetAudioVolumeScaleAtChannel(tonumber(Param1), tonumber(Param2))
    elseif "SetNearestPointListenerType" == Name then
        local EnvSoundMgr = _G.UE.UEnvSoundMgr
        local ENearestPointListenerType = _G.UE.ENearestPointListenerType
        if EnvSoundMgr and ENearestPointListenerType then
            if Param1 == "Camera" then
                EnvSoundMgr.Get():SetNearestPointListenerType(ENearestPointListenerType.Camera)
            elseif Param1 == "Character" then
                EnvSoundMgr.Get():SetNearestPointListenerType(ENearestPointListenerType.Character)
            end
        end
    elseif "trans" == Name then
        local PWorldID = tonumber(Param1)

        if Param2 then
            local MapID = tonumber(Param2)
            self:ReqGM(string.format("scene enter %d %d", PWorldID, MapID))
        else
            self:ReqGM(string.format("scene enter %d", PWorldID))
        end
        -- _G.PWorldMgr:SendEnterPWorld(PWorldID, MapID)
    elseif "PathFollow" == Name then
        if Param1 == "Start" then
            local FileName = "Waypoints.txt"
            if Param2 ~= nil and Param2 ~= "" then
                FileName = Param2
            end

            local Waypoints = _G.UE.TArray(_G.UE.FVector)
            _G.UE.USaveMgr.LoadTextFileAsVectors(FileName, Waypoints)
            MajorUtil.GetMajor():StartPathFollow(Waypoints)
        elseif Param1 == "Pause" then
            MajorUtil.GetMajor():PausePathFollow()
        elseif Param1 == "Resume" then
            MajorUtil.GetMajor():ResumePathFollow()
        end
    elseif "chocoboshow" == Name then
        _G.ChocoboMgr:ShowChocoboMainPanelView()
    elseif "changemountpart" == Name then
        local Major = MajorUtil.GetMajor()
        local RideComp = Major:GetRideComponent()
        if RideComp then
            RideComp:ChangeMountPart(tonumber(splitList[3]), tonumber(splitList[4]), tonumber(splitList[5]), tonumber(splitList[6]))
        end
    elseif "takeoffmountpart" == Name then
        local Major = MajorUtil.GetMajor()
        local RideComp = Major:GetRideComponent()
        if RideComp then
            RideComp:TakeOffMountPart(tonumber(splitList[3]))
        end
    elseif "chocoboshowid" == Name then
        local RetList = {}
        local TempList = _G.ChocoboMainVM:GetChocoboViewModels()
        for __, V in pairs(TempList) do
            local Temp = {}
            Temp.ID = V.ChocoboID
            Temp.Name = V.Name
            table.insert(RetList, Temp)
        end
        local Text = _G.table_to_string(RetList)
        GMMgr.GMHistoryRecord = GMMgr.GMHistoryRecord .. Text .. "\n"
    elseif "summonscale" == Name then
        _G.SummonMgr:SetSummonScale(tonumber(Param1))
    elseif "Tradition" == Name then
        local Major = MajorUtil.GetMajor()
        local bIsTradition = false
        if tonumber(Param1) == 1 then
            bIsTradition = true
        end
        Major:GetCameraControllComponent():SwitchSurroundResponseSkill(not bIsTradition)
        Major:GetStateComponent():SetSkillTriggersFaceToTarget(not bIsTradition)
    elseif "printnavmesh" == Name then
        if _G.NaviDecalMgr.TargetPosByWorldOrigin then
            local Major = MajorUtil:GetMajor()
            local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
            local TargetPos = _G.NaviDecalMgr.TargetPosByWorldOrigin
            local Text = string.format("\n起点：%s\n终点：%s", tostring(MajorPos), tostring(TargetPos))
            GMMgr.GMHistoryRecord = GMMgr.GMHistoryRecord .. Text .. "\n"
        else
            local Text = "\n当前没有寻路"
            GMMgr.GMHistoryRecord = GMMgr.GMHistoryRecord .. Text .. "\n"
        end
    elseif "CrafterHideOtherPlayers" == Name then
        _G.CrafterMgr:SetShouldHideOtherPlayer(tonumber(Param1) ~= 0)
    elseif "PrintBGMMapRangeInfo" == Name then
        local Text = _G.UE.UBGMAreaMgr.Get():GetDebugInfo()
        GMMgr.GMHistoryRecord = GMMgr.GMHistoryRecord .. "\n" .. Text .. "\n"
    elseif "GetSkillListForSkillSystemSequence" == Name then
        local SkillIDList = SkillUtil.GetSkillListForSkillSystemSequence()
        local Text = table.concat(SkillIDList, ",")
        GMMgr.GMHistoryRecord = GMMgr.GMHistoryRecord .. "\n" .. Text .. "\n"
    elseif "NPCDialogGM" == Name then
        UIViewMgr:ShowView(UIViewID.NPCDialogGMPanel)
    elseif "showrtt" == Name then
        _G.EventMgr:SendEvent(_G.EventID.GMShowRTT, tonumber(Param1) ~= 0)
    elseif "showsamplepanel" == Name then
        UIViewMgr:ShowView(UIViewID.SampleMain)
    elseif "testdisconnect" == Name then
        _G.NetworkStateMgr.TestDisconnect()
    elseif "testreconnect" == Name then
        _G.NetworkStateMgr.TestReconnect()
    elseif "SetMaxDistance" == Name then
        if nil == Param1 then return end
        local InteractiveType = tonumber(Param1)
        local MaxDistance = tonumber(splitList[4]) or -1
        if MaxDistance < 0 then return end
        _G.FLOG_INFO("SetMaxDistance InteractiveType=%d, MaxDistance=%f", InteractiveType, MaxDistance)
    elseif "playdialog" == Name then
        local DialogLibID = tonumber(Param1)
        _G.NpcDialogMgr:PlayDialogLib(DialogLibID)
    elseif "ShowChocoboRaceAreaCollision" == Name then
        _G.ChocoboRaceMgr:ShowArea()
    elseif "allowride" == Name then
        _G.MountMgr.AllowRide = true
    elseif "LogSkillPoolInfo" == Name then
        _G.SkillObjectMgr:LogPoolInfo()
        _G.FLOG_INFO(" ")
        _G.SkillActionMgr:LogPoolInfo()
    elseif "LoadingMap" == Name then
        local MapID = tonumber(Param1) or 0
        local LoadingTime = tonumber(Param2) or 1
        _G.LoadingMgr:DebugShowMapLoading(MapID, LoadingTime)
    elseif "LoadingPool" == Name then
        local LoadingPoolID = tonumber(Param1) or 0
        local MapID = tonumber(Param2) or 0
        local LoadingTime = tonumber(Param3) or 1
        _G.LoadingMgr:DebugShowLoadingPool(LoadingPoolID, MapID, LoadingTime)
    elseif "LoadingView" == Name then
        local ContentID = tonumber(Param1) or 0
        local MapID = tonumber(Param2) or 0
        local LoadingTime = tonumber(Param3) or 1
        _G.LoadingMgr:DebugShowLoadingView(ContentID, MapID, LoadingTime)
    elseif "SimulateLoading" == Name then
        local MapID = tonumber(Param1) or 0
        local Count = tonumber(Param2) or 0
        local Result = _G.LoadingMgr:DebugSimulateLoading(MapID, Count)
        GMMgr.GMHistoryRecord = GMMgr.GMHistoryRecord .. "\n\n" .. "Simulate Result:"
        for _, Item in ipairs(Result) do
            GMMgr.GMHistoryRecord = GMMgr.GMHistoryRecord .. "\n" .. tostring(Item.ID) .. ":" .. tostring(Item.Count)
        end
    elseif "querynd" == Name then
        local NpcResID = tonumber(Param1) or 0
        if NpcResID == 0 then
            GMMgr.GMHistoryRecord = GMMgr.GMHistoryRecord .."\nNPC ResID 不能为0 \n"
        else
            local DiscoveryID = _G.FogMgr:QueryNpcDiscoveryID(NpcResID)
            if DiscoveryID < 0 then
                GMMgr.GMHistoryRecord = GMMgr.GMHistoryRecord .."\nNPC ResID="..tostring(NpcResID).." 在当前地图找不到 \n"
            else
                GMMgr.GMHistoryRecord = GMMgr.GMHistoryRecord .. "\n".. tostring(NpcResID).."所属迷雾区域ID=" ..tostring(DiscoveryID).. "\n"
            end
        end
    elseif "ChangeOnlineStatusIcon" == Name then
        local MajorEntityID = MajorUtil.GetMajorEntityID()
        local ActorVM = _G.HUDMgr:GetActorVM(MajorEntityID)
        if ActorVM ~= nil then
            ActorVM.TextureOnlineStatus = Param1
        end
    elseif "ChangeCollectablesVersion" == Name then
        local Ver = {}
        Ver.X = tonumber(Param1) or 0
        Ver.Y = tonumber(Param2) or 0
        Ver.Z = tonumber(Param3) or 0
        _G.CollectablesMgr.CutVersion = Ver
        _G.CollectablesMgr:RestartRedDotLoad()
    elseif "meshcount" == Name then
        local Value = tonumber(Param2)
        if Value ~= nil then
            if Param1 == "player" then
                _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(1, false, Value, true)
                _G.FLOG_INFO("meshcount set to %d", Value)
            elseif Param1 == "npc" then
                _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(3, false, Value, true)
                _G.FLOG_INFO("meshcount set to %d", Value)
            elseif Param1 == "monster" then
                _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(2, false, Value, true)
                _G.FLOG_INFO("meshcount set to %d", Value)
            elseif Param1 == "monsterDungeon" then
                _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(2, true, Value, true)
                _G.FLOG_INFO("meshcount set to %d", Value)
            elseif Param1 == "companion" then
                _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(4, false, Value, true)
                _G.FLOG_INFO("meshcount set to %d", Value)
            end
        end
    elseif "SetMajorAudioType" == Name then
        local Major = MajorUtil.GetMajor()
        _G.UE.UAudioMgr.SetRTPCValue("Player_type", tonumber(Param1), 0, Major)
    elseif "ShowAnimViewTool" == Name then
        local AMajorController = GameplayStaticsUtil.GetPlayerController();
        if AMajorController then
            AMajorController:LoadSelectionManager();
        end
    elseif "SetGatherNoteVersion" == Name then
        if Param1 then
            _G.GatheringLogMgr:SetGameVersionNameGM(Param1)
        end
    elseif "UseAozyFont" == Name then
        ---若处于英文环境，则全局替换艾欧泽亚字体，其他语言环境会发生乱码
        if CommonUtil.IsCurCultureEnglish() then
            _G.UIViewMgr:SetUseAzerothFont(true)
            _G.HUDMgr:SetAllHUDFontForAozy(true)
        end
    elseif "UseMainFont" == Name then
        ---若处于英文环境，则全局替换主字体，适配Aozy字体切回
        if CommonUtil.IsCurCultureEnglish() then
            _G.UIViewMgr:SetUseMainFont(true)
            --- _G.HUDMgr:SetAllHUDFontForMain(true)
        end
    elseif "DrawPoint" == Name then
        local World = FWORLD()
        local Pos = _G.UE.FVector(tonumber(Param1),tonumber(Param2),tonumber(Param3))
        local Color = _G.UE.FLinearColor(1,0,0,1)
        local SphereRadius = tonumber(Param5)
        _G.UE.UKismetSystemLibrary.DrawDebugPoint(World,Pos,tonumber(Param5),Color,tonumber(Param4))
        --_G.UE.UKismetSystemLibrary.DrawDebugSphere(World,Pos,SphereRadius,64,Color,tonumber(Param4))

	elseif "LogCharaState" == Name then
        local Target = _G.SelectTargetMgr:GetCurrSelectedTarget() or MajorUtil.GetMajor()
		if nil ~= Target and nil ~= Target:GetStateComponent() then
			local CommonStateLog = Target:GetStateComponent():LogCommonState() .. "\n"
			local CombatStateLog = Target:GetStateComponent():LogCombatState() .. "\n"
			local Log = CommonStateLog .. CombatStateLog
			GMMgr.GMHistoryRecord = GMMgr.GMHistoryRecord .. "\n" .. Log
		end

    elseif "TestMapEditCfgMemory" == Name then
        _G.MapEditDataMgr:TestMapEditCfgMemory()

	elseif "ChangeMaxVisionCacheCount" == Name then
        _G.UE.UVisionMgr.Get():OverrideChannelMaxCacheCount(tonumber(Param1), tonumber(Param2))
		-- _G.VisionMeshMgr:ChangeMaxCacheCount(tonumber(Param1), tonumber(Param2))
    elseif LSTR("SetShadowBias") ==  Name then
        _G.UE.UTestMgr:Get():GMSetShadowBias(Param1);
    elseif LSTR("SetShadowSlopeBias") ==  Name then
        _G.UE.UTestMgr:Get():GMSetShadowSlopeBias(Param1);
    elseif LSTR("PreviewMeshToSocket") ==  Name then
        _G.UE.UTestMgr:Get():GMPreviewMeshToSocket(Param1,Param2,Param3);
    elseif LSTR("ActiveOrnamentByID") ==  Name then
        _G.UE.UTestMgr:Get():GMActiveOrnamentByID(Param1,Param2);
    elseif LSTR("SetMobileMobileExtraShadowBias") == Name then
        _G.UE.UTestMgr:Get():GMSetMobileMobileExtraShadowBias(Param1);
    elseif LSTR("SetMobileMobileExtraShadowSlopeBias") == Name then
        _G.UE.UTestMgr:Get():GMSetMobileMobileExtraShadowSlopeBias(Param1);
    elseif "uploadlog" == Name then
        _G.LevelRecordMgr:UpLoadLog(tonumber(Param1))
	elseif "PlayATL" == Name then
		local Major = MajorUtil.GetMajor()
		local Target = _G.SelectTargetMgr:GetCurrSelectedTarget()
		if nil == Target then
			Target = Major
		end
		if nil ~= Target and nil ~= Param1 then
			local VFXTarget = Target:GetActorEntityID()
			if nil ~= Param2 then
				VFXTarget = Major:GetActorEntityID()
			end
			Target:SetVFXTarget(VFXTarget)
			if nil ~= tonumber(Param1) then
                local tempATLName= ""
                tempATLName = Target:GetAnimationComponent().ConvertActionTimelineIDToStr(tonumber(Param1))
				_G.AnimMgr:PlayActionTimeLineWithCustomBlendTime(Target:GetActorEntityID(), tempATLName)
			else
				_G.AnimMgr:PlayActionTimeLineWithCustomBlendTime(Target:GetActorEntityID(), Param1)
			end
		end
    elseif "DebugFishLineTrace" == Name then
        _G.FishMgr:ShowDebugLineTarce()
	elseif "LogCommonStateChange" == Name then
        local Target = _G.SelectTargetMgr:GetCurrSelectedTarget() or MajorUtil.GetMajor()
		if nil ~= Target and nil ~= Target:GetStateComponent() then
			local Logs = Target:GetStateComponent():GetCommonStateUpdateLogs()
			local Output = ""
			for Index = 1, Logs:Length() do
				Output = Output .. Logs:GetRef(Index) .. "\n"
			end
			GMMgr.GMHistoryRecord = GMMgr.GMHistoryRecord .. "\n" .. Output
		end
    elseif "custommade" == Name then
        local EntityID = MajorUtil.GetMajorEntityID()
        _G.MountMgr:EquipCustomMade(EntityID, tonumber(Param1), tonumber(Param2))
    elseif "swShowTimeNow" == Name then
        _G.EventMgr:SendEvent(_G.EventID.GMShowTimeNow)
    elseif "ChangeMarketVersion" == Name then
        local Version = {}
        table.insert(Version, tonumber(Param1))
        table.insert(Version, tonumber(Param2))
        table.insert(Version, tonumber(Param3))
        _G.MarketMgr.CurVersion = Version
    elseif "mountui" == Name then
        _G.MountMgr:JumpToMountPanel(tonumber(Param1))
    elseif  "JumpByID" == Name then
        local JumpUtil = require("Utils/JumpUtil")
        JumpUtil.JumpTo(tonumber(Param1), true)
	elseif "SetBNPCAvatar" == Name then
		local Target = _G.SelectTargetMgr:GetCurrSelectedTarget()
		if nil == Target then
			return
		end
		Target:SetModelState(tonumber(Param1))
	elseif "HideAllCharacters" == Name then
		-- 当前仅用于自动化测试，其他场景切勿使用此GM
		local BuildConfig = _G.UE.UCommonUtil.GetBuildConfiguration()
		if BuildConfig == "Development" or BuildConfig == "Debug" then
			local bHide = nil == Param1 or tonumber(Param1) == 1
			FLOG_WARNING(string.format("Test only!!! %s all characters.", bHide and "Hide" or "Show"))
			local function HideAllActors()
				local Actors = _G.UE.UActorManager.Get():GetAllActors()
				for _, Actor in pairs(Actors) do
					Actor:SetVisibility(not bHide, _G.UE.EHideReason.Common, true)
				end
			end
			self:UnRegisterTimer(self.HideCharacterTimer)
			if bHide then
				self.HideCharacterTimer = self:RegisterTimer(HideAllActors, 0, 0, 0)
			else
				HideAllActors()
			end
		end
    elseif "TestTutorial" == Name then
        if Param1 ~= nil and tonumber(Param1) > 0 then
            Param2 = Param2 or 0
            Param3 = Param3 or 0

            local EventParams = _G.EventMgr:GetEventParams()
            EventParams.Type = tonumber(Param1)
            EventParams.Param1 = tonumber(Param2)
            EventParams.Param2 = tonumber(Param3)
            _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
        end
    elseif "NoCd" == Name then
        GMMgr:ReqGM("cell skill resetcd")
	elseif "GetActiveCommonStates" == Name then
		local ProtoCommon = require("Protocol/ProtoCommon")
		local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
		local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
		local ActiveStatesStr = "Active states:\n"
		for _, State in pairs(CommonStateUtil.GetActiveStates()) do
			ActiveStatesStr = ActiveStatesStr ..
				ProtoEnumAlias.GetAlias(ProtoCommon.CommStatID, State) .. "\n"
		end
		GMMgr.GMHistoryRecord = GMMgr.GMHistoryRecord .. "\n" .. ActiveStatesStr
		print(ActiveStatesStr)
    elseif "ClientReportRoleLeave" == Name then
        if Param1 == "0" then
            _G.ClientReportMgr:SetAllowSendRoleLeave(false)
        else
            _G.ClientReportMgr:SetAllowSendRoleLeave(true)
        end
    elseif "FishFastGM" == Name then
        -- 快速钓鱼GM指令
        local FishAreaID = _G.FishMgr:GetFishAreaID()
        local BaitID = tonumber(Param1) or 0
        -- 没有参数则为默认的抛竿和提竿技能
        local DropSkillID = tonumber(Param2) or 30301
        local LiftSkillID = tonumber(Param3) or 30302
        _G.FishMgr:SetFishFastState()
        GMMgr:ReqGM(string.format("role lifeskill fishfast %d %d %d %d", FishAreaID, BaitID, DropSkillID, LiftSkillID))
    elseif "MountCustomShot" == Name then
        local View = UIViewMgr:FindView(UIViewID.MountCustomMadePanel)
        if View then
            View:DebugSetShot(tonumber(Param1), tonumber(Param2), tonumber(Param3), tonumber(Param4), tonumber(Param5), tonumber(Param6), tonumber(Param7))
        end
    elseif "TestSetAutoSkipQuestSequence" == Name then
        local bValue = (Param1 ~= "0")
        _G.StoryMgr.Setting.SetAutoSkipQuestSequence(bValue)
        print("GM SetAutoSkipQuestSequence", bValue)
    elseif "parselabel" == Name then
        _G.FLOG_INFO(DialogueUtil.ParseLabel(Param1))
    elseif "ShowVfxInfo" == Name then
        if _G.UIViewMgr:IsViewVisible(_G.UIViewID.MainPanel) then
            _G.UIViewMgr:ShowView(_G.UIViewID.GMVfxInfo)
        end
    elseif "SwitchPlayerEffWhiteList" == Name then
        local bSwitch = (Param1 ~= "0")
        self:SwitchPlayerEffWhiteList(bSwitch)
        _G.FLOG_INFO(DialogueUtil.ParseLabel(Param1))
    elseif "SwitchVisionEffWhiteList" == Name then
        local bSwitch = (Param1 ~= "0")
        self:SwitchVisionEffWhiteList(bSwitch)
    elseif "HotUpdateTest" == Name then
        UIViewMgr:ShowView(UIViewID.HotUpdateTest)
    elseif "LogVfxInfo" == Name then
        local bStartLogVfxInfo = (Param1 ~= "0")
        _G.UE.UTestMgr:Get():GMLogVfxInfo(bStartLogVfxInfo)
    elseif "SidePopup" == Name then
        local Type = tonumber(Param2) or 0
        if Type == 0 then
            _G.SidePopUpMgr.PauseCount = "Pause" == Param1 and 1 or 0
        else
            _G.SidePopUpMgr:Pause(Type,"Pause" == Param1)
        end
    elseif "SysChatMsgBattleLimit" == Name then
        local SysChatMsgBattleLimit = tonumber(Param1) or 3
        _G.SkillLogicMgr:SetSysChatMsgBattleLimit(SysChatMsgBattleLimit)
    elseif "AddSysChatMsgBattle" == Name then
        local AttackNum = tonumber(Param1) or 0
        local BuffNum = tonumber(Param2) or 0
        _G.SkillLogicMgr:AddSysChatMsgBattleDebug(AttackNum, BuffNum)
    end
end

function GMMgr:OnNetMsgPWorldReady(MsgBody)
	local MaxCycle = 100
	self.TimeStamp = (self.TimeStamp + 1) % MaxCycle

	if true == self.bStartTest then
		local DelayCallBack = function()
            GMMgr:ReqGM("social fight AutoFight_Fight")
        end

        self.bStartTest = false
        TimerMgr:AddTimer(self, DelayCallBack, 10.0, 1.0, 1, nil)
    end
end

function GMMgr:OnGetTargetAIInfo(MsgBody)
    --_G.FLOG_INFO("OnGetTargetAIInfo")
    local AIInfoGetRsp = MsgBody.ai_info_rsp
    local TargetAIInfoStr = RichTextUtil.GetText("AI数据", "#ffcc33ff")
    for _, value in ipairs(AIInfoGetRsp.info_items) do
        TargetAIInfoStr = TargetAIInfoStr .. "\n"
        if value.name ~= nil and value.name ~= '' then
            TargetAIInfoStr = TargetAIInfoStr .. value.name .. "     "
        end
        for index, Data in ipairs(value.data) do
            --_G.FLOG_INFO("OnGetTargetAIInfo,Data.arg_int = %s,UINT64_MAX = %s",Data.arg_int,UINT64_MAX)
            if Data.arg_string ~= nil and Data.arg_string ~= '' then
                TargetAIInfoStr = TargetAIInfoStr .. Data.arg_string
            end
            if Data.arg_int ~= UINT64_MAX and Data.arg_int ~= -1 then
                TargetAIInfoStr = TargetAIInfoStr .. Data.arg_int
            end
		end
	end

    _G.EventMgr:SendEvent(_G.EventID.GMGetMonsterAIInfo, TargetAIInfoStr)
end

function GMMgr:GetTargetAIInfo(TargetEntityID)

end

function GMMgr:SetCacheValue(key, value)
    if nil == self.CacheValue then
        self.CacheValue = {}
        self.CacheTime = {}
    end

    if self.CacheValue[key] == nil then
        table.insert(self.CacheValue, {})
        table.insert(self.CacheTime, {})
    end

    self.CacheValue[key] = value
    self.CacheTime[key] = self.TimeStamp
end

function GMMgr:GetCacheValue(key, Reset)
    if nil == self.CacheValue then
        self.CacheValue = {}
        self.CacheTime = {}
    end
    if 1 == Reset and self.CacheTime[key] ~= self.TimeStamp then
        self.CacheTime[key] = self.TimeStamp
        self.CacheValue[key] = 0
    end
    return self.CacheValue[key]
end

function GMMgr:CaptainStart()
    self.bStartTest = true
    self:ReqGM("social fight AutoFight_Cloth")

    local DelayCallBack = function()
        GMMgr:ReqGM("social enter")
    end

    TimerMgr:AddTimer(self, DelayCallBack, 5.0, 1.0, 1, nil)
end

function GMMgr:StartAutoFight()
    if true == self.bAutoFight then
        self:EndAutoFight()
    end

    self.bAutoFight = true

    self.ShouldMove = false
    self.SkillTime = 1.0
    self.MoveTime = 3.0
    self.WaitTime = 1.0

    self.SkillIndex = 0

    self.AutoSkillTimer = TimerMgr:AddTimer(self, self.OnAutoSkill, 1.0, self.SkillTime, -1.0, nil)
    self.AutoMoveTimer = TimerMgr:AddTimer(self, self.OnAutoMove, 1.0, 1.0, 1, nil)
    self.AutoTickTimer = TimerMgr:AddTimer(self, self.OnAutoTick, 1.0, 0.2, -1, nil)
end

function GMMgr:EndAutoFight()
    self.bAutoFight = false

    if nil ~= self.AutoSkillTimer then
        TimerMgr:UnRegisterTimer(self.AutoSkillTimer)
        self.AutoSkillTimer = nil
    end
    if nil ~= self.AutoMoveTimer then
        _G.TimerMgr:UnRegisterTimer(self.AutoMoveTimer)
        self.AutoMoveTimer = nil
    end
    if nil ~= self.AutoTickTimer then
        _G.TimerMgr:UnRegisterTimer(self.AutoTickTimer)
        self.AutoTickTimer = nil
    end

    self:MajorIdle()
end

-- 释放技能
function GMMgr:OnAutoSkill()
    if true ~= self.bAutoFight then return end

    local SkillID = _G.SkillLogicMgr:MajorPlaySkill(self.SkillIndex)
    if nil ~= SkillID then
        SkillUtil.CastSkill(self.SkillIndex, SkillID)
    end

    self.SkillIndex = (self.SkillIndex + 1) % 8
end

function GMMgr:OnAutoMove()
    if true ~= self.bAutoFight then return end

    self.ShouldMove = true

    self:ResetCamera()

    self.AutoMoveTimer = _G.TimerMgr:AddTimer(self, self.OnAutoMoveWait, self.MoveTime, 1.0, 1, nil)
end

function GMMgr:OnAutoMoveWait()
    if true ~= self.bAutoFight then return end

    self.ShouldMove = false

    self.AutoMoveTimer = _G.TimerMgr:AddTimer(self, self.OnAutoMove, self.WaitTime, 1.0, 1, nil)
end

-- 移动
function GMMgr:OnAutoTick()
    if self.ShouldMove then
        self:MajorMoveForward()
    else
        self:MajorIdle()
    end
end

function GMMgr:ResetCamera()
    local Major = MajorUtil.GetMajor();
    if Major then
        Major:GetCameraControllComponent():ResetSpringArm()
    else
        FLOG_ERROR("ResetCamera Major is Nil")
    end
end

function GMMgr:MajorMoveLeft()
    self:SimulateInputKey("A", _G.UE.EInputEvent.IE_Pressed)
end

function GMMgr:MajorMoveRight()
    self:SimulateInputKey("D", _G.UE.EInputEvent.IE_Pressed)
end

function GMMgr:MajorMoveForward()
    self:SimulateInputKey("W", _G.UE.EInputEvent.IE_Pressed)
end

function GMMgr:MajorMoveBack()
    self:SimulateInputKey("S", _G.UE.EInputEvent.IE_Pressed)
end

function GMMgr:MajorIdle()
    local KeyList = {"W", "A", "S", "D"}
    for i = 1, #KeyList do
        self:SimulateInputKey(KeyList[i], _G.UE.EInputEvent.IE_Released)
    end
end

function GMMgr:SimulateInputKey(KeyName, KeyEvent)
    local PlayerController = _G.GameplayStaticsUtil.GetPlayerController()
    if nil == PlayerController then return end
    if nil == PlayerController.SimulateInputKey then return end

    PlayerController:SimulateInputKey(KeyName, KeyEvent)
end

function GMMgr:OnGetTargetCombatInfo(MsgBody)
    _G.EventMgr:SendEvent(_G.EventID.GMGetTargetCombatInfo, MsgBody)
end

--自动移动到目标位置
function GMMgr:MoveTo(TargetPos)
    local UMoveSyncMgr = _G.UE.UMoveSyncMgr:Get()
    UMoveSyncMgr.OnSimulateMoveFinish:Clear()
    UMoveSyncMgr.OnSimulateMoveFinish:Add(UMoveSyncMgr, function(seqID, StopType)
        if StopType == _G.UE.ESimulateMoveStop.Finished then
            print("GMMgr:MoveTo NavComplete ")
            UMoveSyncMgr.OnSimulateMoveFinish:Clear()
        else
            print("GMMgr:MoveTo Nav cancel")
        end
    end)

	local Major = MajorUtil:GetMajor()
	-- local TargetPos = _G.UE.FVector(X, Y, Z)
	local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
    _G.FLOG_INFO("GMMgr:MoveTo BeginNav ")
   UMoveSyncMgr:StartSimulateMove(MajorPos, TargetPos, 10)
end

--主角和相机都朝向某个点
function GMMgr:LookAtPos(TargetPos)
	-- local TargetPos = _G.UE.FVector(120,-2350,119)
    MajorUtil.LookAtPos(TargetPos)

    local Major = MajorUtil.GetMajor()
    local CamCtrComp = Major:GetCameraControllComponent()
    if Major and CamCtrComp then
        local MajorRot = Major:FGetActorRotation()
        -- local MajorPosition = Major:FGetActorLocation() - _G.UE.FVector(0, 0, Major:GetCapsuleHalfHeight())
        -- local lookatRotation = _G.UE.UKismetMathLibrary.FindLookAtRotation(MajorPosition, TargetPos)
        CamCtrComp:SetCameraBoomRelativeRotation(MajorRot)
    end
end

function GMMgr:CrafterCamer(Length, a1, a2, a3)
    local Major = MajorUtil.GetMajor()
    -- local CamCtrComp = Major:GetCameraControllComponent()
    local Camera = Major:GetCameraControllComponent()
    local CameraParams = _G.UE.FCameraResetParam()
    if Major and Camera then
        -- local Ratation = _G.UE.FRotator(a1, a2, a3)
        -- -- local MajorRot = Major:FGetActorRotation()
        -- CamCtrComp:SetCameraBoomRelativeRotation(Ratation)
        -- CamCtrComp:SetArmLength(Length, true)
        CameraParams.Distance = Length
        CameraParams.Rotator = _G.UE.FRotator(a1, a2, a3)
        CameraParams.bRelativeRotator = true
        CameraParams.Offset = _G.UE.FVector(0, 0, 0)
        CameraParams.ResetType = _G.UE.ECameraResetType.Jump
        CameraParams.LagValue = 10
        Camera:ResetSpringArmByParam(_G.UE.ECameraResetLocation.RecordLocation, CameraParams)

    end
end

function GMMgr:ResetCameraPos(Length, AngleYaw)
    local Major = MajorUtil.GetMajor()
    local Camera = Major:GetCameraControllComponent()
    local CameraParams = _G.UE.FCameraResetParam()
    CameraParams.Distance = Length
    CameraParams.Rotator = _G.UE.FRotator(0, AngleYaw, 0)
    CameraParams.bRelativeRotator = true
    CameraParams.Offset = _G.UE.FVector(0, 0, 0)
    CameraParams.ResetType = _G.UE.ECameraResetType.Jump
    CameraParams.LagValue = 10
    Camera:ResetSpringArmByParam(_G.UE.ECameraResetLocation.RecordLocation, CameraParams)
end

function GMMgr:ResetCameraPosTest(Length, AnglePitch, AngleYaw)
    local Major = MajorUtil.GetMajor()
    local Camera = Major:GetCameraControllComponent()
    local CameraParams = _G.UE.FCameraResetParam()
    CameraParams.Distance = Length
    CameraParams.Rotator = _G.UE.FRotator(AnglePitch, AngleYaw, 0)
    CameraParams.bRelativeRotator = true
    CameraParams.Offset = _G.UE.FVector(0, 0, 0)
    CameraParams.ResetType = _G.UE.ECameraResetType.Jump
    CameraParams.LagValue = 10
    Camera:ResetSpringArmByParam(_G.UE.ECameraResetLocation.RecordLocation, CameraParams)
end

function GMMgr:Chsize(char)
	if not char then
		return 0
	elseif char > 240 then
		return 4
	elseif char > 225 then
		return 3
	elseif char > 192 then
		return 2
	else
		return 1
	end
end

function GMMgr:StringToTable(Str, Tab)
	local Index = 1
	while Index <= #Str do
		local char = string.byte(Str, Index)
		if self:Chsize(char) >= 3 then
			local value = string.sub(Str, Index, Index + self:Chsize(char) - 1)
			table.insert(Tab, value)
		end

		Index = Index + self:Chsize(char)
	end
	return Tab
end


---@param str1 string@input text
---@param str2 string@检索文本
function GMMgr:SearchByInput(str1, str2)
	local count = 0
	local list1 = {}
	local list2 = {}
    local IsSame = false

	list1 = self:StringToTable(str1, list1)
	list2 = self:StringToTable(str2, list2)

	if #list1 > 0 and #list2 > 0 then
		for i = 1, #list1 do
			for j = #list2, 1, -1 do
				if list1[i] == list2[j] then
					count = count + 1
                    if count >= 2 then
                        IsSame = true
                        return IsSame
                    end
				end
			end
		end
	end

	return IsSame
end

function GMMgr:SwitchPlayerEffWhiteList(Switch)
    self.PlayerEffWhiteListSwitch = Switch
end

function GMMgr:SwitchVisionEffWhiteList(Switch)
    self.VisionEffWhiteListSwitch = Switch
end

return GMMgr