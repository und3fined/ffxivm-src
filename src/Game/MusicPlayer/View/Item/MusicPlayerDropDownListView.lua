---
--- Author: Administrator
--- DateTime: 2023-12-08 11:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local WidgetCallback = require("UI/WidgetCallback")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")


---@class MusicPlayerDropDownListView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DropListPanel UFCanvasPanel
---@field ExtendItem CommDropDownExtendItemView
---@field ImgDown UFImage
---@field ImgIcon UFImage
---@field ImgListBg UFImage
---@field ImgUp UFImage
---@field SizeBoxRange USizeBox
---@field TableViewItemList UTableView
---@field TextContent UFTextBlock
---@field ToggleBtnExtend UToggleButton
---@field DropDown bool
---@field ParamShowIcon bool
---@field ParamIcon SlateBrush
---@field PositionUp Vector2D
---@field PositionDown Vector2D
---@field AlignmentUp Vector2D
---@field AlignmentDown Vector2D
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MusicPlayerDropDownListView = LuaClass(UIView, true)

function MusicPlayerDropDownListView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DropListPanel = nil
	--self.ExtendItem = nil
	--self.ImgDown = nil
	--self.ImgIcon = nil
	--self.ImgListBg = nil
	--self.ImgUp = nil
	--self.SizeBoxRange = nil
	--self.TableViewItemList = nil
	--self.TextContent = nil
	--self.ToggleBtnExtend = nil
	--self.DropDown = nil
	--self.ParamShowIcon = nil
	--self.ParamIcon = nil
	--self.PositionUp = nil
	--self.PositionDown = nil
	--self.AlignmentUp = nil
	--self.AlignmentDown = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MusicPlayerDropDownListView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ExtendItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MusicPlayerDropDownListView:OnInit()
	self.OnSelectionChanged = WidgetCallback.New()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewItemList, self.OnItemSelectChanged, false)
end

function MusicPlayerDropDownListView:OnDestroy()
	self.OnSelectionChanged:Clear()
	self.OnSelectionChanged = nil
end

function MusicPlayerDropDownListView:OnShow()

end

function MusicPlayerDropDownListView:OnHide()
	self.ToggleBtnExtend:SetIsChecked(false)
	UIUtil.SetIsVisible(self.ExtendItem, false)
end

function MusicPlayerDropDownListView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnExtend, self.OnStateChangedEvent)
end

function MusicPlayerDropDownListView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateDropState, self.UpdateDropListPanelState)
end

function MusicPlayerDropDownListView:OnRegisterBinder()

end

function MusicPlayerDropDownListView:UpdateDropListPanelState(State)
	self.ToggleBtnExtend:SetIsChecked(State)
	UIUtil.IsToggleButtonChecked(State)
	UIUtil.SetIsVisible(self.DropListPanel, State)
end

function MusicPlayerDropDownListView:OnStateChangedEvent(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	if IsChecked then
		FLOG_ERROR("MusicPlayerDropDownListView ScrollToTop")
		self.TableViewAdapter:ScrollToTop()
	end
	UIUtil.SetIsVisible(self.DropListPanel, IsChecked)
	EventMgr:SendEvent(EventID.ClickDrop, State)
end

---OnItemSelectChanged
---@param Index number
---@param ItemData any
---@param ItemView UIView
function MusicPlayerDropDownListView:OnItemSelectChanged(Index, ItemData, ItemView, IsByClick)
	self.ToggleBtnExtend:SetIsChecked(false)
	self.OnSelectionChanged:OnTriggered(Index, ItemData, ItemView, IsByClick)
	self.TextContent:SetText(ItemData.Title or ItemData.Name)

	if nil ~= ItemData.IconPath then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, ItemData.IconPath)
	end
end

function MusicPlayerDropDownListView:SetSelectedIndex(Index,ItemData)
	self.ToggleBtnExtend:SetIsChecked(false)
	self.OnSelectionChanged:OnTriggered(Index)
	self.TextContent:SetText(ItemData.Title or ItemData.Name)
	self.TableViewAdapter:SetSelectedIndex(Index)
end

function MusicPlayerDropDownListView:ResetDropDown()
	self.TableViewAdapter:SetSelectedIndex(1)
end

---UpdateItems
---@param ListData table @不显示Icon时 不用传递IconPath { {Name = "Name1", IconPath="IconPath1"}, {Name = "Name2", IconPath="IconPath2"}  }
---@private SelectedIndex number @当前选中索引 从 1 开始
function MusicPlayerDropDownListView:UpdateItems(ListData, SelectedIndex)
	local TableViewAdapter = self.TableViewAdapter

	TableViewAdapter:UpdateAll(ListData)

	SelectedIndex = SelectedIndex or 1

	TableViewAdapter:SetSelectedIndex(SelectedIndex)
end

return MusicPlayerDropDownListView