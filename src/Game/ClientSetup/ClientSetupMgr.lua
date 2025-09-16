local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")

local ClientSetupKey = ProtoCS.ClientSetupKey
local CS_CMD = ProtoCS.CS_CMD
local CLIENT_SETUP_SUB_ID = ProtoCS.ClientSetupMsgID

-- 客户端通用配置 (配置跟随RoleID 用于和服务器同步各个玩家的一些选项)
---@class ClientSetupMgr : MgrBase
local ClientSetupMgr = LuaClass(MgrBase)

function ClientSetupMgr:OnInit()
end

function ClientSetupMgr:OnBegin()
	-- 目前只记录主角
	self.SetupRecorder = {}
	self.bSetupRequested = false
end

function ClientSetupMgr:OnEnd()
	self.SetupRecorder = {}
	self.bSetupRequested = false
end

function ClientSetupMgr:OnShutdown()

end

function ClientSetupMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLIENT_CFG, CLIENT_SETUP_SUB_ID.ClientSetupMsgIDQuery, self.OnNetMsgQueryRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLIENT_CFG, CLIENT_SETUP_SUB_ID.ClientSetupMsgIDSet, self.OnNetMsgSetRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLIENT_CFG, CLIENT_SETUP_SUB_ID.ClientSetupMsgIDNtf, self.OnNetMsgNotifyRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_CLIENT_CFG_CHG, self.OnNetMsgVisionCfgChange)
end

function ClientSetupMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ClientSetupQuery, self.OnGameEventQuery)
	self:RegisterGameEvent(EventID.ClientSetupQueryAll, self.OnGameEventQueryAll)
	self:RegisterGameEvent(EventID.ClientSetupSet, self.OnGameEventSet)
	self:RegisterGameEvent(EventID.ClientSetupPost, self.OnGameEventPost)
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventRoleLoginRes)
	self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)
	self:RegisterGameEvent(EventID.ClientSetupVisionInit, self.OnGameEventVisionInit)
end

function ClientSetupMgr:SendQueryReq(KeyList)
	local MsgID = CS_CMD.CS_CMD_CLIENT_CFG
	local SubMsgID = CLIENT_SETUP_SUB_ID.ClientSetupMsgIDQuery
	local MsgBody = {}
	MsgBody.SubMsgID = SubMsgID
	if KeyList ~= nil and #KeyList > 0 then		-- 空表示查询全部
		MsgBody.Query = { Key = KeyList }
	end

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function ClientSetupMgr:SendSetReq(Key, Value)
  	FLOG_WARNING("ClientSetupMgr:SendSetReq " .. Key .. " To " ..Value)
	local MsgID = CS_CMD.CS_CMD_CLIENT_CFG
	local SubMsgID = CLIENT_SETUP_SUB_ID.ClientSetupMsgIDSet
	local MsgBody = {}
	MsgBody.SubMsgID = SubMsgID
	MsgBody.Set = { Key = Key, Value = Value }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function ClientSetupMgr:GetSetupList(RoleID)
	return self.SetupRecorder[RoleID]
end

function ClientSetupMgr:GetSetupValue(RoleID, SetupKey)
	local SetupList = self:GetSetupList(RoleID)
	return SetupList and SetupList[SetupKey] or nil
end

function ClientSetupMgr:RecordValue(RoleID, ValueTable)
	if self.SetupRecorder == nil then
		self.SetupRecorder = {}
	end
	if RoleID == nil then
		return
	end
	local RoleRecoder = self.SetupRecorder[RoleID]
	if RoleRecoder == nil then
		self.SetupRecorder[RoleID] = {}
		RoleRecoder = self.SetupRecorder[RoleID]
	end

	for k,v in pairs(ValueTable) do
		RoleRecoder[k] = v
	end
end

function ClientSetupMgr:OnNetMsgQueryRsp(MsgBody)
	if MsgBody.Query then
		local ValueTable = MsgBody.Query.Table

		-- 只记录Major
		local RoleID = MajorUtil.GetMajorRoleID()
		self:RecordValue(RoleID, ValueTable)

		--广播
		-- print("ClientSetupMgr:OnNetMsgQueryRsp:" .. RoleID)
		for Key, Value in pairs(ValueTable) do
			self:PrintLog("ClientSetupMgr:OnNetMsgQueryRsp", RoleID, Key, Value)
			self:SendPost(RoleID, Key, Value)
		end
	end
end

function ClientSetupMgr:OnNetMsgNotifyRsp(MsgBody)
	local Key = MsgBody.Ntf.Key
	local Value = MsgBody.Ntf.value
	local MajorRoleID = MajorUtil.GetMajorRoleID()
	local ValueTable = {}
	ValueTable[Key] = Value
	self:RecordValue(MajorRoleID, ValueTable)
	self:SendPost(MajorRoleID, Key, Value)
end

function ClientSetupMgr:GetDesc(RoleID, Key, Value)
	return string.format("[RoleID:%d] Set Key %d to Value %s", RoleID, Key, Value)
end

function ClientSetupMgr:PrintLog(Title, RoleID, Key, Value)
	-- print(string.format("[%s] %s", Title, self:GetDesc(RoleID, Key, Value)))
end

function ClientSetupMgr:OnNetMsgSetRsp(MsgBody)
	local Key = MsgBody.Set.Key
	local Value = MsgBody.Set.Value
	local MajorRoleID = MajorUtil.GetMajorRoleID()
	local ValueTable = {}
	ValueTable[Key] = Value
	self:RecordValue(MajorRoleID, ValueTable)
	self:SendPost(MajorRoleID, Key, Value, true)
	self:PrintLog("ClientSetupMgr:OnNetMsgSetRsp", MajorRoleID, Key, Value)
end

function ClientSetupMgr:OnNetMsgVisionCfgChange(MsgBody)
	local ClientCfgChg = MsgBody.ClientCfgChg
	local EntityID = MsgBody.ClientCfgChg.EntityID
	local RoleID = ActorUtil.GetRoleIDByEntityID(EntityID)
	for Key, Value in pairs(ClientCfgChg.ClientCfg) do
		self:PrintLog("ClientSetupMgr:OnNetMsgVisionCfgChange", RoleID, Key, Value)
		self:RecordAndPost(RoleID, Key, Value, true)
	end
end

function ClientSetupMgr:SendPost(RoleID, Key, Value, IsSet)
	local EventParams = _G.EventMgr:GetEventParams()
	EventParams.ULongParam1 = RoleID
	EventParams.IntParam1 = Key
	EventParams.StringParam1 = Value
	EventParams.BoolParam1 = IsSet or false	-- 用于判断是查询同步的还是设置回复的
	_G.EventMgr:SendEvent(_G.EventID.ClientSetupPost, EventParams)
	_G.EventMgr:SendCppEvent(_G.EventID.ClientSetupPost, EventParams)
end

-- 记录Major的Setup Post所有
function ClientSetupMgr:RecordAndPost(RoleID, Key, Value, IsSet)
	if RoleID == MajorUtil.GetMajorRoleID() then
		local ValueTable = {}
		ValueTable[Key] = Value
		self:RecordValue(RoleID, ValueTable)
	end

	self:SendPost(RoleID, Key, Value, IsSet)
end

-- 查询时 如果本地有缓存数据 则立即通过事件返回
-- 否则将会向后台请求后通过事件返回
function ClientSetupMgr:OnGameEventQuery(Params)
	local RoleID = Params.ULongParam1
	local SetupKey = Params.IntParam1

	local CacheValue = self:GetSetupValue(RoleID, SetupKey)
	if CacheValue then
		self:SendPost(RoleID, SetupKey, CacheValue)
		self:PrintLog("ClientSetupMgr:OnGameEventQuery", RoleID, SetupKey, CacheValue)
	else
		print(string.format("ClientSetupMgr:OnGameEventQuery [%d] for %s" , RoleID, SetupKey))
		local KeyList = {}
		KeyList[0] = SetupKey
		self:SendQueryReq(KeyList)
	end
end

function ClientSetupMgr:OnGameEventQueryAll(Params)
	local RoleID = Params.ULongParam1
	--print("ClientSetupMgr Query All " .. RoleID)
	self:SendQueryReq(nil)
end

-- 为保证后台安全 字符串长度最多2048
function ClientSetupMgr:OnGameEventSet(Params)
	-- 只允许修改自己客户端的值 故无需指定RoleID
	local Key = Params.IntParam1 or 0
	local Value = Params.StringParam1 or ""
	if #Value > 2048 then
		FLOG_ERROR("ClientSetupMgr Set value is invalid because length limit 2048!" .. Value)
		return
	end
	self:SendSetReq(Key, Value)
end

function ClientSetupMgr:OnGameEventVisionInit(Params)
	-- 由服务器发来 只需要进行缓存与Post
	local Key = Params.IntParam1
	local Value = Params.StringParam1
	local RoleID = Params.ULongParam1

	--self:PrintLog("ClientSetupMgr:OnGameEventVisionInit", RoleID, Key, Value)
	self:RecordAndPost(RoleID, Key, Value)
end

function ClientSetupMgr:OnGameEventPost(Params)
	local RoleID = Params.ULongParam1
	local SetupKey = Params.IntParam1
	local SetupValue = Params.StringParam1
	self:PrintLog("ClientSetupMgr:OnGameEventPost", RoleID, SetupKey, SetupValue)
end

function ClientSetupMgr:OnGameEventRoleLoginRes(Params)
	if Params.bReconnect then
		self:SendQueryReq(nil)
	end
end

function ClientSetupMgr:OnGameEventMajorCreate(Params)
	local bReuseMajor = Params.BoolParam1
	if not bReuseMajor then
		self:SendQueryReq(nil)
	end
end

---查询设置信息
---@param Keys table @待查询的Keys, { ClientSetupKey }
function ClientSetupMgr:QuerySetupInfo( RoleID, Keys )
	if nil == RoleID or nil == Keys then
		return
	end

	local CacheValue = self:GetSetupValue(RoleID, Keys)
	if CacheValue then
		self:SendPost(RoleID, Keys, CacheValue)
	else
		self:SendQueryReq(Keys)
	end
end

---设置玩家偏好职业
---@param StrJsonProfIDs string @职业ID列表Json字符串
function ClientSetupMgr:SetPerferredProf( StrJsonProfIDs )
	if nil == StrJsonProfIDs then
		return
	end

	self:SendSetReq(ClientSetupKey.PerferredProf, StrJsonProfIDs)
end


---设置玩家当前头像ID
---@param StrHeadPortraitID string @头像ID 
function ClientSetupMgr:SetCurHeadPortraitID( StrHeadPortraitID )
	if nil == StrHeadPortraitID then
		return
	end

	self:SendSetReq(ClientSetupKey.HeadPortrait, StrHeadPortraitID)
end

---设置玩家游戏风格
---@param StrJsonStyleIDs string @风格ID列表Json字符串
function ClientSetupMgr:SetGameStyle( StrJsonStyleIDs )
	if nil == StrJsonStyleIDs then
		return
	end

	self:SendSetReq(ClientSetupKey.Playstyle, StrJsonStyleIDs)
end

---设置玩家活跃时间
---@param StrHoursBitValue string @各个时间与运算值字符串
function ClientSetupMgr:SetActiveHours( StrHoursBitValue )
	if nil == StrHoursBitValue then
		return
	end

	self:SendSetReq(ClientSetupKey.ActiveHours, StrHoursBitValue)
end

---设置玩家签名
---@param StrContent string @签名文本内容
function ClientSetupMgr:SetSignContent( StrContent )
	if nil == StrContent then
		return
	end

	self:SendSetReq(ClientSetupKey.PersonalSignature, StrContent)
end

-- 这个是临时的，需要在proto文件里面添加ID，先自己写一个好了
function ClientSetupMgr:SetCardEmoIDList(StrContent)
	self:SendSetReq(ClientSetupKey.FantacyCardEmoList, StrContent)
end

--- 记录是否开启过野外宝箱
function ClientSetupMgr:SetWildBoxOpen(StrContent)
	if nil == StrContent then return end

	self:SendSetReq(ClientSetupKey.CSKWildBoxOpen, StrContent)
end

return ClientSetupMgr