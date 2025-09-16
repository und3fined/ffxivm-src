---
--- Author: Alex
--- DateTime: 2023-09-01 15:11:30
--- Description: 风脉泉主界面地图列表Item
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
--local UIUtil = require("Utils/UIUtil")
local UIBindableList = require("UI/UIBindableList")
local AetherCurrentTaskItemVM = require("Game/AetherCurrent/ItemVM/AetherCurrentTaskItemVM")
local AetherCurrentExploreItemVM = require("Game/AetherCurrent/ItemVM/AetherCurrentExploreItemVM")
local ProtoRes = require("Protocol/ProtoRes")
local AetherCurrentDefine = require("Game/AetherCurrent/AetherCurrentDefine")
local WindPulseSpringActivateType = ProtoRes.WindPulseSpringActivateType
---@class AetheCurrentMainItemVM : UIViewModel
local AetheCurrentMainItemVM = LuaClass(UIViewModel)

---Ctor
function AetheCurrentMainItemVM:Ctor()
    -- Main Part
    self.MapID = 0
    self.MapName = ""
    self.BannerPath = ""
    self.bFinished = false
    self.AnimInSwitch = false
    self.bSelfChecked = false
    self.QuestMarkItems = UIBindableList.New(AetherCurrentTaskItemVM)
    self.InteractMarkItems = UIBindableList.New(AetherCurrentExploreItemVM)
    self.bRootPanelVisible = false
end

function AetheCurrentMainItemVM:IsEqualVM(Value)
    return self.MapID == Value.MapID
end

function AetheCurrentMainItemVM:UpdateVM(Value)
    local UniqueID = Value.MapID
    self.Key = UniqueID
    self.MapID = UniqueID
    self.MapName = Value.MapName
    self.BannerPath = Value.BannerPath
    self.bFinished = Value.bFinished
    self.bRootPanelVisible = Value.bRootPanelVisible
    local QuestMarkDatas = Value.QuestMarkDatas
    local QuestMarkItems = self.QuestMarkItems
    if QuestMarkDatas then
        QuestMarkItems:UpdateByValues(QuestMarkDatas)
    else
        QuestMarkItems:Clear()
    end

    local InteractMarkDatas = Value.InteractMarkDatas
    local InteractMarkItems = self.InteractMarkItems
    if InteractMarkDatas then
        InteractMarkItems:UpdateByValues(InteractMarkDatas)
    else
        InteractMarkItems:Clear()
    end
end

--- 风脉泉激活后刷新界面状态
function AetheCurrentMainItemVM:UpdatePointActiveState(PointInfo)
    local MarkID = PointInfo.MarkID
    local Type = PointInfo.CurrentType
    local bFinished = PointInfo.bFinished
    if Type == WindPulseSpringActivateType.Interact then
        self:UpdateInteractMarkList(MarkID)
    elseif Type == WindPulseSpringActivateType.Task then
        self:UpdateQuestMarkList(MarkID)
    end
    local bHaveComp = self.bFinished
    if bHaveComp ~= bFinished then
        self.bFinished = bFinished
        --to do 动画特效播放,当前地图所有风脉泉点均解锁
    end
end

function AetheCurrentMainItemVM:UpdateQuestMarkList(MarkID)
    local ListItems = self.QuestMarkItems
    for i = 1, ListItems:Length() do
        local ItemVM = ListItems:Get(i)
        if ItemVM and ItemVM.QuestID == MarkID then
            ItemVM:SetItemActived()
            break
        end
    end
    --ListItems:Sort(AetherCurrentDefine.QuestMarkSortRule)
end

function AetheCurrentMainItemVM:UpdateInteractMarkList(MarkID)
    local ListItems = self.InteractMarkItems
    for i = 1, ListItems:Length() do
        local ItemVM = ListItems:Get(i)
        if ItemVM and ItemVM.ListID == MarkID then
            ItemVM:SetItemActived()
            break
        end
    end
end

return AetheCurrentMainItemVM
