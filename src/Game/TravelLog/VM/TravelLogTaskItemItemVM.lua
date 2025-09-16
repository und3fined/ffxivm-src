---
--- Author: sammrli
--- DateTime: 2024-02-24
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class TravelLogTaskItemItemVM : UIViewModel
local TravelLogTaskItemItemVM = LuaClass(UIViewModel)

function TravelLogTaskItemItemVM:Ctor()
    self.ImgTask = nil
    self.TextTask = ""
    self.TextLevel = ""
    self.LogID = 0
    self.ChapterID = 0
    self.PWorldID = 0
    self.IsSelected = false
    self.IsPrefixVisible = false
    self.IsPrefixFinish = false
    self.GenreID = 0
    self.DetailedGenre = ""
end

function TravelLogTaskItemItemVM:UpdateVM(Value)
    self.ImgTask = Value.ImgTask
    self.TextTask = Value.TextTask
    self.TextLevel = Value.TextLevel
    self.LogID = Value.LogID
    self.ChapterID = Value.ChapterID
    self.PWorldID = Value.PWorldID
    self.IsSelected = Value.IsSelected
    self.IsPrefixVisible = Value.IsPrefixVisible
    self.IsPrefixFinish = Value.IsPrefixFinish
    self.GenreID = Value.GenreID
    self.DetailedGenre = Value.DetailedGenre
end

return TravelLogTaskItemItemVM