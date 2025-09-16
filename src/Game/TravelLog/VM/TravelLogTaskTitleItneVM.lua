---
--- Author: sammrli
--- DateTime: 2024-02-02
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local UIBindableList = require("UI/UIBindableList")

local TravelLogTaskItemVM = require("Game/TravelLog/VM/TravelLogTaskItemVM")

local QuestHelper = require("Game/Quest/QuestHelper")

---@class TravelLogTaskTitleItneVM : UIViewModel
local TravelLogTaskTitleItneVM = LuaClass(UIViewModel)

function TravelLogTaskTitleItneVM:Ctor()
    self.Title = ""
    self.LogVMList = UIBindableList.New(TravelLogTaskItemVM)
    self.LogList = {}
    self.FirstTitleItne = false
    self.IsMarkVisible = true
    self.IsLineVisible = true
end

function TravelLogTaskTitleItneVM:UpdateVM(Value)
    self.Title = Value.Title
    self.LogList = Value.LogList
    self.FirstTitleItne = Value.FirstTitleItne
    if not self.Title or self.Title == "" then
        self.IsMarkVisible = false
        self.IsLineVisible = false
    else
        self.IsMarkVisible = true
        self.IsLineVisible = true
    end
end

function TravelLogTaskTitleItneVM:UpdateList()
    self.LogVMList:FreeAllItems()

    ---@type table<TravelTaskData>
    local AllCfg = {}
    if self.LogList then
        for _,TaskData in pairs(self.LogList) do
            table.insert(AllCfg, TaskData)
        end
    end
    -- 按等级排列
    table.sort(AllCfg, self.SortListPredicate)

    for _,TaskData in pairs(AllCfg) do
        local VM = {
            ChapterID = TaskData.ChapterID,
            ImgTask = TaskData.LogImage,
            TextTask = TaskData.QuestName,
            TextLevel = tostring(TaskData.MinLevel),
        }
        self.LogVMList:AddByValue(VM)
    end
end

function TravelLogTaskTitleItneVM.SortListPredicate(Left, Right)
    return Left.MinLevel < Right.MinLevel
end

function TravelLogTaskTitleItneVM:SetSelectedTaskItne(LogID)
    local Length = self.LogVMList:Length()
    for i=1, Length do
        local VM = self.LogVMList:Get(i)
        VM.IsSelected = VM.LogID == LogID
    end
end

return TravelLogTaskTitleItneVM