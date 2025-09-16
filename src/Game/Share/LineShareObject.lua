--[[
Author: jususchen jususchen@tencent.com
Date: 2024-12-17 15:50:42
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-17 15:50:55
FilePath: \Script\Game\Share\LineShareObject.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local ShareObject = require("Game/Share/ShareObject")
local ShareDefine = require("Game/Share/ShareDefine")


---@class LineShareObject : ShareObject
local LineShareObject = LuaClass(ShareObject, nil)

function LineShareObject:Ctor()
    LineShareObject:SetIcon(ShareDefine.SharePlatformIcons.LINE)
end

function LineShareObject:IsAppToShareInstalled()
    -- #TODO
end

function LineShareObject:GetShareChannel()
    return "Line"
end


return LineShareObject