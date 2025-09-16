---
---@author Carl
---DateTime: 2023-09-12 19:17:13
---Description:幻卡筛选VM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local MagicCardLocalDef = require("Game/MagicCard/MagicCardLocalDef")
local MagicCardCollectionDefine = require("Game/MagicCardCollection/MagicCardCollectionDefine")
local MagicCardFilterItemVM = require("Game/MagicCardCollection/VM/ItemVM/MagicCardFilterItemVM")
--local MagicCardCollectionMgr = require("Game/MagicCardCollection/MagicCardCollectionMgr")
local MagicCardCollectionDefine = require("Game/MagicCardCollection/MagicCardCollectionDefine")


---@class MagicCardFilterVM : UIViewModel
---@field CardGetWayList table @获取方式列表
---
---@field MagicCardName string @幻卡名字
---@field MagicCardID string @幻卡编号
---@field MagicCardIntroduction string @幻卡介绍
---@field MagicCardQuantity number @幻卡累计数量
---@field MagicCardBigIcon string @幻卡图片路径

local FilterBtnType = MagicCardLocalDef.FilterBtnType
local MagicCardFilterVM = LuaClass(UIViewModel)

function MagicCardFilterVM:Ctor()
    self.SelectedUnlockType = MagicCardCollectionDefine.CardUnlockFilter.All
    self.SelectedStar = MagicCardCollectionDefine.CardStarFilter.All
    self.SelectedRace = MagicCardCollectionDefine.CardRaceFilter.All
    self.FilterInfo =
    {
        SelectedFilterUnlock = nil,
        SelectedFilterStarList = {},
        SelectedFilterRaceList = {},
    }
    self.FilterInfoTemp =
    {
        SelectedFilterUnlock = nil,
        SelectedFilterStarList = {},
        SelectedFilterRaceList = {},
    }
    self.FiterStarList = {}
    self.FilterRaceList = {}
    -- 这里避免读表，RaceId, StarId就写死了。RaceId:[0..4], StarId:[1..5]
    local FilterStarBtnList = {}
    local FilterRaceBtnList = {}
    for i=1, 5 do
        FilterStarBtnList[i] = MagicCardFilterItemVM.New(FilterBtnType.Star, i, self)
        FilterRaceBtnList[i] = MagicCardFilterItemVM.New(FilterBtnType.Race, i-1, self)
    end
    self.FilterStarBtnList = FilterStarBtnList
    self.FilterRaceBtnList = FilterRaceBtnList
end

function MagicCardFilterVM:OnInit()

end

function MagicCardFilterVM:OnShutdown()
    self.CardGetWayList:Clear()
end

function MagicCardFilterVM:OnSelectAllCard()
    self.FilterInfoTemp.SelectedFilterUnlock = nil
end

function MagicCardFilterVM:OnSelectFilterUnlock()
    self.FilterInfoTemp.SelectedFilterUnlock = true
end

function MagicCardFilterVM:OnSelectFilterlock()
    self.FilterInfoTemp.SelectedFilterUnlock = false
end

function MagicCardFilterItemVM:OnFilterBtnClickedAllStar()
    if self.FilterInfoTemp and self.FilterInfoTemp.SelectedFilterStarList then
        self.FilterInfoTemp.SelectedFilterStarList = {}
    end

    if self.FilterStarBtnList or next(self.FilterStarBtnList) == nil then
        return
    end
    for _, StarBtnVM in ipairs(self.FilterStarBtnList) do
        StarBtnVM.IsSelected = false
    end
end

function MagicCardFilterItemVM:OnFilterBtnClickedAllRace()
    if self.FilterInfoTemp and self.FilterInfoTemp.SelectedFilterRaceList then
        self.FilterInfoTemp.SelectedFilterRaceList = {}
    end

    if self.FilterRaceBtnList or next(self.FilterRaceBtnList) == nil then
        return
    end

    for _, RaceBtnVM in ipairs(self.FilterRaceBtnList) do
        RaceBtnVM.IsSelected = false
    end
end

function MagicCardFilterItemVM:OnFilterBtnClicked(FilterType, IsSetOrUnset, RaceOrStarId)
    if self.FilterInfoTemp == nil then
        return
    end

    local function SetOrUnsetFilterList(FilterList, SetOrUnset, FilterElement)
        if SetOrUnset then
            local FindRace = table.find_item(FilterList, FilterElement)
            if FindRace == nil then
                table.insert(FilterList, FilterElement)
            end
        else
            table.remove_item(FilterList, FilterElement)
        end
    end

    local FilterRaceList = self.FilterInfoTemp.SelectedFilterRaceList
    local FilterStarList = self.FilterInfoTemp.SelectedFilterStarList
    if FilterType == FilterBtnType.Race then
        SetOrUnsetFilterList(FilterRaceList, IsSetOrUnset, RaceOrStarId)
    elseif FilterType == FilterBtnType.Star then
        SetOrUnsetFilterList(FilterStarList, IsSetOrUnset, RaceOrStarId)
    end
end

---@type 将临时筛选条件保存
function MagicCardFilterVM:OnConfirmFilt()
    self.FilterInfo.SelectedFilterUnlock = self.FilterInfoTemp.SelectedFilterUnlock
    self.FilterInfo.SelectedFilterStarList = self.FilterInfoTemp.SelectedFilterStarList
    self.FilterInfo.SelectedFilterRaceList = self.FilterInfoTemp.SelectedFilterRaceList
end

return MagicCardFilterVM
