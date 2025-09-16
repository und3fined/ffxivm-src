--[[
Author: jususchen jususchen@tencent.com
Date: 2024-12-17 15:38:56
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-17 15:39:12
FilePath: \Script\Game\Share\QQShareObject.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local ShareObject = require("Game/Share/ShareObject")
local ShareDefine = require("Game/Share/ShareDefine")


---@class QQShareObject : ShareObject
local QQShareObject = LuaClass(ShareObject, nil)

function QQShareObject:Ctor()
    self:SetIcon(ShareDefine.SharePlatformIcons.QQ)
    self.TipIDAppNotInstalled = 172023
end

function QQShareObject:IsAppToShareInstalled()
    local AccountUtil = require("Utils/AccountUtil")
    return AccountUtil.IsQQInstalled()
end

function QQShareObject:ShareExternalLink()
    local ShareMgr = require("Game/Share/ShareMgr")
    ShareMgr.ShareLinkByMSDK(self)
end

function QQShareObject:GetShareChannel()
    return "QQ"
end

function QQShareObject:CanShareImage()
    return true
end

function QQShareObject:ShareImage()
    local ShareMgr = require("Game/Share/ShareMgr")
    ShareMgr.ShareImageToFriendByMSDK(self)
end

return QQShareObject