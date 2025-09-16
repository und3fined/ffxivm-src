--[[
Author: EmmyLua(https://github.com/EmmyLua)
Date: 2023/11/2 15:18
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-08-20 20:28:42
FilePath: \Script\Game\PWorld\Entrance\ItemVM\PWorldSelectionItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local UIViewModel = require("UI/UIViewModel")
local SceneMatchUnlockCfg = require("TableCfg/SceneMatchUnlockCfg")
local ProfUtil = require("Game/Profession/ProfUtil")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local LSTR = _G.LSTR

---@class PWorldSelectionItemVM: UIViewModel
local PWorldSelectionItemVM = LuaClass(UIViewModel)

function PWorldSelectionItemVM:Ctor()
    self.SelectionName = ""
	self.SelectionID = 0
	self.bTabUnlock = false
	self.bSelected = false
end

function PWorldSelectionItemVM:UpdateVM(Data)
	self.SelectionID = Data.ID
    self.SelectionName = Data.Name

	self.bTabUnlock = false
	
	local IsUnlock = false
	local Cfg = SceneMatchUnlockCfg:FindCfgByKey(self.SelectionID)
	if Cfg ~= nil then
		IsUnlock = Cfg.IsUnlock == 1
	end
	self.bTabUnlock = IsUnlock
end

function PWorldSelectionItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.SelectionID == self.SelectionID
end

function PWorldSelectionItemVM:AdapterOnGetCanBeSelected()
	return self.bTabUnlock
end

return PWorldSelectionItemVM