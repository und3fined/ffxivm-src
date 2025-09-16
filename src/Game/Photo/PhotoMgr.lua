local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local PhotoRoleStatCfg = require("TableCfg/PhotoRoleStatCfg")
local UIUtil = require("Utils/UIUtil")

local EventID = require("Define/EventID")

local CommonUtil = require("Utils/CommonUtil")
local PhotoMediaUtil = require("Game/Photo/Util/PhotoMediaUtil")

local PhotoCameraUtil = require("Game/Photo/Util/PhotoCameraUtil")
local PhotoEffectUtil = require("Game/Photo/Util/PhotoEffectUtil")
local PhotoSceneUtil = require("Game/Photo/Util/PhotoSceneUtil")
local PhotoDefine = require("Game/Photo/PhotoDefine")

local PhotoMouthMoveCfg = require("TableCfg/PhotoMouthMoveCfg")
local PhotoEndueCfg = require("TableCfg/PhotoEndueCfg")
local PhotoTemplateUtil = require("Game/Photo/Util/PhotoTemplateUtil")

local PhotoActorAgent = require("Game/Photo/PhotoActorAgent")

local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local EmotionAnimUtils = require("Game/Emotion/Common/EmotionAnimUtils")
local ActiontimelinePathCfg = require("TableCfg/ActiontimelinePathCfg")
local AnimationUtil = require("Utils/AnimationUtil")
local UIViewID = require("Define/UIViewID")
local ProtoRes = require("Protocol/ProtoRes")
local PhotoActorUtil = require("Game/Photo/Util/PhotoActorUtil")
local MainPanelVID = UIViewID.MainPanel
local PhotoVID = UIViewID.PhotoMain
local UIViewMgr
local EventMgr
-- local PrintTable = _G.table_to_string_block
local PhotoVM
local AnimMgr
local PhotoCamVM
local PhotoRoleSettingVM
local PhotoSceneVM
local PhotoFilterVM
local PhotoTemplateVM
local PhotoDarkEdgeVM
local PhotoActionVM
local PhotoEmojiVM
local CommonDefine = require("Define/CommonDefine")
local DataReportUtil = require("Utils/DataReportUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ClientReportType = ProtoCS.ReportType

local Weather = require("Game/Weather/Weather")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")

local GameNetworkMgr
local TeamMgr
local ObjectGCType = require("Define/ObjectGCType")

local HUDMgr

local PhotoTemplateCfg = require("TableCfg/PhotoTemplateCfg")
local PhotoFilterCfg = require("TableCfg/PhotoFilterCfg")

-- local PWorldQuestDefine = require("Game/PWorld/Quest/PWorldQuestDefine")
local ProtoCS = require("Protocol/ProtoCS")

local MAIN_CMD = ProtoCS.CS_CMD.CS_CMD_PHOTOS
local SUB_CMD = ProtoCS.Role.Photos.PhotosOptCmd

local Json = require("Core/Json")

local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoRes = require("Protocol/ProtoRes")
local PhotoUtil = require("Game/Photo/PhotoUtil")

local ShowTips = MsgTipsUtil.ShowTips

local WARN = _G.FLOG_WARNING
local ERR = _G.FLOG_ERROR
local LOG = _G.FLOG_INFO

local PhotoMgr = LuaClass(MgrBase)


function PhotoMgr:OnInit()
    self:InitLocalValue()
end

function PhotoMgr:OnBegin()

    self.TemplateMap = {
        PhotoCamVM          = PhotoCamVM,
        -- PhotoRoleSettingVM  = PhotoRoleSettingVM,
        PhotoSceneVM        = PhotoSceneVM,
        PhotoFilterVM       = PhotoFilterVM,
        PhotoDarkEdgeVM     = PhotoDarkEdgeVM,
        PhotoActionVM     = PhotoActionVM,
        PhotoEmojiVM     = PhotoEmojiVM,
        PhotoVM          = PhotoVM,
    }

    self:BeginTemplate()
    self:BeginRoleEffect()
    self:BeginAnim()
end

function PhotoMgr:OnEnd()

end

function PhotoMgr:OnShutdown()
end

function PhotoMgr:OnRegisterNetMsg()
    self:OnRegisterNetMsgTemplate()
end

function PhotoMgr:OnRegisterGameEvent()
    -- @todo 把事件移到photo main panel
    self:RegisterGameEvent(EventID.TrivialCombatStateUpdate,    self.OnEveCombatStat)
    self:RegisterGameEvent(EventID.SelectTarget,                self.OnEveSelt)
    self:RegisterGameEvent(EventID.TeamLeave,                   self.OnEveTeamChg)
    self:RegisterGameEvent(EventID.TeamJoin,                    self.OnEveTeamChg)
    self:RegisterGameEvent(EventID.ActorVelocityUpdate,         self.OnEveMoveChg)
end

function PhotoMgr:Reset()
    self.SeltEntID = nil
    self.CastInfo = nil
    self.IsOnPhoto = false
    self.SeltHdl = nil
end

function PhotoMgr:InitLocalValue()
    GameNetworkMgr = _G.GameNetworkMgr
    TeamMgr = _G.TeamMgr

    -- PWorldQuestVM = _G.PWorldQuestVM
    UIViewMgr = _G.UIViewMgr
    EventMgr = _G.EventMgr
    PhotoVM = _G.PhotoVM    
    AnimMgr = _G.AnimMgr
    PhotoVM = _G.PhotoVM   
    UIViewMgr       = _G.UIViewMgr
    EventMgr        = _G.EventMgr
    PhotoVM         = _G.PhotoVM   
    HUDMgr = _G.HUDMgr
    
    PhotoCamVM              = _G.PhotoCamVM 
    PhotoRoleSettingVM      = _G.PhotoRoleSettingVM 
    PhotoSceneVM            = _G.PhotoSceneVM 
    PhotoFilterVM           = _G.PhotoFilterVM 
    PhotoTemplateVM         = _G.PhotoTemplateVM
    PhotoDarkEdgeVM         = _G.PhotoDarkEdgeVM
    PhotoActionVM           = _G.PhotoActionVM
    PhotoEmojiVM            = _G.PhotoEmojiVM
end

-- function PhotoMgr:OnTimer()
-- end

-------------------------------------------------------------------------------------------------------
---@region SelectActor


function PhotoMgr:OnTimerSelt()
	EventMgr:SendEvent(EventID.UnSelectTarget, {ULongParam1 = self.SeltEntID})
end

function PhotoMgr:EndSeltTimer()
    if self.SeltHdl then
        self:UnRegisterTimer(self.SeltHdl)
        self.SeltHdl = nil
    end
end

function PhotoMgr:CancelSelt()
    local EventParams = _G.EventMgr:GetEventParams()
    EventParams.ULongParam1 = 0
    _G.EventMgr:SendCppEvent(_G.EventID.ManualUnSelectTarget, EventParams)
end

-------------------------------------------------------------------------------------------------------
---@region EveHdl

function PhotoMgr:OnEveCombatStat(Params)
	local EntityID = Params.ULongParam1
    local MajorEntityID = MajorUtil.GetMajorEntityID()

    if EntityID == MajorEntityID then
	    local IsCombatState = ActorUtil.IsCombatState(MajorEntityID)
        if IsCombatState and UIViewMgr:IsViewVisible(PhotoVID) then
            self:ClosePhotoUI()
        end
    end
end

function PhotoMgr:OnEveSelt(Params)
    if not self.IsOnPhoto then
        return
    end
	self:EndSeltTimer()
    self:SetSeltEntID(Params.ULongParam1)

    self.SeltHdl = self:RegisterTimer(self.OnTimerSelt, 2, 0, 1)
end

function PhotoMgr:OnEveTeamChg()
    PhotoVM:UpdCanGiveAll()
end

function PhotoMgr:OnEveMoveChg(Params)
    local EntID = Params.ULongParam1

    -- todo 暂时先屏蔽掉非选中单位,后面会专门处理角色的状态
    if not EntID or EntID ~= self.SeltEntID then
        return
    end

    _G.PhotoRoleStatVM:TryRptStat()

    local bNowZero = Params.BoolParam1

    if bNowZero then
        return
    end

    if self:IsCurSeltMajor() then
        PhotoVM:TryRptPause()
        _G.PhotoRoleSettingVM:SetMajorAngleIdx(0.5, true)
    end
end

-------------------------------------------------------------------------------------------------------
---@region UI显示隐藏

function PhotoMgr:TryOpenPhotoUI()
    if not _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_PHOTO, true) then
        return
    end

    if _G.ChocoboTransportMgr:GetIsTransporting() then
	    ShowTips(LSTR(630059))
        return
    end

    if _G.SettingsMgr:IsPerforcemanceMode() then
	    MsgTipsUtil.ShowTipsByID(174002)
    end

    local MajorEntityID = MajorUtil.GetMajorEntityID()
	local IsCombatState = ActorUtil.IsCombatState(MajorEntityID)

    if not IsCombatState then
        self:OnOpenPhotoUI()
        UIViewMgr:ShowView(PhotoVID)
        return true
    end

	ShowTips(LSTR(630012))
    return false
end

function PhotoMgr:OnOpenPhotoUI()
    self.IsOnPhoto = true
    self:RecordStat()

    do
        local _ <close> = CommonUtil.MakeProfileTag("[Photo][PhotoMgr][OnOpenPhotoUI]")
        self:AddFilterLevel()
        self:StartRoleAniTime()
        self:LoadDarkEdgeLevel()
        self:SetSceneActorLOD(false)
        self:SetMajorOnlineStat(true)
        self:ReqGetPhotoTemplate()
        self:SetMajorLookCamera()

        local MajorID = MajorUtil.GetMajorEntityID()

        -- 之前有个优化把选中改成异步的，这里处理下
        self.SeltEntID = MajorID
        _G.SelectTargetMgr:SkillSelectTarget(MajorID)

        HUDMgr:SetIsDrawHUD(false)
        HUDMgr:SetPlayerInfoVisible(false)
        HUDMgr:SetActorInfoVisible(false)
        _G.TargetMgr:SetHardLockEffectMask(CommonDefine.HardLockEffectMaskType.Photo, true)
        
        _G.NaviDecalMgr:SetNavPathHiddenInGame(true)
        _G.NaviDecalMgr:DisableTick(true)
        
        -- _G.UE.USettingUtil.ExeCommand("r.ScreenPercentage", 200)
        LOG('[Photo][PhotoMgr][OnOpenPhotoUI]')
    end

    self:ConvertAndSetConfigTemplate()
    --
    EventMgr:SendEvent(EventID.PhotoStart)
	EventMgr:SendCppEvent(EventID.PhotoStartCpp)
    self:TLogShowView()
end

function PhotoMgr:ClosePhotoUI()
    UIViewMgr:HideView(PhotoVID)
    self:OnClosePhotoUI()
end

function PhotoMgr:OnClosePhotoUI()
    self:ResumeStat()
    do
        local _ <close> = CommonUtil.MakeProfileTag("[Photo][PhotoMgr][OnClosePhotoUI]")
        self:EndDOFTimer()
        self:CheckAndClearRoleEff(true)

        self:StopRoleAniTime()
        self:RemoveDarkEdgeLevel()

        self:EndSeltTimer()
        self:CancelSelt()
        self:RemFilterLevel()
        self:SetSceneActorLOD(true)
        self:SetMajorOnlineStat(false)

        self:EndNPCLookAt()
        self:ShowAllActor() --显示隐藏的Actor

        HUDMgr:SetIsDrawHUD(true)
        HUDMgr:SetPlayerInfoVisible(true)
        HUDMgr:SetActorInfoVisible(true)
        _G.TargetMgr:SetHardLockEffectMask(CommonDefine.HardLockEffectMaskType.Photo, false)

        _G.NaviDecalMgr:SetNavPathHiddenInGame(false) 
        _G.NaviDecalMgr:DisableTick(false)

        self:TryClearAniEntList()
        self:ResumeActorPause()
        _G.PhotoActionVM:ResetRoleActAni()
        _G.PhotoEmojiVM:ResetRoleActAni()

        self:ResetLookAt()
        self.SeltEntID = nil

        -- _G.UE.USettingUtil.ExeCommand("r.ScreenPercentage", 100)
        LOG('[Photo][PhotoMgr][OnClosePhotoUI]')
    end

    PhotoActorUtil.PauseAllActorAnim(false)
    self.IsOnPhoto = false

    EventMgr:SendEvent(EventID.PhotoEnd)
	EventMgr:SendCppEvent(EventID.PhotoEndCpp)
end

function PhotoMgr:PostClosePhotoUI()
    if not self.IsOnPhoto then
        return
    end
    self:ClosePhotoUI()
end

-------------------------------------------------------------------------------------------------------
---@region 拍照角色角色管理

---@return PhotoActorAgent
function PhotoMgr:GetActorAgent(EntityID)
    self.AgentPool = {}
    self.AgentMap = {}

    if self.AgentMap[EntityID] then
        return self.AgentMap[EntityID]
    end

    local Ret
    if #self.AgentPool == 0 then
        Ret = PhotoActorAgent.New()
    else
        Ret = table.remove(self.AgentPool)
    end

    self.AgentMap[EntityID] = Ret

    Ret:Init(EntityID)

    return Ret
end

function PhotoMgr:ClearActorAgent(EntityID)
    for _, Agent in pairs(self.AgentMap) do
        Agent:End()
        table.insert(self.AgentPool, Agent)
    end 

    self.AgentMap = {}
end

function PhotoMgr:EndNPCLookAt()
    local NPCList = self.LookatNPCList
    for _, NPC in pairs(NPCList or {}) do
        --ActorUtil.SetCharacterLookAtCamera(NPC, _G.UE.ELookAtType.None)
        self:SetNpcLookAt(NPC, false)
        NPC:GetThinkComponent():SetEnableLookAtTick(true)
    end
    self.LookatNPCList = nil
end

function PhotoMgr:StartNPCLookAt()
    self:EndNPCLookAt()
    -- local ActorUtil = require("Utils/ActorUtil")
    local NPCList = PhotoActorUtil.GetNPCs()
    self.LookatNPCList = NPCList
    for _, NPC in pairs(NPCList) do
        NPC:GetThinkComponent():SetEnableLookAtTick(false)
        --ActorUtil.SetCharacterLookAtCamera(NPC, _G.UE.ELookAtType.HeadAndEye)
        self:SetNpcLookAt(NPC, true)
    end
end

function PhotoMgr:SetNpcLookAt(Character, bOpen)
    local NpcParams = _G.UE.FLookAtParams()
    NpcParams.LookAtType = _G.UE.ELookAtType.ALL
	NpcParams.Target.Type = bOpen and _G.UE.ELookAtTargetType.Camera or _G.UE.ELookAtTargetType.None
    NpcParams.bUseBlendPose = true
	ActorUtil.SetCharacterLookAtParams(Character, NpcParams)
end

-------------------------------------------------------------------------------------------------------
---@region 选中角色

-- function PhotoMgr:ShowAllActor()
--     local Reason = _G.UE.EHideReason.Common
--     local All = PhotoActorUtil.GetAllActor()
--     for _, Actor in pairs(All) do
--         Actor:SetVisibility(true, Reason, true)
--     end
-- end

-------------------------------------------------------------------------------------------------------
---@region 隐藏

function PhotoMgr:ShowAllActor()
    local Reason = _G.UE.EHideReason.Common
    local All = PhotoActorUtil.GetAllActor()
    for _, Actor in pairs(All) do
        Actor:SetVisibility(true, Reason, true)
    end
end

-------------------------------------------------------------------------------------------------------
---@region 选中

function PhotoMgr:ResumeActorPause()
    local Major = MajorUtil.GetMajor()
    local AnimComp = Major:GetAnimationComponent()
    if AnimComp then
        AnimComp:PauseAnimation(false);
    end
end


function PhotoMgr:IsCurSeltMajor()
    return self.SeltEntID == MajorUtil.GetMajorEntityID()
end

function PhotoMgr:IsCurSeltPlayer()
    local Actor = ActorUtil.GetActorByEntityID(self.SeltEntID)
    if not Actor then return end
    local AttrComponent = Actor:GetAttributeComponent()
    if AttrComponent then
        local ActorType = AttrComponent:GetActorType()
        return ActorType == _G.UE.EActorType.Player or ActorType == _G.UE.EActorType.Major
    end
end

function PhotoMgr:SetSeltEntID(EntID)
    -- if self.SeltEntID and self.SeltEntID ~= EntID then
    --     local EventParams = _G.EventMgr:GetEventParams()
    --     EventParams.ULongParam1 = self.SeltEntID
    --     _G.EventMgr:SendCppEvent(_G.EventID.ManualSelectTarget, EventParams)
    --     return
    -- end
    local IsChg = false
    if self.SeltEntID and self.SeltEntID ~= EntID then
        IsChg = true
        self:OnSeltEntIDChg(EntID)
    end

    self.SeltEntID = EntID

    if IsChg then
        EventMgr:SendEvent(EventID.PhotoSeltEntChg)
    end

    -- local Selt = ActorUtil.GetActorByEntityID(self.SeltEntID)
    -- self:SetActorLookCamera(Selt)
end

function PhotoMgr:OnSeltEntIDChg(EntID)
    local AnimComp = ActorUtil.GetActorAnimationComponent(self.SeltEntID)
    self:StopRoleAllAnim(AnimComp)
    self:RefreshCharacterLookAt()

    if PhotoVM.IsPauseSelect then
        PhotoVM:SetIsPauseSelect(false)
        MsgTipsUtil.ShowTips(LSTR(630048))
    end
    PhotoRoleSettingVM:ResetMajorAngleIdx()
end

function PhotoMgr:SetMajorLookCamera()
    local UMajor = MajorUtil.GetMajor()
    self:SetActorLookCamera(UMajor)
end

function PhotoMgr:SetActorLookCamera(Actor)
    if not Actor then
        return
    end

    local UMajor = MajorUtil.GetMajor()
	local Rot = Actor:FGetActorRotation()
	local CameraControllComponent = UMajor:GetCameraControllComponent()
	CameraControllComponent:SetCameraBoomRelativeRotation(Rot + _G.UE.FRotator(0, 180, 0))
end

function PhotoMgr:RefreshCharacterLookAt()
	local Major = MajorUtil.GetMajor()
    local Selt = nil

    if self.SeltEntID ~= MajorUtil.GetMajorEntityID() then
        Selt = ActorUtil.GetActorByEntityID(self.SeltEntID)
    end

	if PhotoVM.IsFollowWithFace and PhotoVM.IsFollowWithEye then
        self:SetCharacterLookAtCamera(Major, _G.UE.ELookAtType.HeadAndEye)
        self:SetCharacterLookAtCamera(Selt, _G.UE.ELookAtType.HeadAndEye)
	elseif PhotoVM.IsFollowWithEye then
        self:SetCharacterLookAtCamera(Major, _G.UE.ELookAtType.Eye)
        self:SetCharacterLookAtCamera(Selt, _G.UE.ELookAtType.Eye)
	elseif PhotoVM.IsFollowWithFace then
        self:SetCharacterLookAtCamera(Major, _G.UE.ELookAtType.Head)
        self:SetCharacterLookAtCamera(Selt, _G.UE.ELookAtType.Head)
	else
        self:SetCharacterLookAtCamera(Major, _G.UE.ELookAtType.None)
        self:SetCharacterLookAtCamera(Selt, _G.UE.ELookAtType.None)
	end
end

function PhotoMgr:ResetLookAt()
	local Major = MajorUtil.GetMajor()
    local Selt = nil

    if self.SeltEntID ~= MajorUtil.GetMajorEntityID() then
        Selt = ActorUtil.GetActorByEntityID(self.SeltEntID)
    end

    self:CancelLookAt(Major)
    self:CancelLookAt(Selt)
end

function PhotoMgr:CancelLookAt(Actor)
	local LookAtParams = _G.UE.FLookAtParams()
    LookAtParams.LookAtType = _G.UE.ELookAtType.None
    LookAtParams.Target.Type = _G.UE.ELookAtTargetType.None
    ActorUtil.SetCharacterLookAtParams(Actor, LookAtParams)
end

function PhotoMgr:SetCharacterLookAtCamera(Actor, Type)
    if Actor and Type then
        ActorUtil.SetCharacterLookAtCamera(Actor, Type)
    end
end

function PhotoMgr:PauseSeltAnim(IsPause)
    if not self.SeltEntID then
        return
    end

    local Selt = ActorUtil.GetActorByEntityID(self.SeltEntID)
    if Selt then
        PhotoActorUtil.PauseActorAnim(Selt, IsPause)
    end
end


function PhotoMgr:SetActorVisible(Actor, IsOpen)
    if not Actor then
        return
    end

    local Reason = _G.UE.EHideReason.Common
    Actor:SetVisibility(IsOpen, Reason, true)

	local AttrComponent = Actor:GetAttributeComponent()
    if AttrComponent then
        if AttrComponent.EntityID == self.SeltEntID then
            if IsOpen then
                _G.UE.USelectEffectMgr.Get():ShowDecal(true)
            else
                _G.UE.USelectEffectMgr.Get():ShowDecal(false)
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------
---@region 设置角色的LOD

local function GetAllActorAvatarComp()
    local AllActor = PhotoActorUtil.GetAllActorUEArray()
    local Ret = {}
    for I = 1, AllActor:Length() do
        local Actor = AllActor:Get(I)
        if Actor then
            local Comp = Actor:GetAvatarComponent()
            if Comp then
                table.insert(Ret, Comp)
            end
        end
    end

    return Ret
end

---@param IsAuto boolean 拍照时F
function PhotoMgr:SetSceneActorLOD(IsAuto)
    local Idx = IsAuto == true and 0 or 1 -- 0自动， 1即lodlevel0
    local AllAvatarComp = GetAllActorAvatarComp()
    for _, Comp in pairs(AllAvatarComp) do
        Comp:SetForcedLODForAll(Idx)
    end
end

-------------------------------------------------------------------------------------------------------
---@region 设置主角的名牌

function PhotoMgr:SetMajorOnlineStat(IsShow)
    local Type = IsShow and ProtoCS.ReportType.ReportTypeEnterTakePhotos or ProtoCS.ReportType.ReportTypeQuitTakePhotos
    _G.ClientReportMgr:SendClientReport(Type)
    LOG('[Photo][PhotoMgr][SetMajorOnlineStat] IsShow = ' .. tostring(IsShow))
end

-------------------------------------------------------------------------------------------------------
---@region 状态缓存和恢复


function PhotoMgr:RecordStat()
    local _ <close> = CommonUtil.MakeProfileTag("[Photo][PhotoMgr][RecordStat]")

    -- 相机
    PhotoCameraUtil.BeginCameraEnv()
    self.CameraRot = PhotoCameraUtil.GetRatateRoll()
    self.CameraFOV = PhotoCameraUtil.GetFOV()
    self.CameraDOF = PhotoCameraUtil.GetDOFBokeh()
    self.CameraPos = PhotoCameraUtil.GetOffset()
    -- 相机 景深
    local Cam = PhotoCameraUtil.GetCam()
    if Cam then
        local PostProcessSettings = Cam.PostProcessSettings;
        self.CamDOFCache = {
            bOverride_DepthOfFieldScale             = PostProcessSettings.bOverride_DepthOfFieldScale,
            DepthOfFieldScale                       = PostProcessSettings.DepthOfFieldScale,
            bOverride_DepthOfFieldFocalRegion       = PostProcessSettings.bOverride_DepthOfFieldFocalRegion,
            DepthOfFieldFocalRegion                 = PostProcessSettings.DepthOfFieldFocalRegion,
            bOverride_DepthOfFieldFocalDistance     = PostProcessSettings.bOverride_DepthOfFieldFocalDistance,
            DepthOfFieldFocalDistance               = PostProcessSettings.DepthOfFieldFocalDistance,
            MobileBokehDOFScale                     = PostProcessSettings.MobileBokehDOFScale,
            bOverride_MobileBokehDOFScale           = PostProcessSettings.bOverride_MobileBokehDOFScale,
            DepthOfFieldFstop                       = PostProcessSettings.DepthOfFieldFstop,
            bOverride_DepthOfFieldFstop             = PostProcessSettings.bOverride_DepthOfFieldFstop,
            bMobileDiaphragmDOF                     = PostProcessSettings.bMobileDiaphragmDOF,
            bOverride_MobileDiaphragmDOF            = PostProcessSettings.bOverride_MobileDiaphragmDOF,
        }
    end

    LOG('[Photo][PhotoMgr][RecordStat]')
end

function PhotoMgr:ResumeStat()
    if not self.IsOnPhoto then
        return
    end

    local _ <close> = CommonUtil.MakeProfileTag("[Photo][PhotoMgr][ResumeStat]")

    -- 相机
    PhotoCameraUtil.SetRatateRoll(self.CameraRot)
    PhotoCameraUtil.SetFOV(self.CameraFOV)
    PhotoCameraUtil.SetDOFBokehNotVirtual(self.CameraDOF)
    -- 相机 景深
    local Cam = PhotoCameraUtil.GetCam()
    if Cam and self.CamDOFCache then
        local PostProcessSettings = Cam.PostProcessSettings;
        PostProcessSettings.bOverride_DepthOfFieldScale             = self.CamDOFCache.bOverride_DepthOfFieldScale
        PostProcessSettings.DepthOfFieldScale                       = self.CamDOFCache.DepthOfFieldScale
        PostProcessSettings.bOverride_DepthOfFieldFocalRegion       = self.CamDOFCache.bOverride_DepthOfFieldFocalRegion
        PostProcessSettings.DepthOfFieldFocalRegion                 = self.CamDOFCache.DepthOfFieldFocalRegion
        PostProcessSettings.bOverride_DepthOfFieldFocalDistance     = self.CamDOFCache.bOverride_DepthOfFieldFocalDistance
        PostProcessSettings.DepthOfFieldFocalDistance               = self.CamDOFCache.DepthOfFieldFocalDistance
        PostProcessSettings.MobileBokehDOFScale                     = self.CamDOFCache.MobileBokehDOFScale
        PostProcessSettings.bOverride_MobileBokehDOFScale           = self.CamDOFCache.bOverride_MobileBokehDOFScale
        PostProcessSettings.DepthOfFieldFstop                       = self.CamDOFCache.DepthOfFieldFstop
        PostProcessSettings.bOverride_DepthOfFieldFstop             = self.CamDOFCache.bOverride_DepthOfFieldFstop
        PostProcessSettings.bMobileDiaphragmDOF                     = self.CamDOFCache.bMobileDiaphragmDOF
        PostProcessSettings.bOverride_MobileDiaphragmDOF            = self.CamDOFCache.bOverride_MobileDiaphragmDOF
    end
    PhotoCameraUtil.EndCameraEnv()

    -- 摇杆
	CommonUtil.ShowJoyStick()

    -- 天气
    CommonUtil.DisableShowJoyStick(false)
    PhotoSceneUtil.PauseWeather(false)
    PhotoSceneUtil.ExitPhotoWeather()
    self:ResumeCameraPos()

    

    LOG('[Photo][PhotoMgr][ResumeStat]')
end

function PhotoMgr:ResumeCameraPos()
    if self.CameraPos then
        PhotoCameraUtil.SetOffsetVec(self.CameraPos)
    end
    --
end

-------------------------------------------------------------------------------------------------------
---@region 角色动画相关
local AnimType = PhotoDefine.PhotoGiveType

function PhotoMgr:BeginAnim()
    self.AnimDic = {}
    self.AniEntList = {}

    -- use for mount
    self.MouthID = nil
	self.MoveID = nil
	self.EmojiID = nil
	self.ActionID = nil
end

function PhotoMgr:StartRoleAniTime()
    if self.RoleTimeId == nil then
        self.RoleTimeId = _G.TimerMgr:AddTimer(self, self.UpdateRoleAni, 0, 0.1, 0)
    end
end

function PhotoMgr:StopRoleAniTime()
    _G.TimerMgr:CancelTimer(self.RoleTimeId)
    self:AllRoleStopMontage()
    self.RoleTimeId = nil
    self.AnimDic = {}
    self.AniEntList = {}

    -- use for mount
    self.MouthID = nil
	self.MoveID = nil
	self.EmojiID = nil
	self.ActionID = nil
end

function PhotoMgr:GetEmojCfgList()
	local AllEmotion = _G.EmotionMgr:EmotionTab(EmotionDefines.EmotionTypeId.FaceEmotionTab, PhotoUtil.CheckEmo4Photo)
    return AllEmotion
end

function PhotoMgr:GetActionCfgList()
	local AllEmotion = _G.EmotionMgr:EmotionTab(EmotionDefines.EmotionTypeId.OnceEmotionTab, PhotoUtil.CheckEmo4Photo)
    return AllEmotion
end

function PhotoMgr:GetMoveOrMouthList(MoveMouthType)
	local CurList = {}
	if MoveMouthType == PhotoDefine.MoveMouthType.Movement then
        local SearchConditions = "Type == 1"
		CurList = PhotoMouthMoveCfg:FindAllCfg("(" .. SearchConditions .. ") AND Hide != 1")
	elseif MoveMouthType == PhotoDefine.MoveMouthType.Mouth then
        local SearchConditions = "Type == 2"
		CurList = PhotoMouthMoveCfg:FindAllCfg("(" .. SearchConditions .. ") AND Hide != 1")
	end

	-- 排序
	table.sort(CurList,function(l,r)
		local PriorityL = l.SortPriority or 0
		local PriorityR = r.SortPriority or 0
		if PriorityL == PriorityR then
		end
		return PriorityL < PriorityR
	end)

	return CurList
end

function PhotoMgr:UpdateRoleAni()
	-- if self:RoleInPlayingAni(AnimComp) == nil then
        self:PlayPhotoAnim(self.SeltEntID)
    -- end

    if self.AniEntList == nil then
        return
    end

    for i = 1, #self.AniEntList do
		local EntID = self.AniEntList[i]
        if EntID == "MOUNT" then
            local AnimComp = ActorUtil.GetActorAnimationComponent(self.SeltEntID)
	        if self:StopMountMontage(AnimComp) == nil then
                self:PlayPhotoMountAnim(AnimComp)
            end
        else
		    -- if self:RoleInPlayingAni(AnimComp) == nil then
                self:PlayPhotoAnim(EntID)
            -- end
        end
	end
end

function PhotoMgr:CurRoleInPlayingAni()
    local AnimComp = ActorUtil.GetActorAnimationComponent(self.SeltEntID)
    return self:RoleInPlayingAni(AnimComp)
end

function PhotoMgr:GetCurMainAnimInfo()
    local Info = self.AnimDic[AnimType.Action] or self.AnimDic[AnimType.Movement]
    return Info
end

function PhotoMgr:GetCurMainMontage()
    local Info = self:GetCurMainAnimInfo() --self.AnimDic[AnimType.Action] or self.AnimDic[AnimType.Movement]
    if Info then
        return Info.Montage
    end
end

function PhotoMgr:RoleInPlayingAni(AnimComp)
    if AnimComp == nil then return nil end
    local AnimInstance = AnimComp:GetAnimInstance()
    if AnimInstance then
        local Montage = self:GetCurMainMontage()
        if AnimationUtil.MontageIsPlaying(AnimInstance, Montage) then
            return Montage
        end
    end
end

function PhotoMgr:AllRoleStopMontage()
    local AnimComp = ActorUtil.GetActorAnimationComponent(self.SeltEntID)
    self:StopRoleAllAnim(AnimComp)
    if self.AniEntList == nil then
        return
    end

    for i = 1, #self.AniEntList do
		local EntID = self.AniEntList[i]
        if EntID == "MOUNT" then
            local AnimComp = ActorUtil.GetActorAnimationComponent(self.SeltEntID)
	        self:StopMountMontage(AnimComp)
        else
            local AnimComp = ActorUtil.GetActorAnimationComponent(EntID)
		    self:StopRoleAllAnim(AnimComp)
        end
	end
end

function PhotoMgr:RoleStopAnimByType(AnimType)
    local AnimComp = ActorUtil.GetActorAnimationComponent(self.SeltEntID)
    self:DoStopRoleAnim(AnimComp, AnimType)

    if self.AniEntList == nil then
        self.AnimDic[AnimType] = nil
        return
    end

    for i = 1, #self.AniEntList do
		local EntID = self.AniEntList[i]
        if EntID == "MOUNT" then
            local AnimComp = ActorUtil.GetActorAnimationComponent(self.SeltEntID)
	        self:StopMountMontage(AnimComp)
        else
            local AnimComp = ActorUtil.GetActorAnimationComponent(EntID)
            self:DoStopRoleAnim(AnimComp, AnimType)
        end
	end

    self.AnimDic[AnimType] = nil
end

function PhotoMgr:StopRoleAllAnim(AnimComp)
    if AnimComp == nil then return end

    for T, _ in pairs(self.AnimDic) do
        self:TryStopRoleAnim(AnimComp, T)
    end
end

function PhotoMgr:TryStopRoleAnim(AnimComp, AnimType)
    local Info = self.AnimDic[AnimType]
    if Info then
        local Montage = Info.Montage
        if (AnimComp and Montage) then
            local AnimInstance = AnimComp:GetAnimInstance()
            if AnimInstance == nil then return end
            AnimationUtil.MontageStop(AnimInstance, Montage)
            self.AnimDic[AnimType] = nil
        end
    end
end

function PhotoMgr:DoStopRoleAnim(AnimComp, AnimType)
    local Info = self.AnimDic[AnimType]
    if Info then
        local Montage = Info.Montage
        if (AnimComp and Montage) then
            local AnimInstance = AnimComp:GetAnimInstance()
            if AnimInstance == nil then return end
            AnimationUtil.MontageStop(AnimInstance, Montage)
            -- AnimComp:StopAnimationByMontage(AnimInstance, Montage) 
        end
    end
end

function PhotoMgr:SetCurMontagePct(Pct)
    local AnimComp = ActorUtil.GetActorAnimationComponent(self.SeltEntID)

    if AnimComp == nil then return end
    local AnimInstance = AnimComp:GetAnimInstance()
    if AnimInstance == nil then return end

    local Info = self:GetCurMainAnimInfo() or {}
    local Montage = Info.Montage
    if Montage and CommonUtil.IsObjectValid(Montage) then
		local BlendTime = AnimationUtil.MontageGetBlendTime(AnimInstance, Montage)
        local Len = Montage.SequenceLength - BlendTime
        local CurPos = Pct * Len

        self:PauseAllMontage(true)
        AnimationUtil.MontageStop(AnimInstance, Info.Montage)
	    Info.Montage = AnimationUtil.PlayMontage(AnimComp, Montage, nil, nil, AnimInstance, nil, 0.00001, false, 0, 0, CurPos)
        -- AnimationUtil.SetMontagePosition(AnimInstance, Montage, CurPos) 
        -- AnimationUtil.MontagePause(AnimInstance, Montage)
    else
        -- debug
        local Info = self:GetCurMainAnimInfo()
        _G.FLOG_WARNING('PhotoMgr:SetCurMontagePct Montage = nil, table = ' .. table.tostring_block(Info))
    end
end

function PhotoMgr:PauseCurMontage()
    self:PauseAllMontage(true)
end

function PhotoMgr:ResumeCurMontage()
    self:PauseAllMontage(false)
end

function PhotoMgr:PauseAllMontage(IsPause)
    local AnimComp = ActorUtil.GetActorAnimationComponent(self.SeltEntID)

    if AnimComp == nil then return end
    local AnimInstance = AnimComp:GetAnimInstance()
    if AnimInstance == nil then return end

    local AnimMap = self.AnimDic or {}

    for _, Info in pairs(AnimMap) do
        local Montage = Info.Montage
        if Montage then
            Info.Montage = self:DoPauseMontage(AnimComp, AnimInstance, Montage, IsPause)
        end
    end
end

function PhotoMgr:DoPauseMontage(AnimComp, AnimInst, Montage, IsPause, Pos)
    if AnimComp and AnimInst and Montage then
        -- AnimationUtil.MontagePause(AnimInstance, Montage)

        -- self:StopEmotionEye(true)
	    -- 把播放速度设置极低
        local CurPos = Pos or AnimationUtil.GetMontagePosition(AnimInst, Montage)
        AnimationUtil.MontageStop(AnimInst, Montage)
        local Sp = IsPause and 0.00001 or 1
	    return AnimationUtil.PlayMontage(AnimComp, Montage, nil, nil, AnimInst, nil, Sp, false, 0, 0, CurPos)
    end
end

function PhotoMgr:GetCurMontagePct()
    local AnimComp = ActorUtil.GetActorAnimationComponent(self.SeltEntID)

    if AnimComp == nil then return end
    local AnimInstance = AnimComp:GetAnimInstance()
    if AnimInstance == nil then return end

    local Montage = self:GetCurMainMontage()

    -- if PhotoVM.GiveType == AnimType.Action or PhotoVM.GiveType == AnimType.Movement then
    --     Montage = self.AnimDic[PhotoVM.GiveType].Montage
    -- end

    if Montage and CommonUtil.IsObjectValid(Montage) then
		local BlendTime = AnimationUtil.MontageGetBlendTime(AnimInstance, Montage)
        local Len = Montage.SequenceLength - BlendTime
        local CurPos = AnimationUtil.GetMontagePosition(AnimInstance, Montage)
        local Pct = CurPos / Len
        return  Pct
    end
end

function PhotoMgr:StopMountMontage(AnimComp)
    if AnimComp == nil then return end
    local AnimInstance = AnimComp:GetPartAnimInstance(3001)
    if AnimInstance == nil then return end

    local Montage = AnimInstance:GetCurrentActiveMontage()
    if Montage then
        AnimationUtil.MontageStop(AnimInstance, Montage) 
    end
end

function PhotoMgr:PlayPhotoAnim(EntID)
    self:CheckAndLoopAnim(EntID, AnimType.Action, self.GetEmotionPath)
    self:CheckAndLoopAnim(EntID, AnimType.Movement, self.GetMoveMouthPath)
    self:CheckAndLoopAnim(EntID, AnimType.Emoji, self.GetEmotionPath)
    self:CheckAndLoopAnim(EntID, AnimType.Mouth, self.GetMoveMouthPath)
end

function PhotoMgr:CheckAndLoopAnim(EntID, InAnimType, PathFunc)
    local AnimComp = ActorUtil.GetActorAnimationComponent(EntID)
    if AnimComp == nil then return end

    local Info = self.AnimDic[InAnimType] or {}
    local ID = Info.ID
    local Montage = Info.Montage
    local AnimInstance = AnimComp:GetAnimInstance()

    if ID ~= nil and AnimInstance ~= nil then
        -- loop
        if (Montage ~= nil and (not AnimationUtil.MontageIsPlaying(AnimInstance, Montage))) and (not _G.PhotoActionVM.IsPauseAnim) then
            -- print("loop SET " .. tostring(self.AnimDic[AnimType].Montage))
            self.AnimDic[InAnimType].Montage = self:PlayPhotoMontageByAnimType(EntID, InAnimType, ID, PathFunc)
        -- start
        elseif Montage == nil then
            -- print("PLAY SET" .. tostring(self.AnimDic[AnimType].Montage))
            self.AnimDic[InAnimType].Montage = self:PlayPhotoMontageByAnimType(EntID, InAnimType, ID, PathFunc)
        end
    end
end

function PhotoMgr:PlayPhotoMontageByAnimType(EntID, InAnimType, ID, PathFunc)
    if InAnimType == AnimType.Action then
        return _G.EmotionMgr:PhotoPlayEmotion(ID, EntID)
    else
        local AnimComp = ActorUtil.GetActorAnimationComponent(EntID)
        local ActionAniPath = PathFunc(self, ID)
        local Rate = InAnimType == AnimType.Emoji and 0.00001 or 1
        local StartAtTime = InAnimType == AnimType.Emoji and 1 or 0
        return self:PlayPhotoMontage(AnimComp, ActionAniPath, Rate, nil, nil, StartAtTime)
    end
end

function PhotoMgr:PlayPhotoMontage(AnimComp, Path, PlayRate, BlendInTime, BlendOutTime, StartAtTime)
    -- AnimComp:PlayAnimation(Path)
    local StateAnim = _G.ObjectMgr:LoadObjectSync(Path, ObjectGCType.LRU)
    local Ret = self:DoPlayPhotoMontage(AnimComp, StateAnim, PlayRate, BlendInTime, BlendOutTime, StartAtTime)
    return Ret
end

function PhotoMgr:DoPlayPhotoMontage(AnimComp, StateAnim, PlayRate, BlendInTime, BlendOutTime, StartAtTime)
    return AnimComp:PlayMontage(StateAnim, nil , nil, PlayRate or 1, BlendInTime or 0.25, BlendOutTime or 0.25, nil, false, StartAtTime, true)
end

function PhotoMgr:PlayPhotoMontageByEmoSys(EntID, EmoID)
    -- 
end

function PhotoMgr:PlayPhotoMountAnim(AnimComp)
    if AnimComp == nil then return end

    if self.ActionID ~= nil then
        local ActionAniPath = self:GetEmotionPath(self.ActionID)
        AnimComp:PlayAnimation(ActionAniPath, 1, 0.25, 0.25, false, 3001)
    end
	
	if self.MoveID ~= nil then
        local MoveAniPath = self:GetMoveMouthPath(self.MoveID)
        AnimComp:PlayAnimation(MoveAniPath, 1, 0.25, 0.25, false, 3001)
    end

    if self.EmojiID ~= nil then
        local EmojiAniPath = self:GetEmotionPath(self.EmojiID)
        AnimComp:PlayAnimation(EmojiAniPath, 1, 0.25, 0.25, false, 3001)
    end
    
    if self.MouthID ~= nil then
        local MouthAniPath = self:GetMoveMouthPath(self.MouthID)
        AnimComp:PlayAnimation(MouthAniPath, 1, 0.25, 0.25, false, 3001)
    end
end


function PhotoMgr:GetEmotionPath(ID)
    local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
    local EntityID = MajorUtil.GetMajorEntityID()
    local CurState = _G.EmotionMgr:GetCurState(EntityID)
    return EmotionAnimUtils.GetEmotionAtlPath(ID, EmotionDefines.AnimPathType[CurState])
end

function PhotoMgr:GetMoveMouthPath(ID)
    local MouthMoveCfg = PhotoMouthMoveCfg:FindCfgByKey(ID)
    if MouthMoveCfg == nil then
        return
    end
    local Cfg = ActiontimelinePathCfg:FindCfgByKey(MouthMoveCfg.ActionTimelineID)
	if Cfg == nil then
        return
	end
    return AnimMgr:GetActionTimeLinePath(Cfg.Filename)
end


function PhotoMgr:SetActionID(ActionID)
    ---@TODO FLOW OPT
    if ActionID then
        _G.PhotoActionVM:CancelIdxMovement()
        self:RoleStopAnimByType(AnimType.Movement)
        self.MoveID = nil
    end

    self:RoleStopAnimByType(AnimType.Action)
    self.AnimDic[AnimType.Action] = {ID = ActionID}
    self.ActionID = ActionID

    PhotoVM.GiveType = PhotoDefine.PhotoGiveType.Action
    self:UpdatePlayAniRoleList()
end

function PhotoMgr:SetMoveID(MoveID)
    ---@TODO FLOW OPT
    if MoveID then
        _G.PhotoActionVM:CancelIdxMontion()
        self:RoleStopAnimByType(AnimType.Action)
        self.ActionID = nil
    end

    self:RoleStopAnimByType(AnimType.Movement)
    self.AnimDic[AnimType.Movement] = {ID = MoveID}
    self.MoveID = MoveID

    PhotoVM.GiveType = PhotoDefine.PhotoGiveType.Movement
    self:UpdatePlayAniRoleList()
end

function PhotoMgr:SetEmojiID(EmojiID)
    self:RoleStopAnimByType(AnimType.Emoji)
    self.AnimDic[AnimType.Emoji] = {ID = EmojiID}
    self.EmojiID = EmojiID
    -- self.ActionID = nil
    -- self.MoveID = nil
    -- self.MouthID = nil
    -- self:AllRoleStopMontage()

    PhotoVM.GiveType = PhotoDefine.PhotoGiveType.Emoji
    self:UpdatePlayAniRoleList()
end

function PhotoMgr:SetMouthID(MouthID)
    self:RoleStopAnimByType(AnimType.Mouth)
    self.AnimDic[AnimType.Mouth] = {ID = MouthID}
    self.MouthID = MouthID
    -- self.ActionID = nil
    -- self.MoveID = nil
    -- self.EmojiID = nil
    -- self:AllRoleStopMontage()

    PhotoVM.GiveType = PhotoDefine.PhotoGiveType.Mouth

    self:UpdatePlayAniRoleList()
end


function PhotoMgr:UpdatePlayAniRoleList()
    if PhotoVM.IsGiveAll then
        self:GetGiveActorList()
    else
        -- self:AllRoleStopMontage()
        self:TryClearAniEntList()
    end

    self:UpdateRoleAni()
end

---@todo temporary fix for animation not cleaning up issues
function PhotoMgr:TryClearAniVMStat()
    _G.PhotoActionVM:ResetRoleActAni()
    _G.PhotoEmojiVM:ResetRoleActAni()
end

---@todo temporary fix for animation not cleaning up issues
function PhotoMgr:TryClearAniEntList()
    if self.AniEntList and not table.empty(self.AniEntList) then
        self:AllRoleStopMontage()
        self:TryClearAniVMStat()
        self.AniEntList = {}
    end
end

function PhotoMgr:GetGiveActorList()
    local CfgSearchCond = string.format("Type == %d", PhotoVM.GiveType)
    local Cfgs = PhotoEndueCfg:FindAllCfg(CfgSearchCond)
    if nil == Cfgs then
		return
	end

    self:TryClearAniEntList()
    for _, Cfg in pairs(Cfgs) do
        if Cfg.Target == ProtoRes.Endue_Target_Type.TARGET_TYPE_SELF then
            local EntityID = MajorUtil.GetMajorEntityID()
            if EntityID ~= self.SeltEntID then
                table.insert(self.AniEntList, EntityID)
            end
        elseif Cfg.Target == ProtoRes.Endue_Target_Type.TARGET_TYPE_PET then
            local EntityID = _G.CompanionMgr.CallingOutCompanionEntityID
            if EntityID and EntityID ~= self.SeltEntID then
                table.insert(self.AniEntList, EntityID)
            end
        elseif Cfg.Target == ProtoRes.Endue_Target_Type.TARGET_TYPE_MATE then
            local Mates =  PhotoActorUtil.GetMateEIDSet(false)
            for EID, _ in pairs(Mates) do
                if EID  ~= self.SeltEntID then
                    table.insert(self.AniEntList, EID)
                end
            end
        elseif Cfg.Target == ProtoRes.Endue_Target_Type.TARGET_TYPE_BUDDY then
            local EntityID = _G.BuddyMgr.BuddyEntityID
            if EntityID and EntityID ~= self.SeltEntID then
                table.insert(self.AniEntList, EntityID)
            end
        elseif Cfg.Target == ProtoRes.Endue_Target_Type.TARGET_TYPE_SUMMON then
            local Data = _G.SummonMgr.SummonRecord
            local MEID = MajorUtil.GetMajorEntityID()
            local Buffs = Data[MEID]
            if Buffs then
                for _, Info in pairs(Buffs) do
                    if Info.SummonEntityID  ~= self.SeltEntID then
                        table.insert(self.AniEntList, Info.SummonEntityID)
                    end
                end
            end
        elseif Cfg.Target == ProtoRes.Endue_Target_Type.TARGET_TYPE_MOUNT then
            table.insert(self.AniEntList, "MOUNT")
        end
    end
        
end

-------------------------------------------------------------------------------------------------------
---@region 模板

---@region Network

function PhotoMgr:OnRegisterNetMsgTemplate()
	self:RegisterGameNetMsg(MAIN_CMD, SUB_CMD.PhotosSave,   self.RespSavePhotoTemplate)
	self:RegisterGameNetMsg(MAIN_CMD, SUB_CMD.PhotosDelete, self.RespDeletePhotoTemplate)
	self:RegisterGameNetMsg(MAIN_CMD, SUB_CMD.PhotosGet,    self.RespGetPhotoTemplate)
end

function PhotoMgr:ReqPhotoTemplate(SubCmd, MsgBody)
    LOG(string.format('[Photo][PhotoMgr][ReqPhotoTemplate] SubCmd = %s, MsgBody = %s',
        tostring(SubCmd), 
        table.tostring(MsgBody)
    ))
    MsgBody.cmd = SubCmd
    GameNetworkMgr:SendMsg(MAIN_CMD, SubCmd, MsgBody)
end

-- Save

function PhotoMgr:ReqSavePhotoTemplate(ID, Template)
    local MsgBody = {
        save = {
            photo_id = ID,
            photo_metadata = Json.encode(Template),
        }
    }

    self:ReqPhotoTemplate(SUB_CMD.PhotosSave, MsgBody)
    self.ReqTemplateID = ID
    self.ReqTemplate = Template
end

function PhotoMgr:RespSavePhotoTemplate(MsgBody)
    LOG('[Photo][PhotoMgr][RespSavePhotoTemplate] MsgBody = ' .. table.tostring(MsgBody))
    local Msg = MsgBody.save
	if nil == Msg then
		return
	end

    --[[
        message CommonUpload {
            string upload_url = 1; // 上传图片的上传链接
            string http_header_token_key = 2; // token 塞到http的header 的key
            string http_token = 3; // token 值
            string http_method = 4; // http method   POST 
        }
    ]]

    local Upload = Msg.upload
    local Token = Upload.http_token
    local Url = Upload.upload_url
    local ImageStream = self.CurIconStream

    if string.isnilorempty(ImageStream) then
        ERR('[Photo][PhotoMgr][RespSavePhotoTemplate] ImageStream is nil or empty')
    end
    
    self:PostTemplateImage(Token, Url, ImageStream)
end

function PhotoMgr:PostTemplateImage(Token, Url, ImageStream)
    LOG(string.format('[Photo][PhotoMgr][PostTemplateImage] Token = %s, Url = %s, ImageStream = %s', 
        tostring(Token), 
        tostring(Url), 
        tostring(ImageStream)
    ))

    local JsonStr = Json.encode({ data = ImageStream })
    if _G.HttpMgr:Post(Url, Token, JsonStr, self.PostTemplateImageCallback, self) then
        LOG(string.format('[Photo][PhotoMgr][PostTemplateImage] Post success'))
    end
end

function PhotoMgr:PostTemplateImageCallback(MsgBody, Succ)
    LOG(string.format('[Photo][PhotoMgr][PostTemplateImage] Post Callback MsgBody = %s, Succ = %s', 
        table.tostring(MsgBody),
        tostring(Succ)
    ))

    MsgBody = Json.decode(MsgBody)

    LOG(string.format('[Photo][PhotoMgr][PostTemplateImage] icon url = %s', tostring(MsgBody.photo_url)))

    self:ReqGetPhotoTemplate()
	MsgTipsUtil.ShowTips(_G.LSTR(630038))
    -- if (not self.ReqTemplateID) then
    --     ERR('[Photo][PhotoMgr][PostTemplateImage] ReqTemplateImageUrl or ReqTemplateID nil')
    --     return
    -- end

    -- local Info = self.ReqTemplate
    
    -- if Info then
    --     local BaseInfo = PhotoTemplateUtil.GetBaseInfo(Info)
    --     BaseInfo.Icon = MsgBody.photo_url

    --     if string.isnilorempty(MsgBody.photo_url) then
    --         ERR('[Photo][PhotoMgr][PostTemplateImage] icon url is nil or empty')
    --         return
    --     end
    -- end

    -- -- update order itemvm
    -- _G.PhotoTemplateVM:UpdTemplates()
end

-- Delete

function PhotoMgr:ReqDeletePhotoTemplate(ID)
    local MsgBody = {
        delete = {
            photo_id = ID,
        }
    }

    self:ReqPhotoTemplate(SUB_CMD.PhotosDelete, MsgBody)
    LOG('[Photo][PhotoMgr][ReqDeletePhotoTemplate] MsgBody = ' .. table.tostring(MsgBody))
end

function PhotoMgr:RespDeletePhotoTemplate(MsgBody)
    LOG('[Photo][PhotoMgr][RespDeletePhotoTemplate] MsgBody = ' .. table.tostring(MsgBody))
    local Msg = MsgBody.delete
	if nil == Msg then
		return
	end

    local Succ = Msg.success

    self:ReqGetPhotoTemplate()

    -- if Succ then
    -- end
end

-- Get

function PhotoMgr:ReqGetPhotoTemplate()

    -- 模版id 不传默认为0 则返回所有
    local MsgBody = {
        photos_list = {
            -- photo_id = 0,
        }
    }

    self:ReqPhotoTemplate(SUB_CMD.PhotosGet, MsgBody)
end

function PhotoMgr:RespGetPhotoTemplate(MsgBody)
    LOG('[Photo][PhotoMgr][RespGetPhotoTemplate] MsgBody = ' .. table.tostring(MsgBody))

    local Msg = MsgBody.photos_list
	if nil == Msg then
		return
	end
   
    --[[
        message PhotoTemplateData {
        int32 photo_id = 1; // 模版id
        string photo_url =2; // 图片地址
        bytes photo_metadata = 3;  // 模版信息
    ]]
    
    local Photos = Msg.photos
    local CustTemplateList = {}
    for _, PhotoTemplateData in pairs(Photos) do
        local Temp = Json.decode(PhotoTemplateData.photo_metadata)
        if Temp then
            PhotoTemplateUtil.SetIcon(Temp, PhotoTemplateData.photo_url)
            PhotoTemplateUtil.SetID(Temp, tonumber(PhotoTemplateData.photo_id))
            table.insert(CustTemplateList, Temp)
        end
    end

    self:CoverCustTemplate(CustTemplateList)
    LOG('[Photo][PhotoMgr][RespGetPhotoTemplate] CoveTemplateList = ' .. table.tostring(CustTemplateList))
end

---@region Data operation

function PhotoMgr:TryInitCustTemplateList()
    if not self.HasInitCustTemplateList then
        self.HasInitCustTemplateList = true
        self:ReqGetPhotoTemplate()
    end
end

function PhotoMgr:BeginTemplate()
    self.HasInitCustTemplateList = nil
    self.CustTemplateList = {}
    self.CfgTemplateList = {}
end



local function NormNum(V, Min, Max)
    return (1 - (V - Min) / (Max - Min))
end

function PhotoMgr:ConvertAndSetConfigTemplate()
    if self.CfgTemplateList and not table.empty(self.CfgTemplateList) then
        return
    end

    local AllCfg = PhotoTemplateCfg:FindAllCfg()
    -- print('[PhotoMgr]:ConvertAndSetConfigTemplate All = ' .. table.tostring_block(AllCfg, 4))
    local AllEmo = self:GetEmojCfgList()
    local AllAct = self:GetActionCfgList()
    local AllMove = self:GetMoveOrMouthList(PhotoDefine.MoveMouthType.Movement)
    local AllMouth = self:GetMoveOrMouthList(PhotoDefine.MoveMouthType.Mouth)

    for _, Cfg in pairs(AllCfg or {}) do
        local Item = {}

        local FOV = NormNum(Cfg.FOV, PhotoDefine.CameraUnit2ValueFOVMin, 
                        PhotoDefine.CameraUnit2ValueFOVMax) * PhotoDefine.CameraTurnplateUnitMax
        local DOF = NormNum(Cfg.DOF, PhotoDefine.CameraUnit2ValueDOFMin, 
                        PhotoDefine.CameraUnit2ValueDOFMax) * PhotoDefine.CameraTurnplateUnitMax
        local Rot = NormNum(Cfg.Rot, PhotoDefine.CameraUnit2ValueRotMin, 
                        PhotoDefine.CameraUnit2ValueRotMax) * PhotoDefine.CameraTurnplateUnitMax

        PhotoTemplateUtil.SetBaseInfo(Item, Cfg.Name, Cfg.Icon, Cfg.ID, false)
        PhotoTemplateUtil.SetMain(Item, Cfg.IsFollowFace == 1, Cfg.IsFollowEye == 1)
        PhotoTemplateUtil.SetCam(Item, FOV, DOF, Rot, Cfg.CamOffX, Cfg.CamOffY,{Yaw = Cfg.Yaw or 0, Pitch = Cfg.Pitch or 0})
        PhotoTemplateUtil.SetScene(Item, Cfg.WeatherID, Cfg.Time)
        PhotoTemplateUtil.SetFilter(Item, Cfg.FilterID)
        PhotoTemplateUtil.SetDarkFrame(Item, Cfg.DuskyPower, Cfg.DuskyAspect, Cfg.DuskyRed, Cfg.DuskyYellow, Cfg.DuskyBlue)
        PhotoTemplateUtil.SetRole(Item, Cfg.ActID, Cfg.EmoID, Cfg.MoveID, Cfg.MouthID)

        local Pct = Cfg.ActPct -- = 0.12

        if Cfg.MoveID then
            local _, Idx = table.find_item(AllMove, Cfg.MoveID, "ID")
            if Idx then
                PhotoTemplateUtil.SetActAndMove(Item, 1, Idx, Pct)
            end
        end

        -- override move
        if Cfg.ActID then
            local _, Idx = table.find_item(AllAct, Cfg.ActID, "ID")
            if Idx then
                PhotoTemplateUtil.SetActAndMove(Item, 0, Idx, Pct)
            end
        end

        local EmoIdx = nil
        local MouthIdx = nil
        if Cfg.EmoID then
            _, EmoIdx = table.find_item(AllEmo, Cfg.EmoID, "ID")
        end

        if Cfg.MouthID then
            _, MouthIdx = table.find_item(AllMouth, Cfg.MouthID, "ID")
        end

        if EmoIdx or MouthIdx then
            PhotoTemplateUtil.SetEmojAndMouth(Item, EmoIdx, MouthIdx)
        end

        table.insert(self.CfgTemplateList, Item)
    end

end

function PhotoMgr:NextCustTempID()
    local Ret = 0
    for _, Temp in pairs(self.CustTemplateList or {}) do
        local BaseInfo = PhotoTemplateUtil.GetBaseInfo(Temp)
        if BaseInfo and BaseInfo.ID and BaseInfo.ID > Ret then
            Ret = BaseInfo.ID
        end
    end

    Ret = Ret + 1
    
    return Ret
end

function PhotoMgr:AddCustTemplate(Name, Icon)
    local Num = #self.CustTemplateList

    if Num >= PhotoDefine.MaxTemplateCnt then
        return false
    end

    local Template = {}
    local ID = self:NextCustTempID()
    self.CurIconStream = Icon
    self:TemplateSave(Template, Name, ID, "")
    -- table.insert(self.CustTemplateList, Template)
    -- self:OnCustTemplateListChanged()
    self:ReqSavePhotoTemplate(ID, Template)

    return true
end

function PhotoMgr:RemCustTemplate(ID)
    local Num = #self.CustTemplateList

    -- if ID > Num then
    --     ERR(string.format("[PhotoMgr][RemCustTemplate] Invalid ID : %d"), ID)
    --     return false
    -- end

    -- table.remove(self.CustTemplateList, ID)
    -- self:OnCustTemplateListChanged()
    self:ReqDeletePhotoTemplate(ID)
    return true
end

function PhotoMgr:CoverCustTemplate(CustTemplateList)
    self.CustTemplateList = CustTemplateList
    self:OnCustTemplateListChanged()
end

function PhotoMgr:OnCustTemplateListChanged()
    table.sort(self.CustTemplateList, function (a, b) 
        local DateA = a.Date or 0
        local DateB = b.Date or 0
        return DateA > DateB
    end)

    -- for Idx, CustTemplate in pairs(self.CustTemplateList) do
    --     local BaseInfo = PhotoTemplateUtil.GetBaseInfo(CustTemplate)
    --     if BaseInfo then
    --         BaseInfo.ID = Idx
    --     end
    -- end
    
    PhotoTemplateVM:UpdTemplates()
end

local function CallTemplateFunc(Template, Objects, FuncName)
    for Name, Obj in pairs(Objects) do
        if Obj[FuncName] then
            Obj[FuncName](Obj, Template)
        else
            ERR(string.format("[PhotoMgr] CallTemplateFunc %s Not Such FuncName : %s",
                tostring(Name), tostring(FuncName)))
        end
    end
end

function PhotoMgr:TemplateSave(Template, Name, ID, Icon)
    PhotoTemplateUtil.SetBaseInfo(Template, Name, Icon, ID, true)
    PhotoTemplateUtil.SetDate(Template)
    CallTemplateFunc(Template, self.TemplateMap, "TemplateSave")
end

function PhotoMgr:TemplateApply(Template)
    CallTemplateFunc(Template, self.TemplateMap, "TemplateApply")
end

function PhotoMgr:GetTemplate(ID, IsCust)
    local Info = nil

    if IsCust then
        local test = function(V)
            local BaseInfo = PhotoTemplateUtil.GetBaseInfo(V)
            if BaseInfo then
                return BaseInfo.ID == ID
            end

            return false
        end

        Info = table.find_by_predicate(self.CustTemplateList, test)
        -- Info = self.CustTemplateList[ID]
    else
        Info = self.CfgTemplateList[ID]
    end

    if Info == nil then
        ERR(string.format("[PhotoMgr][GetTemplate] template not exist ID : %s, IsCust : %s",
                tostring(ID), 
                tostring(IsCust)))
    end

    return Info
end

-------------------------------------------------------------------------------------------------------
---@region 滤镜

function PhotoMgr:AddFilterLevel()
    local _ <close> = CommonUtil.MakeProfileTag("[Photo][PhotoMgr][AddFilterLevel]")

    PhotoSceneUtil.AddFilterLevel()
    self.IsLoadFilterLevel = true

    LOG('[Photo][PhotoMgr][AddFilterLevel]')
end

function PhotoMgr:RemFilterLevel()
    local _ <close> = CommonUtil.MakeProfileTag("[Photo][PhotoMgr][RemFilterLevel]")

    if not self.IsLoadFilterLevel then
        return
    end

    self:CheckAndHdlCloseFilter()
    PhotoSceneUtil.RemFilterLevel()
    self.IsLoadFilterLevel = false
    self.TAryFilters = nil

    LOG('[Photo][PhotoMgr][RemFilterLevel]')
end

function PhotoMgr:HdlFilter(CfgID, IsOpen)
    if IsOpen then
        self:CheckAndHdlCloseFilter()

        local Cfg = PhotoFilterCfg:FindCfgByKey(CfgID)
        if Cfg then
            self:HdlFilterInner(Cfg, true)
            self.CurFilterID = CfgID
        end
    else
        if CfgID ~= self.CurFilterID then
            local Cfg = PhotoFilterCfg:FindCfgByKey(CfgID)
            if Cfg then
                self:HdlFilterInner(Cfg, false)
            end
        end

        if self.CurFilterID then
            local OldCfg = PhotoFilterCfg:FindCfgByKey(self.CurFilterID)
            self:HdlFilterInner(OldCfg, false)
        end

        self.CurFilterID = nil
    end
end

function PhotoMgr:CheckAndHdlCloseFilter()
    if self.CurFilterID then
        local OldCfg = PhotoFilterCfg:FindCfgByKey(self.CurFilterID)
        self:HdlFilterInner(OldCfg, false)
        self.CurFilterID = nil
    end
end

function PhotoMgr:HdlFilterInner(Cfg, IsOpen)
    if IsOpen then
        local Param = Cfg.Param
        if string.isnilorempty(Param) then
            self:ShowFilter(Cfg.ResName, true)
        -- elseif Param == "xx" then
        --     --
        -- else
        --     --
        end
    else
        local Param = Cfg.Param
        if string.isnilorempty(Param) then
            self:ShowFilter(Cfg.ResName, false)
        -- elseif Param == "xx" then
        --     --
        -- else
        --     --
        end
    end
end

-- local TestFilterName = "TA_PostProcessVolume_DanSeLan_4"

function PhotoMgr:ShowFilter(Name, IsShow)
    if IsShow then
        if self.CurFilterName == Name then
            return
        end

        self:CheckAndHideFilter()
        self:ShowFilterInner(Name, true)
        self.CurFilterName = Name
    else
        if self.CurFilterName ~= Name then
            self:ShowFilterInner(Name, false)
        end

        self:CheckAndHideFilter()
    end
end

function PhotoMgr:CheckAndHideFilter()
    if self.CurFilterName then
        self:ShowFilterInner(self.CurFilterName, false)
        self.CurFilterName = nil
    end
end

function PhotoMgr:ShowFilterInner(Name, IsShow)
    if not self.TAryFilters then
        self.TAryFilters = _G.UE.TArray(_G.UE.APostProcessVolume)
        _G.UE.UGameplayStatics.GetAllActorsOfClass(FWORLD(), _G.UE.APostProcessVolume.StaticClass(), self.TAryFilters)
    end

    local Cnt = self.TAryFilters:Length()

    for i = 1, Cnt do
        local PostProcess = self.TAryFilters:Get(i)
        local ItemName = PostProcess:GetName()

        -- if Name == ItemName then
        --     PostProcess.bEnabled = IsShow
        -- end

        if string.find(ItemName, Name) then
            PostProcess.bEnabled = IsShow

            if (IsShow) then
                self.CurPostProcess = PostProcess
            else
                self.CurPostProcess = nil
            end
        end
    end
end

--- Filter Alpha

function PhotoMgr:SetFilterAlpha(V)
    if self.CurPostProcess then
        self.CurPostProcess.BlendWeight = V
    end
end

-------------------------------------------------------------------------------------------------------
---@region 昏暗

function PhotoMgr:LoadDarkEdgeLevel()
    PhotoSceneUtil.AddDarkEdgeLevel()
end

function PhotoMgr:UpdateDarkEdgeEffect()
    if self.DarkEdgeActor == nil then
        local Actors = PhotoSceneUtil.GetDarkEdgeActors()
        if Actors then
            for i=1, Actors:Length() do
                local Actor = Actors:GetRef(i)
                local Name = Actor:GetName()
                if Name == "PostProcessVolume_DarkEdge" or Name == "PostProcessVolumeDarkEdge" then
                    self.DarkEdgeActor = Actor
                    break
                end
            end
        end
    end
    
    if self.DarkEdgeActor ~= nil then
        local PostProcessSettings = self.DarkEdgeActor.Settings
        local WeightedBlendable = PostProcessSettings.WeightedBlendables.Array[1]
        local MaterialInstance = WeightedBlendable.Object
        if self.DarkEdgeMID == nil then
            self.DarkEdgeMID = _G.UE.UKismetMaterialLibrary.CreateDynamicMaterialInstance(FWORLD(), MaterialInstance)
            if self.DarkEdgeMID == nil then
                return
            end

            WeightedBlendable.Object = self.DarkEdgeMID
            PostProcessSettings.WeightedBlendables.Array[1] = WeightedBlendable
        end
        self.DarkEdgeMID:SetVectorParameterValue("Color", _G.UE.FLinearColor(PhotoDarkEdgeVM.RedValue, PhotoDarkEdgeVM.GreenValue, PhotoDarkEdgeVM.BlueValue, 1))
        self.DarkEdgeMID:SetVectorParameterValue("cVignettingParam", _G.UE.FLinearColor(PhotoDarkEdgeVM.VignettingA, PhotoDarkEdgeVM.VignettingG, PhotoDarkEdgeVM.VignettingB, 1))
    end

end

function PhotoMgr:RemoveDarkEdgeLevel()
    self.DarkEdgeActor = nil
    self.DarkEdgeMID = nil
    PhotoSceneUtil.RemDarkEdgeLevel()
end

-------------------------------------------------------------------------------------------------------
---@region 角色特效

function PhotoMgr:BeginRoleEffect()
    self.Role4EffectMap = {}
    self.RoleEffInfo = {}
    self.Role4EffList = {}
    self:SwitchRole4EffGroup(true)
end

function PhotoMgr:SeltRoleEff(ID)
    if self.RoleEffInfo.CurrRoleEffID == ID then
        local SeltInfo = self.Role4EffectMap[self.SeltEntID]
        if SeltInfo and SeltInfo.EffID == ID then
            return
        end
    end
    self.RoleEffInfo.CurrRoleEffID = ID
    self:UpdateRoleEff()
end

function PhotoMgr:SwitchRole4EffGroup(IsSingle)
    if TeamMgr:IsInTeam() then
        ERR('[Photo][PhotoMgr][SwitchRole4EffGroup] Not a team but SwitchRole4EffGroup')
        return
    end

    self.RoleEffInfo.IsSingle = IsSingle
    self:UpdateRoleEff()
end

function PhotoMgr:UpdateRoleEff()
    LOG(string.format('[Photo][PhotoMgr][UpdateRoleEff] CurrRoleEffID = %s, Role4EffList = %s, Role4EffectMap = %s',
        table.tostring(self.RoleEffInfo),
        table.tostring(self.Role4EffList),
        table.tostring(self.Role4EffectMap)
    ))

    self.Role4EffList = self.RoleEffInfo.IsSingle and {[1] = self.SeltEntID} or _G.TeamMgr:GetMemberRoleIDList()
    self:CheckAndClearRoleEff()
    self:PlayRoleEffs()
end

function PhotoMgr:CheckAndClearRoleEff(IsForce)
    local DelList = {}
    for EntID, CacheInfo in pairs(self.Role4EffectMap) do
        local ShouldDelete = false

        if IsForce then
            ShouldDelete = true
        end

        if EntID == self.SeltEntID then --and CacheInfo.EffID ~= self.RoleEffInfo.CurrRoleEffID then
            ShouldDelete = true
        end

        -- if not table.find_item(self.Role4EffList, EntID) then
        --     ShouldDelete = true
        -- end

        if ShouldDelete then
            table.insert(DelList, EntID)
        end
    end

    for _, EntID in pairs(DelList) do
        if self.Role4EffectMap[EntID].ClearHdl then
            self.Role4EffectMap[EntID].ClearHdl()
        end
        self.Role4EffectMap[EntID] = nil
    end
end

function PhotoMgr:PlayRoleEffs()
    if not self.RoleEffInfo.CurrRoleEffID then
        WARN('[Photo][PhotoMgr][PlayRoleEffs] CurrRoleEffID = ' .. tostring(self.RoleEffInfo.CurrRoleEffID))
        return
    end

    for _, EntID in pairs(self.Role4EffList) do

        local Hdl = self:PlayRoleEff(EntID, self.RoleEffInfo.CurrRoleEffID) --PhotoEffectUtil.CreateEffect(EntID, self.RoleEffInfo.CurrRoleEffID)
        self.Role4EffectMap[EntID] = {
            ClearHdl = Hdl,
            EffID = self.RoleEffInfo.CurrRoleEffID,
        }
    end
end

function PhotoMgr:PlayRoleEff(EntID, RoleEffID)
    local Cfg = PhotoRoleStatCfg:FindCfgByKey(RoleEffID)

    if not Cfg then
        ERR('[Photo][PhotoMgr][PlayRoleEff] Not cfg, CurrRoleEffID = ' .. tostring(RoleEffID))
        return
    end


    local EntityID = EntID


    if (not EntityID) or EntityID == 0 then
        ERR('[Photo][PhotoMgr][PlayRoleEff] Not EntityID, EntID = ' .. tostring(EntID))
        return
    end

    LOG(string.format('[Photo][PhotoMgr][PlayRoleEff] Cfg = %s',
        table.tostring(Cfg)
    ))

    local EffHdl
    local FuncHdl
    local AnimHdl 

    -- Cfg.Effect = "VfxBlueprint'/Game/Assets/Effect/Particles/Monster/Common/VBP/BP_dk10ht_hea0s.BP_dk10ht_hea0s_C'"
    if not string.isnilorempty(Cfg.Effect) then
        EffHdl = PhotoEffectUtil.CreateEffect(EntityID, Cfg.Effect)
    end

    FuncHdl = PhotoEffectUtil.PlayStat(EntityID, RoleEffID)

    -- Cfg.Anim = 13
    if Cfg.Anim and Cfg.Anim > 0 then
        local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
        if AnimComp then
            local ActionAniPath = self:GetEmotionPath(Cfg.Anim)
            if ActionAniPath then
                local UpValMont = AnimComp:PlayAnimation(ActionAniPath)
                AnimHdl = function()
                    LOG(string.format('[Photo][PhotoMgr][PlayRoleEff] Stop Anim = %s', tostring(Cfg.Anim)))
                    
                    if AnimComp == nil then return end
                    local AnimInstance = AnimComp:GetAnimInstance()
                    if AnimInstance == nil then return end

                    -- local Montage = AnimInstance:GetCurrentActiveMontage()
                    if UpValMont then
                        -- AnimComp:StopAnimationByMontage(AnimInstance, Montage) 
                        AnimationUtil.MontageStop(AnimInstance, UpValMont) 
                    end
                end
            else
                ERR('[Photo][PhotoMgr][PlayRoleEff] Not ActionAniPath, AnimID = ' .. tostring(Cfg.Anim))
            end
            
        else
            ERR('[Photo][PhotoMgr][PlayRoleEff] Not AnimComp, EntityID = ' .. tostring(EntityID))
        end
        
    end

    return function ()
        if EffHdl then
            PhotoEffectUtil.DelEffect(EffHdl)
        end

        if FuncHdl then
            FuncHdl()
        end

        if AnimHdl then
            AnimHdl()
        end
    end
end

-------------------------------------------------------------------------------------------------------
---@region 景深

function PhotoMgr:DEBUG_DIS()
    local Cam = PhotoCameraUtil.GetCamCtr()
    if Cam then
        self:RegisterTimer(function() 
            local DIS = Cam:GetTargetArmLength()
            _G.FLOG_SCREEN("DIS = " .. tostring(DIS))
        end, 0, 1, 0)
    end
end

function PhotoMgr:CheckAndSwitchDOFTimer(DOFScale)
    local Dof = DOFScale

    if Dof > 0 then
        self:DoUpdateDOFSetting()
        self:StartDOFTimer()
    else
        self:DoUpdateDOFSetting()
        self:EndDOFTimer()
    end
end

function PhotoMgr:StartDOFTimer()
    self:EndDOFTimer()

    self.TimerUpdDOF = self:RegisterTimer(self.OnDOFTimer, 0, 0.5, 0)
end

function PhotoMgr:EndDOFTimer()
    if self.TimerUpdDOF then
		self:UnRegisterTimer(self.TimerUpdDOF)
		self.TimerUpdDOF = nil
	end
end

function PhotoMgr:OnDOFTimer()
    -- _G.FLOG_INFO('[Photo][PhotoMgr][OnDOFTimer]')
    self:UpdateDOFSetting()
end

function PhotoMgr:UpdateDOFSetting()
    local Cam = PhotoCameraUtil.GetCamCtr()
    if Cam then
        local CamDis = Cam:GetTargetArmLength()

        if self.LastCamDis ~= CamDis then
            self.LastCamDis = CamDis
            self:DoUpdateDOFSetting(CamDis)
        end
    end
end

function PhotoMgr:DoUpdateDOFSetting(Dis)
    local CamDis
    if Dis then
        CamDis = Dis
    else
        local Cam = PhotoCameraUtil.GetCamCtr()
        if Cam then
            CamDis = Cam:GetTargetArmLength()
        else
            return
        end
    end

    local Region = CamDis - PhotoDefine.DofDis

    PhotoCameraUtil.SetDOFRegionAndDis(CamDis, Region)
end

-------------------------------------------------------------------------------------------------------
---@region 拍照

function PhotoMgr:TakePhoto()
    self:ReqTakePhoto()
end

function PhotoMgr:ReqTakePhoto()
    if self.TakePhotoTimerID then
        return
    end

    -- _G.UE.USettingUtil.ExeCommand("r.ScreenPercentage", 300)

    self.TakePhotoTimerID = self:RegisterTimer(self.OnTimerTakePhoto,0.05,0.05,1)
end

function PhotoMgr:OnTimerTakePhoto()
    LOG(string.format('[Photo][PhotoMgr][OnTimerTakePhoto]'))

    PhotoMediaUtil.CapScreen(function (W, H, AR) 
        local Tex = _G.UE.UMediaUtil.CovertColorsToTexture2D("", AR, W, H)
        _G.UE.UUIUtil.SetTextureHighQuality(Tex,_G.UE.TextureCompressionSettings.TC_EditorIcon)
        -- print('testinfo set succ')
        _G.ShareMgr:OpenPhotoShare(Tex, W, H, true)
        -- _G.UE.USettingUtil.ExeCommand("r.ScreenPercentage", 100)
        self.TakePhotoTimerID = nil
        EventMgr:SendEvent(EventID.TakePhotoSucc)
        self:ReportTakePhotoFootStep()
        self:TLogTakePhoto()
		_G.ObjectMgr:CollectGarbage(false)
	end)
end

-------------------------------------------------------------------------------------------------------
---@region TLOG

function PhotoMgr:TLogShowView()
    DataReportUtil.ReportData("TakePicturesClickFlow", true, false, true,
        "OpType", "1"
    )
end

function PhotoMgr:TLogTakePhoto()
    local CameraData = _G.PhotoCamVM:GetTLogData()

    local Depthoffield = CameraData.DOF
    local Farandnear = CameraData.FOV
    local Rotate = CameraData.Rot
    local CharacterActions = _G.PhotoActionVM.CurID
    local Characterexpression = _G.PhotoEmojiVM.CurID
    local Rolestatus = _G.PhotoRoleStatVM.CurID
    local Filter = _G.PhotoFilterVM.CurID
    local DarkSide = _G.PhotoDarkEdgeVM.Aspect
    local Time = _G.PhotoSceneVM.Time
    local Weather = _G.PhotoSceneVM.WeatherID

    local Info = _G.PhotoTemplateVM.CurItemVM or {}
    local TemplateType = Info.IsCust and 1 or 2
    local Template = Info.ID

    local RsData = _G.PhotoRoleSettingVM:GetTLogData()
    local Rolesetting = RsData

    DataReportUtil.ReportData("TakePicturesFlow", true, false, true,
        "Depthoffield",             tostring(Depthoffield),
        "Farandnear",               tostring(Farandnear),
        "Rotate",                   tostring(Rotate),
        "CharacterActions",         tostring(CharacterActions),
        "Characterexpression",      tostring(Characterexpression),
        "Rolestatus",               tostring(Rolestatus),
        "Rolesetting",              tostring(Rolesetting),
        "Filter",                   tostring(Filter),
        "DarkSide",                 tostring(DarkSide),
        "Time",                     tostring(Time),
        "Weather",                  tostring(Weather),
        "TemplateType",             tostring(TemplateType),
        "Template",                 tostring(Template)
    )
end

function PhotoMgr:ReportTakePhotoFootStep()
    _G.ClientReportMgr:SendClientReport(ClientReportType.ReportTypeTakePhotos or 8)
end

return PhotoMgr