--[[
Author: jususchen jususchen@tencent.com
Date: 2024-12-17 15:35:48
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-17 15:36:13
FilePath: \Script\Game\Share\BilibiliShareObject.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local ShareObject = require("Game/Share/ShareObject")
local ShareDefine = require("Game/Share/ShareDefine")


---@class BilibiliShareObject : ShareObject
local BilibiliShareObject = LuaClass(ShareObject)

function BilibiliShareObject:Ctor()
    self:SetIcon(ShareDefine.SharePlatformIcons.BILIBILI)
end

function BilibiliShareObject:IsAppToShareInstalled()
    -- #TODO
end


return BilibiliShareObject