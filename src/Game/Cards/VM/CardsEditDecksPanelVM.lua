--
-- Author: MichaelYang_LightPaw
-- Date: 2023-10-23 14:50
-- Description: 编辑卡组主界面的VM
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local CardsSingleCardVM = require("Game/Cards/VM/CardsSingleCardVM")
local MagicCardEditGroupFilterBtnVM = require("Game/MagicCard/VM/MagicCardEditGroupFilterBtnVM")
local MagicCardMgr = require("Game/MagicCard/MagicCardMgr")
local CardCfg = require("TableCfg/FantasyCardCfg")
local CardsGroupCardVM = require("Game/Cards/VM/CardsGroupCardVM")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local ProfType = ProtoCommon.prof_type
local RoleGender = ProtoCommon.role_gender
local LSTR = _G.LSTR
local CardTypeEnum = LocalDef.CardItemType
local FilterBtnType = LocalDef.FilterBtnType
local TotalFilterBtn = 11 -- filter btn 的总数
local AllFilterBtnResteIconPath = nil
local AllFilterBtnDefaultIconPath = nil

---@class CardsEditDecksPanelVM : UIViewModel
local CardsEditDecksPanelVM = LuaClass(UIViewModel)

---Ctor
function CardsEditDecksPanelVM:Ctor(ParentVM)
    -- self.LocalString = nil
    -- self.TextColor = nil
    -- self.ProfID = nil
    -- self.GenderID = nil
    -- self.IsVisible = nil
    self.FilteredOwnedCardList = {} -- 筛选过后卡牌的表格
    self.FilterStarList = {} -- 星级过滤
    self.FilterRaceList = {} -- 种族过滤
    self.CurrentPageNum = 1
    self.TotalPagesNumber = 1
    self.OwnedCardListToShow = 0
    self.ParentVM = ParentVM
    self:SetCardPoolFrameState(LocalDef.BGFrameState.NormalState)

    local OwnedCardListToShow = {}
    for i = 1, LocalDef.CardNumToShowInEditPanel do
        OwnedCardListToShow[i] = CardsSingleCardVM.New(self, i, LocalDef.CardItemType.OwnedCard)
    end
    self.OwnedCardListToShow = OwnedCardListToShow

    local _FilterTabDataList = {}
    -- 全部
    _FilterTabDataList[1] = MagicCardEditGroupFilterBtnVM.New(FilterBtnType.Star, 1, self, 1)
    _FilterTabDataList[1].IsSelected = true
    _FilterTabDataList[1].ImgAssetPath = "/Game/UI/Atlas/Cards/Frames/UI_Cards_Icon_All_png.UI_Cards_Icon_All_png"
    AllFilterBtnDefaultIconPath = _FilterTabDataList[1].ImgAssetPath
    AllFilterBtnResteIconPath = "/Game/UI/Atlas/Cards/Frames/UI_Cards_Icon_Reset_png.UI_Cards_Icon_Reset_png"

    -- 星级
    for i = 2, 6 do
        _FilterTabDataList[i] = MagicCardEditGroupFilterBtnVM.New(FilterBtnType.Star, i - 1, self, i)
    end
    -- 种族
    for i = 7, TotalFilterBtn do
        _FilterTabDataList[i] = MagicCardEditGroupFilterBtnVM.New(FilterBtnType.Race, i - 7, self, i)
    end

    self.EditCardChangeNotify = true
    self.EditGroupCardVM = CardsGroupCardVM.New(self, 1) -- 这里的参数是临时的，后面会从其他的地方拷贝
    local _cardGroupList = self.EditGroupCardVM.GroupCardList
    for i = 1, #_cardGroupList do
        _cardGroupList[i]:SetParentVM(self)
    end

    self.FilterTabDataList = _FilterTabDataList
    self.FilteredOwnedCardCount = 0 -- 筛选过后的卡牌数量
    self.CurrentSelectCardVM = nil -- 当前选中的卡片

    --- 这个是拖拽的
    self.DragVisualCardVM = nil
    self.DragVisualCardItemView = nil
end

--- func desc
---@param TargetVM CardsGroupCardVM
function CardsEditDecksPanelVM:SetEditGroupCardVM(TargetVM)
    if (TargetVM == nil) then
        return
    end
    self.RealCardGroupVM = TargetVM
    self.EditGroupCardVM:SimpleCopyFromOther(TargetVM)
    self:OnEditCardChangeNotify()
end

function CardsEditDecksPanelVM:OnEditCardChangeNotify()
    self.EditCardChangeNotify = not self.EditCardChangeNotify
end

function CardsEditDecksPanelVM:SetParentVM(TargetParentVM)
    self.ParentVM = TargetParentVM
end

function CardsEditDecksPanelVM:GetDragVisualCardVM()
    if (self.DragVisualCardVM == nil) then
        self.DragVisualCardVM = CardsSingleCardVM.New(self, 1, CardTypeEnum.DragVisualEdit)
    end
    return self.DragVisualCardVM
end

function CardsEditDecksPanelVM:GetDragVisualCardItemView()
    return self.DragVisualCardItemView
end

---@param DragItemVM CardsSingleCardVM
function CardsEditDecksPanelVM:OnDragDetected(DragItemVM)
    if (DragItemVM == nil) then
        return
    end

    DragItemVM:SetFrameState(LocalDef.BGFrameState.YellowState)
    DragItemVM:SetIsDisabled(true)

    -- 编辑槽里面，为空的显示蓝色
    local _cardList = self.EditGroupCardVM.GroupCardList
    for i = 1, 5 do
        if (_cardList[i]:GetCardId() <= 0) then
            _cardList[i]:SetFrameState(LocalDef.BGFrameState.BlueState)
        end
    end

    -- 这里要看一下，如果拖动的是一个编辑槽的，不是卡池的，那么显示蓝色
    if (DragItemVM.CardItemType == LocalDef.CardItemType.InfoShow) then
        self:SetCardPoolFrameState(LocalDef.BGFrameState.BlueState)
    end
end

--- func desc
---@param CardsSingleCardVM CardsSingleCardVM
function CardsEditDecksPanelVM:OnDragEnter(CardsSingleCardVM)
end

--- func desc
---@param CardsSingleCardVM CardsSingleCardVM
function CardsEditDecksPanelVM:OnDragLeave(CardsSingleCardVM)
end

function CardsEditDecksPanelVM:GetDragVisualCardScale()
    return LocalDef.ScaleForFantasyCardEditDrag
end

---@param TargetState LocalDef.CardItemType
function CardsEditDecksPanelVM:SetCardPoolFrameState(TargetState)
    self.BGFrameState = TargetState
end

function CardsEditDecksPanelVM:CanDrag(TargetCardVM)
    if TargetCardVM:GetCardId() == 0 or TargetCardVM:GetIsDisable() then
        return false
    end

    if (self.ParentVM ~= nil) then
        if (not self.ParentVM:CanDrag(TargetCardVM)) then
            return false
        end
    end

    local _dragCardType = TargetCardVM:GetCardType()
    if (_dragCardType == CardTypeEnum.OwnedCard or _dragCardType == CardTypeEnum.InfoShow) then
        return true
    end

    return false
end

--- func desc
---@param TargetCardVM CardsSingleCardVM
function CardsEditDecksPanelVM:CanCardClick(TargetCardVM)
    if (self.ParentVM ~= nil) then
        return self.ParentVM:CanCardClick(TargetCardVM)
    end
    return true
end

function CardsEditDecksPanelVM:OnDragCancelled(TargetVM)
    if (TargetVM == nil) then
        return
    end

    TargetVM:SetFrameState(LocalDef.BGFrameState.NormalState)
    TargetVM:SetIsDisabled(false)

    local _cardList = self.EditGroupCardVM.GroupCardList
    for i = 1, 5 do
        _cardList[i]:SetFrameState(LocalDef.BGFrameState.NormalState)
    end

    self:SetCardPoolFrameState(LocalDef.BGFrameState.NormalState)
    if (self.CurrentSelectCardVM ~= nil) then
        self.CurrentSelectCardVM:SetIsDisabled(false)
    end
    self.CurrentSelectCardVM = nil
    if (self.DragVisualCardItemView ~= nil) then
        self.DragVisualCardItemView:HideView()
    end
end

function CardsEditDecksPanelVM:OnClickPrePageBtn()
    if (self.CurrentPageNum > 1) then
        self:SetCurrentPageNum(self.CurrentPageNum - 1)
    end
end

function CardsEditDecksPanelVM:OnClickNextPageBtn()
    if (self.CurrentPageNum < self.TotalPagesNumber) then
        self:SetCurrentPageNum(self.CurrentPageNum + 1)
    end
end

function CardsEditDecksPanelVM:OnDrop(DropOnCardItemVM)
    -- 情况只有几种可能
    -- 1 空的
    -- 2 自己
    -- 3 已使用
    -- 4 卡池
    local _currentVM = self.CurrentSelectCardVM
    if (_currentVM == nil) then
        _G.FLOG_ERROR("CardsEditDecksPanelVM:OnDrop 出错，self.CurrentSelectCardVM 为空，请检查")
        return
    end
    local _cardList = self.EditGroupCardVM.GroupCardList
    for i = 1, 5 do
        _cardList[i]:SetFrameState(LocalDef.BGFrameState.NormalState)
        _cardList[i]:SetIsDisabled(false)
    end

    self:SetCardPoolFrameState(LocalDef.BGFrameState.NormalState)

    local _currentVM = self.CurrentSelectCardVM
    _currentVM:SetIsSelected(false)
    _currentVM:SetIsDisabled(false)
    _currentVM:SetFrameState(LocalDef.BGFrameState.NormalState)

    local _tempCardID = 0
    local _currentCardType = _currentVM:GetCardType()
    if (DropOnCardItemVM == nil) then
        if (_currentCardType ~= LocalDef.CardItemType.OwnedCard) then
            _tempCardID = _currentVM:GetCardId()
            _currentVM:SetCardId(0)
        end
    else
        if (self.CurrentSelectCardVM ~= DropOnCardItemVM) then
            local _dropCardType = DropOnCardItemVM:GetCardType()
            if (_currentCardType == LocalDef.CardItemType.InfoShow) then
                if (_dropCardType == LocalDef.CardItemType.InfoShow) then
                    -- 这里是交换
                    self:ExchangeChard(self.CurrentSelectCardVM, DropOnCardItemVM)
                elseif (_dropCardType == LocalDef.CardItemType.OwnedCard) then
                    -- 这里是取消选择
                    _tempCardID = _currentVM:GetCardId()
                    _currentVM:SetCardId(0)
                    self.CurrentSelectCardVM = nil
                end
            elseif (_currentCardType == LocalDef.CardItemType.OwnedCard) then
                if (_dropCardType == LocalDef.CardItemType.InfoShow) then
                    -- 这里将使用卡槽的ID设置一下
                    _tempCardID = DropOnCardItemVM:GetCardId()
                    DropOnCardItemVM:SetCardId(_currentVM:GetCardId())
                    self.CurrentSelectCardVM:SetIsDisabled(true)
                end
            end
        end
    end

    MagicCardMgr.CheckCardGropuIsValid(self.EditGroupCardVM)
    if (_tempCardID > 0) then
        local _poolItemVM = table.find_item(self.OwnedCardListToShow, _tempCardID, "CardId")
        if (_poolItemVM ~= nil) then
            _poolItemVM:SetIsDisabled(false)
        end
    end

    self.CurrentSelectCardVM = nil
end

function CardsEditDecksPanelVM:SetCurrentPageNum(CurrentPageNum)
    if CurrentPageNum < 1 or CurrentPageNum > self.TotalPagesNumber then
        _G.FLOG_ERROR("Wrong CurrentPageNum: [%s] max page is self.TotalPagesNumber", CurrentPageNum)
        return
    end

    self.CurrentPageNum = CurrentPageNum
    local StartIndexForCurPage = (CurrentPageNum - 1) * LocalDef.CardNumToShowInEditPanel
    for i = 1, LocalDef.CardNumToShowInEditPanel do
        local CardVm = self.OwnedCardListToShow[i]
        local IndexInAllCardList = StartIndexForCurPage + i
        if IndexInAllCardList > self.OwnedCardNumWithFilter then
            CardVm:SetCardId(0)
            CardVm:SetIsDisabled(false)
        else
            local CardId = self.FilteredOwnedCardList[IndexInAllCardList]
            CardVm:SetCardId(CardId)
            -- 已在卡组中的卡牌置灰
            local _used = table.find_item(self.EditGroupCardVM.GroupCardList, CardId, "CardId") ~= nil
            CardVm:SetIsDisabled(_used)
        end
    end
end

function CardsEditDecksPanelVM:FilterCardFunc(CardId)
    local IsFilterStar, IsFilterRace = #self.FilterStarList ~= 0, #self.FilterRaceList ~= 0
    if not IsFilterStar and not IsFilterRace then
        return true
    end

    local ItemCfg = CardCfg:FindCfgByKey(CardId)
    if ItemCfg == nil then
        _G.FLOG_ERROR("Wrong CardId: [%d]", CardId)
        return false
    end
    if not IsFilterStar then
        return table.find_item(self.FilterRaceList, ItemCfg.Race) ~= nil
    elseif not IsFilterRace then
        return table.find_item(self.FilterStarList, ItemCfg.Star) ~= nil
    else
        return table.find_item(self.FilterStarList, ItemCfg.Star) ~= nil and
                   table.find_item(self.FilterRaceList, ItemCfg.Race) ~= nil
    end
end

function CardsEditDecksPanelVM:UpdateOwnedCardListToShowWithFilter()
    self.FilteredOwnedCardList = {}
    local _totalFilterCardCount = 0
    for _, CardId in ipairs(MagicCardMgr.OwnedCardList) do
        if self:FilterCardFunc(CardId) then
            _totalFilterCardCount = _totalFilterCardCount + 1
            self.FilteredOwnedCardList[_totalFilterCardCount] = CardId
        end
    end
    self.OwnedCardNumWithFilter = _totalFilterCardCount
    if (self.OwnedCardNumWithFilter > LocalDef.CardNumToShowInEditPanel) then
        self.TotalPagesNumber = math.ceil(self.OwnedCardNumWithFilter / LocalDef.CardNumToShowInEditPanel)
    else
        self.TotalPagesNumber = 1
    end

    self.IsShowSubPageBtn = self.TotalPagesNumber > LocalDef.PageNumToShowPerSubPage

    self:SetCurrentPageNum(1)
end

function CardsEditDecksPanelVM:OnHide()
    if (self.CurrentSelectCardVM ~= nil) then
        self.CurrentSelectCardVM:SetIsSelected(false)
        self.CurrentSelectCardVM:SetFrameState(LocalDef.BGFrameState.NormalState)
        self.CurrentSelectCardVM = nil
    end
end

function CardsEditDecksPanelVM:OnEditGroupReturn(CardGroupInex, CardIDList)
    if not CardIDList or #CardIDList == 0 then
        -- 点了保存按钮后的返回
        _G.MsgTipsUtil.ShowTips(LSTR(LocalDef.UKeyConfig.CardGroupUpdate))
        _G.EventMgr:SendEvent(_G.EventID.MagicCardChangedName)
        if (self.RealCardGroupVM ~= nil) then
            self.RealCardGroupVM:SimpleCopyFromOther(self.EditGroupCardVM)
        end
    else
        -- 自动组卡结果
        if (#CardIDList ~= LocalDef.CardCountInGroup) then
            -- _G.MsgTipsUtil.ShowTips(LSTR(LocalDef.UKeyConfig.CardNumError))
            _G.FLOG_ERROR("尝试更新当前卡组卡牌，但是卡牌数量出错，请检查")
        else
            self.EditGroupCardVM:SetGroupCardList(CardIDList)
        end

        -- 这里更新一下情况，偷个懒
        self:SetCurrentPageNum(self.CurrentPageNum)
    end
end

---@param CardItemVm CardsSingleCardVM
---@return 返回是确认一下，是否选择了
function CardsEditDecksPanelVM:HandleCardClicked(CardItemVm)
    if CardItemVm == self.CurrentSelectCardVM then
        return true
    end

    local _cardItemCardID = CardItemVm:GetCardId()

    local _currentSelectCardVM = self.CurrentSelectCardVM

    if (_currentSelectCardVM ~= nil) then
        _currentSelectCardVM:SetIsSelected(false)
        _currentSelectCardVM:SetFrameState(LocalDef.BGFrameState.NormalState)
        _currentSelectCardVM:SetIsDisabled(false)
    end

    if (CardItemVm:GetCardId() <= 0 or CardItemVm:GetIsDisable()) then
        self.CurrentSelectCardVM = nil
        return false
    else
        self.CurrentSelectCardVM = CardItemVm
        CardItemVm:SetFrameState(LocalDef.BGFrameState.YellowState)
        CardItemVm:SetIsSelected(true)
        return true
    end
end

--- 传入的卡片是在什么地方，是在卡池里面，还是已经在已经编辑的 deck 里面 ,0 表示无效，1表示在卡池，2表示在编辑的deck
function CardsEditDecksPanelVM:WhereIsCard(CardItemVM)
    if (CardItemVM == nil) then
        return 0
    end

    local _cardType = CardItemVM:GetCardType()
    local _index = CardItemVM:GetIndex()
    if (_cardType == LocalDef.CardItemType.InfoShow) then
        -- 上面显示的
        for i = 1, #self.EditGroupCardVM.GroupCardList do
            if (self.EditGroupCardVM.GroupCardList[i]:GetIndex() == _index) then
                return 2
            end
        end
    elseif (_cardType == LocalDef.CardItemType.OwnedCard) then
        -- 卡池里面的
        for i = 1, #self.OwnedCardListToShow do
            if (self.OwnedCardListToShow[i]:GetIndex() == _index) then
                return 1
            end
        end
    end
end

--- 只是交换一下卡片的ID
function CardsEditDecksPanelVM:ExchangeChard(SourceCardVM, TargetCardVM)
    local _sourceCardId = SourceCardVM:GetCardId()
    local _targetCardId = TargetCardVM:GetCardId()
    SourceCardVM:SetCardId(_targetCardId)
    TargetCardVM:SetCardId(_sourceCardId)
end

--- 这里已经更改过 IsSelected = not IsSelected 了，不用再更改了
function CardsEditDecksPanelVM:OnFilterBtnClicked(FilterType, IsSelected, RaceOrStarId, Index)
    local _vmDataList = self.FilterTabDataList
    if (Index == 1) then
        if (_vmDataList[1].IsSelected) then
            -- 只有当选择全部不是 true 的时候，才进入设置
            -- 选择了全部，其他的消除掉
            _vmDataList[1].IsSelected = true
            self.FilterStarList = {} -- 清理筛选内容
            self.FilterRaceList = {} -- 清理筛选内容
            _vmDataList[1].ImgAssetPath = AllFilterBtnDefaultIconPath
            for i = 2, TotalFilterBtn do
                _vmDataList[i].IsSelected = false
            end
            self:UpdateOwnedCardListToShowWithFilter()
        end
    else
        -- 这里检查一下看是不是没有一个
        if (IsSelected) then
            if (FilterType == LocalDef.FilterBtnType.Race) then
                if (not table.find_item(self.FilterRaceList, RaceOrStarId)) then
                    table.insert(self.FilterRaceList, RaceOrStarId)
                end
            elseif (FilterType == LocalDef.FilterBtnType.Star) then
                if (not table.find_item(self.FilterStarList, RaceOrStarId)) then
                    table.insert(self.FilterStarList, RaceOrStarId)
                end
            else
                _G.FLOG_ERROR("Error, invalid filter type : " .. FilterType)
                return
            end
        else
            if (FilterType == LocalDef.FilterBtnType.Race) then
                table.remove_item(self.FilterRaceList, RaceOrStarId)
            elseif (FilterType == LocalDef.FilterBtnType.Star) then
                table.remove_item(self.FilterStarList, RaceOrStarId)
            else
                _G.FLOG_ERROR("Error, invalid filter type : " .. FilterType)
                return
            end
        end

        local _filterNotSelectCount = 0
        for i = 2, TotalFilterBtn do
            if (_vmDataList[i].IsSelected == false) then
                _filterNotSelectCount = _filterNotSelectCount + 1
            end
        end

        if (_filterNotSelectCount == TotalFilterBtn - 1) then
            if (_vmDataList[1].IsSelected == false) then
                _vmDataList[1].IsSelected = true
                _vmDataList[1].ImgAssetPath = AllFilterBtnDefaultIconPath
            end
        else
            if (_vmDataList[1].IsSelected) then
                _vmDataList[1].IsSelected = false
                _vmDataList[1].ImgAssetPath = AllFilterBtnResteIconPath
            end
        end

        self:UpdateOwnedCardListToShowWithFilter()
    end
end

-- 要返回当前类
return CardsEditDecksPanelVM
