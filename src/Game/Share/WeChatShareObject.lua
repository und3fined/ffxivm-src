--[[
Author: jususchen jususchen@tencent.com
Date: 2024-12-17 15:20:17
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-17 15:21:30
FilePath: \Script\Game\Share\WeChatShareObject.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AEru
--]]
local LuaClass = require("Core/LuaClass")
local ShareObject = require("Game/Share/ShareObject")
local ShareDefine = require("Game/Share/ShareDefine")


---@class WeChatShareObject : ShareObject
local WeChatShareObject = LuaClass(ShareObject, nil)

function WeChatShareObject:Ctor()
    self:SetIcon(ShareDefine.SharePlatformIcons.WECHAT)
    self.TipIDAppNotInstalled = 172023
end

function WeChatShareObject:IsAppToShareInstalled()
    local AccountUtil = require("Utils/AccountUtil")
    return AccountUtil.IsWeChatInstalled()
end

function  WeChatShareObject:ShareExternalLink()
    local ShareMgr = require("Game/Share/ShareMgr")
    ShareMgr.ShareLinkByMSDK(self)
end

function WeChatShareObject:GetShareChannel()
    return "WeChat"
end

function WeChatShareObject:ShareImage()
    local ShareMgr = require("Game/Share/ShareMgr")
    ShareMgr.ShareImageToFriendByMSDK(self)
end

function WeChatShareObject:CanShareImage()
    return true
end

return WeChatShareObject