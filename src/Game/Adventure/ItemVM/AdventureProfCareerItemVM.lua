--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2024-10-08 19:36:57
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-03-10 16:14:34
FilePath: \Script\Game\Adventure\ItemVM\AdventureProfCareerItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local UIBindableList = require("UI/UIBindableList")
local AdventureItemItemVM = require("Game/Adventure/ItemVM/AdventureItemItemVM")
local LootMappingCfg = require("TableCfg/LootMappingCfg")
local ItemUtil = require("Utils/ItemUtil")
local ProtoCS = require("Protocol/ProtoCS")
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS

local AdventureProfCareerItemVM = LuaClass(UIViewModel)

function AdventureProfCareerItemVM:Ctor()
    self.RewardList = UIBindableList.New(AdventureItemItemVM)
    self.SortID = nil
    self.ChapterID = nil
    self.ImgTaskIcon = nil
    self.TextTitle = nil
    self.Status = nil
    self.BtnGoVisible = nil
    self.PanelSelectVisible = nil
    self.IsNew = nil
    self.Prof = nil
    self.TextBtnGo = nil
    self.TextTypeTagVisible = nil
    self.TextTypeTag = nil
    self.ImgTask = nil
    self.FinishLootID = nil
    self.JobStateIcon = nil
    self.JobStateIconVisible = nil
    self.JobStateColor = nil
    self.Activate = false
    self.EffVisible = false
end

function AdventureProfCareerItemVM:UpdateRewardItems(LootID, Status)
    local LootMappingCfgItem = LootMappingCfg:FindCfg(string.format("ID = %d", LootID))
    if LootMappingCfgItem ~= nil then
        local LootID = LootMappingCfgItem.Programs[1].ID
        local RewardItemList = ItemUtil.GetLootItems(LootID)
        local ItemList = {}
        for _, v in ipairs(RewardItemList) do
            local Data = {}
            Data.ResID = v.ResID
            Data.IconPath = UIUtil.GetIconPath(ItemUtil.GetItemIcon(v.ResID))
            Data.NumText = _G.ScoreMgr.FormatScore(v.Num)
            Data.Num = v.Num
            Data.IsMaskVisible = Status == QUEST_STATUS.CS_QUEST_STATUS_FINISHED
            Data.IsVisible = true
            table.insert(ItemList, Data)
        end

        self.RewardList:UpdateByValues(ItemList)
    end
end

function AdventureProfCareerItemVM:UpdateVM(Params)
    self.SortID = Params.SortID
    self.ChapterID = Params.ChapterID
    self.ImgTaskIcon = Params.ImgTaskIcon
    self.TextTitle = Params.TextTitle
    self.Status = Params.Status
    self.BtnGoVisible = Params.BtnGoVisible
    self.PanelSelectVisible = Params.PanelSelectVisible
    self.JobStateIconVisible = Params.PanelSelectVisible
    self.EffVisible = Params.PanelSelectVisible
    self.JobStateColor = Params.PanelSelectVisible and "ffeebb" or "d1ba8e"
    self.IsNew = Params.IsNew
    self.Prof = Params.Prof
    self.TextBtnGo = Params.TextBtnGo
    self.TextTypeTagVisible = Params.TextTypeTagVisible
    self.TextTypeTag = Params.TextTypeTag
    self.ImgTask = Params.ImgTask
    self.FinishLootID = Params.FinishLootID
    self.JobStateIcon = Params.ImgTask
    self.Activate = Params.Activate
    if self.FinishLootID and self.Status then
        self:UpdateRewardItems(self.FinishLootID, self.Status)
    end
end

function AdventureProfCareerItemVM:IsEqualVM(Value)
	return self.ChapterID == Value.ChapterID
end

return AdventureProfCareerItemVM