---
--- Author: frankjfwang
--- DateTime: 2022-05-15 19:01
--- Description:
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local MagicCardVMUtils = require("Game/MagicCard/MagicCardVMUtils")
local MagicCardCardItemVM = require("Game/MagicCard/VM/MagicCardCardItemVM")
local MagicCardEditGroupFilterBtnVM = require("Game/MagicCard/VM/MagicCardEditGroupFilterBtnVM")
local EventID = require("Define/EventID")
local Log = require("Game/MagicCard/Module/Log")
local CardCfg = require("TableCfg/FantasyCardCfg")
local CardTypeEnum = LocalDef.CardItemType
local FilterBtnType = LocalDef.FilterBtnType
local LSTR = _G.LSTR
local EventMgr = _G.EventMgr
local MagicCardMgr = _G.MagicCardMgr

local ClickSoundEffectEnum = LocalDef.ClickSoundEffectEnum

---@class MagicCardGroupEditItemVM : UIViewModel
---@field __ParentVm MagicCardMatchStartVM
---@field GroupCardList MagicCardCardItemVM[]
---@field OwnedCardListToShow MagicCardCardItemVM[]
---@field DragVisualCard MagicCardCardItemVM
---@field CurrentSubPageNum integer @SubPageNum是指通过界面上翻页按钮操作，将TotalPages再进行分页后的当前页数
---@field CurrentShowPageIndexWrapped integer @经过SubPage分页后经过wrap的index，从1开始
local MagicCardGroupEditItemVM = LuaClass(UIViewModel)

function MagicCardGroupEditItemVM:Ctor(ParentVm, Index)
    self.__Index = Index
    self.__ParentVm = ParentVm
    self.GroupName = self:GetDefaultGroupName()
    self.IsReadyToEdit = false
    self.IsSelectedToBattle = false
    self.IsDefaultGroup = false
    self.IsAutoGroup = Index == 0
    local GroupCardList = {}
    for i = 1, 5 do
        GroupCardList[i] = MagicCardCardItemVM.New(CardTypeEnum.RewardCard, {
            IndexInList = i
        })
    end
    self.GroupCardList = GroupCardList
    self.IsShowRuleHelpDesc = false

    local OwnedCardListToShow = {}
    for i = 1, LocalDef.CardNumToShowPerPage do
        OwnedCardListToShow[i] = MagicCardCardItemVM.New(CardTypeEnum.OwnedCard, {
            EditingVm = self
        })
    end
    self.OwnedCardListToShow = OwnedCardListToShow
    self.OwnedCardNumWithFilter = 0
    self.ShowPageList = nil
    self.IsShowSubPageBtn = false
    self.TotalPagesToShow = 1
    self.CurrentSubPageNum = 1
    self.CurrentShowPageIndexWrapped = 1
    self.__CurrentShowPage = 1

    self.__FilteredOwnedCardList = {}

    self.DragVisualCard = MagicCardCardItemVM.New(CardTypeEnum.DragVisualEdit)
    self.DragVisualCard:SetEditingVm(self)

    self.__FiterStarList = {}
    self.__FilterRaceList = {}
    self.FilteringType = FilterBtnType.Star

    -- 这里避免读表，RaceId, StarId就写死了。RaceId:[0..4], StarId:[1..5]
    local FilterStarBtnList = {}
    local FilterRaceBtnList = {}
    for i = 1, 5 do
        FilterStarBtnList[i] = MagicCardEditGroupFilterBtnVM.New(FilterBtnType.Star, i, self)
        FilterRaceBtnList[i] = MagicCardEditGroupFilterBtnVM.New(FilterBtnType.Race, i - 1, self)
    end
    self.FilterStarBtnList = FilterStarBtnList
    self.FilterRaceBtnList = FilterRaceBtnList

    self.LastSelectedOwnedCard = nil
    self.LastSelectedCardInGroup = nil

    -- 规则
    self.CheckRuleCardNum = true
    self.CheckRuleFiveStarCard = true
    self.CheckRuleFourStarCard = true
    self.IsAllRulePass = true
end

function MagicCardGroupEditItemVM:SyncContentFromOther(OtherEditItemVm)
    if not OtherEditItemVm then
        return
    end
    -- only "Content"
    self.GroupName = OtherEditItemVm.GroupName
    local OtherGroupCardList = {}
    for i = 1, 5 do
        OtherGroupCardList[i] = OtherEditItemVm.GroupCardList[i].CardId
    end
    self:SetGroupCardList(OtherGroupCardList)
end

function MagicCardGroupEditItemVM:OnSelectItemToBattle()
    self.__ParentVm:SelectItemToBattle(self)
end

function MagicCardGroupEditItemVM:OnSetAsDefaultGroup()
    self.__ParentVm:SetItemAsDefaultGroup(self, true)
end

function MagicCardGroupEditItemVM:OnOpenEditGroup()
    self.__ParentVm:OnEditGroup()
end

function MagicCardGroupEditItemVM:GetIndex()
    return self.__Index
end

function MagicCardGroupEditItemVM:GetServerIndex()
    return self.__Index - 1
end

function MagicCardGroupEditItemVM:GetDefaultGroupName()
    return string.format(LSTR(LocalDef.UKeyConfig.CardGroupName), self.__Index)
end

function MagicCardGroupEditItemVM:SetGroupCardList(CardList)
    for i, CardId in ipairs(CardList) do
        self.GroupCardList[i]:SetCardId(CardId)
    end
    MagicCardMgr.CheckCardGropuIsValid(self)
end

function MagicCardGroupEditItemVM:OnEditGroup()
    -- 进入编辑模式
    for _, CardVm in ipairs(self.GroupCardList) do
        -- 显示卡牌名称
        CardVm.IsShowCardName = CardVm.CardId ~= 0
        -- 设置EditingVm
        CardVm:SetEditingVm(self)
    end

    for _, CardVm in ipairs(self.OwnedCardListToShow) do
        if CardVm then
            CardVm:SetEditingVm(self)
        end
    end

    self:UpdateOwnedCardListToShowWithFilter()
end

function MagicCardGroupEditItemVM:OnCloseEditGroup()
    -- 退出编辑模式
    for _, CardVm in ipairs(self.GroupCardList) do
        if CardVm then
            -- 隐藏卡牌名称
            CardVm.IsShowCardName = false
            -- 清空EditingVm
            CardVm:SetEditingVm()
        end
    end

    -- 清空EditingVm，防止额外引用
    for _, CardVm in ipairs(self.OwnedCardListToShow) do
        if CardVm then
            CardVm:SetEditingVm()
        end
    end
end

---@param CardVm MagicCardCardItemVM
local function FilterCardFunc(CardId, FilterStarList, FilterRaceList)
    FilterStarList = FilterStarList or {}
    FilterRaceList = FilterRaceList or {}

    local IsFilterStar, IsFilterRace = #FilterStarList ~= 0, #FilterRaceList ~= 0
    if not IsFilterStar and not IsFilterRace then
        return true
    end

    local ItemCfg = CardCfg:FindCfgByKey(CardId)
    if ItemCfg == nil then
        Log.E("Wrong CardId: [%d]", CardId)
        return false
    end
    if not IsFilterStar then
        return table.find_item(FilterRaceList, ItemCfg.Race) ~= nil
    elseif not IsFilterRace then
        return table.find_item(FilterStarList, ItemCfg.Star) ~= nil
    else
        return table.find_item(FilterStarList, ItemCfg.Star) ~= nil and table.find_item(FilterRaceList, ItemCfg.Race) ~=
                   nil
    end
end

function MagicCardGroupEditItemVM:SetCurrentSubPageNum(CurrentSubPage)
    if CurrentSubPage < 1 or CurrentSubPage > self:GetMaxSubPageNum() then
        Log.E("Wrong CurrentSubPage: [%s]", CurrentSubPage)
        return
    end

    self.CurrentSubPageNum = CurrentSubPage
    local StartIndex = (CurrentSubPage - 1) * LocalDef.PageNumToShowPerSubPage
    local PageList = {}
    for i = 1, LocalDef.PageNumToShowPerSubPage do
        local PageNum = StartIndex + i
        if PageNum > self.TotalPagesToShow then
            break
        end
        PageList[i] = PageNum
    end

    Log.I("CurrentSubPage [%d], StartPageIndex [%d] EndPageIndex [%s]", CurrentSubPage, StartIndex, PageList[#PageList])
    self.ShowPageList = PageList

    self:SetCurrentShowPageIndexWrapped(1)
end

function MagicCardGroupEditItemVM:GetMaxSubPageNum()
    local Num, Left = math.modf(self.TotalPagesToShow / LocalDef.PageNumToShowPerSubPage)
    return Left == 0.0 and Num or Num + 1
end

function MagicCardGroupEditItemVM:SetCurrentShowPageIndexWrapped(CurrentShowPageIndexWrapped)
    self.CurrentShowPageIndexWrapped = CurrentShowPageIndexWrapped

    self.__CurrentShowPage = (self.CurrentSubPageNum - 1) * LocalDef.PageNumToShowPerSubPage +
                                 CurrentShowPageIndexWrapped
    print("CurrentShowPage", self.__CurrentShowPage, "TotalPages", self.TotalPagesToShow)

    local StartIndexForCurPage = (self.__CurrentShowPage - 1) * LocalDef.CardNumToShowPerPage
    for i = 1, LocalDef.CardNumToShowPerPage do
        local CardVm = self.OwnedCardListToShow[i]
        local IndexInAllCardList = StartIndexForCurPage + i
        if IndexInAllCardList > self.OwnedCardNumWithFilter then
            CardVm:SetCardId(0)
        else
            local CardId = self.__FilteredOwnedCardList[IndexInAllCardList]
            CardVm:SetCardId(CardId)
            -- 已在卡组中的卡牌置灰
            CardVm.CardDisable = table.find_item(self.GroupCardList, CardId, "CardId") ~= nil
        end
    end
end

function MagicCardGroupEditItemVM:UpdateOwnedCardListToShowWithFilter()
    self.__FilteredOwnedCardList, self.OwnedCardNumWithFilter = {}, 0
    for _, CardId in ipairs(MagicCardMgr.OwnedCardList) do
        if FilterCardFunc(CardId, self.__FiterStarList, self.__FilterRaceList) then
            self.OwnedCardNumWithFilter = self.OwnedCardNumWithFilter + 1
            self.__FilteredOwnedCardList[self.OwnedCardNumWithFilter] = CardId
        end
    end
    self.TotalPagesToShow = math.modf(self.OwnedCardNumWithFilter / LocalDef.CardNumToShowPerPage) + 1

    self.IsShowSubPageBtn = self.TotalPagesToShow > LocalDef.PageNumToShowPerSubPage

    self:SetCurrentSubPageNum(1)

    -- local ValidCardNum = #ResList
    -- local PlaceHolderNeededNum = LocalDef.CardNumToShowPerPage - ValidCardNum
    -- for j=1, PlaceHolderNeededNum do
    --     self.__PlaceHolderCardFreeList = self.__PlaceHolderCardFreeList or {}
    --     local PlaceHolderCard = self.__PlaceHolderCardFreeList[j]
    --     if not PlaceHolderCard then
    --         PlaceHolderCard = MagicCardCardItemVM.New(CardTypeEnum.OwnedCard, {EditingVm = self})
    --         self.__PlaceHolderCardFreeList[j] = PlaceHolderCard
    --     end
    --     ResList[ValidCardNum+j] = PlaceHolderCard
    -- end

    -- self.OwnedCardListToShow = ResList
    -- for _, CardVm in ipairs(self.OwnedCardListToShow) do
    --     CardVm:SetEditingVm(self)
    -- end
    -- self.OwnedCardNumWithFilter = ValidCardNum

    self.LastSelectedCardInGroup = nil
    self.LastSelectedOwnedCard = nil
end

function MagicCardGroupEditItemVM:CloseEditGroup()
    self.__ParentVm:OnCloseEditGroup()
end

function MagicCardGroupEditItemVM:SaveEditGroup()
    -- TODO: check rules
    self.__ParentVm:OnSaveEditGroup()
end

function MagicCardGroupEditItemVM:OnClearAllFilter()
    local FilterListToClear
    if self.FilteringType == FilterBtnType.Star then
        FilterListToClear = self.FilterStarBtnList
        self.__FiterStarList = {}
    else
        FilterListToClear = self.FilterRaceBtnList
        self.__FilterRaceList = {}
    end

    for _, FilterBtnVm in ipairs(FilterListToClear) do
        FilterBtnVm.IsSelected = false
    end

    self:UpdateOwnedCardListToShowWithFilter()
end

function MagicCardGroupEditItemVM:OnFilterBtnClicked(FilterType, IsSetOrUnset, RaceOrStarId)
    local function SetOrUnsetFilterList(SetOrUnset, FilterList, FilterElement)
        if SetOrUnset then
            local FilterListLen = #FilterList
            for i = 1, FilterListLen do
                if FilterList[i] == FilterElement then
                    return
                end
            end
            FilterList[FilterListLen + 1] = FilterElement
        else
            table.remove_item(FilterList, FilterElement)
        end
    end

    if FilterType == FilterBtnType.Race then
        SetOrUnsetFilterList(IsSetOrUnset, self.__FilterRaceList, RaceOrStarId)
    elseif FilterType == FilterBtnType.Star then
        SetOrUnsetFilterList(IsSetOrUnset, self.__FiterStarList, RaceOrStarId)
    end

    self:UpdateOwnedCardListToShowWithFilter()
end

---@param CardInGroup MagicCardCardItemVM 编辑卡组内的卡
---@param OwnedCard MagicCardCardItemVM 展示区的卡
function MagicCardGroupEditItemVM:ExchangeCard(CardInGroup, OwnedCard)
    if not CardInGroup or not OwnedCard then
        Log.E("MagicCardGroupEditItemVM:ExchangeCard() error data")
        return
    end

    Log.I("ExchangeCard: CardInGroup index [%d], OwnedCard index [%d]", CardInGroup.IndexInList, OwnedCard.IndexInList)
    if not OwnedCard.CardDisable then
        -- 处理“编辑到卡组内的卡牌，需要在卡池中置灰”逻辑
        if CardInGroup.CardId ~= 0 then
            local FoundCard = table.find_item(self.OwnedCardListToShow, CardInGroup.CardId, "CardId")
            if FoundCard then
                FoundCard.CardDisable = false
            end
        end
        if OwnedCard.CardId ~= 0 then
            OwnedCard.IsVisible = true
            OwnedCard.IsPlayedBGVisible = true
            OwnedCard.CardDisable = true
        end

        CardInGroup:SetCardId(OwnedCard.CardId)
        CardInGroup.IsShowCardName = CardInGroup.CardId ~= 0
    else
        CardInGroup.IsVisible = true
        CardInGroup.IsPlayedBGVisible = true
    end

    self.LastSelectedCardInGroup = nil
    self.LastSelectedOwnedCard = nil

    EventMgr:SendEvent(EventID.MagicCardPlayCardClickSound, ClickSoundEffectEnum.Put)

    MagicCardMgr.CheckCardGropuIsValid(self)
end

---@param CardItemVm MagicCardCardItemVM
function MagicCardGroupEditItemVM:OnSelectOwnedCard(CardItemVm)
    print("OnSelectOwnedCard: ", CardItemVm.IndexInList)
    if CardItemVm == self.LastSelectedOwnedCard then
        CardItemVm.IsVisible = true
        CardItemVm.IsPlayedBGVisible = true
        self.LastSelectedOwnedCard = nil
        EventMgr:SendEvent(EventID.MagicCardPlayCardClickSound, ClickSoundEffectEnum.Cancel)
        return
    end

    if not self.LastSelectedCardInGroup then
        Log.I("未在卡组中选择，只记录当前选择的OwnedCard")
        if self.LastSelectedOwnedCard then
            self.LastSelectedOwnedCard.IsVisible = true
            self.LastSelectedOwnedCard.IsPlayedBGVisible = true
        end
        if CardItemVm.CardId == 0 or CardItemVm.CardDisable then
            self.LastSelectedOwnedCard = nil
        else
            CardItemVm.IsVisible = true
            CardItemVm.IsPlayedBGVisible = true
            self.LastSelectedOwnedCard = CardItemVm
        end
        EventMgr:SendEvent(EventID.MagicCardPlayCardClickSound, ClickSoundEffectEnum.Select)
    else
        self:ExchangeCard(self.LastSelectedCardInGroup, CardItemVm)
    end
end

---@param CardItemVm MagicCardCardItemVM
function MagicCardGroupEditItemVM:OnSelectCardInGroup(CardItemVm)
    print("OnSelectCardInGroup: ", CardItemVm.IndexInList)
    if not self.LastSelectedOwnedCard then
        if CardItemVm.CardId == 0 then
            if self.LastSelectedCardInGroup then
                if self.LastSelectedCardInGroup.CardId ~= 0 then
                    Log.I("先点击了卡组中的卡牌[%d]再点击了卡组中的空位，移动",
                        self.LastSelectedCardInGroup.IndexInList)
                    CardItemVm:SetCardId(self.LastSelectedCardInGroup.CardId)
                    self.LastSelectedCardInGroup:SetCardId(0)
                    EventMgr:SendEvent(EventID.MagicCardPlayCardClickSound, ClickSoundEffectEnum.Put)
                end
            end
            self.LastSelectedCardInGroup = nil
            return
        end

        if self.LastSelectedCardInGroup then
            if self.LastSelectedCardInGroup == CardItemVm then
                EventMgr:SendEvent(EventID.MagicCardPlayCardClickSound, ClickSoundEffectEnum.Cancel)
                CardItemVm.IsVisible = true
                CardItemVm.IsPlayedBGVisible = true
            else
                Log.I("前后分别点击卡牌[%d] [%d]，交换位置", self.LastSelectedCardInGroup.IndexInList,
                    CardItemVm.IndexInList)
                EventMgr:SendEvent(EventID.MagicCardPlayCardClickSound, ClickSoundEffectEnum.Put)
                local LastSectectedCardId = self.LastSelectedCardInGroup.CardId
                self.LastSelectedCardInGroup:SetCardId(CardItemVm.CardId)
                CardItemVm:SetCardId(LastSectectedCardId)
            end
            self.LastSelectedCardInGroup = nil
        else
            self.LastSelectedCardInGroup = CardItemVm
            if CardItemVm.CardId ~= 0 then
                CardItemVm.IsVisible = true
                CardItemVm.IsPlayedBGVisible = true
            end
            EventMgr:SendEvent(EventID.MagicCardPlayCardClickSound, ClickSoundEffectEnum.Select)
        end
    else
        self:ExchangeCard(CardItemVm, self.LastSelectedOwnedCard)
    end
end

--- 当前处理MouseDown/Drag的顺序，一定是先选中了卡牌再移动，所以这里判断是否要移动的卡牌就是选中的那张
---@param ItemVm MagicCardCardItemVM
function MagicCardGroupEditItemVM:CanDrag(ItemVm)
    if ItemVm.CardItemType == CardTypeEnum.RewardCard then
        return self.LastSelectedCardInGroup == ItemVm
    elseif ItemVm.CardItemType == CardTypeEnum.OwnedCard then
        return self.LastSelectedOwnedCard == ItemVm
    end
    return false
end

return MagicCardGroupEditItemVM
