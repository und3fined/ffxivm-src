local ProtoRes = require("Protocol/ProtoRes")

local FRIEND_CFG_INDEXS = ProtoRes.FriendCfgIndexDesc

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
	local Cfg = self:FindCfgByKey(FRIEND_CFG_INDEXS.FriendCfgFriendMax)
	if nil == Cfg or nil == Cfg.Value then
		return 0
	end

	return tonumber(Cfg.Value[1]) or 0
end

--- 获取好友分组数量上限
function FriendsDefineCfg:GetFriendGroupMax()
	local Cfg = self:FindCfgByKey(FRIEND_CFG_INDEXS.FriendCfgFriendGroupMax)
	if nil == Cfg or nil == Cfg.Value then
		return 0
	end

	return tonumber(Cfg.Value[1]) or 0
end

return FriendsDefineCfg
