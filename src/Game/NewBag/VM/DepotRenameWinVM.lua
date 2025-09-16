local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local UIBindableList = require("UI/UIBindableList")
local DepotLogoItemVM = require("Game/NewBag/VM/DepotLogoItemVM")
local DepotConfig = require("Game/Depot/DepotConfig")

---@class DepotRenameWinVM : UIViewModel
local DepotRenameWinVM = LuaClass(UIViewModel)

---Ctor
function DepotRenameWinVM:Ctor()
	self.DepotIconBindableList = UIBindableList.New(DepotLogoItemVM)
	self.CurrentIndex = 1
	self.BtnRenameEnabled = nil
end

function DepotRenameWinVM:UpdateListInfo()
	self.DepotIconBindableList:UpdateByValues(DepotConfig.DepotIconConfig)
end

function DepotRenameWinVM:SetSelectedIndex(Index)
	self.CurrentIndex = Index
end

--要返回当前类
return DepotRenameWinVM