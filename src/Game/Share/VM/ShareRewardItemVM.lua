--[[
Author: jususchen jususchen@tencent.com
Date: 2024-12-17 10:24
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-26 17:09:22
FilePath: \Script\Game\Share\VM\ShareRewardItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class ShareRewardItemVM : UIViewModel
---@field Icon string
local ShareRewardItemVM = LuaClass(UIViewModel, nil)

function ShareRewardItemVM:IsEqualVM()
	return false
end

function ShareRewardItemVM:UpdateVM(Value)
    self.Icon = Value.Icon
    self.IsValid = self.Icon and self.Icon ~= ""
    self.ItemColorAndOpacity = Value.ItemColorAndOpacity or _G.UE.FLinearColor(1, 1, 1, 1)
    self.ItemLevelVisible = Value.ItemLevelVisible or false
    self.Num = Value.Num or 0
    self.NumVisible = self.Num > 0
    self.IconChooseVisible = Value.IconChooseVisible or false
    self.bSyncIcon = Value.bSyncIcon or false
end



return ShareRewardItemVM