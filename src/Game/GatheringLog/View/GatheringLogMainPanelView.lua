---
--- Author: Leo
--- DateTime: 2023-03-29 10:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GatheringLogVM = require("Game/GatheringLog/GatheringLogVM")
local GatheringLogMgr = require("Game/GatheringLog/GatheringLogMgr")
local EventID = require("Define/EventID")
local GatheringLogDefine = require("Game/GatheringLog/GatheringLogDefine")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local GatheringCustomerItemVM = require("Game/GatheringLog/ItemVM/GatheringCustomerItemVM")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCS = require("Protocol/ProtoCS")
local LSTR = _G.LSTR
local UIDefine = require("Define/UIDefine")
local CommUIStyleType = UIDefine.CommUIStyleType
local DataReportUtil = require("Utils/DataReportUtil")

---@class GatheringLogMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackpackEmpty CommBackpackEmptyView
---@field Bkg CommonBkg01View
---@field BtnActivateClock CommBtnLView
---@field BtnClose CommonCloseBtnView
---@field BtnSort UFButton
---@field CommonBookBkg CommonBookBkgView
---@field CommonTitle CommonTitleView
---@field DropDown CommDropDownListView
---@field HorTabs CommHorTabsView
---@field InfoPage GatheringLogInfoPageView
---@field InputSearch CommSearchBarView
---@field PanelActivateTips UFCanvasPanel
---@field PanelFix UFCanvasPanel
---@field PanelInfo UFCanvasPanel
---@field PanelTabList UFCanvasPanel
---@field SearchHistory GatheringLogSearchHistoryItemView
---@field TableViewList UTableView
---@field TextAT UFTextBlock
---@field TextCondition UFTextBlock
---@field VerIconTabs CommVerIconTabsView
---@field AnimIn UWidgetAnimation
---@field AnimPanelIn1 UWidgetAnimation
---@field AnimPanelIn2 UWidgetAnimation
---@field AnimPanelIn3 UWidgetAnimation
---@field AnimSearchBack UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatheringLogMainPanelView = LuaClass(UIView, true)

function GatheringLogMainPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackpackEmpty = nil
	--self.Bkg = nil
	--self.BtnActivateClock = nil
	--self.BtnClose = nil
	--self.BtnSort = nil
	--self.CommonBookBkg = nil
	--self.CommonTitle = nil
	--self.DropDown = nil
	--self.HorTabs = nil
	--self.InfoPage = nil
	--self.InputSearch = nil
	--self.PanelActivateTips = nil
	--self.PanelFix = nil
	--self.PanelInfo = nil
	--self.PanelTabList = nil
	--self.SearchHistory = nil
	--self.TableViewList = nil
	--self.TextAT = nil
	--self.TextCondition = nil
	--self.VerIconTabs = nil
	--self.AnimIn = nil
	--self.AnimPanelIn1 = nil
	--self.AnimPanelIn2 = nil
	--self.AnimPanelIn3 = nil
	--self.AnimSearchBack = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatheringLogMainPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackpackEmpty)
	self:AddSubView(self.Bkg)
	self:AddSubView(self.BtnActivateClock)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommonBookBkg)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.DropDown)
	self:AddSubView(self.HorTabs)
	self:AddSubView(self.InfoPage)
	self:AddSubView(self.InputSearch)
	self:AddSubView(self.SearchHistory)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatheringLogMainPanelView:OnInit()
    --创建Adapter
    self.TableViewListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil, true)

    --多个Entry要初始化其分类
    self.TableViewListAdapter:InitCategoryInfo(GatheringCustomerItemVM, GatheringLogVM.ItemTypePredicate)
    self.InputSearch:SetHintText(LSTR(GatheringLogDefine.DefauleSearchText))
    --创建Binders
    self.Binders = {
        {"TextTitle", UIBinderSetText.New(self, self.CommonTitle.TextTitleName)},
        {"TextSubTitle", UIBinderSetText.New(self, self.CommonTitle.TextSubtitle)},
        {"bTextListEmptyVisible", UIBinderSetIsVisible.New(self, self.BackpackEmpty)},
        {"CurLogItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewListAdapter)},
        {"bPanelFixVisible", UIBinderSetIsVisible.New(self, self.PanelFix)},
        {"bPanelTabListVisible", UIBinderSetIsVisible.New(self, self.PanelTabList)},
        {"bSubTitleVisible", UIBinderSetIsVisible.New(self, self.CommonTitle.TextSubtitle)},
        {"bVerticalConditionsVisible", UIBinderSetIsVisible.New(self, self.VerticalConditions)},
        {"bBtnCloseVisible", UIBinderSetIsVisible.New(self, self.BtnClose)},
        {"bSearchHistoryShow", UIBinderSetIsVisible.New(self, self.SearchHistory)},
        {"GatherItemProf", UIBinderValueChangedCallback.New(self, nil, self.SetSwichProfBtnState)},
    }

    UIUtil.SetIsVisible(self.PanelActivateTips, false)
    UIUtil.SetIsVisible(self.DropDown.TextQuantity,true)
    UIUtil.SetIsVisible(self.BackpackEmpty.PanelBtn, false)
end

function GatheringLogMainPanelView:OnDestroy()
end

function GatheringLogMainPanelView:OnShow()
    self.CommonTitle.CommInforBtn:SetHelpInfoID(11126)
    GatheringLogMgr:GetQuestStatus()
    self.HorTabs:SetRedDotType(ProtoCS.NoteType.NOTE_TYPE_COLLECTION)
    self.IsUpdateLastSelectPorf = false
    self.bPlayAnimation = true

    --更新获得力属性
    GatheringLogMgr:UpdateAttrGathering()
    -- 每次打开更新职业数据
    GatheringLogMgr:UpdateProfessionData()
    GatheringLogVM:InitGlobalDataCfg()

    --打开对应职业页签
    if self.Params and self.Params.JumpData then
        local ProfID = self.Params.JumpData[1]
        if ProfID then
            GatheringLogMgr.LastFilterState.GatheringJobID = ProfID
        end
	end

    -- 初始化职业列表
    self:UpdateProfessionList()
    self.UpdateClockSetting()
end

function GatheringLogMainPanelView:OnHide()
    GatheringLogMgr:DelRedDotsOnHide()
    local GatheringJobID = GatheringLogMgr:GetChoiceProfID()
    self:SaveLastSelectProfessJob(GatheringJobID)
end

function GatheringLogMainPanelView:OnRegisterUIEvent()
    UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabs, self.OnSelectionChangedVerIconTabs)
    UIUtil.AddOnSelectionChangedEvent(self, self.HorTabs, self.OnSelectionChangedHorTabs)
    UIUtil.AddOnSelectionChangedEvent(self, self.DropDown, self.OnSelectionChangedDropDown)
    --排序按钮
    UIUtil.AddOnClickedEvent(self, self.BtnSort, self.OnBtnSorting)

    self.InputSearch:SetCallback(self, nil, self.OnSearchTextCommitted, self.OnSearchCloseBtnClick)
    UIUtil.AddOnFocusReceivedEvent(self, self.InputSearch.TextInput, self.OnBtnSearchClick)
    UIUtil.AddOnFocusLostEvent(self, self.InputSearch.TextInput, self.OnTextFocusLost)
end

function GatheringLogMainPanelView:OnRegisterGameEvent()
    --刷新DorpDown
    self:RegisterGameEvent(EventID.GatheringLogUpdateDropDownFilter, self.UpdateDropDownFilter)
    --更新当前下拉筛选列表右侧数字
    self:RegisterGameEvent(EventID.GatheringLogUpdateDropDownProgress, self.UpdateDropDownItemsProgress)
    --刷新HorTabs
    self:RegisterGameEvent(EventID.GatheringLogUpdateHorTabs, self.OnSelectionChangedHorTabs)
    --点击闹钟提示后更新应该选择的职业
    self:RegisterGameEvent(EventID.GatheringLogSetFiltraSelect, self.UpdateProfSelect)
    --获取跳转搜索结果
    self:RegisterGameEvent(EventID.GatheringLogSearch, self.OnGetSearch)
    self:RegisterGameEvent(EventID.GatheringLogExitSearchState, self.ExitSearchState)
    self:RegisterGameEvent(EventID.CrystalTransferReq, self.SendDataReportor)
end

function GatheringLogMainPanelView:OnRegisterBinder()
    self:RegisterBinders(GatheringLogVM, self.Binders)
end

function GatheringLogMainPanelView:SendDataReportor()
    local CollectingID = _G.GatheringLogMgr.LastFilterState.GatherID--采集物ID
    if CollectingID then
        local CollectingTab = _G.GatheringLogMgr.LastFilterState.HorTabsIndex --所处的页签
        local CollectingType = MajorUtil.GetMajorProfID()--传送功能对应的职业ID
        DataReportUtil.ReportSystemFlowData("CollectnotesClickFlow", 1, CollectingID, CollectingTab, CollectingType)
    end
end

---@type 发送事件更新职业列表
function GatheringLogMainPanelView:UpdateProfessionList()
    --先处理到左边tab的职业ID和index（不是采矿工或园艺工的情况下，显示上次选中的，或默认的）
    local GatheringJobID = GatheringLogMgr:GetChoiceProfID()
    local ProfessionData = GatheringLogMgr.LeftProfessionData
    local Professionindex = GatheringLogMgr:GetProfIndexByProfID(GatheringJobID)
    self.VerIconTabs:UpdateItems(ProfessionData, Professionindex)
end

---@type 发送事件更新闹钟设置
function GatheringLogMainPanelView:UpdateClockSetting()
    local Setting = GatheringLogMgr.ClockSetting
    GatheringLogVM:SetClockSetting(Setting)
end

---@type 点击闹钟提示后更新应该选择的职业
---@param JobIndex number @职业的索引，1为采矿，2为园艺，3为都有
function GatheringLogMainPanelView:UpdateProfSelect(Params)
    local GatherItem = Params.GatherItem
    if GatherItem == nil then
        return
    end
    local GatheringJob = GatherItem.GatheringJob
    local LastFilterState = GatheringLogMgr.LastFilterState
    local IsSameVerIndex = LastFilterState.GatheringJobID == GatheringJob
    LastFilterState.GatheringJobID = GatheringJob

    local ClockIndex = GatheringLogDefine.HorBarIndex.ClockIndex
    local IsSameHorIndex = LastFilterState.HorTabsIndex == ClockIndex
    LastFilterState.HorTabsIndex = ClockIndex

    local DropIndex = 2
    if not Params.IsAppearing then
        local DropItems = GatheringLogMgr:UpdateDropData(GatheringJob, ClockIndex)
        if DropItems ~= nil then
            for Index, value in pairs(DropItems) do
                if value.Name == LSTR(70023) then
                    DropIndex = Index
                end
            end
        end
    end
    local IsSameDropIndex = LastFilterState.DropDownIndex == DropIndex
    LastFilterState.DropDownIndex = DropIndex
    self:SaveLastSelectProfessJob(GatheringJob)

    if not IsSameVerIndex then
        local VerIndex = GatheringLogMgr:GetProfIndexByProfID(GatheringJob)
        self.VerIconTabs:SetSelectedIndex(VerIndex)
    elseif not IsSameHorIndex then
        self.HorTabs:SetSelectedIndex(ClockIndex)
    elseif not IsSameDropIndex then
        self.DropDown:SetSelectedIndex(DropIndex)
    end

    local SelectIndex = GatheringLogVM:UpdateSelectItemTab(GatherItem.ID)
    if SelectIndex then
        self.TableViewListAdapter:ScrollToIndex(SelectIndex)
    end

    local AlarmExistProf = GatheringLogMgr.AlarmExistProf
    AlarmExistProf.bMiner = false
    AlarmExistProf.bBotanist = false
end

---@type 职业选择变化
---@param ProfessionIndex number @职业索引
function GatheringLogMainPanelView:OnSelectionChangedVerIconTabs(ProfessionIndex)
    self:ExitSearchState()
    self:PlayAnimation(self.AnimPanelIn1)
    --拿到上一次选择的职业ID（选择开始储存ID），保存上一次选择的各个属性（选择被替换时储存属性）
    local GatheringJobID = GatheringLogMgr:GetChoiceProfID()
    self:SaveLastSelectProfessJob(GatheringJobID)
    
    --根据当前职业ID获取当前职业保存的各个属性，并储存当前选择的职业ID
    local CurProfessionData = GatheringLogMgr.LeftProfessionData[ProfessionIndex]
    local LastSelectProfess = self:SaveSelectProfID(CurProfessionData)
    -- 加载当前职业上一次的选中状态,如果是第一次打开则加载默认
    local HorTabsID = LastSelectProfess.HorTabsID or 1
    local HorTabsIndex = GatheringLogMgr.LastFilterState.HorTabsIndex
    self.HorTabs:SetSelectedIndex(HorTabsID)
    if HorTabsIndex and HorTabsIndex == HorTabsID then
        self:OnSelectionChangedHorTabs(HorTabsID)
    end
    GatheringLogVM.TextSubTitle = CurProfessionData.ProfessionName

    --前往转职按钮
    self.InfoPage:SetSwichProfState(CurProfessionData.IsLock, CurProfessionData.ProfID)

    _G.ObjectMgr:CollectGarbage(false, true, false)
end

function GatheringLogMainPanelView:SetSwichProfBtnState(Prof)
    if Prof ~= nil then
        local IsLock =GatheringLogMgr:GetCurProfbLock(Prof)
        self.InfoPage:SetSwichProfState(IsLock, Prof)
    end
end

---@type 保存选择的职业ID
---@param CurProfessionData table @目前玩家玩家的信息
function GatheringLogMainPanelView:SaveSelectProfID(CurProfessionData)
    local ProfessType = ProtoCommon.prof_type
    local LastSelectProfess
    local LastFilterState = GatheringLogMgr.LastFilterState
    --为采矿工
    if CurProfessionData.ProfID == ProfessType.PROF_TYPE_MINER then
        --为园艺工
        LastFilterState.GatheringJobID = ProfessType.PROF_TYPE_MINER
        LastSelectProfess = GatheringLogMgr.LastSelectProfessMiner
    elseif CurProfessionData.ProfID == ProfessType.PROF_TYPE_BOTANIST then
        LastFilterState.GatheringJobID = ProfessType.PROF_TYPE_BOTANIST
        LastSelectProfess = GatheringLogMgr.LastSelectProfessBotanist
    end
    return LastSelectProfess
end

---@type 保存上一次选择职业的各个属性
---@param LastGatheringJobID number @选择的职业ID
function GatheringLogMainPanelView:SaveLastSelectProfessJob(LastGatheringJobID)
    local ProfessType = ProtoCommon.prof_type
    local LastSelectProfess = GatheringLogMgr.LastSelectProfessMiner
    if LastGatheringJobID == ProfessType.PROF_TYPE_MINER then
        LastSelectProfess = GatheringLogMgr.LastSelectProfessMiner
    elseif LastGatheringJobID == ProfessType.PROF_TYPE_BOTANIST then
        LastSelectProfess = GatheringLogMgr.LastSelectProfessBotanist
    end

    local LastFilterState = GatheringLogMgr.LastFilterState
    LastSelectProfess.HorTabsID = LastFilterState.HorTabsIndex
    LastSelectProfess.DropDownID = LastFilterState.DropDownIndex
    LastSelectProfess.GatherID = LastFilterState.GatherID

    GatheringLogMgr:SaveHorbarData(LastGatheringJobID, true)
end

---@type 当切换上方水平列表
---@param HorTabindex number @水平列表索引
function GatheringLogMainPanelView:OnSelectionChangedHorTabs(HorTabindex)
    --存上次的数据，存到对应的职业下面
    local LastFilterState = GatheringLogMgr.LastFilterState
    local GatheringJobID = GatheringLogMgr:GetChoiceProfID()
    GatheringLogMgr:SaveHorbarData(GatheringJobID, false)

    --存当前的Index
    LastFilterState.HorTabsIndex = HorTabindex
    self.HorTabs.SelectedIndex = HorTabindex
    --存完之后再刷新
    if GatheringLogMgr.SearchState ~= 0 then
        local VerIndex = GatheringLogMgr:GetProfIndexByProfID(GatheringLogMgr.LastFilterState.GatheringJobID)
        self.VerIconTabs:SetSelectedIndex(VerIndex)
        return
    end

    self:PlayAnimation(self.AnimPanelIn1)
    self.DropDown:SetForceTrigger(true)
    --拿到要更新的下拉列表的数据
    local DropData = GatheringLogMgr:UpdateDropData(GatheringJobID, HorTabindex)
    if #DropData < 1 then
        self:OnClearDropDownData()
        return
    else
        UIUtil.SetIsVisible(self.DropDown, true)
        UIUtil.SetIsVisible(self.BtnSort, true, true)
    end
    --调到这里后会先调 OnSelectionChangedDropDown 函数（当切换下拉筛选列表：处理下拉框筛选条件下的采集物有无和展示） 再往下调用

    --且拿到当前index在当前职业在上次被选时的（选择高亮index）数据，加载
    local LastSelectHorbarData = GatheringLogMgr:GetLastSelectHorbarData(GatheringJobID, HorTabindex)
    local DefaultDropDownIndex = 1
    if #DropData >= DefaultDropDownIndex then
        if LastSelectHorbarData.DorpDownIndex then
            DefaultDropDownIndex = LastSelectHorbarData.DorpDownIndex 
        elseif HorTabindex == GatheringLogDefine.HorBarIndex.NormalIndex then
            if MajorUtil.IsGatherProf() then
                local ProfLevel = MajorUtil.GetMajorLevelByProf(LastFilterState.GatheringJobID) or 1
                DefaultDropDownIndex = (ProfLevel - 1) // 5 + 1
                if GatheringLogMgr.ReverseOrder then
                    local Total = GatheringLogDefine.MaxLevel//5
                    DefaultDropDownIndex = Total + 1 - DefaultDropDownIndex
                end
            end
        end
    end
    --更新下拉框的显示
    self.DropDown:UpdateItems(DropData, DefaultDropDownIndex)

    ----防止加载采集物之前先获取了空ID, 然后选择采集物高亮
    local GatherID = LastSelectHorbarData.GatherID or GatheringLogVM:GetSelectGatherID()
    if GatherID then
        local SelectedItemIndex = GatheringLogVM:UpdateSelectItemTab(GatherID)
        self.TableViewListAdapter:ScrollToIndex(SelectedItemIndex)
    end
end

---@type 当切换下拉筛选列表
---@param index number @下拉筛选列表索引
function GatheringLogMainPanelView:OnSelectionChangedDropDown(index)
    local Data = self.DropDown:GetDropDownItemDataByIndex(index)
	if Data and Data.Name == LSTR(70042) then --不限
		return
	end
    local LastFilterState = GatheringLogMgr.LastFilterState
    self.DropDown:SetForceTrigger(false)
    
    if self.bPlayAnimation then
        self:PlayAnimation(self.AnimPanelIn2)
    end
    self.bPlayAnimation = true

    local HorTabsIndex = LastFilterState.HorTabsIndex or 1
    local GatheringJobID = GatheringLogMgr:GetChoiceProfID()
    LastFilterState.DropDownIndex = index
    --拿到要更新的下拉列表的数据
    local DropData = GatheringLogMgr:UpdateDropData(GatheringJobID, HorTabsIndex)
    --假如下拉列表第一个没有
    if DropData[1] == nil or DropData[index] == nil then
        LastFilterState.GatherID = nil
        UIUtil.SetIsVisible(self.InfoPage, false)
        GatheringLogVM.bTextListEmptyVisible = true
        GatheringLogVM.CurLogItemVMList:Clear()
        return
    end

    self.DropDown.TextQuantity:SetText(DropData[index].TextQuantityStr or "")
    --根据DropDown所选择的条件筛选采集物
    local Condition = DropData[index]
    local GatherItemData = GatheringLogMgr:UpdataItems(GatheringJobID, Condition, HorTabsIndex)

    --采集物的红点显示,下拉框选项红点的消失
    local DropdownIndex = DropData[index].DropdownIndex
    local DropResDotName = GatheringLogMgr:GetRedDotName(GatheringJobID, HorTabsIndex, DropdownIndex)

    if DropResDotName then
        local SpecialType = GatheringLogDefine.SpecialType
		local DropRedNode =  _G.RedDotMgr:FindRedDotNodeByName(DropResDotName)
        local ReadData = GatheringLogMgr:GetSpecialReadData(GatheringJobID, DropdownIndex)
		local ReadVersion = ReadData and ReadData.ReadVersion or 0
		local Volume = ReadData and ReadData.Volume or 0
        if (DropdownIndex == SpecialType.SpecialTypeCollection or DropdownIndex == SpecialType.SpecialTypeInherit ) and DropRedNode.IsStrongReminder == true then
            _G.RedDotMgr:DelRedDotByName(DropResDotName)
            if DropdownIndex == SpecialType.SpecialTypeInherit then
                GatheringLogMgr:SendMsgRemoveDropNewData(GatheringJobID, nil, DropdownIndex, nil, true)
            elseif DropdownIndex == SpecialType.SpecialTypeCollection then
                GatheringLogMgr.SpecialDropRedDotLists[GatheringJobID][SpecialType.SpecialTypeCollection] = {ReadVersion=0, Volume=0, IsRead=true, SpecialType=3}
				GatheringLogMgr:SpecialRedDotDataUpdate(GatheringJobID)
				_G.EventMgr:SendEvent(EventID.UpdateTabRedDot)
                    self:OnSelectionChangedHorTabs(2)
            end
            DropResDotName = GatheringLogMgr:GetRedDotName(GatheringJobID, HorTabsIndex, DropdownIndex, GatheringLogDefine.RedDotID.GarherLogProf)
            DropRedNode =  _G.RedDotMgr:FindRedDotNodeByName(DropResDotName)
        end

        if DropRedNode then
            if table.is_nil_empty(DropRedNode.SubRedDotList) then
                DropRedNode.SubRedDotList = {}
                if GatherItemData and #GatherItemData > 0 then
                    for _, Item in pairs(GatherItemData) do
                        if Item.TextTips == nil 
                        and ((HorTabsIndex == 2 and DropdownIndex == SpecialType.SpecialTypeCollection)-- and ReadVersion < Item.GatheringGrade )
                        or (HorTabsIndex == 2 and DropdownIndex == SpecialType.SpecialTypeInherit and ReadVersion < GatheringLogMgr:VersionNameToNum(Item.VersionName) or (ReadVersion == GatheringLogMgr:VersionNameToNum(Item.VersionName) and GatheringLogMgr:IsHaveUnReadLInheritVolume(GatheringJobID, Volume)))
                        or HorTabsIndex == 1) then
                            local Name = string.format("%s/%s",DropResDotName,Item.Name)
                            _G.RedDotMgr:AddRedDotByName(Name)
                            GatheringLogMgr.GatherItemRedDotNameList[Item.ID] = Name
                        end
                    end
                end
            end
    
            if HorTabsIndex == GatheringLogDefine.HorBarIndex.NormalIndex then
                if GatheringLogMgr.CancelNormalDropRedDotLists == nil then
                    GatheringLogMgr.CancelNormalDropRedDotLists = {}
                end
                if GatheringLogMgr.CancelNormalDropRedDotLists[GatheringJobID] == nil then
                    GatheringLogMgr.CancelNormalDropRedDotLists[GatheringJobID] = {}
                end
                GatheringLogMgr.CancelNormalDropRedDotLists[GatheringJobID][DropdownIndex] = true
            elseif HorTabsIndex == GatheringLogDefine.HorBarIndex.SpecialIndex then
                if GatheringLogMgr.CancelSpecialDropRedDotLists == nil then
                    GatheringLogMgr.CancelSpecialDropRedDotLists = {}
                end
                if GatheringLogMgr.CancelSpecialDropRedDotLists[GatheringJobID] == nil then
                    GatheringLogMgr.CancelSpecialDropRedDotLists[GatheringJobID] = {}
                end
                GatheringLogMgr.CancelSpecialDropRedDotLists[GatheringJobID][DropdownIndex] = true
            end
        end
    end

    --如果传承录都没有解锁
    if LastFilterState.HorTabsIndex == GatheringLogDefine.HorBarIndex.SpecialIndex then
        local TextQuantityStr = DropData[index].TextQuantityStr
        if TextQuantityStr then
            local ItemsCountStr = string.sub(TextQuantityStr, -1)
            if tonumber(ItemsCountStr) == 0 then
                UIUtil.SetIsVisible(self.InfoPage, false)
                GatheringLogVM:UpdateGatheringItemTypesList(GatherItemData)
                if GatheringLogVM.HaveGatherItem == false then
                    self.BackpackEmpty:SetTipsContent(LSTR(GatheringLogDefine.SpecialListEmpty))
                    GatheringLogVM.bTextListEmptyVisible = true
                else
                    GatheringLogVM.bTextListEmptyVisible = false
                end
                return
            end
        end
    end

    --假如选择的下拉列表条件下，没有采集物：右侧的页面条件隐藏
    if #GatherItemData < 1 then
        LastFilterState.GatherID = nil
    else
        UIUtil.SetIsVisible(self.InfoPage, true)
    end

    --加载Item列表
    GatheringLogVM:UpdateGatheringItemTypesList(GatherItemData)
    self:SetItemEmptyTipAndSelect()
    self.TableViewListAdapter:ScrollToTop()


    if HorTabsIndex == GatheringLogDefine.HorBarIndex.NormalIndex then
        self.ChangeDropCount = (self.ChangeDropCount or 0) + 1
        if self.ChangeDropCount >= 4 then
            self.ChangeDropCount = 0
            _G.ObjectMgr:CollectGarbage(false, true, false)
        end
	end
end

---@type 更新下拉筛选列表
---@param HorbarIndex number @水平筛选框索引
function GatheringLogMainPanelView:UpdateDropDownFilter(HorbarIndex)
    local LastFilterState = GatheringLogMgr.LastFilterState
    local GatheringJobID = LastFilterState.GatheringJobID
    local DropData = GatheringLogMgr:UpdateDropData(GatheringJobID, HorbarIndex)
    if #DropData < 1 then
        self:OnClearDropDownData()
        return
    end
    if LastFilterState.DropDownIndex > #DropData then
        LastFilterState.DropDownIndex = 1
    end
    self.bPlayAnimation = false
    self.DropDown:SetForceTrigger(true)
    local DorpDownIndex = LastFilterState.DropDownIndex or 1
    self.DropDown:UpdateItems(DropData, DorpDownIndex)
end

---@type 更新当前下拉筛选列表右侧数字
function GatheringLogMainPanelView:UpdateDropDownItemsProgress()
    local LastFilterState = GatheringLogMgr.LastFilterState
    local GatheringJobID = GatheringLogMgr:GetChoiceProfID()
    local DropData = GatheringLogMgr:UpdateDropData(GatheringJobID, LastFilterState.HorTabsIndex)
    local DropDownIndex = LastFilterState.DropDownIndex
    self.DropDown:UpdateItems(DropData, DropDownIndex)
    self.DropDown.TextQuantity:SetText(DropData[DropDownIndex].TextQuantityStr or "")
end

---@type 当没有下拉筛选列表数据时
function GatheringLogMainPanelView:OnClearDropDownData()
    self:SetEmptyList()
    GatheringLogVM.CurLogItemVMList:Clear()
    GatheringLogVM.bNoConditionVisible = false
    UIUtil.SetIsVisible(self.DropDown, false)
    UIUtil.SetIsVisible(self.BtnSort, false)
end

---@type 列表为空时的设置
function GatheringLogMainPanelView:SetEmptyList()
    GatheringLogVM.bTextListEmptyVisible = true
    if GatheringLogMgr.LastFilterState.HorTabsIndex == GatheringLogDefine.HorBarIndex.CollectionIndex then
        self.BackpackEmpty:SetTipsContent(LSTR(GatheringLogDefine.TextListEmptyCollection))
    elseif GatheringLogMgr.LastFilterState.HorTabsIndex == GatheringLogDefine.HorBarIndex.SpecialIndex then
        self.BackpackEmpty:SetTipsContent(LSTR(GatheringLogDefine.SpecialListEmpty))
    else
        self.BackpackEmpty:SetTipsContent(LSTR(GatheringLogDefine.TextListEmpty))
    end
    UIUtil.SetIsVisible(self.InfoPage, false)
    GatheringLogVM.CurGatherPlaceVMList:Clear()
    GatheringLogVM.bVerticalConditionsVisible = false
    GatheringLogMgr.LastFilterState.GatherID = nil
end

---@type 有采集物或没有采集物进行不同的设置
function GatheringLogMainPanelView:SetItemEmptyTipAndSelect()
    if self.IsUpdateLastSelectPorf then
        self.IsUpdateLastSelectPorf = false
        return
    end
    local Length = GatheringLogVM.CurLogItemVMList:Length()
    if Length >= 1 then
        local Elem = GatheringLogVM.CurLogItemVMList:Get(1)
        GatheringLogVM:UpdateSelectItemTab(Elem.ID)
        GatheringLogVM.bTextListEmptyVisible = false
        GatheringLogVM.bVerticalConditionsVisible = true
        UIUtil.SetIsVisible(self.InfoPage, true)
        --如果是列表中只有传承录提示item，也要展示空页签在右侧
        if GatheringLogVM.HaveGatherItem == false and GatheringLogMgr.LastFilterState.HorTabsIndex == GatheringLogDefine.HorBarIndex.SpecialIndex then
            self.BackpackEmpty:SetTipsContent(LSTR(GatheringLogDefine.SpecialListEmpty))
            GatheringLogVM.bTextListEmptyVisible = true
        end
    else
        self:SetEmptyList()
    end
end

function GatheringLogMainPanelView:OnBtnSorting()
    GatheringLogMgr:OnBtnSorting(self.DropDown)
end

---@type 获取跳转搜索
function GatheringLogMainPanelView:OnGetSearch(Name)
    GatheringLogMgr.SearchState = GatheringLogDefine.SearchState.BeforSearch
    self.InputSearch:SetText(Name)
	self:OnSearchTextCommitted(Name)
end

---@type 点击搜索
function GatheringLogMainPanelView:OnBtnSearchClick()
    FLOG_INFO("GatheringLogMainPanelView:OnBtnSearchClick")
    GatheringLogMgr.SearchState = GatheringLogDefine.SearchState.BeforSearch
    --记录搜索前的ItemID
    local LastFilterState = GatheringLogMgr.LastFilterState
    LastFilterState.GatherIDBeforeSearch = LastFilterState.GatherID

    self:ShowSearchHistory(true)
    --self.InputSearch:SetText("")
end

function GatheringLogMainPanelView:ShowSearchHistory(HistoryVisible)
	if self.HistoryVisible ~= nil and self.HistoryVisible == HistoryVisible then
        FLOG_INFO("GatheringLogMainPanelView:ShowSearchHistory self.HistoryVisible == HistoryVisible")
		--return
	end
	self.HistoryVisible = HistoryVisible
	UIUtil.SetIsVisible(self.SearchHistory,HistoryVisible)
	UIUtil.SetIsVisible(self.PanelTabList,not HistoryVisible)
    UIUtil.SetIsVisible(self.CommonBookBkg, not HistoryVisible)
    local InputSearch = self.InputSearch
    local FSlateColor = _G.UE.FSlateColor
    local FLinearColor = _G.UE.FLinearColor
    if HistoryVisible then
        UIUtil.SetIsVisible(self.InfoPage, false)
        GatheringLogVM.bTextListEmptyVisible = false
        InputSearch.SytleType = CommUIStyleType.Dark
        InputSearch.InputTextColor = FSlateColor(FLinearColor.FromHex("#d5d5d5")) --白
    else
        local bShowInfoPage = GatheringLogMgr.LastFilterState.GatherID ~= nil
        UIUtil.SetIsVisible(self.InfoPage, bShowInfoPage)
        InputSearch.SytleType = CommUIStyleType.Light
        InputSearch.InputTextColor = FSlateColor(FLinearColor.FromHex("#313131")) --黑
    end
    InputSearch:UpdateStyle()
    InputSearch:SetInputTextWidgetStyle(#InputSearch:GetText() <= 0)
    self.VerIconTabs.AdapterTabs:SetAlwaysNotifySelectChanged(HistoryVisible)
end

---@type 如果是点击采集物进入的搜索填ItemID搜索有默认选择该Item
function GatheringLogMainPanelView:OnSearchTextCommitted(SearchText)
	if string.isnilorempty(SearchText) then
        return
    end
    self:PlayAnimation(self.AnimSearchBack)
    self:ShowSearchHistory(false)
    GatheringLogMgr.SearchState = GatheringLogDefine.SearchState.InSearching
    --保存历史记录
    local SearchRecord = {}
    local HistoryList = GatheringLogMgr.SearchRecordList
    local bNeedData = true
    if #HistoryList > 0 then
        for i = 1, #HistoryList do
            local Elem = HistoryList[i]
            if Elem.SearchText == SearchText then
                bNeedData = false
                break
            end
        end
    end
    if bNeedData then
        SearchRecord.SearchText = SearchText
        local SearchRecordOrderNum = GatheringLogMgr.SearchRecordOrderNum
        SearchRecord.SearchRecordOrderNum = SearchRecordOrderNum + 1
        GatheringLogMgr.SearchRecordOrderNum = SearchRecordOrderNum + 1
        table.insert(GatheringLogMgr.SearchRecordList, SearchRecord)
        table.sort(GatheringLogMgr.SearchRecordList, GatheringLogMgr.SortSearchRecord)
        local MaxHistoryNum = 6
        local NewHistoryList = GatheringLogMgr.SearchRecordList
        if #NewHistoryList > MaxHistoryNum then
            NewHistoryList[MaxHistoryNum + 1] = nil
        end
    end

    GatheringLogVM.GatherItemProf = nil
    --取消所有页签的选中
    self.VerIconTabs.AdapterTabs:CancelSelected()
    self.HorTabs:CancelSelected()
    self.DropDown:CancelSelected()
    --下拉框显示不限，且不可切换
    UIUtil.SetIsVisible(self.BtnSort, true, true)
    UIUtil.SetIsVisible(self.DropDown, true)
    UIUtil.SetIsVisible(self.DropDown.TextQuantity,false)
    self.DropDown:UpdateItems({{Name = LSTR(70042)}}, 1) --70042不限
    self.DropDown.ToggleBtnExtend:SetCheckedState(_G.UE.EToggleButtonState.Locked)
    --隐藏左上角副标题
    GatheringLogVM.bSubTitleVisible = false
    GatheringLogMgr.LastFilterState.IDofSearchItem = nil

    --显示搜索结果
    local Result =  GatheringLogVM:GetSearchResultList(SearchText)
    GatheringLogVM:UpdateGatheringItemTypesList(Result)
    self:SetItemEmptyTipAndSelect()
    self.TableViewListAdapter:ScrollToTop()
    if table.is_nil_empty(Result) then
        self.BackpackEmpty:SetTipsContent(LSTR(GatheringLogDefine.GetNoSearchResult))
    end
end

function GatheringLogMainPanelView:OnTextFocusLost()
    UIUtil.SetIsVisible(self.InputSearch.BtnCancelNode, true,true)
end

---@type 点击关闭
function GatheringLogMainPanelView:OnSearchCloseBtnClick()
    self:PlayAnimation(self.AnimSearchBack)
    self:ShowSearchHistory(false)
    local LastFilterState = GatheringLogMgr.LastFilterState
    local ID = LastFilterState.IDofSearchItem
    if ID ~= nil then
        GatheringLogVM:SaveSearchSelectData(ID)
        self:SaveLastSelectProfessJob(LastFilterState.GatheringJobID)
        LastFilterState.IDofSearchItem = nil
    end
    local VerIndex = GatheringLogMgr:GetProfIndexByProfID(LastFilterState.GatheringJobID)
    self.VerIconTabs:SetSelectedIndex(VerIndex)
    --刷新的时候就一连串都刷新了，且在页签改变时退出搜索状态,但是下拉框选项刷新的时候会选中列表中第一个Item
    local SelectID = ID or LastFilterState.GatherIDBeforeSearch
    if SelectID == nil then
        if LastFilterState.GatherID == nil then
            self:OnClearDropDownData()
        end
    else
        local SelectIndex = GatheringLogVM:UpdateSelectItemTab(SelectID)
        if SelectIndex then
            self.TableViewListAdapter:ScrollToIndex(SelectIndex)
        end
    end
    self:ExitSearchState()
end

---@type 退出搜索状态
function GatheringLogMainPanelView:ExitSearchState()
    if GatheringLogMgr.SearchState == 0 then
        return
    end
    FLOG_INFO("GatheringLogMainPanelView:ExitSearchState")
    self.InputSearch:SetText("")
    self:ShowSearchHistory(false)
    GatheringLogMgr.SearchState = 0
    self.DropDown.ToggleBtnExtend:SetCheckedState(_G.UE.EToggleButtonState.Unchecked)
    GatheringLogVM.bSubTitleVisible = true
    UIUtil.SetIsVisible(self.DropDown.TextQuantity,true)
    UIUtil.SetIsVisible(self.InputSearch.BtnCancelNode, false)
    GatheringLogVM.GatherItemProf = nil
end

return GatheringLogMainPanelView
