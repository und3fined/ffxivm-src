local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
-- local SceneEnterTypeCfg = require("TableCfg/SceneEnterTypeCfg")
-- local ProfUtil = require("Game/Profession/ProfUtil")
-- local UIUtil = require("Utils/UIUtil")
-- local ItemUtil = require("Utils/ItemUtil")
local PhotoRoleStatCfg = require("TableCfg/PhotoRoleStatCfg")

local PhotoRoleStatItemVM = LuaClass(UIViewModel)

function PhotoRoleStatItemVM:Ctor()
    self.ID = -1
    self.Name = ""
    self.Icon = ""
    self.IsSelected = false
end

function PhotoRoleStatItemVM:UpdateVM(Data)
	self.ID = Data.ID
    local Cfg = PhotoRoleStatCfg:FindCfgByKey(self.ID)

    if Cfg then
        self.Name = Cfg.Name
        self.Icon = Cfg.Icon
        self.StatID = Cfg.StatID
    end
end

function PhotoRoleStatItemVM:IsEqualVM(Data)
	return Data.ID == self.ID
end


return PhotoRoleStatItemVM