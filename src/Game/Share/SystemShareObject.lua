--[[
Author: jususchen jususchen@tencent.com
Date: 2024-12-17 15:51:42
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-17 15:51:58
FilePath: \Script\Game\Share\SystemShareObject.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local ShareObject = require("Game/Share/ShareObject")
local ShareDefine = require("Game/Share/ShareDefine")


---@class SystemShareObject : ShareObject
local SystemShareObject = LuaClass(ShareObject, nil)

function SystemShareObject:Ctor()
    self:SetIcon(ShareDefine.SharePlatformIcons.SYSTEM)
end

function SystemShareObject:IsAppToShareInstalled()
    return true
end

function SystemShareObject:CanShareImage()
    return true
end

function SystemShareObject:GetShareChannel()
    return "System"
end


return SystemShareObject