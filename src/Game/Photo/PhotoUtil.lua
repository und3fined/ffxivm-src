local Util = {}
local PhotoDefine = require("Game/Photo/PhotoDefine")
local AnimType = PhotoDefine.AnimType
local MsgTipsID = require("Define/MsgTipsID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")

function Util.CheckEmo4Photo(EmoCfg)
    return EmoCfg.PhotoHide ~= 1
end

function Util.ShowAnimTips(InAnimType, ID)
    if InAnimType == AnimType.Motion or InAnimType == AnimType.Face then
        _G.EmotionMgr:ShowCannotUseTips(ID)
    else
        MsgTipsUtil.ShowTipsByID(MsgTipsID.EmitionCannotUse)
    end
end

---@param EmotionID 	情感动作ID
---@param EntityID 		玩家EntityID
function Util.IsEnableIDMovement(EntityID)

    local EmotionMgr = _G.EmotionMgr
	
	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if not Actor then return end
	local StateCom = ActorUtil.GetActorStateComponent(EntityID)
	if StateCom == nil then return end
	local RideCom = Actor:GetRideComponent()
	if RideCom == nil then return end
	local AttributeComp = ActorUtil.GetActorAttributeComponent(EntityID)
	if AttributeComp == nil then return end

	-- 先使用EmotionMgr数据,后面movement也会合到情感动作
	-- local SitChairID = EmotionMgr.SitChairID
	-- local SitGroundID = EmotionMgr.SitGroundID

	local IsSit = _G.EmotionMgr:IsSitState(EntityID)
	local bIsActiveChangeRole = EmotionMgr.bIsActiveChangeRole
	local bBecomeHuman = EmotionMgr.bBecomeHuman

	local RideID = RideCom:GetRideResID()
	local bIsRiding = RideCom:IsInRide()			--坐骑中
	local bIsSwimming = Actor:IsSwimming()			--游泳中
	local bIsFish = _G.FishMgr:IsInFishState()		--钓鱼中
	local bIsUsingSkill = StateCom:IsUsingSkill()	--技能中
	local bIsStorage = _G.SkillStorageMgr:IsStorage(EntityID)	--蓄力中
	local bIsDead = StateCom:IsDeadState()			--死亡中
	local bIsChange = bIsActiveChangeRole and not bBecomeHuman or false	--变人
	local bSpecialState = bIsUsingSkill or bIsStorage or bIsDead or bIsChange	--特殊状态，所有动作都不可用
	local bIsEnable = true

	if bSpecialState then
		bIsEnable = false
	elseif bIsRiding then   --坐骑状态
		bIsEnable = false
	elseif bIsSwimming then	 --游泳状态
		bIsEnable = false
	elseif bIsFish then		 --钓鱼状态
		bIsEnable = false
	elseif IsSit then
        bIsEnable = false
	end
    
	return bIsEnable
end

-- 获取坐骑乘客EntityID列表
function Util.GetPassengerEnts()
	local Major = MajorUtil:GetMajor()
    if not Major then return end
    local RideComp = Major:GetRideComponent()
	if not RideComp then return end
	if not RideComp:IsInRide() then return end
	
	local PassengerEntityIDList = {}

	local bIsInOtherRide = RideComp:IsInOtherRide()
	if bIsInOtherRide then
		local HostEntityID = RideComp:GetHostEntityID()
		local HostActor = ActorUtil.GetActorByEntityID(HostEntityID)
		if not HostActor then return end
		RideComp = HostActor:GetRideComponent()
		if not RideComp then return end
		table.insert(PassengerEntityIDList, HostEntityID)
	end

	local MajorEntityID = MajorUtil.GetMajorEntityID()
	for i = 1, RideComp:GetSeatCount() do
		local EntityID = RideComp:GetPassengerEntityID(i)
        if EntityID > 0 and (not bIsInOtherRide or EntityID ~= MajorEntityID) then
            table.insert(PassengerEntityIDList, EntityID)
        end
    end
	return PassengerEntityIDList
end

function Util.SetCharacterLookAtCamera(Actor, PartType, bKeepCurrent, bAddictive)
    if Actor and PartType then
        local LookAtCameraParams = _G.UE.FLookAtParams()
        LookAtCameraParams.LookAtType = PartType
        LookAtCameraParams.Target.Type = _G.UE.ELookAtTargetType.Camera
        LookAtCameraParams.bKeepCurrent = bKeepCurrent
        LookAtCameraParams.bAddictive = bAddictive
        ActorUtil.SetCharacterLookAtParams(Actor, LookAtCameraParams)
    end
end

function Util.SetCharacterLookAtNone(Actor, PartType, bKeepCurrent, bAddictive)
    if Actor and PartType then
        local LookAtCameraParams = _G.UE.FLookAtParams()
        LookAtCameraParams.LookAtType = PartType
        LookAtCameraParams.Target.Type = _G.UE.ELookAtTargetType.None
        LookAtCameraParams.bKeepCurrent = bKeepCurrent
        LookAtCameraParams.bAddictive = bAddictive
        ActorUtil.SetCharacterLookAtParams(Actor, LookAtCameraParams)
    end
end

function Util.SetCharacterLookAtActor(Actor, PartType, bKeepCurrent, bAddictive, TargetCharacter)
    if Actor and PartType then
        local LookAtCameraParams = _G.UE.FLookAtParams()
        LookAtCameraParams.LookAtType = PartType
		LookAtCameraParams.Target.Type = _G.UE.ELookAtTargetType.Actor
		LookAtCameraParams.Target.Target = TargetCharacter
        LookAtCameraParams.bKeepCurrent = bKeepCurrent
        LookAtCameraParams.bAddictive = bAddictive
        ActorUtil.SetCharacterLookAtParams(Actor, LookAtCameraParams)
    end
end

function Util.GetCropRangeDataByAspectRatio(SourceW, SourceH, TargetAspectRatio)
	if not SourceW or not SourceH or not TargetAspectRatio or SourceW <= 0 or SourceH <= 0 or TargetAspectRatio <= 0 then
		return
    end

	local OriginalAspect = SourceW / SourceH
	local CropWidth, CropHeight = SourceW, SourceH
	local StartX, StartY = 0, 0

	if OriginalAspect > TargetAspectRatio then
		-- 原始宽高比更宽：裁剪宽度
		CropWidth = SourceH * TargetAspectRatio
		StartX = (SourceW - CropWidth) / 2
	else
		--  原始宽高比更高：裁剪高度
		CropHeight = SourceW / TargetAspectRatio
		StartY = (SourceH - CropHeight) / 2
	end

	local CropCenterX = StartX + CropWidth * 0.5
    local CropCenterY = StartY + CropHeight * 0.5

	-- 像素位置
	return {
		StartX = StartX, StartY = StartY,
		EndX = StartX + CropWidth, EndY = StartY + CropHeight,
		CropWidth = CropWidth, CropHeight = CropHeight,
		CenterX = CropCenterX, CenterY = CropCenterY,
	}
end

function Util.ConvertTexturePixelToScreenCoord(SourceW, SourceH, PixelLeftPos, PixelSize, Widget)
	-- local UVMinX = PixelLeftPos.X / SourceW
	-- local UVMinY = PixelLeftPos.Y / SourceH
	-- local UVSizeX = PixelSize.X /  SourceW
	-- local UVSizeY = PixelSize.Y /  SourceH
	local UIUtil = require("Utils/UIUtil")
	local ViewportSize = UIUtil.GetViewportSize()
	local UVMinX = PixelLeftPos.X / ViewportSize.X
	local UVMinY = PixelLeftPos.Y / ViewportSize.Y
	local UVSizeX = PixelSize.X / ViewportSize.X
	local UVSizeY = PixelSize.Y / ViewportSize.Y
	--return  _G.UE.FVector2D(UVMinX * ViewportSize.X, UVMinY * ViewportSize.Y)
	local ScreenPos = UIUtil.LocalToAbsolute(Widget, PixelLeftPos)
	local ScreenSize = UIUtil.LocalToAbsolute(Widget, _G.UE.FVector2D(UVSizeX, UVSizeY))
	return ScreenPos, ScreenSize
end

function Util.GetNormalCropRengeData(SourceW, SourceH, CropWidth, CropHeight, CropCenterX, CropCenterY)
	local NormalizedSizeX = CropWidth / SourceW
    local NormalizedSizeY = CropHeight / SourceH
	local NormalizedCenterX = CropCenterX / SourceW
    local NormalizedCenterY = CropCenterY / SourceH
	return {
		NormalSX = NormalizedSizeX,
		NormalSY = NormalizedSizeY,
		NormalCX = NormalizedCenterX,
		NormalCY = NormalizedCenterY,
	}
end

function Util.GetCropBoxPositions(NoramlCropData, SourceW, SourceH)
	if table.is_nil_empty(NoramlCropData) or not SourceW or not SourceH then
		return
	end

    local CropWidth = NoramlCropData.NormalSX * SourceW
    local CropHeight = NoramlCropData.NormalSY * SourceH
    local CenterX = NoramlCropData.NormalCX * SourceW
    local CenterY = NoramlCropData.NormalCY * SourceH
	
    return {
		BoxStartX = CenterX - (CropWidth / 2),
		BoxStartY = CenterY - (CropHeight / 2),
		BoxEndX = CenterX + (CropWidth / 2),
		BoxEndY = CenterY + (CropHeight / 2),
    }
end


function Util.GetCropDataByCropType(CropType, Index)
	if not CropType then
		return
	end

	if CropType ~= PhotoDefine.UIEditCropType.Normal then
		return PhotoDefine.UIEditSubCropCfg[CropType][1]
	end

	if not table.is_nil_empty(PhotoDefine.UIEditSubCropCfg[CropType]) then
		return PhotoDefine.UIEditSubCropCfg[CropType][Index]
	end
end


return Util