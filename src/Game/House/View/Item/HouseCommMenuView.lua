---
--- Author: skysong
--- DateTime: 2025-05-10 09:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local HouseCommMenuParentVM  = require("Game/House/VM/HouseCommMneuParentVM")
local WidgetCallback = require("UI/WidgetCallback")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBindableList = require("UI/UIBindableList")
local UIUtil = require("Utils/UIUtil")
local HouseMainPanelVM = require("Game/House/VM/HouseMainPanelVM")
local EventID = require("Define/EventID")
local ParentDesiredSize = 106
local ChildDesiredSize = 92
local MenuDesiredSize = 0

---@class HouseCommMenuView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBG UFImage
---@field ImgMask UFImage
---@field PanelBG UFCanvasPanel
---@field TreeViewMenu UFTreeView
---@field ParamColorNormal SlateColor
---@field ParamColorSelect SlateColor
---@field IsMaskVisible bool
---@field IsBgVisible bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseCommMenuView = LuaClass(UIView, true)

function HouseCommMenuView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBG = nil
	--self.ImgMask = nil
	--self.PanelBG = nil
	--self.TreeViewMenu = nil
	--self.ParamColorNormal = nil
	--self.ParamColorSelect = nil
	--self.IsMaskVisible = nil
	--self.IsBgVisible = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseCommMenuView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseCommMenuView:OnInit()
    self.OnSelectionChanged = WidgetCallback.New()
    self.AdapterMenu = UIAdapterTreeView.CreateAdapter(self, self.TreeViewMenu, self.OnSelectChanged, true, false, false, true)
    local function GetSelectKey()
        return self:GetLastSelectKey()
    end

    local Param = { ColorNormal = self.ParamColorNormal, ColorSelect = self.ParamColorSelect, GetKeyFun = GetSelectKey}
    self.AdapterMenu:SetParams(Param)
    self.SelectedChildKeyMap = {}
    self.ListData = {}
    self.BindableListChildren = UIBindableList.New(HouseCommMenuParentVM)
    self.IsCacheLastIndex = true   ----自动存储上次选择的子页签
end

function HouseCommMenuView:SetIsCacheLastChildIndex(IsCache)
    self.IsCacheLastIndex = IsCache
end

function HouseCommMenuView:SetAlwaysNotifySelectChanged(AlwaysNotifySelectChanged)
    -- if self.AdapterMenu ~= nil then
    -- 	self.AdapterMenu:SetAlwaysNotifySelectChanged(AlwaysNotifySelectChanged)
    -- end
end

function HouseCommMenuView:OnDestroy()
    self.OnSelectionChanged:Clear()
    self.OnSelectionChanged = nil
end

function HouseCommMenuView:OnShow()
    MenuDesiredSize = UIUtil.GetWidgetSize(self.TreeViewMenu).Y
end

function HouseCommMenuView:OnHide()
    self.LastMainSelectedKey = nil
    self.LastSubSelectKey = nil
    self.ListData = {}
end

function HouseCommMenuView:OnRegisterUIEvent()

end

function HouseCommMenuView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.HouseMainPanelTabMenuChange, self.OnHouseMainPanelTabMenuChange)
end

function HouseCommMenuView:OnRegisterBinder()

end

function HouseCommMenuView:OnSelectChanged(Index, ItemData, ItemView, IsByClick)
    self:ProcessSelectAction(ItemData)
    if self.NeedTrigger then
        self.OnSelectionChanged:OnTriggered(Index, ItemData, ItemView, self.LastMainSelectedKey, self.LastSubSelectKey, IsByClick)
    end
end

function HouseCommMenuView:UpdateItems(ListData, bAutoExpandAll)
    self.ListData = ListData
    if next(self.ListData) then
        self:CollapseAll()
    end

    self.BindableListChildren:UpdateByValues(ListData)
    self:InitSelectedChildKeyMap(ListData)
    local AdapterMenu = self.AdapterMenu
    AdapterMenu:SetAutoExpandAll(bAutoExpandAll)
    AdapterMenu:UpdateAll(self.BindableListChildren)
end

---SetSelectedIndex @只有一级菜单 通过索引选中更方便
---@param SelectedIndex number
function HouseCommMenuView:SetSelectedIndex(SelectedIndex)
    self.AdapterMenu:SetSelectedIndex(SelectedIndex)
end

---SetSelectedKey @如果有二级菜单 需要通过Key选中
---@param Key any @列表中的对象 需要实现GetKey函数
---@param IsExpandItem boolean
function HouseCommMenuView:SetSelectedKey(Key, IsExpandItem)
    local ParentKey = self:GetParentKey(Key)
    if nil ~= ParentKey then
        self.AdapterMenu:SetIsExpansion(ParentKey, IsExpandItem)
    end

    self.AdapterMenu:SetSelectedKey(Key, IsExpandItem)
    if IsExpandItem then
        self:RegisterTimer(function()
            self:FixScrollRealOffsetByKey(Key)
        end, 0.01, 0, 1)
    end
end

---@param Key any @列表中的对象 需要实现GetKey函数
---@param IsExpandItem boolean @是否展开
function HouseCommMenuView:SetIsExpansion(Key, IsExpandItem)
    return self.AdapterMenu:SetIsExpansion(Key, IsExpandItem)
end

---ExpandAll
function HouseCommMenuView:ExpandAll()
    self.AdapterMenu:ExpandAll()
end

---CollapseAll
function HouseCommMenuView:CollapseAll()
    self.AdapterMenu:CollapseAll()
end

function HouseCommMenuView:CancelSelected()
    self.AdapterMenu:CancelSelected()
    self.LastMainSelectedKey = nil
    self.LastSubSelectKey = nil
end

function HouseCommMenuView:GetParentKey(InKey)
    local MenuItems = self.BindableListChildren:GetItems()
    if nil == MenuItems then
        return
    end

    for i = 1, #MenuItems do
        local Item = MenuItems[i]
        local Key = Item:GetKey()
        if Key == InKey then
            return
        end
        if nil ~= Item:FindChild(InKey) then
            return Key
        end
    end
end

function HouseCommMenuView:InitSelectedChildKeyMap(MenuData)
    if nil == MenuData or #MenuData == 0 then
        return
    end

    self.SelectedChildKeyMap = {}

    for i = 1, #MenuData do
        local Children = MenuData[i].Children
        local ChildKey = nil
        if nil ~= Children and #Children > 0 then
            ChildKey = Children[1].Key
        end
        table.insert(self.SelectedChildKeyMap, { ParentKey = MenuData[i].Key, ChildKey = ChildKey })
    end

    self.LastSelectedKey = MenuData[1].Key
end

function HouseCommMenuView:IsParentKey(InKey)
    for _, Value in ipairs(self.SelectedChildKeyMap) do
        if Value.ParentKey == InKey then
            return true
        end
    end

    return false
end

function HouseCommMenuView:GetSelectedChildKey(InKey)
    if not self.IsCacheLastIndex then
        local ChildData = self.ListData[InKey] and self.ListData[InKey].Children or {}
        if next(ChildData) then
            return ChildData[1].Key
        end
    else
        for _, Value in ipairs(self.SelectedChildKeyMap) do
            if Value.ParentKey == InKey then
                return Value.ChildKey
            end
        end
    end
end

function HouseCommMenuView:CollapseItems(InKey)
    if nil == InKey then
        self:CollapseAll()
    else
        for _, Value in ipairs(self.SelectedChildKeyMap) do
            if Value.ParentKey ~= InKey then
                self:SetIsExpansion(Value.ParentKey, false)
            end
        end
    end
end

function HouseCommMenuView:ProcessSelectAction(ItemData)
    --_G.FLOG_INFO("CommMenuView:ProcessSelectAction")
    self.NeedTrigger = true
    local CurSelectedKey = ItemData:GetKey()
    local CurParentKey = self:GetParentKey(CurSelectedKey)
    if CurParentKey then
        self:OnSubTabClick(CurSelectedKey, CurParentKey)
    else
        self:OnMainTabClick(CurSelectedKey)
    end
end

function HouseCommMenuView:FixScrollRealOffsetByKey(Key)
    local MainIndex
    local ChildIndexPos
    local RealSize

    for i, v in ipairs(self.ListData) do
        local ChildData = self.ListData[i] and self.ListData[i].Children or {}
        if next(ChildData) then
            for ChildIndex, ChildData in ipairs(ChildData) do
                if ChildData.Key == Key then
                    MainIndex = i
                    ChildIndexPos = ChildIndex
                    break
                end
            end
        end
    end

    if not MainIndex or not ChildIndexPos then return end
    RealSize = MainIndex * ParentDesiredSize + ChildDesiredSize * ChildIndexPos

    local ScrollOffset
    if MenuDesiredSize ~= 0 and RealSize > MenuDesiredSize then
        if RealSize - MainIndex * ParentDesiredSize > MenuDesiredSize then
            ScrollOffset = (RealSize - MenuDesiredSize - MainIndex * ParentDesiredSize) / ChildDesiredSize + MainIndex
        else
            ScrollOffset = (RealSize - MenuDesiredSize) / ParentDesiredSize
        end
    end

    if ScrollOffset then
        local CurOffset = 0
        self:RegisterTimer(function()
            CurOffset = (CurOffset + 1) < ScrollOffset and CurOffset + 1 or ScrollOffset
            self.AdapterMenu:SetScrollOffset(CurOffset)
        end, 0.1, 0.01, math.ceil(ScrollOffset))
    end
end

function HouseCommMenuView:OnMainTabClick(ParentIndex)
    local SoftPath = _G.UE.FSoftObjectPath()
    SoftPath:SetPath("/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_FM_FirstNaviBar.Play_FM_FirstNaviBar")
    self.TreeViewMenu.SoundPathOnClick = SoftPath
    if not self.LastMainSelectedKey or self.LastMainSelectedKey ~= ParentIndex then
        if self.LastMainSelectedKey then
            local Index = self:GetParentIndexByParentKey(self.LastMainSelectedKey)
            local Widget = self.AdapterMenu:GetChildWidget(Index)
            if Widget and Index then
                Widget:OnSelectChanged(false)
            end

            self.LastSubSelectKey = nil
        end

        self.SubTabShow = false
        self:CollapseItems(ParentIndex)
        self.AdapterMenu:SetIsExpansion(ParentIndex, true)
        self.LastMainSelectedKey = ParentIndex
        local ChildKey = self:GetSelectedChildKey(ParentIndex)
        if ChildKey and (not self.LastSubSelectKey or self.LastSubSelectKey ~= ChildKey) then
            self.SubTabShow = true
            self:SetSelectedKey(ChildKey, true)
            self:SetSelectedChildKey(ParentIndex, ChildKey)
            self.NeedTrigger = false
        end
    else
        if self.LastSubSelectKey then
            if self.SubTabShow then
                self.AdapterMenu:SetIsExpansion(ParentIndex, false)
                self.SubTabShow = false
            else
                self.SubTabShow = true
                self:SetSelectedKey(self.LastSubSelectKey, true)
            end
        end

        self.NeedTrigger = false
    end
end

function HouseCommMenuView:OnSubTabClick(ChildKey, CurParentKey)
    if not self.LastMainSelectedKey then
        self.SubTabShow = true
    end

    self.LastMainSelectedKey = CurParentKey
    local SoftPath = _G.UE.FSoftObjectPath()
    SoftPath:SetPath("/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_FM_ChildNaviBar.Play_FM_ChildNaviBar")
    self.TreeViewMenu.SoundPathOnClick = SoftPath
    if not self.LastSubSelectKey or self.LastSubSelectKey ~= ChildKey then
        self.LastSubSelectKey = ChildKey
        self:SetSelectedChildKey(CurParentKey, ChildKey)
        self:CollapseItems(CurParentKey)
        self.AdapterMenu:SetIsExpansion(CurParentKey, true)
    else
        self.NeedTrigger = false
    end
end

function HouseCommMenuView:GetLastSelectKey()
    return self.LastMainSelectedKey, self.LastSubSelectKey
end

function HouseCommMenuView:ScrollToItemByKey(Key)
    if not self.LastMainSelectedKey then return end
    local Index
    if self:IsParentKey(Key) then
        Index = self:GetParentIndexByParentKey(Key)
    else
        Index = self:GetChildIndexByChildKey(Key)
    end

    if Index then
        self.AdapterMenu:ScrollToIndex(Index)
    end
end

function HouseCommMenuView:GetParentIndexByParentKey(Key)
    if next(self.ListData) then
        for i, v in ipairs(self.ListData) do
            if v.Key == Key then
                return i
            end
        end
    end
end

function HouseCommMenuView:GetChildIndexByChildKey(Key)
    for i, v in ipairs(self.ListData) do
        local ChildData = self.ListData[i] and self.ListData[i].Children or {}
        if next(ChildData) then
            for ChildIndex, ChildData in ipairs(ChildData) do
                if ChildData.Key == Key then
                    return ChildIndex + i
                end
            end
        end
    end
end

function HouseCommMenuView:SetSelectedChildKey(ParentKey, ChildKey)
    if not self.IsCacheLastIndex then return end

    for _, Value in ipairs(self.SelectedChildKeyMap) do
        if Value.ParentKey == ParentKey then
            Value.ChildKey = ChildKey
            --刷新右边道具栏
            HouseMainPanelVM:ChangeTab(_G.HousingMgr:GetHouseModel(), ParentKey, ChildKey)
            break
        end
    end
end

function HouseCommMenuView:OnHouseMainPanelTabMenuChange(Param)
    local HouseCommon = require("Game/House/HouseCommon")
    local HousingMgr = _G.HousingMgr

    local ParentKey = Param.ParentKey
    local ChildIndex = Param.ChildIndex

    -- 此处写死了
    local HouseModel = HousingMgr:GetHouseModel()
    if HouseModel == HouseCommon.HouseModel.IndoorTerritoryModel then
        local Floor = HousingMgr:GetIndoorTerritoryFloor()
        if Floor == HouseCommon.FloorCategory.FLOOR_CATEGORY_COMMON then
            ChildIndex = 3
        end
    elseif HouseModel == HouseCommon.HouseModel.HouseTerritoryModel then
        local Type = HousingMgr:GetHouseTerritoryType()
        if Type == HouseCommon.TerritoryOptType.Base then
            if ChildIndex >= 2 then
                ChildIndex = ChildIndex + 1
            end
        end
    end
    
    for _, ParentItem in ipairs(self.ListData) do
        if ParentItem.Key == ParentKey then
            local ChildItem = ParentItem.Children[ChildIndex]
            if ChildItem then
                self.AdapterMenu:SetSelectedKey(ChildItem.Key)
            end
            return
        end
    end
end

return HouseCommMenuView