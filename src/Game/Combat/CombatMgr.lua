---
--- Author: anypkvcai
--- DateTime: 2021-02-23 14:08
--- Description:
---

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local EventID = require("Define/EventID")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local HUDMgr = require("Game/HUD/HUDMgr")
local SelectTargetBase = require("Game/Skill/SelectTarget/SelectTargetBase")

local CS_CMD = ProtoCS.CS_CMD
local CS_COMBAT_CMD = ProtoCS.CS_COMBAT_CMD
local FLOG_SCREEN = _G.FLOG_SCREEN
local UE = _G.UE

---@class CombatMgr : MgrBase
local CombatMgr = LuaClass(MgrBase)

function CombatMgr:OnInit()
	self.ShowEnemyCount = false
	self.CloakingActors = {}
end

function CombatMgr:OnBegin()
end

function CombatMgr:OnEnd()
end

function CombatMgr:OnShutdown()

end

function CombatMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMBAT, CS_COMBAT_CMD.CS_COMBAT_CMD_BATCH_COMBAT_PKG, self.OnNetMsgCombatDispatch)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMBAT, CS_COMBAT_CMD.CS_COMBAT_CMD_GET_ENMITY_LIST, self.OnNetMsgGetEnmityList)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMBAT, CS_COMBAT_CMD.CS_COMBAT_CMD_QUERY_RELATE_ENMITY_LIST, self.OnNetMsgGetRelateEnmityList)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMBAT, CS_COMBAT_CMD.CS_COMBAT_CMD_SUBSCRIBE_ENMITY_CHANGES, self.OnNetMsgSubscribeEnmityList)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMBAT, CS_COMBAT_CMD.CS_COMBAT_CMD_CANCEL_SUBSCRIBE_ENMITY_CHANGES, self.OnNetMsgCancelSubscribeEnmityList)
end

function CombatMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.TrivialCombatStateUpdate, self.OnCombatStateUpdate)
    self:RegisterGameEvent(EventID.NetworkReconnected, 		self.OnNetworkReconnected) 			-- 断线重连 
end

--战斗协议合并到了一起，这里负责分发
function CombatMgr:OnNetMsgCombatDispatch(MsgBody)
	local Pkgs = MsgBody.BatchCombatPkg.Pkgs
	for _, value in ipairs(Pkgs) do
		_G.GameNetworkMgr:DispatchMsg(CS_CMD.CS_CMD_COMBAT, value.Cmd, value)
	end
end

---OnNetMsgGetEnemyList
---@param MsgBody table                @CombatRsp
function CombatMgr:OnNetMsgGetEnmityList(MsgBody)
	local Msg = MsgBody.EnmityList
	if nil == Msg then
		return
	end

	_G.EventMgr:SendEvent(EventID.CombatGetEnmityList, Msg)

	if self.ShowEnemyCount then
		FLOG_SCREEN("ActorName=%s EnemyCount=%d ", _G.HUDMgr:GetActorName(Msg.EntityID), #Msg.List)
	end
end

function CombatMgr:OnNetMsgGetRelateEnmityList(MsgBody)
	local Msg = MsgBody.RelateEmityList
	if nil == Msg then
		return
	end

	_G.EventMgr:SendEvent(EventID.CombatGetRelateEnmityList, Msg)
end

function CombatMgr:OnCombatStateUpdate(Params)
	local EntityID = Params.ULongParam1
	local CombatStatIDCloack = 24 -- 协议暂未定义该CombatStatID
	local CurActor = ActorUtil.GetActorByEntityID(EntityID)
	if nil == CurActor then
		return
	end
	-- 主角EntityID会一直改变，单独处理
	if MajorUtil.IsMajor(EntityID) then
		if ActorUtil.IsInComBatState(EntityID, CombatStatIDCloack) then
			CurActor:GetStateComponent():StartTransparent(0, UE.ETransparentReason.Cloak)
		else
			CurActor:GetStateComponent():EndTransparent(0, UE.ETransparentReason.Cloak)
		end
		return
	end

	-- 其他角色
	if ActorUtil.IsInComBatState(EntityID, CombatStatIDCloack) then
		if nil == self.CloakingActors[EntityID] then
			local bIsAlly = SelectTargetBase:GetCampRelationByMajor(MajorUtil.GetMajor(), CurActor) == ProtoRes.camp_relation.camp_relation_ally
			self.CloakingActors[EntityID] = {bIsAlly = bIsAlly}
			if bIsAlly then
				CurActor:GetStateComponent():StartTransparent(0, UE.ETransparentReason.Cloak)
			else
				CurActor:SetActorVisibility(false, _G.UE.EHideReason.Sneak)
				CurActor:SetHUDVisibility(false, _G.UE.EHideReason.Sneak)
				CurActor:GetStateComponent():SetActorControlState(_G.UE.EActorControllStat.CanPlayerSelected, false, "Combat")
			end
		end
	elseif nil ~= self.CloakingActors[EntityID] and not ActorUtil.IsInComBatState(EntityID, CombatStatIDCloack) then
		if self.CloakingActors[EntityID].bIsAlly == true then
			CurActor:GetStateComponent():EndTransparent(0, UE.ETransparentReason.Cloak)
		else
			CurActor:SetActorVisibility(true, _G.UE.EHideReason.Sneak)
			CurActor:SetHUDVisibility(true, _G.UE.EHideReason.Sneak)
			CurActor:GetStateComponent():SetActorControlState(_G.UE.EActorControllStat.CanPlayerSelected, true, "Combat")
		end
		self.CloakingActors[EntityID] = nil
	end
end

function CombatMgr:OnNetworkReconnected(Params)
    -- if not Params or not Params.bRelay then
    --     return
    -- end

	local MajorActor = MajorUtil.GetMajor()
	if not MajorActor then
		return
	end

	FLOG_INFO("SendReqMajorCamp")
	--闪断了，重新拉取主角的阵营
	self:SendReqMajorCamp()
end

---SendModifyTeamTaskReq
---@param EntityID number
---@param MaxCount number        @ 拉取数量，0表示拉取全部仇恨列表
---@param Reason number          @ 拉取原因
function CombatMgr:SendGetEnmityListReq(EntityID, MaxCount, Reason)
	local MsgID = CS_CMD.CS_CMD_COMBAT
	local SubMsgID = CS_COMBAT_CMD.CS_COMBAT_CMD_GET_ENMITY_LIST

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.EnmityList = { EntityID = EntityID, MaxCount = MaxCount, Reason = Reason }

	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---OnNetMsgSubscribeEnmityList
---@param MsgBody table                @CombatRsp
function CombatMgr:OnNetMsgSubscribeEnmityList(MsgBody)
	local Msg = MsgBody.SubscribeEnmity
	if nil == Msg then
		return
	end

	_G.EventMgr:SendEvent(EventID.CombatSubscribeEnmityList, Msg)
end

---OnNetMsgCancelSubscribeEnmityList
---@param MsgBody table                @CombatRsp
function CombatMgr:OnNetMsgCancelSubscribeEnmityList(MsgBody)
	local Msg = MsgBody.CancelSubscribeEnmity
	if nil == Msg then
		return
	end

	_G.EventMgr:SendEvent(EventID.CombatCancelSubscribeEnmityList, Msg)
end

---SubscribeEnmityListReq		 订阅仇恨变化的entity列表
---@param EntityList table
function CombatMgr:SubscribeEnmityListReq(EntityList)
	local MsgID = CS_CMD.CS_CMD_COMBAT
	local SubMsgID = CS_COMBAT_CMD.CS_COMBAT_CMD_SUBSCRIBE_ENMITY_CHANGES

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.SubscribeEnmity = {EntityID=EntityList}
	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---CancelSubscribeEnmityListReq		 取消订阅仇恨变化的entity列表
---@param EntityList table
function CombatMgr:CancelSubscribeEnmityListReq(EntityList)
	local MsgID = CS_CMD.CS_CMD_COMBAT
	local SubMsgID = CS_COMBAT_CMD.CS_COMBAT_CMD_CANCEL_SUBSCRIBE_ENMITY_CHANGES

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.CancelSubscribeEnmity = {EntityID=EntityList}
	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function CombatMgr:SendSyncBuffReq(EntityID)
	local MsgID = CS_CMD.CS_CMD_COMBAT
	local SubMsgID = CS_COMBAT_CMD.CS_COMBAT_CMD_SYNC_BUFF

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.SyncBuff = { ObjID = EntityID }

	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function CombatMgr:SendReqMajorCamp()
	local MsgID = CS_CMD.CS_CMD_COMBAT
	local SubMsgID = CS_COMBAT_CMD.CS_COMBAT_CMD_QUERY_CAMP

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID

	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--获取怪物周围与其关联仇恨的怪物列表
function CombatMgr:SendGetRelateEnmityListReq(EntityID)
	local MsgID = CS_CMD.CS_CMD_COMBAT
	local SubMsgID = CS_COMBAT_CMD.CS_COMBAT_CMD_QUERY_RELATE_ENMITY_LIST

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.RelateEnmtiy = { EntityID = EntityID }

	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

return CombatMgr