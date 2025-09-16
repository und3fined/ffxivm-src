---
--- Author: michaelyang_lightpaw
--- DateTime: 2024-08-29 09:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local FateEventStatisticsVM = require("Game/FateArchive/VM/FateEventStatisticsVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local FateArchiveWorldEventTabItemVM = require("Game/FateArchive/VM/FateArchiveWorldEventTabItemVM")
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
local MapUtil = require("Game/Map/MapUtil")

local LSTR = _G.LSTR

local LeftTabType = {
    None = 0,
    WorldEvent = 1,
    MyEvent = 2
}
---@class FateEventStatisticsNewPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnChange UFButton
---@field PanelEvent UFCanvasPanel
---@field PanelMap UFCanvasPanel
---@field PanelMonster UFCanvasPanel
---@field PanelMyEvent UFCanvasPanel
---@field PanelSpoil UFCanvasPanel
---@field PanelWorldEvent UFCanvasPanel
---@field SingleBoxNotOwn CommSingleBoxView
---@field TableViewEvent UTableView
---@field TableViewMap UTableView
---@field TableViewMonster UTableView
---@field TableViewMyEvent UTableView
---@field TableViewSpoil UTableView
---@field TableViewWorldEventType UTableView
---@field TextBigTitle UFTextBlock
---@field TextChange UFTextBlock
---@field TextFinish UFTextBlock
---@field TextNotOwn UFTextBlock
---@field TextOwn UFTextBlock
---@field TextRarity UFTextBlock
---@field TextSubTitle UFTextBlock
---@field TextTopEventTitle UFTextBlock
---@field TextTopMonsterTitle UFTextBlock
---@field ToggleBtnMyEvent UToggleButton
---@field ToggleBtnWorldEvent UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimToggleBtnMyEventChecked UWidgetAnimation
---@field AnimToggleBtnMyEventUnChecked UWidgetAnimation
---@field AnimToggleBtnWorldEventChecked UWidgetAnimation
---@field AnimToggleBtnWorldEventUnChecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateEventStatisticsNewPanelView = LuaClass(UIView, true)

function FateEventStatisticsNewPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnChange = nil
	--self.PanelEvent = nil
	--self.PanelMap = nil
	--self.PanelMonster = nil
	--self.PanelMyEvent = nil
	--self.PanelSpoil = nil
	--self.PanelWorldEvent = nil
	--self.SingleBoxNotOwn = nil
	--self.TableViewEvent = nil
	--self.TableViewMap = nil
	--self.TableViewMonster = nil
	--self.TableViewMyEvent = nil
	--self.TableViewSpoil = nil
	--self.TableViewWorldEventType = nil
	--self.TextBigTitle = nil
	--self.TextChange = nil
	--self.TextFinish = nil
	--self.TextNotOwn = nil
	--self.TextOwn = nil
	--self.TextRarity = nil
	--self.TextSubTitle = nil
	--self.TextTopEventTitle = nil
	--self.TextTopMonsterTitle = nil
	--self.ToggleBtnMyEvent = nil
	--self.ToggleBtnWorldEvent = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimToggleBtnMyEventChecked = nil
	--self.AnimToggleBtnMyEventUnChecked = nil
	--self.AnimToggleBtnWorldEventChecked = nil
	--self.AnimToggleBtnWorldEventUnChecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateEventStatisticsNewPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.SingleBoxNotOwn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateEventStatisticsNewPanelView:OnInit()
    self.TextRarity:SetText(LSTR(190039))
    self.TextFinish:SetText(LSTR(190038))
    self.TextChange:SetText(LSTR(190092))
    self.TextBigTitle:SetText(LSTR(190036))
    self.TextNotOwn:SetText(LSTR(190043))
    self.TextTopMonsterTitle:SetText(LSTR(190034))
    self.TextTopEventTitle:SetText(LSTR(190035))

    self.CurLeftTablType = LeftTabType.None
    self.MapEventForWorld = true
    self.ViewModel = FateEventStatisticsVM
    self.AdapterFateTypeList =
        UIAdapterTableView.CreateAdapter(self, self.TableViewWorldEventType, self.OnTableViewWorldEventTypeChanged)
    self.AdapterTableViewMonster = UIAdapterTableView.CreateAdapter(self, self.TableViewMonster)
    self.AdapterTableViewEvent = UIAdapterTableView.CreateAdapter(self, self.TableViewEvent)
    self.AdapterTableViewSpoil = UIAdapterTableView.CreateAdapter(self, self.TableViewSpoil)
    self.AdapterTableViewMap = UIAdapterTableView.CreateAdapter(self, self.TableViewMap)
    self.AdapterTableViewMyEvent = UIAdapterTableView.CreateAdapter(self, self.TableViewMyEvent)
    self.Binders = {
        {"FateEventTypeList", UIBinderUpdateBindableList.New(self, self.AdapterFateTypeList)},
        {"bShowPanelWorldEvent", UIBinderSetIsVisible.New(self, self.PanelWorldEvent)},
        {"bShowPanelMyEvent", UIBinderSetIsVisible.New(self, self.PanelMyEvent)},
        {"SelectedType", UIBinderValueChangedCallback.New(self, nil, self.SetSelectedType)}
    }
    self.IsNotDefeatMonster = false
    self.IsNotDefeatEvent = false
    self.IsNotOwnedSpoil = false
end

function FateEventStatisticsNewPanelView:OnTableViewWorldEventTypeChanged(Index, ItemData, ItemView, bClick)
    self:PlayAnimation(self.AnimChangeWorldEvent)
    local Type = ItemData.Type
    self.ViewModel:SelectType(Type)
    _G.ObjectMgr:CollectGarbage(false)
end

function FateEventStatisticsNewPanelView:OnDestroy()
end

function FateEventStatisticsNewPanelView:OnShow()
    self.IsFirstUpdate = true
    self.ViewModel:OnShow()
    self:OnToggleBtnWorldEvent(self.ToggleBtnWorldEvent, _G.UE.EToggleButtonState.Checked)
    self.AdapterFateTypeList:SetSelectedIndex(1)
    self.bCanExit = false
    self:RegisterTimer(
        function()
            self.bCanExit = true
        end,
        1.5,
        0,
        1
    )
end

function FateEventStatisticsNewPanelView:OnHide()
    self.MyEventProgressTable = nil
    self.IsFirstUpdate = false
    self.bCanExit = true
end

function FateEventStatisticsNewPanelView:OnRegisterUIEvent()
    self.BtnBack:AddBackClick(
        self,
        function(TargetUIView)
            if (self.bCanExit) then
                _G.EventMgr:SendEvent(EventID.FateCloseStatisticsPanel)
                self:Hide()
            end
        end
    )

    UIUtil.AddOnClickedEvent(self, self.BtnChange, self.OnClickBtnChange)
    UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnWorldEvent, self.OnToggleBtnWorldEvent)
    UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnMyEvent, self.OnToggleBtnMyEvent)
    UIUtil.AddOnStateChangedEvent(self, self.SingleBoxNotOwn, self.OnSingleBoxNotOwnClick)
end

function FateEventStatisticsNewPanelView:OnClickBtnChange()
    self.MapEventForWorld = not self.MapEventForWorld
    if (self.MapEventForWorld) then
        self.TextChange:SetText(LSTR(190092))
    else
        self.TextChange:SetText(LSTR(190093))
    end
    self:SetSelectedType(self.SelectedType)
end

function FateEventStatisticsNewPanelView:RefreshForMapEvent()
end

function FateEventStatisticsNewPanelView:OnRegisterGameEvent()
end

function FateEventStatisticsNewPanelView:OnRegisterBinder()
    self:RegisterBinders(self.ViewModel, self.Binders)
end

function FateEventStatisticsNewPanelView:OnSingleBoxNotDefeatClick(ToggleButton, ButtonState)
    self.IsNotDefeatMonster = ButtonState == _G.UE.EToggleButtonState.Checked
    self:UpdateMonsterList()
end

function FateEventStatisticsNewPanelView:OnSingleBoxNotDefeat1Click(ToggleButton, ButtonState)
    self.IsNotDefeatEvent = ButtonState == _G.UE.EToggleButtonState.Checked
    self:UpdateEventList()
end

function FateEventStatisticsNewPanelView:OnSingleBoxNotOwnClick(ToggleButton, ButtonState)
    self.IsNotOwnedSpoil = ButtonState == _G.UE.EToggleButtonState.Checked
    self:UpdateSpoilList()
end

function FateEventStatisticsNewPanelView:OnToggleBtnWorldEvent(ToggleButton, State)
    if (self.CurLeftTablType == LeftTabType.WorldEvent) then
        return
    end
    _G.ObjectMgr:CollectGarbage(false)
    if UIUtil.IsToggleButtonChecked(State) then
        self.TextSubTitle:SetText(LSTR(190094))
        self.CurLeftTablType = LeftTabType.WorldEvent
        self:PlayAnimation(self.AnimToggleBtnWorldEventChecked)
        self:PlayAnimation(self.AnimToggleBtnMyEventUnChecked)

        self.ToggleBtnMyEvent:SetChecked(false, false)
        self.ToggleBtnWorldEvent:SetChecked(true, false)
        self.ViewModel:RefreshWorldEvent()
    else
        self:PlayAnimation(self.AnimToggleBtnWorldEventUnChecked)
    end
end

function FateEventStatisticsNewPanelView:OnToggleBtnMyEvent(ToggleButton, State)
    if (self.CurLeftTablType == LeftTabType.MyEvent) then
        return
    end
    _G.ObjectMgr:CollectGarbage(false)
    if UIUtil.IsToggleButtonChecked(State) then
        self.TextSubTitle:SetText(LSTR(190095))
        self.CurLeftTablType = LeftTabType.MyEvent
        self:PlayAnimation(self.AnimToggleBtnWorldEventUnChecked)
        self:PlayAnimation(self.AnimToggleBtnMyEventChecked)

        self.ToggleBtnWorldEvent:SetChecked(false, false)
        self.ToggleBtnMyEvent:SetChecked(true, false)
        self.ViewModel:RefreshMyEvent()
        local TempList = FateMgr:GetMyEventData()
        if (self.IsFirstUpdate) then
            self.IsFirstUpdate = false
            self.AdapterTableViewMyEvent:UpdateAll(TempList)
        end
    else
        self:PlayAnimation(self.AnimToggleBtnMyEventUnChecked)
    end
end

function FateEventStatisticsNewPanelView:SetSelectedType(Type)
    self.SelectedType = Type
    UIUtil.SetIsVisible(self.PanelMonster, Type == ProtoCS.CS_FATE_STATS.CS_FATE_STATS_POWERFUL_MONSTER)
    UIUtil.SetIsVisible(self.PanelEvent, Type == ProtoCS.CS_FATE_STATS.CS_FATE_STATS_DIFFICULT_FATE)
    UIUtil.SetIsVisible(self.PanelMap, Type == ProtoCS.CS_FATE_STATS.CS_FATE_STATS_MAP_PROGRESS)

    self.CurSelectTypeDataList = FateMgr:GetWorldEventData(Type)

    if Type == ProtoCS.CS_FATE_STATS.CS_FATE_STATS_POWERFUL_MONSTER then
        self:UpdateMonsterList()
    elseif Type == ProtoCS.CS_FATE_STATS.CS_FATE_STATS_DIFFICULT_FATE then
        self:UpdateEventList()
    elseif Type == ProtoCS.CS_FATE_STATS.CS_FATE_STATS_MAP_PROGRESS then
        if (self.MapEventForWorld) then
            self.AdapterTableViewMap:UpdateAll(self.CurSelectTypeDataList)
        else
            -- 自己的进度
            self:InternalGetMyMapEventProgress()
            self.AdapterTableViewMap:UpdateAll(self.MyEventProgressTable)
        end
    end
end

function FateEventStatisticsNewPanelView:InternalGetMyMapEventProgress()
    if (self.MyEventProgressTable == nil) then
        self.MyEventProgressTable = {} -- Key : key , Value : table {ResID : MapID, Percent : progress}
    else
        return
    end

    if (self.Region2AreaTable == nil) then
        self.Region2AreaTable, self.Area2MapTable = MapUtil.GetRegionAndAreaTable()
        self.FateMapInfo, self.Fate2MapID = _G.FateMgr:GatherMapFateStageInfo()
    end

    for k, v in pairs(self.Region2AreaTable) do
        local AreaTable = v
        for k, v in pairs(AreaTable) do
            local TempList = self.Area2MapTable[v.ID]
            if (TempList ~= nil) then
                for Key, Value in pairs(TempList) do
                    local FateEventList = self.FateMapInfo[Value.ID]
                    if FateEventList ~= nil then
                        local NewTableData = {}
                        NewTableData.ResID = Value.ID
                        NewTableData.Percent = 0
                        table.insert(self.MyEventProgressTable, NewTableData)
                        local TotalCount = 0
                        local FinishCount = 0
                        TotalCount = TotalCount + #FateEventList * 4
                        for j = 1, #FateEventList do
                            local FateEvent = FateEventList[j]
                            local FateInfo = _G.FateMgr:GetFateInfo(FateEvent.ID)
                            if FateInfo ~= nil then
                                for k = 1, #FateInfo.Achievement do
                                    local Achievement = FateInfo.Achievement[k]
                                    if (Achievement ~= nil and Achievement.Target ~= nil and Achievement.Progress ~= nil) then
                                        local bFinished = Achievement.Target > 0 and Achievement.Progress >= Achievement.Target
                                        if bFinished then
                                            FinishCount = FinishCount + 1
                                        end
                                    end
                                end
                            end
                        end
                        if (TotalCount ~= 0) then
                            NewTableData.Percent = (FinishCount / TotalCount) * 100
                        end
                    end
                end
            end
        end
    end

    table.sort(
        self.MyEventProgressTable,
        function(Left, Right)
            if (Left.Percent == Right.Percent) then
                return Left.ResID > Right.ResID
            end
            return Left.Percent > Right.Percent
        end
    )
end

function FateEventStatisticsNewPanelView:UpdateMonsterList()
    local TempList = {}
    if self.IsNotDefeatMonster then
        for _, MonsterInfo in pairs(self.CurSelectTypeDataList) do
            local bIsDefeat = MonsterInfo.AvatarDone
            if not bIsDefeat then
                table.insert(TempList, MonsterInfo)
            end
        end
    else
        TempList = self.CurSelectTypeDataList
    end
    self.AdapterTableViewMonster:UpdateAll(TempList)
end

function FateEventStatisticsNewPanelView:UpdateEventList()
    local TempList = {}
    if self.IsNotDefeatEvent then
        for _, FateInfo in pairs(self.CurSelectTypeDataList) do
            local FateServerInfo = FateMgr:GetFateInfo(FateInfo.FateID)
            local bIsDefeat = (FateServerInfo ~= nil)
            if not bIsDefeat then
                table.insert(TempList, FateInfo)
            end
        end
    else
        TempList = self.CurSelectTypeDataList
    end
    self.AdapterTableViewEvent:UpdateAll(TempList)
end

function FateEventStatisticsNewPanelView:UpdateSpoilList()
    local TempList = {}
    local OwnedCount = 0
    for _, SpoilInfo in pairs(self.CurSelectTypeDataList) do
        local bIsDefeat = SpoilInfo.AvatarDone
        if self.IsNotOwnedSpoil then
            if not bIsDefeat then
                table.insert(TempList, SpoilInfo)
            end
        else
            table.insert(TempList, SpoilInfo)
        end
        if bIsDefeat then
            OwnedCount = OwnedCount + 1
        end
    end
    self.TextOwn:SetText(string.format(LSTR(190096), OwnedCount, #self.CurSelectTypeDataList))
    self.AdapterTableViewSpoil:UpdateAll(TempList)
end

return FateEventStatisticsNewPanelView
