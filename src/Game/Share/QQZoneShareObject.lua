--[[
Author: jususchen jususchen@tencent.com
Date: 2024-12-17 15:38:56
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-17 15:39:12
FilePath: \Script\Game\Share\QQZoneShareObject.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local ShareObject = require("Game/Share/ShareObject")
local ShareDefine = require("Game/Share/ShareDefine")


---@class QQZoneShareObject : ShareObject
local QQZoneShareObject = LuaClass(ShareObject, nil)

function QQZoneShareObject:Ctor()
    self:SetIcon(ShareDefine.SharePlatformIcons.QQ_ZONE)
    self.TipIDAppNotInstalled = 172023
end

function QQZoneShareObject:IsAppToShareInstalled()
    return _G.AccountUtil and _G.AccountUtil.IsQQInstalled()
end

function QQZoneShareObject:GetShareChannel()
    return "QQ"
end

function QQZoneShareObject:CanShareImage()
    return true
end


return QQZoneShareObject