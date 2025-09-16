---
--- Author: xingcaicao
--- DateTime: 2023-03-21 19:15
--- Description: 通用下拉框
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local WidgetCallback = require("UI/WidgetCallback")
local UIBindableList = require("UI/UIBindableList")
local CommonUtil = require("Utils/CommonUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local FLinearColor = _G.UE.FLinearColor

local CommDropDownListItemNewVM = require("Game/Common/DropDownList/VM/CommDropDownListItemNewVM")

---@class CommDropDownListView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DropListPanel UFCanvasPanel
---@field ExtendItem CommDropDownExtendItemView
---@field ImgBar UFImage
---@field ImgDown UFImage
---@field ImgIcon UFImage
---@field ImgListBg UFImage
---@field ImgUp UFImage
---@field RedDot CommonRedDotView
---@field RedDot2 CommonRedDot2View
---@field SizeBox USizeBox
---@field SizeBoxRange USizeBox
---@field TableViewItemList UTableView
---@field TextContent UFTextBlock
---@field TextQuantity UFTextBlock
---@field ToggleBtnExtend UToggleButton
---@field DropDown bool
---@field ParamShowIcon bool
---@field ParamIcon SlateBrush
---@field PositionUp Vector2D
---@field PositionDown Vector2D
---@field AlignmentUp Vector2D
---@field AlignmentDown Vector2D
---@field CommDropDownListStyle CommDropDownListParams
---@field StyleIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommDropDownListView = LuaClass(UIView, true)

function CommDropDownListView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DropListPanel = nil
	--self.ExtendItem = nil
	--self.ImgBar = nil
	--self.ImgDown = nil
	--self.ImgIcon = nil
	--self.ImgListBg = nil
	--self.ImgUp = nil
	--self.RedDot = nil
	--self.RedDot2 = nil
	--self.SizeBox = nil
	--self.SizeBoxRange = nil
	--self.TableViewItemList = nil
	--self.TextContent = nil
	--self.TextQuantity = nil
	--self.ToggleBtnExtend = nil
	--self.DropDown = nil
	--self.ParamShowIcon = nil
	--self.ParamIcon = nil
	--self.PositionUp = nil
	--self.PositionDown = nil
	--self.AlignmentUp = nil
	--self.AlignmentDown = nil
	--self.CommDropDownListStyle = nil
	--self.StyleIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommDropDownListView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ExtendItem)
	self:AddSubView(self.RedDot)
	self:AddSubView(self.RedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommDropDownListView:OnInit()
    self.OnSelectionChanged = WidgetCallback.New()

    self.DropDownItemList = UIBindableList.New(CommDropDownListItemNewVM)

    self.ItemIsSelectedFunc = function(ItemVM, Index)
        ---屏蔽下相同项点击
        if self.SelectedIndex == Index then
            return
        end
        if self.IsSelectedFunc then
            return self.IsSelectedFunc(ItemVM)
        end
    end
    self.SelectedIndex = nil
    self.IsCancelHideClearSelected = false
    self.IsShowExtendItem = false
    self.ExtendData = nil
    self.ForceTrigger = false
    self.TextContent:SetText("")
    ---默认朝下
    self:SetIsUpward(false)

    self.PreClickDropDownFunc = nil
end

function CommDropDownListView:OnDestroy()
    self.OnSelectionChanged:Clear()
    self.OnSelectionChanged = nil
end

function CommDropDownListView:OnShow()
    ---防止onshow时外部未设置选中，显示上次的内容,不触发事件，避免影响之前的接入
    self:SetSelectedIndex(self.SelectedIndex or 1, nil, true)
end

function CommDropDownListView:OnHide()
    if not self.IsCancelHideClearSelected then
        self.SelectedIndex = nil
    end
    self.ToggleBtnExtend:SetIsChecked(false)
    UIUtil.SetIsVisible(self.ExtendItem, false)
end

function CommDropDownListView:OnRegisterUIEvent()
    UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnExtend, self.OnStateChangedEvent)
end

function CommDropDownListView:OnRegisterGameEvent()

end

function CommDropDownListView:OnRegisterBinder()

end

function CommDropDownListView:SetForceTrigger(flag)
    self.ForceTrigger = flag
end

function CommDropDownListView:OnStateChangedEvent(ToggleButton, State)
    local IsChecked = UIUtil.IsToggleButtonChecked(State)
    --UIUtil.SetIsVisible(self.DropListPanel, IsChecked)
    if IsChecked then
        if self.PreClickDropDownFunc then
            self.PreClickDropDownFunc()
        end
        
        local Style = {}
        if self.StyleIndex + 1 <= self.CommDropDownListStyle:Length() then
            Style = self.CommDropDownListStyle[self.StyleIndex + 1]
        end
        local Data = {
            TargetWidget = self.ToggleBtnExtend,
            SelectedIndex = self.SelectedIndex,
            OnItemSelectChangedFunc = self.OnItemSelectChanged,
            FuncOwner = self,
            DropDownItemList = self.DropDownItemList,
            IsShowExtendItem = self.IsShowExtendItem,
            ExtendData = self.ExtendData,
            ImgListBgIcon = Style.ImgListBg,
            ImgExtendLineColor = Style.ImgExtendLineColor,
            ExtendImgIcon = Style.ExtendImgIcon,
            IsUpward = self.IsUpward,
        }
        UIViewMgr:ShowView(UIViewID.CommDropDownListNew,   Data)
    else
        UIViewMgr:HideView(UIViewID.CommDropDownListNew)
    end
end

---OnItemSelectChanged
---@param Index number
---@param ItemData any
---@param ItemView UIView
function CommDropDownListView:OnItemSelectChanged(Index, InItemData, ItemView, IsByClick)
    if IsByClick or Index ~= self.SelectedIndex then
        self.ToggleBtnExtend:SetIsChecked(false)
    end
    local ItemData
    if nil == InItemData then
        ItemData = self.DropDownItemList:Get(Index)
    else
        ItemData = InItemData
    end
    if nil == ItemData then
        return
    end

    self.TextContent:SetText(ItemData.Title or ItemData.Name) --在回调触发前执行，就可以在OnSelectionChanged中对TextContent进行加工处理

    ---相同选中可能会有刷新显示需求
    if self.SelectedIndex ~= Index or (self.ForceTrigger == true and IsByClick ~= nil) then
        self.SelectedIndex = Index
        self.OnSelectionChanged:OnTriggered(Index, ItemData, ItemView, IsByClick)
    end

    if nil ~= ItemData.IconPath then
        UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, ItemData.IconPath)
        if ItemData.ImgIconColorbSameasText then
            self.ImgIcon:SetColorAndOpacity(ItemData.TitleTextContentColor)
        end
        UIUtil.SetIsVisible(self.ImgIcon, true)
        UIUtil.SetIsVisible(self.SizeBox, true)
    else
        UIUtil.SetIsVisible(self.SizeBox, false)
    end
end

function CommDropDownListView:SetSelectedIndex(Index, InItemData, NoCallBack)
    local ItemData
    if nil == InItemData then
        ItemData = self.DropDownItemList:Get(Index)
    else
        ItemData = InItemData
    end
    if nil == ItemData then
        return
    end
    self.ToggleBtnExtend:SetIsChecked(false)
    
    if self.SelectedIndex ~= Index then
        self.SelectedIndex = Index

        if not NoCallBack then
            self.OnSelectionChanged:OnTriggered(Index, ItemData)
        end
    end
    self.TextContent:SetText(ItemData.Title or ItemData.Name)
    if nil ~= ItemData.IconPath then
        UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, ItemData.IconPath)
        UIUtil.SetIsVisible(self.ImgIcon, true)
        UIUtil.SetIsVisible(self.SizeBox, true)
    else
        UIUtil.SetIsVisible(self.SizeBox, false)
    end
    if UIViewMgr:IsViewVisible(UIViewID.CommDropDownListNew) then
        local CommDropDownListNewView =  UIViewMgr:FindVisibleView(UIViewID.CommDropDownListNew)
        if CommDropDownListNewView then
            CommDropDownListNewView:SetSelectedIndex(Index)
        end
    end
    --self.TableViewAdapter:SetSelectedIndex(Index)
end

function CommDropDownListView:SetSelectedIndexByItemVM(ItemVM)
    local Index = self.DropDownItemList:GetItemIndex(ItemVM)
    if Index then
        self:SetSelectedIndex(Index, ItemVM)
    end
end

---UpdateItems
---@param ListData table @不显示Icon时 不用传递IconPath { {Name = "Name1", IconPath="IconPath1"，IsShowIcon = bool, RightIconPath="RightIconPath1", IsShowRightIcon = bool, ClickFunc = func1(ItemVM) return IsSelected end, IsNew = bool, ItemData = {}}, {Name = "Name2", IconPath="IconPath2",IsShowIcon = bool, RightIconPath="RightIconPath2", IsShowRightIcon = bool, ClickFunc = func2(ItemVM) return IsSelected  end, IsNew = bool, ItemData = {}}  }
---@private SelectedIndex number @当前选中索引 从 1 开始
---@param IsSelectedFunc @通用点击切换判断函数,如果Item传了ClickFunc，会优先使用ClickFunc
function CommDropDownListView:UpdateItems(ListData, InSelectedIndex, IsSelectedFunc)
    --local TableViewAdapter = self.TableViewAdapter

    self.IsSelectedFunc = IsSelectedFunc
    local Style
    if self.StyleIndex + 1 <= self.CommDropDownListStyle:Length() then
        Style = self.CommDropDownListStyle[self.StyleIndex + 1]
        --Style = self.CommDropDownListStyle:GetRef(self.StyleIndex + 1)
    else
        _G.FLOG_WARNING("CommDropDownListView:UpdateItems Style is nil")
        return
    end
    if self.IsSelectedFunc then
        for _, Data in ipairs(ListData) do
            Data.IsSelectedFunc = self.ItemIsSelectedFunc
        end
    end
    local IsUIBindableListData = CommonUtil.IsA(ListData, UIBindableList)
    if IsUIBindableListData then
        self.DropDownItemList = ListData
        local Items = self.DropDownItemList:GetItems()
        if Items then
            for _, Item in ipairs(Items) do
                if self.IsSelectedFunc then
                    Item.IsSelectedFunc = self.ItemIsSelectedFunc
                end
                local ItemTextContentColor = self:GetLinearColorBySlateColor(Style.ItemTextContentColor)
                local ItemTextContenSelectedColor = self:GetLinearColorBySlateColor(Style.ItemTextContenSelectedColor)
                local ImgLineColor = self:GetLinearColorBySlateColor(Style.ImgLineColor)
                local ImgSelectColor = self:GetLinearColorBySlateColor(Style.ImgSelectColor)
                local TitleTextContentColor = self:GetLinearColorBySlateColor(Style.TitleTextContentColor)
                --Item.Style = Style
                ---防止崩溃，用rawset设置颜色变量
                rawset(Item, "ItemTextContentColor", ItemTextContentColor)
                rawset(Item, "ItemTextContenSelectedColor", ItemTextContenSelectedColor)
                rawset(Item, "ImgLineColor", ImgLineColor)
                rawset(Item, "ImgSelectColor", ImgSelectColor)
                rawset(Item, "TitleTextContentColor", TitleTextContentColor)
                rawset(Item, "Style", Style)
            end
        end
    else
        for _, Data in ipairs(ListData) do
            if self.IsSelectedFunc then
                Data.IsSelectedFunc = self.ItemIsSelectedFunc
            end
            local ItemTextContentColor = self:GetLinearColorBySlateColor(Style.ItemTextContentColor)
            local ItemTextContenSelectedColor = self:GetLinearColorBySlateColor(Style.ItemTextContenSelectedColor)
            local ImgLineColor = self:GetLinearColorBySlateColor(Style.ImgLineColor)
            local ImgSelectColor = self:GetLinearColorBySlateColor(Style.ImgSelectColor)
            local TitleTextContentColor = self:GetLinearColorBySlateColor(Style.TitleTextContentColor)
            --Data.Style = Style
            rawset(Data, "ItemTextContentColor", ItemTextContentColor)
            rawset(Data, "ItemTextContenSelectedColor", ItemTextContenSelectedColor)
            rawset(Data, "ImgLineColor", ImgLineColor)
            rawset(Data, "ImgSelectColor", ImgSelectColor)
            rawset(Data, "TitleTextContentColor", TitleTextContentColor)
            rawset(Data, "Style", Style)
        end
        self.DropDownItemList:UpdateByValues(ListData)
    end


    --TableViewAdapter:UpdateAll(self.DropDownItemList)
    --TableViewAdapter:UpdateAll(ListData)

    --self.SelectedIndex = SelectedIndex or 1
    local SelectedIndex = InSelectedIndex or 1
    self:OnItemSelectChanged(SelectedIndex, self.DropDownItemList:Get(SelectedIndex), nil, false)

    --TableViewAdapter:SetSelectedIndex(SelectedIndex)
end

---@param IsSelectedFunc @通用点击切换判断函数,如果Item传了ClickFunc，会优先使用ClickFunc
function CommDropDownListView:SetIsSelectFunc(IsSelectedFunc)
    if nil == self.IsSelectedFunc then
        local Items = self.DropDownItemList:GetItems()
        self.IsSelectedFunc = IsSelectedFunc
        if Items then
            for _, Item in ipairs(Items) do
                Item.IsSelectedFunc = self.ItemIsSelectedFunc
            end
        end
    else
        self.IsSelectedFunc = IsSelectedFunc
    end
end

function CommDropDownListView:SetPreClickDropDownFunc(PreClickDropDownFunc)
    self.PreClickDropDownFunc = PreClickDropDownFunc
end

function CommDropDownListView:ResetDropDown()
    self:SetDownListNewViewSelected(1)
end

function CommDropDownListView:SetDropDownIndex(Index)
    self:SetDownListNewViewSelected(Index)
end

function CommDropDownListView:FoldDropDown()
    self.ToggleBtnExtend:SetIsChecked(false)
end

---设置扩展项
---@param Name string @扩展项名
---@param IsVisible boolean @扩展项是否可见
---@param ClickCBFunc function @扩展项被点击回调函数
function CommDropDownListView:SetExtendItem( Name, IsVisible, ClickCBFunc )
    local CommDropDownListNewView =  UIViewMgr:FindVisibleView(UIViewID.CommDropDownListNew)
    if CommDropDownListNewView then
        CommDropDownListNewView:SetExtendItem( Name, IsVisible, ClickCBFunc )
    end
    self.IsShowExtendItem = IsVisible
    self.ExtendData = {Name = Name,ClickCBFunc = ClickCBFunc}
    --self.ExtendItem:SetData(Name, ClickCBFunc)
    --UIUtil.SetIsVisible(self.ExtendItem, IsVisible)
end

function CommDropDownListView:GetDropDownItemVM(ID)
    if nil == ID then
        return
    end

    return self.DropDownItemList:Find(function(e) return e.ID == ID end)
end

function CommDropDownListView:GetDropDownItemDataByIndex(Index)
    if nil == Index then
        return
    end

    return self.DropDownItemList:Get(Index)
end

function CommDropDownListView:GetIndexByItemData(ItemData)
    if nil == ItemData then
        return
    end

    return self.DropDownItemList:GetItemIndex(ItemData)
end

function CommDropDownListView:GetIndexByPredicate(Predicate)
    return self.DropDownItemList:GetItemIndexByPredicate(Predicate)
end

--- 设置当前选中
function CommDropDownListView:SetDownListNewViewSelected(Index)
    if UIViewMgr:IsViewVisible(UIViewID.CommDropDownListNew) then
        local CommDropDownListNewView =  UIViewMgr:FindVisibleView(UIViewID.CommDropDownListNew)
        if CommDropDownListNewView then
            CommDropDownListNewView:SetSelectedIndex(Index)
            return true
        else
            self:OnItemSelectChanged(Index, self.DropDownItemList:Get(Index), nil, false)
            return false
        end
    end
    self:OnItemSelectChanged(Index, self.DropDownItemList:Get(Index), nil, false)
    return false
end

function CommDropDownListView:CancelSelected()
    self.SelectedIndex = nil

    local CommDropDownListNewView =  UIViewMgr:FindVisibleView(UIViewID.CommDropDownListNew)
    if CommDropDownListNewView then
        CommDropDownListNewView:CancelSelected()
        return true
    end
    return false
end

--- 规避崩溃，用LinearColor设置UI
function CommDropDownListView:GetLinearColorBySlateColor(SlateColor)
    if SlateColor then
        local LinearColor = SlateColor:GetSpecifiedColor()
        LinearColor = FLinearColor(LinearColor.R, LinearColor.G, LinearColor.B, LinearColor.A)
        return LinearColor
    else
        return FLinearColor(1, 1, 1, 1)
    end
end

---部分系统希望hide时不清理选中，提供接口
function CommDropDownListView:SetIsCancelHideClearSelected(InIsCancelHideClearSelected)
    self.IsCancelHideClearSelected = InIsCancelHideClearSelected
end

---部分系统希望修改展开方向
function CommDropDownListView:SetIsUpward(InIsUpward)
    self.IsUpward = InIsUpward
    if self.IsUpward then
        self.ImgDown:SetRenderTransformAngle(180)
        self.ImgUp:SetRenderTransformAngle(0)
    else
        self.ImgDown:SetRenderTransformAngle(0)
        self.ImgUp:SetRenderTransformAngle(180)
    end
end

function CommDropDownListView:ClearItems()
    self.DropDownItemList:Clear()
end

function CommDropDownListView:IsEmpty()
    return self.DropDownItemList:Length() <= 0
end

return CommDropDownListView