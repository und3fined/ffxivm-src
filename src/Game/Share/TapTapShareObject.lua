--[[
Author: jususchen jususchen@tencent.com
Date: 2024-12-17 15:37:26
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-17 15:37:44
FilePath: \Script\Game\Share\TapTapShareObject.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local ShareObject = require("Game/Share/ShareObject")
local ShareDefine = require("Game/Share/ShareDefine")


---@class TapTapShareObject : ShareObject
local TapTapShareObject = LuaClass(ShareObject, nil)

function TapTapShareObject:Ctor()
    self:SetIcon(ShareDefine.SharePlatformIcons.TAPTAP)
end

function TapTapShareObject:IsAppToShareInstalled()
    -- #TODO
end


return TapTapShareObject