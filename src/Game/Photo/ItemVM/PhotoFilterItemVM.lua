local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
-- local SceneEnterTypeCfg = require("TableCfg/SceneEnterTypeCfg")
-- local ProfUtil = require("Game/Profession/ProfUtil")
-- local UIUtil = require("Utils/UIUtil")
-- local ItemUtil = require("Utils/ItemUtil")
local PhotoTemplateUtil = require("Game/Photo/Util/PhotoTemplateUtil")
local PhotoFilterCfg = require("TableCfg/PhotoFilterCfg")

local PhotoFilterItemVM = LuaClass(UIViewModel)

function PhotoFilterItemVM:Ctor()
    self.ID = -1
    self.Name = ""
    self.Icon = ""
    self.IsSelected = false
end

function PhotoFilterItemVM:UpdateVM(Data)
	self.ID = Data.ID
    local Cfg = PhotoFilterCfg:FindCfgByKey(self.ID)

    if Cfg then
        self.Name = Cfg.Name
        self.Icon = Cfg.Icon
        self.ResName = Cfg.ResName
        self.Param = Cfg.Param
    end

    self.IsSelected = false
end

function PhotoFilterItemVM:IsEqualVM(Data)
	return Data.ID == self.ID
end


return PhotoFilterItemVM