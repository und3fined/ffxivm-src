---
--- Author: sammrli
--- DateTime: 2024-02-02
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local TravelLogGenreCfg = require("TableCfg/TravelLogGenreCfg")

---@class TravelLogTaskTitleItemVM : UIViewModel
local TravelLogTaskTitleItemVM = LuaClass(UIViewModel)

function TravelLogTaskTitleItemVM:Ctor(Value)
    self.GenreID = 0
    self.Title = ""

    if Value ~= nil  then
        self:UpdateVM(Value)
    end
end

function TravelLogTaskTitleItemVM:UpdateVM(Value)
    self.GenreID = Value.GenreID

    local Cfg = TravelLogGenreCfg:FindCfgByKey(Value.GenreID)
    if Cfg then
        self.Title = Cfg.DetailedGenre
    else
        self.Title = ""
    end
end

function TravelLogTaskTitleItemVM:IsEqualVM(Value)
	return self.GenreID == Value.GenreID
end

function TravelLogTaskTitleItemVM:AdapterOnGetCanBeSelected()
    return false
 end

 function TravelLogTaskTitleItemVM:AdapterOnGetWidgetIndex()
    return 0
 end

function TravelLogTaskTitleItemVM:AdapterSetCategory(ItemCategory)
    if self.GenreID == ItemCategory then return end
    self:UpdateVM({GenreID = ItemCategory})
end

return TravelLogTaskTitleItemVM