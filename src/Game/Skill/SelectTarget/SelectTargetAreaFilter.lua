--author : haialexzhou
--brief : 技能选怪目标范围过滤：根据攻击范围类型过滤目标

local ProtoRes = require ("Protocol/ProtoRes")
local SelectTargetBase = require ("Game/Skill/SelectTarget/SelectTargetBase")
local RPNGenerator = require ("Game/Skill/SelectTarget/RPNGenerator")
local CommonUtil = require("Utils/CommonUtil")
local LuaClass = require ("Core/LuaClass")

local SelectTargetAreaFilter = {}

local Rect = LuaClass()

function Rect:Ctor()
	self.X = 0
	self.Y = 0
	self.Width = 0
	self.Height = 0
	self.Min = nil
	self.Max = nil
end

function Rect:Init(X, Y, Z, W, H)
	self.X = X
	self.Y = Y
	self.Width = W
	self.Height = H
	self.Min = _G.UE.FVector(X, Y, Z)
	self.Max = _G.UE.FVector(X + H, Y + W, Z)
end

function Rect:Contains(TargetPos)
	if (TargetPos.X >= self.Min.X and TargetPos.X < self.Max.X
		and TargetPos.Y >= self.Min.Y and TargetPos.Y < self.Max.Y) then
		return true
	end

	return false
end

--绘制矩形区域
function Rect:DrawSelf(ActionPos, Angle)
	if (self.Width > 0 and self.Height > 0 and self.Min ~= nil and self.Max ~= nil) then
		local Pos1 = self.Min
		local Pos2 = self.Min + _G.UE.FVector(self.Height, 0, 0)
		local Pos3 = self.Max
		local Pos4 = self.Max - _G.UE.FVector(self.Height, 0, 0)
		--朝X轴正方向的矩形
		--  _G.UE.UCommonUtil.DrawLine(Pos1, Pos2)
		--  _G.UE.UCommonUtil.DrawLine(Pos2, Pos3)
		--  _G.UE.UCommonUtil.DrawLine(Pos3, Pos4)
		--  _G.UE.UCommonUtil.DrawLine(Pos4, Pos1)

		--面向角色前方的矩形
		local Pos11 = _G.UE.UCommonUtil.RotatePoint(ActionPos, Angle, Pos1)
		local Pos22 = _G.UE.UCommonUtil.RotatePoint(ActionPos, Angle, Pos2)
		local Pos33 = _G.UE.UCommonUtil.RotatePoint(ActionPos, Angle, Pos3)
		local Pos44 = _G.UE.UCommonUtil.RotatePoint(ActionPos, Angle, Pos4)
		_G.UE.UCommonUtil.DrawLine(Pos11, Pos22)
		_G.UE.UCommonUtil.DrawLine(Pos22, Pos33)
		_G.UE.UCommonUtil.DrawLine(Pos33, Pos44)
		_G.UE.UCommonUtil.DrawLine(Pos44, Pos11)
	end
end

--朝向角度
function SelectTargetAreaFilter:GetSelectedDirAngle(ResSkillArea, Executor)
	if SelectTargetBase.SelectedDirAngle == -1 then	--SelectTargetBase的重置、初始化都是-1
		if (ResSkillArea.PointType == ProtoRes.skill_point_type.SKILL_POINT_SELECT_POS) then
			local DirAngle = SelectTargetBase:GetDirAngle()
			if (DirAngle == nil) then
				local Rotator = Executor:K2_GetActorRotation()
				DirAngle = Rotator.Yaw
			end

			SelectTargetBase.SelectedDirAngle = DirAngle
		else
			local Rotator = Executor:K2_GetActorRotation()
			SelectTargetBase.SelectedDirAngle = Rotator.Yaw
		end
	end

	return SelectTargetBase.SelectedDirAngle
end

--朝向向量
local function GetSelectedDirVector(ResSkillArea, Executor)
	if (ResSkillArea.PointType == ProtoRes.skill_point_type.SKILL_POINT_SELECT_POS) then
		local DirAngle = SelectTargetBase:GetDirAngle()
		local Rotator = _G.UE.FRotator(0, DirAngle, 0)
		return Rotator:GetForwardVector()
	else
		local Rotator = Executor:K2_GetActorRotation()
		return Rotator:GetForwardVector()
	end
	
end

-- 获取技能作用点
-- 注意：Target有可能会是nil，如果是nil, Target变更为Executor
-- 记得给SelectTargetBase.SkillActionPos赋值
local function GetActionPosition(ResSkillArea, Executor, Target, bCalcOffset, TargetPos)
	if not Target then
		-- SelectTargetMgr:GetSkillActors()中使用； 从c++初筛actors
		Target = Executor
	end

	local AreaID = ResSkillArea.ID
	local PointType = ResSkillArea.PointType
	SelectTargetBase.ActionPosMap[AreaID] = SelectTargetBase.ActionPosMap[AreaID] or {}

	local AreaActionPosMap = SelectTargetBase.ActionPosMap[AreaID]
	local bSetSkillActionPos = false
	local ActionPos = AreaActionPosMap[PointType]

	if (PointType == ProtoRes.skill_point_type.SKILL_POINT_SELECT_POS) then				--缓存    这种直接return的 单独拎出来处理
		-- 选点坐标，双摇杆手搓技能
		if ActionPos == nil then
			ActionPos = SelectTargetBase:GetSelectedPos()
			--如果作用点类型是选点坐标，但是选中点参数是空的，默认都在伤害范围内，不走伤害范围判断逻辑，只比较技能条件表里的距离判断
			if (ActionPos == nil) then
				ActionPos = TargetPos or Target:FGetLocation(_G.UE.EXLocationType.ServerLoc)
			end
	
			AreaActionPosMap[PointType] = ActionPos
		end

		SelectTargetBase.SkillActionPos = ActionPos
		return ActionPos
	elseif ActionPos == nil then	--需要缓存的第一次是nil，不需要缓存的一直是nil
		if (PointType == ProtoRes.skill_point_type.SKILL_POINT_SELF) then					--缓存
			ActionPos = Executor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
			AreaActionPosMap[PointType] = ActionPos	
		elseif (PointType == ProtoRes.skill_point_type.SKILL_POINT_SELECT_TARGET) then		--有选中目标后才缓存，第一次hit的时候如果没选中目标是不缓存的
			-- 当前选中的目标
			local CurrSelectedTarget = SelectTargetBase.SelectedTarget --:GetCurrSelectedTarget()
			if CurrSelectedTarget then
				ActionPos = CurrSelectedTarget:FGetLocation(_G.UE.EXLocationType.ServerLoc)
				AreaActionPosMap[PointType] = ActionPos
	
				SelectTargetBase.IsSelectTargetHit = true
				--选择的目标必然会当做for循环中的1个，进入到这里
				-- bSetSkillActionPos = true
				-- if CurrSelectedTarget == Target then
				-- 	SelectTargetBase.SkillActionPos = Executor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
				-- end
			else
				ActionPos = TargetPos or Target:FGetLocation(_G.UE.EXLocationType.ServerLoc)
				--同SKILL_POINT_TARGET类型的处理
				bSetSkillActionPos = true
				SelectTargetBase.SkillActionPos = Executor:FGetLocation(_G.UE.EXLocationType.ServerLoc)	
			end
		elseif (PointType == ProtoRes.skill_point_type.SKILL_POINT_TARGET) then				--不需要缓存
			-- 获取Target自身坐标
			ActionPos = TargetPos or Target:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	
			bSetSkillActionPos = true
			SelectTargetBase.SkillActionPos = ActionPos--Executor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
		-- elseif (PointType == ProtoRes.skill_point_type.SKILL_POINT_SELECT) then --没有这个类型
		elseif (PointType == ProtoRes.skill_point_type.SKILL_POINT_BASE) then
			--todo 获取原点坐标
		end
	end


	if (bCalcOffset) then
		--以施法者朝向的坐标系，计算偏移
		local RelativeOffset = SelectTargetBase.RelativeOffsetMap[ResSkillArea.ID]
		if RelativeOffset == nil then
			local _ <close> = CommonUtil.MakeProfileTag("CalcOffset")
			-- local Rotator = Executor:K2_GetActorRotation()
			-- local FinalRotor = Rotator + _G.UE.FRotator(0, ResSkillArea.DirOffset - 90, 0)
			-- local Offset = _G.UE.FVector(ResSkillArea.VOffset, ResSkillArea.HOffset, 0)	--导表的时候Y是HOffset，所以这样颠倒
			-- RelativeOffset = FinalRotor:RotateVector(Offset)

			RelativeOffset = _G.UE.USelectEffectMgr:Get():GetRelativeOffset(Executor
			    , ResSkillArea.DirOffset - 90, ResSkillArea.VOffset, ResSkillArea.HOffset)

			SelectTargetBase.RelativeOffsetMap[ResSkillArea.ID] = RelativeOffset
		end

		ActionPos = ActionPos + RelativeOffset

		-- local Rotator = Executor:K2_GetActorRotation()
		-- local ExecutorForward = Rotator:GetForwardVector() --释放技能时玩家的朝向
		-- ActionPos = ActionPos + ExecutorForward * _G.UE.FVector(ResSkillArea.VOffset, ResSkillArea.HOffset, 0)
	end
	
	if not bSetSkillActionPos then
		SelectTargetBase.SkillActionPos = ActionPos
	end

	return ActionPos or _G.UE.FVector()
end

local function TargetIsInSingleArea(ResSkillArea, Executor, Target)
	--作用点是目标位置的单体攻击，这里永远满足条件
	if (ResSkillArea.PointType == ProtoRes.skill_point_type.SKILL_POINT_TARGET) then
		return true
	end

	local AttackDistance = tonumber(ResSkillArea.AreaParamStr)
	if (not AttackDistance) then
		return false
	end

	AttackDistance = AttackDistance + SelectTargetBase:GetFaultTolerantRangeInArea(ResSkillArea)
	local ActionPos = GetActionPosition(ResSkillArea, Executor, Target, true)
	--pcw
	-- local TargetPos = Target:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	-- --todo 作用点跟目标的距离
	-- local ExecutorRadius = SelectTargetBase:GetTargetRadius(Executor)
	-- local TargetRadius = SelectTargetBase:GetTargetRadius(Target)
	-- local Distance = SelectTargetBase:GetDistance(ActionPos, TargetPos, ExecutorRadius, TargetRadius)
	local Distance = _G.UE.USelectEffectMgr:Get():GetDistByPos(Executor, Target, SelectTargetBase.MaxZDiff, ActionPos)
	
	--绘制单点攻击范围
	if (_G.GMMgr:IsShowDebugTips()) then
		_G.UE.UCommonUtil.DrawCircle(ActionPos, AttackDistance)
	end

	if (Distance <= AttackDistance) then
		return true
	end
end

local function GetCasterRadius(Executor)
	return SelectTargetBase.CasterRadius
	--pcw
	-- local Radius = 0
	-- if Executor then
	-- 	local AvatarComponent = Executor:GetAvatarComponent()
	-- 	if AvatarComponent then
	-- 		Radius = AvatarComponent:GetRadius() * 100 * Executor:GetModelScale()
	-- 	end
	-- end
	-- return tonumber(Radius)
end

local function TargetIsInCFRArea(ResSkillArea, Executor, Target)
	local AreaID = ResSkillArea.ID
	local ParamArray = SelectTargetAreaFilter.AreaParamArrayMap[AreaID]
	if ParamArray == nil then
		local AreaParamArray = _G.StringTools.StringSplit(ResSkillArea.AreaParamStr, ",")
		--外半径，内半径，角度
		if (#AreaParamArray ~= 3) then
			SelectTargetAreaFilter.AreaParamArrayMap[AreaID] = {}
			return false
		end
		local OuterR = tonumber(AreaParamArray[1])
		local innerR = tonumber(AreaParamArray[2])
		local Angle = tonumber(AreaParamArray[3])

		ParamArray = {OuterR, innerR, Angle}
		SelectTargetAreaFilter.AreaParamArrayMap[AreaID] = ParamArray
	end
	
	--外半径，内半径，角度
	if (#ParamArray ~= 3) then
		return false
	end
	
	local innerR = ParamArray[2]
	local FaultTolerantRangeInAre = SelectTargetBase:GetFaultTolerantRangeInArea(ResSkillArea)
	innerR = innerR - FaultTolerantRangeInAre
	local OuterR = ParamArray[1]
	OuterR = OuterR + FaultTolerantRangeInAre
	local Angle = ParamArray[3]

	--pcw
	local TargetPos = Target:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	local ActionPos = GetActionPosition(ResSkillArea, Executor, Target, true, TargetPos)
	-- --todo 作用点跟目标的距离
	-- local ExecutorRadius = SelectTargetBase:GetTargetRadius(Executor)
	-- local TargetRadius = SelectTargetBase:GetTargetRadius(Target)
	-- local Distance = SelectTargetBase:GetDistance(ActionPos, TargetPos, ExecutorRadius, TargetRadius)
	local Distance = _G.UE.USelectEffectMgr:Get():GetDistByPos(Executor, Target, SelectTargetBase.MaxZDiff, ActionPos)

	local IsInAttackRange = false

	--考虑施法者半径
	local CasterRadius = 0
	if ResSkillArea.CasterRadius ~= 0 then
		CasterRadius = GetCasterRadius(Executor)
	end
	OuterR = OuterR + CasterRadius
	if(innerR > 0) then
		innerR = innerR + CasterRadius

	end
	if (OuterR > 0 and innerR > 0 and innerR < OuterR) then
		IsInAttackRange = (Distance >= innerR and Distance <= OuterR)
	elseif (OuterR > 0 and innerR == 0) then
	    IsInAttackRange = (Distance <= OuterR)
	elseif (OuterR == 0 and innerR > 0) then
	    IsInAttackRange = (Distance <= innerR)
	end


	--绘圆环扇范围
	if (_G.GMMgr:IsShowDebugTips()) then
		if (Angle % 360 ~= 0) then
			local SkillDir = GetSelectedDirVector(ResSkillArea, Executor) --释放技能时玩家的朝向
			if ResSkillArea.DirOffset ~= 0 then
				SkillDir = SkillDir:RotateAngleAxis(ResSkillArea.DirOffset, _G.UE.FVector(0, 0, 1))
			end
			local FarPos = ActionPos + SkillDir * (OuterR > 0 and OuterR or innerR)
			local LeftEdgeFarPos = _G.UE.UCommonUtil.RotatePoint(ActionPos, -(Angle * 0.5), FarPos)
			local RightEdgeFarPos = _G.UE.UCommonUtil.RotatePoint(ActionPos, (Angle * 0.5), FarPos)
			_G.UE.UCommonUtil.DrawLine(ActionPos, LeftEdgeFarPos)
			_G.UE.UCommonUtil.DrawLine(ActionPos, RightEdgeFarPos)
		end

		local Rotator = Executor:K2_GetActorRotation()
		local FinalRotor = Rotator + _G.UE.FRotator(0, ResSkillArea.DirOffset, 0)
		if (innerR > 0) then
			_G.UE.UCommonUtil.DrawCircle(ActionPos, innerR, 300, Angle, FinalRotor)
		end

		if (OuterR > 0) then
			_G.UE.UCommonUtil.DrawCircle(ActionPos, OuterR, 300, Angle, FinalRotor)
		end
	end

	--在圆环内
	if (IsInAttackRange) then
		if (Angle % 360 == 0) then
			IsInAttackRange = true
		else
			--pcw
			IsInAttackRange = _G.UE.USelectEffectMgr:Get():IsInAngleRange(Executor, ActionPos, TargetPos
				, Angle, ResSkillArea.PointType, SelectTargetBase:GetDirAngle(), ResSkillArea.DirOffset)
			-- local SkillDir = GetSelectedDirVector(ResSkillArea, Executor) --释放技能时玩家的朝向

			-- if ResSkillArea.DirOffset ~= 0 then
			-- 	SkillDir = SkillDir:RotateAngleAxis(ResSkillArea.DirOffset, _G.UE.FVector(0, 0, 1))
			-- end

			-- local WithTargetDir = TargetPos - ActionPos
			-- local CosValue2D = SkillDir:CosineAngle2D(WithTargetDir)
			-- local AngleForTarget = SelectTargetBase:DegAcos(CosValue2D)
			-- --print("CosValue2D=" .. CosValue2D .. " AngleForTarget=" .. AngleForTarget .. " SkillDir=" .. tostring(SkillDir) .. " WithTargetDir=" .. tostring(WithTargetDir))
			-- --判断作用点的方向跟目标的方向向量夹角是否小于扇形角度的二分之一
			-- if (AngleForTarget <= (Angle * 0.5)) then
			-- 	IsInAttackRange = true
			-- else
			-- 	IsInAttackRange = false
			-- end
		end
	end

	return IsInAttackRange
end

--矩形和圆是否相交(目标体积比较大的情况）
--selectPos: 选中点，矩形中心
--CircleCenterPos: 目标坐标
--Radius:目标半径
local function CircleRectangleIsIntersect(RectObj, RectCenterPos, CircleCenterPos, Radius)
	if (Radius == 0) then
		return false
	end

	local DistanceSquared = RectCenterPos:DistSquared2D(CircleCenterPos)
	local OutCircleR = (RectObj.Min:Dist2D(RectObj.Max)) / 2
	local CircleAdd = OutCircleR + Radius
	--距离大于矩形外接圆和圆半径，不可能相交
	if (DistanceSquared > (CircleAdd * CircleAdd)) then
		return false
	end
	--计算圆心与矩形的最短距离u，若u的长度小于r则两者相交。
	--矩形中心和圆心的向量(转换至第1象限)
	local TwoCenterVector = _G.UE.FVector(math.abs(CircleCenterPos.X - RectCenterPos.X), math.abs(CircleCenterPos.Y - RectCenterPos.Y), 0)
	--计算矩形中心和右顶点的向量
	local CenterTopRightVector = _G.UE.FVector(RectObj.Height / 2, RectObj.Width / 2, 0)
	--计算圆心至矩形的最短距离向量，如果向量在x分量为负数则不考虑x分量，直接设为0，y分量也一样
	local CenterMinDisVector = _G.UE.FVector(math.max((TwoCenterVector.X - CenterTopRightVector.X), 0), math.max((TwoCenterVector.Y - CenterTopRightVector.Y), 0), 0)
	--计算向量的长度是否小于 r
	local RadiusSquared = Radius * Radius
	if (CenterMinDisVector:SizeSquared() <= RadiusSquared) then
		return true
	end

	return false
end

local function TargetIsInRectangleArea(ResSkillArea, Executor, Target)
	local AreaID = ResSkillArea.ID
	local ParamArray = SelectTargetAreaFilter.AreaParamArrayMap[AreaID]
	if ParamArray == nil then
		local AreaParamArray = _G.StringTools.StringSplit(ResSkillArea.AreaParamStr, ",")
		--宽，高
		if (#AreaParamArray ~= 2) then
			SelectTargetAreaFilter.AreaParamArrayMap[AreaID] = {}
			return false
		end

		local Width = tonumber(AreaParamArray[1]) --矩形宽度
		local Height = tonumber(AreaParamArray[2]) --矩形高度
		
		ParamArray = {Width, Height}
		SelectTargetAreaFilter.AreaParamArrayMap[AreaID] = ParamArray
	end

	--宽，高
	if (#ParamArray ~= 2) then
		return false
	end
	local Width = ParamArray[1] --矩形宽度
	local FaultTolerantRangeInAre = SelectTargetBase:GetFaultTolerantRangeInArea(ResSkillArea)
	Width = Width + FaultTolerantRangeInAre
	local Height = ParamArray[2] --矩形高度
	Height = Height + FaultTolerantRangeInAre

	--作用点(偏移之前)
	local TargetPos = Target:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	local ActionPos = GetActionPosition(ResSkillArea, Executor, Target, false, TargetPos)
	local OffsetValue = _G.UE.FVector(ResSkillArea.HOffset, ResSkillArea.VOffset, 0)
	--print("GetActionPosition Width=" .. Width .. "; Height=" .. Height .. "; OffsetValue=" .. tostring(OffsetValue))
	--考虑施法者半径	--pcw
	local CasterRadius = 0
	if ResSkillArea.CasterRadius ~= 0 then
		CasterRadius = GetCasterRadius(Executor)
	end

	Height = Height + CasterRadius

	--矩形的中心
	local RectCenterPos = ActionPos + OffsetValue + _G.UE.FVector(CasterRadius / 2, 0, 0)
	local RectBottomCenterPos = _G.UE.FVector(RectCenterPos.X - Height/2, RectCenterPos.Y, RectCenterPos.Z)
	
	--释放者朝向
	local DirAngle = SelectTargetAreaFilter:GetSelectedDirAngle(ResSkillArea, Executor)	--pcw
	local ExecutorAngle = DirAngle + ResSkillArea.DirOffset
	
	--根据作用点，创建矩形
	local RectObj = SelectTargetAreaFilter.RectObj
	--玩家Z角度为0时，面向X轴
	RectObj:Init(RectBottomCenterPos.X, RectBottomCenterPos.Y - Width/2, RectCenterPos.Z, Width, Height)

	--绘制矩形范围
	if (_G.GMMgr:IsShowDebugTips()) then
		RectObj:DrawSelf(ActionPos, ExecutorAngle)
	end

	--目标的胶囊体半径
	local TargetRadius = SelectTargetBase:GetTargetRadius(Target)
	--print("ActionPos: " .. tostring(ActionPos) .. " TargetPos: " .. tostring(TargetPos) .. " ExecutorAngle: " .. tostring(-ExecutorAngle))
	
	--把目标旋转到Rect坐标系,必须使用偏移之前的作用点旋转
	local NewTargetPos = _G.UE.UCommonUtil.RotatePoint(ActionPos, -ExecutorAngle, TargetPos)
	--矩形底部中点到对角线距离
	local MaxDistance = RectBottomCenterPos:Dist2D(RectObj.Max)
	local Distance = SelectTargetBase:GetDistance(RectBottomCenterPos, NewTargetPos, 0, TargetRadius)
	--超过了矩形对角线长度
	if (Distance > MaxDistance) then
		return false
	end

	if (_G.GMMgr:IsShowDebugTips()) then
		_G.UE.UCommonUtil.DrawLine(ActionPos, TargetPos)
	end
	
	if (TargetRadius == 0) then
		--点
		if (RectObj:Contains(NewTargetPos)) then
			return true
		end
	else
		if (_G.GMMgr:IsShowDebugTips()) then
			_G.UE.UCommonUtil.DrawCircle(TargetPos, TargetRadius)
		end
		--矩形中心跟圆心的距离
		Distance = SelectTargetBase:GetDistance(RectCenterPos, NewTargetPos, 0, TargetRadius)
		if (Distance < TargetRadius) then
			return true
		end

		--圆
		if (CircleRectangleIsIntersect(RectObj, RectCenterPos, NewTargetPos, TargetRadius)) then
			return true
		end
	end

	return false
end

--暂未实现
local function TargetIsInBulletArea(ResSkillArea, Executor, Target)

end

--暂未实现
local function TargetIsInSceneArea(ResSkillArea, Executor, Target)

end

--扩展新类型的时候，如果像TargetIsInRectangleArea那样，GetSkillActionPos特殊的话，也同步修改下
--SelectTargetAreaFilter:GetSkillActionPos
local function TargetIsInArea(Executor, Target, AreaID)
	local ResSkillArea = SelectTargetBase:GetResSkillArea(AreaID)
	if (ResSkillArea == nil) then
		return false
	end

	--单体
	if (ResSkillArea.AreaType == ProtoRes.skill_area_type.SKILL_AREA_SINGLE) then
		return TargetIsInSingleArea(ResSkillArea, Executor, Target)
	--圆扇环
	elseif (ResSkillArea.AreaType == ProtoRes.skill_area_type.SKILL_AREA_CFR) then
		return TargetIsInCFRArea(ResSkillArea, Executor, Target)
	--矩形
	elseif (ResSkillArea.AreaType == ProtoRes.skill_area_type.SKILL_AREA_RECTANGLE) then
		return TargetIsInRectangleArea(ResSkillArea, Executor, Target)
	--子弹
	elseif (ResSkillArea.AreaType == ProtoRes.skill_area_type.SKILL_AREA_BULLET) then
		return TargetIsInBulletArea(ResSkillArea, Executor, Target)
	--场景区域
	elseif (ResSkillArea.AreaType == ProtoRes.skill_area_type.SKILL_AREA_SCENE) then
		return TargetIsInSceneArea(ResSkillArea, Executor, Target)
	end
	return false
end

function SelectTargetAreaFilter:Construct()
	self.AreaParamArrayMap = {}
	self.RectObj = Rect.New()
end

--目标是否在技能范围内
function SelectTargetAreaFilter:TargetIsInArea(Executor, Target, AreaExpressionStr)
	if Executor == Target then
		return true
	end

	if not AreaExpressionStr then
		AreaExpressionStr = SelectTargetBase:GetSkillHitAreaStr()
	end

	local IsInArea = RPNGenerator:ExecuteRPNBoolExpression(AreaExpressionStr, Executor, Target, TargetIsInArea)
	return IsInArea
end

-- 获取施法位置
-- SelectTargetMgr:GetSkillActors()中使用； 从c++初筛actors
function SelectTargetAreaFilter:GetSkillActionPos(ResSkillArea, Executor)
	--如果ResSkillArea.AreaType扩展新类型，有如同矩形那样比较特殊的话，这里也补充下
	if ResSkillArea.AreaType == ProtoRes.skill_area_type.SKILL_AREA_RECTANGLE then
		local ActionPos = GetActionPosition(ResSkillArea, Executor, nil, false)
		return ActionPos + _G.UE.FVector(ResSkillArea.HOffset, ResSkillArea.VOffset, 0)
	end

	return GetActionPosition(ResSkillArea, Executor, nil, true)
end

return SelectTargetAreaFilter