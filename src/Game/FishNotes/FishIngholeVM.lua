--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-01-17 17:15:07
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-01-20 09:59:38
FilePath: \Client\Source\Script\Game\FishNotes\FishIngholeVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
---@author Lucas
---DateTime: 2023-03-29 10:51:00
---Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local LocalizationUtil = require("Utils/LocalizationUtil")
local TimeUtil = require("Utils/TimeUtil")
local MapUtil = require("Game/Map/MapUtil")
local MajorUtil = require("Utils/MajorUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgTipsID = require("Define/MsgTipsID")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local ItemCfg = require("TableCfg/ItemCfg")
local MapCfg = require("TableCfg/MapCfg")
local WeatherRateCfg = require("TableCfg/WeatherRateCfg")
local MapWeatherCfg = require("TableCfg/MapWeatherCfg")
local LifeskillEffectCfg = require("TableCfg/LifeskillEffectCfg")
local WeatherMappingCfg = require("TableCfg/WeatherMappingCfg")
local FishNotesAreaVM = require("Game/FishNotes/ItemVM/FishNotesAreaVM")
local FishIngholeTipsItemVM = require("Game/FishNotes/ItemVM/FishIngholeTipsItemVM")
local FishNotesWeatherBallItemVM = require("Game/FishNotes/ItemVM/FishNotesWeatherBallItemVM")
local FishNotesWindowsTimeVM = require("Game/FishNotes/ItemVM/FishNotesWindowsTimeVM")
local FishNotesClockVM = require("Game/FishNotes/ItemVM/FishNotesClockVM")
local FishTabItemVM = require("Game/FishNotes/ItemVM/FishTabItemVM")
local FishIngholeBaitsVM = require("Game/FishNotes/ItemVM/FishIngholeBaitsVM")
local FishNotesBaitISlotVM = require("Game/FishNotes/ItemVM/FishNotesBaitISlotVM")
local FishSlotItemVM = require("Game/FishNotes/ItemVM/FishSlotItemVM")
local FishNotesGridVM = require("Game/FishNotes/ItemVM/FishNotesGridVM")
local FishNotesDefine = require("Game/FishNotes/FishNotesDefine")
local FishNotesMgr = require("Game/FishNotes/FishNotesMgr")
local TimeDefine = require("Define/TimeDefine")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ProtoRes = require ("Protocol/ProtoRes")
local WeatherUtil = require("Game/Weather/WeatherUtil")
local AozyTimeDefine = TimeDefine.AozyTimeDefine
local EToggleButtonState = _G.UE.EToggleButtonState
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_INFO = _G.FLOG_INFO
local LSTR = _G.LSTR

---@class FishIngholeVM: UIViewModel
---列表
---@field FishIngholeLocationList table @钓场列表
---@field FishIngholeLocationFishList table @选中钓场的鱼类列表
---@field FishingholeClockList table @闹钟列表
-----切换按钮状态
---@field ToggleSwitchState number @闹钟钓场切换状态
---可见性
---@field bClockFishListVisible boolean @控制钓场列表闹钟列表切换
---@field bPanelMapVisible boolean @是否显示地图区域
---@field bFishDetailsVisible boolean @显示鱼类详情
---@field bFishlistVisible boolean @显示钓场鱼类列表
---@field bFishSearchEmptyVisible boolean @搜索内容为空是否显示
---@field bClockEmptyVisible boolean @是否显示暂无闹钟提示
---@field bClockNotActiveVisible boolean @是否显示闹钟解锁
---数量显示
---@field UnlockFishProgress string @详情下方钓场中鱼解锁进度
---@field TextClockNum string @闹钟数量
---鱼类信息详情
---@field FishDetailsInfo FishNotesSlotItemView @鱼类详情-鱼类信息
---@field FishDetailsName string @鱼类详情-鱼类名字
---@field FishDetailsNameColor string @鱼类详情-鱼类名字颜色
---@field bBtnBuffVisible boolean @是否显示捕鱼人之识按钮
---@field BtnCollectVisible boolean @是否显示收藏品图标
---@field bBtnFishInheritVisible boolean @是否显示传承录图标
---时间进度条
---@field FishDetailsTime string @鱼类详情-鱼类开启时间
---@field FishDetailsTimeState string @鱼类详情-鱼类最近窗口状态
---@field FishDetailClockState number @鱼类详情-闹钟状态
---@field bFishDetailClockVisible bolean 鱼类详情-闹钟显示
---@field bFishDetailClockEnabled boolean @鱼类详情-闹钟按钮是否可点击
---@field bFishDetailProBarCDVisible boolean @鱼类详情-鱼类时间Probar显示
---@field FishDetailsProgress number @鱼类详情-鱼类时间Probar进度显示
--- --鱼饵
---@field FishIngholeBaitsInfo table @鱼类钓饵链VM
---@field bFishDetailBaitBtn boolean @钓饵盒子显隐
---@field FishDetailAllBaitData table @钓饵盒子中钓饵数据
---@field FishDetailAllBaitList table @鱼类详情-鱼饵盒子列表
---捕鱼人之识
---@field bFishStatusVisible boolean @鱼类详情-鱼类获取状态
---@field FishDetailStatusBuffIcon string @鱼类详情-状态-增益图标
---@field FishDetailStatusBuffTime string @鱼类详情-状态-增益持续时间
---@field FishDetailStatusFishIoreList table @鱼类详情-状态-鱼识列表
---@field bFishDetailStatusBuffVisible string @鱼类详情-状态-增益主节点显示变量
---@field bFishDetailStatusFishIoreVisible string @鱼类详情-状态-鱼识主节点显示变量
---窗口期
---@field bFishWindowsVisible boolean @鱼类详情-鱼类窗口期
---@field FishDetailConditionTime string @鱼类详情-鱼类出现条件-出现时间
---@field FishDetailConditionWeatherName string @鱼类详情-鱼类出现条件-天气名字
---@field FishWeatherList table @鱼类详情-天气列表
---@field FishPreWeatherList table @鱼类详情-前置天气列表
---@field TimeList table @鱼类详情-鱼类窗口期-窗口期列表
---闹钟激活
---@field FishingholeClockActiveTips string @闹钟激活提示
---@field bClockIsActive boolean @闹钟是否激活
---选中数据
---@field SelectedFactionName string @当前选中的势力名字
---@field SelectFactionIndex number @选中的势力下标
---@field SelectFactionsChildIndex table @选中的各势力下的地点下标
---@field SelectAreaIndex number @选中的区域下标
---@field SelectAreasChildIndex table @选中的各区域下的地点下标
---@field SelectLocationID number @当前选中钓场id
---@field SelectedLocationName string @详情下方选中钓场的名字
---@field SelectLocationFishIndex number @当前选中地区选中的鱼类下标
---@field SelectLocationFishData table @当前选中地区的鱼类数据缓存
---@field SelectFishData table @当前选中鱼类
---@field SelectedLocationMapID number @选中的地点地图ID
---@field SelectClockIndex number @选中的闹钟下标
---@field SelectClockItemID number @选中的闹钟的Item
---@field SelectClockTabIndex number @选中的闹钟页签
---列表数据
---@field TabDataList table @页签数据列表
---@field AreaDataList table @地区树状列表控件结构体
---搜索
---@field SkipLocationInfo table @跳转地点信息
---@field bSearch boolean @是否在搜索
---@field SearchContent string @搜索内容

local FishIngholeVM = LuaClass(UIViewModel)
function FishIngholeVM:Ctor()
end

function FishIngholeVM:OnInit()
    --列表
    self.FishIngholeLocationList = UIBindableList.New(FishNotesAreaVM)
    self.FishIngholeLocationFishList = UIBindableList.New(FishSlotItemVM)
    self.FishingholeClockList = UIBindableList.New(FishNotesClockVM)
    --切换按钮状态
    self.ToggleSwitchState = EToggleButtonState.UnChecked
    --可见性
    self.bClockFishListVisible = false
    self.bPanelMapVisible = true
    self.bFishDetailsVisible = false
    self.bFishlistVisible = true
    self.bFishSearchEmptyVisible = false
    self.bClockEmptyVisible = false
    self.bClockNotActiveVisible = false
    --数量显示
    self.UnlockFishProgress = ""
    self.TextClockNum = ""
    --鱼类信息
    self.FishDetailsInfo = FishNotesGridVM.New()
    self.FishDetailsName = ""
    --self.FishDetailsNameColor = ""
    self.bBtnBuffVisible = false
    self.BtnCollectVisible = false
    self.bBtnFishInheritVisible = false
    --时间进度条
    self.FishDetailsTime = ""
    self.FishDetailsTimeState = ""
    self.FishDetailClockState = EToggleButtonState.Unchecked
    self.bFishDetailClockEnabled = false
    self.bFishDetailClockVisible = false
    self.bFishDetailProBarCDVisible = false
    self.FishDetailsProgress = nil
    --鱼饵
    self.FishIngholeBaitsInfo = FishIngholeBaitsVM.New()
    self.bFishDetailBaitBtn = false
    self.FishDetailAllBaitData = nil
    self.FishDetailAllBaitList = UIBindableList.New(FishNotesBaitISlotVM)
    --捕鱼人之识
    self.bBtnBuffVisible = false
    self.FishDetailStatusBuffIcon = ""
    self.FishDetailStatusBuffTime = ""
    self.FishDetailStatusFishIoreList = UIBindableList.New(FishIngholeTipsItemVM)
    self.bFishDetailStatusBuffVisible = false
    self.bFishDetailStatusFishIoreVisible = false
    --窗口期
    self.bFishWindowsVisible = false
    self.bFishWeatherVisible = false
    self.bFishDetailConditionTimeState = true
    self.FishDetailConditionTime = ""
    self.FishDetailConditionWeatherName = ""
    self.FishWeatherList = UIBindableList.New(FishNotesWeatherBallItemVM)
    self.FishPreWeatherList = UIBindableList.New(FishNotesWeatherBallItemVM)
    self.TimeList = UIBindableList.New(FishNotesWindowsTimeVM)
    self.bImgArrowVisible = false
    self.TempChildKey = 0
    --闹钟激活
    self.FishingholeClockActiveTips = LSTR(FishNotesDefine.ClockActiveTipsText)
    self.bClockIsActive = true
    --选中数据
    self.SelectedFactionName = ""
    self.ClockTitleName = ""
    self.SelectFactionIndex = nil
    self.SelectFactionsChildIndex = {}
    self.SelectAreaIndex = nil
    self.SelectAreasChildIndex = {}
    self.SelectLocationID = 0
    self.SelectedLocationName = ""
    self.SelectLocationFishIndex = 0
    self.SelectLocationFishData = nil
    self.SelectFishData = nil
    self.SelectedLocationMapID = 0
    self.SelectClockIndex = FishNotesDefine.SelectClockIndexDefault
    self.SelectClockItemID = 0
    self.IsFirstOpenView = true
    self.IsOpenView = false
    --列表数据
    self.AreaDataList = nil
    --搜索
    self.SkipLocationInfo = nil
    self.bSearch = false
    self.SearchContent = ""
    self.SearchState = false
    self.SearchFishContent = nil
    self.SearchFishIndex = nil
    self.SearchHoleData = nil
    --红点
    self.ReadRedDotList = {}
    --地图缩放条
    self.MapScale = 0
    self.UIMapMinScale = 0
	self.UIMapMaxScale = 0
end

function FishIngholeVM:OnShutdown()
    self.FishIngholeLocationList:Clear()
    self.FishIngholeLocationFishList:Clear()
    self.FishDetailStatusFishIoreList:Clear()
    self.TimeList:Clear()
    self.FishingholeClockList:Clear()

    self.AreaDataList = nil
    self.SelectLocationFishData = nil
    self.SelectFishData = nil
    self.IsFirstOpenView = true
    self.IsOpenView = false
end

---@type 每秒刷新
function FishIngholeVM:RefreshSecond()
    local NowTime = TimeUtil.GetServerTime()
    if self.SelectFishData ~= nil then
        self:RefreshFishDetailsTime()
    end
    if self:IsClockView() then
        local Items = self.FishingholeClockList.Items
        if not table.is_nil_empty(Items) then
            for _, Item in ipairs(Items) do
                Item:UpdateTime(NowTime)
            end
        end
    end
end

function FishIngholeVM:RefreshFishIoreListSecond()
    local Items = self.FishDetailStatusFishIoreList.Items
    if not table.is_nil_empty(Items) then
        for _, Item in ipairs(Items) do
            Item:RefreshProBar()
        end
    end
end

---@type 切换闹钟_钓场信息-----------------------------------------------------------------------------
function FishIngholeVM:OnClickSwitch(State, BeforSearchSelectData)
    --切换按钮状态
    if State ~= nil then
        self.ToggleSwitchState = State
    else
        if self.ToggleSwitchState == EToggleButtonState.Checked then
            self.ToggleSwitchState = EToggleButtonState.UnChecked
        else
            self.ToggleSwitchState = EToggleButtonState.Checked
        end
    end
    --切换到按钮对应界面
    if self.ToggleSwitchState == EToggleButtonState.Checked then -- 闹钟列表
        if BeforSearchSelectData ~= nil then
           self:RecoverBeforSearchSelect(BeforSearchSelectData)
        end
        self.bClockFishListVisible = true
        self.bFishSearchEmptyVisible = false
        self.bClockNotActiveVisible = not self.bClockIsActive
        self.SelectedFactionName = LSTR(FishNotesDefine.ClockSetTitle)
        local Num = FishNotesMgr:GetTotalClockNum()
        self.TextClockNum = string.format(LSTR(180084), Num, FishNotesMgr.MaxClockNum)--"闹钟数量：%d/%d"
        self:InitClockTabView()
    else
        self.bClockFishListVisible = false
        self.bClockNotActiveVisible = false
        self.bClockEmptyVisible = false
        self.bFishlistVisible = true
        --self.SelectLocationID = 0
        --self.SelectAreaIndex = nil
        self.IsOpenView = false
        self.SelectLast = true
        if self.SelectFactionIndex == nil then
            self:SetDefaultSelectFactionIndex()
        end
        self.SelectedFactionName = FishNotesMgr:GetFactionInfo(self.SelectFactionIndex)
        self.TabsComp:UpdateItems(FishNotesMgr:TabDataList(), self.SelectFactionIndex, 1)
    end
end

--恢复搜索前的选中
function FishIngholeVM:RecoverBeforSearchSelect(BeforSearchSelectData)
    self.SearchHoleData = nil
    local FactionIndex = BeforSearchSelectData.FactionIndex or 2
    local AreaIndex = BeforSearchSelectData.AreaIndex or 1
    local AreaChildIndex = BeforSearchSelectData.LocationIndex or 1

    self.SelectFactionIndex = FactionIndex
    self.SelectAreaIndex = AreaIndex
    self.SelectAreasChildIndex =
    self.SelectFactionsChildIndex and self.SelectFactionsChildIndex[self.SelectFactionIndex] or {}
    self.SelectAreasChildIndex[AreaIndex] = AreaChildIndex
    if self.SelectFactionIndex then
        self.SelectFactionsChildIndex[self.SelectFactionIndex] = self.SelectAreasChildIndex
    end
end

function FishIngholeVM:IsClockView()
    return self.ToggleSwitchState == EToggleButtonState.Checked
end

---@type 界面OnShow初始化
---@param TabsComp UITabsComponent 页签组件
function FishIngholeVM:InitLocationView()
    --界面显隐
    self.bClockFishListVisible = false
    self.bPanelMapVisible = true
    self.bFishDetailsVisible = false
    self.bFishlistVisible = true
    self.bFishSearchEmptyVisible = false
    self.bClockEmptyVisible = false
    self.bClockNotActiveVisible = false
    self.bClockIsActive = _G.FishNotesMgr:GetClockActiveState()
    self.ToggleSwitchState = EToggleButtonState.UnChecked
    --数据初始化
    self.IsOpenView = false
    self:SetDefaultSelectFactionIndex()
    self.TabsComp:UpdateItems(FishNotesMgr:TabDataList(), self.SelectFactionIndex, 1)
    if self.SkipLocationInfo then
        self:SkipToSpecifiedLocation(self.SkipLocationInfo)
        self.SkipLocationInfo = nil
    end
end

--region 钓场
---@type 设置默认选择势力
function FishIngholeVM:SetDefaultSelectFactionIndex()
    --当角色为捕鱼人状态时，进入某个钓场范围后，显示自己当前的钓场
    local PlaceID = MajorUtil.IsFishingProf() and _G.FishMgr.AreaID
    local Place = PlaceID and FishNotesMgr:GetPlaceInfoByPlaceID(PlaceID)
    if Place then
        local FactionIndex = FishNotesMgr:GetFactionIndexByFactionName(Place.Faction)
        self.SelectFactionIndex = FactionIndex
        self.SelectDefaultAreaName = Place.Area
        self.SelectDefaultPlaceID = PlaceID
        self.IsOpenView = false --确保SelectDefaultAreaAndPlace（）走在钓场的逻辑
    else
        --不在钓场时，打开上次选中钓场
        --如果是首次打开，当前所在二级地图
        if self.SelectFactionIndex == nil then
            local UIMapID = _G.MapMgr:GetUIMapID()
            local AreaName = MapUtil.GetMapName(UIMapID)
            local FishNoteFactionName = FishNotesMgr:GetFactionNameByAreaName(AreaName)
            local FactionName = FishNoteFactionName or MapUtil.GetMapName(MapUtil.GetUpperUIMapID(UIMapID))
            self.SelectFactionIndex = FishNotesMgr:GetFactionIndexByFactionName(FactionName)

            --假如当前地图在钓鱼笔记中有，就选择当前地图，eg：东萨纳兰
            if FishNoteFactionName then
                self.SelectDefaultAreaName = AreaName
            else
                --如果在钓鱼笔记中没有，就选中该区域第一个地图的第一个钓场，eg：在乌尔达哈，则选中第一个西萨纳兰
                self.SelectDefaultAreaName = nil
            end
        end
    end
end

---@type 功能区选中切换至对应的界面刷新
---@param Index number 页签索引
function FishIngholeVM:SelectedTabIndex(Index)
    self.SelectedFactionName = FishNotesMgr:GetFactionInfo(Index)
    self:InitLocationData()
        if self.SearchHoleData then
            --选中区域和钓场、鱼类
            self:SelectSearchData(Index)
        else
            self:SelectDefaultAreaAndPlace(Index)
        end
    self.IsOpenView = true
    self.SelectFactionIndex = Index
end

---@type 初始化区域和钓场数据
function FishIngholeVM:InitLocationData()
    local AreaData = FishNotesMgr:GetAreaInfo(self.SelectedFactionName)
    self.bSearch = false
    if AreaData then
        self.AreaDataList = {}
        local bLock = false
        for i = 1, #AreaData do
            bLock = FishNotesMgr:GetAreaIsLock(self.SelectedFactionName, AreaData[i].AreaName)
            self.AreaDataList[#self.AreaDataList + 1] = {
                Index = i,
                Key = AreaData[i].AreaID,
                WidgetIndex = FishNotesDefine.FishLocationTreeType.Area,
                Type = FishNotesDefine.FishAreaType.Area,
                Name = AreaData[i].AreaName,
                bChanged = false,
                bExpand = false,
                bLock = bLock
            }
        end
        self:UpdateLocationList()
    end
end

---@type 刷新区域和钓场数据
function FishIngholeVM:UpdateLocationData()
    for i = #self.AreaDataList, 1, -1 do
        local AreaData = self.AreaDataList[i]
        if AreaData.bChanged == true then
            self:ExpandArea(AreaData)
        else
            self:CollapseArea(AreaData)
        end
    end
    self:UpdateLocationList()
end

---@type 展开钓点区域控件
function FishIngholeVM:ExpandArea(AreaData)
    if AreaData == nil then
        return
    end
    if AreaData.bExpand == true then
        --return
    end
    AreaData.bExpand = true
    local PlaceData = FishNotesMgr:GetPlaceInfo(self.SelectedFactionName, AreaData.Name, self.bSearch)
    if PlaceData == nil then
        FLOG_ERROR("FishIngholeVM:ExpandArea PlaceData is nil")
        return
    end
    local Children = {}
    for i = 1, #PlaceData do
        local UnLockNum, TotalNum = FishNotesMgr:GetLocationFishUnLockProgress(PlaceData[i])

        table.insert(
            Children,
            {
                ID = PlaceData[i].ID,
                ParentKey = AreaData.Index,
                Key = PlaceData[i].ID,
                Name = PlaceData[i].Name,
                Level = PlaceData[i].Level,
                bLock = FishNotesMgr:CheckFishLocationbLock(PlaceData[i].ID),
                MapID = PlaceData[i].MapID,
                bChanged = false,
                IsUnlockedAllFish = UnLockNum == TotalNum,
                UnlockFishProgress = string.format("%d/%d", UnLockNum, TotalNum),
                bActive = _G.FishNotesMgr:GetIsHaveFishInWindowInLocation(PlaceData[i].ID)
            }
        )
    end

    table.sort(Children, function(a, b)
        if a.bActive ~= b.bActive then
            return a.bActive == true
        elseif a.bActive == true then
            return a.ID < b.ID
        end
        if a.IsUnlockedAllFish ~= b.IsUnlockedAllFish then
            return a.IsUnlockedAllFish == true
        elseif a.IsUnlockedAllFish == true then
            return a.ID < b.ID
        end
        if a.bLock ~= b.bLock then
            return a.bLock == false
        end
        return a.ID < b.ID
    end)
    for index, value in ipairs(Children) do
        value.Index = index
    end
    AreaData.Children = Children
end

---@type 收起钓点区域控件
function FishIngholeVM:CollapseArea(LocationData)
    if LocationData == nil then
        return
    end

    if LocationData.bExpand == false then
        return
    end
    LocationData.bExpand = false
    LocationData.Children = nil
end

---@type 依据地区数据刷新区域和钓场控件
function FishIngholeVM:UpdateLocationList()
    self.FishIngholeLocationList:UpdateByValues(self.AreaDataList)
end

---@type 正确选择默认的钓场
function FishIngholeVM:SelectDefaultAreaAndPlace(FactionIndex)
    local DefaultAreaIndex, DefaultAreaChildIndex = self:GetFirstUnlockIndex()
    --处于打开状态
    if self.IsOpenView then
        self:AreaStateChanged(FactionIndex, DefaultAreaIndex)
        DefaultAreaIndex, DefaultAreaChildIndex = self:GetFirstUnlockIndex()
        self:SelectedLocation(DefaultAreaIndex, DefaultAreaChildIndex)
    else
        --在钓场
        if MajorUtil.IsFishingProf() and _G.FishMgr.AreaID and not self.SelectLast then
            --展开后再选择解锁地点
            DefaultAreaIndex, DefaultAreaChildIndex = self:GetAreaIndexPlaceIndex(self.SelectDefaultAreaName, self.SelectDefaultPlaceID)
            self:AreaStateChanged(FactionIndex, DefaultAreaIndex)
            DefaultAreaIndex, DefaultAreaChildIndex = self:GetAreaIndexPlaceIndex(self.SelectDefaultAreaName, self.SelectDefaultPlaceID)
            self.SelectDefaultAreaName = nil
            self.SelectDefaultPlaceID = nil
            self:SelectedLocation(DefaultAreaIndex, DefaultAreaChildIndex)
        else
            --首次打开
            if self.IsFirstOpenView then
                --解锁的钓场或当前地图第一个钓场
                if self.SelectDefaultAreaName then
                    DefaultAreaIndex = FishIngholeVM:GetAreaIndexPlaceIndex(self.SelectDefaultAreaName)
                    self.SelectDefaultAreaName = nil
                end
                self:AreaStateChanged(FactionIndex, DefaultAreaIndex)
                local DefaultAreaChildIndex = self:GetFirstUnlockIndexByAreaIndex(DefaultAreaIndex)
                self:SelectedLocation(DefaultAreaIndex, DefaultAreaChildIndex)
            else
                --选择上次打开的钓场
                self.SelectAreaIndex = self.SelectAreaIndex or 1
                self:AreaStateChanged(FactionIndex, self.SelectAreaIndex)
                self.SelectAreasChildIndex = self.SelectFactionsChildIndex and self.SelectFactionsChildIndex[FactionIndex]
                local ChildIndex = self.SelectAreasChildIndex and self.SelectAreasChildIndex[self.SelectAreaIndex] or 1
                self:SelectedLocation(self.SelectAreaIndex, ChildIndex)
            end
        end
    end
    self.IsFirstOpenView = false
    self.SelectLast = false
end

---@type 跳转到指定地区显示
---@param Info table 地区信息
function FishIngholeVM:SkipToSpecifiedLocation(Info)
    local MapInfo = MapCfg:FindCfgByKey(Info.MapID)
    local ClassInfo = FishNotesMgr:GetMapInfo(Info.MapID)
    local FactionList = FishNotesMgr:GetFactionInfo()
    if FactionList == nil then
        return
    end
    local TabIndex = 0
    for i, FactionName in ipairs(FactionList) do
        if FactionName == ClassInfo.Name then
            TabIndex = i
            break
        end
    end

    if TabIndex <= 0 then
        return
    end

    self.IsOpenView = false
    self.SelectLast = true
    self.SelectedFactionName = FishNotesMgr:GetFactionInfo(TabIndex)
    self:InitLocationData()
    local AreaName = MapInfo.DisplayName
    local PlaceName = Info.Name
    local AreaIndex = 1
    for i, Location in ipairs(self.AreaDataList) do
        if Location.Type == FishNotesDefine.FishAreaType.Area and Location.Name == AreaName then
            self:AreaStateChanged(TabIndex, i)
            AreaIndex = i
            break
        end
    end
    local AreaData = self.AreaDataList[AreaIndex]
    if AreaData ~= nil then
        local PlaceList = AreaData.Children
        if PlaceList ~= nil then
            for i, Place in ipairs(PlaceList) do
                if Place.Name == PlaceName then
                    self:SelectedLocation(AreaData.Index, i)
                    break
                end
            end
        end
    end

    if self:IsClockView() then
        self.ToggleSwitchState = EToggleButtonState.UnChecked
        self.bClockFishListVisible = false
        self.bClockNotActiveVisible = false
        self.bClockEmptyVisible = false
        self.bFishlistVisible = true
        self.TabsComp:UpdateItems(FishNotesMgr:TabDataList(), TabIndex, 1)
    end

    self.TabsComp:SetSelectedIndex(TabIndex)
    self.IsOpenView = true
end

---@type 获取列表中指定钓场区域和钓点索引
function FishIngholeVM:GetAreaIndexPlaceIndex(AreaName, PlaceID)
    local AreaIndexTemp, AreaChildIndexTemp = 1, 1
    if self.AreaDataList ~= nil then
        for AreaIndex, AreaData in ipairs(self.AreaDataList) do
            if AreaData.Name == AreaName then
                AreaIndexTemp = AreaIndex
                if PlaceID then
                    local Childrens = AreaData.Children
                    if Childrens and #Childrens > 0 then
                        for ChildIndex, PlaceData in ipairs(Childrens) do
                            if FishNotesMgr:CheckFishLocationbLock(PlaceData.ID) == false and PlaceData.ID == PlaceID then
                                AreaChildIndexTemp = ChildIndex
                                break
                            end
                        end
                    end
                end
                break
            end
        end
    end
    return AreaIndexTemp, AreaChildIndexTemp
end

---@type 按顺序获取列表中第一个解锁的钓场区域和钓点索引
function FishIngholeVM:GetFirstUnlockIndex()
    local AreaIndexTemp = 1
    local AreaChildIndexTemp = 1
    if self.AreaDataList ~= nil then
        for AreaIndex, AreaData in ipairs(self.AreaDataList) do
            if AreaData.bLock == false then
                AreaIndexTemp = AreaIndex
                local Childrens = AreaData.Children
                if Childrens and #Childrens > 0 then
                    for ChildIndex, PlaceData in ipairs(Childrens) do
                        if FishNotesMgr:CheckFishLocationbLock(PlaceData.ID) == false then
                            AreaChildIndexTemp = ChildIndex
                            break
                        end
                    end
                end
                break
            end
        end
    end
    return AreaIndexTemp, AreaChildIndexTemp
end

---@type 获取钓场区域中解锁的第一个钓点索引
function FishIngholeVM:GetFirstUnlockIndexByAreaIndex(AreaIndex)
    local AreaChildIndexTemp = 1
    if self.AreaDataList and self.AreaDataList[AreaIndex] then
        local Childrens = self.AreaDataList[AreaIndex].Children
        if Childrens ~= nil then
            for ChildIndex, PlaceData in ipairs(Childrens) do
                if FishNotesMgr:CheckFishLocationbLock(PlaceData.ID) == false then
                    AreaChildIndexTemp = ChildIndex
                    break
                end
            end
        end
    end
    return AreaChildIndexTemp
end

function FishIngholeVM:GetPlaceIndexByName(PlaceName)
    if self.AreaDataList == nil then
        return
    end
    local AreaItem = self.AreaDataList[self.SelectAreaIndex]
    local AreaChildren = AreaItem and AreaItem.Children
    if AreaChildren ~= nil and next(AreaChildren) ~= nil then
        for i, Place in ipairs(AreaChildren) do
            if Place.Name == PlaceName then
                return i
            end
        end
    end
end

---@type 点击区域或钓场回调
---@param ItemData FishNotesAreaVM
function FishIngholeVM:OnTreeViewPlaceSelected(ItemData)
    if ItemData.WidgetIndex and ItemData.WidgetIndex == 0 then
        self:AreaStateChanged(self.SelectFactionIndex, ItemData.Index)
        self.SelectAreasChildIndex =
            self.SelectFactionsChildIndex and self.SelectFactionsChildIndex[self.SelectFactionIndex]
        local DefaultAreaChildIndex = self:GetFirstUnlockIndexByAreaIndex(ItemData.Index)
        local ChildIndex =
            self.SelectAreasChildIndex and self.SelectAreasChildIndex[ItemData.Key] or DefaultAreaChildIndex
        self:SelectedLocation(self.SelectAreaIndex, ChildIndex)
        return
    end
    self:SelectedLocation(ItemData.ParentKey, ItemData.Index)
end

---@type 切换区域
---@param AreaIndex number 区域索引
function FishIngholeVM:AreaStateChanged(FactionIndex, AreaIndex)
    --重复点击，取消选中
    if FactionIndex == self.SelectFactionIndex and self.IsOpenView then
        if self.SelectAreaIndex and self.SelectAreaIndex == AreaIndex then
            return
        end
    end

    if AreaIndex == nil then
        return
    end

    if self.AreaDataList == nil then
        return
    end

    local SelectAreaData = self.AreaDataList[AreaIndex]
    if SelectAreaData == nil then --or SelectAreaData.bLock
        FLOG_WARNING("FishIngholeVM:AreaStateChanged SelectAreaData is nil")
        return
    end

    local PrevSelectArea = self.AreaDataList[self.SelectAreaIndex]
    if PrevSelectArea then
        PrevSelectArea.bChanged = false
        if PrevSelectArea.Children then
            self.SelectAreasChildIndex =
                self.SelectFactionsChildIndex and self.SelectFactionsChildIndex[self.SelectFactionIndex]
            local PreSelectChildIndex =
                self.SelectAreasChildIndex and self.SelectAreasChildIndex[self.SelectAreaIndex] or 1
            local PrevAreaChildData = PrevSelectArea.Children[PreSelectChildIndex]
            if PrevAreaChildData then
                PrevAreaChildData.bChanged = false
            end
        end
    end

    self.SelectFactionIndex = FactionIndex
    SelectAreaData.bChanged = not SelectAreaData.bChanged
    self:UpdateLocationData()
    self:UpdateLocationList()
    self.SelectAreaIndex = SelectAreaData.bChanged and AreaIndex or nil

    local AreaData = self.AreaDataList[AreaIndex]
    if AreaData == nil then
        FLOG_WARNING("FishIngholeVM:AreaStateChanged AreaData is nil")
        return
    end
    local LocationData = FishNotesMgr:GetPlaceInfo(self.SelectedFactionName, AreaData.Name, self.bSearch)
    if LocationData == nil then
        FLOG_WARNING("FishIngholeVM:AreaStateChanged LocationData is nil")
        return
    end
    local SelectedLocation = LocationData[1]
    if SelectedLocation == nil then
        FLOG_WARNING("FishIngholeVM:AreaStateChanged SelectedLocation is nil")
        return
    end
    self.SelectedLocationMapID = SelectedLocation.MapID
    if self.SelectedLocationMapID == nil then
        FLOG_WARNING("FishIngholeVM:AreaStateChanged SelectedLocationMapID is nil")
        return
    end

    self.bPanelMapVisible = true
    self.bFishDetailsVisible = false

    if AreaData.bLock then
        self.SelectedLocationName = FishNotesDefine.FishLockPlaceName
    else
        local PlaceName = AreaData.Name
        local PlaceType = ProtoEnumAlias.GetAlias(ProtoRes.FISH_LOCATION_TYPE, AreaData.LocationType) or ""
        self.SelectedLocationName = string.format("%s  %s", PlaceName, PlaceType)
    end
    --EventMgr:SendEvent(EventID.FishNoteNotifyMapInfo, self.SelectedLocationMapID)
end

---@type 切换区域下的钓点
---@param AreaIndex number 区域索引
---@param AreaChildIndex number 区域下的钓点索引
function FishIngholeVM:SelectedLocation(AreaIndex, AreaChildIndex, FishID, NoSelectFish)
    if AreaIndex == nil or AreaChildIndex == nil then
        return
    end

    if self.AreaDataList == nil then
        return
    end

    self.SelectAreasChildIndex =
        self.SelectFactionsChildIndex and self.SelectFactionsChildIndex[self.SelectFactionIndex]
    local PreSelectChildIndex = self.SelectAreasChildIndex and self.SelectAreasChildIndex[self.SelectAreaIndex]
    if PreSelectChildIndex then
        -- if AreaIndex == self.SelectAreaIndex and AreaChildIndex == PreSelectChildIndex then
        --     return
        -- end

        local PrevAreaChildData = nil
        local PrevSelectArea = self.AreaDataList[self.SelectAreaIndex]
        if PrevSelectArea and PrevSelectArea.Children then
            PrevAreaChildData = PrevSelectArea.Children[PreSelectChildIndex]
            if PrevAreaChildData then
                PrevAreaChildData.bChanged = false
            end
        end

        if self.SelectAreaIndex then
            local PrevSelectAreaVM = self.FishIngholeLocationList:Get(self.SelectAreaIndex)
            if PrevSelectAreaVM then
                PrevSelectAreaVM:UpdateChildVM(PreSelectChildIndex, PrevAreaChildData)
            end
        end
    end

    local AreaItem = self.AreaDataList[AreaIndex]
    if AreaItem == nil then
        return
    end
    AreaItem.bChanged = true
    local AreaChildren = AreaItem.Children
    if AreaChildren == nil or next(AreaChildren) == nil then
        return
    end

    self.ReadRedDotList = self.ReadRedDotList or {}
    for _, value in pairs(AreaChildren) do
        if not self.ReadRedDotList[value.ID] then
            self.ReadRedDotList[value.ID] = true
        end
        FishNotesMgr:RemoveRedDot(value.ID, true)
    end

    local AreaChildrenItem = AreaChildren[AreaChildIndex]
    if AreaChildrenItem then
        AreaChildrenItem.bChanged = true
        --移除红点
        FishNotesMgr:RemoveRedDot(AreaChildrenItem.ID)
        --如果是搜索，记录选中
        if self.SearchState then
            self.SearchHoleData = {PlaceName = AreaChildrenItem.Name,AreaName = AreaChildrenItem.Area}
        end
    end

    local AreaVM = self.FishIngholeLocationList:Get(AreaIndex)
    if AreaVM then
        AreaVM:UpdateChildVM(AreaChildIndex, AreaChildrenItem)
    end
    self.SelectLocationFishIndex = FishNotesDefine.SelectFishIndexDefault
    self.SelectAreaIndex = AreaIndex
    self.SelectAreasChildIndex =
        self.SelectFactionsChildIndex and self.SelectFactionsChildIndex[self.SelectFactionIndex] or {}
    self.SelectAreasChildIndex[AreaIndex] = AreaChildIndex
    if self.SelectFactionIndex then
        self.SelectFactionsChildIndex[self.SelectFactionIndex] = self.SelectAreasChildIndex
    end
    self.SelectLocationID = 0
    if AreaChildrenItem then
        self.SelectLocationID = AreaChildrenItem.ID
        self:ShowLocationDetail(self.SelectLocationID, NoSelectFish)
        self:UpdateLocationFishList(self.SelectLocationID, FishID, NoSelectFish)
    end
end

---@type 显示钓点信息
---@param LocationID number 钓点ID
function FishIngholeVM:ShowLocationDetail(LocationID, NoRreshMarkers)
    if LocationID == nil then
        return
    end

    local LocationData = FishNotesMgr:GetFishingholeData(LocationID)
    if LocationData == nil then
        return
    end
    --self.bPanelMapVisible = true
    self.SelectedLocationbLock = FishNotesMgr:CheckFishLocationbLock(LocationData.ID)
    if self.SelectedLocationbLock then
        --钓场名和类型todo
        self.SelectedLocationName = FishNotesDefine.FishLockPlaceName
    else
        --钓场名
        local PlaceType = ProtoEnumAlias.GetAlias(ProtoRes.FISH_LOCATION_TYPE, LocationData.LocationType) or ""
        self.SelectedLocationName = string.format("%s  %s", LocationData.Name, PlaceType)
    end
    local UnLockNum, TotalNum = FishNotesMgr:GetLocationFishUnLockProgress(LocationData)
    self.UnlockFishProgress = string.format("%d/%d", UnLockNum, TotalNum)
    EventMgr:SendEvent(EventID.FishNoteNotifyMapInfo, {MapID =  LocationData.MapID, NoRreshMarkers = NoRreshMarkers})
    EventMgr:SendEvent(EventID.FishNoteNotifyChangePointState, LocationData.ID, true)

    self.SelectedLocationMapID = LocationData.MapID
end

function FishIngholeVM:GetSelectLocationMapInfo()
    if self:IsClockView() then
        return self:GetLocationMapInfoByID(self.SelectLocationID)
    end

    local LocationData = self.AreaDataList[self.SelectAreaIndex]
    if LocationData == nil then
        FLOG_WARNING("FishIngholeVM:GetSelectLocationMapInfo LocationData is nil")
        return nil
    end

    local PlaceData = nil
    if LocationData.Type == FishNotesDefine.FishAreaType.Place then
        PlaceData = FishNotesMgr:GetPlaceInfo(self.SelectedFactionName, LocationData.Area, self.bSearch)
    else
        PlaceData = FishNotesMgr:GetPlaceInfo(self.SelectedFactionName, LocationData.Name, self.bSearch)
    end
    if PlaceData == nil then
        FLOG_WARNING("FishIngholeVM:GetSelectLocationMapInfo PlaceData is nil")
        return nil
    end

    local MapInfo = {}
    for _, Data in ipairs(PlaceData) do
        if FishNotesMgr:CheckFishLocationbLock(Data.ID) == false then
            MapInfo[Data.ID] = {
                Name = Data.Name,
                Points = Data.Points,
                HorizontalDistance = Data.HorizontalDistance,
                VerticalDistance = Data.VerticalDistance,
                MaxLocationOffsetZ = Data.MaxLocationOffsetZ,
                FishIngholeX = Data.FishIngholeX ,
                FishIngholeY = Data.FishIngholeY ,
                Status = false
            }
        end
    end

    if LocationData.Type == FishNotesDefine.FishAreaType.Place then
        MapInfo[LocationData.ID].Status = true
    end

    return MapInfo
end

function FishIngholeVM:GetLocationMapInfoByID(LocationID)
    local LocationData = FishNotesMgr:GetFishingholeData(LocationID)
    if LocationData == nil then
        FLOG_WARNING("FishIngholeVM:GetSelectLocationMapInfo LocationData is nil")
        return nil
    end

    local MapInfo = {}
    MapInfo[LocationID] = {
        Name = FishNotesMgr:CheckFishLocationbLock(LocationID) and "" or LocationData.Name,
        Points = LocationData.Points,
        HorizontalDistance = LocationData.HorizontalDistance,
        VerticalDistance = LocationData.VerticalDistance,
        MaxLocationOffsetZ = LocationData.MaxLocationOffsetZ,
        FishIngholeX = LocationData.FishIngholeX ,
        FishIngholeY = LocationData.FishIngholeY ,
        Status = false
    }

    return MapInfo
end

---@type 刷新当前地点的鱼类信息
---@param LocationID number 鱼场ID
---@param SelectFishID number 默认选中鱼的ID
function FishIngholeVM:UpdateLocationFishList(LocationID, SelectFishID, NoSelectFish)
    local LocationData = FishNotesMgr:GetFishingholeData(LocationID)
    if LocationData == nil then
        return
    end

    local ClockActiveState = FishNotesMgr:GetClockActiveState()
    local FishList = FishNotesMgr:GetLocationFishListByID(LocationID) or {}
    local ResultData = {}
    local SelectIndex = 0
    for i = 1, #FishList do
        local FishID = FishList[i]
        --窗口期
        local bClockActiveVisible = FishNotesMgr:GetIsFishInWindowInLocation(LocationID, FishID)
        --闹钟
        local bClockVisible = false
        if ClockActiveState == true then
            local ClockData = FishNotesMgr:GetClockData(FishID, LocationID)
            bClockVisible = ClockData ~= nil and bClockActiveVisible ~= true
        end
        local LocationbLock = FishNotesMgr:CheckFishLocationbLock(LocationID)
        ResultData[#ResultData + 1] = {
            ID = FishID,
            LocationID = LocationID,
            IsLocationFish = true,
            bCommonSelectShow = false,
            bClockActiveVisible = bClockActiveVisible,
            bClockVisible = bClockVisible,
            bUnLock = LocationbLock == false and FishNotesMgr:CheckFishbUnLock(FishID)
        }
    end

    table.sort(ResultData, function(a, b)
        if a.bClockActiveVisible ~= b.bClockActiveVisible then
            return a.bClockActiveVisible == true
        elseif a.bClockActiveVisible == true then
            return a.ID < b.ID
        end
        if a.bClockVisible ~= b.bClockVisible then
            return a.bClockVisible == true
        elseif a.bClockVisible == true then
            return a.ID < b.ID
        end
        if a.bUnLock ~= b.bUnLock then
            return a.bUnLock == true
        end
        return a.ID < b.ID
    end)

    if not NoSelectFish then
        for i = 1, #ResultData do
            local FishID = ResultData[i].ID
            if SelectFishID ~= nil and SelectFishID == FishID then
                SelectIndex = i
            elseif self.SearchState and SelectIndex == 0  then
                local Content = self.SearchFishContent
                local FishName = FishNotesMgr:GetFishName(FishID)
                if Content and string.find(FishName,Content) then
                    SelectIndex = i
                end
            end
        end
    end
    self.SelectLocationFishData = ResultData
    self.FishIngholeLocationFishList:UpdateByValues(ResultData, nil)

    if SelectIndex ~= 0 then
        self:SelectedLocationFish(SelectIndex)
    else
        self.bPanelMapVisible = true
        self.bFishDetailsVisible = false
    end
end

--获得当前钓场解锁的鱼类数量
function FishIngholeVM:GetCurLocationUnLockFishNum()
    if self.SelectLocationID == 0 or self.SelectLocationID == nil or FishNotesMgr:CheckFishLocationbLock(self.SelectLocationID) == true then
        return 0
    end
    local Num = 0
    if self.SelectLocationFishData then
        for _, Fish in pairs(self.SelectLocationFishData) do
            if FishNotesMgr:CheckFishbUnLock(Fish.ID) then
                Num = Num + 1
            end
        end
    end
    return Num
end
--endregion

--region 选中的鱼类详情信息
---@type 选中当前地点某条鱼
---@param Index number 鱼类索引
function FishIngholeVM:SelectedLocationFish(Index)
    if Index == nil then
        return
    end

    if self.SearchState and self.SearchFishContent ~= nil then
		self.SearchFishIndex = Index
	end

    local Items = self.FishIngholeLocationFishList.Items
    local SelectFish = Items[Index] or Items[1]
    if Index == self.SelectLocationFishIndex then
        self.SelectLocationFishIndex = FishNotesDefine.SelectFishIndexDefault
        self.bPanelMapVisible = true
        self.bFishDetailsVisible = false
        SelectFish:UpdateSelectXState(false)
        return
    end

    if self.SelectLocationFishIndex ~= FishNotesDefine.SelectFishIndexDefault then
        self.FishIngholeLocationFishList.Items[self.SelectLocationFishIndex]:UpdateSelectXState(false)
    end

    SelectFish:UpdateSelectXState(true)
    self.SelectLocationFishIndex = Index
    self:UpdateSelectedFishInfo(SelectFish.ID)
end

---@type 刷新选中的鱼类信息
---@param FishData table 鱼类数据
---@param LocationID number 鱼场ID
function FishIngholeVM:UpdateSelectedFishInfo(FishID)
    local FishData = FishID and FishNotesMgr:GetFishData(FishID)
    if FishData == nil then
        return
    end
    self.SelectFishData = FishData
    self.bPanelMapVisible = false
    self.bFishDetailsVisible = true
    local FishCfg = FishData.Cfg
    self.FishDetailsInfo:UpdateVM(FishCfg)
    self.FishDetailsName = FishCfg.Name
    self.bBtnFishInheritVisible = FishCfg.NeedFolklore
    self.BtnCollectVisible = FishCfg.CollectItemID ~= 0

    if self.SelectLocationID ~= 0 then
        self.FishDetailsProgress = nil
        self:RefreshFishDetailsTime()
    end

    self:UpdateFishBaitsInfo(FishCfg)
    self:UpdateFishStatusInfo(FishCfg, self.SelectLocationID)
    self:UpdateFishConditionInfo(FishData)
    self:UpdateFishWindowsInfo(FishData, self.SelectLocationID)
end

---@type 刷新选中的鱼类最近窗口期
function FishIngholeVM:RefreshFishDetailsTime()
    --最近窗口期ProBar
    local Fish = self.SelectFishData
    local TimeCondition = Fish.TimeCondition and Fish.TimeCondition[1]
    if Fish.WeatherCondition == nil and TimeCondition == nil then
        --全天可钓
        self.FishDetailsTimeState = LSTR(180042)--"全天可钓"
        self.FishDetailsTime = ""
        self.bFishDetailProBarCDVisible = false
        self.bFishDetailClockEnabled = false
    else
        local Begin, End = FishNotesMgr:GetFishNeasetWindowTime(Fish.Cfg.ID, self.SelectLocationID, true)
        if Begin ~= nil and End ~= nil then
            local Now = TimeUtil.GetServerTime()
            local bActive = Now >= Begin and Now < End
            if bActive then
                --活跃中
                local TotalWindowTime = End - Begin
                local LeftTime = End - Now
                self.FishDetailsTimeState = _G.LSTR(180066)--"活跃中"
                self.FishDetailsTime = LocalizationUtil.GetCountdownTimeForLongTime(LeftTime)
                self.FishDetailsProgress = LeftTime / TotalWindowTime
                self.bFishDetailProBarCDVisible = true
            else
                --休眠期
                local RemainSeconds = Begin - Now
                self.FishDetailsTimeState = _G.LSTR(180067)--"休眠期"
                self.FishDetailsTime =  LocalizationUtil.GetCountdownTimeForLongTime(RemainSeconds)
                self.bFishDetailProBarCDVisible = false
            end
            self.bFishDetailClockEnabled = true
        else
            --暂不出现
            self.FishDetailsTimeState = _G.LSTR(180068)--"暂不出现"
            self.FishDetailsTime = ""
            self.bFishDetailProBarCDVisible = false
            self.bFishDetailClockEnabled = false
        end
    end

    --闹钟按钮状态
    self.bFishDetailClockVisible = self.bClockIsActive and self.bFishDetailClockEnabled
    local ClockData = FishNotesMgr:GetClockData(Fish.Cfg.ID, self.SelectLocationID)
    if ClockData and next(ClockData) then
        self.FishDetailClockState = EToggleButtonState.Checked
    else
        self.FishDetailClockState = EToggleButtonState.Unchecked
        self.CurFishClockBegin = nil --否则会瞬时显示成已开启
    end
end

---@type 转换闹钟显示时间
---@param TimeSeconds number 待转换的时间差值(秒)
function FishIngholeVM:Seconds2DisplayTime(TimeSeconds, TimeText)
    if TimeText == nil then
        return
    end

    local DayValue = TimeSeconds // FishNotesDefine.TimeValue.Day
    if DayValue >= 1 then
        return string.format(TimeText.Day, DayValue)
    end

    local HourValue = TimeSeconds // FishNotesDefine.TimeValue.Hour
    if HourValue >= 1 then
        return string.format(TimeText.Hour, HourValue)
    end

    local MinuteValue = TimeSeconds // FishNotesDefine.TimeValue.Minute
    if MinuteValue >= 1 then
        return string.format(TimeText.Minute, MinuteValue)
    end

    if TimeSeconds <= 0 then
        return string.format(TimeText.Now)
    end

    return string.format(TimeText.Second, TimeSeconds)
end

---@type 刷新选中的鱼类对应的鱼饵信息
function FishIngholeVM:UpdateFishBaitsInfo(FishData)
    local BaitsList, AllBaitsList = _G.FishNotesMgr:GetAllBaitData(FishData)
    --钓饵链
    if not table.is_nil_empty(BaitsList) then
        self.FishIngholeBaitsInfo:UpdateVM(BaitsList, FishData, self.SelectLocationID)
    end
    --钓饵盒子
    self.bFishDetailBaitBtn = #AllBaitsList > 1
    self.FishDetailAllBaitData = AllBaitsList
end

---@type 刷新选中的鱼类对应的鱼饵信息
function FishIngholeVM:InitFishBaitsList()
    self.FishDetailAllBaitList:UpdateByValues(self.FishDetailAllBaitData)
end

---@type 刷新选中的鱼类对应的状态信息
---@param FishData table 鱼类数据
---@param LocationID number 渔场ID
function FishIngholeVM:UpdateFishStatusInfo(FishData, LocationID)
    self.bFishDetailStatusFishIoreVisible = false
    self.bBtnBuffVisible = false
    if FishData.BuffCondition == nil then
        return
    end

    if FishData.BuffCondition == 0 then
        return
    end

    local BuffData = LifeskillEffectCfg:FindCfgByKey(FishData.BuffCondition)
    if BuffData == nil then
        FLOG_WARNING(
            string.format("FishIngholeVM:UpdateFishStatusInfo, BuffData with id %s not found", tostring(FishData.ID))
        )
        return
    end

    self.bBtnBuffVisible = true 
    self.FishDetailStatusBuffIcon = BuffData.Icon
    self.FishDetailStatusBuffTime =
        string.format(LSTR(FishNotesDefine.StatusBuffTimeText), math.ceil(BuffData.Duration / FishNotesDefine.HourTime))
    self.bFishDetailStatusBuffVisible = true

    if LocationID == nil then
        return
    end

    local LocationData = FishNotesMgr:GetFishingholeData(LocationID)
    if LocationData == nil then
        FLOG_WARNING(
            string.format(
                "FishIngholeVM:UpdateFishStatusInfo, LocationData with id %s not found",
                tostring(FishData.ID)
            )
        )
        return
    end
    self:UpdateFishIoreList(LocationData.IntuitionCond, LocationID)
end

---@type 刷新选中鱼类对应状态的鱼识信息
---@param Data table 鱼识数据
function FishIngholeVM:UpdateFishIoreList(Data, LocationID)
    if Data == nil then
        return
    end

    local FishID
    local FishData
    local IoreData = {}
    for i = 1, #Data do
        FishID = Data[i].FishID
        if FishID ~= 0 then
            if FishNotesMgr:CheckFishIsInCurLocation(FishID) then
                FishData = FishNotesMgr:GetFishData(FishID)
                if FishData then
                    IoreData[#IoreData + 1] = {
                        Fish = FishData,
                        LocationID = LocationID,
                        Num = string.format("%d/%d", _G.BagMgr:GetItemNum(FishData.Cfg.ItemID), Data[i].Num)
                    }
                    self.bFishDetailStatusFishIoreVisible = true
                end
            else
                --如果在这个钓场中没有对应的捕鱼人之识前置鱼(必须是两个都满足)，需要把这一列都隐藏
                self.bBtnBuffVisible = false
                return
            end
        end
    end

    self.FishDetailStatusFishIoreList:UpdateByValues(IoreData, nil)
end

---@type 刷新鱼类出现条件
---@param Data table 鱼类数据
function FishIngholeVM:UpdateFishConditionInfo(Data)
    if Data == nil then
        return
    end
    if Data.WeatherCondition == nil then
        if Data.TimeConditionText == nil then
            self.bFishDetailConditionTimeState = false
            self.FishDetailConditionTime = FishNotesDefine.UnlimitedText.both
            self.FishDetailConditionWeatherName = FishNotesDefine.UnlimitedText.both
        else
            self.bFishDetailConditionTimeState = true
            self.FishDetailConditionTime = Data.TimeConditionText
            self.FishDetailConditionWeatherName = FishNotesDefine.UnlimitedText.Weather
        end
        self.FishWeatherList:Clear()
        self.FishPreWeatherList:Clear()
        return
    end

    self.bFishDetailConditionTimeState = Data.TimeConditionText ~= nil
    self.FishDetailConditionTime = Data.TimeConditionText or FishNotesDefine.UnlimitedText.Time
    self.FishDetailConditionWeatherName = ""
    local WeatherCondition = self:GetWeatherConditionInCurLocation(Data.WeatherCondition)
    local PreWeatherCondition = self:GetWeatherConditionInCurLocation(Data.PreWeatherCondition)
    self.FishWeatherList:UpdateByValues(WeatherCondition)
    self.FishPreWeatherList:UpdateByValues(PreWeatherCondition)
    self.bImgArrowVisible = not table.is_nil_empty(Data.PreWeatherCondition)
end

---@type 获得当前钓场下的配置天气（去除不可能在此地图出现的天气）
function FishIngholeVM:GetWeatherConditionInCurLocation(WeatherCondition)
    if table.is_nil_empty(WeatherCondition) then
        return
    end
    local RealWeatherCondition = {}
    local MapInfoMapID = self.SelectedLocationMapID
    local MapID = WeatherMappingCfg:FindValue(MapInfoMapID, "Mapping") or MapInfoMapID
    local MapWeather = MapWeatherCfg:FindCfgByKey(MapID)
    if MapWeather then
        local Scheme = MapWeather.Scheme
        if Scheme then
            local SchemeCfg = WeatherRateCfg:FindCfgByKey(Scheme)
            local Weathers = SchemeCfg.Weather

            local InLocation = {}
            for _, WID in pairs(Weathers) do
                if WID ~= 0 then
                    InLocation[WID] = true
                end
            end

            for _, value in pairs(WeatherCondition) do
                if InLocation[value.ID] == true then
                    table.insert(RealWeatherCondition, value)
                end
            end
        end
    end
    return RealWeatherCondition
end

---@type 添加基于艾欧泽亚时间的窗口期显示
---@param WeatherStartSec number （根据天气条件得的某对应天气的）开始时间（现实秒）
---@param WeatherEndSec number （根据天气条件得的某对应天气的）结束时间（现实秒）
---@param WindowIndex number 窗口期索引
---@param DetailWindowsList table 窗口期列表控件
local function AddWindowTime(TimeConditionStartHour, TimeConditionEndHour, WeatherStartSec, WeatherEndSec, WindowIndex, DetailWindowsList, MapID, WeatherOffset, bChackPre)
    FLOG_WARNING(string.format("AddWindowTime() TimeCondition:%dh~%dh", TimeConditionStartHour, TimeConditionEndHour))
    local OffsetAozyHour = 0
    local WeatherStartHour = FishNotesMgr:GetAozyHourByTime(WeatherStartSec)
    local WeatherEndHour = FishNotesMgr:GetAozyHourByTime(WeatherEndSec)
    FLOG_INFO(string.format("Weather:%dh~%dh", WeatherStartHour, WeatherEndHour))
    local ConvertEndTimeSec = 0
    local Now = TimeUtil:GetServerTime()

    local WindowStartSec
    local WindowEndSec
    --当偏移后的时间在天气结束之前
    while (ConvertEndTimeSec <= WeatherEndSec) do
        --此天气的开始时间 按小时向后推移，直到天气开始时间在时间条件的起始之间
        if WeatherStartSec >= Now and WeatherStartHour >= TimeConditionStartHour and WeatherStartHour <= TimeConditionEndHour then
            FLOG_INFO(string.format("OffsetAozyHour:%d", OffsetAozyHour))
            FLOG_INFO(string.format("Weather:%dh~%dh", WeatherStartHour, WeatherEndHour))
            --窗口起始时间
            WindowStartSec = FishNotesMgr:GetServerTimeByAozy(WeatherStartSec, OffsetAozyHour)

            --窗口间隔时间
            OffsetAozyHour = OffsetAozyHour + (TimeConditionEndHour - WeatherStartHour)
            WeatherStartHour = TimeConditionEndHour + 1

            --窗口结束时间
            WindowEndSec = FishNotesMgr:GetServerTimeByAozy(WeatherStartSec, OffsetAozyHour)
            WindowEndSec = math.clamp(WindowEndSec, WindowEndSec, WeatherEndSec)
            FLOG_INFO(string.format("AddWindowTime.WindowStart:%d ~ WindowEnd:%d", FishNotesMgr:GetAozyHourByTime(WindowStartSec), FishNotesMgr:GetAozyHourByTime(WindowEndSec)))

            --添加窗口
            if WindowStartSec ~= WindowEndSec then
                table.insert(DetailWindowsList, {StartTime = WindowStartSec, EndTime = WindowEndSec, MapID = MapID, WeatherOffset = WeatherOffset, bChackPre = bChackPre})
            end
            WindowIndex = WindowIndex + 1

            --偏移后的时间
            ConvertEndTimeSec = FishNotesMgr:GetServerTimeByAozy(WeatherStartSec, OffsetAozyHour)
        else
            OffsetAozyHour = OffsetAozyHour + 1
            WeatherStartHour = WeatherStartHour + 1
            if WeatherStartHour > FishNotesDefine.WindowDayEndTime then
                WeatherStartHour = FishNotesDefine.WindowDayStartTime
            end
            ConvertEndTimeSec = FishNotesMgr:GetServerTimeByAozy(WeatherStartSec, OffsetAozyHour)
        end
    end

    return WindowIndex
end

---@type 刷新鱼类出现窗口期列表
---@param FishData table 鱼类数据
---@param LocationID number 渔场ID
function FishIngholeVM:UpdateFishWindowsInfo(FishData, LocationID)
    local FishID = FishData.Cfg.ID
    local WindowsList = self:GetWindowsList(FishID, LocationID) --窗口数据
    local TempList = {}
    local TimeListData = {} --窗口数据tree
    local StartDate
    if not table.is_nil_empty(WindowsList) then
        local NearestWindow = FishNotesMgr.NearestWindowList[FishID][LocationID]
        if NearestWindow ~= nil and NearestWindow.End == WindowsList[1].EndTime then
            WindowsList[1].StartTime = NearestWindow.Begin
        end
        for _, value in pairs(WindowsList) do
            StartDate = os.date("%m月%d日",  value.StartTime)
            if TempList[StartDate] == nil then
                local Index = #TimeListData + 1
                TempList[StartDate] = Index
                table.insert(TimeListData, {
                    Key = value.StartTime,
                    StartDate = StartDate,
                    Children = {}
                })
            end
            local ParentIndex = TempList[StartDate]
            local Children = TimeListData[ParentIndex].Children
            self.TempChildKey = self.TempChildKey  + 1
            table.insert(Children, {
                ParentKey = ParentIndex,
                Key = self.TempChildKey,
                StartTime = value.StartTime,
                EndTime = value.EndTime,
                MapID = value.MapID,
                WeatherOffset = value.WeatherOffset,
                bChackPre = value.bChackPre
            })
        end
        self.TimeList:UpdateByValues(TimeListData)
        self.bFishWindowsVisible = true
        self.bFishWeatherVisible = true
    else
        self.TimeList:Clear()
        self.bFishWindowsVisible = false
        if FishData.WeatherCondition == nil then
            self.bFishWeatherVisible = false
        else
            self.bFishWeatherVisible = true
        end
    end
end

function FishIngholeVM:GetWindowsList(FishID, LocationID, bOutTime)
    local FishData = FishNotesMgr:GetFishData(FishID)
    if FishData == nil or LocationID == nil then
        return
    end
    local LocationData = FishNotesMgr:GetFishingholeData(LocationID)
    if LocationData == nil then
        FLOG_WARNING("FishIngholeVM:UpdateFishWindowsInfo, LocationData is nil")
        return
    end

    local MapInfoMapID = LocationData.MapID
    local MapID = WeatherMappingCfg:FindValue(MapInfoMapID, "Mapping") or MapInfoMapID
    local TimeCondition = FishData.TimeCondition and FishData.TimeCondition[1]
    local ShowIndex = 0
    local WindowsList = {} --窗口数据
    local WeatherCondition = FishData.WeatherCondition
    local PreWeatherCondition = FishData.PreWeatherCondition

    --只有时间，没有天气限制时
    if WeatherCondition == nil and TimeCondition ~= nil then
        local ServerTime = TimeUtil.GetServerTime()
        local AozyHour = FishNotesMgr:GetWindowBeginTimeAozyHour()
        local AozyDayOffset = 0
        local Start = TimeCondition.Start
        local End = TimeCondition.End
        --local NowAozyHourToday = TimeUtil.GetAozyHour()
        if Start > End then
            --if NowAozyHourToday < End then
                --Start = NowAozyHourToday
            --else
                End = End + FishNotesDefine.DayAllHourValue
            --end 
        end
        while (ShowIndex < FishNotesDefine.WindowItemLength) do
            local TimeConditionStart =
                (AozyHour + AozyDayOffset * FishNotesDefine.DayAllHourValue + Start) * AozyTimeDefine.AozyHour2RealSec
            local TimeConditionEnd =
                (AozyHour + AozyDayOffset * FishNotesDefine.DayAllHourValue + End) * AozyTimeDefine.AozyHour2RealSec
            if ServerTime < TimeConditionEnd then
                local WindowStartTime = TimeConditionStart
                -- if ServerTime > TimeConditionStart then
                --     WindowStartTime = ServerTime
                -- end

                local WeatherOffset1 = math.ceil((TimeConditionStart - ServerTime)/AozyTimeDefine.AozyHour2RealSec/8)
                local WeatherOffset2 = math.ceil((TimeConditionEnd - ServerTime)/AozyTimeDefine.AozyHour2RealSec/8)
                WeatherOffset2 = (WeatherOffset2 - WeatherOffset1) >= 1 and (WeatherOffset1 + 1) or WeatherOffset1
                local Weather1 = WeatherUtil.GetMapWeather(MapID, WeatherOffset1)
                local Weather2 = WeatherUtil.GetMapWeather(MapID, WeatherOffset2)
                table.insert(WindowsList, {StartTime = WindowStartTime, EndTime = TimeConditionEnd, MapID = MapID, WeatherOffset = WeatherOffset2, bChackPre = Weather1~= Weather2})
                ShowIndex = ShowIndex + 1
            end
            AozyDayOffset = AozyDayOffset + 1
        end
    else

        --BeginPoint用于推算对应天气的时间
        local BeginPoint = FishNotesMgr:GetWindowBeginTime()
        local WeatherOffset = 0
        local WeatherStart
        local WeatherEnd
        local WeathIntervalRealSec = FishNotesDefine.WeathAozyImterval * AozyTimeDefine.AozyHour2RealSec
        while (ShowIndex < FishNotesDefine.WindowItemLength and WeatherOffset < FishNotesDefine.WeathTryBorder) do
            if FishNotesMgr:WhetherIsWindowByOffset(MapID, WeatherOffset, WeatherCondition) == true and
                (PreWeatherCondition == nil or FishNotesMgr:PreWhetherIsWindowByOffset(MapID, WeatherOffset - 1, PreWeatherCondition)) then
                --对应天气的开始时间 = 当前天气的开始时间 + 天气偏移个数 * 一个天气的时间
                WeatherStart = BeginPoint + WeatherOffset * WeathIntervalRealSec
                WeatherEnd = BeginPoint + (WeatherOffset + 1) * WeathIntervalRealSec
                local bChackPre = PreWeatherCondition ~= nil

                --只有天气，没有时间限制时
                if TimeCondition == nil then
                    --local NowTime = TimeUtil:GetServerTime()
                    -- if NowTime > WeatherStart then
                    -- 	WeatherStart = NowTimePre
                    -- end
                    --天气更新慢一步，WeatherOffset=0是更新前的当前天气，WeatherStart算的是更新后的即下一个天气
                    if bOutTime ~= true or WeatherOffset ~= 0 then 
                        if ShowIndex >= 1 and WindowsList[ShowIndex].EndTime == WeatherStart then
                            WindowsList[ShowIndex].EndTime = WeatherEnd
                        else
                            WindowsList[ShowIndex + 1] = {StartTime = WeatherStart, EndTime = WeatherEnd, MapID = MapID, WeatherOffset = WeatherOffset, bChackPre = bChackPre}
                            ShowIndex = ShowIndex + 1
                        end
                    end
                else
                    --天气，时间限制都有时
                    local TimeConditionStartHour = TimeCondition.Start
                    local TimeConditionEndHour = TimeCondition.End
                    --当鱼的时间限制条件是处于跨天时，从凌晨0点分开
                    if TimeConditionStartHour > TimeConditionEndHour then
                        local Begin = FishNotesMgr:GetBeginDayTimeByAozySec(WeatherStart)
                        local TimeConditionStartSec = Begin + TimeCondition.Start * AozyTimeDefine.AozyHour2RealSec
                        local TimeConditionEndSec = Begin + TimeCondition.End * AozyTimeDefine.AozyHour2RealSec
                        if WeatherStart < TimeConditionEndSec and TimeConditionEndSec <= WeatherEnd then
                            TimeConditionStartHour = 0
                        elseif WeatherStart <= TimeConditionStartSec and TimeConditionStartSec < WeatherEnd then
                            --如果是跨天的并且下一个天气也是合适的
                            if FishNotesMgr:WhetherIsWindowByOffset(MapID, WeatherOffset + 1, WeatherCondition) == true then
                                WeatherEnd = WeatherEnd + WeathIntervalRealSec
                                TimeConditionEndHour = TimeConditionEndHour + 24
                                WeatherOffset = WeatherOffset + 1
                            else
                                TimeConditionEndHour = 24
                            end
                        end
                    end
                    local NowTime = TimeUtil:GetServerTime()
                    if NowTime < WeatherEnd then
                        -- if NowTime > WeatherStart then
                        --     WeatherStart = NowTime
                        -- end
                        --如果有前置天气且前置天气符合
                        ShowIndex = AddWindowTime(TimeConditionStartHour, TimeConditionEndHour,
                        WeatherStart, WeatherEnd, ShowIndex, WindowsList, MapID, WeatherOffset, bChackPre)
                    end
                end
            end
            WeatherOffset = WeatherOffset + 1
        end
    end

    return WindowsList
end
--endregion

--region 闹钟页签-----------------------------------------------------------------------------
---@type 初始化闹钟页签列表
function FishIngholeVM:InitClockTabView()
    local ClockTabIcon = FishNotesDefine.ClockTabIcon
    self.TabsComp:UpdateItems(ClockTabIcon, 1, 0)
end

---@type 闹钟增删改之后列表更新
---@param Index number 选中的索引
function FishIngholeVM:RefreshClockTabView()
    if self:IsClockView() and self.SelectClockTabIndex == 1 then
        --活跃中列表不刷，只刷新闹钟列表
        self:SelectedClockTabItem(self.SelectClockTabIndex)
    end
end

---@type 选中闹钟页签列表内的一个
---@param Index number 选中的索引
function FishIngholeVM:SelectedClockTabItem(Index)
    self.SelectClockTabIndex = Index
    local SortedClockList
    if Index == 1 then
        SortedClockList = FishNotesMgr:GetClockListSorted()
        self.ClockTitleName = LSTR(180085)--"闹钟列表"
    else
        SortedClockList = FishNotesMgr:GetActivedClockListSorted()
        self.ClockTitleName = LSTR(180086)--"活跃中列表"
    end
    self:UpdateClockList(SortedClockList)
end


---@type 刷新鱼类闹钟列表
function FishIngholeVM:UpdateClockList(SortedClockList)
    if SortedClockList == nil or next(SortedClockList) == nil then
        self.bClockEmptyVisible = true
        self.bPanelMapVisible = false
        self.bFishDetailsVisible = false
        self.bFishlistVisible = false
        self.FishingholeClockList:Clear()
        return
    end
    self.bClockEmptyVisible = false
    self.bFishlistVisible = true
    self:UpdateClockItemList(SortedClockList)
end

---@type 刷新闹钟列表条目
---@param Data table 闹钟数据
function FishIngholeVM:UpdateClockItemList(SortedClockList)
    if SortedClockList == nil or next(SortedClockList) == nil then
        return
    end

    local ClockData = {}
    for Index, Clock in pairs(SortedClockList) do
        local FishID = Clock.FishID
        local FishName = FishNotesMgr:GetFishName(FishID)
        ClockData[#ClockData + 1] = {
            Index = Index,
            Name = FishName,
            Time = "",
            IsSelected = false,
            WindowTime = {
                Begin = Clock.Begin,
                End = Clock.End,
                bActive = Clock.bActive
            },
            FishID = FishID,
            LocationID = Clock.LocationID,
            Tab = Clock.Tab
        }
    end

    -- local Items = self.FishingholeClockList:GetItems()
    -- for _, ItemVM in pairs(Items) do
    --     _G.ObjectPoolMgr:FreeObject(FishSlotItemVM, ItemVM.SlotVM)
    --     ItemVM.SlotVM = nil
    -- end
    self.FishingholeClockList:UpdateByValues(ClockData, nil)

    --设置选中默认第一个
    local SelectClock = 1
    if FishNotesMgr.SidebarNoticedFishID ~= 0 then
        local ClockListItems = self.FishingholeClockList.Items
        for _, value in pairs(ClockListItems) do
            if value.FishID == FishNotesMgr.SidebarNoticedFishID then
                SelectClock = value.Index
                self:SelectedClockItem(SelectClock)
                EventMgr:SendEvent(EventID.FishNotesScrollClockFishList,SelectClock)
                return
            end
        end
    end
    self:SelectedClockItem(SelectClock)
end

---@type 选中闹钟列表内的鱼
---@param Index number 选中的索引
function FishIngholeVM:SelectedClockItem(Index)
    if self.FishingholeClockList == nil or self.FishingholeClockList.Items == nil then
        return
    end

    local SelectedFishItem = self.FishingholeClockList.Items[Index]
    if SelectedFishItem == nil then
        return
    end
    self.SelectLocationFishIndex = FishNotesDefine.SelectFishIndexDefault

    local PrevSelectFishItem = self.FishingholeClockList.Items[self.SelectClockIndex]
    if self.SelectClockIndex ~= FishNotesDefine.SelectClockIndexDefault and PrevSelectFishItem then
        PrevSelectFishItem:SetClockSelected(false)
    end

    SelectedFishItem:SetClockSelected(true)
    self.SelectClockItemID = SelectedFishItem.ItemId
    self.SelectLocationID = SelectedFishItem:GetFishLocationID()
    self:ShowLocationDetail(self.SelectLocationID)
    self.SelectClockIndex = Index
    local FishID = SelectedFishItem:GetFishID()
    self:UpdateSelectedFishInfo(FishID)
    self:UpdateLocationFishList(self.SelectLocationID, FishID)
end

---@type 激活闹钟功能
function FishIngholeVM:OnActiveClick()
    self.bClockIsActive = true
    FishNotesMgr:SetClockActiveState(true)
    self:SelectedClockTabItem(1)
end

---@type 开关闹钟
function FishIngholeVM:ChangeFishClockState()
    -- Unchecked Checked Locked Other
    if self.bClockIsActive == false then
        MsgTipsUtil.ShowTips(LSTR(FishNotesDefine.ClockInvailidTipsText))
        return false
    end

    local FishID = self.SelectFishData.Cfg.ID
    local GroundID = self.SelectLocationID
    local function RightCallBack()
        FishNotesMgr:SendMsgCancelClock(FishID,GroundID)
        FishNotesMgr:OnUpdateClock(FishID, GroundID, false)
    end
    local function LeftCallBack()
        MsgBoxUtil.CloseMsgBox()
    end
    if FishNotesMgr:IsFishSubscribeClock(FishID, GroundID) then
        MsgBoxUtil.ShowMsgBoxTwoOp(
            self,
            LSTR(10004), --提  示
            LSTR(180043), --确认取消钓鱼闹钟提醒？
            RightCallBack,
            LeftCallBack,
            LSTR(10003), --取  消
            LSTR(10002) --确  认
        )
    else
        if FishNotesMgr:CheckFishLocationbLock(GroundID) == true then
            MsgTipsUtil.ShowTips(LSTR(180044)) --该钓场未激活，不可设置闹钟
            return false
        end
        local Num = FishNotesMgr:GetTotalClockNum()
        if Num >= FishNotesMgr.MaxClockNum  then
            --提示闹钟已满
            MsgTipsUtil.ShowTipsByID(MsgTipsID.MaxClockTip)
            return false
        end
        local Begin, End = FishNotesMgr:GetFishNeasetWindowTime(FishID, GroundID)
        if Begin == nil or End == nil then
             --暂时不会出现时，没有设置闹钟的按钮，这里再验证一下
             return false
        end

        FishNotesMgr:SendMsgAddClock(FishID,GroundID)
        FishNotesMgr:OnUpdateClock(FishID, GroundID, true)
    end
end

---@type 刷新鱼类闹钟状态
---@param ID number 鱼类ID
---@param IsSubscribe boolean 是否订阅
function FishIngholeVM:UpdateFishClockButtonState(ID, IsSubscribe)
    if self.SelectLocationFishIndex == nil or self.SelectLocationFishIndex <= 0 then
        return
    end

    local FishData = self.SelectFishData
    if FishData == nil then
        return
    end
    local FishID = FishData.Cfg.ID
    if FishID ~= ID then
        FLOG_WARNING(
            string.format(
                "FishIngholeVM:UpdateFishClockButtonState, does not match with id %s, IsSubscribe is %s",
                tostring(ID),
                tostring(IsSubscribe)
            )
        )
        return
    end

    if self.FishIngholeLocationFishList == nil then
        return
    end
    --更新选中的鱼的闹钟Icon显示
    local function SameIDItem(ItemData)
        return ItemData.ID == ID
    end
    local SelectedFishItem = self.FishIngholeLocationFishList:Find(SameIDItem)
    if SelectedFishItem == nil then
        return
    end

    SelectedFishItem:UpdateClockState(IsSubscribe)
end

function FishIngholeVM:UpdateLocationFishWindowState(ID)
    if self.FishIngholeLocationFishList == nil then
        return
    end
    --更新选中的鱼的闹钟Icon显示
    local function SameIDItem(ItemData)
        return ItemData.ID == ID
    end
    local SelectedFishItem = self.FishIngholeLocationFishList:Find(SameIDItem)
    if SelectedFishItem == nil then
        return
    end

    SelectedFishItem:RefreshWindowState()
end
--endregion

--region 搜索
---@type 搜索
---@param Content string 搜索内容
---@param Length number 搜索内容长度
function FishIngholeVM:FishIngholeSearch(Content, Length)
    if Length <= 0 then
        self:CancelSearch()
        return
    end
    self.SearchContent = Content

    local List, SortList, IsFish = FishNotesMgr:SearchInfoInFishinghole(Content)
    self.bSearch = true
    self.AreaDataList = {}
    if List == nil or next(List) == nil then
        self:UpdateLocationList()
        self.bFishlistVisible = false
        self.bFishSearchEmptyVisible = true
        self.bPanelMapVisible = false
        self.bFishDetailsVisible = false
        return
    end
    self.bFishSearchEmptyVisible = false
    --self.bPanelMapVisible = true
    self.SelectAreaIndex = nil
    self.bClockFishListVisible = false
    self.bFishlistVisible = true

    for i = 1, #SortList do
        local Area = SortList[i]
        self.AreaDataList[i] = {
            Index = i,
            WidgetIndex = FishNotesDefine.FishLocationTreeType.Area,
            Type = FishNotesDefine.FishAreaType.Area,
            Name = Area,
            bChanged = true,
            bExpand = true,
            Key = i + 10000
        }
        self.AreaDataList[i].Children = {}
        local Places = List[Area]

        for j = 1, #Places do
            local UnLockNum, TotalNum = FishNotesMgr:GetLocationFishUnLockProgress(Places[j])
            table.insert(
                self.AreaDataList[i].Children,
                {
                    Index = j,
                    WidgetIndex = FishNotesDefine.FishLocationTreeType.Place,
                    Type = FishNotesDefine.FishAreaType.Place,
                    Area = Area,
                    bChanged = false,
                    ID = Places[j].ID,
                    Name = Places[j].Name,
                    Level = Places[j].Level,
                    MapID = Places[j].MapID,
                    SearchText = Content,
                    Key = Places[j].ID + 1000,
                    bLock = _G.FishNotesMgr:CheckFishLocationbLock(Places[j].ID),
                    ParentKey = i,
                    IsUnlockedAllFish = UnLockNum == TotalNum,
                    UnlockFishProgress = string.format("%d/%d", UnLockNum, TotalNum),
                    bActive = _G.FishNotesMgr:GetIsHaveFishInWindowInLocation(Places[j].ID)
                }
            )
        end
    end
    self.FishIngholeLocationList:Clear()
    self:UpdateLocationList()
    --选中钓场(鱼在每次选中钓场后根据搜索内容再筛选选中)
    self.SearchFishContent = IsFish and Content
    self:SelectedLocation(1,1)
    EventMgr:SendEvent(EventID.FishNoteSearchFinished)
end

---@type 取消搜索
function FishIngholeVM:CancelSearch()
    self.SearchContent = ""
    self.bFishSearchEmptyVisible = false
    self.bSearch = false
    self.SelectAreaIndex = nil
    self.bFishlistVisible = true
    self:InitLocationData()
end

function FishIngholeVM:SelectSearchData(FactionIndex)
    local Faction = self.SelectedFactionName
    local PlaceName = self.SearchHoleData.PlaceName
    local Area = 1
    local Place = 1
    local AreaDataList = self.AreaDataList
    for AreaIndex, AreaData in pairs(AreaDataList) do
        local Children = AreaData.Children
        if Children == nil then
            Children = FishNotesMgr:GetPlaceInfo(Faction, AreaData.Name, false)
        end
        if not table.is_nil_empty(Children) then
            for PlaceIndex, PlaceData in pairs(Children) do
                if PlaceData.Name == PlaceName then
                    --Place = PlaceIndex
                    Area = AreaIndex
                    break
                end
            end
        end
    end
    --由于窗口期会导致钓场排序不同
    local AreaData = AreaDataList[Area]
    local Children = AreaData.Children
    if Children == nil then
        Children = FishNotesMgr:GetPlaceInfo(Faction, AreaData.Name, false)
    end
    if not table.is_nil_empty(Children) then
        local UnLockNum, TotalNum = 1, 1
        for _, PlaceData in pairs(Children) do
            PlaceData.bActive = _G.FishNotesMgr:GetIsHaveFishInWindowInLocation(PlaceData.ID)
            UnLockNum, TotalNum = FishNotesMgr:GetLocationFishUnLockProgress(PlaceData)
            PlaceData.IsUnlockedAllFish = UnLockNum == TotalNum
            PlaceData.bLock = FishNotesMgr:CheckFishLocationbLock(PlaceData.ID)
        end
        table.sort(Children, function(a, b)
            if a.bActive ~= b.bActive then
                return a.bActive == true
            elseif a.bActive == true then
                return a.ID < b.ID
            end
            if a.IsUnlockedAllFish ~= b.IsUnlockedAllFish then
                return a.IsUnlockedAllFish == true
            elseif a.IsUnlockedAllFish == true then
                return a.ID < b.ID
            end
            if a.bLock ~= b.bLock then
                return a.bLock == false
            end
            return a.ID < b.ID
        end)
        for PlaceIndex, PlaceData in pairs(Children) do
            if PlaceData.Name == PlaceName then
                Place = PlaceIndex
                break
            end
        end
    end
    self:AreaStateChanged(FactionIndex, Area)
    self:SelectedLocation(Area, Place)
    --选中鱼类
    if self.SearchFishIndex then
        self:SelectedLocationFish(self.SearchFishIndex)
    end
    self.SearchHoleData = nil
    self.SearchFishIndex = nil
end
--endregion


function FishIngholeVM:SaveUIMapScale(UIMapMinScale, UIMapMaxScale)
	self.UIMapMinScale = UIMapMinScale
	self.UIMapMaxScale = UIMapMaxScale
end

function FishIngholeVM:SetMapScale(Scale)
    Scale = math.clamp(Scale, self.UIMapMinScale, self.UIMapMaxScale)
	self.MapScale = Scale
end

return FishIngholeVM
