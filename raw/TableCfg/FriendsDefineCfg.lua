local ProtoRes = require("Protocol/ProtoRes")

local FRIEND_GLOBAL_CFG_ID = ProtoRes.friend_global_cfg_id

-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FriendsDefineCfg : CfgBase
local FriendsDefineCfg = {
	TableName = "c_friends_define_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FriendsDefineCfg, { __index = CfgBase })

FriendsDefineCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---获取好友数量上限
function FriendsDefineCfg:GetFriendMax()
	local Cfg = self:FindCfgByKey(FRIEND_GLOBAL_CFG_ID.FRIEND_CFG_MIN_FRIEND_NUM_MAX)
	if nil == Cfg or nil == Cfg.Value then
		return 0
	end

	return tonumber(Cfg.Value[1]) or 0
end

--- 获取好友分组数量上限
function FriendsDefineCfg:GetFriendGroupMax()
	local Cfg = self:FindCfgByKey(FRIEND_GLOBAL_CFG_ID.FRIEND_CFG_MAX_GROUP_NUM_MAX)
	if nil == Cfg or nil == Cfg.Value then
		return 0
	end

	return tonumber(Cfg.Value[1]) or 0
end

--- 获取好友分组名称长度上限
function FriendsDefineCfg:GetMaxLengthGroupName()
	local Cfg = self:FindCfgByKey(FRIEND_GLOBAL_CFG_ID.FRIEND_CFG_MAX_FRIEND_GROUP_MESSAGE)
	if nil == Cfg or nil == Cfg.Value then
		return 0
	end

	return tonumber(Cfg.Value[1]) or 0
end

--- 获取好友昵称长度上限
function FriendsDefineCfg:GetMaxLengthNickname()
	local Cfg = self:FindCfgByKey(FRIEND_GLOBAL_CFG_ID.FRIEND_CFG_MAX_NICKNAME_LEN)
	if nil == Cfg or nil == Cfg.Value then
		return 0
	end

	return tonumber(Cfg.Value[1]) or 0
end

return FriendsDefineCfg
