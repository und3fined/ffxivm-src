--[[
Author: your name
Date: 2021-08-19 09:54:41
LastEditTime: 2021-08-19 09:54:42
LastEditors: your name
Description: In User Settings Edit
FilePath: \Script\Game\Npc\NpcDialogMgr.lua
--]]

local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local LuaClass = require("Core/LuaClass")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local UIUtil = require("Utils/UIUtil")
local NpcCfg = require("TableCfg/NpcCfg")
local EobjCfg = require("TableCfg/EobjCfg")
local DialogCfg = require("TableCfg/DialogCfg")
local DefaultDialogCfg = require("TableCfg/DefaultDialogCfg")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local CommonUtil = require("Utils/CommonUtil")
local SwitchTalkCfg = require("TableCfg/SwitchTalkCfg")
local DialogStyleCfg = require("TableCfg/DialogStyleCfg")
local QuestDefine = require("Game/Quest/QuestDefine")
local ConditionMgr = require("Game/Interactive/ConditionMgr")
local CustomDialogOptionCfg = require("TableCfg/CustomDialogOptionCfg")
local NpcDialogCameraCfg = require("TableCfg/NpcDialogCameraCfg")
local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR
local FunctionItemFactory = require("Game/Interactive/FunctionItemFactory")
local NpcDialogHistoryVM = require("Game/Interactive/View/New/NpcDialogueHistoryVM")
local NpcDialogVM = require("Game/Story/NpcDialogPlayVM")
local StoryDefine = require("Game/Story/StoryDefine")
local AnimationUtil = require("Utils/AnimationUtil")
local ObjectGCType = require("Define/ObjectGCType")
local ActiontimelinePathCfg = require("TableCfg/ActiontimelinePathCfg")
local EffectUtil = require("Utils/EffectUtil")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS

local DialogParams = LuaClass()

function DialogParams:OnInit()
    self.NpcEntityID = 0
    self.DialogLibID = 0
    self.DialogGroup = 0
    self.IsTempSetAvatarBack = false
end

local NpcDialogState = {
    START_DIALOG = 0,
    FUNCTION = 1,
    END_DIALOG = 2,
    NO_DIALOG = 3,
    WAITING_INTERACTION = 4,
    END_QUEST_DIALOG = 5,
    PENDING_DIALOG = 6,
}

--后续考虑配表
local TimeLineBaseDefine = {
    BaseIdel = "EVENT_BASE_IDLE",          --普通站立
    BaseChair = "EVENT_BASE_CHAIR_SIT",    --普通椅子坐
    BaseGround = "EVENT_BASE_CHAIR_START"  --普通地板坐
}

local ExcessiveTimeLineDefine = {
    EVENT_BASE_CHAIR_END = "EVENT_BASE_CHAIR_END",
    EVENT_BASE_GROUND_END = "EVENT_BASE_GROUND_END",
    EVENT_BASE_CHAIR_START = "EVENT_BASE_CHAIR_START",
    EVENT_BASE_GROUND_START = "EVENT_BASE_GROUND_START"
}

local StanceTypeDefine = {
    NOTHING = 0,                           --无
	NORMAL_STAND = 1,                      --基本站立
	NORMAL_SIT_GROUND = 2,                 --基本地面坐
	NORMAL_SIT_CHAIR = 3,                  --基本椅子坐
	SPECIAL_STAND = 4,                     --华丽的站立
	SPECIAL_SIT_GROUND = 5,                --华丽的地面坐
	SPECIAL_SIT_CHAIR = 6,                 --华丽的椅子坐,
	STAND_ONLY = 7,                        --站立状态专用
	SIT_GROUND_ONLY = 8,                   --地面坐状态专用
	SIT_CHAIR_ONLY = 9,                    --椅子坐状态专用
	PECULIAR = 10,                         --特殊
	GOING_TO_STAND_FROM_SIT_GROUND = 11,   --从地面坐到站着
	GOING_TO_STAND_FROM_SIT_CHAIR = 12,    --从椅子坐到站着
	GOING_TO_SIT_GROUND_FROM_STAND = 13,   --从站着到地面坐
	GOING_TO_SIT_CHAIR_FROM_STAND = 14,    --从站着到椅子坐
}

local MajorValidDistance = 150
local MajorCameraValidDistance = 350
local MIN_FLOOR_DIST = 1.9
local MAX_FLOOR_DIST = 2.4

local NpcDialogMgr = LuaClass(MgrBase)

function NpcDialogMgr:OnInit()
    self.LastDialog = DialogParams:New()
    self.DialogQueue = {}
    self.DialogLib = {}
    self.DialogState = NpcDialogState.NO_DIALOG
    self.bIsDialogPlaying = false
    self.DialogLibLastGroup = {}
    self.QuestDialogParams = nil
    self.PlayDialogCallbacks = {}
    -- self.CachedCameraSettings = nil
    self.PreDefaultDialogID = 0
    self.NpcLookAtData = {}

	-- 任务自动对话需求，避免两组对话之间主界面突然显示又隐藏
    -- 这个MainPanel指游戏主界面，和self.MainPanel不一样
	--self.DelayMainPanelTimer = nil
    self.bAutoPlayDialog = false

    self.EnableEndInteractionWhenFinishing = true

    self.bIsSetMove = false

    self.IdleTimer = nil
    self.PlayAnimtionCallBack = nil

    self.DialogNpcTable = {}
    self.ActorPreIdelAnimKeyTable = {}

    self.HudHideState = false

    self.ResumeTimerTable = {}
end

function NpcDialogMgr:OnBegin()
end

function NpcDialogMgr:OnEnd()
end

function NpcDialogMgr:OnShutdown()
end

function NpcDialogMgr:OnRegisterGameEvent()
    -- self:RegisterGameEvent(EventID.SelectTarget, self.OnGameEventSelectTarget)
    self:RegisterGameEvent(EventID.ClickNextDialog, self.OnGameEventClickNextDialog)
    self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)
    self:RegisterGameEvent(EventID.NPCFinishTurning, self.OnNPCFinishTurning)
    self:RegisterGameEvent(EventID.FinishDialog, self.OnGameEventFinishDialog)

    --为了保持原意，preclick的时候先修改NpcDialogState，然后再click
    self:RegisterGameEvent(EventID.PreClickFunctionItems, self.OnPreFunctionItemClick)
    -- self:RegisterGameEvent(EventID.PostClickFunctionItems, self.OnPostFunctionItemClick)

    self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldExit)
    self:RegisterGameEvent(EventID.MajorHit, self.OnGameEventMajorHit)
    self:RegisterGameEvent(EventID.MajorDead, self.OnGameEventMajorHit)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.EnterInteractive, self.OnEnterInteractive)

    --情感动作面板点击关闭的时候
    self:RegisterGameEvent(EventID.OnEmotionPanelClose, self.OnEmotionPanelClose)

    --本地传送
    self:RegisterGameEvent(EventID.PWorldTransBegin, self.OnGameEventEnterWorld)
    --切地图
    self:RegisterGameEvent(EventID.WorldPostLoad, self.OnGameEventEnterWorld)
    --网络闪断
    self:RegisterGameEvent(EventID.NetworkReconnected, self.OnRelayConnected)
    --任务失败
    self:RegisterGameEvent(EventID.QuestErrorFarDistance, self.CheckNeedEndInteraction)
    --Fate对话Npc销毁
    self:RegisterGameEvent(EventID.OnDialogNpcDestory, self.OnDialogNpcDestory)
end

--InteractiveMgr也保存了一份view pcw
--将来对话那部分单独拆出去，这里就不是MainPanel了
function NpcDialogMgr:OnGameEventMajorCreate(Params)
   
end

-- function NpcDialogMgr:OnGameEventSelectTarget(Params)

-- end

------------ 界面相关接口 --------------

---NpcDialogMgr.PlayDialogLib 根据DialogLibID播放对话库中的对话。此函数会将对话库的一组对话加入对话队列，然后播放队列中的第一条对话，参考NpcDialogMgr:PushDialog。
---@param DialogLibID number
---@param EntityID    number
---@param PlayDialogLibCallback function 对话组播放完毕后回调
---@param EnableEndInteractionWhenFinishing bool
---@param bUseNpcInteractionCamera bool 是不是使用Npc配置的InteractionCamera字段
---@param bCanMoveInteraction bool 是否能移动中交互
function NpcDialogMgr:PlayDialogLib(DialogLibID, EntityID, IsDefaultDialogID, PlayDialogLibCallback, 
    EnableEndInteractionWhenFinishing, bWithTurning, bUseNpcInteractionCamera, bCanMoveInteraction)
    if not bCanMoveInteraction and self:CheckCharacterMovementSpeed() then
        --外部调用需要结束交互
        self:EndInteraction()
        return
    end
    --HintTalk判断
    local IsHintTalk = false
    local ActorType = ActorUtil.GetActorType(EntityID)
    local ResID = ActorUtil.GetActorResID(EntityID)
    local HintTalkData
    if ActorType and  ActorType ==  _G.UE.EActorType.Npc then
        HintTalkData =  _G.QuestMgr:GetHintTalk(ResID)
    elseif ActorType and  ActorType ==  _G.UE.EActorType.EObj then
        HintTalkData =  _G.QuestMgr:GetHintTalk(nil, ResID)
    end
    if HintTalkData and next(HintTalkData) then
        IsHintTalk = true
        DialogLibID = HintTalkData.DialogID
        PlayDialogLibCallback = HintTalkData.Callback
    end

	CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.CommStatDialog, true)

    _G.EventMgr:SendEvent(EventID.StartDialog)
	_G.LuaCameraMgr:UpdateAmbientOcclusionParam(true)
    if DialogLibID ~= 0 then
        self:SetMajorCanMove(false)
    end
    InteractiveMgr:OnEnterDialogue()
    self.EnableEndInteractionWhenFinishing = EnableEndInteractionWhenFinishing or EnableEndInteractionWhenFinishing == nil
    self.IsSkipInteractiveUIAfterDialog = false

    self.DialogLibID = DialogLibID
    if not self.MainPanel then
        self.MainPanel = _G.UIViewMgr:ShowView(_G.UIViewID.NpcDialogueMainPanel,{ViewType = StoryDefine.UIType.NpcDialog})
    end

    if DialogLibID == nil or DialogLibID == 0 then
        if EntityID == -1 then
            FLOG_WARNING("no dialog, Interactive END_DIALOG, from FunctionNPCQuit")
            self.DialogState = NpcDialogState.END_DIALOG
        end

        FLOG_WARNING("Interactive PlayDialogLib DialogLibID=0, ClickNextDialog")
        if PlayDialogLibCallback ~= nil then
            PlayDialogLibCallback({NpcEntityID = 0, DialogGroup = 0, DialogLibID = 0})
        end
        self:ContinueDialog()
        return
    end

    if self.DialogLib == nil or self.DialogLib[DialogLibID] == nil then
        if EntityID ~= nil then
            self.DialogLib = self:ReadDialogLib(DialogLibID, EntityID)
        else
            self.DialogLib = self:ReadDialogLib(DialogLibID, self.LastDialog.NpcEntityID)
        end
        if next(self.DialogLib) == nil then
            FLOG_WARNING("Interactive ReadDialogLib failed")
            --如果点击二级交互的按钮后，对话逻辑失败，则结束npc的交互；  当前也处于一级交互的阶段
            self:EndInteraction()
            return
        end
    end

    FLOG_INFO("Interactive PlayDialogLib:%d", DialogLibID)

    local LastGroup = self.DialogLibLastGroup[DialogLibID]
    if LastGroup == nil then
        LastGroup = 0
    end

    local NewGroup = 0
    -- _G.FLOG_WARNING(string.format("NpcDialogMgr:PlayDialogLib: %d, %d", DialogLibID, EntityID))
    -- _G.FLOG_WARNING(table_to_string(self.DialogLib))
    local LibType = self.DialogLib[DialogLibID][1][1].DialogLibType
    if not next(self.DialogLib[DialogLibID][1]) then 
        FLOG_WARNING("GroupID == nil, Please Check it"..DialogLibID)
        return 
    end
    if LibType == ProtoRes.dialog_lib_type.SEQUENCE or IsHintTalk then
        NewGroup = math.min(LastGroup + 1, #self.DialogLib[DialogLibID])

    elseif LibType == ProtoRes.dialog_lib_type.RANDOM then
        NewGroup = LastGroup % #self.DialogLib[DialogLibID] + 1

    elseif LibType == ProtoRes.dialog_lib_type.QUEST then
        NewGroup = math.min(LastGroup + 1, #self.DialogLib[DialogLibID])
        if NewGroup == #self.DialogLib[DialogLibID] then
            self.DialogState = NpcDialogState.END_QUEST_DIALOG
            if IsDefaultDialogID then
                FLOG_ERROR("Interactive DefaultDialog is QuestDialog")
                MsgTipsUtil.ShowTips(LSTR(1280011))
            end
        end
    else
        NewGroup = math.min(LastGroup + 1, #self.DialogLib[DialogLibID])
    end

    for _, value in ipairs(self.DialogLib[DialogLibID][NewGroup]) do
        value.EntityID = EntityID or self.LastDialog.NpcEntityID
        value.bUseNpcInteractionCamera = bUseNpcInteractionCamera
        if value.Condition and value.Condition ~= 0 then
            if ConditionMgr:CheckConditionByID(value.Condition) then
                table.insert(self.DialogQueue, value)
            end
        else
            table.insert(self.DialogQueue, value)
        end
    end

    if PlayDialogLibCallback ~= nil then
        self.DialogQueue[#self.DialogQueue].Callback = PlayDialogLibCallback
    else
        self.DialogQueue[#self.DialogQueue].Callback = nil
    end
    local Actor = ActorUtil.GetActorByEntityID(EntityID)

    local Major = MajorUtil.GetMajor()
    local AvatarCom = Major:GetAvatarComponent()
    if AvatarCom and not self.IsTempSetAvatarBack then
        -- 立刻收刀
        self.IsTempSetAvatarBack = true
        _G.EmotionMgr:SendStopEmotionAll()
    end

    --设置一次Lookat
    if bWithTurning and Actor ~= nil and ActorType and ActorType == _G.UE.EActorType.Npc
    and not Actor:IsInInteraction() then
        local AnimCom = Actor:GetAnimationComponent()
        self:SavePreIdelAnimKey(ResID, AnimCom)
        Actor:BeginInteraction(true)
    else
        self:PlayDialogInQueue()
    end
end

---NpcDialogMgr.PushDialog 向对话队列中插入一条对话
---@param Content       string 对话框内容
---@param DialogStyleID number 对话框样式ID
---@param Name          string 对话框名字
---@param Title         string 对话框NPC称号
---@param Callback      function 插入对话的回调，该条对话播放完毕后调
function NpcDialogMgr:PushDialog(Content, DialogStyleID, Name, Title, Callback)
    local ParamContent = Content == nil and "" or Content
    local ParamDialogStyleID = DialogStyleID == nil and 0 or DialogStyleID
    local ParamName = Name == nil and "" or Name
    local ParamTitle = Title == nil and "" or Title

    local Params = {DialogContent = ParamContent, DialogStyle = ParamDialogStyleID, Name = ParamName, Title = ParamTitle, EntityID = self.LastDialog.NpcEntityID, Callback = Callback }
    table.insert(self.DialogQueue, Params)
    if self.MainPanel == nil then
        self.MainPanel = _G.UIViewMgr:ShowView(_G.UIViewID.NpcDialogueMainPanel,{ViewType = StoryDefine.UIType.NpcDialog})
    end
    if not self:IsDialogPlaying() then
        self:PlayDialogInQueue()
    end
end

---NpcDialogMgr.SwitchStyle 更改对话框样式
---@param Style       number 对话框样式表中的ID

function NpcDialogMgr:SwitchStyle(Style)
    if self.MainPanel ~= nil then
        self.MainPanel:SwitchStyle(Style)
    else
        FLOG_ERROR("NpcDialogMgr:SwitchStyle, MainPanel is nil")
    end
end

---NpcDialogMgr.IsDialogPlaying 当前正在对话框文字是否正在滚动显示
function NpcDialogMgr:IsDialogPlaying()
    return self.MainPanel ~= nil and NpcDialogVM.bIsDialogPlaying
end

function NpcDialogMgr:IsDialogPanelVisible()
    return self.MainPanel ~= nil and NpcDialogVM.bIsDialogVisible
end

---NpcDialogMgr.BreakDialog 打断当前对话
function NpcDialogMgr:BreakDialog()
    self.DialogQueue = {}
    if self.MainPanel then
        self.MainPanel:StopDialog()
    else
        FLOG_ERROR("NpcDialogMgr:BreakDialog, MainPanel is nil")
    end
end

------------ 内部接口 --------------

function NpcDialogMgr:OnGameEventClickNextDialog(Params)
    if not self:IsDialogPlaying() and self.LastDialog.Callback ~= nil then
        self.LastDialog.Callback(self.lastDialog)
        self.LastDialog.Callback = nil
    end

    if self:IsDialogPlaying() then
        -- 当前对话正在播放，加速
        self:SpeedUpDialog()
    elseif next(self.DialogQueue) ~= nil then
        -- 当前对话播放完毕，存在下一条对话，播放下一条
        self:PlayDialogInQueue()
    else
        -- 当前对话组结束
        local FinishDialogParams = { DialogLibID = self.LastDialog.DialogLibID, NpcEntityID = self.LastDialog.NpcEntityID }
        _G.EventMgr:SendEvent(_G.EventID.FinishDialog, FinishDialogParams)
        FLOG_INFO("Interactive OnGameEventClickNextDialog DialogState:%d", self.DialogState)
        -- for _, callback in ipairs(self.PlayDialogCallbacks) do
        --     if callback ~= nil then
        --         callback(self.LastDialog.DialogLibID, self.LastDialog.NpcEntityID)
        --     end
        -- end
        -- self.PlayDialogCallbacks = {}
        NpcDialogVM.bClickVisible = false 
        if self.IsSkipInteractiveUIAfterDialog then
            return
        end

        if not self.EnableEndInteractionWhenFinishing then
            return
        end

        if _G.InteractiveMgr:GetIsResetCustomTalk() then
            return
        end
        if (not _G.InteractiveMgr.CurInteractEntrance) and (not self.bAutoPlayDialog) then
            self:EndInteraction()
            _G.InteractiveMgr:ShowEntrances()
            return
        end

        --检查是否是对白分支，对白分支不结束交互，展示选项及后续功能
        if self:CheckDialogIDIsBranch() then
            return
        end

        self.DialogLibID = nil
        
        if self.DialogState == NpcDialogState.START_DIALOG or self.DialogState == NpcDialogState.FUNCTION then
            local FunctionList = _G.InteractiveMgr.CurInteractEntrance:GenFunctionList()
            local NpcType = ProtoRes.NPC_TYPE.NPC
            if _G.InteractiveMgr.CurInteractEntrance.Cfg then
                NpcType = _G.InteractiveMgr.CurInteractEntrance.Cfg.Type or 0
            end
            if (#FunctionList == 2 and self.DialogState == NpcDialogState.START_DIALOG   -- 如果除了离开以外只有一个功能选项，自动选择这个选项
            or #FunctionList == 1) and (NpcType and NpcType ~= ProtoRes.NPC_TYPE.ARMY) then                                              -- 如果只有离开选项，自动离开
                self.DialogState = NpcDialogState.FUNCTION

                if FunctionList[1]:NeedMessageBoxConfirm() then
                    local function func()
                        local CoHandle = coroutine.create(FunctionList[1].Click)
                        FunctionList[1].ClickCoroutine = CoHandle
                        FLOG_INFO("========== Interactive create and resume ClickCoroutine ==========")
                        coroutine.resume(CoHandle, FunctionList[1])
                        FLOG_INFO("Interactive ClickCoroutine resumed, and yiled to wait messagebox click ok or cancel")
                        local ClickRlt = coroutine.yield()
                        FLOG_INFO("========== Interactive after clickcorutine resume (ClickRlt is %s)", tostring(ClickRlt))
                        FunctionList[1].ClickCoroutine = nil
                        if not ClickRlt then
                            --通用交互没处理的就ClickNextDialog
                            _G.EventMgr:SendEvent(EventID.ClickNextDialog)
                        elseif not self:IsDialogPlaying() then
                            self:EndInteraction()
                        end
                    end

                    local Co = coroutine.create(func)
                    FunctionList[1].OuterCoroutine = Co
                    FLOG_INFO("####### Interactive NpcDialogMgr create and resume OuterCoroutine ####### ")
                    coroutine.resume(Co)
                    FLOG_INFO("####### Interactive NpcDialogMgr after resume OuterCoroutine ####### ")
                else
                    if not FunctionList[1]:Click(true) then
                        --通用交互没处理的就ClickNextDialog
                        _G.EventMgr:SendEvent(EventID.ClickNextDialog)
                    elseif not self:IsDialogPlaying() and self.EnableEndInteractionWhenFinishing then
                        self:EndInteraction()
                    end
                end

            else
                --这里有可能是2个function，也有可能是多于2个的
                --必然会有个离开的
                local ShowList = function()
                    -- 展示功能选项列表
                    _G.InteractiveMgr:SetFunctionList(FunctionList)
                    local InteractiveMainView = _G.UIViewMgr:FindView(_G.UIViewID.InteractiveMainPanel)
                    if not InteractiveMainView then return end
                    NpcDialogVM:SetSelfVisible(false)
                    NpcDialogVM:SetArrowHide(true)
                    _G.InteractiveMgr:SetMainPanelIsVisible(InteractiveMainView, true)
                end
                if NpcType and NpcType == ProtoRes.NPC_TYPE.ARMY then
                    ShowList()
                else
                    if #FunctionList <= 2 then
                        self:EndInteraction()
                        _G.InteractiveMgr:ShowEntrances()
                    else
                        ShowList()
                    end
                end
            end
        elseif self.DialogState == NpcDialogState.END_DIALOG then
            --该恢复到一级入口
            _G.InteractiveMgr:ShowEntrances()
            self:EndInteraction()
        elseif self.DialogState ==NpcDialogState.PENDING_DIALOG then
            -- do nothing
        else
            -- 对话库结束后更新任务状态
            if self.DialogState == NpcDialogState.END_QUEST_DIALOG
            and nil ~= self.QuestDialogParams then
                --print("Interactive 任务对话库结束")
                local NeedEndInteraction = _G.QuestMgr:OnQuestInteractionFinished(self.QuestDialogParams)
                self.QuestDialogParams = nil
                if self.bAutoPlayDialog then
                    self.bAutoPlayDialog = false
                end
                local ClearQuestData = NpcDialogHistoryVM:CheckCanClearQuestData()
                if NeedEndInteraction then
                    local NeedWait = _G.QuestMgr:IsBlackScreenOnStopDialogOrSeq(self.LastDialog.DialogLibID)
                    if NeedWait then
                        local FadeViewID = _G.UIViewID.CommonFadePanel
			            local Data = {}
			            Data.FadeColorType = 3
			            Data.Duration = 1
			            Data.bAutoHide = false
			            _G.UIViewMgr:ShowView(FadeViewID, Data)
                    end
                    self:EndInteraction(ClearQuestData)
                end
                NpcDialogVM:SetSelfVisible(false)
            else
                self:EndInteraction()
            end
        end
    end
end

function NpcDialogMgr:SetNpcLookAt(Actor, Target, EntityID)
    if Actor then
        local AnimComp = Actor:GetAnimationComponent()
        if not AnimComp then return end
        if EntityID and (not next(self.NpcLookAtData) or not self.NpcLookAtData[EntityID]) then
            local SaveParams = _G.UE.FLookAtParams()
            local LookatParam = AnimComp:GetLookAtParam()
            LookatParam.Target.Target = LookatParam.Target.Target
            LookatParam.Target.Type = LookatParam.Target.Type
            LookatParam.LookAtType = LookatParam.LookAtType
            self.NpcLookAtData[EntityID] = SaveParams
        end
        if Target then
            local LookAtTarget = _G.UE.FLookAtTarget()
            local Type =_G.UE.ELookAtType.All
            LookAtTarget.Type = _G.UE.ELookAtTargetType.Actor
            LookAtTarget.Target = Target
            local TempParams = _G.UE.FLookAtParams()
            TempParams.LookAtType = Type
            TempParams.Target = LookAtTarget
            TempParams.bInterp = true
            AnimComp:SetLookAtParam(TempParams)
        else
            if EntityID then
                local OldParam = self.NpcLookAtData[EntityID]
                AnimComp:SetLookAtParam(OldParam)
                self.NpcLookAtData[EntityID] = {}
            end
        end

        local Major = MajorUtil:GetMajor()
        if Major then
            local MajorComp = Major:GetAnimationComponent()
            local MajorLookAtTarget = _G.UE.FLookAtTarget()
            local MajorType = Target and _G.UE.ELookAtType.All or _G.UE.ELookAtType.None
            MajorLookAtTarget.Type = _G.UE.ELookAtTargetType.Actor
            MajorLookAtTarget.Target = Target and Actor or nil
            if MajorComp then
                local Param = _G.UE.FLookAtParams()
                Param.LookAtType = MajorType
                Param.Target = MajorLookAtTarget
                Param.bInterp = true
                MajorComp:SetLookAtParam(Param)
            end
        end
    end
end

--第一次设置npclookat需要存一次数据a
function NpcDialogMgr:SaveNpcLookAtParam(Actor)
    -- if Actor then
    --     local AnimComp = Actor:GetAnimationComponent()
    --     if not AnimComp then return end
    --     if not self.LookAtParams then
    --         self.LookAtParams = AnimComp:GetLookAtParam()
    --     end
    -- end
end

function NpcDialogMgr:DeleNpcLookaTParam()

end

function NpcDialogMgr:SetMajorCanMove(bCanMove)
    if not bCanMove then
        local ZeroVector = _G.UE.FVector(0, 0, 0)
        local MajorPlayer = MajorUtil.GetMajor()
        MajorPlayer:SetCharacterMove(ZeroVector, 0, true, false)
    end
end

function NpcDialogMgr:OnNPCFinishTurning(Params)
    -- if self.DialogState == NpcDialogState.WAITING_INTERACTION then
    --     local EntityID = Params.ULongParam1
    --     self:PlayDefaultDialog(EntityID)
    -- end
    local EntityID = Params.ULongParam1
    FLOG_INFO("Interactive OnNPCFinishTurning")
    if self.OnlyTurnWithNotDialog then
        self:SwitchIdleAnim(EntityID)
        if self.FnishTurnCallBack then
            self.FnishTurnCallBack()
            self.FnishTurnCallBack = nil
        end
        self.OnlyTurnWithNotDialog = false
        return
    end
    local ResID = ActorUtil.GetActorResID(EntityID)
    local NeedClick = self:ClickDoingTaskFunction()
    if NeedClick then 
        self:SwitchIdleAnim(EntityID)
        return 
    end

    if self.DialogState ~= NpcDialogState.END_QUEST_DIALOG then
        self.DialogState = NpcDialogState.START_DIALOG
    end

    if _G.QuestFaultTolerantMgr:CheckStartUnAcceptDialog(ResID) then
        -- 如果触发容错未接取对话
        self:SwitchIdleAnim(EntityID)
        return
    end

    local DefaultDialogID = self.PreDefaultDialogID or 0 --self:GetDefaultDialogID(ResID)
    if DefaultDialogID ~= 0 then
        -- 当有默认对白时 直接中断所有情感动作
        print("[emotion] play default dialog, stop all emotions")
        _G.EmotionMgr:SendStopEmotionAll()
    else
        -- 当默认对话被跳过，可能会导致Npc不进管理，这里塞一下
        self.DialogNpcTable[ResID] = {}
        self.DialogNpcTable[ResID].EntityID = EntityID
    end
    self:SwitchIdleAnim(EntityID)
    self:PlayDialogLib(DefaultDialogID, EntityID, true)
end

---检查是否拥有复数交互以及对话
---@param ResID number NpcID
function NpcDialogMgr:CheckHasComplexInteractiveID(ResID)
    local Cfg = NpcCfg:FindCfgByKey(ResID)
    --没有Npc配置直接返回
    if not Cfg then return false end 
    local CustomTalkIDList = self:GetCustomTalkIDList(ResID)
    local InteractiveIDList = Cfg.InteractiveIDList
    --检查是否拥有复数ID
    if CustomTalkIDList and #CustomTalkIDList >= 1 then
        if InteractiveIDList and #InteractiveIDList >= 1 and #CustomTalkIDList + #InteractiveIDList >= 2 then
            local FunItem = {}
            for i = 1, #InteractiveIDList do
                FunItem.FuncValue = InteractiveIDList[i]
                FunItem.EntityID = self.LastDialog.NpcEntityID
                FunItem.ResID = ResID
                if FunctionItemFactory:CreateInteractiveDescFunc(FunItem, true) ~= nil then
                    return true
                end
            end
            return false
        end
    end
    return false
end

function NpcDialogMgr:GetInteractionIDNum(IDList, ResID)
    local Num = 0
    if IDList and #IDList >= 1 then
        local FunItem = {}
        for i = 1, #IDList do
            FunItem.FuncValue = IDList[i]
            FunItem.EntityID = self.LastDialog.NpcEntityID
            FunItem.ResID = ResID
            if FunctionItemFactory:CreateInteractiveDescFunc(FunItem, true) ~= nil then
                Num = Num + 1
            end
        end
    end
    return Num
end

function NpcDialogMgr:GetDefaultDialogID(NpcResID)
    local DefaultDialogID = 0
    local Cfg = NpcCfg:FindCfgByKey(NpcResID)
    if not Cfg then return DefaultDialogID end
    local CustomTalkIDList = self:GetCustomTalkIDList(NpcResID)
    local InteractiveIDList = Cfg.InteractiveIDList
    local InteractiveIDNum = self:GetInteractionIDNum(InteractiveIDList, NpcResID)
    --有CustomTalk，则没有默认对话，只需要检查是否把CustomTalk放在前置对话
    if CustomTalkIDList and next(CustomTalkIDList) then
        --只有一条CustomTalkID,则CustomTalk为前置对话
        if #CustomTalkIDList == 1 and InteractiveIDNum == 0 then
            local OptionCfg = CustomDialogOptionCfg:FindCfgByKey(CustomTalkIDList[1])
            local FunctionList = _G.InteractiveMgr.CurInteractEntrance:GenFunctionList()
            if OptionCfg ~= nil and #FunctionList <= 2 then
                DefaultDialogID = self:GetDialogIDByCondition(OptionCfg.PreDialogID, OptionCfg.PreConditionID)
            end
        end
    --没有CustomTalk，只需要检查交互ID，按照原来逻辑走
    else
        --有复数交互ID或者没有交互ID才考虑前置对话
        if InteractiveIDNum > 1 or InteractiveIDNum == 0 then
            local Cfg = NpcCfg:FindCfgByKey(NpcResID)
            if Cfg == nil then return 0 end
            if Cfg.SwitchTalkID and Cfg.SwitchTalkID > 0 then
                DefaultDialogID = self:FindDeafalutIDBySwitchTalk(Cfg.SwitchTalkID)
            end
        end
    end

    return DefaultDialogID
end

function NpcDialogMgr:FindDeafalutIDBySwitchTalk(ID)
    if ID and ID > 0 then
        local num = #tostring(ID)
        if num < 7 then
            --默认对话，不处理，直接return原ID
            return ID
        else
            --SwitchTalk
            local SearchStr = string.format("SwitchTalkID = %d", ID)
            local Cfg = SwitchTalkCfg:FindAllCfg(SearchStr)
            local DefaultID = 0
            local FirstTalkID = 0
            if Cfg and next(Cfg) then
                table.sort(Cfg, function(a, b)
                    return a.Rank < b.Rank
                end)
                --升序判断
                local ComPleteIndex
                for _, value in pairs(Cfg) do
                    if value.Rank ~= 0 and (not ComPleteIndex or ComPleteIndex == value.Rank - 1)then
                        if value.QuestCompletedID and value.QuestCompletedID > 0 then
                            local Status = _G.QuestMgr:GetQuestStatus(value.QuestCompletedID)
                            if Status == QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
                                DefaultID = value.DialogLibID
                                ComPleteIndex = value.Rank
                            end
                        elseif value.QuestAcceptedID and value.QuestAcceptedID > 0 then
                            local Status = _G.QuestMgr:GetQuestStatus(value.QuestCompletedID)
                            if Status == QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS then
                                DefaultID = value.DialogLibID
                                ComPleteIndex = value.Rank
                            end
                        elseif value.PworldID and value.PworldID > 0 then
                            local ClearNum = _G.CounterMgr:GetCounterCurrValue(value.PworldID)
                            if ClearNum > 0 then
                                DefaultID = value.DialogLibID
                                ComPleteIndex = value.Rank
                            end
                        elseif not value.PworldID and not value.QuestAcceptedID and not value.QuestCompletedID then
                            DefaultID =  value.DialogLibID
                            ComPleteIndex = value.Rank
                        end
                    end
                    if value.Rank == 0 then
                        FirstTalkID = value.DialogLibID
                    end
                end
            end
            DefaultID = DefaultID == 0 and FirstTalkID or DefaultID
            return DefaultID
        end
    else
        return 0
    end
end

function NpcDialogMgr:GetDialogIDByCondition(ValueListStr, ConditionListStr, Splitter)
    local p = Splitter or ';'
    local ValueList = string.split(ValueListStr, p)
    local ConditionList = string.split(ConditionListStr, p)
    for i = 1,#ValueList do
        local Value = tonumber(ValueList[i])
        local Condition = tonumber(ConditionList[i])
        if ConditionList[i] == 0 or ConditionMgr:CheckConditionByID(Condition) then
            return Value
        end
    end
end

function NpcDialogMgr:GetCustomTalkIDList(NpcResID)
    local Cfg = NpcCfg:FindCfgByKey(NpcResID)
    if Cfg == nil then return 0 end
    if NpcResID == self.CachedCustomTalkResID then return self.CachedCustomTalkIDList end

    self.CachedCustomTalkResID = 0
    self.CachedCustomTalkIDList = {}
    for _, Str in ipairs(Cfg.CustomTalkIDList) do
        local Strs = string.split(Str, ';')
        if #Strs == 2 then
            local DialogID = tonumber(Strs[1])
            local ConditionID = tonumber(Strs[2])
            if ConditionMgr:CheckConditionByID(ConditionID) then
                table.insert(self.CachedCustomTalkIDList, DialogID)
            end
        elseif #Strs > 0 then
            self.CachedCustomTalkResID = NpcResID
            local DialogID = tonumber(Strs[1])
            table.insert(self.CachedCustomTalkIDList, DialogID)
        end
    end
    return self.CachedCustomTalkIDList
end

function NpcDialogMgr:ClickDoingTaskFunction(DoingTaskID)
    self.DialogState = NpcDialogState.FUNCTION

    if not _G.InteractiveMgr.CurInteractEntrance then
        return false
    end

    local FunctionList = _G.InteractiveMgr.CurInteractEntrance:GenFunctionList()
    --只有离开和一个任务的时候，直接触发任务的点击
    if #FunctionList <= 2 then
        local FunctionItem = FunctionList[1]
        if FunctionItem and FunctionItem.FuncType == LuaFuncType.QUEST_FUNC then
            if not FunctionList[1]:Click(true) then
                _G.EventMgr:SendEvent(EventID.ClickNextDialog)
            end
            return true
        end
    end

    return false
end

function NpcDialogMgr:OnGameEventFinishDialog(Params)
end

function NpcDialogMgr:CheckCharacterMovementSpeed()
    local Major = MajorUtil.GetMajor()
    if Major and Major.CharacterMovement then
        local Velocity = Major.CharacterMovement.Velocity
        if Velocity.Z ~= 0 then
            MsgTipsUtil.ShowErrorTips(_G.LSTR(1280012))
            return true
        elseif self.ResumeTimerTable and next(self.ResumeTimerTable) then
            MsgTipsUtil.ShowTips(_G.LSTR(1280013))
            return true
        end
    end
end

function NpcDialogMgr:CheckDistanceCanInteraction(EntranceNpcEntityID)
    --默认500距离,500距离外的Npc不做交互
    local DefaultDisTance = 600
    local Actor = ActorUtil.GetActorByEntityID(EntranceNpcEntityID)
    if Actor then
        local MajorActor = MajorUtil.GetMajor()
        local MajorPos = MajorActor:FGetActorLocation()
        local NPCPos = Actor:FGetActorLocation()
        local NpcDistance = math.sqrt(((NPCPos.X - MajorPos.X) ^ 2) + ((NPCPos.Y - MajorPos.Y) ^ 2) + ((NPCPos.Z - MajorPos.Z) ^ 2))
        if NpcDistance > DefaultDisTance then
            FLOG_ERROR("NpcDialogMgr:CheckDistanceCanInteraction DisTance Is Too Far, %s", debug.traceback())
            return false
        else
            return true
        end
    else
        --没有对应的Actor
        FLOG_ERROR("NpcDialogMgr:CheckDistanceCanInteraction Not Have Actor, %s", debug.traceback())
        return false
    end
end

function NpcDialogMgr:OnEnterInteractive(EntranceItem)
    self.LastMajorPos = nil
end

--点击一级npc交互的时候过来的
function NpcDialogMgr:BeginInteraction(EntranceNpc)
    if self:CheckCharacterMovementSpeed() or not self:CheckDistanceCanInteraction(EntranceNpc.EntityID) then
        InteractiveMgr:DelayShowEntrance(0.5)
        return 
    end
	CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.CommStatDialog, true)

    EffectUtil.SetIsInDialog(true)
    self.IsNeedResumeCamera = false
    self:SetMajorCanMove(false)
    if not self.MainPanel then
        self.MainPanel = _G.UIViewMgr:ShowView(_G.UIViewID.NpcDialogueMainPanel,{ViewType = StoryDefine.UIType.NpcDialog})
    end
    InteractiveMgr:OnEnterDialogue()

    local EntityID = EntranceNpc.EntityID
    _G.FLOG_INFO("Begin Interactive: "..EntityID)
    self.LastDialog.NpcEntityID = EntityID
    self.LastDialog.DialogLibID = 0

    local Major = MajorUtil.GetMajor()
    local AvatarCom = Major:GetAvatarComponent()
    if AvatarCom and not self.IsTempSetAvatarBack then
        -- 立刻收刀
        self.IsTempSetAvatarBack = true
        _G.EmotionMgr:SendStopEmotionAll()
    end

    self.IsSkipInteractiveUIAfterDialog = false

    --预先计算
    self.PreDefaultDialogID = self:GetDefaultDialogID(EntranceNpc.ResID)

    local Cfg = NpcCfg:FindCfgByKey(EntranceNpc.ResID)
    local ConfigID = Cfg == nil and 0 or Cfg.InteractionCamera
    --隐藏头顶信息
    if not self.HudHideState then
        FLOG_INFO("DialogMgr:HideHUD")
        _G.HUDMgr:SetIsDrawHUD(false)
        self.HudHideState = true
    end
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    local AnimCom = Actor:GetAnimationComponent()
    self:SavePreIdelAnimKey(EntranceNpc.ResID, AnimCom)
    if Actor ~= nil and Actor.BeginInteraction ~= nil then
        if Actor.IsTurning and Actor:IsTurning() and Actor:StopTurning() then
            Actor:StopTurning()
        end
        local ActorType = ActorUtil.GetActorType(EntityID)
        if ActorType and ActorType == _G.UE.EActorType.Npc then
            Actor:BeginInteraction(ConfigID == nil or ConfigID >= 20000 or ConfigID < 10)
        end
    elseif Actor == nil then
        _G.FLOG_ERROR("[DialogMgr] BeginInteractive Dialog Actor is Nil")
        self:EndInteraction()
        return
    end
    _G.FLOG_INFO("Begin Interactive DialogState: %d", self.DialogState)
    
    --任务Cut/对话存在的时候，npc对话结束，连交互都结束了  == NO_DIALOG
    if self.DialogState == NpcDialogState.END_DIALOG or 
        not _G.InteractiveMgr.bLockTimer then
        self.PreDefaultDialogID = 0
        _G.FLOG_INFO("Interactive is end")
        return
    end
    
    local bSwitchCamera = false
    if self.PreDefaultDialogID == 0 then
        local FunctionList = EntranceNpc:GenFunctionList()
        local FunctionNum = #FunctionList
        FLOG_INFO("Interactive FunctionNum:%d", FunctionNum)
        if FunctionNum > 2 then
            bSwitchCamera = true
        elseif FunctionNum > 0 then
            local FirstType = FunctionList[1].FuncType
            if FirstType ~= LuaFuncType.QUIT_FUNC and FirstType ~= LuaFuncType.NPCQUIT_FUNC then
                if FirstType == LuaFuncType.QUEST_FUNC then
                    local ID = FunctionList[1].FuncParams.QuestParams.DialogOrSequenceID
                    local DialogType = QuestDefine.GetDialogueType(ID)
                    FLOG_INFO("Interactive QuestDialogIDOrSeqID:%d, Type:%d", ID, DialogType)
                    if DialogType == QuestDefine.DialogueType.NpcDialog then
                        bSwitchCamera = true
                    end
                end
            end
        end
    else
        bSwitchCamera = true
    end

    Major:DoClientModeEnter()
    if bSwitchCamera and Cfg and Cfg.InteractionCamera ~= nil and Cfg.InteractionCamera > 0 and Major and Actor then
        self.IsNeedResumeCamera = true
        if Cfg.InteractionCamera == 1 then
            ConfigID = self:GetCameraConfigID(EntityID)
        end

        FLOG_INFO("Interactive InteractionCamera:%d", ConfigID)
        -----------
        -- local ActorRotation = Actor:FGetActorRotation()
        -- local ActorForward = ActorRotation:GetForwardVector()

        local NpcPos = Actor:FGetActorLocation()
        self.LastMajorPos = Major:FGetActorLocation()
        -- FLOG_INFO("=====pcw LastMajoPos :%s", tostring(self.LastMajorPos))
        local Distance = _G.UE.FVector.Dist(self.LastMajorPos, NpcPos)
        if Distance < MajorValidDistance then
            local MajorPos2 = self:GetMajorBackPos(Actor, NpcPos, Major, Distance)
            if MajorPos2 then
                Major:K2_SetActorLocation(MajorPos2, false, nil, false)
            else
                self.LastMajorPos = nil
            end
        else
            self.LastMajorPos = nil
        end
        -----------
        local ChageViewRlt, ConfigKeyID = self:ChangeView(ConfigID)
        if ChageViewRlt == nil then
            self.IsNeedResumeCamera = false
            FLOG_ERROR("Interactive ChageViewRlt failed")
            if self.LastMajorPos then
                Major:K2_SetActorLocation(self.LastMajorPos, false, nil, false)
            end
        else
            self:OnEnterDialogCamera(EntityID, ConfigKeyID)
        end
    end
end

function NpcDialogMgr:GetMajorBackPos(NpcActor, NpcPos, Major, Distance)
    local MajorSvrPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
    local NpcSvrPos = NpcActor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
    local MajorToTarget = MajorSvrPos - NpcSvrPos
    MajorToTarget.Z = 0

    _G.UE.FVector.Normalize(MajorToTarget)
    local MajorPos2 = MajorSvrPos + MajorToTarget * (MajorValidDistance - Distance)
    MajorPos2.Z = MajorPos2.Z + 100
    local GroudPos, GroundValid = _G.PWorldMgr:GetGroudPosByLineTrace(MajorPos2, 1000, true)
    if not GroundValid then
        return nil
    end
    local TestPos = MajorSvrPos + MajorToTarget * (MajorCameraValidDistance - Distance)
    TestPos.Z = TestPos.Z + 78
    if ActorUtil.CheckPawnBlockByPos(NpcPos, TestPos) then
        if math.abs(MajorSvrPos.Z - GroudPos.Z) > 80 then
            return nil
        end

        MajorPos2.Z = GroudPos.Z + Major:GetCapsuleHalfHeight()
        local Radus = Major:GetCapsuleRadius()

        local function CheckPos(UpDir)
            local Pos = MajorToTarget:Cross(UpDir)
            _G.UE.FVector.Normalize(Pos)

            local CheckPos = MajorPos2 + Pos * Radus
            CheckPos.Z = CheckPos.Z - 30
            if ActorUtil.CheckPawnBlockByPos(NpcPos, CheckPos) then
                return true
            end

            return false
        end

        --这个点的左右也各检测一次，因为胶囊体有个范围，会造成主角TestPos在坛子这种阻挡的时候，主角会掉落
        if not CheckPos(_G.UE.FVector(0, 0, 1)) then
            return nil
        end

        if not CheckPos(_G.UE.FVector(0, 0, -1)) then
            return nil
        end
        MajorPos2.Z = MajorPos2.Z + (MIN_FLOOR_DIST + MAX_FLOOR_DIST) * 0.5
        return MajorPos2
    end

    return nil
end

--二级交互直接进来的切换镜头
--Param包含NpcResID,Eid以及FuncType
function NpcDialogMgr:OnlySwitchCameraOrTurn(Param, WithOutSwithCamera, CallBack)
    self.IsNeedResumeCamera = false
    if self:CheckCharacterMovementSpeed() or not self:CheckDistanceCanInteraction(Param.EntityID) then
        InteractiveMgr:DelayShowEntrance(0.5)
        return 
    end
	CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.CommStatDialog, true)

    self:SetMajorCanMove(false)
    InteractiveMgr:OnEnterDialogue()
    --这里需要先显示对话面板，用UI互斥隐藏主界面
    if not self.MainPanel then
        self.MainPanel = _G.UIViewMgr:ShowView(_G.UIViewID.NpcDialogueMainPanel,{ViewType = StoryDefine.UIType.NpcDialog})
    end
    self.OnlyTurnWithNotDialog = true
    local EntityID = Param.EntityID
    self.LastDialog.NpcEntityID = EntityID
    self.LastDialog.DialogLibID = 0

    local Major = MajorUtil.GetMajor()
    local AvatarCom = Major:GetAvatarComponent()
    if AvatarCom and not self.IsTempSetAvatarBack then
        -- 立刻收刀
        self.IsTempSetAvatarBack = true
        _G.EmotionMgr:SendStopEmotionAll()
    end

    --npc转向
    local Cfg = NpcCfg:FindCfgByKey(Param.ResID)
    local ConfigID = Cfg == nil and 0 or Cfg.InteractionCamera

    --隐藏头顶信息
    if not self.HudHideState then
        FLOG_INFO("DialogMgr:HideHUD")
        _G.HUDMgr:SetIsDrawHUD(false)
        self.HudHideState = true
    end
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    local AnimCom = Actor:GetAnimationComponent()
    self:SavePreIdelAnimKey(Param.ResID, AnimCom)
    if Actor ~= nil then
        --这里要重设转身回调函数，结束交互的时候清理一下
        self.FnishTurnCallBack = CallBack
        if Actor.IsTurning and Actor:IsTurning() and Actor:StopTurning() then
            Actor:StopTurning()
        end
        local ActorType = ActorUtil.GetActorType(EntityID)
        if ActorType and ActorType == _G.UE.EActorType.Npc then
            Actor:BeginInteraction(ConfigID == nil or ConfigID >= 20000 or ConfigID < 10)
        end
    else
        _G.FLOG_ERROR("[DialogMgr] OnlySwitchCameraOrTurn Dialog Actor is Nil")
        self:EndInteraction()
        return
    end

    if WithOutSwithCamera then
        _G.InteractiveMgr:EnterInteractive()
        return
    end
    self.IsSkipInteractiveUIAfterDialog = false
    _G.InteractiveMgr:EnterInteractive()

    _G.FLOG_INFO("Begin Interactive: "..EntityID)
    if Cfg and Cfg.InteractionCamera ~= nil and Cfg.InteractionCamera > 0 and Major and Actor then
        self.IsNeedResumeCamera = true
        if Cfg.InteractionCamera == 1 then
            ConfigID = self:GetCameraConfigID(EntityID)
        end

        FLOG_INFO("NpcDialogMgr OnlySwitchCameraOrTurn:%d", ConfigID)
        local NpcPos = Actor:FGetActorLocation()
        self.LastMajorPos = Major:FGetActorLocation()
        local Distance = _G.UE.FVector.Dist(self.LastMajorPos, NpcPos)
        if Distance < MajorValidDistance then
            local MajorPos2 = self:GetMajorBackPos(Actor, NpcPos, Major, Distance)
            if MajorPos2 then
                -- FLOG_INFO("pcw MajorPos2 :%s", tostring(GroudPos))
                Major:DoClientModeEnter()
                Major:K2_SetActorLocation(MajorPos2, false, nil, false)
            else
                self.LastMajorPos = nil
            end
        else
            self.LastMajorPos = nil
        end
        -----------
        local ChageViewRlt, ConfigKeyID = self:ChangeView(ConfigID)
        if ChageViewRlt == nil then
            self.IsNeedResumeCamera = false
            if self.LastMajorPos then
                Major:K2_SetActorLocation(self.LastMajorPos, false, nil, false)
            end
        else
            self:OnEnterDialogCamera(EntityID, ConfigKeyID)
        end
    end
end

function NpcDialogMgr:CheckNeedEndInteraction()
    if _G.InteractiveMgr.bLockTimer then
        self:EndInteraction()
    end
end

function NpcDialogMgr:OnDialogNpcDestory(EntityID)
    if _G.InteractiveMgr.bLockTimer and EntityID == self.LastDialog.NpcEntityID then
        self:EndInteraction()
    end
end

function NpcDialogMgr:OnEmotionPanelClose(TargetID)
    if TargetID then
        self:CheckNeedEndInteraction()
    end
end

function NpcDialogMgr:OnEnterDialogCamera(NpcEntityID, CameraConfigKeyID)
    local IsHideMajor = false
    local IsHideOtherNpc = false

    _G.UE.UWorldMgr:Get():DisableVolumeUpdate(true)
    _G.UE.UVisionMgr.Get():PauseActorEnterShow()
    _G.CompanionMgr:HideAllCompanion(true)

    if CameraConfigKeyID then
        local Cfg = NpcDialogCameraCfg:FindCfgByKey(CameraConfigKeyID)
        if Cfg then
            if Cfg.IsHideMajor == 1 then
                IsHideMajor = true
            end

            if Cfg.IsHideOtherNpc == 1 then
                IsHideOtherNpc = true
            end
        end
    end

    local ExcludeActorTypes = _G.UE.TArray(_G.UE.uint8)
    local ExcludeActorID = _G.UE.TArray(_G.UE.uint64)

    if _G.StoryMgr:SequenceIsPlaying() then
        IsHideMajor = false
        IsHideOtherNpc = false
    end
    
    ExcludeActorID:Add(NpcEntityID)

    if not IsHideMajor then
        ExcludeActorTypes:Add(_G.UE.EActorType.Major)
    end

    if not IsHideOtherNpc then
        ExcludeActorTypes:Add(_G.UE.EActorType.Npc)
    end
    ExcludeActorTypes:Add(_G.UE.EActorType.EObj)

    _G.UE.UActorManager:Get():HideAllActors(true, ExcludeActorID, ExcludeActorTypes)

    if not IsHideMajor then
        -- _G.UE.UActorManager:Get():HideMajor(false)
        local Major = MajorUtil.GetMajor()
        if Major then
            Major:SetActorHiddenInGame(false)
        end
    end
    
    --上次隐藏，并且这次不隐藏的才重新显示下所有npc
    if self.LastIsHideOtherNpc and not IsHideOtherNpc then
        _G.UE.UActorManager:Get():HideAllNpc(false)
    end

    self.LastIsHideOtherNpc = IsHideOtherNpc

    local SelectedTarget = _G.SelectTargetMgr:GetCurrSelectedTarget()
    if SelectedTarget then
		local AttrComp = SelectedTarget:GetAttributeComponent()
        if AttrComp then 
            self.LastSelectedTargetID = AttrComp.EntityID
            _G.UE.USelectEffectMgr:Get():UnSelectActor(AttrComp.EntityID)
        end
    end

    _G.NaviDecalMgr:SetNavPathHiddenInGame(true)
    _G.NaviDecalMgr:DisableTick(true)

    _G.SpeechBubbleMgr:ShowSpeechBubbleAll(false)
    -- local Actor = ActorUtil.GetActorByEntityID(NpcEntityID)
    -- local TargetType = Actor:GetActorType()
    -- if TargetType == _G.UE.EActorType.Npc then
    --     Actor:UseAnimLookAt(not IsHideMajor)
    -- end
    return IsHideMajor
end

function NpcDialogMgr:CheckNeedNpcLookAt(CameraConfigKeyID)
    local IsHideMajor = false

    if CameraConfigKeyID then
        local Cfg = NpcDialogCameraCfg:FindCfgByKey(CameraConfigKeyID)
        if Cfg then
            if Cfg.IsHideMajor == 1 then
                IsHideMajor = true
            end
        end
    end

    if _G.StoryMgr:SequenceIsPlaying() then
        IsHideMajor = false
    end

    return IsHideMajor
end

function NpcDialogMgr:GetCameraConfigID(EntityID)
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    local Major = MajorUtil.GetMajor()
    local Camera = Major:GetCameraControllComponent()

    local ConfigID = 0
    if Actor ~= nil and Major ~= nil and Camera ~= nil then
        local MajorRotation = Major:FGetActorRotation()
        local MajorForward = MajorRotation:GetForwardVector()

        local CameraPos = nil
        local CameraComponent = Camera:GetTopDownCameraComponent()
        if CameraComponent then
            CameraPos = CameraComponent:K2_GetComponentLocation()
        else
            return ConfigID
        end


        local MajorToTarget = Major:FGetActorLocation() - Actor:FGetActorLocation()
        local MajorToCamera = Major:FGetActorLocation() - CameraPos

        local CameraRotation = Major:GetCameraBoomRelativeRotation()
        local CameraForward = CameraRotation:GetForwardVector()
        
        -- local CameraRight = CameraRotation:GetRightVector()
        local CrossRlt = MajorToTarget:Cross(MajorToCamera)
        if MajorForward:Dot(CameraForward) >= 0 then    --背向相机
            if CrossRlt.Z <= 0 then  ----居右背视
                ConfigID = 30000
                -- print("pcw 居右背视")
            else    --居左背视
                ConfigID = 20000
                -- print("pcw 居左背视")
            end
        else    --正视相机
            if CrossRlt.Z <= 0 then  ----居右正视
                ConfigID = 30001
                -- print("pcw 居右正视")
            else    --居左正视
                ConfigID = 20001
                -- print("pcw 居左背视")
            end
        end
    end

    return ConfigID
end

function NpcDialogMgr:ResumeCamera()
    self.LastIsHideOtherNpc = nil

    local Major = MajorUtil.GetMajor()
    _G.UE.UWorldMgr:Get():DisableVolumeUpdate(false)

    if self.IsNeedResumeCamera then
        self.IsNeedResumeCamera = false
        FLOG_INFO("Interactive ResumeCamera")

        if self.LastMajorPos and Major then
            local MajorPos = Major:FGetActorLocation()
            local Distance = _G.UE.FVector.Dist(self.LastMajorPos, MajorPos)
            if Distance < MajorValidDistance + 50 then
                -- FLOG_INFO("=====pcw Restor MajoPos :%s", tostring(self.LastMajorPos))
                Major:K2_SetActorLocation(self.LastMajorPos, false, nil, false)
            else
                FLOG_ERROR("LastMajorPos is too far:%.2f", Distance)
            end
        end
        self.LastMajorPos = nil

        if self.LastSelectedTargetID then
            _G.SwitchTarget:ManualSwitchToTarget(self.LastSelectedTargetID, true)
            self.LastSelectedTargetID = nil
        end
        
        _G.NaviDecalMgr:SetNavPathHiddenInGame(true)
        _G.NaviDecalMgr:DisableTick(false)
        
        _G.UE.UActorManager:Get():HideAllActors(false
            , _G.UE.TArray(_G.UE.uint64), _G.UE.TArray(_G.UE.uint8))
        _G.SpeechBubbleMgr:ShowSpeechBubbleAll(true)
    end
    if Major then
        Major:DoClientModeExit()
        print("[NpcDialogMgr]ResumeCamera:DoClientModeExit")
        local MajorIsShow = Major:GetActorVisibility()
        Major:SetActorHiddenInGame(not MajorIsShow)
    end
end

--
function NpcDialogMgr:PreEndInteraction()
    if self.MainPanel then
        self.MainPanel:ClearAllTimer()
    end
    if _G.InteractiveMgr.bLockTimer then
        _G.LuaCameraMgr:ResumeCamera(false)
    else
        FLOG_INFO("[NpcDialogMgr] Play Seq Not In Dialog")
    end
    --空表的情况下，说明从对话进入了，但是没有过对话流程进了seq
    local State = CommonStateUtil.IsInState(ProtoCommon.CommStatID.CommStatDialog)
    if State and (not self.DialogNpcTable or not next(self.DialogNpcTable)) then
        local ResID = ActorUtil.GetActorResID(self.LastDialog.NpcEntityID)
        self.DialogNpcTable = {}
        self.DialogNpcTable[ResID] = {}
        --有动作也结束一下再进cut
        self:SwitchIdleAnim(self.LastDialog.NpcEntityID)
        self.DialogNpcTable[ResID].EntityID = self.LastDialog.NpcEntityID
    end
end

--所有对话、交互都没了过来的
function NpcDialogMgr:EndInteraction(ClearQuestData)
	CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.CommStatDialog, false)
    self.IsSkipInteractiveUIAfterDialog = false
    self.LastCameraConfigID = 0
    self.LastConfigKeyID = 0
    self.FnishTurnCallBack = nil
    self.IsTempSetAvatarBack = false
    _G.FLOG_INFO("End Interactive")
    self.bIsSetMove = false
    --解除禁止移动
    self:SetMajorCanMove(true)
    --解除特效屏蔽
    EffectUtil.SetIsInDialog(false)
    self:RsetActorAnimation()

    self.DialogState = NpcDialogState.NO_DIALOG

    InteractiveMgr:ExitInteractive()
    InteractiveMgr:OnExitDialogue()
    _G.UE.UVisionMgr.Get():ResumeActorEnterShow()
    _G.CompanionMgr:HideAllCompanion(false)
    --恢复镜头放外面，不管进不进镜头都调用一次
    _G.LuaCameraMgr:ResumeCamera(false)
    if self.HudHideState then
        FLOG_INFO("DialogMgr:ShowHUD")
        _G.HUDMgr:SetIsDrawHUD(true)
        self.HudHideState = false
    end
    if self.IsNeedResumeCamera then
        self:ResumeCamera()
    end

	_G.LuaCameraMgr:UpdateAmbientOcclusionParam(false)

    -- 隐藏对话框，显示一级交互列表
    if self.MainPanel then
        self.MainPanel:ClearAllTimer()
        self.MainPanel:HideDialog()
    end
	-- 任务自动对话需求，避免两组对话之间主界面突然显示又隐藏
    -- if self.DelayMainPanelTimer ~= nil then
    --     _G.TimerMgr:CancelTimer(self.DelayMainPanelTimer)
    -- end
	-- self.DelayMainPanelTimer = _G.TimerMgr:AddTimer(nil, function()
	-- 	_G.BusinessUIMgr:ShowMainPanel(_G.UIViewID.MainPanel,true)
    --     self.DelayMainPanelTimer = nil
	-- end, 0.2, 0, 1)
    _G.UIViewMgr:HideView(_G.UIViewID.DialogHistoryLow)
    _G.UIViewMgr:HideView(_G.UIViewID.NpcDialogueMainPanel)
    self.MainPanel = nil
    self.LastDialog.Callback = nil
    NpcDialogVM:DialogBranchStartOrEnd(false)
    NpcDialogVM:SetDialogBranchVisible(false)
    NpcDialogVM.BranchCfg = nil
    self.DialogLibID = nil
    if not _G.StoryMgr:SequenceIsPlaying() then -- 防止断线重连影响sequence数据
        NpcDialogHistoryVM:ClearHistoryData(ClearQuestData)
    end
    if not _G.MountMgr:IsRequestingMount() then
        InteractiveMgr:DelayShowEntrance(0.3)
    end
end

function NpcDialogMgr:RsetActorAnimation()
    --兜底构造一个NpcTable,上次结束交互的Npc
    if not self.DialogNpcTable or not next(self.DialogNpcTable) then
        local ResID = ActorUtil.GetActorResID(self.LastDialog.NpcEntityID)
        self.DialogNpcTable = {}
        self.DialogNpcTable[ResID] = {}
        self.DialogNpcTable[ResID].EntityID = self.LastDialog.NpcEntityID
    end
    for _, data in pairs(self.DialogNpcTable) do
        if data.EntityID and data.EntityID ~= 0 then
            local EntityID = data.EntityID
            local ResID = ActorUtil.GetActorResID(EntityID)
            local Actor = ActorUtil.GetActorByEntityID(data.EntityID)
            if Actor and Actor.EndInteraction ~= nil and Actor:IsInInteraction() then
                if self.NpcLookAtData and next(self.NpcLookAtData) then
                    self:SetNpcLookAt(Actor, nil, EntityID)
                end
                local Cfg = NpcCfg:FindCfgByKey(ResID)
                local AnimCom = Actor:GetAnimationComponent()
                if AnimCom then
                    self:UnRegisterTimer(self["IdleTimer"..tostring(EntityID)])
                    self:UnRegisterTimer(self["PlayAnimtionCallBack"..tostring(EntityID)])
                    self["IdleTimer"..tostring(EntityID)] = nil
                    self["PlayAnimtionCallBack"..tostring(EntityID)] = nil
                    local IdelTimeline = AnimCom:GetIdleActionTimeline()
                    if Cfg and next(Cfg) and Cfg.IdleTimeline ~= IdelTimeline and IdelTimeline ~= 0 then
                        local NewTimeline
                        if self.ActorPreIdelAnimKeyTable[ResID] and self.ActorPreIdelAnimKeyTable[ResID] ~= 0 then
                            NewTimeline = self.ActorPreIdelAnimKeyTable[ResID]
                            self:GetEndInteracticeAnimation(IdelTimeline, NewTimeline, AnimCom, Actor, EntityID)
                        else
                            NewTimeline = Cfg.IdleTimeline
                            self:GetEndInteracticeAnimation(IdelTimeline, NewTimeline, AnimCom, Actor, EntityID)
                        end
                    end
                    if data.LastSpeakMontage and data.LastSpeakMontage:IsValid() then
                        AnimCom:StopMontage(data.LastSpeakMontage)
                        data.LastSpeakMontage = nil
                    end
                end
                if Actor.IsTurning and Actor:IsTurning() and Actor.ForceAbortTurning then
                    Actor:ForceAbortTurning()
                end
                if data.PlayingAnim and data.PlayingAnim:IsValid() then
                    AnimCom:StopMontage(data.PlayingAnim)
                    data.PlayingAnim = nil
                end
                if data.ExcessiveAnim and data.ExcessiveAnim:IsValid() then
                    AnimCom:StopMontage(data.ExcessiveAnim)
                    data.ExcessiveAnim = nil
                end
                Actor:EndInteraction()
            end
        end
    end
    self.ActorPreIdelAnimKeyTable = {}
    self.DialogNpcTable = {}
    self.NpcLookAtData = {}
end

function NpcDialogMgr:PlayDialogAnim(EntityID, AnimPath)
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if not Actor then return end

    local AnimCom = Actor:GetAnimationComponent()
    if not AnimCom then
        return
    end

    local ResID = ActorUtil.GetActorResID(EntityID)
    self:SavePreIdelAnimKey(ResID, AnimCom)

    if not AnimPath or #AnimPath == 0 then
        -- 无对话动画情况
        self:SwitchIdleAnim(EntityID)
        return
    end

    --获取蒙太奇播放时间
    local AnimationAssetPath = self:GetTimelinePath(AnimPath)
    if not AnimationAssetPath or #AnimationAssetPath == 0 then
        return
    end

    local SlotName = AnimCom:GetMontageSlotName(AnimationAssetPath)
    --上半身，脸，加算动作维持待机状态，否则混合站立
    local DelayTime = 0
    --如果不是默认站姿状态，需要过度动画
    local IdelTimeline = AnimCom:GetIdleActionTimeline()
    if IdelTimeline ~= 0 then
        --slot是face Upperbody和addtive的时候，切换承站姿
        if SlotName == "Face" or SlotName == "UpperBody" or SlotName == "Additive_Body" then
            self:SwitchIdleAnim(EntityID)
        --全身动作，需要考虑过渡动作
        elseif SlotName == "WholeBody" then
            local CurrentStance = _G.AnimMgr:GetActionTimeLineStance(IdelTimeline)
            local TargetStance = self:GetTimelineStance(AnimPath)
            local NextStanceStr = self:AnalyzeNextStanceTimeline(CurrentStance,TargetStance)
            local Key = self:GetStanceBaseIdleKey(TargetStance)
            
            --判断一次是否需要重设待机动作,根据是否需要过渡动作决定是否延迟修改待机
            local CallBack = function()
                if Key > 0 and IdelTimeline ~= Key then
                    FLOG_INFO("[SetIdleActionTimeline]NpcDialogMgr:PlayDialogAnim  TargetStance = %s,Key = %s", tostring(TargetStance),tostring(Key))
                    AnimCom:SetIdleActionTimeline(Key)
                    --因为多人对话需求，这里Timer命名修改规则为 IdelTime+EID
                    self["IdleTimer"..tostring(EntityID)] = nil
                end
            end 
            --需要过渡动作，直接播放过度动作
            if NextStanceStr ~= nil and #NextStanceStr > 0 and self["IdleTimer"..tostring(EntityID)] == nil then
                local ExcessiveAnimationPath = AnimCom:GetActionTimeline(NextStanceStr)
                local ExcessiveAnimation = _G.ObjectMgr:LoadObjectSync(ExcessiveAnimationPath, ObjectGCType.NoCache)
                local Montage = Actor:CheckActionTimelineMontage(ExcessiveAnimation, "WholeBody", 0, 0, 99999)
                DelayTime = AnimationUtil.GetAnimMontageLength(Montage)
                local ExcessiveAnim =AnimCom:PlayAnimation(ExcessiveAnimationPath, 1, 0)
                self.DialogNpcTable[ResID].ExcessiveAnim = ExcessiveAnim
            end
            local IdelDelayTime = 0
            if DelayTime then
                IdelDelayTime = DelayTime * 0.7
            end
            self["IdleTimer"..tostring(EntityID)] = self:RegisterTimer(CallBack, IdelDelayTime, 0 , 1)
        else
            local CurrentStance = _G.AnimMgr:GetActionTimeLineStance(IdelTimeline)
            local TargetStance = self:GetTimelineStance(AnimPath)
            local NextStanceStr = self:AnalyzeNextStanceTimeline(CurrentStance,TargetStance)
            local Key = self:GetStanceBaseIdleKey(0)

            local CallBack = function() 
                if IdelTimeline ~= Key then
                    FLOG_INFO("[SetIdleActionTimeline]NpcDialogMgr:PlayDialogAnim TimeLineBaseDefine.BaseIdel")
                    AnimCom:SetIdleActionTimeline(Key)
                    self["IdleTimer"..tostring(EntityID)] = nil
                end
            end
            --需要过渡动作，直接播放过度动作
            if NextStanceStr ~= nil and #NextStanceStr > 0 and self["IdleTimer"..tostring(EntityID)] == nil then
                local ExcessiveAnimationPath = AnimCom:GetActionTimeline(NextStanceStr)
                local ExcessiveAnimation = _G.ObjectMgr:LoadObjectSync(ExcessiveAnimationPath, ObjectGCType.NoCache)
                local Montage = Actor:CheckActionTimelineMontage(ExcessiveAnimation, "WholeBody", 0, 0, 99999)
                DelayTime = AnimationUtil.GetAnimMontageLength(Montage)
                local ExcessiveAnim = AnimCom:PlayAnimation(ExcessiveAnimationPath, 1, 0)
                self.DialogNpcTable[ResID].ExcessiveAnim = ExcessiveAnim
            end
            local IdelDelayTime = 0
            if DelayTime then
                IdelDelayTime = DelayTime * 0.7
            end
            self["IdleTimer"..tostring(EntityID)] = self:RegisterTimer(CallBack, IdelDelayTime, 0 , 1)
        end
    end
    local AnimCallBack = function()
        FLOG_INFO("[TimerCallBack]NpcDialogMgr:PlayDialogAnim"..tostring(AnimationAssetPath))
        local PlayingAnim = AnimCom:PlayAnimation(AnimationAssetPath, 1, 0)
        self.DialogNpcTable[ResID].PlayingAnim = PlayingAnim
    end
    if DelayTime == 0 then
        FLOG_INFO("[WithOutTimer]NpcDialogMgr:PlayDialogAnim"..tostring(AnimationAssetPath))
        self:UnRegisterTimer(self["PlayAnimtionCallBack"..tostring(EntityID)])
        self["PlayAnimtionCallBack"..tostring(EntityID)] = nil
        local PlayingAnim = AnimCom:PlayAnimation(AnimationAssetPath, 1, 0.15)
        self.DialogNpcTable[ResID].PlayingAnim = PlayingAnim
    else
        FLOG_INFO("[WithTimer]NpcDialogMgr:PlayDialogAnim"..tostring(AnimationAssetPath))
        self["PlayAnimtionCallBack"..tostring(EntityID)] = self:RegisterTimer(AnimCallBack, DelayTime + 0.1, 0 , 1)
    end
end

function NpcDialogMgr:SavePreIdelAnimKey(ResID, Comp)
    if self.ActorPreIdelAnimKeyTable[ResID] or not Comp then
        return
    end
    local IdleTimelineKey = Comp:GetIdleActionTimeline()
    self.ActorPreIdelAnimKeyTable[ResID] = IdleTimelineKey
end

function NpcDialogMgr:SwitchIdleAnim(EntityID)
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if not Actor then 
        return 
    end
    local AnimCom = Actor:GetAnimationComponent()
    if not AnimCom then
        return
    end
    local ResID = ActorUtil.GetActorResID(EntityID)
    local Cfg = NpcCfg:FindCfgByKey(ResID)
    -- 配置了原地转身
    if Cfg and Cfg.InteractionWithTurning == 1 then
        local SearchCondition =  string.format("Label = \"%s\"", TimeLineBaseDefine.BaseIdel)
        local ActiontimelineCfg = ActiontimelinePathCfg:FindCfg(SearchCondition)
        local Key = ActiontimelineCfg.Key
        AnimCom:SetIdleActionTimeline(Key)
    end
end

function NpcDialogMgr:GetExcessiveAnimation(IdelTimeline, AnimDefine, AttachType)
    if IdelTimeline == 0 then return 0 end
    local Key = 0
    local Condition
    Condition = string.format("Key = \"%s\"", IdelTimeline)
    local ActiontimelineCfg = ActiontimelinePathCfg:FindCfg(Condition)
    local Label = ActiontimelineCfg and ActiontimelineCfg.Label or ""
    if Label and Label ~= "" then
        if string.find(Label, "CHAIR") and AnimDefine ~= TimeLineBaseDefine.BaseChair then
            Key = Key ~= ExcessiveTimeLineDefine.EVENT_BASE_CHAIR_END and ExcessiveTimeLineDefine.EVENT_BASE_CHAIR_END or 0
        elseif string.find(Label, "GROUND") and AnimDefine ~= TimeLineBaseDefine.BaseGround then
            if Label == "EVENT_BASE_GROUND_SIT" and AttachType == "c1201" then
                Key = 0
            else
                Key = Key ~= ExcessiveTimeLineDefine.EVENT_BASE_GROUND_END and ExcessiveTimeLineDefine.EVENT_BASE_GROUND_END or 0
            end
        elseif Label == "EVENT_BASE_KNEE_SUFFERING" then
            Key = ExcessiveTimeLineDefine.EVENT_BASE_CHAIR_END
        end
    end
    return Key
end

function NpcDialogMgr:GetStanceBaseIdleKey(InStance)
    local AnimDefine = TimeLineBaseDefine.BaseIdel
    if InStance == StanceTypeDefine.NORMAL_SIT_CHAIR or InStance == StanceTypeDefine.SPECIAL_SIT_CHAIR or InStance == StanceTypeDefine.SIT_CHAIR_ONLY  then
        AnimDefine =  TimeLineBaseDefine.BaseChair
    elseif InStance == StanceTypeDefine.NORMAL_SIT_GROUND or InStance == StanceTypeDefine.SPECIAL_SIT_GROUND or InStance == StanceTypeDefine.SIT_GROUND_ONLY  then
        AnimDefine = TimeLineBaseDefine.BaseGround
    end
    local SearchCondition = string.format("Label = \"%s\"", AnimDefine)
    local ActiontimelineCfg = ActiontimelinePathCfg:FindCfg(SearchCondition)
    local Key = 0
    if ActiontimelineCfg then
        Key = ActiontimelineCfg.Key
    end
    return Key
end

function NpcDialogMgr:AnalyzeNextStanceTimeline(InCurrentStance,IntargetStance)
    local NextStanceTimeline = ""
    -- 站立
    if InCurrentStance == StanceTypeDefine.NORMAL_STAND or  InCurrentStance == StanceTypeDefine.SPECIAL_STAND or InCurrentStance == StanceTypeDefine.STAND_ONLY then
        if IntargetStance == StanceTypeDefine.NORMAL_SIT_GROUND or IntargetStance == StanceTypeDefine.SPECIAL_SIT_GROUND or IntargetStance == StanceTypeDefine.SIT_CHAIR_ONLY then
            NextStanceTimeline = "event_base/event_base_ground_start"
        elseif IntargetStance == StanceTypeDefine.NORMAL_SIT_CHAIR or IntargetStance == StanceTypeDefine.SPECIAL_SIT_CHAIR or IntargetStance == StanceTypeDefine.SIT_CHAIR_ONLY then
            NextStanceTimeline = "event_base/event_base_chair_start"
        end
    -- 椅子坐
    elseif  InCurrentStance == StanceTypeDefine.NORMAL_SIT_CHAIR or InCurrentStance == StanceTypeDefine.SPECIAL_SIT_CHAIR or InCurrentStance == StanceTypeDefine.SIT_CHAIR_ONLY  then
        if IntargetStance == StanceTypeDefine.NORMAL_STAND or IntargetStance == StanceTypeDefine.SPECIAL_STAND or IntargetStance == StanceTypeDefine.STAND_ONLY then
            NextStanceTimeline = "event_base/event_base_chair_end"
        end
    -- 地面坐
    elseif  InCurrentStance == StanceTypeDefine.NORMAL_SIT_GROUND or InCurrentStance == StanceTypeDefine.SPECIAL_SIT_GROUND or InCurrentStance == StanceTypeDefine.SIT_GROUND_ONLY  then
        if IntargetStance == StanceTypeDefine.NORMAL_STAND or IntargetStance == StanceTypeDefine.SPECIAL_STAND or IntargetStance == StanceTypeDefine.STAND_ONLY then
            NextStanceTimeline = "event_base/event_base_ground_end"
        end
    end
	return NextStanceTimeline;
end

function NpcDialogMgr:GetEndInteracticeAnimation(OldTimeLine, IdelTimeline, AnimCom, Actor, EntityID)
    if not IdelTimeline or IdelTimeline == 0 then return end
    local Condition
    Condition = string.format("Key = \"%s\"", IdelTimeline)
    local ActiontimelineCfg = ActiontimelinePathCfg:FindCfg(Condition)
    Condition = string.format("Key = \"%s\"", OldTimeLine)
    local OldTimelineCfg = ActiontimelinePathCfg:FindCfg(Condition)
    local TargetStance = ActiontimelineCfg and ActiontimelineCfg.Stance or 0
    local CurrentStance = OldTimelineCfg and OldTimelineCfg.Stance or 0
    local NextStanceStr = self:AnalyzeNextStanceTimeline(CurrentStance,TargetStance)

    local NowIdleID = AnimCom:GetIdleActionTimeline()
    if NextStanceStr ~= nil and #NextStanceStr > 0 and NowIdleID ~= 0 then
        local ExcessiveAnimationPath = AnimCom:GetActionTimeline(NextStanceStr)
        local CallBack = function()
            self:UnRegisterTimer(self["ResumeTimer"..tostring(EntityID)])
            self.ResumeTimerTable[EntityID] = nil
            AnimCom:SetIdleActionTimeline(IdelTimeline)
        end
        local NeedMontage = _G.ObjectMgr:LoadObjectSync(ExcessiveAnimationPath, ObjectGCType.NoCache)
        local Montage = Actor:CheckActionTimelineMontage(NeedMontage, "WholeBody", 0, 0, 99999)
        local DelayTime = AnimationUtil.GetAnimMontageLength(Montage)
        local ResumeTime = 0
        if DelayTime then
            ResumeTime = DelayTime * 0.8
        end
        self["ResumeTimer"..tostring(EntityID)]= self:RegisterTimer(CallBack, ResumeTime, 0 , 1)
        self.ResumeTimerTable[EntityID] = true
        AnimCom:PlayAnimation(ExcessiveAnimationPath, 1, 0)
    elseif IdelTimeline ~= 0 then
        AnimCom:SetIdleActionTimeline(IdelTimeline)
    end
end

function NpcDialogMgr:PlayFacialAnim(Actor, FacialExpression)
    if not FacialExpression or #FacialExpression == 0 then
        return
    end
    local AnimCom = Actor:GetAnimationComponent()
    AnimCom:PlayAnimation(self:GetTimelinePath(FacialExpression))
end

function NpcDialogMgr:PlaySpeakAnim(ResID, EntityID, Subtitle, DialogStyle)
	if nil == EntityID or nil == Subtitle or nil == DialogStyle then
		FLOG_ERROR("Speak anim play failed. EntityID: " .. tostring(EntityID) .. ". Subtitle: " .. tostring(Subtitle)
			.. ". Dialog style: " .. tostring(DialogStyle))
		return
	end
	local MouthSize = tonumber(DialogStyle) == 7 and "shout" or "normal"
	local SubtitleBytes = CommonUtil.GetStringByteCount(Subtitle)
	SubtitleBytes = SubtitleBytes / NpcDialogVM.SpeedLevel
	local SpeakLength
	-- テキストのバイトサイズに応じてリップモーション自動選択
	if SubtitleBytes >= 64 then
		SpeakLength = "long"
	elseif SubtitleBytes >= 16 then
		SpeakLength = "middle"
	else
		SpeakLength = "short"
	end
	local ATLPath = string.format("speak/%s_%s", MouthSize, SpeakLength)
    --因为策划要求，不配正常走流程，这里可能拿到的npc是不对的
    if not self.DialogNpcTable or not self.DialogNpcTable[ResID] then
        ResID = ActorUtil.GetActorResID(EntityID)
    end
    if ResID and self.DialogNpcTable and self.DialogNpcTable[ResID] then
        self.DialogNpcTable[ResID].LastSpeakMontage = _G.AnimMgr:PlayActionTimeLine(EntityID, ATLPath)
    end
end

function NpcDialogMgr:GetTimelinePath(AnimName)
    if string.startsWith(AnimName, "ACTION_TIMELINE_") then
        return _G.AnimMgr:GetActionTimeLinePathByLabel(string.sub(AnimName, 17))
    else
        return _G.AnimMgr:GetActionTimeLinePath(AnimName)
    end
end

function NpcDialogMgr:GetTimelineStance(AnimName)
    if string.startsWith(AnimName, "ACTION_TIMELINE_") then    
        local AnimPathSub = string.sub(AnimName, 17)
        local SearchCondition = string.format("Label = \"%s\"", AnimPathSub)
        local ActiontimelineCfg = ActiontimelinePathCfg:FindCfg(SearchCondition)
        if ActiontimelineCfg then
            return ActiontimelineCfg.Stance or 0
        end
    else
        local SearchCondition = string.format("Filename = \"%s\"", AnimName)
        local ActiontimelineCfg = ActiontimelinePathCfg:FindCfg(SearchCondition)
        if ActiontimelineCfg then
            return ActiontimelineCfg.Stance or 0
        end
    end
    return 0
end

--停止对话（隐藏对话ui相关），但取消后续和交互的流程（也就是不会显示交互的ui）
--方便对话后，接其他的内容
--目前用于幻卡：点击幻卡交互后，会先对话，对话结束后弹幻卡的入口主界面
function NpcDialogMgr:StopDialog()
    if self.MainPanel then
        self.MainPanel:StopDialog()
    else
        FLOG_ERROR("NpcDialogMgr:StopDialog, MainPanel is nil")
    end
    self.IsSkipInteractiveUIAfterDialog = true
end

-- 展示一个对话框，指定对话框内容
function NpcDialogMgr:ShowDialog(DialogPanelParams)
    local Name = DialogPanelParams.Name
    local Title = DialogPanelParams.Title
    local Content = DialogPanelParams.Content
    local DialogTexturePath = DialogPanelParams.DialogTexturePath or ""
    NpcDialogVM.bClickVisible = true
    if self.MainPanel then
        if Content and Content ~= "" then
            NpcDialogVM:SetSelfVisible(true)
        else
            NpcDialogVM:SetSelfVisible(false)
        end
        self.MainPanel:ShowDialog(Name, Title, Content, DialogTexturePath)
    else
        FLOG_ERROR(" NpcDialogMgr:ShowDialog, MainPanel is nil")
    end
    -- if self.DelayMainPanelTimer ~= nil then
    --     _G.TimerMgr:CancelTimer(self.DelayMainPanelTimer) -- 打断HideDialog()后的计时器
    --     self.DelayMainPanelTimer = nil
    -- end
end

-- 加速对话内容步进速度
function NpcDialogMgr:SpeedUpDialog()
    NpcDialogVM.bSpeedUp = true
end

function NpcDialogMgr:PlayDialogInQueue()
    if next(self.DialogQueue) == nil then
        _G.FLOG_WARNING("No dialog in queue.")
        return
    end

    local Params = self.DialogQueue[1]
    table.remove(self.DialogQueue, 1)
    local DialogActorName = ""
    local DialogActorTitle = ""
    local NpcInteractionCameraID = 0
    local SpecialName = ""
    local DialogTexturePath = ""
    if Params.DialogName and Params.DialogName ~= "" then
        SpecialName = Params.DialogName
    end
    --从这里开始，多人对话判定以RelevantNPCID为准
    --先判断有没有npc对过话，如果有，判断当前对话句的npc是否在对话过的npc里面
    local EntityID = 0
    if Params.RelevantNPCID ~= nil and Params.RelevantNPCID ~= 0 then
        --如果相同, 则不需要更新
        if self.DialogNpcTable and self.DialogNpcTable[Params.RelevantNPCID] then
            EntityID = self.DialogNpcTable[Params.RelevantNPCID].EntityID
        else
            --不相同，更新存储的eid
            local ActorTable =_G.UE.UActorManager.Get():GetActorsByResID(Params.RelevantNPCID)
            local Length = ActorTable:Length()
            if ActorTable and Length == 1 then
                local Actor = ActorTable:Get(1)
                if not next(self.DialogNpcTable) or not  self.DialogNpcTable[Params.RelevantNPCID] then
                    self.DialogNpcTable[Params.RelevantNPCID] = {}
                end
                EntityID = Actor:GetAttributeComponent().EntityID
                self.DialogNpcTable[Params.RelevantNPCID].EntityID = Actor:GetAttributeComponent().EntityID
            elseif Length == 0 then

            else
                local MinDistance = nil
                local MinIndex = 1
                for i = 1, Length do
                    local Actor = ActorTable:Get(i)
	                local MajorActor = MajorUtil.GetMajor()
	                local MajorPos = MajorActor:FGetActorLocation()
                    local NPCPos = Actor:FGetActorLocation()
                    local NpcDistance = math.sqrt(((NPCPos.X - MajorPos.X) ^ 2) + ((NPCPos.Y - MajorPos.Y) ^ 2) + ((NPCPos.Z - MajorPos.Z) ^ 2))
                    if not MinDistance then
                        MinDistance = NpcDistance
                        MinIndex = i
                    elseif MinDistance > NpcDistance then
                        MinIndex = i
                    end
                end
                local Actor = ActorTable:Get(MinIndex)
                if not next(self.DialogNpcTable) or not self.DialogNpcTable[Params.RelevantNPCID] then
                    self.DialogNpcTable = {}
                    self.DialogNpcTable[Params.RelevantNPCID] = {}
                end
                EntityID = Actor:GetAttributeComponent().EntityID
                self.DialogNpcTable[Params.RelevantNPCID].EntityID = Actor:GetAttributeComponent().EntityID
            end
        end
    end

    --找不到EntityID就用记录的上一个id，此处为了保证不配置npcid时的逻辑正常运转
    --可能导致口型，动作错误，需要先排查Npcid
    local Actor = nil
    local TmpResID = nil
    if  EntityID == 0 then
        EntityID = Params.EntityID
        TmpResID = ActorUtil.GetActorResID(EntityID)
        Actor = ActorUtil.GetActorByEntityID(EntityID or 0)
        if Actor then
            self.DialogNpcTable[TmpResID] = {}
            self.DialogNpcTable[TmpResID].EntityID = Actor:GetAttributeComponent().EntityID
        end
    else
        Actor = ActorUtil.GetActorByEntityID(EntityID)
    end

    --这里用表格的ID没问题
    if Params.RelevantNPCID ~= nil and Params.RelevantNPCID ~= 0 then
        local Cfg = NpcCfg:FindCfgByKey(Params.RelevantNPCID)
        if Cfg ~= nil then
            DialogActorName = SpecialName == "" and Cfg.Name or SpecialName
            DialogActorTitle = Cfg.Title
            NpcInteractionCameraID = Cfg.InteractionCamera
        end
    elseif Params.RelevantEobjID ~= nil and Params.RelevantEobjID ~= 0 then
        local Cfg = EobjCfg:FindCfgByKey(Params.RelevantEobjID)
        if Cfg ~= nil then
            DialogActorName = SpecialName == "" and Cfg.Name or SpecialName
        end
    elseif TmpResID and TmpResID ~= 0 then
        local Cfg = NpcCfg:FindCfgByKey(TmpResID)
        if Cfg ~= nil then
            DialogActorName = SpecialName == "" and Cfg.Name or SpecialName
            DialogActorTitle = Cfg.Title
            NpcInteractionCameraID = Cfg.InteractionCamera
        end
    else
        FLOG_INFO("[NpcDialogMgr] DialogRelevantNPCID Is Nil ! ")
        --多Npc对话需求，没有配置不显示
        DialogActorName = ""
        DialogActorTitle = ""
        NpcInteractionCameraID = nil
    end

    --这里需要处理多个Npc的动作
    if Actor then
        self:PlayDialogAnim(EntityID, Params.AnimPath)
        self:PlayFacialAnim(Actor, Params.FacialExpression)
		if Params.RelevantNPCID ~= nil and Params.RelevantNPCID ~= 0 then
            self:PlaySpeakAnim(Params.RelevantNPCID, EntityID, Params.DialogContent, Params.DialogStyle)
        else
            if self.DialogNpcTable and next(self.DialogNpcTable) then
                for key, value in pairs(self.DialogNpcTable) do
                    if value.LastSpeakMontage and value.LastSpeakMontage:IsValid() then
                        local OtherActor = ActorUtil.GetActorByEntityID(value.EntityID)
                        local AnimCom = OtherActor:GetAnimationComponent()
                        if AnimCom then
                            AnimCom:StopMontage(value.LastSpeakMontage)
                            value.LastSpeakMontage = nil
                        end
                    end
                end
            end
        end
    end

    if self.MainPanel then
        if tonumber(Params.DialogStyle) ~= nil then
            self.MainPanel:SwitchStyle(tonumber(Params.DialogStyle))
        else
            self.MainPanel:SwitchStyle(0)
        end
    else
        FLOG_ERROR("NpcDialogMgr:PlayDialogInQueue, MainPanel is nil")
    end
    --从这里开始记录剧情回顾，后续只用关心从哪里清除就好
    local Name = ""
    local PreCutName, Content = self:PreCutDialogString(Params.DialogContent)
    if PreCutName and PreCutName ~= "" then
        Name = PreCutName
    else
        Name = DialogActorName
    end
    local ContentType = (Name and Name ~= "")
        and StoryDefine.ContentType.NpcContent
        or StoryDefine.ContentType.Choice
    if tonumber(Params.DialogStyle) == 8 or tonumber(Params.DialogStyle) == 10 then
        ContentType = StoryDefine.ContentType.OnlyContent
    end
    DialogTexturePath = Params.TexturePath or ""
    local HistoryItem = StoryDefine.DialogHistoryClass.New(ContentType, StoryDefine.DialogType.Dialog, Name, Content)
    NpcDialogHistoryVM:InsertHistoryItem(HistoryItem)
    self:ShowDialog({ Name = Name, Title = Params.Title or DialogActorTitle, Content = Content, DialogTexturePath = DialogTexturePath})
    self.LastDialog.NpcEntityID = Params.EntityID
    self.LastDialog.DialogGroup = Params.DialogGroup
    self.LastDialog.DialogLibID = Params.DialogLibID
    if Params.DialogLibID ~= nil then
        self.DialogLibLastGroup[Params.DialogLibID] = Params.DialogGroup
    end
    self.LastDialog.Callback = Params.Callback

    local CameraID = 0
    if NpcInteractionCameraID and Params.bUseNpcInteractionCamera and NpcInteractionCameraID > 0 then
        if Params.CameraConfig ~= nil and Params.CameraConfig ~= 0 then
            CameraID = Params.CameraConfig
        else
            if NpcInteractionCameraID == 1 then
                CameraID = self:GetCameraConfigID(EntityID)
            else
                CameraID = NpcInteractionCameraID
            end
        end
    else
        if Params.CameraConfig ~= nil and Params.CameraConfig ~= 0 then
            CameraID = Params.CameraConfig
        end
    end
    local Major = MajorUtil.GetMajor() or nil
    if CameraID and CameraID > 0 and self.LastCameraConfigID ~= CameraID then
        FLOG_INFO("NpcDialogMgr:PlayDialogInQueueCameraID"..CameraID)
        local Ret, ConfigKeyID = self:ChangeView(CameraID, EntityID)
        if Ret ~= nil then
            local IsHideMajor = self:OnEnterDialogCamera(EntityID, ConfigKeyID)
            _G.InteractiveMgr:EnterInteractive()
            if not IsHideMajor then
                self:SetNpcLookAt(Actor, Major, EntityID)
            end
            self.IsNeedResumeCamera = true
        else
            self:SetNpcLookAt(Actor, Major, EntityID)
        end
    else
        if self.LastConfigKeyID and self.LastConfigKeyID ~= 0 then
            local IsHideMajor = self:CheckNeedNpcLookAt(self.LastConfigKeyID)
            if not IsHideMajor then
                self:SetNpcLookAt(Actor, Major, EntityID)
            end
        else
            self:SetNpcLookAt(Actor, Major, EntityID)
        end        
    end
end

function NpcDialogMgr:PreCutDialogString(Content)
    if not Content or Content == "" then return "", "" end
    local result = ""
    --这里不用正则表达式了，约定好格式后这种更保险
    if Content:sub(1,1) == "(" and Content:sub(2,2) == "-" then
        Content = Content:sub(3)
        for i = 1, string.len(Content)  do
            if Content:sub(i,i) == ")" then
                result = Content:sub(1, i - 2)
                Content = Content:sub(i + 2)--换行符删除
                break
            end
        end
        
    end
    return result, Content
end

function NpcDialogMgr.DoSwitchStyle(DialogueWidget, DialogueWidgetView, StyleID)
	-- 对话框样式表中查看ID对应的样式路径
	if StyleID == nil or DialogueWidgetView.CurrentStyleID == StyleID then return end
	local CfgRow = DialogStyleCfg:FindCfgByKey(StyleID)
	if CfgRow == nil then return end
    --系统和字幕样式没有名字
    if StyleID == 8 or StyleID == 10 then
        UIUtil.SetIsVisible(DialogueWidget.TexTitle, false)
    else
        UIUtil.SetIsVisible(DialogueWidget.TexTitle, true)
    end
    --对话背景图
    local DialogPath = CfgRow.DialoguePath
    if DialogPath and DialogPath ~= "" then
        UIUtil.SetIsVisible(DialogueWidget.ImgLIne, true)
        UIUtil.SetIsVisible(DialogueWidget.ImgDecoShadow, true)
        UIUtil.ImageSetBrushFromAssetPath(DialogueWidget.ImgLIne, DialogPath)
    else
        UIUtil.SetIsVisible(DialogueWidget.ImgDecoShadow, false)
        UIUtil.SetIsVisible(DialogueWidget.ImgLIne, false)
    end
    --对话文字颜色
    local DefaultContentColor = "FFFFFFFF"
    local DialogueColor = CfgRow.DialogueColor
    if DialogueColor and DialogueColor ~= "" then
        UIUtil.TextBlockSetColorAndOpacityHex(DialogueWidget.TextContent, DialogueColor)
    else
        UIUtil.TextBlockSetColorAndOpacityHex(DialogueWidget.TextContent, DefaultContentColor)
    end
    --对话描边
    local DialogueOutlineColor = CfgRow.DialogueOutlineColor
    local DialogueAlpha = CfgRow.DialogueAlpha 
    if DialogueOutlineColor and DialogueOutlineColor ~= "" then
        DialogueWidget.TextContent.Font.OutlineSettings.OutlineSize = 2
        local ContentColor = _G.UE.FLinearColor.FromHex(DialogueOutlineColor)
        if DialogueAlpha and DialogueAlpha ~= 0 then
            ContentColor.A = DialogueAlpha / 100
        end 
        DialogueWidget.TextContent.Font.OutlineSettings.OutlineColor = ContentColor
	    DialogueWidget.TextContent:SetFont(DialogueWidget.TextContent.Font)
    else
        DialogueWidget.TextContent.Font.OutlineSettings.OutlineSize = 0
        local DefaultColor = _G.UE.FLinearColor.FromHex("#FFFFFF")
        DefaultColor.A = 0
        DialogueWidget.TextContent.Font.OutlineSettings.OutlineColor = DefaultColor
	    DialogueWidget.TextContent:SetFont(DialogueWidget.TextContent.Font)
    end

    --标题文字颜色
    local DefaultNameColor = "FFDA7FFF"
    local NameColor = CfgRow.NameColor
    if NameColor and NameColor ~= "" then
        UIUtil.TextBlockSetColorAndOpacityHex(DialogueWidget.TexTitle, NameColor)
    else
        UIUtil.TextBlockSetColorAndOpacityHex(DialogueWidget.TexTitle, DefaultNameColor)
    end
    --标题描边
    local NameOutlineColor = CfgRow.NameOutlineColor
    local NameAlpha = CfgRow.NameAlpha
    if NameOutlineColor and NameOutlineColor ~= "" then
        DialogueWidget.TexTitle.Font.OutlineSettings.OutlineSize = 2
        local ContentColor = _G.UE.FLinearColor.FromHex(NameOutlineColor)
        if DialogueAlpha and DialogueAlpha ~= 0 then
            ContentColor.A = NameAlpha / 100
        end 
        DialogueWidget.TexTitle.Font.OutlineSettings.OutlineColor = ContentColor
	    DialogueWidget.TexTitle:SetFont(DialogueWidget.TexTitle.Font)
    else
        DialogueWidget.TexTitle.Font.OutlineSettings.OutlineSize = 0
        local DefaultColor = _G.UE.FLinearColor.FromHex("#FFFFFF")
        DefaultColor.A = 0
        DialogueWidget.TexTitle.Font.OutlineSettings.OutlineColor = DefaultColor
	    DialogueWidget.TexTitle:SetFont(DialogueWidget.TexTitle.Font)
    end

    --背景处理
    local BgDefaultColor = "000000FF"
    local RobotColor = "#001133"
    if StyleID == 5 then
        UIUtil.ImageSetColorAndOpacityHex(DialogueWidget.ImgBG, RobotColor)
        UIUtil.ImageSetColorAndOpacityHex(DialogueWidget.ImgDecoShadow, RobotColor)
    else
        UIUtil.ImageSetColorAndOpacityHex(DialogueWidget.ImgBG, BgDefaultColor)
        UIUtil.ImageSetColorAndOpacityHex(DialogueWidget.ImgDecoShadow, BgDefaultColor)
    end
	DialogueWidgetView.CurrentStyleID = StyleID
end

--从NPC对话表中读取对话库
function NpcDialogMgr:ReadDialogLib(DialogLibID, EntityID)
    local DialogLib = {}
    local AllCfg = nil
    if DialogLibID >= 500000 and DialogLibID <= 599999 then
        AllCfg = DefaultDialogCfg:FindAllCfg("DialogLibID = "..DialogLibID)
    else
        AllCfg = DialogCfg:FindAllCfg("DialogLibID = "..DialogLibID)
    end
    if AllCfg == nil then
        return nil
    end
    for _, Value in ipairs(AllCfg) do
        local Cfg = table.shallowcopy(Value)
        if Cfg ~= nil then
            if EntityID ~= nil then
                Cfg.EntityID = EntityID
            end
            if DialogLib[Cfg.DialogLibID] ~= nil then
                if DialogLib[Cfg.DialogLibID][Cfg.DialogGroup] ~= nil then
                    table.insert(DialogLib[Cfg.DialogLibID][Cfg.DialogGroup], Cfg)
                else
                    DialogLib[Cfg.DialogLibID][Cfg.DialogGroup] = {Cfg}
                end
            else
                DialogLib[Cfg.DialogLibID] = {[Cfg.DialogGroup] = {Cfg}}
            end
        end
    end
    return DialogLib
end

function NpcDialogMgr:ContinueDialog()
    _G.EventMgr:SendEvent(EventID.ClickNextDialog)
end

function NpcDialogMgr:OnPreFunctionItemClick(FuncItem)
    if self.LastDialog.NpcEntityID == FuncItem.EntityID then
        self.DialogState = NpcDialogState.FUNCTION
        FLOG_INFO("Interactive OnPreFunctionItemClick DialogState:%d, FuncType:%d", self.DialogState, FuncItem.FuncType)

        --这里InteractiveMgr的CurInteractFuncItem不一定被赋值了 （messagebox的取消按钮时）

        if FuncItem.FuncType == LuaFuncType.NPCQUIT_FUNC then
            self.DialogState = NpcDialogState.END_DIALOG
        elseif FuncItem.FuncType == LuaFuncType.QUEST_FUNC then
            --播放sequence的对话的时候要关掉npc的对话
            if QuestDefine.GetDialogueType(FuncItem.FuncParams.QuestParams.DialogOrSequenceID) == QuestDefine.DialogueType.DialogueSequence then
                self.DialogState = NpcDialogState.END_DIALOG
                --self:ContinueDialog()
            end
        elseif FuncItem.FuncType == LuaFuncType.INTERACTIVEDESCC_FUNC then
            if FuncItem.InteractivedescCfg then
                local npcFuncType = FuncItem.InteractivedescCfg.FuncType
                if (npcFuncType == ProtoRes.interact_func_type.INTERACT_FUNC_ENTER_PWORLD_UI) then       --传送副本
                    self.DialogState = NpcDialogState.END_DIALOG
                elseif (npcFuncType == ProtoRes.interact_func_type.INTERACT_FUNC_ENTER_FANTASYCARD) then    --独立玩法
                    self.DialogState = NpcDialogState.END_DIALOG
                elseif npcFuncType == ProtoRes.interact_func_type.INTERACT_FUNC_ENTER_SCENE_S then
                    self.DialogState = NpcDialogState.END_DIALOG
                    --self:ContinueDialog()
                elseif npcFuncType == ProtoRes.interact_func_type.INTERACT_FUNC_GUIDE then
                    self.DialogState = NpcDialogState.END_DIALOG
                    self:ContinueDialog()
                elseif npcFuncType == ProtoRes.interact_func_type.INTERACT_FUNC_NEWBIE_AUTH then
                    self.DialogState = NpcDialogState.END_DIALOG
                    self:ContinueDialog()
                end
            else
                FLOG_ERROR("Interactive ERROR InteractivedescCfg is nil")
            end
        end
    end
end

function NpcDialogMgr:OverrideStatePending()
    self.DialogState = NpcDialogState.PENDING_DIALOG
end

function NpcDialogMgr:OverrideStateEnd()
    self.DialogState = NpcDialogState.END_DIALOG
end

function NpcDialogMgr:OnGameEventPWorldExit()
    -- if self.DelayMainPanelTimer ~= nil then
    --     _G.TimerMgr:CancelTimer(self.DelayMainPanelTimer) -- 打断HideDialog()后的计时器
    --     self.DelayMainPanelTimer = nil
    -- end
end

function NpcDialogMgr:OnGameEventMajorHit()
    if self:IsDialogPanelVisible() or _G.InteractiveMgr.bLockTimer then
        MsgTipsUtil.ShowTips(LSTR(1280010))
        self.DialogQueue = {}
        self:EndInteraction()
    end
end

function NpcDialogMgr:OnGameEventLoginRes(Params)
    local bReconnect = Params.bReconnect
    local IsInSeq = _G.StoryMgr:SequenceIsPlaying()
	if IsInSeq then
        return
    end
	if bReconnect then
        --断线重连对话未结束需要结束对话
        if self.HudHideState then
            FLOG_INFO("DialogMgr:ShowHUD")
            _G.HUDMgr:SetIsDrawHUD(true)
            self.HudHideState = false
        end
        if _G.InteractiveMgr.bLockTimer then
            self.PreDefaultDialogID = 0
            self.DialogQueue = {}
            _G.InteractiveMgr:ShowEntrances()
            _G.InteractiveMgr:ClearCustomData()
            self.bIsSetMove = false
            self:EndInteraction()
        end
    end
end

function NpcDialogMgr:OnGameEventEnterWorld()
    if self.HudHideState then
        FLOG_INFO("DialogMgr:ShowHUD")
        _G.HUDMgr:SetIsDrawHUD(true)
        self.HudHideState = false
    end
    if _G.InteractiveMgr.bLockTimer then
        self.PreDefaultDialogID = 0
        self.DialogQueue = {}
        _G.InteractiveMgr:ClearCustomData()
        self.bIsSetMove = false
        self:EndInteraction()
    end
end

function NpcDialogMgr:OnRelayConnected(Params)
    if not Params.bRelay then
        return
    end
    local IsInSeq = _G.StoryMgr:SequenceIsPlaying()
	if IsInSeq then
        return
    end
    if self.HudHideState then
        FLOG_INFO("DialogMgr:ShowHUD")
        _G.HUDMgr:SetIsDrawHUD(true)
        self.HudHideState = false
    end
    if _G.InteractiveMgr.bLockTimer then
        self.PreDefaultDialogID = 0
        self.DialogQueue = {}
        _G.InteractiveMgr:ClearCustomData()
        self.bIsSetMove = false
        self:EndInteraction()
    end
end

function NpcDialogMgr:ChangeView(ViewConfigID, EntityID)
    local DialogNpcEntityId = 0
    --优先使用传入的entityid
    if EntityID~= nil then
        DialogNpcEntityId = EntityID
    elseif self.LastDialog~= nil then 
        DialogNpcEntityId = self.LastDialog.NpcEntityID
    end
    local Ret, ConfigKeyID = _G.LuaCameraMgr:TryChangeViewByConfigID(ViewConfigID, DialogNpcEntityId)
    self.LastCameraConfigID = ViewConfigID
    self.LastConfigKeyID = ConfigKeyID
    return Ret, ConfigKeyID
end

function NpcDialogMgr:ChangeViewByParams(Params)
    return _G.LuaCameraMgr:ChangeViewByParams(Params)
end

function NpcDialogMgr:SaveDialogBranchCfg(Cfg)
    NpcDialogVM:SaveBranchCfg(Cfg)
end

function NpcDialogMgr:ChooseMenuChoice(ChoiceIndex)
    NpcDialogVM:ChooseMenuChoice(ChoiceIndex)
end  

function NpcDialogMgr:NarrativeTest(DialogLibID)
    local DialogueBranchCfg = require("TableCfg/DialogueBranchCfg")
    self.DialogLibID = DialogLibID

    if type(self.DialogLibID) ~= "number" or self.DialogLibID <= 0 then return false end

    local Cfg = DialogueBranchCfg:FindCfg(string.format("DialogID == %d", self.DialogLibID))
    if Cfg and next(Cfg) then
        NpcDialogVM:SaveBranchCfg(Cfg)
        NpcDialogVM:SetSelfBranchList()
        NpcDialogVM:SetDialogBranchVisible(true)
        return true
    end
end  

function NpcDialogMgr:CheckDialogIDIsBranch()
    local DialogueBranchCfg = require("TableCfg/DialogueBranchCfg")
    --先检索是否是对白分支的对话组ID
    if type(self.DialogLibID) ~= "number" or self.DialogLibID <= 0 then return false end
    local Cfg = DialogueBranchCfg:FindCfg(string.format("DialogID == %d", self.DialogLibID))
    if Cfg and next(Cfg) then
        NpcDialogVM:SaveBranchCfg(Cfg)
        NpcDialogVM:SetSelfBranchList()
        NpcDialogVM:SetDialogBranchVisible(true)
        return true
    end
    return false
end

function NpcDialogMgr:SetTouchWaitTime(Time, AutoTime)
    NpcDialogVM:SetTouchWaitTime(Time, AutoTime)
end

function NpcDialogMgr:GetBranchListItem(BranchCfg)
	if BranchCfg and next(BranchCfg) and next(BranchCfg.ChoiceList) then
		local TempUnitList = {}
		for key, value in pairs(BranchCfg.ChoiceList) do
			---DB暂时有问题，这里先拦截一下
			if value.Content ~= "" then
				local ChoiceFunctionUnit = FunctionItemFactory:CreateNpcDialogBranch(value.Content,
				{
                    NeedInsertHistory = true,
					ChoiceIndex = key,
				})
				table.insert(TempUnitList, ChoiceFunctionUnit)
			end
		end
        return TempUnitList
	end
end

return NpcDialogMgr