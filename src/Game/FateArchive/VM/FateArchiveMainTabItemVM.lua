---
--- Author: michaelyang_lightpaw
--- DateTime: 2024-08-28 10:12
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class FateArchiveMainTabItemVM : UIViewModel
local FateArchiveMainTabItemVM = LuaClass(UIViewModel)

function FateArchiveMainTabItemVM:Ctor()
end

function FateArchiveMainTabItemVM:OnInit()
end

---UpdateVM
---@param Value table
function FateArchiveMainTabItemVM:UpdateVM(Data)
    if (Data == nil) then
        _G.FLOG_ERROR("FateArchiveMainTabItemVM:UpdateVM(Data) 错误，传入的 Data为空")
        return
    end
    self.IconSelect = Data.IconSelect
    self.IconNormal = Data.IconNormal
    if Data.Percent ~= nil then
        self.TextPercentVisible = true
        self.Percent = string.format("%s%%", Data.Percent)
    else
        self.TextPercentVisible = false
        self.Percent = string.format("%s%%", Data.Percent)
    end

    if Data.IsLock then
        self.IsModuleOpen = true
    else
        self.IsModuleOpen = false
    end

    --系统解锁
    if Data.ModuleID ~= nil then
        self.ModuleID = Data.ModuleID
        self.IsUnLock = _G.ModuleOpenMgr:CheckOpenState(Data.ModuleID)
        self.IsModuleOpen = not self.IsUnLock
    end

    self.ID = Data.ID
    self.RedDotType = Data.RedDotType
    self.RedDotData = Data.RedDotData
end

function FateArchiveMainTabItemVM:OnBegin()
end

function FateArchiveMainTabItemVM:OnEnd()
end

function FateArchiveMainTabItemVM:OnShutdown()
end

function FateArchiveMainTabItemVM:IsEqualVM(Value)
    return true
end

function FateArchiveMainTabItemVM:AdapterOnGetCanBeSelected()
    if self.ModuleID ~= nil then
        if not self.IsUnLock then
            _G.ModuleOpenMgr:ModuleState(self.ModuleID)
        end
        return self.IsUnLock
    else
        return true
    end
end

return FateArchiveMainTabItemVM
