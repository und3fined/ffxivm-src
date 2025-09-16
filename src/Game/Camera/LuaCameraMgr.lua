local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local CommonUtil = require("Utils/CommonUtil")
local NpcDialogCameraCfg = require("TableCfg/NpcDialogCameraCfg")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local NpcDialogSkeletonGroupCfg = require("TableCfg/NpcDialogSkeletonGroupCfg")

local CameraFocusType = ProtoRes.CameraFocusTypeEnum
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING
local UE = _G.UE

local GameNetMsgRegister
local GameEventRegister
local TimerRegister

local LuaCameraMgr = LuaClass(MgrBase)

function LuaCameraMgr:Ctor()
end

function LuaCameraMgr:OnInit()
end

function LuaCameraMgr:OnBegin()
    GameNetMsgRegister = require("Register/GameNetMsgRegister")
    GameEventRegister = require("Register/GameEventRegister")
    TimerRegister = require("Register/TimerRegister")
end

function LuaCameraMgr:OnEnd()
end

function LuaCameraMgr:OnShutdown()
end

function LuaCameraMgr:OnRegisterNetMsg()
end

function LuaCameraMgr:OnRegisterGameEvent()
end

function LuaCameraMgr:OnRegisterTimer()
end

function LuaCameraMgr:HasExtraCamera()
    return nil ~= self.ExtraCamera and CommonUtil.IsObjectValid(self.ExtraCamera)
end

--- ---@param TargetID integer NPC对话镜头配置表里的ConfigID
---@param ViewConfigID int32
---@param InNpcEntityId int32
function LuaCameraMgr:TryChangeViewByConfigID(ViewConfigId, InNpcEntityId)
	if nil == ViewConfigId or ViewConfigId == 0 then
		FLOG_ERROR("Invalid view config ID")
		return
	end

    local OriginSearchStr = string.format("ConfigID = %d", ViewConfigId)
    CameraCfgDataList = NpcDialogCameraCfg:FindAllCfg(OriginSearchStr)
    if nil == CameraCfgDataList or #CameraCfgDataList < 1 then
        FLOG_ERROR("NPC特写镜头 NpcDialogCameraCfg:FindAllCfg 找不到数据，查找字符串是 : "..OriginSearchStr)
        return
    end

    local InViewType = CameraCfgDataList[1].CameraFocusType
    if (InViewType <= 0) then
        FLOG_ERROR("传入的ViewConfigId无效，ID是"..ViewConfigId)
        return
    end

    local bNeedNpc = InViewType ~= CameraFocusType.MajorBack
    local TargetNpc = nil
    if (bNeedNpc) then
        TargetNpc = ActorUtil.GetActorByEntityID(InNpcEntityId)
    end

    if (bNeedNpc and TargetNpc == nil) then
        FLOG_ERROR("需要NPC，但是无法通过EntityId获取，Id是：%s",tostring(InNpcEntityId))
        return
    end

	local Major = MajorUtil.GetMajor()
	if nil == Major then
        FLOG_ERROR("TryChangeViewByConfigID 的 MajorUtil.GetMajor()为空")
		return
	end

	local CameraCfgDataList = nil
    local ResultCameraCfgData = nil
    local DefaultCameraCfgData = nil

    if (InViewType == CameraFocusType.Closeup) then
        -- NPC特写镜头
        local OriginSearchStr = string.format("ConfigID = %d", ViewConfigId)
        CameraCfgDataList = NpcDialogCameraCfg:FindAllCfg(OriginSearchStr)
        if nil == CameraCfgDataList then
            FLOG_ERROR("NPC特写镜头 NpcDialogCameraCfg:FindAllCfg 找不到数据，查找字符串是 : "..OriginSearchStr)
            return
        end

        local SearchStr = nil
        local NPCSkeletonGroupCfgData = nil
        local NPCSkeletonGroup = 0
        local AvatarComp = TargetNpc:GetAvatarComponent()
        if (AvatarComp ~= nil) then
            SearchStr = string.format("SkeletonName = \"%s\"", AvatarComp:GetAttachTypeIgnoreChangeRole())
            NPCSkeletonGroupCfgData = NpcDialogSkeletonGroupCfg:FindCfg(SearchStr)
            NPCSkeletonGroup = nil ~= NPCSkeletonGroupCfgData and NPCSkeletonGroupCfgData.NPCSkeletonGroup or 0
        else
            _G.FLOG_ERROR("无法获取角色的 AvatarComp，EntityID : %s", InNpcEntityId)
        end

        for _, CameraCfgData in ipairs(CameraCfgDataList) do
            if DefaultCameraCfgData == nil or CameraCfgData.NPCSkeletonGroup == 0 then
                DefaultCameraCfgData = CameraCfgData
            elseif CameraCfgData.NPCSkeletonGroup == NPCSkeletonGroup then
                ResultCameraCfgData = CameraCfgData
                break
            end
        end
    elseif (InViewType == CameraFocusType.MajorBack) then
        -- 基于玩家背面的单人镜头
        local OriginSearchStr = nil
        local TempStrOne = string.format("SkeletonName = \"%s\"", Major:GetAvatarComponent():GetAttachTypeIgnoreChangeRole())
        local PlayerSkeletonGroupCfgData = NpcDialogSkeletonGroupCfg:FindCfg(TempStrOne)
        local PlayerSkeletonGroup = nil ~= PlayerSkeletonGroupCfgData and PlayerSkeletonGroupCfgData.PlayerSkeletonGroup or 0
        local TempStrTwo  = string.format("ConfigID = %d AND PlayerSkeletonGroup = %d", ViewConfigId, PlayerSkeletonGroup)
        CameraCfgDataList = NpcDialogCameraCfg:FindAllCfg(TempStrTwo)
        if nil == CameraCfgDataList then
            OriginSearchStr = string.format("ConfigID = %d", ViewConfigId)
            CameraCfgDataList = NpcDialogCameraCfg:FindAllCfg(OriginSearchStr)
            FLOG_ERROR("玩家背面的单人镜头 NpcDialogCameraCfg:FindAllCfg 找不到数据，将使用默认数据，字符串是 : "..TempStrTwo)
        end
        if nil == CameraCfgDataList then
            FLOG_ERROR("玩家背面的单人镜头 NpcDialogCameraCfg:FindAllCfg 找不到数据，查找字符串是 : "..OriginSearchStr)
            return
        end
        for _, CameraCfgData in ipairs(CameraCfgDataList) do
            if DefaultCameraCfgData == nil or CameraCfgData.PlayerSkeletonGroup == 0 then
                DefaultCameraCfgData = CameraCfgData
            elseif CameraCfgData.PlayerSkeletonGroup == PlayerSkeletonGroup then
                ResultCameraCfgData = CameraCfgData
                break
            end
        end
    else
        -- 双人镜头，根据玩家骨骼和NPC骨骼组过滤
        local TempStrOne = string.format("SkeletonName = \"%s\"", Major:GetAvatarComponent():GetAttachTypeIgnoreChangeRole())
		local PlayerSkeletonGroupCfgData = NpcDialogSkeletonGroupCfg:FindCfg(TempStrOne)
		local PlayerSkeletonGroup = nil ~= PlayerSkeletonGroupCfgData and PlayerSkeletonGroupCfgData.PlayerSkeletonGroup or 0

        local TempStrTwo  = string.format("ConfigID = %d AND PlayerSkeletonGroup = %d", ViewConfigId, PlayerSkeletonGroup)
		CameraCfgDataList = NpcDialogCameraCfg:FindAllCfg(TempStrTwo)

        if nil == CameraCfgDataList then
            FLOG_ERROR("双人镜头玩家数据 NpcDialogCameraCfg:FindAllCfg 找不到数据，查找字符串是 : "..TempStrTwo)
            return
        end

        local SearchStr = nil
        local NPCSkeletonGroupCfgData = nil
        local NPCSkeletonGroup = 0
        local AvatarComp = TargetNpc:GetAvatarComponent()
        if (AvatarComp ~= nil) then
            SearchStr = string.format("SkeletonName = \"%s\"", AvatarComp:GetAttachTypeIgnoreChangeRole())
            NPCSkeletonGroupCfgData = NpcDialogSkeletonGroupCfg:FindCfg(SearchStr)
            NPCSkeletonGroup = nil ~= NPCSkeletonGroupCfgData and NPCSkeletonGroupCfgData.NPCSkeletonGroup or 0
        else
            _G.FLOG_ERROR("无法获取角色的 AvatarComp，EntityID : %s", InNpcEntityId)
        end

        for _, CameraCfgData in ipairs(CameraCfgDataList) do
            if DefaultCameraCfgData == nil or CameraCfgData.NPCSkeletonGroup == 0 then
                DefaultCameraCfgData = CameraCfgData
            elseif CameraCfgData.NPCSkeletonGroup == NPCSkeletonGroup then
                ResultCameraCfgData = CameraCfgData
                break
            end
        end
    end

	local FinalCameraCfgData = ResultCameraCfgData or DefaultCameraCfgData
	if nil == FinalCameraCfgData then
		FLOG_ERROR("数据出错，没有 ResultCameraCfgData or DefaultCameraCfgData")
		return
	end

	local ViewParams =
	{
		ViewType = InViewType,
		PlayerEID = FinalCameraCfgData.PlayerEID,
		NPCEID = FinalCameraCfgData.NPCEID,
		ViewDistance = FinalCameraCfgData.Distance,
		ExtraRotation = _G.UE.FRotator(FinalCameraCfgData.Pitch, FinalCameraCfgData.Yaw, FinalCameraCfgData.Roll),
		SocketOffset = _G.UE.FVector(FinalCameraCfgData.OffsetX, FinalCameraCfgData.OffsetY, FinalCameraCfgData.OffsetZ),
        InNpcEntityId = InNpcEntityId,
        OpenCollision = FinalCameraCfgData.CancelCollision ~= 1,
        FOV = FinalCameraCfgData.FOV
	}

    return self:ChangeViewByParams(ViewParams), FinalCameraCfgData.ID
end

--- func desc
---@param TargetID integer NPC对话镜头配置表里的唯一ID
function LuaCameraMgr:TrySwitchCameraByID(TargetID, InNpcEntityId)
    local TableData = NpcDialogCameraCfg:FindCfgByKey(TargetID)
    if (TableData == nil) then
        FLOG_ERROR("无法获取 NpcDialogCameraCfg 表格数据 请检查 , ID : %s", TargetID)
        return
    end

    local ExtraCamera = self:GetExtraCamera()
    if (ExtraCamera == nil) then
        FLOG_ERROR("无法获取到额外的摄像机请检查")
        return
    end

    local TempSocketOffset = _G.UE.FVector(TableData.OffsetX, TableData.OffsetY, TableData.OffsetZ)
    local TempRotation = _G.UE.FRotator(TableData.Pitch, TableData.Yaw, TableData.Roll)

    local ViewParams = {
        ViewType = TableData.CameraFocusType,
        PlayerEID = TableData.PlayerEID,
        NPCEID = TableData.NPCEID,
        ViewDistance = TableData.Distance,
        ExtraRotation = TempRotation,
        SocketOffset = TempSocketOffset,
        FOV = TableData.FOV,
        InNpcEntityId = InNpcEntityId,
        OpenCollision = TableData.CancelCollision ~= 1
    }

    return self:ChangeViewByParams(ViewParams)
end

function LuaCameraMgr:ChangeViewByParams(Params)
    if (Params == nil) then
        FLOG_ERROR("传入的 Params 为空，请检查")
        return
    end
    local CameraFocusType = Params.ViewType
    if (CameraFocusType == ProtoRes.CameraFocusTypeEnum.NotValid) then
        FLOG_ERROR("传入的镜头聚焦类型错误，请检查")
        return
    end

    local PlayerEID = Params.PlayerEID
    local NPCEID = Params.NPCEID
    local ViewDistance = Params.ViewDistance
    local ExtraRotation = Params.ExtraRotation
    local SocketOffset = Params.SocketOffset
    local FOV = Params.FOV
    local InNpcEntityId = Params.InNpcEntityId
    local FocusLocation = nil
    local RawRotation = nil
    local TargetNpc = nil
    local bNeedNpc = CameraFocusType ~= ProtoRes.CameraFocusTypeEnum.MajorBack -- 目前只有玩家背面是不需要NPC的
    if (bNeedNpc) then
        if (InNpcEntityId ~= nil and InNpcEntityId > 0) then
            TargetNpc = ActorUtil.GetActorByEntityID(InNpcEntityId)
        end
    end

    if (bNeedNpc and TargetNpc == nil) then
        FLOG_ERROR("镜头有NPC参与，但是无法获取NPC，请检查")
        return
    end

    if (TargetNpc ~= nil and TargetNpc:IsMeshLoaded() == false) then
        return
    end

    local Major = MajorUtil.GetMajor()
    if (Major == nil) then
        return
    end

    if (CameraFocusType == ProtoRes.CameraFocusTypeEnum.Closeup) then
        local NPCEIDLocation = TargetNpc:GetSocketLocationByName(NPCEID)
        -- NPC正面特写
        FocusLocation = NPCEIDLocation
        RawRotation = (-TargetNpc:GetActorForwardVector()):ToRotator()
    elseif (CameraFocusType == ProtoRes.CameraFocusTypeEnum.MajorBack) then
        local PlayerEIDLocation = Major:GetSocketLocationByName(PlayerEID)
        FocusLocation = PlayerEIDLocation
        RawRotation = (Major:GetActorForwardVector()):ToRotator()
    else
        local NPCEIDLocation = TargetNpc:GetSocketLocationByName(NPCEID)
        local PlayerEIDLocation = Major:GetSocketLocationByName(PlayerEID)
        FocusLocation = (NPCEIDLocation + PlayerEIDLocation) * 0.5
        local Major2NPC = NPCEIDLocation - PlayerEIDLocation
        local DirectionFactor = CameraFocusType == ProtoRes.CameraFocusTypeEnum.TwoPeoplePlayerLeft and 1 or -1
        RawRotation = (Major2NPC * DirectionFactor):Cross(_G.UE.FVector(0, 0, 1)):ToRotator()
    end
    if (FocusLocation == nil) then
        FocusLocation = _G.UE.FVecotr(0, 0, 0) -- 保险措施，防止FocusLocation为空，引起崩溃
    end
    if (SocketOffset == nil) then
        SocketOffset = _G.UE.FVecotr(0, 0, 0) -- 保险措施，防止FocusLocation为空，引起崩溃
    end

    local Rotation = RawRotation + ExtraRotation
    if (Rotation == nil) then
        Rotation = _G.UE.FRotator(0,0,0) -- 保险措施，防止FocusLocation为空，引起崩溃
    end

    local DialogCamera = self:GetExtraCamera()
    DialogCamera:SetViewDistance(ViewDistance, false)
    DialogCamera:SetTargetLocation(FocusLocation, false)
    DialogCamera:SetSocketOffset(SocketOffset, false)
    DialogCamera:Rotate(Rotation, false)
	DialogCamera:SwitchCollision(false)
	DialogCamera:UpdateTransformImmediately()
	if Params.OpenCollision == true then
		self:CheckDistanceWithCollision(Rotation, ViewDistance)
	end
    if self.Timer then
        self:UnRegisterTimer(self.Timer)
        self.Timer = nil
    end
    self.Timer = self:RegisterTimer(
        function()
            _G.UE.UCameraMgr.Get():SwitchCamera(DialogCamera, 0) -- 每次都切一下避免调用者忘了切
            -- 设置FOV要放在 SwitchCamera 后面，因为里面会拷贝主摄像机的FOV
            if (FOV ~= nil and FOV > 0) then
                DialogCamera:SetFOVY(FOV)
            end
        end,
        0.01,
        0,
        1
    )
    _G.UIUtil.SetInputMode_UIOnly()
    return {RawRotation = RawRotation}
end

function LuaCameraMgr:GetExtraCamera()
    if not self:HasExtraCamera() then
        self.ExtraCamera = CommonUtil.SpawnActor(UE.ATargetCamera, UE.FVector(0, 0, 0), UE.FRotator(0, 0, 0))
    end
    return self.ExtraCamera
end

function LuaCameraMgr:ResumeCamera(ResetToDefault)
    if self.Timer then
        self:UnRegisterTimer(self.Timer)
        self.Timer = nil
    end
    local CameraMgr = _G.UE.UCameraMgr.Get()
    if CameraMgr ~= nil then
        CameraMgr:ResumeCamera(0, true, self:HasExtraCamera() and self.ExtraCamera or nil)
    end

    if (ResetToDefault == true) then
        local Major = MajorUtil.GetMajor()
        if (Major ~= nil) then
            Major:GetCameraControllComponent():ResetSpringArmToDefault()
        end
    end

    _G.UIUtil.SetInputMode_GameAndUI()
end

-- 从当前的主角相机获取默认FCameraResetParam参数
function LuaCameraMgr:GetDefaultCameraParam()
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		return 
	end

	local MajorCameraCom = Major:GetCameraControllComponent()
	if MajorCameraCom == nil then
		return 
	end

	local OriginCameraParams = _G.UE.FCameraResetParam()
	OriginCameraParams.Distance = MajorCameraCom:GetTargetArmLength()
	OriginCameraParams.Rotator = MajorCameraCom:GetCameraBoomRelativeRotation()
	OriginCameraParams.TargetOffset = MajorCameraCom:GetTargetOffset()
	OriginCameraParams.SocketExternOffset = MajorCameraCom:GetSocketTargetOffset()
	OriginCameraParams.ResetType = _G.UE.ECameraResetType.Interp
	OriginCameraParams.FOV = MajorCameraCom:GetATPCFOV()
	OriginCameraParams.bRelativeRotator = false
	OriginCameraParams.LagValue = 10
	return OriginCameraParams
end

function LuaCameraMgr:CheckDistanceWithCollision(Rotation, CurrentDistance)
    local DialogCamera = self:GetExtraCamera()

	-- 各Transform信息计算
	local ExactFocusLocation = DialogCamera:GetFocusLocation()
	local Direction = -Rotation:ToVector()
	Direction:Normalize()
	local CameraLocation = DialogCamera:GetFocusLocation() + Direction * CurrentDistance

	-- 检查相机当前位置是否有碰撞
	local ObjectTypeArray = _G.UE.TArray(_G.UE.EObjectTypeQuery)
	ObjectTypeArray:Add(_G.UE.ECollisionChannel.ECC_WorldStatic)
	local SphereRadius = 10.0
	if not _G.UE.UKismetSystemLibrary.SphereOverlapComponents(_G.FWORLD(), CameraLocation, SphereRadius, ObjectTypeArray,
	  nil, nil, nil) then
		return
	else
		FLOG_INFO("Camera start with overlapping")
	end

	-- 将相机调整到最近的非碰撞点
	local OutHits = _G.UE.TArray(_G.UE.FHitResult)
	_G.UE.UKismetSystemLibrary.SphereTraceMultiForObjects(_G.FWORLD(), ExactFocusLocation, CameraLocation, SphereRadius,
		ObjectTypeArray, true, nil, _G.UE.EDrawDebugTrace.None, OutHits)

	for Index = 1, OutHits:Length() do
		if not OutHits:GetRef(Index).bStartPenetrating and
		  not _G.UE.UKismetSystemLibrary.SphereOverlapComponents(_G.FWORLD(),
		  OutHits:GetRef(Index).Location, SphereRadius, ObjectTypeArray, nil, nil, nil) then
			local NewDistance = OutHits:GetRef(Index).Distance
			DialogCamera:SetViewDistance(NewDistance, false)
			break
		end
	end
end

function LuaCameraMgr:ResetMajorCameraSpringArmByParam(CameraResetType, CameraMoveParam)
    local Major = MajorUtil.GetMajor()
    local MajorCameraCom = Major and Major:GetCameraControllComponent() or nil
    if MajorCameraCom then
        MajorCameraCom:ResetSpringArmByParam(CameraResetType, CameraMoveParam)
    end

    _G.UIUtil.SetInputMode_GameAndUI()
end

function LuaCameraMgr:UpdateAmbientOcclusionParam(bEnable, AORadius, AOIntensity, AmbientOcclusionType)
    local FAmbientOcclusionParam = _G.UE.FAmbientOcclusionParam()
    local EAmbientOcclusionType = AmbientOcclusionType or _G.UE.EAmbientOcclusionType.UI
    FAmbientOcclusionParam.bEnabled = bEnable

    local UCameraPostEffectMgr = _G.UE.UCameraPostEffectMgr.Get()
    if UCameraPostEffectMgr then
        if bEnable then
            FAmbientOcclusionParam.AORadius = AORadius or 2
            FAmbientOcclusionParam.AOIntensity = 0 --AOIntensity or 0.2
            UCameraPostEffectMgr:UpdateAmbientOcclusionParam(EAmbientOcclusionType, FAmbientOcclusionParam)
        else
            UCameraPostEffectMgr:UpdateAmbientOcclusionParam(EAmbientOcclusionType, FAmbientOcclusionParam)
        end
    end
end

return LuaCameraMgr
