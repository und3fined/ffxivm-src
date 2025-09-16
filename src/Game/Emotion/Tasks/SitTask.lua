local LuaClass = require("Core/LuaClass")
local EmotionTaskBase = require("Game/Emotion/EmotionTaskBase")
local MajorUtil = require("Utils/MajorUtil")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local ActorUtil = require("Utils/ActorUtil")
local SitTask = LuaClass(EmotionTaskBase)

function SitTask:PlayEmotion()
	--坐下动作走动画蓝图
--	local FishSate = ActorUtil.GetActorAnimationComponent(self.FromID):GetFishState();
--	if FishSate == _G.UE.EFishStateType.None then
--		self.Super:PlayEmotion()
--	end
end

function SitTask:OnTaskEnter(Params)
	local EventParams = _G.EventMgr:GetEventParams()
	EventParams.ULongParam1 = self.FromID
	EventParams.BoolParam1 = true				--对应动画蓝图变量bSit
	EventParams.BoolParam2 = self:IsSitGround() --对应动画蓝图变量bCpp_SitGround
	_G.EventMgr:SendCppEvent(EventID.ActorSit, EventParams)

	-- 椅子座りの場合
	local EmotionMgr = _G.EmotionMgr
	if not EventParams.BoolParam2 then
		EmotionMgr:SitChairStat(self.FromID)
	end

	if MajorUtil.IsMajor(self.FromID) then
		EmotionMgr:SetCameraLookAt(Params.IntParam1, true)	-- ネームプレートとカメラの注視点のセット
		EmotionMgr:MajorCanUseSkill(false, self.FromID, self.EmotionID)
	end
	EmotionMgr:UpdateName(self.FromID, -30)
	-- _G.EmotionMgr:OnNameTask(Params.IntParam1, self.FromID)  --暂不使用此方案（实时调整名字位置）

	local FromActor = ActorUtil.GetActorByEntityID(self.FromID)
	if FromActor then
		if FromActor:GetAvatarComponent() then
			FromActor:GetAvatarComponent():TempSetAvatarBack(1)
		end
		if FromActor:GetAnimationComponent() then
			FromActor:GetAnimationComponent():UseIK(false)
		end
		local StateCom = FromActor:GetStateComponent()
		if StateCom then
			StateCom:ClearTempHoldWeapon(_G.UE.ETempHoldMask.ALL, false)
		end
	end
end

function SitTask:OnTaskEnd(Params)
	local EventParams = _G.EventMgr:GetEventParams()
	local CancelBySkill = self.CancelReason == EmotionDefines.CancelReason.SKILL
	EventParams.ULongParam1 = self.FromID
	EventParams.BoolParam1 = false
	EventParams.BoolParam3 = CancelBySkill -- 技能中断的坐下动作   对应动画蓝图变量bCpp_ExitSit
	_G.EventMgr:SendCppEvent(EventID.ActorSit, EventParams)

	-- 结束使用椅子
	local EmotionMgr = _G.EmotionMgr
	if Params.IntParam1 == EmotionMgr.SitChairID then
		EmotionMgr:EndUseChair(self.FromID)
	end

	if MajorUtil.IsMajor(self.FromID) then
		EmotionMgr:SetCameraLookAt(Params.IntParam1, false)	--ネームプレートとカメラの注視点のセット
		EmotionMgr:MajorCanUseSkill(true, self.FromID, self.EmotionID)
	end
	EmotionMgr:UpdateName(self.FromID)
	-- EmotionMgr.IsNameOffset = false   --暂不使用实时偏移名字位置
	-- if EmotionMgr.TimeHandle ~= nil then
	-- 	EmotionMgr:UnRegisterTimer(EmotionMgr.TimeHandle)
	-- 	EmotionMgr.TimeHandle = nil		 --结束时清空定时器
	-- end

	local FromActor = ActorUtil.GetActorByEntityID(self.FromID)
	if FromActor then
		if FromActor:GetAnimationComponent() then
			FromActor:GetAnimationComponent():UseIK(true)
		end
	end
end

--- 坐地上
function SitTask:IsSitGround()
	return self.EmotionID == 52
end

return SitTask