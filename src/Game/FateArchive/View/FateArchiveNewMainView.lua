---
--- Author: michaelyang_lightpaw
--- DateTime: 2024-08-28 19:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local ProtoRes = require("Protocol/ProtoRes")
local MapDefine = require("Game/Map/MapDefine")
local FateAchievementRewardCfg = require("TableCfg/FateAchievementRewardCfg")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local FateArchiveMainVM = require("Game/FateArchive/VM/FateArchiveMainVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetActiveWidgetIndex = require("Binder/UIBinderSetActiveWidgetIndex")
local ModuleMapContentVM = require("Game/Map/VM/ModuleMapContentVM")
local MonsterCfg = require("TableCfg/MonsterCfg")
local MapRegionIconCfg = require("TableCfg/MapRegionIconCfg")
local MapMap2areaCfg = require("TableCfg/MapMap2areaCfg")
local MapArea2regionCfg = require("TableCfg/MapArea2regionCfg")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local LightDefine = require("Game/Light/LightDefine")
local ProtoCommon = require("Protocol/ProtoCommon")
local ModelDefine = require("Game/Model/Define/ModelDefine")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local FateArchiveMainTabItemVM = require("Game/FateArchive/VM/FateArchiveMainTabItemVM")
local ItemUtil = require("Utils/ItemUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")

local MapContentType = MapDefine.MapContentType
local EquipmentMgr = _G.EquipmentMgr
local LightMgr = _G.LightMgr
local AnimMgr = _G.AnimMgr
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local LSTR = _G.LSTR
local PreviewPanelState = {
    ShowModel = 1,
    ShowMap = 2
}
local DoubleColorShopID = 2001 -- 双色宝石商店ID
local TargetLightID = LightDefine.LightLevelID.LIGHT_LEVEL_ID_EMAIL
local LightLevelCreateLocation = LightDefine.LightLevelCreateLocation

local LightPreset = LightDefine.LightLevelPath[TargetLightID]

local ActorZLocation = 100100
local MonsterLocation = nil
local Rotation = nil

-- local TELEPORT_CRYSTAL_TYPE = ProtoRes.TELEPORT_CRYSTAL_TYPE
-- local TELEPORT_CRYSTAL_ACROSSMAP = TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_ACROSSMAP
local ScaleMin = MapDefine.MapConstant.MAP_SCALE_MIN
local ScaleMax = MapDefine.MapConstant.MAP_SCALE_MAX

local MapTransferCategory = MapDefine.MapTransferCategory
---@class FateArchiveNewMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnDropMap UFButton
---@field BtnReward UFButton
---@field BtnSearch UFButton
---@field BtnStatistics UFButton
---@field BtnStore UFButton
---@field BtnViewMap UFButton
---@field CanvasPanelForMap UFCanvasPanel
---@field CommEmpty CommBackpackEmptyView
---@field CommEmpty02 CommBackpackEmptyView
---@field Common_ModelToImage_UIBP CommonModelToImageView
---@field DropDownList2 CommDropDownListView
---@field EFF_Reward UFCanvasPanel
---@field EFF_RewardFull UFCanvasPanel
---@field ImgChestIcon UImage
---@field ImgMonster_1 UFImage
---@field ImgMountBG UFImage
---@field InputSearchBar CommSearchBarView
---@field MapScale WorldMapScaleItemView
---@field ModelAdjustUI ModelAdjustUIView
---@field MonsterRender2D_UIBP MonsterRender2DView
---@field PanelChallenge UFCanvasPanel
---@field PanelList2 UFCanvasPanel
---@field PanelReward UFCanvasPanel
---@field PanelRight UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field RadialProcess URadialImage
---@field SingleBoxChallenge CommSingleBoxView
---@field SwitcherInfoExplain UFWidgetSwitcher
---@field TableViewCondition UTableView
---@field TableViewEventTab UTableView
---@field TableViewTabs UTableView
---@field TextBigTitle UFTextBlock
---@field TextContent1 UFTextBlock
---@field TextContent3 UFTextBlock
---@field TextContent4 UFTextBlock
---@field TextDropMap UFTextBlock
---@field TextEmpty UFTextBlock
---@field TextEventName UFTextBlock
---@field TextHiddenCondition UFTextBlock
---@field TextMapName UFTextBlock
---@field TextName_3 UFTextBlock
---@field TextRewardNum UFTextBlock
---@field TextUndone UFTextBlock
---@field TextViewMap UFTextBlock
---@field TextZoneName UFTextBlock
---@field VerIconTabs CommVerIconTabsView
---@field mapContent AetherCurrentMapPanelView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimReturn UWidgetAnimation
---@field AnimSwitcherInfoIn UWidgetAnimation
---@field AnimSwitcherInfoOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateArchiveNewMainView = LuaClass(UIView, true)

function FateArchiveNewMainView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnDropMap = nil
	--self.BtnReward = nil
	--self.BtnSearch = nil
	--self.BtnStatistics = nil
	--self.BtnStore = nil
	--self.BtnViewMap = nil
	--self.CanvasPanelForMap = nil
	--self.CommEmpty = nil
	--self.CommEmpty02 = nil
	--self.Common_ModelToImage_UIBP = nil
	--self.DropDownList2 = nil
	--self.EFF_Reward = nil
	--self.EFF_RewardFull = nil
	--self.ImgChestIcon = nil
	--self.ImgMonster_1 = nil
	--self.ImgMountBG = nil
	--self.InputSearchBar = nil
	--self.MapScale = nil
	--self.ModelAdjustUI = nil
	--self.MonsterRender2D_UIBP = nil
	--self.PanelChallenge = nil
	--self.PanelList2 = nil
	--self.PanelReward = nil
	--self.PanelRight = nil
	--self.PanelTips = nil
	--self.RadialProcess = nil
	--self.SingleBoxChallenge = nil
	--self.SwitcherInfoExplain = nil
	--self.TableViewCondition = nil
	--self.TableViewEventTab = nil
	--self.TableViewTabs = nil
	--self.TextBigTitle = nil
	--self.TextContent1 = nil
	--self.TextContent3 = nil
	--self.TextContent4 = nil
	--self.TextDropMap = nil
	--self.TextEmpty = nil
	--self.TextEventName = nil
	--self.TextHiddenCondition = nil
	--self.TextMapName = nil
	--self.TextName_3 = nil
	--self.TextRewardNum = nil
	--self.TextUndone = nil
	--self.TextViewMap = nil
	--self.TextZoneName = nil
	--self.VerIconTabs = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimReturn = nil
	--self.AnimSwitcherInfoIn = nil
	--self.AnimSwitcherInfoOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateArchiveNewMainView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.CommEmpty02)
	self:AddSubView(self.Common_ModelToImage_UIBP)
	self:AddSubView(self.DropDownList2)
	self:AddSubView(self.InputSearchBar)
	self:AddSubView(self.MapScale)
	self:AddSubView(self.ModelAdjustUI)
	self:AddSubView(self.MonsterRender2D_UIBP)
	self:AddSubView(self.SingleBoxChallenge)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateArchiveNewMainView:OnInit()
    self.CurSelectFateID = 0
    self.bInSearchState = false
    self.ID2IndexTable = {}
    self.BtnBack:AddBackClick(self, self.OnClickBtnBack)
    MonsterLocation = _G.UE.FVector(0, 0, ActorZLocation)
    Rotation = _G.UE.FRotator(0, 0, 0)

    self.AdapterEventTabList = UIAdapterTableView.CreateAdapter(
        self, self.TableViewEventTab, self.OnFateEventItemSelected
    )

    -- 收集每个地图中包含的Fate列表，以及FateID对应MapID的映射关系
    self.FateMapInfo, self.Fate2MapID = _G.FateMgr:GatherMapFateStageInfo()
    self.Region2AreaTable, self.Area2MapTable = MapUtil.GetRegionAndAreaTable()

    self.TableViewConditionAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewCondition)
    self.viewModel = FateArchiveMainVM
    self.viewModel.bIsShowMap = false
    self.ModelAdjustUI:Setup(self.viewModel, self)
    self.MultiBinders = {
        {
            ViewModel = FateArchiveMainVM,
            Binders = {
                {"FateName", UIBinderSetText.New(self, self.TextEventName)},
                {"FateDescribe", UIBinderSetText.New(self, self.TextContent1)},
                {"FateCondition", UIBinderSetText.New(self, self.TextContent3)},
                {"FateSpecial", UIBinderSetText.New(self, self.TextContent4)},
                {"HideConditionText", UIBinderSetText.New(self, self.TextHiddenCondition)},
                {"FateEventList", UIBinderUpdateBindableList.New(self, self.AdapterEventTabList)},
                {"ConditionList", UIBinderUpdateBindableList.New(self, self.TableViewConditionAdapter)},
                {"SwitcherInfoPanel", UIBinderSetActiveWidgetIndex.New(self, self.SwitcherInfoExplain)},
                {"bShowPanelPreview", UIBinderSetIsVisible.New(self, self.PanelDetailsPreview)},
                {"MonsterResID", UIBinderValueChangedCallback.New(self, nil, self.SetMonsterResID)},
                {"bShowDebugUI", UIBinderSetIsVisible.New(self, self.ModelAdjustUI)},
                {"ProgressText", UIBinderSetText.New(self, self.TextRewardNum)},
                {"ProgressPercent", UIBinderValueChangedCallback.New(self, nil, self.SetProgressPercent)},
                {"bHaveReward", UIBinderSetIsVisible.New(self, self.EFF_Reward)},
                {"bShowFateSpecial", UIBinderSetIsVisible.New(self, self.TextContent4)},
--                {"bShowBtnViewMap", UIBinderValueChangedCallback.New(self, nil, self.OnShowBtnViewMapVisibleChanged)}
            }
        },
        {
            ViewModel = ModuleMapContentVM,
            Binders = {
                {"MapScale", UIBinderSetSlider.New(self, self.MapScale.Slider)},
                {"MapScale", UIBinderValueChangedCallback.New(self, nil, self.SetProgressBar)}
            }
        }
    }
end

function FateArchiveNewMainView:OnShowBtnViewMapVisibleChanged(NewValue, OldValue)
    -- if (NewValue) then
    --     UIUtil.SetIsVisible(self.BtnViewMap, true, true)
    -- else
    --     UIUtil.SetIsVisible(self.BtnViewMap, false, false)
    -- end
end

function FateArchiveNewMainView:OnFateEventItemSelected(Index, ItemData, ItemView, bClick)
    if (ItemData == nil) then
        _G.FLOG_ERROR("错误，FateArchiveNewMainView:OnFateEventItemSelected 传入的 ItemData 为空，请检查")
        return
    end

    if (self.LastSelectItemData ~= nil) then
        self.LastSelectItemData.bSelected = false
        _G.FateMgr:ClearNewTriggerFateByFateID(self.LastSelectItemData.ID)
        self.LastSelectItemData:RefreshNewState()
    end

    self.LastSelectItemData = ItemData
    ItemData.bSelected = true

    local FateID = ItemData.ID
    self:InternalSelectFateEventItem(FateID)
    if (self.bInSearchState) then
        self.SelecteFateIDWhenSearch = FateID
    end

    if (self.viewModel.bIsShowMap) then
        self:RefreshPreviewMap()
    end
end

function FateArchiveNewMainView:InternalSelectFateEventItem(InFateID)
    local OldSelectFate = self.viewModel.SelectID
    self.CurSelectFateID = InFateID
    local FateID = InFateID
    self.viewModel:SelectEvent(FateID)
    local TempIndex = self.ID2IndexTable[FateID]
    if TempIndex ~= nil then
        self.AdapterEventTabList:SetSelectedIndex(TempIndex)
        local SlatePreTick = require("Game/Skill/SlatePreTick")
        SlatePreTick.RegisterSlatePreTickNextFrame(
            self,
            function(View, DeltaTime, Params)
                self.TableViewEventTab:ScrollIndexIntoView(Params.TargetIndex - 1)
            end,
            {
                TargetIndex = TempIndex
            }
        )
    end

    if (OldSelectFate ~= nil and OldSelectFate ~= ID and not self.IsNewShow) then
        _G.FateMgr:ClearNewTriggerFateByFateID(OldSelectFate)
    end

    _G.FateMgr.CurArchiveSelectFateID = FateID
end

function FateArchiveNewMainView:OnClickBtnBack()
    _G.UIViewMgr:HideView(self.ViewID)
end

function FateArchiveNewMainView:OnLeftSideSelectChanged(Index, ItemData, ItemView, bClick)
    if (self.bInSearchState) then
        self:OnSearchCancel()
        return
    end
    self.SelectedTabIndex = Index
    self:SetSearchState(false)
    self:OnTabSelectChanged(Index)
end

function FateArchiveNewMainView:OnDestroy()
end

function FateArchiveNewMainView:InitLeftSiderBar(ListData, SelectedIndex)
    local Data = nil

    if ListData.Items ~= nil then
        Data = ListData.Items
    else
        Data = ListData
    end

    if (Data == nil) then
        Data = {}
    end

    self.VerIconTabs:UpdateItems(Data, SelectedIndex)
end

function FateArchiveNewMainView:OnShow()
    UIUtil.SetIsVisible(self.BtnViewMap, true, true)
    self.TextBigTitle:SetText(LSTR(190026))
    self.TextUndone:SetText(LSTR(190027))
    self.InputSearchBar:SetHintText(LSTR(190025))
    self.TextViewMap:SetText(LSTR(190028))
    self.TextEmpty:SetTExt(LSTR(190115))
    self.CommEmpty:SetTipsContent(LSTR(190029))
    self.CommEmpty02:SetTipsContent(LSTR(190024))
    self.TextDropMap:SetText(LSTR(190020))

    -- 双色宝石商店ID
    local TableData = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_SHOP_DOUBLE_COLOR_SHOP)
    if (TableData ~= nil) then
        DoubleColorShopID = TableData.Value[1]
    end
    -- end

    self.SearchText = ""
    self.bCheckShowUnfinished = false
    self.SingleBoxChallenge:SetChecked(false, false)

    self.SelectedFateID = _G.FateMgr.SelectedFateID
    self.bShowRewardPanel = _G.FateMgr.bShowRewardPanel

    if (self.SelectedFateID == nil or type(self.SelectedFateID) ~= "number") then
        self.SelectedFateID = 0
    end

    self.MapTabList = self.viewModel:GetMapTabList(self, true)
    self.SelectedTabIndex = 1
    self.SelectedAreaIndex = 1
    self.SelectedMapIndex = 1
    self.SelectedFateIndex = 1

    -- 如果有传入FateID，则自动选择合适的页签
    if self.SelectedFateID ~= nil and self.SelectedFateID > 0 then
        self.SelectedTabIndex, self.SelectedAreaIndex, self.SelectedMapIndex, self.SelectedFateIndex =
            self.viewModel:GetMapTabIndexByFate(self, self.SelectedFateID)
    end

    self:InitLeftSiderBar(self.MapTabList, self.SelectedTabIndex)
    self.DropDownList2:SetForceTrigger(true)
    self.IsNewShow = true
    local TargetMapID = _G.FateMgr.FateArchiveShowMapID
    if (TargetMapID == nil or TargetMapID <= 0) then
        -- 如果没有要指定显示的地图，那么显示当前的
        local CurMapTableData = _G.PWorldMgr:GetCurrMapTableCfg()
        if (CurMapTableData ~= nil) then
            TargetMapID = CurMapTableData.ID
        end
    end
    self:TrySelectTargetMapByID(TargetMapID)
    self.IsNewShow = false

    -- 这里看一下，如果有缓存的，需要跳转的目标，那么跳转过去
    self.AdapterEventTabList:SetSelectedIndex(self.SelectedFateIndex)

    if (self.bShowRewardPanel) then
        self:RegisterTimer(
            function()
                self:OnBtnRewardClicked()
            end,
            0.1,
            0,
            1
        )

        self.bShowRewardPanel = false
    end

    self.bAnimInOver = false
    local DelayTime = self.AnimIn:GetEndTime()
    self:RegisterTimer(
        function()
            self.bAnimInOver = true
        end,
        DelayTime,
        0,
        1
    )
end

function FateArchiveNewMainView:TrySelectTargetMapByID(InMapID)
    -- 策划需求，如果当前所在地图有数据，那么打开当前地图的
    if (self.SelectedFateID ~= nil and self.SelectedFateID > 0) then
        return
    end
    local MapId = InMapID
    local MapToAreaData = MapMap2areaCfg:FindCfgByKey(MapId)
    if (MapToAreaData == nil) then
        FLOG_ERROR("无法获取 MapMap2areaCfg 数据，当前地图ID是:" .. MapId)
        return
    end

    local AreaData = MapArea2regionCfg:FindCfgByKey(MapToAreaData.AreaID)
    if (AreaData == nil) then
        FLOG_ERROR("无法获得 MapArea2regionCfg 数据，ID是:" .. MapToAreaData.AreaID)
        return
    end

    local BindDataList = self.VerIconTabs.AdapterTabs.BindableList.Items
    for i = 1, #BindDataList do
        if (BindDataList[i].ID == AreaData.RegionID) then
            self.VerIconTabs:SetSelectedIndex(i)
            break
        end
    end

    if (self.MapList == nil) then
        return
    end

    for i = 1, #self.MapList do
        if (self.MapList[i].ID == MapId) then
            self.DropDownList2:SetSelectedIndex(i)
            return
        end
    end
end

function FateArchiveNewMainView:RefreshPreviewMap()
    if (self.FateMapContent == nil) then
        self.FateMapContent = _G.UIViewMgr:CreateView(UIViewID.AetherCurrentMapPanelView, self)
        self.CanvasPanelForMap:AddChildToCanvas(self.FateMapContent)
        local TempSize =  _G.UE.FVector2D(2348, 2048)
        UIUtil.CanvasSlotSetSize(self.FateMapContent, TempSize)

        local Anchor = _G.UE.FAnchors()
        local HalfVector2D = _G.UE.FVector2D(0.5, 0.5)
        Anchor.Minimum = HalfVector2D
        Anchor.Maximum = HalfVector2D
        UIUtil.CanvasSlotSetAnchors(self.FateMapContent, Anchor)

        UIUtil.CanvasSlotSetAlignment(self.FateMapContent, HalfVector2D)

        UIUtil.CanvasSlotSetPosition(_G.UE.FVector2D(0,0))

        self.FateMapContent:InitView()
        self.FateMapContent:ShowView()

        self:InternalShowMap()
    else
        self:InternalShowMap()
    end
end

function FateArchiveNewMainView:InternalShowMap()
    if (self.FateMapContent == nil) then
        _G.FLOG_ERROR("错误， self.FateMapContent 为空，请检查")
        return
    end
    if self.viewModel.MapID ~= nil then
        --- 为确保子View刷新时数据正确，初始化数据放在父蓝图内
        local FateArchiveType = MapContentType.FateArchive
        self.FateMapContent:SetContentType(FateArchiveType)
        _G.MapMarkerMgr:CreateProviders(FateArchiveType)

        local TargetMapID = self.Fate2MapID[self.CurSelectFateID] or self.viewModel.MapID
        self.FateMapContent:ShowMapContent(TargetMapID, self.viewModel.SelectID)
    end
end

function FateArchiveNewMainView:OnHide()
    if (self.LastSelectItemData ~= nil) then
        self.LastSelectItemData.bSelected = false
    end

    self.CurSelectFateID = 0
    _G.FateMgr.CurArchiveSelectFateID = 0
    self.LastSelectItemData = nil
    self:SetSearchState(false)
    LightMgr:SwitchSceneLights(true)
    LightMgr:UnLoadLightLevel(ProtoRes.SYSTEM_LIGHT_ID.SYSTEM_LIGHT_ID_MAIL)
    if (self.viewModel.SelectID ~= nil) then
        _G.FateMgr:ClearNewTriggerFateByFateID(self.viewModel.SelectID)
    end
    self.viewModel:OnHide()
    if (self.MonsterEntityID ~= nil and self.MonsterEntityID > 0) then
        _G.ClientVisionMgr:DestoryClientActor(self.MonsterEntityID, _G.UE.EActorType.Monster)
        local UActorManager = _G.UE.UActorManager.Get()
        UActorManager:RemoveClientActor(self.MonsterEntityID)
    end
    self.MonsterEntityID = nil
    self.MonsterActor = nil
end

function FateArchiveNewMainView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnViewMap, self.OnBtnViewMapClicked)
    UIUtil.AddOnClickedEvent(self, self.BtnDropMap, self.OnBtnDropMapClicked)
    UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList2, self.OnSelectionChangedDropDownList2)
    UIUtil.AddOnValueChangedEvent(self, self.MapScale.Slider, self.OnValueChangedScale)
    UIUtil.AddOnClickedEvent(self, self.BtnStatistics, self.BtnStatisticsClicked)
    UIUtil.AddOnClickedEvent(self, self.BtnStore, self.OnBtnStoreClicked)
    self.SingleBoxChallenge:SetStateChangedCallback(self, self.OnSingleBoxClick)
    self.InputSearchBar:SetCallback(self, self.ChangeCallback, self.OnSearchInputFinish, self.OnSearchCancel)
    UIUtil.AddOnClickedEvent(self, self.BtnReward, self.OnBtnRewardClicked)
    UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabs, self.OnLeftSideSelectChanged)
end

function FateArchiveNewMainView:OnSearchCancel()
    if (not self.bInSearchState) then
        return
    end

    UIUtil.SetIsVisible(self.PanelRight, true)
    self:SetSearchState(false)
    UIUtil.SetIsVisible(self.CommEmpty02, false)
    local TargetIndex = self.SelectedAreaIndex or 1
    self.VerIconTabs:SetSelectedIndex(TargetIndex)

    if (self.SelecteFateIDWhenSearch ~= nil and self.SelecteFateIDWhenSearch > 0) then
        self:OnFateSelected(self.SelecteFateIDWhenSearch)
        self.SelecteFateIDWhenSearch = 0
    else
        self:RefreshFateEventList()
    end
end

function FateArchiveNewMainView:ChangeCallback(Text, CurLen)
    if (CurLen ~= nil and CurLen <= 0 and self.bInSearchState) then
        self:OnSearchCancel()
    end
end

function FateArchiveNewMainView:OnSearchInputFinish(Text, CommitMethod)
    self.SearchText = Text
    self:SetSearchState(true)
    self.VerIconTabs.AdapterTabs:CancelSelected()
    local TempList = self:RefreshFateEventList()
    if (TempList == nil or #TempList < 1) then
        UIUtil.SetIsVisible(self.PanelRight, false)
        UIUtil.SetIsVisible(self.TableViewEventTab, false)
        UIUtil.SetIsVisible(self.CommEmpty02, true)
        self.CommEmpty02:SetTipsContent(LSTR(190024))
    else
        UIUtil.SetIsVisible(self.PanelRight, true)
        UIUtil.SetIsVisible(self.TableViewEventTab, true)
        UIUtil.SetIsVisible(self.CommEmpty02, false)
        self.CommEmpty02:SetTipsContent(LSTR(190024))
    end
end

function FateArchiveNewMainView:SetSearchState(bInSearchState)
    if (self.bInSearchState == bInSearchState) then
        return
    end

    self.bInSearchState = bInSearchState

    if (self.bInSearchState) then
        --self.DropDownList2.ToggleBtnExtend:SetIsChecked(false)
        UIUtil.SetIsVisible(self.DropDownList2.ToggleBtnExtend, false)
        self.DropDownTextBeforeSearch = self.DropDownList2.TextContent.Text
        self.DropDownListSelectIndex = self.DropDownList2.SelectedIndex
        self.DropDownList2.TextContent:SetText(LSTR(190114))
        UIUtil.SetIsVisible(self.PanelReward, false)
        UIUtil.SetIsVisible(self.PanelChallenge, false)
        UIUtil.SetIsVisible(self.TextZoneName, false)
    else
        self.SearchText = nil
        --self.DropDownList2.ToggleBtnExtend:SetIsChecked(true)
        UIUtil.SetIsVisible(self.DropDownList2.ToggleBtnExtend, true, true)
        self.DropDownList2.TextContent:SetText(self.DropDownTextBeforeSearch)
        UIUtil.SetIsVisible(self.PanelReward, true)
        UIUtil.SetIsVisible(self.PanelChallenge, true)
        UIUtil.SetIsVisible(self.TextZoneName, true)
        UIUtil.SetIsVisible(self.TableViewEventTab, true)
    end
end

function FateArchiveNewMainView:OnBtnRewardClicked()
    -- 如果没有配置则提示不开界面
    local RewardCfg = FateAchievementRewardCfg:FindCfgByKey(self.viewModel.MapID)
    if RewardCfg == nil then
        FLOG_ERROR("地图未配置奖励信息,ID:" .. tostring(self.viewModel.MapID))
    else
        local Params = self:GetRewardInfoForCurMap()

        _G.UIViewMgr:ShowView(UIViewID.CollectionAwardPanel, Params)
    end
end

function FateArchiveNewMainView:GetRewardInfoForCurMap()
    local MapID = self.viewModel.MapID
    local TempRewardList = self:InternalSetMapRewardList(MapID, self.viewModel.CurMapRewardFinishedCount)
    if (TempRewardList == nil) then
        _G.FLOG_ERROR("错误，无法获取FATE地图进度奖励，地图ID : " .. MapID)
        return
    end
    local Params = {}
    Params.AwardList = TempRewardList
    local MapCfg = MapMap2areaCfg:FindCfgByKey(MapID)
    Params.AreaName = MapCfg.MapName or ""
    Params.ModuleID = self.ViewID
    Params.TextCurrent = LSTR(190089)
    local TargetView = self
    -- 这里是点击回调
    local function ClickCallback(Index, ItemData, ItemView)
        local CalbackRewardList = self:InternalSetMapRewardList(MapID, self.viewModel.CurMapRewardFinishedCount)
        local TempData = CalbackRewardList[Index]
        local bGetted = TempData.IsCollectedAward
        local bCanGet = TempData.IsGetProgress
        if not bGetted and bCanGet then
            local bScoreOverflow = false
            if (ProtoRes.SCORE_TYPE.SCORE_TYPE_TWO_TONE_GEM == TempData.AwardID) then
                local ScoreMaxValue = _G.ScoreMgr:GetScoreMaxValue(ProtoRes.SCORE_TYPE.SCORE_TYPE_TWO_TONE_GEM)
                local CurScoreValue = _G.ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_TWO_TONE_GEM)
                CurScoreValue = CurScoreValue + TempData.AwardNum
                if (CurScoreValue >= ScoreMaxValue) then
                    bScoreOverflow = true
                end
            end
            if (bScoreOverflow) then
                -- 这里弹出提示
                MsgBoxUtil.ShowMsgBoxTwoOp(
                    TargetView,
                    LSTR(10032), --"提示",
                    LSTR(190146),--"确定要领取奖励吗？\n双色宝石的持有数量已达到上限，无法获得全部奖励",
                    function()
                        _G.FateMgr:SendGetMapReward(MapID, Index)
                    end,
                    nil,
                    LSTR(10003), -- "取 消",
                    LSTR(10002) -- "确 认"
                )
            else
                _G.FateMgr:SendGetMapReward(MapID, Index)
            end
        end
    end

    local function ItemClickCallback(Index, ItemData, ItemView)
        local CalbackRewardList = self:InternalSetMapRewardList(MapID, self.viewModel.CurMapRewardFinishedCount)
        local TempData = CalbackRewardList[Index]
        local bGetted = TempData.IsCollectedAward
        local bCanGet = TempData.IsGetProgress
        if not bGetted and bCanGet then
            local bScoreOverflow = false
            if (ProtoRes.SCORE_TYPE.SCORE_TYPE_TWO_TONE_GEM == TempData.AwardID) then
                local ScoreMaxValue = _G.ScoreMgr:GetScoreMaxValue(ProtoRes.SCORE_TYPE.SCORE_TYPE_TWO_TONE_GEM)
                local CurScoreValue = _G.ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_TWO_TONE_GEM)
                CurScoreValue = CurScoreValue + TempData.AwardNum
                if (CurScoreValue >= ScoreMaxValue) then
                    bScoreOverflow = true
                end
            end
            if (bScoreOverflow) then
                -- 这里弹出提示
                MsgBoxUtil.ShowMsgBoxTwoOp(
                    TargetView,
                    LSTR(10032), --"提示",
                    LSTR(190146),--"确定要领取奖励吗？\n双色宝石的持有数量已达到上限，无法获得全部奖励",
                    function()
                        _G.FateMgr:SendGetMapReward(MapID, Index)
                    end,
                    nil,
                    LSTR(10003), -- "取 消",
                    LSTR(10002) -- "确 认"
                )
            else
                _G.FateMgr:SendGetMapReward(MapID, Index)
            end
        else
            local ItemTipsUtil = require("Utils/ItemTipsUtil")
            ItemTipsUtil.ShowTipsByResID(TempData.AwardID, ItemView)
        end
    end

    Params.OnGetAwardCallBack = ClickCallback
    Params.CollectedNum = self.viewModel.CurMapRewardFinishedCount
    Params.ItemClickCallback = ItemClickCallback
    Params.MaxCollectNum = self.viewModel.CurMapRewardMaxCount
    Params.bCancelAutoGet = true

    return Params
end

function FateArchiveNewMainView:InternalSetMapRewardList(MapID, CurFinishedCount)
    local MapState = _G.FateMgr:GetMapState(MapID)
    local LootMappingCfg = require("TableCfg/LootMappingCfg")
    local ItemCfg = require("TableCfg/ItemCfg")

    local RewardCfg = FateAchievementRewardCfg:FindCfgByKey(MapID)
    if (RewardCfg == nil) then
        _G.FLOG_ERROR("没有配置FATE地图奖励，ID是 : " .. MapID)
        return nil
    end

    -- 从后台数据获取当前的进度
    local FinishedReward = {}
    if (MapState ~= nil) then
        local TempList = MapState.AwardedRewards or {}
        for i = 1, #TempList do
            FinishedReward[TempList[i] + 1] = true
        end
    end

    local RewardInfoList = {}
    local Index = 1
    for _, v in pairs(RewardCfg.Rewards) do
        if v.Target ~= 0 then
            local RewardData = {}

            RewardData.CollectTargetNum = v.Target
            RewardData.IsCollectedAward = FinishedReward[Index] or false
            RewardData.IsGetProgress = v.Target <= CurFinishedCount and not RewardData.IsCollectedAward

            local SearchStr = string.format("ID=%d", v.RewardID)
            local LootCfg = LootMappingCfg:FindCfg(SearchStr)
            if (LootCfg ~= nil) then
                --默认只采取第一个方案，如果有多个方案，要和策划沟通客户端怎么显示
                if LootCfg.Programs and LootCfg.Programs[1] then
                    local RewardItemList = ItemUtil.GetLootItems(LootCfg.Programs[1].ID)
                    RewardData.AwardNum = RewardItemList[1].Num
                    RewardData.AwardID = RewardItemList[1].ResID
                else
                    _G.FLOG_ERROR("LootCfg.Programs 无效，无法跳转查找 Item , LootCfg查找字符串是：%s", SearchStr)
                end
            else
                _G.FLOG_ERROR("LootMappingCfg:FindCfg 出现错误，无法通过查找字符串 : %s 找到结果", SearchStr)
            end

            table.insert(RewardInfoList, RewardData)
            Index = Index + 1
        end
    end

    return RewardInfoList
end

function FateArchiveNewMainView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.FateOnMapSelected, self.OnMapSelected)
    self:RegisterGameEvent(EventID.FateOnFateSelected, self.OnFateSelected)
    self:RegisterGameEvent(EventID.FateMapRewardUpdate, self.OnFateMapRewardUpdate)
    self:RegisterGameEvent(EventID.MapOnRemoveMarker, self.MapOnRemoveMarker)
    self:RegisterGameEvent(EventID.FateCloseStatisticsPanel, self.OnFateCloseStatisticsPanel)
    self:RegisterGameEvent(EventID.FateOpenStatisticsPanel, self.OnFateOpenStatisticsPanel)
end

function FateArchiveNewMainView:OnFateOpenStatisticsPanel()
    self:StopAnimation(self.AnimIn)
    self:PlayAnimation(self.AnimOut)
end

function FateArchiveNewMainView:OnFateCloseStatisticsPanel()
    self:StopAnimation(self.AnimIn)
    self:PlayAnimation(self.AnimReturn)
    self.bAnimInOver = false
    local DelayTime = self.AnimIn:GetEndTime()
    self:RegisterTimer(
        function()
            self.bAnimInOver = true
        end,
        DelayTime,
        0,
        1
    )
end

-- Params = { ContentType = self:GetContentType(), Marker = Marker }
function FateArchiveNewMainView:MapOnRemoveMarker(Params)
    if (Params == nil or Params.Marker == nil) then
        return
    end

    if (self.viewModel.SelectID ~= Params.Marker.ID) then
        return
    end

    -- 如果销毁的是当前选中 Fate ，那么需要重新新建一个 MapMarker
    if (self.FateMapContent ~= nil) then
        self.FateMapContent:ShowMapContent(self.viewModel.MapID, self.viewModel.SelectID)
    end
end

function FateArchiveNewMainView:OnRegisterBinder()
    -- 因为 Register 比 OnShow 要早，所以在这里调用了
    if (self.viewModel ~= nil) then
        -- 开场重置显示数据
        self.viewModel:ResetOnShow()
    end

    self:RegisterMultiBinders(self.MultiBinders)

    self:PlayAnimation(self.AnimShow)
end

function FateArchiveNewMainView:OnSingleBoxClick(IsChecked)
    self.bCheckShowUnfinished = IsChecked
    self:RefreshFateEventList()
end

-- 切换区域
function FateArchiveNewMainView:OnTabSelectChanged(Index, ItemData, ItemView)
    self.IsChangeAreaTriggerDropDown = true

    self.InputSearchBar:SetText("")
    local MapTabInfo = self.MapTabList[Index]
    local Cfg = MapRegionIconCfg:FindCfgByKey(MapTabInfo.ID)
    if (Cfg == nil) then
        FLOG_ERROR("错误，无法获取 MapRegionIconCfg:FindCfgByKey, ID : " .. MapTabInfo.ID)
    else
        self.TextZoneName:SetText(Cfg.Name)
    end

    -- 这里去取消一下新发现的FATE
    local OldSelectAreaIndex = self.SelectedAreaIndex
    self.SelectedAreaIndex = Index

    self.AreaList = self.viewModel:GetAreaList(self, Index)
    local AreaIndex = 1
    self.IsChangeAreaTriggerDropDown = false
    self.MapList = self.viewModel:GetMapList(self, AreaIndex) or {}
    local MapIndex = self.SelectedMapIndex or 1
    self.SelectedMapIndex = nil

    if not self.IsNewShow and (OldSelectAreaIndex ~= nil and self.SelectedAreaIndex ~= OldSelectAreaIndex) then
        -- 这里去尝试移除新的
        local NewFateCount = #_G.FateMgr.NewFateIDListForShow
        if (self.CurFateEventList ~= nil and NewFateCount > 0) then
            for Key, Value in pairs(self.CurFateEventList) do
                _G.FateMgr:ClearNewTriggerFateByFateID(Value.ID)
                NewFateCount = #_G.FateMgr.NewFateIDListForShow
                if (NewFateCount <= 0) then
                    break
                end
            end
        end
    end

    self.DropDownList2:UpdateItems(self.MapList, MapIndex)
    self:PlayAnimation(self.AnimChangeTab, 0)

    _G.ObjectMgr:CollectGarbage(false)
end

-- 动效播放完之后再进行实际的切换
function FateArchiveNewMainView:OnBtnViewMapClicked()
    self:PlayAnimation(self.AnimSwitcherInfoOut)
    self:RegisterTimer(
        function()
            self.viewModel.bIsShowMap = true
            self.viewModel:SwitchInfoPanel(2)
            self:RefreshPreviewMap()
            self:PlayAnimation(self.AnimSwitcherInfoIn)
        end,
        0.23,
        0,
        1
    )
end
function FateArchiveNewMainView:OnBtnDropMapClicked()
    self:PlayAnimation(self.AnimSwitcherInfoOut)
    self:RegisterTimer(
        function()
            self.viewModel.bIsShowMap = false
            self.viewModel:SwitchInfoPanel(0)
            self:PlayAnimation(self.AnimSwitcherInfoIn)
        end,
        0.23,
        0,
        1
    )
end

function FateArchiveNewMainView:BtnStatisticsClicked()
    if (not self.bAnimInOver) then
        return
    end

    -- 请求数据
    _G.FateMgr:SendGetFateStats()
end

function FateArchiveNewMainView:OnBtnStoreClicked()
    local BtnShowType = 2 -- 关闭按钮的类型，1是返回样式，2是关闭样式
    _G.ShopMgr:OpenShop(DoubleColorShopID, nil, false, BtnShowType)
end

function FateArchiveNewMainView:OnSelectionChangedDropDownList2(Index)
    self.TriggerDropDownList2 = true
    local MapInfo = self.MapList[Index]
    self.viewModel.MapID = MapInfo.ID
    local FateEventList = self.FateMapInfo[MapInfo.ID]
    self.ID2IndexTable = {}
    self.CurFateEventList = FateEventList
    self:RefreshFateEventList()
    self.viewModel:InitRewardState()

    if (not self.IsChangeAreaTriggerDropDown) then
        self:PlayAnimation(self.AnimChangeClass, 0)
    end

    if (self.RecordJumpFateID ~= nil and self.RecordJumpFateID > 0) then
        self:InternalSelectFateEventItem(self.RecordJumpFateID)
        self.RecordJumpFateID = 0
    end
    _G.ObjectMgr:CollectGarbage(false)
    self.TriggerDropDownList2 = false
end

-- 刷新当前要显示的Fate列表，需要处理未完成勾选和上方搜索栏过滤
function FateArchiveNewMainView:RefreshFateEventList()
    local TempEventList = self:ProcessUnfinishedCheck(self.CurFateEventList)
    TempEventList = self:ProcessSearchTextCheck(TempEventList)
    if (TempEventList == nil) then
        _G.FLOG_ERROR("FateArchiveNewMainView:RefreshFateEventList() 错误， 无法获取数据")
        return
    end
    self.ID2IndexTable = {}
    for i, v in ipairs(TempEventList) do
        self.ID2IndexTable[v.ID] = i
    end

    self.viewModel:SetFateEventList(TempEventList)

    if (not self.IsChangeAreaTriggerDropDown) then
        self:PlayAnimation(self.AnimChangeClass)
    end

    self.AdapterEventTabList:SetSelectedIndex(1)

    return TempEventList
end

function FateArchiveNewMainView:ProcessUnfinishedCheck(EventList)
    local TempEventList = {}
    -- 处理过滤已完成Fate的选项
    if self.bCheckShowUnfinished then
        for i = 1, #EventList do
            local FateEvent = EventList[i]
            if not _G.FateMgr:IsFateAchievementFinish(FateEvent.ID) then
                table.insert(TempEventList, FateEvent)
            end
        end
    else
        TempEventList = EventList
    end
    return TempEventList
end

function FateArchiveNewMainView:ProcessSearchTextCheck(EventList)
    if self.SearchText == nil or self.SearchText == "" then
        return EventList
    end

    local TempEventList = {}

    -- Key MapID : Value : FateList
    for Key, Value in pairs(self.FateMapInfo) do
        for K, V in pairs(Value) do
            local FateEvent = V
            if string.find(FateEvent.Name, self.SearchText) ~= nil then
                -- 确保是已经揭示的fate
                local TargetFate = FateMgr:GetFateInfo(FateEvent.ID)
                if (TargetFate ~= nil) then
                    table.insert(TempEventList, FateEvent)
                end
            end
        end
    end

    return TempEventList
end

function FateArchiveNewMainView:SetProgressBar(Value)
    self.MapScale.ProgressBar:SetPercent((Value - ScaleMin) / (ScaleMax - ScaleMin))
end

function FateArchiveNewMainView:OnValueChangedScale(_, Value)
    ModuleMapContentVM:SetMapScale(Value)
end

function FateArchiveNewMainView:SetProgressPercent(percent)
    -- UIUtil.SetIsVisible(self.EFF_Reward, percent >= 1.0)
    if self.EFF_RewardFull and self.RadialProcess then
        UIUtil.SetIsVisible(self.EFF_RewardFull, percent >= 1.0)
        self.RadialProcess:SetPercent(percent)
    end
end

-- 加载怪物模型
function FateArchiveNewMainView:SetMonsterResID(resID)
    FLOG_INFO("FateArchiveNewMainView:SetMonsterResID Start , res id : %s", resID)

    -- 使用图标替代模型
    if self.viewModel ~= nil and self.viewModel.FateModelParamCfg ~= nil then
        local FateModelCfg = self.viewModel.FateModelParamCfg
        local bUseImg = false
        if (FateModelCfg ~= nil) then
            bUseImg = FateModelCfg.IsReplaceModel == 1 or FateModelCfg.IsReplaceModel == true
            local BGPath = FateModelCfg.MonsterBGIcon or FateMgr.DefaultMonsterBGIcon
            UIUtil.ImageSetBrushFromAssetPath(self.ImgMountBG, BGPath)
        else
            _G.FLOG_ERROR("无法找到 FateModelCfg ，请检查")
        end

        if bUseImg then
            local FateInfo = _G.FateMgr:GetFateInfo(self.CurSelectFateID)
            if FateInfo == nil and (not FateArchiveMainVM.bForceShowAll) then
                -- 还没有打的
                UIUtil.ImageSetColorAndOpacityHex(self.ImgMonster_1, _G.FateMgr:GetUnknownMonsterIconColor())
            else
                -- 已经打了
                UIUtil.ImageSetColorAndOpacityHex(self.ImgMonster_1, "ffffffff")
            end

            UIUtil.SetIsVisible(self.ImgMonster_1, true)
            UIUtil.ImageSetBrushFromAssetPath(self.ImgMonster_1, self.viewModel.FateModelParamCfg.MonsterIcon)
            return
        else
            UIUtil.SetIsVisible(self.ImgMonster_1, false)
        end
    else
        UIUtil.SetIsVisible(self.ImgMonster_1, false)
    end

    self.Common_ModelToImage_UIBP:SetRenderOpacity(0)

    if (self.MonsterEntityID ~= nil and self.MonsterEntityID > 0) then
        _G.ClientVisionMgr:DestoryClientActor(self.MonsterEntityID, _G.UE.EActorType.Monster)
        local UActorManager = _G.UE.UActorManager.Get()
        UActorManager:RemoveClientActor(self.MonsterEntityID)
        self.MonsterEntityID = 0
    end

    if (resID ~= nil and resID > 0) then
        local Cfg = MonsterCfg:FindCfgByKey(resID)
        if Cfg ~= nil and Cfg.ProfileName ~= nil and Cfg.ProfileName ~= "" then --怪物表有该形象名
            self:InitMonsterModel(resID)
        else
            FLOG_ERROR("FateArchiveNewMainView:SetMonsterResID Cfg.ProfileName == nil , 请检查resID: %s", resID)
        end
    end

    if self.viewModel.bIsShowMap then
        self:OnBtnViewMapClicked()
    end

    if (not self.IsChangeAreaTriggerDropDown and not self.TriggerDropDownList2) then
        self:PlayAnimation(self.AnimChangeEvent, 0)
    end
end

function FateArchiveNewMainView:InitMonsterModel(MonsterResID)
    local StagePath = "Class'/Game/UI/Render2D/Common/BP_Render2DMonsterActor.BP_Render2DMonsterActor_C'"
    local ListID = 0
    local DefaultSpringLocation = _G.UE.FVector(0, 80, -50)
    local Params = _G.UE.FCreateClientActorParams()
    Params.bUIActor = true
    Params.bNoFadeInOut = true

    self.MonsterEntityID =
        _G.UE.UActorManager:Get():CreateClientActorByParams(
        _G.UE.EActorType.Monster,
        ListID,
        MonsterResID,
        MonsterLocation,
        Rotation,
        Params
    )
    LightMgr:SwitchSceneLights(false)
    self.MonsterActor = ActorUtil.GetActorByEntityID(self.MonsterEntityID)
    if (self.MonsterActor ~= nil) then
        self.MonsterActor:GetMovementComponent():SetComponentTickEnabled(false)
        self.MonsterActor:GetFittingSlopeComponent():SetComponentTickEnabled(false)
        local VisionMgr = _G.UE.UVisionMgr.Get()
        VisionMgr:RemoveFromVision(self.MonsterActor)
        self.MonsterActor:LoadMesh()
    end

    local function RenderSceneCallBack(IsSuccess)
        if (IsSuccess) then
            self.MonsterRender2D_UIBP:SetIsShowUI(false)
            self.MonsterRender2D_UIBP:SwitchLights(false)
            LightMgr:LoadLightLevel(ProtoRes.SYSTEM_LIGHT_ID.SYSTEM_LIGHT_ID_MAIL, LightLevelCreateLocation[TargetLightID])
        end
    end

    local function RenderActorCallBack(EntityID)
        self:OnAssembleAllEnd(EntityID)
    end

    self.MonsterRender2D_UIBP:ShowMonster(
        StagePath,
        self.MonsterActor,
        LightPreset,
        RenderSceneCallBack,
        RenderActorCallBack,
        DefaultSpringLocation
    )
end

function FateArchiveNewMainView:OnAssembleAllEnd(EntityID) --Params
    if EntityID ~= self.MonsterEntityID then
        return
    end

    local monsterActor = ActorUtil.GetActorByEntityID(self.MonsterEntityID)
    if (monsterActor == nil) then
        FLOG_ERROR("FateArchiveNewMainView:SetMonsterResID 加载怪物模型失败 , 请检查resID:", self.MonsterResID)
        return
    end

    self.Common_ModelToImage_UIBP:SetRenderOpacity(1)
    UIUtil.SetIsVisible(self.Common_ModelToImage_UIBP, true)
    self.MonsterRender2D_UIBP:SetActorVisible(true)
    self.MonsterRender2D_UIBP:SetActorLOD(1)
    self.Common_ModelToImage_UIBP:SetAutoCreateDefaultScene(false)
    --self.Common_ModelToImage_UIBP:SetHDModel()
    self.Common_ModelToImage_UIBP:Show(self.MonsterActor, self.MonsterRender2D_UIBP:GetCameraComponent())

    local CapsuleHalfHeight = monsterActor:GetCapsuleHalfHeight()

    local Distance = 200 / 105 * CapsuleHalfHeight
    -- 大型怪物适当放大一点
    if CapsuleHalfHeight > 350 then
        Distance = Distance / 1.25
    end
    -- 保证不会太近，防止小型怪物显示过大
    if Distance < 120 then
        Distance = 120
    end
    local HeightOffset = 0
    --CapsuleHalfHeight / 2
    local HorizontalOffset = 0
    local ModelRotate = 0
    if self.viewModel.FateModelParamCfg ~= nil then
        Distance = self.viewModel.FateModelParamCfg.CameraDistance
        HeightOffset = self.viewModel.FateModelParamCfg.HeightOffset or 0
        HorizontalOffset = self.viewModel.FateModelParamCfg.HorizontalOffset
        ModelRotate = self.viewModel.FateModelParamCfg.ModelRotate
        -- 播放动作
        local AnimTimelineId = self.viewModel.FateModelParamCfg.ActionTimelineId
        local NeedPlayTimeline = AnimTimelineId ~= nil and AnimTimelineId > 0
        if (NeedPlayTimeline) then
            local StateComp = monsterActor:GetStateComponent()
            if (StateComp ~= nil) then
                StateComp:SetNetState(ProtoCommon.CommStatID.COMM_STAT_COMBAT, true, false)
            else
                FLOG_ERROR("没有 StateComp")
            end

            local AnimComp = monsterActor:GetAnimationComponent()
            if (AnimComp == nil) then
                FLOG_ERROR("无法找到角色 AnimationComponent，EntityID : " .. self.MonsterEntityID)
            else
                AnimComp:PlayActionTimeline(AnimTimelineId)
                local avatarComponent = monsterActor:GetAvatarComponent()
                if (avatarComponent ~= nil) then
                    local NeedWeapon = true
                    if (NeedWeapon) then
                        avatarComponent:TempSetAvatar()
                    else
                        avatarComponent:TempSetAvatarBack(1)
                    end
                else
                    FLOG_ERROR("错误，无法获取目标 avatarComponent，EntityID : " .. self.MonsterEntityID)
                end
            end
        end
    -- 播放动作END
    end

    self.viewModel.ModelCameraDistance = Distance
    self.viewModel.ModelHeightOffset = HeightOffset or 0
    self.viewModel.ModelHorizontalOffset = HorizontalOffset
    self.viewModel.ModelRotate = ModelRotate

    self:TryApplyModelOffsetAndRotate()
end

-- 应用调试数据
function FateArchiveNewMainView:TryApplyModelOffsetAndRotate()
    local monsterActor = ActorUtil.GetActorByEntityID(self.MonsterEntityID)
    if (monsterActor == nil) then
        FLOG_ERROR("FateArchiveNewMainView:SetMonsterResID 加载怪物模型失败 , 请检查resID:", self.MonsterResID)
        return
    end

    local Distance = self.viewModel.ModelCameraDistance
    local HeightOffset = self.viewModel.ModelHeightOffset or 0
    local HorizontalOffset = self.viewModel.ModelHorizontalOffset
    local ModelRotate = self.viewModel.ModelRotate

    -- -- 这里还是直接在外面调用，因为调试的子蓝图可能处于隐藏状态没有初始化过
    self.MonsterRender2D_UIBP:SetSpringArmDistance(Distance, false)

    self.MonsterRender2D_UIBP.SpringArmComponent.TargetOffset = _G.UE.FVector(0, HorizontalOffset, -HeightOffset)

    monsterActor:GetFittingSlopeComponent():SetComponentTickEnabled(false)
    local TempRotation = _G.UE.FRotator(0, ModelRotate, 0)
    monsterActor:K2_SetActorLocationAndRotation(MonsterLocation, TempRotation, false, nil, false)
end

-- 如果传入MapID，则自动选择合适的页签
function FateArchiveNewMainView:OnMapSelected(MapID)
    self.SelectedFateIndex = 1
    local OldTabIndex = self.SelectedTabIndex
    self.SelectedTabIndex, self.SelectedAreaIndex, self.SelectedMapIndex = self.viewModel:GetMapTabIndex(self, MapID)

    -- 这里如果跳转过去和当前是同一页的话，后续的两层列表选择回调不会执行，因此强制执行一次
    if OldTabIndex == self.SelectedTabIndex then
        self:OnTabSelectChanged(self.SelectedTabIndex)
    else
        self.VerIconTabs:SetSelectedIndex(self.SelectedTabIndex)
    end
end

-- 如果传入FateID，则自动选择合适的页签
function FateArchiveNewMainView:OnFateSelected(FateID)
    local OldTabIndex = self.SelectedTabIndex

    self.SelectedTabIndex, self.SelectedAreaIndex, self.SelectedMapIndex, self.SelectedFateIndex =
        self.viewModel:GetMapTabIndexByFate(self, FateID)

    self.RecordJumpFateID = FateID

    -- 这里如果跳转过去和当前是同一页的话，后续的两层列表选择回调不会执行，因此强制执行一次
    if OldTabIndex == self.SelectedTabIndex then
        self:OnTabSelectChanged(self.SelectedTabIndex)
    else
        self.VerIconTabs:SetSelectedIndex(self.SelectedTabIndex)
    end
end

function FateArchiveNewMainView:OnFateMapRewardUpdate(Index)
    self.viewModel:InitRewardState()

    local TargetView = _G.UIViewMgr:FindView(UIViewID.CollectionAwardPanel)
    if (TargetView ~= nil) then
        local Params = self:GetRewardInfoForCurMap()
        TargetView:RefreshData(Params)
    end
end

return FateArchiveNewMainView
