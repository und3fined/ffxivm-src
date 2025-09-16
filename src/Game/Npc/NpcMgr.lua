--
-- Author: haialexzhou
-- Date: 2021-6-1
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ActorUtil = require("Utils/ActorUtil")

local NpcCfg = require("TableCfg/NpcCfg")
local MapNpcIconCfg = require ("TableCfg/MapNpcIconCfg")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")

local CS_CMD = ProtoCS.CS_CMD
local CS_NPC_CMD = ProtoCS.CS_NPC_CMD

local NpcFuntionUnit = LuaClass()

function NpcFuntionUnit:Init()
    self.FuncType = 0
    self.ConType = 0
	self.ConValue = 0
	self.DisplayName = 0
	self.FuncValues = 0
end

---@class NpcMgr : MgrBase
local NpcMgr = LuaClass(MgrBase)

function NpcMgr:OnInit()
	self.CurrNpcResID = 0
	self.NpcFuntionUnitList = {}
	self.ChocoboNpcList = {}
end

function NpcMgr:OnBegin()
end

function NpcMgr:OnEnd()
end

function NpcMgr:OnShutdown()

end

function NpcMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_NPC, CS_NPC_CMD.CS_CMD_NPC_RUN, self.OnNetMsgNpcRunRsp)
end

function NpcMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.SelectTarget, self.OnGameEventSelectTarget)
end

function NpcMgr:OnRegisterTimer()

end

---OnGameEventSelectTarget
---@param Params FEventParams
function NpcMgr:OnGameEventSelectTarget(Params)
	if nil == Params then return end
	
	local bIsOutOfRange = Params.BoolParam1
	if bIsOutOfRange then return end

	local EntityID = Params.ULongParam1
	
	local ActorType = ActorUtil.GetActorType(EntityID)
	if ActorType ~= _G.UE.EActorType.Npc then return end

	local AttributeComp = ActorUtil.GetActorAttributeComponent(EntityID)
	if nil == AttributeComp then return end

	self:ShowFuncMenu(AttributeComp.ResID, EntityID)
end

function NpcMgr:InitFunctionUnit(ResID)
	if (ResID == self.CurrNpcResID) then
		return
	end
	self.CurrNpcResID = ResID
	self.NpcFuntionUnitList = {}
	local NpcTableCfg = NpcCfg:FindCfgByKey(self.CurrNpcResID)
	if nil == NpcTableCfg then return end

	local NpcFuntions = NpcTableCfg.Function
	if (NpcFuntions == nil) then
		return
	end
	for i = 1, #NpcFuntions do
		local FuntionUnit = NpcFuntionUnit.New()
		FuntionUnit.FuncType = NpcFuntions[i].Type
		FuntionUnit.ConType = NpcFuntions[i].CondType
		FuntionUnit.ConValue = NpcFuntions[i].CondValue
		FuntionUnit.DisplayName = NpcFuntions[i].ValueStr
		FuntionUnit.FuncValues = NpcFuntions[i].Value
		table.insert(self.NpcFuntionUnitList, FuntionUnit)
	end
end

--废弃
function NpcMgr:ShowFuncMenu(ResID, NpcEntityId)
	--[[
	self:InitFunctionUnit(ResID)
	if (0 == #self.NpcFuntionUnitList) then
		return
	end
	--没有菜单UI，暂时取第一个
	local FuntionUnit = self.NpcFuntionUnitList[1]
	if (FuntionUnit == nil) then
		return
	end

	if (FuntionUnit.FuncType == ProtoRes.interact_func_type.INTERACT_FUNC_OPEN_UI) then
		local ViewID = FuntionUnit.FuncValues[1]
		if (ViewID ~= nil) then
			_G.UIViewMgr:ShowView(ViewID)
		end
	elseif (FuntionUnit.FuncType == ProtoRes.interact_func_type.INTERACT_FUNC_ENTER_PWORLD) then
		local InPWorldID = FuntionUnit.FuncValues[1]
		local InMapID = FuntionUnit.FuncValues[2]
		local Params = { PWorldID = InPWorldID and InPWorldID or 0, MapID = InMapID and InMapID or 0}
	elseif (FuntionUnit.FuncType == ProtoRes.interact_func_type.INTERACT_FUNC_ENTER_ENTERTAIN) then
		local EntertainType = FuntionUnit.FuncValues[1]
		if EntertainType == ProtoCS.EntertainType.ENTERTAIN_TYPE_FANTASY_CARD then
			_G.MagicCardMgr:SendNpcFantasyCard(ResID, NpcEntityId)
		end
	end
	]]
end

function NpcMgr:OnNetMsgNpcRunRsp(MsgBody)
	local InteractiveID = MsgBody.NpcRun.InteractiveID
	if not MsgBody.NpcRun then
		FLOG_ERROR("NpcMgr:OnNetMsgNpcRunRsp NpcRun is nil")
		return
	end

    local Interactivedesc = InteractivedescCfg:FindCfgByKey(InteractiveID)
    if not Interactivedesc then
        FLOG_ERROR("NpcMgr OnNetMsgNpcRunRsp InteractiveID is not config: %d", InteractiveID)
        return false
    end

	--协议里的数据，跟进交互表里的functype来识别
	-- if ProtoRes.interact_func_type.*** == Interactivedesc.FuncType then
	-- end
end

---@type 是否陆行鸟NPC
---@param ListID number@编辑器ListID(当前地图)
---@return boolean
function NpcMgr:IsChocoboNpcByListID(ListID)
	local MapID = _G.PWorldMgr:GetCurrMapResID()
	local NpcList = self.ChocoboNpcList[MapID]
	if not NpcList then
		NpcList = {}
		local MapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
		if MapEditCfg then
			for _,Npc in ipairs(MapEditCfg.NpcList) do
				if self:IsChocoboNpcByNpcID(Npc.NpcID) then
					NpcList[Npc.ListId] = true
				end
			end
			self.ChocoboNpcList[MapID] = NpcList
		end
	end

	return NpcList[ListID] ~= nil
end

---@type 是否陆行鸟NPC
---@param NpcID number
---@return boolean
function NpcMgr:IsChocoboNpcByNpcID(NpcID)
	local MapNpcIconCfgItem = MapNpcIconCfg:FindCfgByKey(NpcID)
	if MapNpcIconCfgItem then
		return MapNpcIconCfgItem.NPCIconType == ProtoRes.MapNPCIconType.MAP_NPC_ICON_TYPE_CHOCOBO
	end
	return false
end

return NpcMgr