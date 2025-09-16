--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-01-17 09:52:15
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-03-05 14:36:25
FilePath: \Client\Source\Script\Game\CraftingLog\CraftingLogSetCraftTimesWinVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-12-02 18:51:33
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-12-04 09:53:13
FilePath: \Client\Source\Script\Game\CraftingLog\CraftingLogSetCraftTimesWinVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local LSTR = _G.LSTR

---@class CraftingLogSetCraftTimesWinVM : UIViewModel

local CraftingLogSetCraftTimesWinVM = LuaClass(UIViewModel)

---Ctor
---@field MakeAmount string @制作数量
function CraftingLogSetCraftTimesWinVM:Ctor()
    self:Reset()
end

function CraftingLogSetCraftTimesWinVM:OnShutdown()
    self:Reset()
end

function CraftingLogSetCraftTimesWinVM:Reset()
    self.MakeAmount = 0
    self.TextCraft = ""
    self.MaxMakeCount = 0
end

function CraftingLogSetCraftTimesWinVM:SetMakeAmount(Value)
    self.MakeAmount = Value
end

function CraftingLogSetCraftTimesWinVM:SetMaxMakeCount(Value)
    self.MaxMakeCount = Value
end

return CraftingLogSetCraftTimesWinVM
