--
-- Author: anypkvcai
-- Date: 2023-11-01 16:13
-- Description:
--

local ProtoMsg = require("Protocol/ProtoMsg")

---@class NetworkUtil
local NetworkUtil = {

}

function NetworkUtil.GetMsgKey(MsgID, SubMsgID)
	if nil == SubMsgID or nil == MsgID then
		return 0
	end
	return MsgID * 1000 + SubMsgID
end

---GetProtoReqName
---@param MsgID number            @消息ID  ProtoCS.CS_CMD
function NetworkUtil.GetProtoReqName(MsgID)
	local Desc = ProtoMsg[MsgID]
	if nil == Desc then
		return
	end

	return Desc.req
end

---GetProtoResName
---@param MsgID number            @消息ID  ProtoCS.CS_CMD
function NetworkUtil.GetProtoResName(MsgID)
	local Desc = ProtoMsg[MsgID]
	if nil == Desc then
		return
	end

	return Desc.res
end

return NetworkUtil