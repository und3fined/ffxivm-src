--[[
Date: 2021-12-03 17:22:28
LastEditors: moody
LastEditTime: 2021-12-03 17:22:28
--]]
local LuaClass = require("Core/LuaClass")
local EmotionTaskBase = require("Game/Emotion/EmotionTaskBase")
local ActorUtil = require("Utils/ActorUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")

local HoldWeaponTask = LuaClass(EmotionTaskBase)

function HoldWeaponTask:PlayEmotion()
	-- 收拔刀不需要播放蒙太奇 走状态切换
end

function HoldWeaponTask:TaskEnter(Params)
	-- 直接覆盖掉 不走武器附加的逻辑
	self:OnTaskEnter(Params)
end

function HoldWeaponTask:TaskEnd(Params)
	-- if MajorUtil.IsMajor(Params.ULongParam1) then
	-- 	--若客户端已经收刀，则也同步后台
	-- 	--避免在已收刀后退出重进时，后台任然通知拔刀EmotionMgr:OnEmotionQueryStat
	-- 	local ProtoCS = require ("Protocol/ProtoCS")
	-- 	_G.EmotionMgr:SendStopEmotionReq(ProtoCS.EmotionType.EmotionTypeAll)
	-- end

	self:OnTaskEnd(Params)
end

function HoldWeaponTask:OnTaskEnter(Params)
	local EventParams = _G.EventMgr:GetEventParams()
	EventParams.ULongParam1 = self.FromID
	EventParams.BoolParam1 = true
	_G.EventMgr:SendCppEvent(EventID.ChangeHoldWeaponState, EventParams)
	_G.EventMgr:SendEvent(EventID.ChangeHoldWeaponState, EventParams)
end

function HoldWeaponTask:OnTaskEnd(Params)
	local EventParams = _G.EventMgr:GetEventParams()
	EventParams.ULongParam1 = self.FromID
	EventParams.BoolParam1 = false
	_G.EventMgr:SendCppEvent(EventID.ChangeHoldWeaponState, EventParams)
	_G.EventMgr:SendEvent(EventID.ChangeHoldWeaponState, EventParams)
end

function HoldWeaponTask:CanPlayEmotion()
	local AttributeComp = ActorUtil.GetActorAttributeComponent(self.FromID)
	if AttributeComp == nil then
		FLOG_ERROR("HoldWeaponTask:CanPlayEmotion AttributeComp is Nil")
		return false
	end
	local ProfID = AttributeComp.ProfID
	local Specialization = RoleInitCfg:FindProfSpecialization(ProfID)
	-- 生产职业不进行收拔刀
	if Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then
		return false
	end
	return not _G.EmotionMgr:IsEmotionPlaying(self.FromID, self.EmotionID)
end

return HoldWeaponTask