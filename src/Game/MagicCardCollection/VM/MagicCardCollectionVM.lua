--
-- Author: Carl
-- Date: 2023-09-08 16:57:14
-- Description:幻卡图鉴VM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ProtoRes = require("Protocol/ProtoRes")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local FantasyCardCfg = require("TableCfg/FantasyCardCfg")
local CollectionAwardCfg = require("TableCfg/FantasyCardCollectionAwardCfg")
local MagicCardListItemVM = require("Game/MagicCardCollection/VM/ItemVM/MagicCardListItemVM")
local MagicCardCollectionDefine = require("Game/MagicCardCollection/MagicCardCollectionDefine")
local GlobalCfg = require("TableCfg/GlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")

---@class MagicCardCollectionVM : UIViewModel
---@field MagicCardVMList table @幻卡图鉴列表
---@field IsSearchEmpty boolean @是否搜索结果为空
---@field MagicCardTotalCollectNum number @幻卡收藏玩家总数
---@field MagicCardTotalNum number @幻卡总数
---@field MagicCardUnlockNum number @幻卡已解锁数量
---@field CardIndex number @幻卡编号
---
local MagicCardCollectionVM = LuaClass(UIViewModel)

function MagicCardCollectionVM:Ctor()
   
end

function MagicCardCollectionVM:OnInit()
    self.IsSearchEmpty = false
    self.IsCheckLocked = false
    self.CanGetAward = false --是否可领奖
    self.MagicCardTotalCollectNum = 0
    self.MagicCardUnlockNum = 0
    self.MagicCardTotalNum = 0
    self.CardIndex = 0 
    self.CollectPercent = 0
    self.MagicCardUnlockPercent = 0
    self.AllMagicCardMap = {}
    self.AllMagicCardList = {}
    self.UnLockCardList = {}
    self.NewUnlockCardList = {} --新解锁幻卡
    self.CurSelectedCard = {}
    self.CollectAwardProgressList = {}
    self.SearchEmptyText = MagicCardCollectionDefine.SearchEmptyText
    self.MagicCardUnlockNumText = ""
    self.CurCardIndexNumText = string.format(MagicCardCollectionDefine.CardNumText, self.CardIndex)
    self.MagicCardTotalCollectNumText = string.format(MagicCardCollectionDefine.CardCollectPlayerNumText, self.MagicCardTotalCollectNum)
    self.CurMagicCardList = {}
    self.MagicCardVMList = UIBindableList.New(MagicCardListItemVM)
    self.SelectedCardIndex = 0
end

function MagicCardCollectionVM:OnBegin()
    self:InitAllMagicCard()

    local CollectAwardList = CollectionAwardCfg:FindAllCfg()
    for _, AwardCfg in ipairs(CollectAwardList) do
		local AwardData = {
            CollectNum = AwardCfg.Num,
            AwardID = AwardCfg.ItemID[1],
            AwardNum = AwardCfg.ItemNum[1],
            IsCollectedAward = false,
        }
        table.insert(self.CollectAwardProgressList, AwardData)
	end
end

function MagicCardCollectionVM:OnEnd()
end

function MagicCardCollectionVM:OnShutdown()
    self.IsSearchEmpty = false
    self.MagicCardTotalCollectNum = 0
    self.MagicCardUnlockNum = 0
end

function MagicCardCollectionVM:InitAllMagicCard()
    self.AllMagicCardMap = {}
    local CfgList = FantasyCardCfg:FindAllCfg()
    local GlobalVersion = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_GAME_VERSION) or {Value = {2, 0, 0}}
	for _, CfgItem in ipairs(CfgList) do
        local PatchMask = {}
        local SplitStrList = string.split(CfgItem.Mask, ".")
        if (SplitStrList ~= nil and #SplitStrList == 3) then
            PatchMask = {
                tonumber(SplitStrList[1]),
                tonumber(SplitStrList[2]),
                tonumber(SplitStrList[3])
            }
        else
            _G.FLOG_ERROR("幻卡的版本参数不是3个，不符合要求，将使用默认数值 2.0.0 ，请检查")
            PatchMask = {2,0,0}
        end

        if (PatchMask[1] <= GlobalVersion.Value[1] and PatchMask[2] <= GlobalVersion.Value[2] and PatchMask[3] <= GlobalVersion.Value[3]) then
            local CardData = {
                IsUnLock = false, 
                CardID = CfgItem.ID,
                FrameType = CfgItem.FrameType,
                Num = CfgItem.Num,
                Name = CfgItem.Name,
                IsNewUnlock = false,
            }

            self.AllMagicCardMap[CardData.CardID] = CardData
            table.insert(self.AllMagicCardList, CardData)
        end
    end
    table.sort(self.AllMagicCardList, function(a, b) 
        if a.FrameType == b.FrameType then
            return a.Num < b.Num
        end
        return a.FrameType < b.FrameType
    end)
    self.MagicCardTotalNum = table.length(self.AllMagicCardList)
end

function MagicCardCollectionVM:GetCollectProgressInfo()
    local CollectInfo = {
        CollectedNum = self.MagicCardUnlockNum,
        MaxCollectNum = self.MagicCardTotalNum,
        AwardList = self.CollectAwardProgressList,
    }
 
    return CollectInfo
end

function MagicCardCollectionVM:OnMagicCardSelected(CardIndex)
    self.CardIndex = CardIndex
    if self.CardIndex then
        self.CurCardIndexNumText = string.format(MagicCardCollectionDefine.CardNumText, self.CardIndex)
    end
    self.SelectedCardIndex = self.CardIndex
    self:RemoveRedDot(CardIndex)
    self:UpdateCardDetail(CardIndex)
end

function MagicCardCollectionVM:UpdateCardDetail(CardIndex)
    if self.CurMagicCardList == nil or #self.CurMagicCardList <= 0 then
        return
    end
    local SelectCardData = self.CurMagicCardList[CardIndex]
    if SelectCardData == nil then
        return
    end

    self.CurSelectedCard = SelectCardData

    local NumText = MagicCardCollectionDefine.CardNumText
    if SelectCardData.FrameType == ProtoRes.fantasy_card_frame_type.FRAME_TYPE_PLATINUM then
        NumText = MagicCardCollectionDefine.CardNumSpecialText
    end
    local CardNum = SelectCardData.Num
    if CardNum then
        self.CurCardIndexNumText = string.format(NumText, CardNum)
    end
end

function MagicCardCollectionVM:RemoveRedDot(CardIndex)
    local SelectCardData = self.CurMagicCardList[CardIndex]
    if SelectCardData == nil then
        return
    end
    self:RemoveNewUnLockCard(SelectCardData.CardID)
    for _, CardData in ipairs(self.AllMagicCardList) do
        if SelectCardData.CardID == CardData.CardID then
            CardData.IsNewUnlock = false
        end 
    end
end

function MagicCardCollectionVM:UpdateCurSelectCardCollection(CollectionInfo)
    if CollectionInfo == nil then
        return
    end 
    --local CardID = CollectionInfo.CardID
    --local IsUnLock = self:IsCardUnLock(CardID)
    self.MagicCardTotalCollectNum = CollectionInfo.CollectionRoleCount or 0
    self.PlayerCollectNum = CollectionInfo.CollectionTimes or 0
    self.MagicCardTotalCollectNumText = string.format(MagicCardCollectionDefine.CardCollectPlayerNumText, self.PlayerCollectNum)
    self.ActiveRoleCount = CollectionInfo.ActiveRoleCount
    if self.ActiveRoleCount > 0 and self.MagicCardTotalCollectNum > 0 then
        self.CollectPercent = math.floor((self.MagicCardTotalCollectNum / self.ActiveRoleCount) * 100 + 0.5) -- 4舍5入
        self.CollectPercent = math.clamp(self.CollectPercent, 1, 100)
    else
        self.CollectPercent = 0
    end
end

function MagicCardCollectionVM:TrySelectTargetCard(InCardID)
    if (self.MagicCardVMList == nil) then
        return
    end

    if (InCardID == nil) then
        return
    end

    local Items = self.MagicCardVMList.Items

    for Key, Value in pairs(Items) do
        if (Value.CardID == InCardID) then
            self.SelectedCardIndex = Key
            break
        end
    end
end

---@type 更新解锁幻卡数据
---@param UnLockCardList table 解锁幻卡数据
function MagicCardCollectionVM:UpdateUnLockMagicCardList(UnLockCardList, IsUpdateAllUnlockCard)
    if IsUpdateAllUnlockCard then
        --增量更新
        self:UpdateNewUnLockCardList(UnLockCardList)
    end

    --local IsFirstUpdate = self.UnLockCardList == nil or table.length(self.UnLockCardList) <= 0
    if UnLockCardList and next(UnLockCardList) ~= nil then
        for _, UnLockCardID in ipairs(UnLockCardList) do
            if self.AllMagicCardMap == nil or table.length(self.AllMagicCardMap) <= 0 then
                self:InitAllMagicCard()
            end
            local CardData = self.AllMagicCardMap and self.AllMagicCardMap[UnLockCardID]
            if CardData then
                CardData.IsUnLock = true
                local NewUnLockCard = self.NewUnlockCardList[UnLockCardID]
                CardData.IsNewUnlock = NewUnLockCard ~= nil  --在新解锁列表中存在，则说明是新解锁
            end
            self.UnLockCardList[UnLockCardID] = UnLockCardID
        end

        self.MagicCardUnlockNum = table.length(self.UnLockCardList) or 0
    end

    if self.MagicCardTotalNum and self.MagicCardTotalNum > 0 then
        self.MagicCardUnlockNumText = string.format(MagicCardCollectionDefine.MajorCollectNumText, self.MagicCardUnlockNum, self.MagicCardTotalNum)
        self.MagicCardUnlockPercent = self.MagicCardUnlockNum / self.MagicCardTotalNum
    end

    for _, Data in ipairs(self.AllMagicCardList) do
        Data = self.AllMagicCardMap and self.AllMagicCardMap[Data.CardID]
    end

    self:UpdateMagicCardList(self.AllMagicCardList)
    self.SelectedCardIndex = self:GetFirstUnLockCardIdx()
end

---@type 新解锁幻卡
---@param NewUnLockCardList table 解锁幻卡数据
function MagicCardCollectionVM:UpdateNewUnLockCardList(NewUnLockCardList)
    if NewUnLockCardList == nil then
        return
    end
    
    if self.NewUnlockCardList == nil then
        self.NewUnlockCardList = {}
    end

    if self.UnLockCardList == nil or table.length(self.UnLockCardList) <= 0 then
        for _, CardID in ipairs(NewUnLockCardList) do
            self.NewUnlockCardList[CardID] = CardID
        end
        return
    end

    for _, CardID in ipairs(NewUnLockCardList) do
        local UnLockCardID = self.UnLockCardList[CardID]
        if not UnLockCardID then
            self.NewUnlockCardList[CardID] = CardID
        end
    end
end

---@type 移除新解锁幻卡
---@param CardID number 解锁幻卡ID
function MagicCardCollectionVM:RemoveNewUnLockCard(CardID)
    if CardID == nil or CardID <= 0 then
        self.NewUnlockCardList = {}
        return
    end
    
    if self.NewUnlockCardList then
        self.NewUnlockCardList[CardID] = nil
    end
end

---@type 更新搜索幻卡结果
---@param CardList table 幻卡数据
function MagicCardCollectionVM:UpdateMagicCardListBySearch(CardList)
    local CurMagicCardList = {}

    if CardList and #CardList > 0 then
        for _, UnLockCardID in ipairs(CardList) do
            local CardData = self.AllMagicCardMap[UnLockCardID]
            if CardData then
                table.insert(CurMagicCardList, CardData)
            end
        end
    end

    self:UpdateMagicCardList(CurMagicCardList)
    self.SelectedCardIndex = #CurMagicCardList > 0 and 1 or 0
end

---@type 更新幻卡列表
---@param CardList table 幻卡数据
function MagicCardCollectionVM:UpdateMagicCardList(CardList)
    self.IsSearchEmpty = CardList == nil or #CardList <= 0
    if self.IsSearchEmpty then
        return
    end

    self.CurMagicCardList = CardList
    self.MagicCardVMList:UpdateByValues(self.CurMagicCardList, nil, false)
end

---@type 更新搜索或筛选结果
---@param UnLockCardList table 过滤幻卡数据
function MagicCardCollectionVM:UpdateMagicCardListByFilter(FilterCardList)
    if FilterCardList == nil or next(FilterCardList) == nil then
        self.MagicCardVMList:UpdateByValues(self.AllMagicCardList, nil)
        return
    end
    self.MagicCardVMList:UpdateByValues(FilterCardList, nil)
end

---@type 更新幻卡收集进度列表
---@param CollectAwardRecordList table 奖励领取记录
function MagicCardCollectionVM:UpdateCollectProgressList(CollectAwardRecordList)
    if CollectAwardRecordList == nil or next(CollectAwardRecordList) == nil then
        self.CanGetAward = self:CheckIsCanGetAward()
        return
    end

    if self.CollectAwardProgressList == nil or next(self.CollectAwardProgressList) == nil then
        return
    end

    for _, RecordID in ipairs(CollectAwardRecordList) do
        for _, CollectInfo in ipairs(self.CollectAwardProgressList) do
            local CollectID = CollectInfo.CollectNum
            if CollectID == RecordID then
                CollectInfo.IsCollectedAward = true
            end
        end
    end
    self.CanGetAward = self:CheckIsCanGetAward()
end

function MagicCardCollectionVM:CheckIsCanGetAward()
    local CanGetAward = false
    if self.CollectAwardProgressList == nil or next(self.CollectAwardProgressList) == nil then
        return false
    end

    for _, Award in ipairs(self.CollectAwardProgressList) do
        local IsGetProgress = self.MagicCardUnlockNum >= Award.CollectNum and not Award.IsCollectedAward -- 是否已达到奖励进度
        if IsGetProgress then
            CanGetAward = true
            break
        end
    end
    -- 暂时屏蔽，奖励按钮目前已隐藏，所以不需要红点
    -- if CanGetAward then
    --     RedDotMgr:AddRedDotByID(MagicCardCollectionDefine.CardRedDotID)
    -- else
    --     RedDotMgr:DelRedDotByID(MagicCardCollectionDefine.CardRedDotID)
    -- end
    return CanGetAward
end

function MagicCardCollectionVM:IsCanGetAward()
    return self.CanGetAward
end

---@type 按表格里的幻卡顺序获取第一个已解锁幻卡索引
function MagicCardCollectionVM:GetFirstUnLockCardIdx()
    for Index, Card in ipairs(self.AllMagicCardList) do
        if Card.IsUnLock == true then
           return Index
        end
    end
    return #self.AllMagicCardList > 0 and 1 or nil
end

---@type 获取幻卡索引
function MagicCardCollectionVM:GetCardIdx(CardID)
    for Index, Card in ipairs(self.AllMagicCardList) do
        if Card.CardID == CardID then
           return Index
        end
    end
    return #self.AllMagicCardList > 0 and 1 or nil
end

---@type 获取当前选中索引
function MagicCardCollectionVM:GetSelectedCardIdx()
    return self.SelectedCardIndex
end

function MagicCardCollectionVM:IsCardUnLock(ID)
    if ID == nil or self.UnLockCardList == nil then
        return false
    end
    return self.UnLockCardList[ID] ~= nil
end

---@param Index number 
function MagicCardCollectionVM:GetCurMagicCardByIndex(Index)
    if self.CurMagicCardList == nil then
        return nil
    end
    return self.CurMagicCardList[Index]
end

---@type 获取当前列表下的未解锁幻卡列表
function MagicCardCollectionVM:GetLockedMagicCardList(IsCheckLocked)
    if not IsCheckLocked then
        return self.AllMagicCardList
    end
    
    if self.CurMagicCardList == nil then
        return nil
    end
    local LockedCardList = {}
    for _, CardData in ipairs(self.CurMagicCardList) do
        if not CardData.IsUnLock then
            table.insert(LockedCardList, CardData)
        end
    end
    return LockedCardList
end

---@type 幻卡是否解锁单项筛选
function MagicCardCollectionVM:OnSearchCardByTag(IsCheckLocked)
    local SearchList = nil
    if self:IsInSearching() then
        -- 从搜索结果中筛选
        SearchList = self:GetFilterResultFromSearchResult(self.SearchResult, IsCheckLocked)
        if SearchList then
            self:UpdateMagicCardList(SearchList)
        end
        self.SelectedCardIndex = 1
    else
        --从全部卡牌中筛选
        SearchList = self:GetLockedMagicCardList(IsCheckLocked)
        if SearchList then
            self:UpdateMagicCardList(SearchList)
        end
        self.SelectedCardIndex = IsCheckLocked and 1 or self:GetFirstUnLockCardIdx()
    end
end

---@type 幻卡文本搜索
function MagicCardCollectionVM:OnSearchCardByText(Content)
    if string.isnilorempty(Content) then
        --已经存在搜索结果，提交为空时，视为取消搜索
		if self:IsInSearching() then
            self:OnCancelSearch()
        else
            self.SearchResult = nil
        end
        return
	end

    self.SearchResult = self:GetSearchResult(Content)
    self:UpdateMagicCardList(self.SearchResult)
    if self.SearchResult and #self.SearchResult > 0 then
        self.SelectedCardIndex = 1
    else
        self.SelectedCardIndex = 0
    end
end

---@type 取消搜索
function MagicCardCollectionVM:OnCancelSearch()
    self:UpdateMagicCardList(self.AllMagicCardList)
    if self:IsInSearching() then
        local CurSelectCard = self.SearchResult[self.CardIndex]
        if CurSelectCard then
            -- 如果主动选中，则取消搜索后还原选中结果
            local _ , Index = table.find_item(self.AllMagicCardList, CurSelectCard.CardID, "CardID")
            self.SelectedCardIndex = Index ~= nil and Index or self.SelectedCardIndex
        else
            -- 未主动选中，则选中第一个解锁卡牌
            self.SelectedCardIndex = self:GetFirstUnLockCardIdx()
        end
        self.SearchResult = nil
    end
end

---@type 是否处于搜索中
function MagicCardCollectionVM:IsInSearching()
    return self.SearchResult ~= nil
end

---@type 从全部卡牌中获取搜索结果
---@param Content 搜索关键词
---@return table 幻卡列表
function MagicCardCollectionVM:GetSearchResult(Content)
    if self.AllMagicCardList == nil or #self.AllMagicCardList <= 0 then
        return nil
    end

    if string.isnilorempty(Content) then
        return nil
    end

    --搜索词是数字（编号）全匹配
    local function PredicateNum(CardData)
        local CardNum = tonumber(Content)
        return CardData.Num == CardNum
    end

    --搜索词是文本（名字）模糊匹配
    local function PredicateName(CardData)
        return string.find(CardData.Name, Content) ~= nil and
                CardData.IsUnLock
    end

    local SearchID = tonumber(Content)
    local Predicate = (SearchID ~= nil and PredicateNum) or PredicateName
    local CardListTemp = {}
    for _, CardData in ipairs(self.AllMagicCardList) do
        if Predicate(CardData) then
            table.insert(CardListTemp, CardData)
        end
    end
    table.sort(CardListTemp, self.CardSortFunc)
    return CardListTemp
end

---@type 从搜索结果中筛选
---@param SearchResultList 搜索结果
---@return IsCheckLocked 是否勾选未解锁
function MagicCardCollectionVM:GetFilterResultFromSearchResult(SearchResultList, IsCheckLocked)
    if SearchResultList == nil or #SearchResultList <= 0 then
        return nil
    end

    if not IsCheckLocked then
        return SearchResultList
    end

    local CardListTemp = {}
    for _, CardData in ipairs(SearchResultList) do
        if not CardData.IsUnLock == IsCheckLocked then
            table.insert(CardListTemp, CardData)
        end
    end

    return CardListTemp
end

---@type 获取当前幻卡列表
function MagicCardCollectionVM:GetCurCardList()
    if self.SearchResult then
        return self.SearchResult
    end
    return self.AllMagicCardList
end

---@type 幻卡排序 编号升序
function MagicCardCollectionVM.CardSortFunc(CardData1, CardData2)
    if CardData1.Num == CardData2.Num then
        return false
    end
    return CardData1.Num < CardData2.Num
end

-----------------------------------------------筛选 start--------------------------------------------
---------------

function MagicCardCollectionVM:OnScreenerAction(ScreenerResult)
	local CardList = {}
	-- 没有选择任何筛选项目
	if ScreenerResult == nil then
        return
	end
    
    local Result = ScreenerResult.Result
    if Result and #Result > 0 then
        CardList = self:GetCardListFromFilterResult(Result)
    end

    table.sort(CardList, self.CardSortFunc)
	self:OnSearchCardByFilter(CardList)
end

---@type 从筛选结果中筛选
---@param SearchResultList 搜索结果
---@return IsCheckLocked 是否勾选未解锁
function MagicCardCollectionVM:GetCardListFromFilterResult(FilterResultList)
    if FilterResultList == nil or #FilterResultList <= 0 then
        return nil
    end

    local CardListTemp = {}
    for _, CardData in ipairs(FilterResultList) do
        local LastCardData = self.AllMagicCardMap[CardData.ID]
        if LastCardData then
            table.insert(CardListTemp, LastCardData)
        end
    end

    return CardListTemp
end

---@type 幻卡筛选搜索
function MagicCardCollectionVM:OnSearchCardByFilter(CardList)
    self.SearchResult = CardList
    self:UpdateMagicCardList(self.SearchResult)
    self.SelectedCardIndex = #self.SearchResult > 0 and 1 or 0
end

---@type 筛选方法
function MagicCardCollectionVM.CardFilterFun(CardInfo, FilterInfo)
    if CardInfo == nil or FilterInfo == nil then
        return false
    end
    local SelectedFilterUnlock = FilterInfo.SelectedFilterUnlock
    local FilterStarList = FilterInfo.SelectedFilterStarList or {}
    local FilterRaceList = FilterInfo.SelectedFilterRaceList or {}
    local IsFilterStar, IsFilterRace = #FilterStarList ~= 0, #FilterRaceList ~= 0

    local ItemCfg = FantasyCardCfg:FindCfgByKey(CardInfo.CardID)
    if ItemCfg == nil then
        Log.E("Wrong CardId: [%d]", CardInfo.CardID)
        return false
    end

    if SelectedFilterUnlock == nil or CardInfo.IsUnlock == SelectedFilterUnlock then
        if not IsFilterStar or table.find_item(FilterStarList, ItemCfg.Star) ~= nil then
            if not IsFilterRace or table.find_item(FilterRaceList, ItemCfg.Race) ~= nil then
                return true
            end
        end
    end
    return false
end

---@type 获取筛选结果
---@param FilterInfo 过滤信息
---@return table 幻卡列表
function MagicCardCollectionVM:GetFilterResult(FilterInfo)
    if self.AllMagicCardList == nil then
        return nil
    end

    if FilterInfo == nil then
        return self.AllMagicCardList
    end
    
    local CardListTemp = {}
    for _, CardData in ipairs(self.AllMagicCardList) do
        if self.CardFilterFun(CardData, FilterInfo) then
            table.insert(CardListTemp,CardData)
        end
    end
    table.sort(CardListTemp, self.CardSortFunc)
    return CardListTemp
end
-----------------------------------------------筛选 End--------------------------------------------

return MagicCardCollectionVM