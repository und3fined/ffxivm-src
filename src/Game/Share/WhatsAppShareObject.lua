--[[
Author: jususchen jususchen@tencent.com
Date: 2024-12-17 15:52:47
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-17 15:53:08
FilePath: \Script\Game\Share\WhatsAppShareObject.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local ShareObject = require("Game/Share/ShareObject")
local ShareDefine = require("Game/Share/ShareDefine")


---@class WhatsAppShareObject : ShareObject
local WhatsAppShareObject = LuaClass(ShareObject, nil)

function WhatsAppShareObject:Ctor()
    WhatsAppShareObject:SetIcon(ShareDefine.SharePlatformIcons.WHATSAPP)
end

function WhatsAppShareObject:IsAppToShareInstalled()
    -- #TODO
end

function WhatsAppShareObject:GetShareChannel()
    return "WhatsApp"
end

function WhatsAppShareObject:CanShareImage()
    return true
end


return WhatsAppShareObject