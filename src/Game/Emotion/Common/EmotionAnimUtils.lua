--[[
Date: 2022-11-17 10:20:23
LastEditors: moody
LastEditTime: 2022-11-17 10:20:23
--]]
local ActorUtil = require("Utils/ActorUtil")
local EmotionCfg = require("TableCfg/EmotionCfg")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local AnimationUtil = require("Utils/AnimationUtil")
local AnimMgr = require("Game/Anim/AnimMgr")
local EActorType = _G.UE.EActorType

local EmotionAnimUtils = {}

function EmotionAnimUtils.GetEmotionAnimPathByRace(EmotionName, RaceName, AnimType, FaceName)
	FaceName = FaceName or ""

	--[[-------- 原方案线 ----------
	local AnimPath = string.format("AnimSequence'/Game/Assets/Character/Human/Animation/%s/a0001/%s/A_%sa0001%s_%s-%s.A_%sa0001%s_%s-%s'",
	 RaceName, AnimType, RaceName, FaceName, AnimType, EmotionName, RaceName, FaceName, AnimType, EmotionName)
	]]

	local EmotionNameLast = EmotionAnimUtils.GetStringLast(EmotionName, "/")

	if string.find(EmotionName, "bed") then   --bed睡觉动作
		local AnimPath = string.format("AnimSequence'/Game/Assets/Character/Action/%s.%s'", EmotionName, EmotionNameLast)
		return AnimPath
	end

	if FaceName ~= "" then   --表情动作
		local AnimPath = string.format("AnimSequence'/Game/Assets/Character/Action/%s.%s'", EmotionName, EmotionNameLast)
		return AnimPath
	end

	if string.find(EmotionName, "pose") then   --pose姿势动作
		local AnimPath = string.format("AnimSequence'/Game/Assets/Character/Human/Animation/%s/a0001/%s/timeline/base/b0001/%s.%s'",
			RaceName, AnimType, EmotionNameLast, EmotionNameLast)
		return AnimPath
	end

	if string.find(EmotionName, "_ajust_") then   --高度调整(下蹲、踮脚)
		local AnimPath = string.format("AnimSequence'/Game/Assets/Character/Human/Animation/%s/a0001/%s/timeline/base/b0001/%s.%s'",
			RaceName, AnimType, EmotionNameLast, EmotionNameLast)
		return AnimPath
	end

	if string.find(EmotionName, "dance01_start") or string.find(EmotionName, "dance_lalafell_start") then
		--屏蔽3600帧的空动作,针对dance01~19动作实际为2分钟Tpose做屏蔽
		return ""
	end

	if string.find(EmotionName, "emote_ajust") then	--改emote_ajust文件夹到emote
		EmotionName = string.gsub(EmotionName, "_ajust", "")
	end

	local AnimPath = string.format("AnimSequence'/Game/Assets/Character/Action/%s.%s'", EmotionName, EmotionNameLast)
	return AnimPath
end

--- 根据ID获取动作的地址（ActionTimeLine）
function EmotionAnimUtils.GetEmotionAtlPath(ID, AnimPathType)
	local EmotionData = EmotionCfg:FindCfgByKey(ID)
	if nil == EmotionData then return end
	local AnimNameCfg = AnimPathType and EmotionData[AnimPathType] or EmotionData.AnimPath
	local AnimPath = AnimMgr:GetActionTimeLinePath(AnimNameCfg)
	return AnimPath
end

--- 截取最后一次出现指定字符的后面部分
function EmotionAnimUtils.GetStringLast(S,Delimiter)
	local Last = string.find(string.reverse(S), Delimiter)
	if not Last then
		return S
	end
	Last = #S - Last + 2
	return string.sub(S, Last)
end

-- 返回空时代表不存在 返回非空时已经确认过资源存在了
function EmotionAnimUtils.GetEmotionPathByRace(FromActor, EmotionName, RaceName, AnimType, FaceName)
	if not FromActor then
		return ""
	end
	-- local AnimPath = ""
	-- if AnimComp then
	-- 	AnimPath = AnimComp:GetDefaultTimeline(EmotionName)
	-- end
	local SoftPath = _G.UE.FSoftObjectPath()
	local AnimPath = EmotionAnimUtils.GetEmotionAnimPathByRace(EmotionName, RaceName, AnimType, FaceName) or ""
	SoftPath:SetPath(AnimPath)

	if _G.UE.UCommonUtil.IsObjectExist(SoftPath) then
		return AnimPath
	end

	return ""
end

-- 返回空时代表不存在 返回非空时已经确认过资源存在了
function EmotionAnimUtils.GetEmotionAnimPath(EmotionName, FromID, AnimType, FaceName)
	if string.isnilorempty(EmotionName) then
		return ""
	end

	local Actor = ActorUtil.GetActorByEntityID(FromID)
	return EmotionAnimUtils.GetEmotionAnimPathByActor(EmotionName, Actor, AnimType, FaceName)
end

function EmotionAnimUtils.GetEmotionAnimPathByActor(EmotionName, Actor, AnimType, FaceName)
	if string.isnilorempty(EmotionName) then
		return ""
	end

	if Actor and Actor:GetAvatarComponent() and Actor:GetAttributeComponent() then
		return EmotionAnimUtils.GetActorEmotionAnimPath(EmotionName, Actor, AnimType, FaceName)
	end

	return ""
end

-- 返回空时代表不存在 返回非空时已经确认过资源存在了
function EmotionAnimUtils.GetActorEmotionAnimPath(EmotionName, Actor, AnimType, FaceName)
	if string.isnilorempty(EmotionName) then
		return ""
	end

	if Actor and Actor:GetAvatarComponent() and Actor:GetAttributeComponent() then
		local AvatarComp = Actor:GetAvatarComponent()
		local AttributeComp = Actor:GetAttributeComponent()
		local RaceName = AvatarComp:GetAttachType()
		local Gender = AttributeComp.Gender

		--c1201 无时，优先调用 c1101（拉拉肥男女）
		--其他男没有时，优先调用 c0101，其他女没有时，优先调用 c0801，再没有就调用 c0101
		local AnimPath = EmotionAnimUtils.GetEmotionPathByRace(Actor, EmotionName, RaceName, AnimType, FaceName)
		if #AnimPath ~= 0 then
			return AnimPath
		end

		if RaceName == 'c1201' then
			AnimPath = EmotionAnimUtils.GetEmotionPathByRace(Actor, EmotionName, "c1101", AnimType, FaceName)
			if #AnimPath ~= 0 then
				return AnimPath
			end
		end
		if Gender ~= 1 then
			AnimPath = EmotionAnimUtils.GetEmotionPathByRace(Actor, EmotionName, "c0801", AnimType, FaceName)
			if #AnimPath ~= 0 then
				return AnimPath
			end
		end
		return EmotionAnimUtils.GetEmotionPathByRace(Actor, EmotionName, "c0101", AnimType, FaceName)
	end
	return ""
end

function EmotionAnimUtils.AddAnimPathIfExist(FromID, Emotion, AnimKeyName, AnimResParam, AnimParamName, AnimType, FaceName)
	if nil == Emotion then
		return
	end
	local RawAnimPath = Emotion[AnimKeyName]
	if not string.isnilorempty(RawAnimPath) then
		local AnimPath = EmotionAnimUtils.GetEmotionAnimPath(RawAnimPath, FromID, AnimType, FaceName)
		if not string.isnilorempty(AnimPath) then
			AnimResParam[AnimParamName .. "Raw"] = RawAnimPath
			AnimResParam[AnimParamName] = AnimPath
		end
	end
end

function EmotionAnimUtils.IsAnimExist(FromID, Emotion, AnimKeyName, AnimType, FaceName)
	local RawAnimPath = Emotion[AnimKeyName]
	if not string.isnilorempty(RawAnimPath) then
		local AnimPath = EmotionAnimUtils.GetEmotionAnimPath(RawAnimPath, FromID, AnimType, FaceName)
		if not string.isnilorempty(AnimPath) then
			return true
		end
	end
	return false
end

---是持续循环动作、改变姿势Id=90（情感动作表：2）
function EmotionAnimUtils.IsLoopAnim(MotionType)
	return MotionType == 2 or MotionType == 3
end

---是表情动作（情感动作表：动作分类列，MotionType = 0）
function EmotionAnimUtils.IsFaceAnim(MotionType)
	return MotionType == 0
end

---是一般动作（情感动作表：MotionType = 1）
function EmotionAnimUtils.IsOnceAnim(MotionType)
	return MotionType == 1
end

local State2SlotName =
{
	["add_"] = EmotionDefines.SlotNames.Head,
	["u_"] = EmotionDefines.SlotNames.UpperBody,
	["j_"] = EmotionDefines.SlotNames.WholeBody,
	["s_"] = EmotionDefines.SlotNames.WholeBody,
}

-- 根据动画名前缀得到用于播放的Slot
function EmotionAnimUtils.GetSlotName(AnimPathRaw)
	if AnimPathRaw ~= nil then
		for Prefix, Value in pairs(State2SlotName) do
			if string.find(AnimPathRaw, Prefix) then
				return Value
			end
		end
	end
	return EmotionDefines.SlotNames.WholeBody
end

--- 获取Idle闲置姿势Pose的名字
function EmotionAnimUtils.GetPlayerIdleAnimPath(IdleType, Actor, IdleAnimType, AnimStage)
	-- stage == 1 -> loop anim
	if nil == Actor then
		return ""
	end
	local AnimName = ""
	if IdleType == _G.UE.EPlayerIdleType.NORMAL then
		if AnimStage == 1 then
			AnimName = "cbem_pose%02d_2lp"
		else
			AnimName = "cbem_pose%02d_1"
		end
	elseif IdleType == _G.UE.EPlayerIdleType.SIT_GROUND then
		if AnimStage == 1 then
			AnimName = "cbem_j_pose%02d_2lp"
		else
			AnimName = "cbem_j_pose%02d_1"
		end
	elseif IdleType == _G.UE.EPlayerIdleType.SLEEP then
		-- if AnimStage == 1 then
		-- 	AnimName = "cbem_pose01_2lp"
		-- else
		-- 	AnimName = "cbem_pose01_1"
		-- end
	elseif IdleType == _G.UE.EPlayerIdleType.SIT_CHAIR then
		if AnimStage == 1 then
			AnimName = "cbem_s_pose%02d_2lp"
		else
			AnimName = "cbem_s_pose%02d_1"
		end
	end

	AnimName = string.format(AnimName, IdleAnimType)

	return EmotionAnimUtils.GetEmotionAnimPathByActor(AnimName, Actor, EmotionDefines.AnimType.EMOT)
end

-- 获取动画资源路径、蒙太奇SlotName等参数
function EmotionAnimUtils.GetEmotionAnimResParam(EmotionTask)
	local AnimResParam = {}
	local CurState = EmotionTask:GetCurState()
	local AnimType = EmotionDefines.AnimType.EMOT

	local Emotion = EmotionCfg:FindCfgByKey(EmotionTask.EmotionID)

	-- Add Begin Anim If Exist
	EmotionAnimUtils.AddAnimPathIfExist(EmotionTask.FromID, Emotion, "BeginAnimPath",
		AnimResParam, "BeginAnimPath", AnimType)

	-- Add State Anim
	if CurState == EmotionDefines.StateDefine.NORMAL then
		EmotionAnimUtils.AddAnimPathIfExist(EmotionTask.FromID, Emotion, "AnimPath",
			AnimResParam, "StateAnimPath", AnimType)
	elseif CurState == EmotionDefines.StateDefine.ADJUST then
		EmotionAnimUtils.AddAnimPathIfExist(EmotionTask.FromID, Emotion, "AdjustAnimPath",
			AnimResParam, "StateAnimPath", AnimType)
	elseif CurState == EmotionDefines.StateDefine.SIT_CHAIR then
		EmotionAnimUtils.AddAnimPathIfExist(EmotionTask.FromID, Emotion, "OnChairAnimPath",
			AnimResParam, "StateAnimPath", AnimType)
	elseif CurState == EmotionDefines.StateDefine.SIT_GROUND then
		EmotionAnimUtils.AddAnimPathIfExist(EmotionTask.FromID, Emotion, "OnGroundAnimPath",
			AnimResParam, "StateAnimPath", AnimType)
	elseif CurState == EmotionDefines.StateDefine.UPPER_BODY then
		EmotionAnimUtils.AddAnimPathIfExist(EmotionTask.FromID, Emotion, "UpperBodyAnimPath",
			AnimResParam, "StateAnimPath", AnimType)
	end

	-- 由 动画名前缀 设置 播放插槽
	AnimResParam.SlotName = EmotionAnimUtils.GetSlotName(AnimResParam.StateAnimPathRaw)

	return AnimResParam
end

-- 自动化测试使用
function EmotionAnimUtils.IsEmotionResExist(EntityID, EmotionID)
	local Emotion = EmotionCfg:FindCfgByKey(EmotionID)
	if Emotion == nil then
		return false
	end

	local MotionType = Emotion.MotionType
	local IsFaceAnim = EmotionAnimUtils.IsFaceAnim(MotionType)
	local AnimType = IsFaceAnim and EmotionDefines.AnimType.FACE or EmotionDefines.AnimType.EMOT
	local FaceName = ""
	if IsFaceAnim then
		local AvatarCom = ActorUtil.GetActorAvatarComponent(EntityID)
		if AvatarCom then
			FaceName = AvatarCom:GetFaceExName()
		end
	end

	local AnimPathNames = { "BeginAnimPath", "AnimPath", "UpperBodyAnimPath", "AdjustAnimPath", "OnChairAnimPath", "OnGroundAnimPath",}
	
	
	for _, AnimPathName in pairs(AnimPathNames) do
		if not string.isnilorempty(Emotion[AnimPathName]) then
			local IsExist = EmotionAnimUtils.IsAnimExist(EntityID, Emotion, AnimPathName,
				AnimType, FaceName)
			if not IsExist then
				print("[Emotion ERR]" .. EmotionID .. " has invalid res.")
				print(AnimPathName .. " " .. Emotion[AnimPathName])
				return false
			end
		end
	end

	return true
end

-- 获取动画资源路径、蒙太奇SlotName等参数
function EmotionAnimUtils.GetFaceEmotionAnimResParam(EmotionTask)
	local AnimResParam = {}
	local AnimType = EmotionDefines.AnimType.FACE

	local Emotion = EmotionCfg:FindCfgByKey(EmotionTask.EmotionID)
	local AvatarCom = ActorUtil.GetActorAvatarComponent(EmotionTask.FromID)
	local FaceName = ""
	if AvatarCom then
		FaceName = AvatarCom:GetFaceExName()
	end
	if #FaceName > 0 then
	--	print("[Emotion] FaceName" .. FaceName)
		EmotionAnimUtils.AddAnimPathIfExist(EmotionTask.FromID, Emotion, "AnimPath",
		AnimResParam, "StateAnimPath", AnimType, FaceName)
	--	print(AnimResParam.StateAnimPath)
	else
		print("[Emotion] FaceName is invalid")
	end

	AnimResParam.SlotName = EmotionDefines.SlotNames.Face

	return AnimResParam
end

function EmotionAnimUtils.Clamp(Value, Min, Max)
	if Value < Min then
		return Min
	elseif Value > Max then
		return Max
	end
	return Value
end

-- 从ClientSetup的值中获取Idle相关参数
function EmotionAnimUtils.CSValueToIdleParams(CSValue)
	local ValueArray = string.split(CSValue, ',')
	local ResultArray = {}
	for _, Type in pairs(EmotionDefines.IdlePoseType) do
		local Value = tonumber(ValueArray[Type])
		if Value == nil then
			Value = EmotionDefines.IdlePoseDefault[Type]
		end
		Value = EmotionAnimUtils.Clamp(Value, 0, EmotionDefines.IdlePoseMax[Type])
		ResultArray[Type] = Value
	end
	return ResultArray
end

-- 使用Idle相关参数生成ClientSetup值
function EmotionAnimUtils.IdleParamsToCSValue(IdleParams)
	local Params = {}
	for _, Type in pairs(EmotionDefines.IdlePoseType) do
		local Param = IdleParams[Type]
		if Param == nil then
			Param = EmotionDefines.IdlePoseDefault[Type]
		end

		Param = EmotionAnimUtils.Clamp(Param, 0, EmotionDefines.IdlePoseMax[Type])
		Params[Type] = Param
	end
	return table.concat(Params, ',')
end

function EmotionAnimUtils.GetPlayerAnimParam(EntityID)
	local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(EntityID)
	if PlayerAnimInst == nil then
		return
	end

	local PlayerAnimParam = PlayerAnimInst:GetPlayerAnimParam()

	if PlayerAnimParam:GetActorType() ~= EActorType.Player then
		return
	end

	return PlayerAnimInst, PlayerAnimParam
end

--- 应用CSValue至对应的动画蓝图上
function EmotionAnimUtils.ApplyIdleCSValue(EntityID, CSValue, ChangePoseImme)
	local PlayerAnimInst, PlayerAnimParam = EmotionAnimUtils.GetPlayerAnimParam(EntityID)

	if PlayerAnimInst == nil or PlayerAnimParam == nil then
		return
	end

	local IdleParams = EmotionAnimUtils.CSValueToIdleParams(CSValue)
	for _, Type in pairs(EmotionDefines.IdlePoseType) do
		local PropName = EmotionDefines.IdlePropertyNames[Type]
		PlayerAnimParam[PropName] = IdleParams[Type]
	end

	PlayerAnimParam.bIgnoreRestTime = ChangePoseImme	--主动发起切换姿势时打印True，放松等待时间自动切换时为false
	PlayerAnimInst:UpdatePlayerAnimParam(PlayerAnimParam)
end

-- 根据当前的Pose类型 自增Pose的ID
function EmotionAnimUtils.ChangePoseByAddOne(EntityID)
	local PlayerAnimInst, PlayerAnimParam = EmotionAnimUtils.GetPlayerAnimParam(EntityID)

	if PlayerAnimInst == nil or PlayerAnimParam == nil then
		return
	end

	local CurIdleType = EmotionAnimUtils.GetCurIdleType(EntityID)
	if CurIdleType == 0 then
		return
	end
	local CurIdlePoseMax = EmotionDefines.IdlePoseMax[CurIdleType]
	local CurPropName = EmotionDefines.IdlePropertyNames[CurIdleType]
	PlayerAnimParam[CurPropName] = (PlayerAnimParam[CurPropName] + 1) % (CurIdlePoseMax + 1)

	PlayerAnimInst:UpdatePlayerAnimParam(PlayerAnimParam)
end

-- 使用指定角色的AnimInstance获取Idle相关的CS值
function EmotionAnimUtils.GetIdleCSValue(EntityID)
	local PlayerAnimInst, PlayerAnimParam = EmotionAnimUtils.GetPlayerAnimParam(EntityID)

	if PlayerAnimInst == nil or PlayerAnimParam == nil then
		return
	end

	local IdleParams = {}
	for _, Type in pairs(EmotionDefines.IdlePoseType) do
		local PropName = EmotionDefines.IdlePropertyNames[Type]
		IdleParams[Type] = PlayerAnimParam[PropName]
	end

	return EmotionAnimUtils.IdleParamsToCSValue(IdleParams)
end

-- 获取Idle类型
function EmotionAnimUtils.GetCurIdleType(EntityID)
	local PlayerAnimInst = AnimationUtil.GetAnimInst(EntityID)
	if PlayerAnimInst == nil then
		return
	end

	return PlayerAnimInst.PrevIdleType + 1
end

--- 检查情感动作表是否填写有动作路径
function EmotionAnimUtils.IsEmotionHasAnim(Data)
	if string.isnilorempty(Data.AnimPath) and string.isnilorempty(Data.BeginAnimPath)
		and string.isnilorempty(Data.OnGroundAnimPath) and string.isnilorempty(Data.OnChairAnimPath)
		and string.isnilorempty(Data.UpperBodyAnimPath) and string.isnilorempty(Data.AdjustAnimPath) then
		return false
	end
	return true
end

return EmotionAnimUtils