--[[
Author: luojiewen_ds luojiewen@dasheng.tv
Date: 2024-05-09 10:32:21
LastEditors: luojiewen_ds luojiewen@dasheng.tv
LastEditTime: 2024-08-02 15:39:00
FilePath: \Script\Game\Interactive\View\New\NpcDialogueHistoryVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
--[[
Author: luojiewen_ds luojiewen@dasheng.tv
Date: 2024-04-18 14:42:24
LastEditors: luojiewen_ds luojiewen@dasheng.tv
LastEditTime: 2024-04-18 15:00:28
FilePath: \Script\Game\Interactive\View\New\NpcDialogueHistoryVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local StoryDefine = require("Game/Story/StoryDefine")

---@class NpcDialogHistoryVM : UIViewModel
local NpcDialogHistoryVM = LuaClass(UIViewModel)

---Ctor
function NpcDialogHistoryVM:Ctor()
    self.HistoryDialogList = {}
    self.HistoryQuestList = {}
    print("NpcDialogHistoryVM:Ctor")
end

---@param HistoryItem StoryDefine.DialogHistoryClass
function NpcDialogHistoryVM:InsertHistoryItem(HistoryItem)
    if not (HistoryItem and next(HistoryItem)) then return end
    -- if HistoryItem.ContentType == StoryDefine.ContentType.Choice and not next(self.HistoryDialogList) then return end

    if HistoryItem.DialogType == StoryDefine.DialogType.Dialog then
        if self.HistoryDialogList and next(self.HistoryDialogList) then
            self.HistoryDialogList[#self.HistoryDialogList].bNew = false
        end
        table.insert(self.HistoryDialogList, HistoryItem)
        HistoryItem.bNew = true
        HistoryItem.Index = #self.HistoryDialogList

    else
        if self.HistoryQuestList and next(self.HistoryQuestList) then
            self.HistoryQuestList[#self.HistoryQuestList].bNew = false
        end
        table.insert(self.HistoryQuestList, HistoryItem)
        HistoryItem.bNew = true
        HistoryItem.Index = #self.HistoryQuestList
    end
end

function NpcDialogHistoryVM:ClearHistoryData(IsClearGuestData)
    if IsClearGuestData then
        self.HistoryQuestList = {}
    end
    self.HistoryDialogList = {}
    print("NpcDialogHistoryVM:ClearHistoryData")
end

function NpcDialogHistoryVM:CheckCanClearQuestData()
    --todo 这里检查记录的任务目标是否完成
    return false
end
return NpcDialogHistoryVM