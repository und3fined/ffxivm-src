local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
-- local SceneEnterTypeCfg = require("TableCfg/SceneEnterTypeCfg")
-- local ProfUtil = require("Game/Profession/ProfUtil")
-- local UIUtil = require("Utils/UIUtil")
-- local ItemUtil = require("Utils/ItemUtil")

local PhotoSubTabItemVM = LuaClass(UIViewModel)

function PhotoSubTabItemVM:Ctor()
    self.Name = ""
	self.IsSelected = false
	self.Idx = -1
end

function PhotoSubTabItemVM:UpdateVM(Data)
	self.Idx = Data.Idx
	self.Name = Data.Name
	self.IsSelected = false
end

function PhotoSubTabItemVM:IsEqualVM(Data)
	return Data.Name == self.Name
end



return PhotoSubTabItemVM