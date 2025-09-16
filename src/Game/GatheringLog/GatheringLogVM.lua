---
--- Author: Leo
--- DateTime: 2023-03-29 11:18:17
--- Description: 采集笔记系统
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local GatheringLogMgr = require("Game/GatheringLog/GatheringLogMgr")
local GatheringLogStuffItemVM = require("Game/GatheringLog/ItemVM/GatheringLogStuffItemVM")
local GatheringPlaceItemVM = require("Game/GatheringLog/ItemVM/GatheringPlaceItemVM")
local GatheringSearchRescordVM = require("Game/GatheringLog/ItemVM/GatheringSearchRescordVM")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local ProtoRes = require("Protocol/ProtoRes")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemTypeCfg = require("TableCfg/ItemTypeCfg")
local CommLight152Slot = require("Game/Common/Slot/CommLight152SlotView")
local GatheringLogDefine = require("Game/GatheringLog/GatheringLogDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local NoteParamCfg = require("TableCfg/NoteParamCfg")
local GatherNoteCfg = require("TableCfg/GatherNoteCfg")
local MajorUtil = require("Utils/MajorUtil")
local ItemUtil = require("Utils/ItemUtil")

local EToggleButtonState = _G.UE.EToggleButtonState
local LSTR = _G.LSTR
---@class GatheringLogVM : UIViewModel
---@field TextSubTitle string @职业名称
---@field bSubTitleVisible bool @控制职业名称
---@field Setting table @闹钟设置
---@field bPanelFixVisible bool @控制PanelFix控件显示与否
---@field bPanelTabListVisible bool @控制PanelTabList控件显示与否
---@field bVerticalConditionsVisible bool @控制条件界面
---@field bBtnCloseVisible bool @控制关闭按钮
---@field bCondition1ImgBidVisible bool @控制采集时间条件的禁止图标
---@field bCondition2ImgBidVisible bool @控制采集鉴别力条件的禁止图标
---@field bCondition1Visible bool @控制是否隐藏第一条条件
---@field bCondition2Visible bool @控制是否隐藏第二条条件
---@field bAozyImgVisible bool @控制艾图标是否隐藏
---@field Condition1Text string @采集时间条件的文本
---@field Condition2Text string @采集鉴别力条件的文本
---@field CurProfess int @当前职业
---@field MaxCollectCount int @最大采集物数量
---@field MaxClockCount int @最大闹钟数量
---@field CurMinerCollectCount int @采矿收藏数量
---@field CurMinerClockGatherCount int @采矿闹钟数量
---@field CurBotanCollectCount int @园艺收藏数量
---@field CurBotanClockGatherCount int @园艺闹钟数量
---@field CurLogItemVMList UIBindableList @当前采集物列表
---@field CurGatherPlaceVMList UIBindableList @当前采集地点列表
---@field SearchRecordVMList UIBindableList @当前搜索记录列表
---@field bTextListEmptyVisible string @控制空页面显示与否
---@field bSearchRecordVisible bool @控制搜索记录显示与否
---@field bNoConditionVisible bool @控制采集条件无显示与否
---@field bTextConditionVisible bool @控制采集条件文本显示与否
---@field MSCheckState EToggleButtonState @控制开启主题界面提醒
---@field WSCheckState EToggleButtonState @控制开启窗口期开始提醒
---@field WPCheckState EToggleButtonState @控制开启窗口期提前提醒
---@field CheckState1M EToggleButtonState @控制开启1分钟提醒
---@field CheckState3M EToggleButtonState @控制开启3分钟提醒
---@field CheckState5M EToggleButtonState @控制开启5分钟提醒
---@field NVCheckState EToggleButtonState @控制开启提示音
---@field SNCheckState EToggleButtonState @控制处于封闭任务不再提醒
local GatheringLogVM = LuaClass(UIViewModel)
---Ctor
function GatheringLogVM:Ctor()
end

function GatheringLogVM:OnInit()
    -- Main Part
    self.TextSubTitle = ""
    self.TextTitle = LSTR(70046)
    self.bSubTitleVisible = true
    self.Setting = {}
    self.bPanelFixVisible = true
    self.bPanelTabListVisible = true
    self.bVerticalConditionsVisible = true
    self.bBtnCloseVisible = true
    self.bCondition1ImgBidVisible = false
    self.bCondition2ImgBidVisible = false
    self.bCondition1Visible = false
    self.bCondition2Visible = true
    self.bAozyImgVisible = false
    self.Condition1Text = ""
    self.Condition2Text = ""
    self.TextContent1 = ""
    self.TextContent2 = ""
    self.CurProfess = nil

    self.MaxCollectCount = 0
    self.MaxClockCount = 0
    self.CurMinerCollectCount = 0
    self.CurMinerClockGatherCount = 0
    self.CurBotanCollectCount = 0
    self.CurBotanClockGatherCount = 0

    self.CurLogItemVMList = UIBindableList.New(GatheringLogStuffItemVM)
    self.CurGatherPlaceVMList = UIBindableList.New(GatheringPlaceItemVM)
    self.SearchRecordVMList = UIBindableList.New(GatheringSearchRescordVM)

    self.bTextListEmptyVisible = false
    self.bNoConditionVisible = false
    self.bTextConditionVisible = true

    --闹钟设置的最终结果
    self.MSCheckState = EToggleButtonState.Checked
    self.WSCheckState = EToggleButtonState.Checked
    self.WPCheckState = EToggleButtonState.Checked
    self.CheckState1M = EToggleButtonState.Checked
    self.CheckState3M = EToggleButtonState.Unchecked
    self.CheckState5M = EToggleButtonState.Unchecked
    self.NVCheckState = EToggleButtonState.Unchecked
    self.SNCheckState = EToggleButtonState.Unchecked

    self.bImgCollectVisible = false
    self.GatherItemTextName = ""
    self.TypeName = ""
    self.IconID = nil
    self.ItemQualityImg = nil
    self.bSetClock = false
    self.bSetFavor = false
    self.bBtnSetAlarmVisible = false
    self.bToggleBtnAlarmClockVisible = false
    self.bSearchHistoryShow = false
    self.bBtnDeleteShow = false
    self.GatherItemProf = nil
    self.bLeveQuestMarked = false
end

function GatheringLogVM:OnBegin()
end

function GatheringLogVM:UpdateVM(Value)
end

function GatheringLogVM:OnShutdown()
    self.CurLogItemVMList = nil
    self.CurGatherPlaceVMList = nil
    self.SearchRecordVMList = nil
end

function GatheringLogVM:OnEnd()
end

---@type 初始化最大收藏数量与最大闹钟数量
function GatheringLogVM:InitGlobalDataCfg()
    local CollectCount = NoteParamCfg:FindCfgByKey(ProtoRes.NoteParamCfgID.NoteCollectionMaxCollectNum)
    local ClockCount = NoteParamCfg:FindCfgByKey(ProtoRes.NoteParamCfgID.NoteGatherClockMaxNum)
    self.MaxCollectCount = CollectCount.Value[1]
    self.MaxClockCount = ClockCount.Value[1]
end

---@type 更新收藏数
---@param GatheringJobID int @职业ID
---@param HorBarIndex int @水平二级tableview索引
function GatheringLogVM:UpdateCurCount(GatheringJobID, HorBarIndex)
    --HorBarIndex:3收藏品列表，4闹钟列表
    local Items = GatheringLogMgr:GetItemDataByTopFilter(GatheringJobID, HorBarIndex)
    local Count = #Items
    local HorBarIndexInDefine = GatheringLogDefine.HorBarIndex
    local ProfID = GatheringLogDefine.ProfID
    if HorBarIndex == HorBarIndexInDefine.CollectionIndex and GatheringJobID == ProfID.MinerJobID then
        self.CurMinerCollectCount = Count
    elseif HorBarIndex == HorBarIndexInDefine.ClockIndex and GatheringJobID == ProfID.MinerJobID then
        self.CurMinerClockGatherCount = Count
    elseif HorBarIndex == HorBarIndexInDefine.CollectionIndex and GatheringJobID == ProfID.BotanistJobID then
        self.CurBotanCollectCount = Count
    elseif HorBarIndex == HorBarIndexInDefine.ClockIndex and GatheringJobID == ProfID.BotanistJobID then
        self.CurBotanClockGatherCount = Count
    end
end

---@type 传承录未解锁时卷级种类排序
function GatheringLogVM.GatherLabelPredicate(Left, Right)
    --return (Left.Category or 0) < (Right.Category or 0)
    return (Left.GatheringLabel or 0) < (Right.GatheringLabel or 0)
end

---@type 特殊采集物种类排序
function GatheringLogVM.ItemTypePredicate(Left, Right)
    return (Left.GatheringLabel or 0) < (Right.GatheringLabel or 0)
end

---@type 地图种类排序
function GatheringLogVM.MapPredicate(Left, Right)
    return (Left.MapID or 0) < (Right.MapID or 0)
end

---@type 加载搜索记录TableView
---@param SearchRecordTabVMs table @搜索记录数据
function GatheringLogVM:UpdateSearchRecordList(SearchRecordTabVMs)
    local SearchRecordVMList = self.SearchRecordVMList
    if SearchRecordVMList == nil then
        return
    end
    if nil ~= SearchRecordVMList and SearchRecordVMList:Length() > 0 then
        SearchRecordVMList:Clear()
        self.bBtnDeleteShow = false
    end
    for _, v in pairs(SearchRecordTabVMs) do
        local Elem = v
        SearchRecordVMList:AddByValue(Elem)
        self.bBtnDeleteShow = true
    end
end

---@type 加载搜索记录TableView
---@param SearchRecordTabVMs table @搜索记录数据
function GatheringLogVM:ClearSearchHistory()
    _G.GatheringLogMgr.SearchRecordList = {}
    self.SearchRecordVMList:Clear()
    self.bBtnDeleteShow = false
end

---@type 测试加载地图以及采集地
---@param PlaceData table @地图以及采集地数据ID
---@param GatherID table @采集物ID
function GatheringLogVM:UpdatePlaceTabList(PlaceData,GatherID)
    local PlaceVMList = self.CurGatherPlaceVMList
    PlaceVMList:Clear()
    local GatherData = self:GetItemDataByID(GatherID)
    local GatheringJob = GatherData.GatheringJob
    local ProfLevel = MajorUtil.GetMajorLevelByProf(GatheringJob) or 0
    local ProfbLock = GatheringLogMgr:GetCurProfbLock()
    for _, v in pairs(PlaceData) do
        local Elem = v
        Elem.GatherID = GatherID
        --采集物等级大于玩家职业等级10级，隐藏跳转至地图内查看采集点的“箭头” story=120248903
        Elem.bArrowShow = not ProfbLock and (Elem.GatherLevel - ProfLevel) < 10
        PlaceVMList:AddByValue(Elem)
    end
end

---@type 加载Item列表
---@param AllGatherLogItemVMs table @所有Item数据
---@param HorBarIndex int @水平二级tableview索引
function GatheringLogVM:UpdateGatheringItemTypesList(AllGatherLogItemVMs)
    local CurLogItemVMList = self.CurLogItemVMList
    if CurLogItemVMList == nil then
        return
    end
    --如果没有Item，那就清空
    if AllGatherLogItemVMs == nil or AllGatherLogItemVMs[1] == nil then
        CurLogItemVMList:Clear()
        return
    end
    --如果有Item，就把列表清空，重新赋值
    -- if nil ~= CurLogItemVMList and CurLogItemVMList:Length() > 0 then
    --     CurLogItemVMList:Clear()
    -- end
    local ProfID = GatheringLogMgr:GetChoiceProfID()
    local MarkedItemID = _G.LeveQuestMgr:GetMarkedItemByProfID(ProfID)
    local HistoryList = GatheringLogMgr.HistoryList or {}
    local CollectList = GatheringLogMgr.CollectList or {}
    local ClockList = GatheringLogMgr.ClockList or {}
    local ID = 0
    local GatherItemInfo = nil
    self.HaveGatherItem = false
    for _, value in pairs(AllGatherLogItemVMs) do
        if value.TextTips == nil then
            value.bLeveQuestMarked = MarkedItemID and MarkedItemID == value.ItemID
            ID = value.ID
            value.bGot = HistoryList[ID] ~= nil
            value.bSetFavor = CollectList[ID] ~= nil
            value.bSetClock = ClockList[ID] ~= nil
            GatherItemInfo = GatheringLogMgr:GetGatherItemInfoByID(ID)
            value.TimeCondition = GatherItemInfo and GatherItemInfo.TimeCondition
            self.HaveGatherItem = true
        end
    end
    CurLogItemVMList:UpdateByValues(AllGatherLogItemVMs)
    EventMgr:SendEvent(EventID.UpdateGatherItemRedDot)
end

---@type 选择采集物高亮
---@param ItemID int @ItemID
function GatheringLogVM:UpdateSelectItemTab(ID)
    if GatheringLogMgr.SearchState == GatheringLogDefine.SearchState.BeforSearch then
        EventMgr:SendEvent(EventID.GatheringLogExitSearchState)
    end
    if self.CurLogItemVMList == nil or ID == nil then
        return
    end
    local AllDropVMs = self.CurLogItemVMList:GetItems()
    local ConditionInDefine = GatheringLogDefine.GatherCondition
    local LastFilterState = GatheringLogMgr.LastFilterState
    local HavaSelect = false
    local SelectIndex = 1
    for index, Elem in pairs(AllDropVMs) do
        Elem.bSelect = Elem.ID == ID
        if Elem.bSelect then
            HavaSelect = true
            SelectIndex = index
            if GatheringLogMgr.SearchState == GatheringLogDefine.SearchState.InSearching then
                LastFilterState.IDofSearchItem = Elem.ID
                --职业变化时前往转职的按钮控制
                self.GatherItemProf = Elem.GatheringJob
            else
                LastFilterState.GatherID = Elem.ID
            end
            --基础信息
            self.bImgCollectVisible = Elem.bIsCollection == 1
            self.GatherItemTextName = ItemCfg:GetItemName(Elem.ItemID)
            local Cfg = ItemCfg:FindCfgByKey(Elem.ItemID)
            if Cfg then
                if 1 == Cfg.IsHQ then
                    self.ItemQualityImg = CommLight152Slot.ItemHQColorType[Cfg.ItemColor]
                else
                    self.ItemQualityImg = CommLight152Slot.ItemColorType[Cfg.ItemColor]
                end
                self.TypeName = ItemTypeCfg:GetTypeName(Cfg.ItemType)
                self.IconID = Cfg.IconID
            end
            self.bSetClock = Elem.bSetClock
            self.bSetFavor = Elem.bSetFavor
            self.bLeveQuestMarked = Elem.bLeveQuestMarked

            local flag = _G.GatheringLogMgr.LastFilterState.HorTabsIndex == GatheringLogDefine.HorBarIndex.ClockIndex
                or GatheringLogMgr.SearchState == GatheringLogDefine.SearchState.InSearching
            self.bBtnSetAlarmVisible = Elem.bUseClock and flag
            self.bToggleBtnAlarmClockVisible = Elem.bUseClock

            --加载第二条采集的条件（获得力，由采集物配置），第一个条件限时由采集地点配置（在下方）
            local MinAcquisition = Elem.MinAcquisition
            if MinAcquisition == 0 then
                --如果获得力是0，而且第一个条件（限时）也不显示，那么“采集条件”就不显示
                self.bCondition2Visible = false
                if not self.bCondition1Visible then
                    self.bNoConditionVisible = true
                end
            else
                self.bCondition2Visible = true
                self.bNoConditionVisible = false
                self.TextContent2 = LSTR(ConditionInDefine.RequireNormal)
                self.Condition2Text = string.format("%s%s", "≥", MinAcquisition)
                self.bCondition2ImgBidVisible = not (MinAcquisition <= GatheringLogMgr.AttrGathering)
            end
            --记载可采集的地图
            local PlaceDate = GatheringLogMgr:GetGatherPlaceByItemData(Elem) 
            local CurGatherPlaceVMList = self.CurGatherPlaceVMList
            if PlaceDate ~= nil and  #PlaceDate >= 1 then
                self:UpdatePlaceTabList(PlaceDate, Elem.ID)
                if CurGatherPlaceVMList:Length() >= 1 then
                    local DefaultPlace = CurGatherPlaceVMList:Get(1)
                    --设置让最上方Map的SpacerInterval不要出现
                    EventMgr:SendEvent(EventID.GatheringLogSetMapSpaceAndAnim, DefaultPlace.MapID)
                    DefaultPlace.bSelect = true
                    self:UpdatePlaceSelectTab()
                end
            else
                CurGatherPlaceVMList:Clear()
                self.bCondition1ImgBidVisible = false
                self.bCondition1Visible = false
                self.bNoConditionVisible = false
            end

            local RedDotName = GatheringLogMgr.GatherItemRedDotNameList[Elem.ID]
            if RedDotName then
                local RedDot = _G.RedDotMgr:FindRedDotNodeByName(RedDotName)
                local isDel = _G.RedDotMgr:DelRedDotByName(RedDotName)
                if isDel then
                    GatheringLogMgr.GatherItemRedDotNameList[Elem.ID] = nil
                    local ParentRedDot = RedDot.ParentRedDotNode
                    if ParentRedDot.SubRedDotList == nil or #ParentRedDot.SubRedDotList == 0 then
                        _G.RedDotMgr:DelRedDotByName(ParentRedDot.RedDotName)
                        local HorNode = ParentRedDot.ParentRedDotNode
                        local HorIndex = HorNode.HorIndex
                        if HorIndex == nil or HorIndex == 1 then
                            GatheringLogMgr:SendMsgRemoveDropNewData(Elem.GatheringJob, ParentRedDot.DropDownIndex)
                        elseif HorIndex == 2 then
                            local ReadVersion = nil
                            if ParentRedDot.DropDownIndex == GatheringLogDefine.SpecialType.SpecialTypeCollection then
                                ReadVersion = MajorUtil.GetMajorLevelByProf(Elem.GatheringJob)
                                --GatheringLogMgr:SendMsgRemoveDropNewData(Data.GatheringJob, nil, ParentRedDot.DropDownIndex, ReadVersion,true)
                                GatheringLogMgr:SendMsgRemoveDropNewData(Elem.GatheringJob, 100)
                                GatheringLogMgr.SpecialDropRedDotLists[Elem.GatheringJob][3] = nil
                                GatheringLogMgr:SpecialRedDotDataUpdate(Elem.GatheringJob)
                            else
                                ReadVersion = GatheringLogMgr.GameVersionNum
                                if GatheringLogMgr.UseLineageProf[Elem.GatheringJob][1] then
                                    GatheringLogMgr:SendMsgRemoveDropNewData(Elem.GatheringJob, nil, ParentRedDot.DropDownIndex, ReadVersion,true,1)
                                end
                                if GatheringLogMgr.UseLineageProf[Elem.GatheringJob][2] then
                                    GatheringLogMgr:SendMsgRemoveDropNewData(Elem.GatheringJob, nil, ParentRedDot.DropDownIndex, ReadVersion,true,2)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if HavaSelect == false and not table.is_nil_empty(AllDropVMs) then
        AllDropVMs[1].bSelect = true
    end

    return SelectIndex
end

---@type 更新地图选择
---@param ID int @地点ID
function GatheringLogVM:UpdatePlaceSelectTab()
    local AllPlaceVMs = self.CurGatherPlaceVMList:GetItems()
    if #AllPlaceVMs < 1 then
        return
    end
    self.Condition1Text = ""
    for _, Elem in pairs(AllPlaceVMs) do
        local TimeCondition = Elem.TimeCondition
        local ConditionInDefine = GatheringLogDefine.GatherCondition
        --如果有时间条件初始化一下时间条件
        if not table.is_nil_empty(TimeCondition) then
            --设置还有几分钟出现 或 多久结束
            Elem:SetTimeTextTip(TimeCondition)
        end
        if not table.is_nil_empty(TimeCondition) then
            self.bAozyImgVisible = true
            self.bCondition1Visible = true
            self.bNoConditionVisible = false
            self.TextContent1 = LSTR(ConditionInDefine.TimeCondition)

            for _, Time in pairs(TimeCondition) do
                self.Condition1Text = string.format("%s  %s", self.Condition1Text, Time)
            end
        else
            self.bAozyImgVisible = false
            self.bCondition1Visible = false
            if not self.bCondition2Visible then
                self.bNoConditionVisible = true
            end
            GatheringLogVM.bCondition1ImgBidVisible = false
        end
    end
end

---@type 得到选中的采集物ID
function GatheringLogVM:GetSelectGatherID()
    if self.CurLogItemVMList == nil then
        return
    end
    local AllItemVMs = self.CurLogItemVMList:GetItems()
    for _, v in pairs(AllItemVMs) do
        local Elem = v
        if Elem.bSelect then
            return Elem.ID
        end
    end
    if AllItemVMs[1] ~= nil then
        return AllItemVMs[1].ID
    end
end

---@type 得到选中的采集点的ID
function GatheringLogVM:GetSelectPlaceID()
    if self.CurGatherPlaceVMList == nil then
        return
    end
    local AllPlaceVMs = self.CurGatherPlaceVMList:GetItems()
    for _, v in pairs(AllPlaceVMs) do
        local Elem = v
        if Elem.bSelect then
            return Elem.ID
        end
    end
    if AllPlaceVMs[1] ~= nil then
        return AllPlaceVMs[1].ID
    end
end

---@type 通过采集物ItemID得到采集物的VM
---@param ItemID number @通过采集物ItemID得到采集物
function GatheringLogVM:GetItemVMByItemID(ItemID)
    if ItemID == nil then
        FLOG_ERROR("GatheringLogVM:GetItemVMByItemID ItemID is nil")
        return
    end
    if self.CurLogItemVMList == nil then
        return
    end
    local AllItemVMs = self.CurLogItemVMList:GetItems()
    for _, v in pairs(AllItemVMs) do
        local Elem = v
        if Elem.ItemID == ItemID then
            return Elem
        end
    end
end

---@type 通过采集物ID得到采集物的Data
---@param ID number @通过采集物ID得到采集物
function GatheringLogVM:GetItemDataByID(ID)
    if ID == nil then
        FLOG_WARNING("GatheringLogVM:GetItemDataByID ID is nil")
        return
    end
    local Cfg = GatherNoteCfg:FindCfgByKey(ID)
    if Cfg ~= nil then
        Cfg.Name = ItemUtil.GetItemName(Cfg.ItemID)
    end
    return Cfg
end

---@type 保存搜索后的选中
function GatheringLogVM:SaveSearchSelectData(ID)
    local ItemData = self: GetItemDataByID(ID)
    _G.GatheringLogMgr.LastFilterState.GatheringJobID = ItemData.GatheringJob
    local HorIndex = 1
    if ItemData.GatheringLabel == LSTR(GatheringLogDefine.DropDownConditions.Normal) then
        HorIndex = GatheringLogDefine.HorBarIndex.NormalIndex
        local DropData = _G.GatheringLogMgr:UpdateDropData(ItemData.GatheringJob, HorIndex)
        for Index, Elem in pairs(DropData) do
            local LevelMinMax = StringTools.StringSplit(Elem.Name, "~")
            if #LevelMinMax < 2 then
                FLOG_ERROR("GatheringLogMgr:UpdataItems LevelMinMax < 2")
                break
            end
            local LevelMin = tonumber(LevelMinMax[1])
            local Temp = StringTools.StringSplit(LevelMinMax[2], LSTR(70022)) --级
            local LevelMax = tonumber(Temp[1])
            if ItemData.GatheringGrade >= LevelMin and ItemData.GatheringGrade <= LevelMax then
                _G.GatheringLogMgr.LastFilterState.DropDownIndex = Index
            end
        end
    else
        HorIndex = GatheringLogDefine.HorBarIndex.SpecialIndex
        local DropData = _G.GatheringLogMgr:UpdateDropData(ItemData.GatheringJob, HorIndex)
        for Index, value in pairs(DropData) do
            if ItemData.GatheringLabel == value.Name then
                _G.GatheringLogMgr.LastFilterState.DropDownIndex = Index
            end
        end
    end
    _G.GatheringLogMgr.LastFilterState.HorTabsIndex = HorIndex
end

---@type 从列表中删除Item
---@param Item Item
function GatheringLogVM:OnItemRemove(Item)
    local function Predicate(ViewModel)
        if ViewModel.ItemID == Item.ItemID then
            return true
        end
    end
    self.CurLogItemVMList:RemoveByPredicate(Predicate)
end

---@type 获取模糊搜索结果
---@param SearchText string @搜索文本
function GatheringLogVM:GetSearchResultList(SearchText)
    local SearchResultList = {}
    local Pattern = "^[%p%s]+$"	--清理特殊符号
	if string.match(SearchText, Pattern) or tonumber(SearchText) then
		return SearchResultList
	end
    local AllItemData, LineageData = GatheringLogMgr:GetItemDataByLevel()
    --模糊搜索
    for i = 1, #AllItemData do
        local Elem = AllItemData[i]
        if Elem.Name == SearchText or string.find(Elem.Name, SearchText) then
            table.insert(SearchResultList, Elem)
        end
    end
    self.SearchText = SearchText
    table.sort(SearchResultList, GatheringLogMgr.SortItemDataByLevelPredicate)
    self.SearchText = nil
    local HaveMatchingLineage = false --未解锁的传承录里是否有匹配数据
    for i = 1, #LineageData do
        local Elem = LineageData[i]
        --精确搜索到的或（模糊搜索到的且没有其他合适结果）
        if Elem.Name == SearchText or (string.find(Elem.Name, SearchText) and #SearchResultList == 0) then
            HaveMatchingLineage = true
            self.SearchLineageData = Elem
            SearchResultList = {}
            break
        end
    end
    return SearchResultList, HaveMatchingLineage
end

---@type 得到选择的采集点
function GatheringLogVM:GetSelectPlace()
    local AllItem = self.CurGatherPlaceVMList:GetItems()
    for _, v in pairs(AllItem) do
        local Elem = v
        if Elem.bSelect then
            return Elem
        end
    end
end

---@type 根据ID得到采集点
function GatheringLogVM:GetPlaceItemByID(ID)
    local AllItem = self.CurGatherPlaceVMList:GetItems()
    for _, v in pairs(AllItem) do
        local Elem = v
        if Elem.ID == ID then
            return Elem
        end
    end
end

---@type 得到闹钟目前的设置
function GatheringLogVM:GetClockSetting()
    local Setting = self.Setting
    if self.MSCheckState == EToggleButtonState.Checked then
        Setting.Trigger = true
    else
        Setting.Trigger = false
    end

    if self.WSCheckState == EToggleButtonState.Checked then
        Setting.StartNotify = true
    else
        Setting.StartNotify = false
    end

    local OneMinIndex = 1
    local ThreeMinIndex = 3
    local FiveMinIndex = 5
    if self.WPCheckState == EToggleButtonState.Checked then
        Setting.IsComingNotify = true
        if self.CheckState1M == EToggleButtonState.Checked then
            Setting.ComingNotify = OneMinIndex
        elseif self.CheckState3M == EToggleButtonState.Checked then
            Setting.ComingNotify = ThreeMinIndex
        elseif self.CheckState5M == EToggleButtonState.Checked then
            Setting.ComingNotify = FiveMinIndex
        end
    else
        Setting.IsComingNotify = false
    end

    if self.NVCheckState == EToggleButtonState.Checked then
        Setting.Sound = true
    else
        Setting.Sound = false
    end

    if self.SNCheckState == EToggleButtonState.Checked then
        Setting.CloseNotify = true
    else
        Setting.CloseNotify = false
    end
    return Setting
end

---@type  设置闹钟设置
---@param Setting table @闹钟设置
function GatheringLogVM:SetClockSetting(Setting)
    local NewSetting = Setting
    if NewSetting.Trigger then
        self.MSCheckState = EToggleButtonState.Checked
    else
        self.MSCheckState = EToggleButtonState.Unchecked
    end

    if NewSetting.StartNotify then
        self.WSCheckState = EToggleButtonState.Checked
    else
        self.WSCheckState = EToggleButtonState.Unchecked
    end

    if NewSetting.IsComingNotify then
        self.WPCheckState = EToggleButtonState.Checked
        local OneMinIndex = 1
        local ThreeMinIndex = 3
        local FiveMinIndex = 5
        if NewSetting.ComingNotify == OneMinIndex then
            self.WPCheckState = EToggleButtonState.Checked
            self.CheckState1M = EToggleButtonState.Checked
            self.CheckState3M = EToggleButtonState.Unchecked
            self.CheckState5M = EToggleButtonState.Unchecked
        elseif NewSetting.ComingNotify == ThreeMinIndex then
            self.WPCheckState = EToggleButtonState.Checked
            self.CheckState1M = EToggleButtonState.Unchecked
            self.CheckState3M = EToggleButtonState.Checked
            self.CheckState5M = EToggleButtonState.Unchecked
        elseif NewSetting.ComingNotify == FiveMinIndex then
            self.WPCheckState = EToggleButtonState.Checked
            self.CheckState1M = EToggleButtonState.Unchecked
            self.CheckState3M = EToggleButtonState.Unchecked
            self.CheckState5M = EToggleButtonState.Checked
        end
    else
        self.WPCheckState = EToggleButtonState.Unchecked
    end

    if NewSetting.Sound then
        self.NVCheckState = EToggleButtonState.Checked
    else
        self.NVCheckState = EToggleButtonState.Unchecked
    end

    if NewSetting.CloseNotify then
        self.SNCheckState = EToggleButtonState.Checked
    else
        self.SNCheckState = EToggleButtonState.Unchecked
    end
end

---@type 设置闹钟
function GatheringLogVM:SetClock(toSet)
    local Data = GatheringLogMgr:GetSelectGatherData()
    local Item = Data and self:GetItemVMByItemID(Data.ItemID)
    if Item == nil then
        _G.FLOG_INFO("GatheringLogVM:SetClock Item is nil")
        return
    end
    local bIsReachMaxCount = self:CheckIsReachMaxClockCount(Item.GatheringJob)
    --如果闹钟已达到最大数量 或 不能设置闹钟
    if bIsReachMaxCount and not Item.bSetClock then
        --提示闹钟已满
        local SaturateTipText = GatheringLogDefine.SaturateTipText
        local ClockTip = LSTR(SaturateTipText.ClockTip)
        MsgTipsUtil.ShowTips(ClockTip)
        return false
    end
    --如果闹钟已激活，则可以设置闹钟
    if not Item.bUseClock then
        return false
    end

    local IsFirstSet = _G.GatheringLogMgr.ClockSetting.IsFirstSet
    toSet = toSet or IsFirstSet
    if toSet then
        _G.UIViewMgr:ShowView(_G.UIViewID.GatheringLogSetAlarmClockWinView)
        return false
    end

    local SelfNoteType = GatheringLogDefine.GatheringLogNoteType
    --订阅列表更新，添加或删除(采集闹钟和钓鱼闹钟通用)
    if not Item.bSetClock then
        GatheringLogMgr:SendMsgAfterClockUpdate(SelfNoteType, Item.ID)
    else
        GatheringLogMgr:SendMsgCancelClock(SelfNoteType, Item.ID)
    end
end

---@type 设置收藏
function GatheringLogVM:SetFavor()
    local Data = GatheringLogMgr:GetSelectGatherData()
    local Item = Data and self:GetItemVMByItemID(Data.ItemID)
    if Item == nil then
        _G.FLOG_INFO("GatheringLogVM:SetFavor Item is nil")
        return
    end
    local GatheringJobID = Item.GatheringJob
	local bIsReachMaxCount = self:CheckIsReachMaxCollectCount(GatheringJobID)
	if bIsReachMaxCount and not Item.bSetFavor then
		local SaturateTipText = GatheringLogDefine.SaturateTipText
		local CollectTip = LSTR(SaturateTipText.CollectTip)
		MsgTipsUtil.ShowTips(CollectTip)
		return false
	end

    local SelfNoteType = GatheringLogDefine.GatheringLogNoteType
    --请求收藏
    if not Item.bSetFavor then
        GatheringLogMgr:SendMsgMarkOrNotinfo(SelfNoteType, Item.ID)
    else
        GatheringLogMgr:SendMsgCancelMark(SelfNoteType, Item.ID)
    end
    return Item.bSetFavor
end

---@type 检查当前职业设置闹钟数量是否是满的
function GatheringLogVM:CheckIsReachMaxClockCount(GatheringJobID)
    self:UpdateCurCount(GatheringJobID, GatheringLogDefine.HorBarIndex.ClockIndex)
    local ProfID = GatheringLogDefine.ProfID
    if GatheringJobID == ProfID.MinerJobID then
        if self.CurMinerClockGatherCount >= self.MaxClockCount then
            return true
        else
            return false
        end
    elseif GatheringJobID == ProfID.BotanistJobID then
        if self.CurBotanClockGatherCount >= self.MaxClockCount then
            return true
        else
            return false
        end
    end
end

---@type 检查当前职业收藏数量是否是满的
function GatheringLogVM:CheckIsReachMaxCollectCount(GatheringJobID)
    self:UpdateCurCount(GatheringJobID, GatheringLogDefine.HorBarIndex.CollectionIndex)
	local ProfID = GatheringLogDefine.ProfID
	if GatheringJobID == ProfID.MinerJobID then
		if self.CurMinerCollectCount >= self.MaxCollectCount then
			return true
		else
			return false
		end
	elseif GatheringJobID == ProfID.BotanistJobID then
		if self.CurBotanCollectCount >= self.MaxCollectCount then
			return true
		else
			return false
		end
	end
end

return GatheringLogVM
