---
--- Author: chriswang
--- DateTime: 2025-04-21 16:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
--local CommDropDownListNewVM = require("Game/Common/DropDownList/VM/CommDropDownListNewVM")
--local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
--local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UUIUtil = _G.UE.UUIUtil
local UKismetInputLibrary = UE.UKismetInputLibrary
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

---@class SettingDropDownListView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DropListPanel UFCanvasPanel
---@field ImgListBg UFImage
---@field SizeBoxRange USizeBox
---@field TableViewItemList UTableView
---@field ItemHeight int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingDropDownListView = LuaClass(UIView, true)
local ListItemBatchNum = 15

function SettingDropDownListView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DropListPanel = nil
	--self.ImgListBg = nil
	--self.SizeBoxRange = nil
	--self.TableViewItemList = nil
	--self.ItemHeight = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingDropDownListView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingDropDownListView:OnInit()
	self.IsFlip = false
	--self.ViewModel = CommDropDownListNewVM.New()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewItemList, self.OnItemSelectChanged, true)
	-- self.Binders = {
	-- 	--{ "DropDownItemList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
	-- 	--{ "ExtendItemData", UIBinderValueChangedCallback.New(self, nil, self.SetExtendItem)},
	-- 	--{ "IsShowExtendItem", UIBinderSetIsVisible.New(self, self.ExtendItem) },
	-- }
end

function SettingDropDownListView:OnDestroy()

end

function SettingDropDownListView:OnShow()
	if nil == self.Params then
		return
	end
	local Params = table.clone(self.Params)
	if nil == Params then
		return
	end
	self.IsUpward = Params.IsUpward
	---Style设置
	self.ImgListBg:SetBrush(Params.ImgListBgIcon)
	-- self.ExtendItem:SetStyle(Params.ExtendImgIcon)
	-- self.ImgExtendLine:SetBrushTintColor(Params.ImgExtendLineColor)

	local SelectedIndex = Params.SelectedIndex or 1
	self.DropDownItemList = Params.DropDownItemList
	---todo 分帧处理
	self.TableViewAdapter:UpdateAll(self.DropDownItemList)
	self.TableViewAdapter:SetSelectedIndex(SelectedIndex)
	self.TableViewAdapter:ScrollIndexIntoView(SelectedIndex)
	local TargetWidgetSize
	if Params and Params.TargetWidget then
		TargetWidgetSize = UUIUtil.GetLocalSize(Params.TargetWidget)
	else
		TargetWidgetSize = {X = 0, Y = 0}
	end
	--self.ViewModel:SetDropDownItemList(self.Params.DropDownItemList)
	self.SizeBoxRange:SetWidthOverride(TargetWidgetSize.X)
	--- 位置设置
	local ViewportSize = UIUtil.GetViewportSize()
	local WidgetAbsolute
	---没有复现self.Params在这为空的情况，怀疑是哪里置空了，先判空 + 换个表存规避
	if Params and Params.TargetWidget then
		WidgetAbsolute = UIUtil.GetWidgetAbsolutePosition(Params.TargetWidget)
	else
		WidgetAbsolute = {X = 0, Y = 0}
	end
	local WindowAbsolute = UIUtil.ScreenToWidgetAbsolute(_G.UE.FVector2D(0, 0), false)
	local ItemWidgetHeight = self.ItemHeight or 62
	local ItemNum = self.DropDownItemList:Length()
	local ListSize = UIUtil.GetWidgetSize(self.TableViewItemList)
	local ListHeightMax = self.SizeBoxRange.MaxDesiredHeight
    local ListHeigh = ItemWidgetHeight * ItemNum
	if ListHeigh > ListHeightMax then
		ListHeigh = ListHeightMax
	end
	local WidgetHeight = ListHeigh - ListSize.Y
	-- if Params.IsShowExtendItem then
	-- 	local ExtendItemSize = UIUtil.GetWidgetSize(self.ExtendItem)
	-- 	WidgetHeight = WidgetHeight + ExtendItemSize.Y
	-- end
	local DPIScale = UIUtil.GetViewportScale()
	local ViewWidgetHeight = WidgetHeight * DPIScale
	local ViewTargetWidgetHeight = TargetWidgetSize.Y * DPIScale
	local Offset
	if self.IsUpward then
		if WidgetAbsolute.Y - ViewWidgetHeight - WindowAbsolute.Y < 0 then
			self.IsFlip = true
			Offset = _G.UE.FVector2D(-TargetWidgetSize.X, TargetWidgetSize.Y)
		else
			self.IsFlip = false
			Offset = _G.UE.FVector2D(-TargetWidgetSize.X, - WidgetHeight)
		end
	else
		if ViewWidgetHeight + WidgetAbsolute.Y + ViewTargetWidgetHeight - WindowAbsolute.Y > ViewportSize.Y then
			self.IsFlip = true
			Offset = _G.UE.FVector2D(-TargetWidgetSize.X, - WidgetHeight)
		else
			self.IsFlip = false
			Offset = _G.UE.FVector2D(-TargetWidgetSize.X, TargetWidgetSize.Y)
		end
	end

	Offset.X = Offset.X - 7
	--todo 位置计算
	UIUtil.AdjustTipsPosition2(self.DropListPanel, Params.TargetWidget, Offset)
	self.FuncOwner = Params.FuncOwner
	self.OnItemSelectChangedFunc = Params.OnItemSelectChangedFunc
	
	--下一帧执行
    -- local function DelayUpdatePosition()
    --  local ViewportSize = UIUtil.GetViewportSize()
	-- 	local WidgetSize = UUIUtil.GetWidgetSize(self.DropListPanel)
	-- 	local WidgetAbsolute = UIUtil.GetWidgetAbsolutePosition(Params.TargetWidget)
	-- 	local WindowAbsolute = UIUtil.ScreenToWidgetAbsolute(_G.UE.FVector2D(0, 0), false)
	-- 	if WidgetSize.Y + WidgetAbsolute.Y + TargetWidgetSize.Y - WindowAbsolute.Y > ViewportSize.Y then

	-- 	end
    -- end
    -- self.PosTimer = _G.TimerMgr:AddTimer(nil, DelayUpdatePosition, 0.1, 1, 1)
	-- 无法确定TableView什么时候完成布局计算,先用Item高度和数量来手动计算是否翻转
	-- if Params.ExtendData then
	-- 	self:SetExtendItem( Params.ExtendData.Name, Params.IsShowExtendItem, Params.ExtendData.ClickCBFunc )
	-- else
	-- 	self:SetExtendItem( nil, false, nil )
	-- end
end

function SettingDropDownListView:OnHide()
	if self.PosTimer ~= nil then
		_G.TimerMgr:CancelTimer(self.PosTimer)
		self.PosTimer = nil
	end
	--- 清空颜色，防止崩溃
	if self.DropDownItemList then
		for _, ItemVM in ipairs(self.DropDownItemList) do
			ItemVM.ItemTextContentColor = nil
			ItemVM.ItemTextContenSelectedColor = nil
			ItemVM.ImgLineColor = nil
			ItemVM.ImgSelectColor = nil
		end
	end
end

function SettingDropDownListView:OnRegisterUIEvent()

end

function SettingDropDownListView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function SettingDropDownListView:OnRegisterBinder()
	--self:RegisterBinders(self.ViewModel, self.Binders)

end

-- function SettingDropDownListView:SetExtendItem(ExtendItemData)
-- 	if ExtendItemData then
-- 		self.ExtendItem:SetData(ExtendItemData.Name, ExtendItemData.ClickCBFunc)
-- 	end
-- end

---设置扩展项
---@param Name string @扩展项名
---@param IsVisible boolean @扩展项是否可见
---@param ClickCBFunc function @扩展项被点击回调函数
function SettingDropDownListView:SetExtendItem( Name, IsVisible, ClickCBFunc )
	-- self.ExtendItem:SetData(Name, ClickCBFunc)
	-- UIUtil.SetIsVisible(self.ExtendPanel, IsVisible)
	-- if IsVisible and self.Params and not self.Params.IsShowExtendItem then
	-- 	local Slot = UIUtil.SlotAsCanvasSlot(self.DropListPanel)
	-- 	local Pos = Slot:GetPosition()
	-- 	local ExtendItemSize = UIUtil.GetWidgetSize(self.ExtendItem)
	-- 	Pos.Y = Pos.Y - ExtendItemSize.Y
	-- 	if nil == Slot then
	-- 		return
	-- 	end
	-- 	Slot:SetPosition(Pos)
	-- end
end

function SettingDropDownListView:SetSelectedIndex(SelectedIndex)
	self.TableViewAdapter:SetSelectedIndex(SelectedIndex)
end

function SettingDropDownListView:OnItemSelectChanged(Index, ItemData, ItemView, IsByClick)
	local Params = self.Params 
	if nil == Params then
		return
	end
	if Params.OnItemSelectChangedFunc and Params.FuncOwner then
		Params.OnItemSelectChangedFunc(Params.FuncOwner, Index, ItemData, ItemView, IsByClick)
	end
end

function SettingDropDownListView:OnPreprocessedMouseButtonDown(MouseEvent)
	local Params = self.Params
	if Params == nil then
		return
	end
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.DropListPanel, MousePosition) == false and UIUtil.IsUnderLocation(Params.TargetWidget, MousePosition) == false then
		local Index = Params.SelectedIndex or 1
		local ItemData = self.DropDownItemList[Index] or self.DropDownItemList:Get(Index)
		Params.OnItemSelectChangedFunc(Params.FuncOwner, Index, ItemData, nil, true)
		UIViewMgr:HideView(UIViewID.SettingDropDownListNew)
	end
end

function SettingDropDownListView:CancelSelected()
	self.TableViewAdapter:CancelSelected()

end

return SettingDropDownListView