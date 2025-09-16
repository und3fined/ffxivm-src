--[[
Author: jususchen jususchen@tencent.com
Date: 2024-12-17 15:31:15
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-17 15:31:28
FilePath: \Script\Game\Share\WeChatCircleShareObject.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local ShareObject = require("Game/Share/ShareObject")
local ShareDefine = require("Game/Share/ShareDefine")


---@class WeChatCircleShareObject : ShareObject
local WeChatCircleShareObject = LuaClass(ShareObject, nil)

function WeChatCircleShareObject:Ctor()
    self:SetIcon(ShareDefine.SharePlatformIcons.WECHAT_CIRCLE)
    self.TipIDAppNotInstalled = 172023
end

function WeChatCircleShareObject:IsAppToShareInstalled()
    return _G.AccountUtil and _G.AccountUtil.IsWeChatInstalled()
end

function WeChatCircleShareObject:GetShareChannel()
    return "WeChat"
end

function WeChatCircleShareObject:GetRealShareChannel()
    return "WeChatCircle"
end

function WeChatCircleShareObject:CanShareImage()
    return true
end


return WeChatCircleShareObject