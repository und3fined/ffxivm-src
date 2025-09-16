--[[
Author: jususchen jususchen@tencent.com
Date: 2024-12-17 15:48:17
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-17 15:48:31
FilePath: \Script\Game\Share\TwitterShareObject.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local ShareObject = require("Game/Share/ShareObject")
local ShareDefine = require("Game/Share/ShareDefine")


---@class TwitterShareObject : ShareObject
local TwitterShareObject = LuaClass(ShareObject, nil)

function TwitterShareObject:Ctor()
    self:SetIcon(ShareDefine.SharePlatformIcons.TWITTER)
end

function TwitterShareObject:IsAppToShareInstalled()
    -- #TODO
end

function TwitterShareObject:GetShareChannel()
    return "Twitter"
end

function TwitterShareObject:CanShareImage()
    return true
end


return TwitterShareObject