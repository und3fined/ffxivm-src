---
--- Author: chaooren
--- DateTime: 2022-03-10 17:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local MajorUtil = require("Utils/MajorUtil")
local EffectUtil = require("Utils/EffectUtil")
local ActorUtil = require("Utils/ActorUtil")
local SkillAreaCfg = require("TableCfg/SkillAreaCfg")
local ProtoRes = require("Protocol/ProtoRes")

local KML = _G.UE.UKismetMathLibrary

local DecalPath = "Blueprint'/Game/Assets/Effect/BluePrint/JointSelect/JointDecal_Sector_Actor.JointDecal_Sector_Actor_C'"
local RectDecalPath = "Blueprint'/Game/Assets/Effect/BluePrint/JointSelect/JointDecal_Rect_PivotDown_Actor.JointDecal_Rect_PivotDown_Actor_C'"

---@class SecondJoyStickView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDefault UFButton
---@field FImg_Touch UFImage
---@field FImg_Touch_1 UFImage
---@field PanelRelease UFCanvasPanel
---@field PanelUnrelease UFCanvasPanel
---@field SecondJoyStick UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SecondJoyStickView = LuaClass(UIView, true)

function SecondJoyStickView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDefault = nil
	--self.FImg_Touch = nil
	--self.FImg_Touch_1 = nil
	--self.PanelRelease = nil
	--self.PanelUnrelease = nil
	--self.SecondJoyStick = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SecondJoyStickView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SecondJoyStickView:OnInit()

end

function SecondJoyStickView:OnDestroy()

end

function SecondJoyStickView:OnShow()
	self.FImg_Touch:SetRenderOpacity(0)
	self:SetCancelStatus(false)
	self.DirOffset = 0
	self.bSuccess = false
	self.DecalState = true
	self.CancelState = false
end

function SecondJoyStickView:OnHide()
	if self.WarningID ~= nil then
		EffectUtil.BreakSkillDecal(self.WarningID)
		self.WarningID = nil
	end
end

function SecondJoyStickView:OnRegisterUIEvent()

end

function SecondJoyStickView:OnRegisterGameEvent()

end

function SecondJoyStickView:OnRegisterBinder()

end

function SecondJoyStickView:OnCancelJSMoveCB(OldStatus, NewStatus)
	if OldStatus ~= NewStatus then
		self:SetCancelStatus(NewStatus)
	end
end

function SecondJoyStickView:SetCancelStatus(bCancel)
	self.CancelState = bCancel
	if bCancel then
		UIUtil.SetIsVisible(self.PanelRelease, false)
		UIUtil.SetIsVisible(self.PanelUnrelease, true)
		self.ValidImageTouch = self.FImg_Touch_1
	else
		UIUtil.SetIsVisible(self.PanelRelease, true)
		UIUtil.SetIsVisible(self.PanelUnrelease, false)
		self.ValidImageTouch = self.FImg_Touch
	end
end

function SecondJoyStickView:InitGeometryData()
	if self.bSuccess == false then
		return
	end
	self.FImg_Touch:SetRenderOpacity(1)
	local Geometry = self:GetCachedGeometry()
	local _, BasePos = _G.UE.USlateBlueprintLibrary.LocalToViewport(self, Geometry, _G.UE.FVector2D(0,0))
	self.RenderTransformScale = self.RenderTransform.Scale
	local BaseSize = UIUtil.CanvasSlotGetSize(self.SecondJoyStick) * self.RenderTransformScale
	
	self.WidgetCenter = BaseSize * 0.5 + BasePos
	self.RadiusXY = BaseSize * 0.5
	self.RadiusSquared = self.RadiusXY.X * self.RadiusXY.X--假设X==Y，用于拖拽最大值，拖拽超出该范围后视为最大距离
end


function SecondJoyStickView:GetAbsoluteAngle()
	if self.AbsoluteAngle == nil then
		return nil
	end

	if self.AbsoluteAngle >= 360 then
		return self.AbsoluteAngle - 360
	end

	if self.AbsoluteAngle < 0 then
		return self.AbsoluteAngle + 360
	end

	return self.AbsoluteAngle
end

function SecondJoyStickView:GetAbsolutePosition()
	return self.AbsolutePosition
end

function SecondJoyStickView:GetDecalState()
	return self.DecalState
end

function SecondJoyStickView:IsJoystickValid()
	return self.bSuccess == true
end

--贴花选点是否有效(无阻挡，符合8m高度要求)，如有效则贴地修正
local function ValidDecalLocation(MajorPosition, DecalPosition)
	local OutFloorPoint = _G.UE.FVector()
	local bValidLocation = _G.UE.USkillMgr.SkillJoyStickLineTrace(OutFloorPoint, MajorPosition, DecalPosition, 0)
	return bValidLocation == 0, OutFloorPoint
end

function SecondJoyStickView:Tick(_, InDeltaTime)
	if self:IsJoystickValid() ~= true then
		return
	end
	local Major = MajorUtil.GetMajor()
	local MajorPosition = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	local AbsolutePosition = self.DistVector + MajorPosition
	local bPosChange = false	--贴花位置或角色位置发生变化时重新计算
	if AbsolutePosition.X ~= self.AbsolutePosition.X or AbsolutePosition.Y ~= self.AbsolutePosition.Y then
		self.AbsolutePosition = AbsolutePosition
		bPosChange = true
	end

	if MajorPosition ~= self.CacheMajorPosition then
		self.CacheMajorPosition = MajorPosition
		bPosChange = true
	end
	if bPosChange == true then
		if self.bEnableJoyStickPoint == 1 then
			local bValidDecalPosition, FloorPosition = ValidDecalLocation(MajorPosition, AbsolutePosition)
			self.DecalState = bValidDecalPosition
			if bValidDecalPosition == true then
				self.AbsolutePosition = FloorPosition
			end
		end
		EffectUtil.SetSkillDecalState(self.WarningID, self.DecalState and not self.CancelState)
		EffectUtil.SetSkillDecalLocation(self.WarningID, self.AbsolutePosition)
	end
end

--获取选点角度，该角度以UI控件X轴向上为0，顺时针旋转（为什么不以水平向右为0呢）
local function GetAngle(NormalVec, TargetVec)
	local CosAngle = _G.UE.FVector2D.Cross(NormalVec, TargetVec)
	local Angle = KML.DegAsin(CosAngle)
	if TargetVec.Y >= 0 then
		Angle = 180 - Angle
	elseif TargetVec.X > 0 then
		Angle = Angle + 360
	end
	Angle = 360 - Angle
	return Angle
end

local function UseSelectTarget(TargetList, MajorPosition, MinDistance, MaxDistance)
	if TargetList:Length() > 0 then
		local Actor = ActorUtil.GetActorByEntityID(TargetList:GetRef(1))
		local ActorLocation = Actor:FGetLocation(_G.UE.EXLocationType.ServerLoc)	--这里取的目标单位高度，不知道要不要统一用主角高度
		local Major2Target = _G.UE.FVector2D(ActorLocation.X - MajorPosition.X, ActorLocation.Y - MajorPosition.Y)
		_G.UE.FVector2D.Normalize(Major2Target)
		local Angle = GetAngle(_G.UE.FVector2D(0, 1), Major2Target)
		local AbsoluteAngle = Angle - 90
		local Rotation = _G.UE.FRotator(0, AbsoluteAngle, 0)

		if MaxDistance * MaxDistance < _G.UE.FVector.DistSquared2D(ActorLocation, MajorPosition) then
			--大于最大施法距离的选点应修正到最大施法距离处
			local Distance2D = Major2Target * MaxDistance
			ActorLocation = MajorPosition + _G.UE.FVector(Distance2D.X, Distance2D.Y, 0)
		end
		return true, ActorLocation, Rotation, AbsoluteAngle
	else
		return false
	end
end

local function IsZeroVec(Vec)
	return Vec.X == 0 and Vec.Y == 0 and Vec.Z == 0
end

local function UseCharacterForward(MajorPosition, MajorRotation, MinDistance, MaxDistance)
	local MajorController = MajorUtil.GetMajorController()
	local InputVec = MajorController:GetCurrentInputVelocity()
	if IsZeroVec(InputVec) then
		MaxOffset = MajorRotation:RotateVector(_G.UE.FVector(MaxDistance, 0, 0))
	else
		local InputVec2D = _G.UE.FVector2D(InputVec.X, InputVec.Y)
		_G.UE.FVector2D.Normalize(InputVec2D)
		local Angle = GetAngle(_G.UE.FVector2D(0, 1), InputVec2D) - 90
		local Major = MajorUtil.GetMajor()
		local CameraRotation = Major:GetCameraBoomRelativeRotation()
		local AbsoluteAngle = Angle + CameraRotation.Yaw
		local Rotation = _G.UE.FRotator(0, AbsoluteAngle, 0)
		MaxOffset = Rotation:RotateVector(_G.UE.FVector(MaxDistance, 0, 0))
		return MajorPosition + MaxOffset, Rotation, AbsoluteAngle
	end
	
	return MajorPosition + MaxOffset, MajorRotation, MajorRotation.Yaw
end

function SecondJoyStickView:InitSkillData(SkillID, SkillSubID)
	local SkillCfg = SkillMainCfg:FindCfgByKey(SkillID)
	self.SkillID = SkillID
	self.SkillSubID = SkillSubID
	self.RangeID = SkillCfg.SkillJoyStickRangeId
	self.bEnableJoyStickPoint = SkillCfg.IsEnableJoyStickPoint
	self.JoyStickDefaultType = SkillCfg.JoyStickDefaultType

	self.MinCastDistance = SkillCfg.MinCastDistance
	self.MaxCastDistance = SkillCfg.CastDistance
	
	self:InitSelectDecalData(self.RangeID)
end

function SecondJoyStickView:InitSelectDecalData(RangeID)
	self.bSuccess = false
	if RangeID == 0 then
		return
	end
	local Cfg = SkillAreaCfg:FindCfgByKey(RangeID)
	if Cfg == nil then
		return
	end

	local AreaType = Cfg.AreaType	--2圆扇环， 3矩形
	local HOffset = Cfg.HOffset
	local VOffset = Cfg.VOffset
	local DirOffset = Cfg.DirOffset
	local AreaParamStr = Cfg.AreaParamStr
	local AreaParams = string.split(AreaParamStr, ",")

	local DecalType = 0
	if AreaType == 2 and tonumber(AreaParams[2]) < 1 then
		DecalType = 1 --圆扇形
	elseif AreaType == 2 and tonumber(AreaParams[2]) >= 1 then
		DecalType = 2 --圆扇环
	elseif AreaType == 3 then
		DecalType = 3 --矩形
	end

	local Offset = _G.UE.FVector(HOffset, VOffset, 0)
	local Major = MajorUtil.GetMajor()
	if not Major then
		return
	end
	local MajorRotation = Major:FGetActorRotation()
	local MajorPosition = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	local RelativeOffset = MajorRotation:RotateVector(Offset)
	--贴花以玩家朝向为基准的位置
	local DecalPosition = MajorPosition + RelativeOffset
	local SkillDecalInfo = _G.UE.FSkillDecalInfo()
	self.Offset = Offset
	if DecalType == 1 then
		SkillDecalInfo.Angle = AreaParams[3]
		SkillDecalInfo.Range = AreaParams[1] / 100
		SkillDecalInfo.LuaWarningPath = DecalPath
	elseif DecalType == 3 then
		SkillDecalInfo.Angle = AreaParams[1] / 100
		SkillDecalInfo.Range = AreaParams[2] / 100
		SkillDecalInfo.LuaWarningPath = RectDecalPath
		DecalPosition = DecalPosition - RelativeOffset  --矩形考虑半个宽度偏移
		self.Offset = Offset - _G.UE.FVector(AreaParams[2] / 2, 0, 0)	--矩形需要偏移半个宽度以修正图形起点
	else
		return
	end

	local Pos = DecalPosition
	local Rot = MajorRotation
	local AbsoluteAngle = MajorRotation.Yaw

	if self.JoyStickDefaultType == ProtoRes.DefaultPointType.SelectTarget then
		local TargetList = _G.SelectTargetMgr:SelectTargets(self.SkillID, self.SkillSubID, 1, Major, false, true)
		local Result = false
		Result, Pos, Rot, AbsoluteAngle = UseSelectTarget(TargetList, MajorPosition, self.MinCastDistance, self.MaxCastDistance)
		if not Result then
			Pos, Rot, AbsoluteAngle = UseCharacterForward(MajorPosition, MajorRotation, self.MinCastDistance, self.MaxCastDistance)
		end
	elseif self.JoyStickDefaultType == ProtoRes.DefaultPointType.CharacterForward then
		Pos, Rot, AbsoluteAngle = UseCharacterForward(MajorPosition, MajorRotation, self.MinCastDistance, self.MaxCastDistance)
	-- else	--ProtoRes.DefaultPointType.CharacterPos

	end

	if self.bEnableJoyStickPoint ~= 1 then
		Pos = DecalPosition
	end
	SkillDecalInfo.Location = Pos
	SkillDecalInfo.Rotation = Rot + _G.UE.FRotator(0, DirOffset, 0)
	self.AbsoluteAngle = AbsoluteAngle

	self.AbsolutePosition = SkillDecalInfo.Location
	self.DistVector = self.AbsolutePosition - MajorPosition

	--贴花是否位于有效位置
	if self.bEnableJoyStickPoint == 1 then
		local bValidDecalPosition, FloorPosition = ValidDecalLocation(MajorPosition, self.AbsolutePosition)
		SkillDecalInfo.DecalState = bValidDecalPosition
		self.DecalState = bValidDecalPosition
		if bValidDecalPosition == true then
			SkillDecalInfo.Location = FloorPosition
			self.AbsolutePosition = FloorPosition
		end
	else
		--方向型技能贴花状态始终为true
		SkillDecalInfo.DecalState = true
	end

	self.CacheMajorPosition = MajorPosition	--缓存主角位置用于判断是否发生变化
	SkillDecalInfo.AnimTime = -1
	SkillDecalInfo.AnimCycle = 1

	self.WarningID = EffectUtil.PlaySkillDecal(SkillDecalInfo)
	EffectUtil.SetSkillDecalState(self.WarningID, self.DecalState)
	self.DirOffset = DirOffset--记录方向偏移，用于拖拽后偏移叠加

	self.bSuccess = true
	--Debug
	--_G.UE.UKismetSystemLibrary.DrawDebugCircle(FWORLD(), Major:FGetActorLocation(), self.MaxCastDistance, 60, _G.UE.FLinearColor(1, 0, 0, 1), 2, 4)
	--_G.UE.UCommonUtil.DrawCircle(Major:FGetActorLocation(), self.MaxCastDistance)
end

function SecondJoyStickView:OnJoyStickMove(MousePosition)
	if self.bSuccess == false then
		return
	end
	local SelfGeometry = _G.UE.UWidgetLayoutLibrary.GetViewportWidgetGeometry(self)
	local CurMousePosition = _G.UE.USlateBlueprintLibrary.AbsoluteToLocal(SelfGeometry, MousePosition)

	local DistSquared = _G.UE.FVector2D.DistSquared(CurMousePosition, self.WidgetCenter)
	local Percent = 1	--拖拽距离百分比，1为最大距离
	if DistSquared < self.RadiusSquared then
		Percent = DistSquared / self.RadiusSquared
	end
	local PointDist = (self.MaxCastDistance - self.MinCastDistance) * Percent + self.MinCastDistance

	--计算输入偏移角度
	local NormalDirVec = _G.UE.FVector2D(0, 1)
	local LocalDir = CurMousePosition - self.WidgetCenter
	_G.UE.FVector2D.Normalize(LocalDir)
	local Angle = GetAngle(NormalDirVec, LocalDir)

	--指示器不超过外层圈范围
	if Percent < 1 then
		UIUtil.CanvasSlotSetPosition(self.ValidImageTouch, (CurMousePosition - self.WidgetCenter) / self.RenderTransformScale)
	else
		UIUtil.CanvasSlotSetPosition(self.ValidImageTouch, self.RadiusXY * LocalDir / self.RenderTransformScale)
	end

	local Major = MajorUtil.GetMajor()
	local MajorPosition = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	local CameraRotation = Major:GetCameraBoomRelativeRotation()
	--贴花朝向应始终以摄像机空间为准
	self.AbsoluteAngle = Angle + CameraRotation.Yaw
	local TotalAngle = Angle + CameraRotation.Yaw + self.DirOffset
	local Rotation = _G.UE.FRotator(0, TotalAngle, 0)
	if self.bEnableJoyStickPoint == 1 then
		local PointNormalVec = _G.UE.FVector(KML.DegCos(TotalAngle), KML.DegSin(TotalAngle), 0) --拖拽产生的单位向量
		self.AbsolutePosition = MajorPosition + PointNormalVec * PointDist
	else
		self.AbsolutePosition = MajorPosition + Rotation:RotateVector(self.Offset) --贴花中心点不变，但应考虑主角位置变化与贴花自身偏移信息
	end

	self.DistVector = self.AbsolutePosition - MajorPosition

	if self.bEnableJoyStickPoint == 1 then
		local bValidDecalPosition, FloorPosition = ValidDecalLocation(MajorPosition, self.AbsolutePosition)
		self.DecalState = bValidDecalPosition
		if bValidDecalPosition == true then
			self.AbsolutePosition = FloorPosition
		end
	end
	EffectUtil.SetSkillDecalState(self.WarningID, self.DecalState and not self.CancelState)
	EffectUtil.SetSkillDecalLocation(self.WarningID, self.AbsolutePosition)
	EffectUtil.SetSkillDecalRotation(self.WarningID, Rotation)
end

return SecondJoyStickView