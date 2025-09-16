---
--- Author: xingcaicao
--- DateTime: 2024-06-26 20:35
--- Description:
---

local SaveKey = require("Define/SaveKey")

local USaveMgr

---@class SocialSettings
local SocialSettings = {
    FriendHideSignRoleIDs = {},
}

function SocialSettings.InitSettings()
	USaveMgr = _G.UE.USaveMgr

    do
        --【好友】隐藏签名信息
        local Str = USaveMgr.GetString(SaveKey.FriendHideSign, "", true)
		local SplitStr = string.split(Str, ",")
		local Data = {}

		for _, v in ipairs(SplitStr) do
			table.insert(Data, tonumber(v))
		end

        SocialSettings.FriendHideSignRoleIDs = Data 
    end
end

---------------------------------------------------------------------------------------------------------------
--- 好友

function SocialSettings.CheckFriendHideSignInfo()
    local CurRoleIDs = SocialSettings.FriendHideSignRoleIDs
    if table.is_nil_empty(CurRoleIDs) then
        return
    end

    local IsChanged = false

    -- 清理掉不是好友的数据
    for i = #CurRoleIDs, 1, -1 do
        if not _G.FriendMgr:IsFriend(CurRoleIDs[i]) then
            table.remove(CurRoleIDs, i)
            IsChanged = true
        end
    end

    if IsChanged then
        local Str = table.concat(CurRoleIDs, ",")
        USaveMgr.SetString(SaveKey.FriendHideSign, Str, true)
    end
end

function SocialSettings.AddFriendHideSignInfo(RoleID)
    if nil == RoleID then
        return
    end

    local CurRoleIDs = SocialSettings.FriendHideSignRoleIDs
    if table.contain(CurRoleIDs, RoleID) then
        return
    end

    table.insert(CurRoleIDs, RoleID)

    local Str = table.concat(CurRoleIDs, ",")
    USaveMgr.SetString(SaveKey.FriendHideSign, Str, true)
end

function SocialSettings.DeleteFriendHideSignInfo(RoleID)
    if nil == RoleID then
        return
    end

    local CurRoleIDs = SocialSettings.FriendHideSignRoleIDs
    if table.is_nil_empty(CurRoleIDs) then
        return
    end

    if table.remove_item(CurRoleIDs, RoleID) then
        local Str = table.concat(CurRoleIDs, ",")
        USaveMgr.SetString(SaveKey.FriendHideSign, Str, true)
    end
end

---是否隐藏签名（好友）
function SocialSettings.IsFriendHideSign(RoleID)
    if RoleID then
        return table.contain(SocialSettings.FriendHideSignRoleIDs, RoleID)
    end
end

return SocialSettings