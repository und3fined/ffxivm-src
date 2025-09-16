local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local UIBindableList = require("UI/UIBindableList")
local ArmyLogoItemVM = require("Game/Army/ItemVM/ArmyLogoItemVM")
local GroupStoreIconCfg = require("TableCfg/GroupStoreIconCfg")

---@class ArmyRenameWinVM : UIViewModel
local ArmyRenameWinVM = LuaClass(UIViewModel)

---Ctor
function ArmyRenameWinVM:Ctor()
	self.DepotIconBindableList = UIBindableList.New(ArmyLogoItemVM)
	self.CurrentIndex = 1
end

function ArmyRenameWinVM:UpdateListInfo()
	local IconAllCfg =  GroupStoreIconCfg:FindAllCfg()
	self.DepotIconBindableList:UpdateByValues(IconAllCfg)
end

function ArmyRenameWinVM:SetSelectedIndex(Index)
	self.CurrentIndex = Index
end

--要返回当前类
return ArmyRenameWinVM