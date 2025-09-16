---
--- Author: sammrli
--- DateTime: 2024-02-02
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class TravelLogTaskItemVM : UIViewModel
---@field ItemVM1 TravelLogTaskItemItemVM
---@field ItemVM2 TravelLogTaskItemItemVM
local TravelLogTaskItemVM = LuaClass(UIViewModel)

function TravelLogTaskItemVM:Ctor()
    self.ItemVM1 = nil
    self.ItemVM2 = nil
    self.IsEmpty = nil
end

function TravelLogTaskItemVM:UpdateVM(Value)
    self.ItemVM1 = Value.ItemVM1
    self.ItemVM2 = Value.ItemVM2
    self.IsEmpty = Value.IsEmpty
end

function TravelLogTaskItemVM:AdapterOnGetWidgetIndex()
    return self.IsEmpty and 2 or 1
 end

function TravelLogTaskItemVM:AdapterGetCategory()
    if not self.ItemVM1.DetailedGenre or self.ItemVM1.DetailedGenre == "" then
        return nil
    end
    return self.ItemVM1.GenreID
end

function TravelLogTaskItemVM:SetSelectedTaskItne(LogID)
    if self.ItemVM1 then
        self.ItemVM1.IsSelected = self.ItemVM1.LogID == LogID
        self:DeleteChildRedDot(self.ItemVM1)
    end
    if self.ItemVM2 then
        self.ItemVM2.IsSelected = self.ItemVM2.LogID == LogID
        self:DeleteChildRedDot(self.ItemVM2)
    end
end

function TravelLogTaskItemVM:DeleteChildRedDot(ItemVM)
    if ItemVM.IsSelected then
        if ItemVM.ChapterID and ItemVM.ChapterID > 0 then
            _G.TravelLogMgr:DeleteChildRedDot(ItemVM.ChapterID)
        end
        if ItemVM.PWorldID and ItemVM.PWorldID > 0 then
            _G.TravelLogMgr:DeleteChildRedDot(ItemVM.PWorldID)
        end
    end
end

return TravelLogTaskItemVM