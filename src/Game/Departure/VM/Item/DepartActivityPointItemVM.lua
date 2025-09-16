--
-- Author: Carl
-- Date: 2025-3-24 16:57:14
-- Description:玩法详情中的兴趣点列表ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local DepartOfLightVMUtils = require("Game/Departure/DepartOfLightVMUtils")

---@class DepartActivityPointItemVM : UIViewModel
local DepartActivityPointItemVM = LuaClass(UIViewModel)

function DepartActivityPointItemVM:Ctor()
    self.Content = "" -- 参数文本
end


function DepartActivityPointItemVM:IsEqualVM(Value)
    return true
end

function DepartActivityPointItemVM:UpdateVM(Value)
    self.Content = Value
end

return DepartActivityPointItemVM