---
--- Author: haialexzhou
--- DateTime: 2021-11-11
--- Description:
--过场动画sequence播放
---1. 通过任务编辑器配置播放：任务sequenceid或者对白组id
---2. 通过关卡编辑器配置播放：任务sequenceid或者对白组id
---3. 通过开场动画播放：关卡sequence路径

local LuaClass = require("Core/LuaClass")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local SequencePlayerVM = require("Game/Story/SequencePlayerVM")
local NpcDialogHistoryVM = require("Game/Interactive/View/New/NpcDialogueHistoryVM")
local StoryDefine = require("Game/Story/StoryDefine")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local TipsQueueDefine = require("Game/TipsQueue/TipsQueueDefine")
local TeamHelper = require("Game/Team/TeamHelper")
local DynamicCutsceneCfg = require("TableCfg/DynamicCutsceneCfg")
local SequenceSkipGroupCfg = require("TableCfg/SequenceSkipGroupCfg")
local SidePopUpDefine = require("Game/SidePopUp/SidePopUpDefine")
local HUDConfig = require("Define/HUDConfig")
local ActorManager = _G.UE.UActorManager
local FVector = _G.UE.FVector
local FRotator = _G.UE.FRotator
local DEFAULT_MAX_PLAYER_RESID = 1000

local ZeroLocation = FVector(0, 0, 0)
local ZeroRotator = FRotator(0, 0, 0)

--缓存未进入视野的队友信息(播放过场动画时)
local TempMemberCacheInfo = LuaClass()

function TempMemberCacheInfo:Ctor()
	self.Guid = nil
    self.ResID = nil
end


local SequencePlayerBase = LuaClass()

function SequencePlayerBase:Ctor()
    self.SequenceActor = nil
    self.SequenceRootLocation = nil
    self.PossessableActorTArray = nil
    self.UIViewID = _G.UIViewID.DialogueMainPanel
    self.ManualStopSequence = false --是否手动停止sequence
    self.bClickButtonSkip = false --是否玩家按键停止sequence
    self.bIsPlayNext = false --是否继续播放
    self.bIsInterruptMultiPlay = false --是否中断多段播放

    self.bPossessableActorWithMajor = false --主角是否绑定在Sequence里面
    self.CachedAvatarsToAssemble = nil
    self.WaitAvatarsToAssembleCount = 0

    self.ActorsForbiddenInSequence = {}
    self.ResIDForbiddenInSequence = {}
end

function SequencePlayerBase:CreateSequenceActor()
	local StoryMgrInstance = _G.UE.UStoryMgr:Get()
	if (StoryMgrInstance ~= nil) then
		self.SequenceActor = StoryMgrInstance:CreateSequenceActor()
	end

	return self.SequenceActor
 end

function SequencePlayerBase:SetSequenceRootLocation(RootLocation)
    self.SequenceRootLocation = RootLocation
end

function SequencePlayerBase:Destroy()
    if (self:SequenceActorIsValid()) then
        local SequencePlayer = self:GetLevelSequencePlayer()
        if (SequencePlayer ~= nil) then
            SequencePlayer.OnStop:Clear()
            SequencePlayer.OnFinished:Clear()
            SequencePlayer.OnPause:Clear()
        end

        self.SequenceActor:ResetData()
        --因为监听了SequencePlayer.OnFinished，SequenceActor不能在播放完成回调中销毁，等到下次播放时再销毁重新创建或者离开副本时销毁
        self.SequenceActor = nil
    end

    self.ManualStopSequence = false
    self.bClickButtonSkip = false
    self.StopCallbackWhenException = nil
    self.SequenceStopedInException = false
    self.PossessableActorTArray = nil
end

function SequencePlayerBase:OnFinish()
    if self.bIsPlayNext then
        return
    end
    local StoryMgrInstance = _G.UE.UStoryMgr:Get()
    if (StoryMgrInstance ~= nil) then
        StoryMgrInstance:Finish()
    end

    _G.FLOG_INFO("SequencePlayerBase_OnFinish LowerUpdatePrimitiveFramedNum()")
    --恢复
    _G.UE.UKismetRenderingLibrary.LowerUpdatePrimitiveFramedNum()
end

function SequencePlayerBase:OnStop()
    local StoryMgrInstance = _G.UE.UStoryMgr:Get()
	if (StoryMgrInstance ~= nil) then
        StoryMgrInstance:ResetStaticMeshLODAndCullDistance()
    end
    --这里清除一下剧情回顾的数据
    --如果后续需要任务回顾需要先判断是否完成HistoryVM的任务
    NpcDialogHistoryVM:ClearHistoryData()
    if (self.ManualStopSequence) then
        --此时不会执行OnFinished.Broadcast()，放到这里清除
        self:OnFinish()
    end

    --恢复
    _G.FLOG_INFO("SequencePlayerBase_OnStop LowerUpdatePrimitiveFramedNum()")
    _G.UE.UKismetRenderingLibrary.LowerUpdatePrimitiveFramedNum()
end

--获取当前对白文本的长度
function SequencePlayerBase:GetCurrentDialogueContentDuration()
    if (SequencePlayerVM.TalkContent ~= nil and SequencePlayerVM.TalkContent ~= "") then
        local ContentLength = _G.CommonUtil.GetStrLen(SequencePlayerVM.TalkContent)
        local ContentDuration = ContentLength * 0.1
        return ContentDuration
    end
    return 0.0
end


function SequencePlayerBase:ShowDialogueSentence(DialogueSentenceInfo)
    if not _G.UIViewMgr:IsViewVisible(self.UIViewID) then
        self.MainPanel =  _G.UIViewMgr:ShowView(self.UIViewID,{ViewType = StoryDefine.UIType.SequenceDialog})
    end

    SequencePlayerVM:UpdateDialogueInfo(DialogueSentenceInfo)
    local Name = DialogueSentenceInfo.SpeakerName

    local ContentType = StoryDefine.ContentType.NpcContent
    if SequencePlayerVM.bSystemDialog then
        ContentType = StoryDefine.ContentType.OnlyContent
    elseif (Name == nil) or (Name == "") then
        ContentType = StoryDefine.ContentType.Choice
    end

    local HistoryItem = StoryDefine.DialogHistoryClass.New(
        ContentType, StoryDefine.DialogType.Dialog, Name, DialogueSentenceInfo.Content,
        DialogueSentenceInfo.VoiceName)

    NpcDialogHistoryVM:InsertHistoryItem(HistoryItem)

    if (self.MainPanel ~= nil) then
        self.MainPanel:SwitchStyle(tonumber(DialogueSentenceInfo.DialogStyle))
    end
end

function SequencePlayerBase:UpdateDialogueAudioDuration(CurrentAudioDuration)
    SequencePlayerVM:UpdateDialogueStayDurationWhenAutoPlay(CurrentAudioDuration)
end

function SequencePlayerBase:UpdateDialogueTopWidget(SkipType, FadeColorType, bCanSkip)
    local bIsCanSkipTemp = bCanSkip
    --关卡数据配置的
    if (self.SequenceCfg ~= nil and self.SequenceCfg.bIsCanSkip ~= nil) then
        bIsCanSkipTemp = SequencePlayerVM:CheckIsCanSkip(self.SequenceCfg)
    end
    SequencePlayerVM:UpdateSkipInfo(bIsCanSkipTemp and not SequencePlayerVM.bIsPlayMultiple, SkipType, FadeColorType)
end

function SequencePlayerBase:GetSceneCharacterShowType()
    if (self.SequenceCfg ~= nil) then
        return self.SequenceCfg.SceneCharacterShowType
    end
    return 0
end

function SequencePlayerBase:CurrentPlayingIsNCut()
    return self.SequenceCfg ~= nil and self.SequenceCfg.bIsNcut == true
end

function SequencePlayerBase:GetPlayerMaxResID()
    return DEFAULT_MAX_PLAYER_RESID
end

--辅助性的sequence
function SequencePlayerBase:IsInvalidMovieSequence(SequenceObject)
    if (self:SequenceActorIsValid()) then
        return self.SequenceActor:IsInvalidMovieSequence(SequenceObject)
    end
    return true
end

function SequencePlayerBase:DestroyAllPossessableActors()
    self.CachedPossessableObjectForTag = nil
    self.CachedPossessableActorsForSeq = nil

    if (self.PossessableActorTArray ~= nil) then
        local PossessableCnt = self.PossessableActorTArray:Length()
        for i = 1, PossessableCnt do
            local PossessableActor = self.PossessableActorTArray:Get(i)
            if (PossessableActor ~= nil and PossessableActor.bCreatedInSeq and PossessableActor.Actor ~= nil and _G.CommonUtil.IsObjectValid(PossessableActor.Actor)) then
                _G.CommonUtil.DestroyActor(PossessableActor.Actor)
            end
        end

        self.PossessableActorTArray:Clear()
        self.PossessableActorTArray = nil
    end
end

function SequencePlayerBase:HideOtherCharacters(bIsHide)
    --头顶信息
    _G.HUDMgr:SetIsDrawHUD(not bIsHide, HUDConfig.IsDrawFlag.Sequence)

    local SceneCharacterShowType = self:GetSceneCharacterShowType()
    if (SceneCharacterShowType == ProtoRes.dialogue_scene_character_show_type.SHOW_ALL) then
        return
    end

    local ActorMgrInst = ActorManager:Get()

    local ExcludeActorIDs = _G.UE.TArray(_G.UE.uint64)
    if (self.PossessableActorTArray ~= nil) then
        local PossessableCnt = self.PossessableActorTArray:Length()
        for i = 1, PossessableCnt do
            local PossessableActor = self.PossessableActorTArray:Get(i)
            if (PossessableActor ~= nil and PossessableActor.Actor ~= nil and _G.CommonUtil.IsObjectValid(PossessableActor.Actor)) then
                local Actor = PossessableActor.Actor
                local AttributeComp = Actor:GetAttributeComponent()
                if (AttributeComp ~= nil) then
                    --存在相同ID    
                    if (not ExcludeActorIDs:Contains(AttributeComp.EntityID)) then
                        ExcludeActorIDs:Add(AttributeComp.EntityID)
                        
                        if (bIsHide) then
                            ActorMgrInst:HideActor(AttributeComp.EntityID, false) --进入npc对话时Sequence里用到的角色可能被隐藏，sequence开始播放时强制显示下
                        end
                    end

                    if (AttributeComp.ObjType == _G.UE.EActorType.EObj) and Actor.GetSgWeaponActorIds then
                        local SgWeaponActorIds = Actor:GetSgWeaponActorIds()
                        for j = 1, SgWeaponActorIds:Length() do
                            local ID = SgWeaponActorIds:Get(j)
                            if ID then
                                ExcludeActorIDs:Add(ID)
                            end
                        end
                    end
                end
            end
        end
    end

    if bIsHide and (SceneCharacterShowType ~= ProtoRes.dialogue_scene_character_show_type.HIDE_ALL) then
        local Actors = ActorMgrInst:GetAllActors()
        local TypeQuestEObj = ProtoRes.ClientEObjType.ClientEObjTypeTask
        for _, Actor in pairs(Actors) do
            if Actor then
                local EObjType = Actor.EObjType
                if (EObjType == TypeQuestEObj) then
                    -- https://tapd.woa.com/tapd_fe/20420083/story/detail/1020420083120925096
                    local EntityID = Actor:GetActorEntityID()
                    ExcludeActorIDs:Add(EntityID)
                end
            end
        end
    end

    local ExcludeActorTypes = _G.UE.TArray(_G.UE.uint8)
    if (SceneCharacterShowType == ProtoRes.dialogue_scene_character_show_type.HIDE_ALL_EXCEPT_NPC) then
        ExcludeActorTypes:Add(_G.UE.EActorType.Npc)
    elseif (SceneCharacterShowType == ProtoRes.dialogue_scene_character_show_type.HIDE_ALL_EXCEPT_MONSTER) then
        ExcludeActorTypes:Add(_G.UE.EActorType.Monster)
    end

    ActorMgrInst:HideAllActors(bIsHide, ExcludeActorIDs, ExcludeActorTypes)
end

 -- lcut相机需要及时获取eid，等待角色模型组装
function SequencePlayerBase:OnAvatarAssembleAllFinish(EntityID, ActorType)
	if self.WaitAvatarsToAssembleCount <= 0 then return end

    if self.CachedAvatarsToAssemble[EntityID] == ActorType then
        self.CachedAvatarsToAssemble[EntityID] = nil
        self.bHasRecvAvatarAssembleEndEvent = true
    end

    if next(self.CachedAvatarsToAssemble) == nil then
        self:DoPlaySequence()
    end
end

function SequencePlayerBase:IsWaitAvatarsToAssemble()
    return self.WaitAvatarsToAssembleCount > 0
end

function SequencePlayerBase:IsExistedInPossessableActors(ResID)
    if (self.PossessableActorTArray == nil) then
        return false
    end

    local PossessableCnt = self.PossessableActorTArray:Length()
    for i = 1, PossessableCnt do
        local PossessableActor = self.PossessableActorTArray:Get(i)
        if (PossessableActor ~= nil and PossessableActor.Actor ~= nil and _G.CommonUtil.IsObjectValid(PossessableActor.Actor)) then
            local AttributeComp = PossessableActor.Actor:GetAttributeComponent()
            --此时Sequence可能还没执行Play，此时可能无法获取PossessableActor.Actor的准确坐标值, 只能通过ResID来判断
            if (AttributeComp ~= nil and ResID == AttributeComp.ResID) then
                return true
            end
        end
    end

    return false
end

--设置Actors状态：是否使用动画蓝图控制角色旋转、脸部朝向跟随、LOD
function SequencePlayerBase:SetPossessableActorsState(bIsPlaying)
    if (self.PossessableActorTArray == nil) then
        return
    end

    local PossessableCnt = self.PossessableActorTArray:Length()
    for i = 1, PossessableCnt do
        local PossessableActor = self.PossessableActorTArray:Get(i)
        if (PossessableActor ~= nil and PossessableActor.Actor ~= nil and _G.CommonUtil.IsObjectValid(PossessableActor.Actor)) then
            if (bIsPlaying) then
                PossessableActor.Actor:DoSequenceEnter()
            else
                PossessableActor.Actor:DoSequenceExit()
                local AnimCom = PossessableActor.Actor:GetAnimationComponent()
                local AvatarCom = PossessableActor.Actor:GetAvatarComponent()
                local Assembler = AvatarCom and AvatarCom:GetAssembler() or nil
                if AnimCom and Assembler then
                    AnimCom:RelinkLayers()
                    Assembler:ReInit()
                end
                --重置表情参数
                PossessableActor.Actor:SetEmojiDataAsset(nil)
                PossessableActor.Actor:SetEmojiMixValue(0)
            end
        end
    end
    -- 主角如果不在Sequence里面也绑定一下，不然cpp里面的状态有问题(IsInSequencer是false)
    -- 断线重连时FMCharacterMovementComponent会在收到PWorldMapEnter事件的时候把主角的MovementMode状态恢复成默认状态
    if not self.bPossessableActorWithMajor then
        local Major = MajorUtil.GetMajor()
        if Major ~= nil then
            -- 走一遍完整的PossessableActor逻辑
            if bIsPlaying then
                Major:DoSequenceEnter()
            else
                Major:DoSequenceExit()
                local AnimCom = Major:GetAnimationComponent()
                local AvatarCom = Major:GetAvatarComponent()
                local Assembler = AvatarCom and AvatarCom:GetAssembler() or nil
                if AnimCom and Assembler then
                    AnimCom:RelinkLayers()
                    Assembler:ReInit()
                end
                --重置表情参数
                Major:SetEmojiDataAsset(nil)
                Major:SetEmojiMixValue(0)
            end
        end
    end
end

function SequencePlayerBase:UpdateMajorSetting(bIsPlay)
    local Major = MajorUtil.GetMajor()
    if (Major ~= nil) then
        Major:GetCameraControllComponent():UpdateDofSettingInSeq(bIsPlay)
        
        --进入Sequence后，强制设置下Major的MovementMode
        local CharacterMovement = Major.CharacterMovement
        if (CharacterMovement ~= nil) then
            if (bIsPlay) then
                CharacterMovement:SetMovementMode(_G.UE.EMovementMode.MOVE_Custom)
            elseif (not bIsPlay) then
                CharacterMovement:SetMovementMode(_G.UE.EMovementMode.MOVE_Walking)
            end
        end
    end
end

function SequencePlayerBase:OnSequenceFinishProcess()
	_G.UE.UCameraMgr.Get():ResetToCurrentCamera()
    self:SetPossessableActorsState(false)
    self:HideOtherCharacters(false)
    --需要放到HideOtherCharacters后执行
    self:UpdateMajorSetting(false)
    self:DestroyAllPossessableActors()
    if (not self.bWaitRestoreLayerSet) then
        _G.StoryMgr:RestoreVisionActorsTransform()
    end

    for EntityID, _ in ipairs(self.ActorsForbiddenInSequence) do
        local Actor = ActorUtil.GetActorByEntityID(EntityID)
        if Actor ~= nil then
            Actor:SetForbiddenInSequence(false)
        end
    end
    self.ActorsForbiddenInSequence = {}
    self.ResIDForbiddenInSequence = {}

    self.CachedTeamMemberInfos = nil
    self.CachedAvatarsToAssemble = nil
    self.WaitAvatarsToAssembleCount = 0
    self.bWaitRestoreLayerSet = false

    if (self.UIViewID ~= nil) then
        _G.UIViewMgr:HideView(self.UIViewID)
    end

    SequencePlayerVM:ResetVM()

    _G.CommonUtil.DisableShowJoyStick(false)
    _G.CommonUtil.ShowJoyStick()
   
    self:ProcessAudioVolumeScale(false)
end

function SequencePlayerBase:SequenceActorIsValid()
    if (not self.SequenceActor) then
        return false
    end

    if (not _G.CommonUtil.IsObjectValid(self.SequenceActor)) then
        return false
    end

    return true
end

function SequencePlayerBase:GetLevelSequencePlayer()
    if (not self:SequenceActorIsValid()) then
        return nil
    end

    return self.SequenceActor.SequencePlayer
end

function SequencePlayerBase:UpdatePlaybackSettings(PlaybackSettings)
    if (not self:SequenceActorIsValid()) then
        return
    end
    local bRestoreState = true
    local bDisableMovementInput = true
    local bDisableLookAtInput = true
    local bPauseAtEnd = false
    if (PlaybackSettings ~= nil) then
        bRestoreState = (PlaybackSettings.bRestoreState == true)
        bDisableMovementInput = (PlaybackSettings.bDisableMovementInput == true)
        bDisableLookAtInput = (PlaybackSettings.bDisableLookAtInput == true)
        bPauseAtEnd = (PlaybackSettings.bPauseAtEnd == true)
    end
    self.SequenceActor:UpdatePlaybackSettings(bRestoreState, bDisableMovementInput, bDisableLookAtInput, bPauseAtEnd)
end

function SequencePlayerBase:UpdateInstanceDataTransform()
    if (not self:SequenceActorIsValid()) then
        return
    end

    local WorldOriginPos = _G.PWorldMgr:GetWorldOriginLocation()
    local AnchorLocation = self.SequenceRootLocation and self.SequenceRootLocation + WorldOriginPos or ZeroLocation
    local AnchorRotator = ZeroRotator
    self.SequenceActor:UpdateInstanceDataTransform(AnchorLocation, AnchorRotator)
end

function SequencePlayerBase:PlaySequence(
    SequenceCfg,
    SequenceStopCallback, SequencePauseCallback, SequenceFinishedCallback, PlaybackSettings)

    if (not self:SequenceActorIsValid() or SequenceCfg == nil or SequenceCfg.SequenceObject == nil) then
        if (SequenceStopCallback ~= nil) then
            SequenceStopCallback()
        end
        return
    end

    local Major = MajorUtil.GetMajor()
    --异步加载资源的过程中，sequence被切图等异常终止了播放
    if (Major == nil or self:IsSequenceStopedInException()) then
        if (SequenceStopCallback ~= nil) then
            SequenceStopCallback()
        end
        return
    end

    local SequencePlayer = self:GetLevelSequencePlayer()
    if (SequencePlayer == nil) then
        if (SequenceStopCallback ~= nil) then
            SequenceStopCallback()
        end
        return
    end

    self.SequenceCfg = SequenceCfg
    --记录有没有成功收到过模型组装成功的事件
    self.bHasRecvAvatarAssembleEndEvent = false
    
    --在SetSequence之前。先设置PlaybackSettings
    self:UpdatePlaybackSettings(PlaybackSettings)
    --设置需要播放的Sequence
    self.SequenceActor:UpdateSequence(self.SequenceCfg.SequenceObject)
    --设置分歧轨道的avtive，active为false的子Sequence对象不需要初始化和bind
    self.SequenceActor:UpdateBranchSubSectionActiveState()

    --设置Sequence的Transform
    self:UpdateInstanceDataTransform()
    --创建Sequence里Possablesd对应的Character
    self:InitPossessableActors()
    --隐藏Sequence里没有用到的Characters
    self:HideOtherCharacters(true)
    --放到Play和BindPossessable之前（BindPossessable里会为每个section提前生成Montage资源），保证play的时候basecharacter已经进入insequence状态了
    self:SetPossessableActorsState(true)
    --Bind Sequence里的Possables
    self.SequenceActor:BindPossessableActors(self.PossessableActorTArray, self.SequenceCfg.StartFrameNumber)
    
    local function OnSequenceStoped(_)
        self:OnSequenceFinishProcess()
        self:OnStop()

        --放到最后面，StopCallback中可能会调用Destroy()函数
        if (SequenceStopCallback ~= nil) then
            SequenceStopCallback(true)
        end

        self:EnablePVSAndSOC()
    end

    --处理播放完成，中途跳过等不会执行
    local function OnSequenceFinished(_)
        if (SequenceFinishedCallback ~= nil) then
            SequenceFinishedCallback()
        end
        self:OnFinish()

        self:EnablePVSAndSOC()
    end

    local function OnSequencePaused(_)
        if (SequencePauseCallback ~= nil) then
            SequencePauseCallback()
        end
    end

    SequencePlayer.OnFinished:Add(self.SequenceActor, OnSequenceFinished)
    SequencePlayer.OnStop:Add(self.SequenceActor, OnSequenceStoped)
    SequencePlayer.OnPause:Add(self.SequenceActor, OnSequencePaused)

    self.StopCallbackWhenException = SequenceStopCallback
    
    local StoryMgrInstance = _G.UE.UStoryMgr:Get()
	if (StoryMgrInstance ~= nil) then
        StoryMgrInstance:SetCurrentSkipInfo(SequenceCfg.bSkipLoadLayerSet, SequenceCfg.bSkipLoadStreamingLevel)
        StoryMgrInstance:DisableStaticMeshLODAndCullDistance()
        if (SequenceCfg.bIsNcut) then
            StoryMgrInstance:HideFestivalLayers(true)
        end
       
        self.bWaitRestoreLayerSet = StoryMgrInstance:IsNeedChangeLayerSet(self.SequenceCfg.SequenceObject)
    end

    if (self.UIViewID ~= nil) then
        self.SequenceCfg.bHasAnyDialog = self.SequenceActor:HasAnyDialogueSection()
        SequencePlayerVM:InitSequenceInfo(self.SequenceCfg)
    end

    _G.CommonUtil.DisableShowJoyStick(true)
    _G.CommonUtil.HideJoyStick()
    _G.TipsQueueMgr:Stop(true, true, TipsQueueDefine.STOP_REASON.PLAYSEQUENCE)
    _G.TipsQueueMgr:Clear()
   

    local FadeViewID = UIViewID.CommonFadePanel
    if UIViewMgr:IsViewVisible(FadeViewID) then
        UIViewMgr:HideView(FadeViewID) -- 隐藏StoryMgr里的ShowView
    end
    -- TODO 临时处理一下, 播放Sequence的时候隐藏目标节点提示, 系统提示队列表中补充目标节点的配置后可以去掉
    if UIViewMgr:IsViewVisible(UIViewID.ActiveTips) then
        UIViewMgr:HideView(UIViewID.ActiveTips)
    end

    if not SequenceCfg.bSkipWaitAvatarLoadFinish and self.WaitAvatarsToAssembleCount > 0 then
        --最小和最大超时时间
        local MinLoadAvatarTimeOut = 5
        local MaxLoadAvatarTimeout = 15
        local LoadAvatarTimeOut = MinLoadAvatarTimeOut
        if (self.WaitAvatarsToAssembleCount > LoadAvatarTimeOut) then
            LoadAvatarTimeOut = self.WaitAvatarsToAssembleCount * 2 --7个模型以上，每个模型2秒
            if (LoadAvatarTimeOut > MaxLoadAvatarTimeout) then
                LoadAvatarTimeOut = MaxLoadAvatarTimeout
            end
        end

        -- 等待固定时间后强制播放sequence
        self.WaitAvatarsTimerID = _G.TimerMgr:AddTimer(nil, function()
            if self.WaitAvatarsToAssembleCount > 0 and self:SequenceActorIsValid() then
                local CurrTime = _G.TimeUtil.GetServerTime()
                _G.FLOG_INFO("[LoadWorld cost time record] PlaySequence LoadAvatars Timeout: CurrTime=%d", CurrTime)
                --异步加载资源的过程中，sequence被切图等异常终止了播放
                if (self:IsSequenceStopedInException()) then
                    _G.FLOG_INFO("[LoadWorld cost time record] PlaySequence IsSequenceStopedInException")
                    OnSequenceStoped()
                    return
                end

                self:DoPlaySequence()
            end
        end, LoadAvatarTimeOut, nil, nil, nil, "DoPlaySequence_AvatarTimeOut")

        --做个保护，定时强制Update下，防止某些原因UVisionMgr不Update，接收不到Avatar_AssembleAllEnd事件导致sequence loading时间过长
        if (LoadAvatarTimeOut > MinLoadAvatarTimeOut) then
            self.UpdateVisionTimerID = _G.TimerMgr:AddTimer(nil, function()
                if (not self.bHasRecvAvatarAssembleEndEvent) then
                    _G.UE.UVisionMgr.Get():ForceUpdate()
                end
            end, MinLoadAvatarTimeOut, 1, self.WaitAvatarsToAssembleCount)
        end

        _G.LoadingMgr:ShowLoadingView(true, true)
    else
        self:DoPlaySequence()
    end
end


function SequencePlayerBase:DoPlaySequence()
    local CurrTime = _G.TimeUtil.GetServerTime()
    _G.FLOG_INFO("[LoadWorld cost time record] PlaySequence DoPlaySequence: CurrTime=%d, WaitAvatarsToAssembleCount=%d", CurrTime, self.WaitAvatarsToAssembleCount)
    
    if (self.SequenceCfg ~= nil) then
        _G.FLOG_INFO("[LoadWorld cost time record] PlaySequence DoPlaySequence: bSkipWaitAvatarLoadFinish=%s", tostring(self.SequenceCfg.bSkipWaitAvatarLoadFinish))
    end

    if (self.WaitAvatarsToAssembleCount > 0) then
        self.WaitAvatarsToAssembleCount = 0
        self.bHasRecvAvatarAssembleEndEvent = false
    end

    _G.LoadingMgr:HideLoadingView() --这里不能延迟Hide，因为Play的时候Sequence里可能会切地图，导致影响Loading的显示

    if (self.WaitAvatarsTimerID) then
        _G.TimerMgr:CancelTimer(self.WaitAvatarsTimerID)
        self.WaitAvatarsTimerID = nil
    end

    if (self.UpdateVisionTimerID) then
        _G.TimerMgr:CancelTimer(self.UpdateVisionTimerID)
        self.UpdateVisionTimerID = nil
    end

    self:UpdateMajorStatePrePlay()
    
    self:DisablePVSAndSOC()	--有过场需要关闭PVS,SOCs

    --播放之前做个判断，如:角色模型加载是异步执行，加载完成后可能SequenceActor被干掉了
    if (not self:SequenceActorIsValid()) then
        _G.FLOG_INFO("SequenceActor is invalid!!!!")
        return
    end

    --设置
    _G.FLOG_INFO("SequencePlayerBase_DoPlaySequence HigherUpdatePrimitiveFramedNum()")
    _G.UE.UKismetRenderingLibrary.HigherUpdatePrimitiveFramedNum()

    self.SequenceActor:Play()

    if (self.SequenceCfg ~= nil and self.SequenceCfg.StartFrameNumber ~= nil and self.SequenceCfg.StartFrameNumber > 0) then
        self.SequenceActor:PlayToFrame(self.SequenceCfg.StartFrameNumber)
    end

    --Play后 有可能执行Stop，释放了SequenceActor
    if (not self:SequenceActorIsValid()) then
        return
    end

    if (self.UIViewID ~= nil) then
        self.MainPanel = _G.UIViewMgr:ShowView(self.UIViewID, {
                ViewType = StoryDefine.UIType.SequenceDialog,
            })
    end

    self.SequenceActor:SavePreAnimatedState()

    self:UpdateMajorSetting(true)
    self:ProcessAudioVolumeScale(true)
end

---屏蔽PVS & SOC，目前是manwil00110过场，相机在建筑物里面，导致部分物件被剔除
function SequencePlayerBase:DisablePVSAndSOC()
    if (nil == self.SequenceCfg) then
        return
    end

    local DisableOcclusionCull = false
    local SequencePath = self.SequenceCfg.SequencePath    
    FLOG_INFO("SequencePlayerBase:DisablePVSAndSOC SequencePath=%s", SequencePath)

    if (self.SequenceCfg.SequenceID ~= nil) then
        local CutSceneSequence = DynamicCutsceneCfg:FindCfgByKey(self.SequenceCfg.SequenceID)	    
        if (CutSceneSequence ~= nil) then
            DisableOcclusionCull = CutSceneSequence.DisableOcclusionCull > 0                
        end
        
    elseif SequencePath ~= nil and SequencePath ~= "" then
        if SequencePath:sub(1,1) == '/' then
			SequencePath = string.format("LevelSequence'%s'", SequencePath)
		end

		local CutSceneSequence = DynamicCutsceneCfg:FindCfg(string.format("SequencePath = \"%s\"", SequencePath))
        if (CutSceneSequence ~= nil) then
            DisableOcclusionCull = CutSceneSequence.DisableOcclusionCull > 0                
        end
    end

	if (DisableOcclusionCull) then
		local PWorldMgrInstance = _G.UE.UPWorldMgr:Get()

		local Cmd = string.format("r.Mobile.AllowSoftwareOcclusion 0")
		local Cmd1 = string.format("r.AllowPrecomputedVisibility 0")
		PWorldMgrInstance:ExecEngineCmd(Cmd)    
		PWorldMgrInstance:ExecEngineCmd(Cmd1)    

		--_G.FLOG_INFO("r.AllowPrecomputedVisibility 0")		
	end
end

---SOC恢复设置
function SequencePlayerBase:EnablePVSAndSOC()
	local PWorldMgrInstance = _G.UE.UPWorldMgr:Get()
	local Cmd = string.format("r.AllowPrecomputedVisibility 1")
	PWorldMgrInstance:ExecEngineCmd(Cmd)   

    _G.PWorldMgr:ExecSetSOCType()

	--_G.FLOG_INFO("r.AllowPrecomputedVisibility 1")	
end

--屏蔽他人技能音效
function SequencePlayerBase:ProcessAudioVolumeScale(bPlay)
    if (bPlay) then
        _G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Enemy, 0)
        _G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Teammate, 0)
    else
        _G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Enemy, 1)
        _G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Teammate, 1)
    end
end


--播Sequence之前，更新major的状态
function SequencePlayerBase:UpdateMajorStatePrePlay()
    --再次让玩家放下手中的刀，避免loading期间又因为某些原因拿起了武器
    local Major = MajorUtil.GetMajor()
    if (Major) then
        _G.EmotionMgr:SendStopEmotionAll()
        Major:GetStateComponent():SetHoldWeaponState(false)
		Major:GetStateComponent():ClearTempHoldWeapon(_G.UE.ETempHoldMask.ALL, true)
    end
end

--进入场景时播放过场动画，队友可能还没进入视野
function SequencePlayerBase:UpdateCachedTeamMemberPossessable(EntityID)
    if (self.CachedTeamMemberInfos == nil) then
        return false
    end
    local CacheMemberInfos = self.CachedTeamMemberInfos[EntityID]
    if (CacheMemberInfos == nil) then
        return false
    end
    local MemberActor = ActorUtil.GetActorByEntityID(EntityID)
    if (MemberActor == nil) then
        return false
    end

    for _, MemberInfo in ipairs(CacheMemberInfos) do
        self:ProcessPlayerPossessableActor(MemberActor, MemberInfo.Guid, MemberInfo.SequenceName, true)
        MemberActor:DoSequenceEnter()
    end

    return true
end

function SequencePlayerBase:InitPossessableActors()
    --读取standposition对应的Actor
    if (self.PossessableActorTArray == nil) then
        self.PossessableActorTArray = _G.UE.TArray(_G.UE.FStoryInputActorsInfo)
    else
        self.PossessableActorTArray:Clear()
    end

    --layerset restore的时候会延迟执行，如果此时又播放新的sequence，先执行下
    _G.StoryMgr:RestoreVisionActorsTransform()

    self.CachedTeamMemberInfos = {}
    self.CachedAvatarsToAssemble = {}
    self.WaitAvatarsToAssembleCount = 0

    local CharacterInfosArray = self.SequenceActor:GetAllCharacterInfos(self.SequenceCfg.StartFrameNumber)
    local CharacterInfoCnt = CharacterInfosArray:Length()

    local MemberEntityIDList = {}
    local MajorRoleID = MajorUtil.GetMajorRoleID()
    --切场景，此时队友可能还未在视野内
    for _, RoleID, EntityID in TeamHelper.GetTeamMgr():IterTeamMembers() do
		if RoleID ~= MajorRoleID then
            if (EntityID ~= nil and EntityID > 0) then
                table.insert(MemberEntityIDList, EntityID)
            end
        end
    end
    
    -- 只有ncut走这段
    if self.SequenceCfg.bIsNcut
    and (self.SequenceCfg.SceneCharacterShowType == ProtoRes.dialogue_scene_character_show_type.HIDE_ALL_EXCEPT_NPC
    or self.SequenceCfg.SceneCharacterShowType == ProtoRes.dialogue_scene_character_show_type.SHOW_ALL) then
        -- 现在actor全部重新创建了，在 HideOtherCharacters 之前先隐藏重复resid的actor，避免创建npc后表现异常
        for i = 1, CharacterInfoCnt, 1 do
            local CharacterInfo = CharacterInfosArray:Get(i)
            if CharacterInfo.ActorType == _G.UE.ESequenceActorType.NPC then
                self.ResIDForbiddenInSequence[CharacterInfo.ResID] = true
                local ActorList = _G.UE.UActorManager.Get():GetActorsByResID(CharacterInfo.ResID)
                local ActorCnt = ActorList:Length()
                for j = 1, ActorCnt do
                    local Actor = ActorList:Get(j)
                    if (Actor ~= nil and _G.CommonUtil.IsObjectValid(Actor)) then
                        local EntityID = Actor:GetActorEntityID()
                        self.ActorsForbiddenInSequence[EntityID] = true
                        Actor:SetForbiddenInSequence(true)
                        ActorManager:Get():HideActor(EntityID, true)
                    end
                end
            end
        end
    end

    local bCacheMajorTransform = true
    --子Sequence在列表前面，这里用倒序遍历比较好，先创建最外层主Sequence的对象，防止后面的子Sequence复用前面的（二者都需要显示的情况下），但是策划没按这个规则配置了太多内容
    --只能先用保持顺序遍历方式，碰到复用错误的时候 需要让策划改resid
    for i = 1, CharacterInfoCnt, 1 do
    --for i = CharacterInfoCnt, 1, -1 do
        local CharacterInfo = CharacterInfosArray:Get(i)
        --npc或者怪物
        if CharacterInfo.ActorType == _G.UE.ESequenceActorType.MONSTER
        or CharacterInfo.ActorType == _G.UE.ESequenceActorType.NPC
        or CharacterInfo.ActorType == _G.UE.ESequenceActorType.COMPANION
        or CharacterInfo.ActorType == _G.UE.ESequenceActorType.EOBJ then
            self:ProcessMonsterPossessableActor(CharacterInfo.ResID, i, CharacterInfo.ActorType, CharacterInfo.Guid, CharacterInfo.SequenceName, CharacterInfo.PossessableTag,
            self.SequenceCfg.OnPossessTarget)

        --主角
        elseif (CharacterInfo.ActorType == _G.UE.ESequenceActorType.MAJOR) then
            self:ProcessMajorPossessableActor(CharacterInfo.Guid, CharacterInfo.SequenceName, bCacheMajorTransform)

        --玩家
        elseif (CharacterInfo.ActorType == _G.UE.ESequenceActorType.PLAYER) then
            --配置了玩家资源ID, 默认使用队伍数据
            local PossessableActor = nil
            local MemberEntityID = MemberEntityIDList[CharacterInfo.ResID]
            if (MemberEntityID ~= nil and MemberEntityID ~= 0) then
                PossessableActor = ActorUtil.GetActorByEntityID(MemberEntityID)
                if (PossessableActor == nil) then
                    local CacheMemberInfos = self.CachedTeamMemberInfos[MemberEntityID]
                    if (CacheMemberInfos == nil) then
                        CacheMemberInfos = {}
                    end
                    local CacheMemberInfo = TempMemberCacheInfo.New()
                    CacheMemberInfo.Guid = CharacterInfo.Guid
                    CacheMemberInfo.ResID = CharacterInfo.ResID
                    CacheMemberInfo.SequenceName = CharacterInfo.SequenceName
                    table.insert(CacheMemberInfos, CacheMemberInfo)
                    self.CachedTeamMemberInfos[MemberEntityID] = CacheMemberInfos
                end
            end

            self:ProcessPlayerPossessableActor(PossessableActor, CharacterInfo.Guid, CharacterInfo.SequenceName, false)

        --武器
        elseif (CharacterInfo.ActorType == _G.UE.ESequenceActorType.WEAPON) then
            self:ProcessWeaponPossessableActor(CharacterInfo.WeaponInfo, CharacterInfo.ActorType, CharacterInfo.Guid, CharacterInfo.SequenceName, i, CharacterInfo.PossessableTag)
        end
    end

    --创建完actor后，强制update下，防止loading界面的时候视野优化的定时器不执行
    _G.UE.UVisionMgr.Get():ForceUpdate()
end

-- 播放Sequence的过程中出现Actor的刷新, 更新一下缓存数据
function SequencePlayerBase:UpdatePossessableActorInfo(Actor, OldEntityID, NewEntityID)
    if (Actor == nil or OldEntityID == nil or NewEntityID == nil or self.PossessableActorTArray == nil) then
        return
    end
    local PossessableCnt = self.PossessableActorTArray:Length()
    for i = 1, PossessableCnt do
        local PossessableActor = self.PossessableActorTArray:Get(i)
        if PossessableActor ~= nil and PossessableActor.EntityID == OldEntityID then
            PossessableActor.Actor = Actor
            PossessableActor.EntityID = NewEntityID
            -- 可以考虑把之前无效的数据清除掉, 暂时先直接把新的加进去
            if self.SequenceActor ~= nil then
                self.SequenceActor:UpdatePossessableActor(PossessableActor)
            end
        end
    end
end

function SequencePlayerBase:AddPossessableActorInfo(Actor, Guid, SequenceName, bCacheTransform, bUpdatePossessable, bCreatedInSeq)
    if (Actor == nil or self.PossessableActorTArray == nil) then
        return
    end

    local ActorsInfo = _G.UE.FStoryInputActorsInfo()
    ActorsInfo.Actor = Actor
    ActorsInfo.Guid = Guid
    ActorsInfo.SequenceName = SequenceName
    ActorsInfo.bCreatedInSeq = bCreatedInSeq
    ActorsInfo.EntityID = ActorUtil.GetActorEntityID(Actor)
    self.PossessableActorTArray:Add(ActorsInfo)

    if (self.SequenceActor ~= nil and bUpdatePossessable) then
        self.SequenceActor:UpdatePossessableActor(ActorsInfo)
    end
    
    local bHasCached = _G.StoryMgr:HasCachedVisionActorTransform(Actor)
    if (bCacheTransform and not bHasCached) then
        _G.StoryMgr:CacheVisionActorTransform(Actor)
    end
end

function SequencePlayerBase:CreateClientActor(ResID, ListID, SeqActorType)
    local ActorType = _G.UE.EActorType.Npc
    if (SeqActorType == _G.UE.ESequenceActorType.MONSTER) then
        ActorType = _G.UE.EActorType.Monster

    elseif (SeqActorType == _G.UE.ESequenceActorType.WEAPON) then
        ActorType = _G.UE.EActorType.ClientShow

    elseif (SeqActorType == _G.UE.ESequenceActorType.EOBJ) then
        ActorType = _G.UE.EActorType.EObj

    elseif (SeqActorType == _G.UE.ESequenceActorType.COMPANION) then
        ActorType = _G.UE.EActorType.Companion
    end

     --手机包编译问题 有可能导致为nil
    if (ActorType == nil) then
        _G.FLOG_ERROR("Amazing, ActorType is null !!!!!!!!!!!!!!!!!!!!!!!SeqActorType=" .. tostring(SeqActorType))
    end

    local Actor = nil
    if (ActorType ~= nil and ActorType ~= _G.UE.EActorType.MaxType) then
        local Location = ZeroLocation
        local Rotator = ZeroRotator
        --MapEditorID 需要大于0
        local EntityID = ActorManager:Get():CreateClientActorForSeq(ActorType, ListID, ResID, Location, Rotator)
        if (EntityID > 0) then
            Actor = ActorUtil.GetActorByEntityID(EntityID)
            -- npc使用最普遍，只记录npc模型组装，先不管怪物或其他actor
            if Actor ~= nil and (ActorType == _G.UE.EActorType.Npc) then
                self.CachedAvatarsToAssemble[EntityID] = ActorType

                self.WaitAvatarsToAssembleCount = self.WaitAvatarsToAssembleCount + 1
            end
        end
    end

    return Actor
end

--npc或者怪物等资源表配置的id
function SequencePlayerBase:ProcessMonsterPossessableActor(ResID, ListID, ActorType, Guid, SequenceName, PossessableTag, OnPossessTarget)
    if (ResID <= 0) then
        return
    end

    local Target = nil
    local bCacheTransform = false
    local IsValidTag = (PossessableTag ~= nil and PossessableTag ~= "")
    if IsValidTag then
        if (self.CachedPossessableObjectForTag == nil) then
            self.CachedPossessableObjectForTag = {}
        else
            Target = self.CachedPossessableObjectForTag[PossessableTag]
        end
    end

    if (self.CachedPossessableActorsForSeq == nil) then
        self.CachedPossessableActorsForSeq = {}
    end
    local CachedPossessableActors = self.CachedPossessableActorsForSeq[SequenceName]
    if (CachedPossessableActors == nil) then
        CachedPossessableActors = {}
        self.CachedPossessableActorsForSeq[SequenceName] = CachedPossessableActors
    end

    if (Target == nil) then
        --其他shot Sequence里创建的相同ResID对象列表
        local OtherCachedPossessableResIDActors = {}
        for OtherSeqName, OtherCachedPossessableActors in pairs(self.CachedPossessableActorsForSeq) do
            if (OtherSeqName ~= SequenceName) then
                for _, CachedPossessableActor in ipairs(OtherCachedPossessableActors) do
                    if (CachedPossessableActor ~= nil and _G.CommonUtil.IsObjectValid(CachedPossessableActor)) then
                        local AttributeComp = CachedPossessableActor:GetAttributeComponent()
                        if (AttributeComp ~= nil and ResID == AttributeComp.ResID) then
                            table.insert(OtherCachedPossessableResIDActors, CachedPossessableActor)
                        end
                    end
                end
            end
        end

        if not self.SequenceCfg.bIsNcut then
            local ActorList = _G.UE.UActorManager.Get():GetActorsByResID(ResID)
            local ActorCnt = ActorList:Length()
            for i = 1, ActorCnt do
                Target = ActorList:Get(i)

                if (CachedPossessableActors ~= nil) then
                    for _, PossessableActor in pairs(CachedPossessableActors) do
                        if (PossessableActor ~= nil and Target == PossessableActor) then
                            Target = nil
                            break
                        end
                    end
                end

                if (Target ~= nil) then
                    --只缓存从视野里取的
                    bCacheTransform = true
                    break
                end
            end
        end

        for _, OtherCachedPossessableActor in ipairs(OtherCachedPossessableResIDActors) do
            Target = OtherCachedPossessableActor

            --检测是否已经在当前sequence中使用了，比如：泰坦中配置了多个相同resid的怪物
            if (CachedPossessableActors ~= nil) then
                for _, PossessableActor in pairs(CachedPossessableActors) do
                    if (PossessableActor ~= nil and Target == PossessableActor) then
                        Target = nil
                        break
                    end
                end
            end

            if (Target ~= nil) then
                break
            end
        end
    end

    local bCreatedInSeq = false
    if (Target == nil) then
        --todo 客户端本地创建
        Target = self:CreateClientActor(ResID, ListID, ActorType)
        bCacheTransform = false
        bCreatedInSeq = true

		_G.UE.UVisionMgr.Get():RemoveFromVision(Target)
    end

    if (Target ~= nil) then
        if IsValidTag then
            self.CachedPossessableObjectForTag[PossessableTag] = Target
        end

        if (CachedPossessableActors) then
            table.insert(CachedPossessableActors, Target)
        end

        self:AddPossessableActorInfo(Target, Guid, SequenceName, bCacheTransform, false, bCreatedInSeq)

        if OnPossessTarget ~= nil then
            OnPossessTarget(Target, ResID, ListID, ActorType)
        end
    end
end

--武器变体模型
function SequencePlayerBase:ProcessWeaponPossessableActor(WeaponInfo, ActorType, Guid, SequenceName, ListID, PossessableTag)
    local Target = nil
    local IsValidTag = (PossessableTag ~= nil and PossessableTag ~= "")
    if IsValidTag then
        if (self.CachedPossessableObjectForTag == nil) then
            self.CachedPossessableObjectForTag = {}
        else
            Target = self.CachedPossessableObjectForTag[PossessableTag]
        end
    end

    if (Target == nil) then
        Target = self:CreateClientActor(0, ListID, ActorType)
    end

    if (Target ~= nil) then
        if IsValidTag then
            self.CachedPossessableObjectForTag[PossessableTag] = Target
        end

        local ModelPath = string.format("w%04d", WeaponInfo.SkeletonId)
        local SubModelPath = string.format("b%04d", WeaponInfo.PatternId)
        Target:GetAvatarComponent():LoadMeshAvatar(ModelPath, SubModelPath, WeaponInfo.ImageChangeId, WeaponInfo.StainingId)
        -- 武器没有种族值,不设置AttachType的话运行时特效挂接会有问题
        Target:GetAvatarComponent():SetAttachType(ModelPath)
        self:AddPossessableActorInfo(Target, Guid, SequenceName, false, false, true)
    end
end

--主角的ResID需配置为-1(主角和玩家的ResID没啥用了，改成ActorType判断)
function SequencePlayerBase:ProcessMajorPossessableActor(Guid, SequenceName, bCacheMajorTransform)
    local Major = MajorUtil.GetMajor()
    self.bPossessableActorWithMajor = true
    self:AddPossessableActorInfo(Major, Guid, SequenceName, bCacheMajorTransform, false, false)
end

--玩家的ResID配置为1-10，为队伍队列索引值
function SequencePlayerBase:ProcessPlayerPossessableActor(PossessableActor, Guid, SequenceName, bUpdatePossessable)
    if (PossessableActor ~= nil) then
        self:AddPossessableActorInfo(PossessableActor, Guid, SequenceName, true, bUpdatePossessable, false)
    end
end

function SequencePlayerBase:IsPlayingStatus()
    local SequencePlayer = self:GetLevelSequencePlayer()
    if (SequencePlayer ~= nil) then
        return SequencePlayer:IsPlaying()
    end

    return false
end

function SequencePlayerBase:IsPausedStatus()
    local SequencePlayer = self:GetLevelSequencePlayer()
    if (SequencePlayer ~= nil) then
        return SequencePlayer:IsPaused()
    end

    return false
end

function SequencePlayerBase:AddLatentAction(LatentAction)
    if (self.SequenceActor) then
        self.SequenceActor:AddLatentAction(LatentAction)
    end
end

function SequencePlayerBase:PlayToSeconds(TimeInSeconds)
    local SequencePlayer = self:GetLevelSequencePlayer()
    if (SequencePlayer ~= nil) then
        SequencePlayer:PlayToSeconds(TimeInSeconds)
    end
end

function SequencePlayerBase:ScrubSequence()
    local SequencePlayer = self:GetLevelSequencePlayer()
    if (SequencePlayer ~= nil) then
        SequencePlayer:Scrub()
    end
end

function SequencePlayerBase:PauseSequence()
    local SequencePlayer = self:GetLevelSequencePlayer()
    if (SequencePlayer ~= nil) then
        SequencePlayer:Pause()
    end
end

function SequencePlayerBase:ContinueSequence()
    local SequencePlayer = self:GetLevelSequencePlayer()
    if (SequencePlayer ~= nil) then
        SequencePlayer:Play()
    end
end

function SequencePlayerBase:OnSequenceStopedInException()
    if (self.StopCallbackWhenException ~= nil) then
        self:OnSequenceFinishProcess()
        self:OnStop()

        self.StopCallbackWhenException(false)
        self.StopCallbackWhenException = nil
    end
end

function SequencePlayerBase:IsSequenceStopedInException()
    return self.SequenceStopedInException
end

function SequencePlayerBase:StopSequenceInException()
    self.SequenceStopedInException = true
    --sequence已经执行了Play()
    if (self:IsPlayingStatus() or self:IsPausedStatus()) then
        local SequencePlayer = self:GetLevelSequencePlayer()
        if (SequencePlayer ~= nil) then
            SequencePlayer:Stop() --Stop不一定当前帧能够执行
        else
            self:OnSequenceStopedInException()
        end
    else
        _G.FLOG_INFO("StopSequenceInException: sequence not playing!")
        self:OnSequenceStopedInException()
    end
end

--手动执行跳过sequence
function SequencePlayerBase:StopSequence(bClickButtonSkip)
    local SequencePlayer = self:GetLevelSequencePlayer()
    if (SequencePlayer ~= nil) then
        self.ManualStopSequence = true
        self.bClickButtonSkip = bClickButtonSkip

        if bClickButtonSkip then
            self:FindSequenceSkipGroup()
        end

        SequencePlayer:Stop() --Stop不一定当前帧能够执行

        _G.EventMgr:SendEvent(_G.EventID.StopSequenceHalfway, bClickButtonSkip)

        self.bClickButtonSkip = false
    end
end

function SequencePlayerBase:FindSequenceSkipGroup()
    local StoryMgr = _G.StoryMgr
    StoryMgr.SkipGroupSeqIDs = {}
    if not self.SequenceCfg then
        return
    end

    -- 读表记录动画分组，下次播动画时检查分组
    local CfgOnSeq = SequenceSkipGroupCfg:FindCfgByKey(self.SequenceCfg.SequenceID);
    if (nil == CfgOnSeq) or (nil == CfgOnSeq.SkipGroupID) then
        return
    end

    local Condition = "SkipGroupID = "..(CfgOnSeq.SkipGroupID)
    local Cfgs = SequenceSkipGroupCfg:FindAllCfg(Condition);
    if (nil == Cfgs) then
        return
    end

    for _, Cfg in ipairs(Cfgs) do
        table.insert(StoryMgr.SkipGroupSeqIDs, Cfg.SequenceID)
    end
end

function SequencePlayerBase:AdjustCharactersPostion()
    if (self.SequenceActor) then
        self.SequenceActor:AdjustCharactersPostion()
    end
end

--设置是否继续播放下一段sequence
function SequencePlayerBase:SetIsPlayNext(Value)
    self.bIsPlayNext = Value
end

--设置是否中断多段播放
function SequencePlayerBase:SetIsInterruptMultiPlay(Value)
    self.bIsInterruptMultiPlay = Value
end

function SequencePlayerBase:HasEnableSkipStart()
    if self:SequenceActorIsValid() then
        return self.SequenceActor:HasEnableSkipStart()
    end
    return false
end

-- ---------------------------------------------------- --------------------------------------------------
-- 片尾动画
-- ---------------------------------------------------- --------------------------------------------------

function SequencePlayerBase:ShowStaffRoll()
    if not _G.UIViewMgr:IsViewVisible(UIViewID.StaffRollMainPanel) then
        _G.UIViewMgr:ShowView(UIViewID.StaffRollMainPanel)
    end
    SequencePlayerVM:UpdateStaffRollInfo()

    -- 播放片尾动画的时候屏蔽下环境和技能音效
    _G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Ambient_Sound, 0)
    _G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Sfx, 0)
end

function SequencePlayerBase.HideStaffRoll()
    SequencePlayerVM:HideStaffRollPanel()

    -- 播放片尾动画完成后，恢复环境和技能音效
    _G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Ambient_Sound, 1)
    _G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Sfx, 1)
end

-- ---------------------------------------------------- --------------------------------------------------

return SequencePlayerBase
