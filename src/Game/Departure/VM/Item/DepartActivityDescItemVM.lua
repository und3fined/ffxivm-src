--
-- Author: Carl
-- Date: 2025-3-24 16:57:14
-- Description:玩法说明列表ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local DepartOfLightVMUtils = require("Game/Departure/DepartOfLightVMUtils")

---@class DepartActivityDescItemVM : UIViewModel
local DepartActivityDescItemVM = LuaClass(UIViewModel)

function DepartActivityDescItemVM:Ctor()
    self.Title = "" -- 小标题
    self.IconPath = "" -- 图片
end


function DepartActivityDescItemVM:IsEqualVM(Value)
    return true
end

function DepartActivityDescItemVM:UpdateVM(Value)
    self.Title = Value.Title
    self.IconPath = Value.IconPath
end

return DepartActivityDescItemVM