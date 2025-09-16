--[[
Author: jususchen jususchen@tencent.com
Date: 2024-12-17 15:33:32
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-17 15:33:44
FilePath: \Script\Game\Share\WeChatVideoShareObject.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local ShareObject = require("Game/Share/ShareObject")
local ShareDefine = require("Game/Share/ShareDefine")


---@class WeChatVideoShareObject : ShareObject
local WeChatVideoShareObject = LuaClass(ShareObject, nil)

function WeChatVideoShareObject:Ctor()
    self:SetIcon(ShareDefine.SharePlatformIcons.WECHAT_VIDEO)
end

function WeChatVideoShareObject:IsAppToShareInstalled()
    return _G.AccountUtil and _G.AccountUtil.IsWeChatInstalled()
end


return WeChatVideoShareObject